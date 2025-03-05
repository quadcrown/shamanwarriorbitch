-- Create the main frame for the SWB addon
local SWB = CreateFrame("Frame", "SWBFrame", UIParent)
SWB:SetMovable(true)
SWB:EnableMouse(true)
SWB:RegisterForDrag("LeftButton")
SWB:SetScript("OnDragStart", function() SWB:StartMoving() end)
SWB:SetScript("OnDragStop", function()
    SWB:StopMovingOrSizing()
    -- Save the frame's position
    local point, _, _, x, y = SWB:GetPoint()
    SWBDB.posX = x
    SWBDB.posY = y
end)
SWB:SetBackdrop(nil) -- No backdrop for the frame

-- Create buttons for up to 5 group members (player + 4 party)
SWB.buttons = {}
for i = 1, 5 do
    local button = CreateFrame("Button", nil, SWB)
    button:SetWidth(32)
    button:SetHeight(32)
    button:SetNormalTexture("Interface\\Icons\\Spell_Nature_Windfury")
    button.nameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.nameText:SetPoint("BOTTOM", button, "TOP", 0, 2) -- Name above icon
    button.overlay = button:CreateTexture(nil, "OVERLAY")
    button.overlay:SetAllPoints()
    button.overlay:SetTexture(0, 1, 0, 0.3) -- Green overlay for aura
    button.overlay:Hide()
    button.timerText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.timerText:SetPoint("CENTER", button, "CENTER") -- Timer on icon
    button.timerText:SetText("")
    -- Enable right-click to toggle layout
    button:EnableMouse(true)
    button:RegisterForClicks("RightButtonUp")
    button:SetScript("OnMouseUp", function(self, mouseButton)
        if mouseButton == "RightButton" then
            SWBDB.layout = (SWBDB.layout == "horizontal") and "vertical" or "horizontal"
            UpdateGroup()
            DEFAULT_CHAT_FRAME:AddMessage("Layout toggled to " .. SWBDB.layout)
        end
    end)
    SWB.buttons[i] = button
end

-- Saved variables for layout, size, timers, and position
SWBDB = SWBDB or { layout = "horizontal", sizeMultiplier = 1.0, showTimers = true, posX = 0, posY = 0 }

-- Variable to track totem timer start time
SWB.totemTimerStart = nil

-- Function to check if a unit has the Windfury aura
local function HasWindfury(unit)
    local index = 1
    while true do
        local texture = UnitBuff(unit, index)
        if not texture then break end
        if texture == "Interface\\Icons\\Spell_Nature_Windfury" then
            return true
        end
        index = index + 1
    end
    return false
end

-- Function to update a button's appearance
local function UpdateButton(button)
    if not button.unit then return end
    local hasWF = HasWindfury(button.unit)
    if hasWF then
        button:SetAlpha(1.0)
        button.overlay:Show()
    else
        button:SetAlpha(0.5)
        button.overlay:Hide()
        button.timerText:SetText("") -- Clear timer if no aura
    end
end

-- Function to update the GUI based on group composition and size multiplier
local function UpdateGroup()
    local numMembers = GetNumPartyMembers() + 1 -- Include player
    if numMembers > 5 then numMembers = 5 end
    local layout = SWBDB.layout or "horizontal"
    local size = 32 * SWBDB.sizeMultiplier
    local spacing = 50 * SWBDB.sizeMultiplier

    for i = 1, 5 do
        local button = SWB.buttons[i]
        if i <= numMembers then
            local unit = (i == 1) and "player" or "party" .. (i - 1)
            local name = UnitName(unit) or ("Party" .. (i - 1))
            button.unit = unit
            button.nameText:SetText(name)
            button:SetWidth(size)
            button:SetHeight(size)
            if layout == "horizontal" then
                button:SetPoint("TOPLEFT", SWB, "TOPLEFT", (i - 1) * spacing, -15 * SWBDB.sizeMultiplier)
            else -- vertical
                button:SetPoint("TOPLEFT", SWB, "TOPLEFT", 0, -15 * SWBDB.sizeMultiplier - (i - 1) * spacing)
            end
            button:Show()
            UpdateButton(button)
        else
            button:Hide()
        end
    end

    -- Adjust frame size
    if layout == "horizontal" then
        SWB:SetWidth(numMembers * spacing)
        SWB:SetHeight(50 * SWBDB.sizeMultiplier)
    else
        SWB:SetWidth(50 * SWBDB.sizeMultiplier)
        SWB:SetHeight(15 * SWBDB.sizeMultiplier + numMembers * spacing)
    end
end

-- Register events
SWB:RegisterEvent("UNIT_AURA")
SWB:RegisterEvent("PARTY_MEMBERS_CHANGED")
SWB:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF") -- For totem drop detection

-- Event handler
SWB:SetScript("OnEvent", function()
    if event == "UNIT_AURA" then
        for _, button in ipairs(SWB.buttons) do
            if button.unit == arg1 then
                UpdateButton(button)
                break
            end
        end
    elseif event == "PARTY_MEMBERS_CHANGED" then
        UpdateGroup()
    elseif event == "CHAT_MSG_SPELL_SELF_BUFF" then
        if arg1 == "You cast Windfury Totem." then
            SWB.totemTimerStart = GetTime()
        end
    end
end)

-- OnUpdate script for timer display
SWB:SetScript("OnUpdate", function()
    if SWBDB.showTimers and SWB.totemTimerStart then
        local elapsed = GetTime() - SWB.totemTimerStart
        local remaining = 120 - elapsed -- 2 minutes
        if remaining > 0 then
            local timeText = math.ceil(remaining)
            local color = (remaining > 15) and "|cffffff00" or "|cffff0000" -- Yellow or red
            for _, button in ipairs(SWB.buttons) do
                if button.unit and HasWindfury(button.unit) then
                    button.timerText:SetText(color .. timeText .. "|r")
                end
            end
        else
            SWB.totemTimerStart = nil
            for _, button in ipairs(SWB.buttons) do
                button.timerText:SetText("")
            end
        end
    else
        for _, button in ipairs(SWB.buttons) do
            button.timerText:SetText("")
        end
    end
end)

-- Slash command handler
SLASH_SWB1 = "/swb"
SlashCmdList["SWB"] = function(msg)
    local cmd = string.lower(msg)
    if cmd == "vertical" or cmd == "horizontal" then
        SWBDB.layout = cmd
        UpdateGroup()
        DEFAULT_CHAT_FRAME:AddMessage("SWB layout set to " .. cmd)
    elseif cmd == "size up" then
        SWBDB.sizeMultiplier = math.min(2.0, SWBDB.sizeMultiplier + 0.25)
        UpdateGroup()
        DEFAULT_CHAT_FRAME:AddMessage("SWB size increased to " .. SWBDB.sizeMultiplier)
    elseif cmd == "size down" then
        SWBDB.sizeMultiplier = math.max(0.5, SWBDB.sizeMultiplier - 0.25)
        UpdateGroup()
        DEFAULT_CHAT_FRAME:AddMessage("SWB size decreased to " .. SWBDB.sizeMultiplier)
    elseif cmd == "timers" then
        SWBDB.showTimers = not SWBDB.showTimers
        DEFAULT_CHAT_FRAME:AddMessage("SWB timers " .. (SWBDB.showTimers and "shown" or "hidden"))
    else
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /swb [horizontal|vertical|size up|size down|timers]")
    end
end

-- Initialize the addon
-- Restore position from saved variables
if SWBDB.posX and SWBDB.posY then
    SWB:ClearAllPoints()
    SWB:SetPoint("TOPLEFT", UIParent, "TOPLEFT", SWBDB.posX, SWBDB.posY)
end

UpdateGroup()