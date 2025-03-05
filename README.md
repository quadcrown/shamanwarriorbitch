# Shaman Warrior Bitch (SWB)

**Shaman Warrior Bitch (SWB)** is a World of Warcraft addon designed for Turtle WoW (1.12.1) that helps shamans track the Windfury Totem aura on themselves and their group members. The addon provides a dynamic graphical user interface (GUI) that displays icons for each group member, showing whether they have the Windfury aura active. It also includes a timer to monitor the totem’s remaining duration, along with options to customize the layout and size of the GUI.

---

## Features

- **Windfury Aura Tracking**: Displays an icon for each group member (up to 5, including the player) and highlights whether the Windfury Totem aura is active on them.
- **Timer Display**: Starts a 2-minute timer when the Windfury Totem is dropped. The timer appears on the icons of members with the aura, displayed in yellow when greater than 15 seconds remain and red when 15 seconds or less remain.
- **Customizable Layout**: Allows switching between horizontal and vertical icon arrangements via slash commands.
- **Resizable GUI**: Lets users adjust the size of the icons and overall GUI using slash commands.
- **Timer Toggle**: Provides an option to show or hide the timer display.
---

## Installation

To install the addon:

1. Download the addon folder.
2. Place the `ShamanWarriorBitch` folder into your `World of Warcraft\Interface\AddOns` directory.
3. Launch the game and ensure the addon is enabled in the AddOns menu.

---

## Commands

The addon supports the following slash commands to customize the GUI:

- `/swb horizontal`  
  Arranges the icons in a horizontal layout (left to right).

- `/swb vertical`  
  Arranges the icons in a vertical layout (top to bottom).

- `/swb size up`  
  Increases the size of the icons and GUI (up to a maximum size multiplier of 2.0).

- `/swb size down`  
  Decreases the size of the icons and GUI (down to a minimum size multiplier of 0.5).

- `/swb timers`  
  Toggles the visibility of the timer display on the icons.

---

## Notes

- This addon is tailored for Turtle WoW (1.12.1) and may not function properly on other versions.
- The timer begins when the Windfury Totem is dropped and runs for 2 minutes, regardless of aura status.
- To reposition the GUI, left-click and drag it to your preferred spot on the screen.
