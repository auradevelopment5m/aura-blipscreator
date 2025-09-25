# Aura Blips Creator - Instructions

## Overview

Aura Blips Creator is a modern, user-friendly tool for FiveM servers that allows you to create, edit, and manage map blips through an interactive UI. It is designed for server owners, making blip management fast, safe, and intuitive.

---

## Features

- **Create Blips:** Add new map blips with custom label, coordinates, sprite, color, scale, secondary color, flashing, and short-range options.
- **Edit Blips:** Modify any existing blip's properties.
- **Remove Blips:** Delete blips with confirmation dialogs to prevent mistakes.
- **Search & Filter:** Quickly find blips by label, coordinates, sprite, or color.
- **Reference Links:** Instantly copy FiveM documentation links for sprite and color IDs.
- **Get Player Coords:** Fetch your current in-game coordinates for precise blip placement.
- **Status Feedback:** Receive clear success or error messages for all actions.
- **Accessible UI:** Designed for both mouse and keyboard navigation, with custom dropdowns and dialogs.

---

## How To Use

### 1. Installation

1. Place the `aura-blipscreator` folder inside your server's `resources` directory.
2. Ensure your `server.cfg` includes:
   ```
   ensure aura-blipscreator
   ```
3. Start your server.

### 2. Accessing the UI

- The UI is opened via the command /blipscreator, or the default keybind "F7".

### 3. Authorization Setup

**Important:** Only authorized users can access the blips creator.

1. Open `config.lua` in the resource folder.
2. Add Discord identifiers to the `Config.AuthorizedDiscords` table:
   ```lua
   Config.AuthorizedDiscords = {
       "discord:123456789012345678", -- Replace with actual Discord ID
       "discord:987654321098765432", -- Add more as needed
       -- Add more Discord IDs here
   }
   ```
3. To find a player's Discord ID:
   - Enable developer mode in Discord (User Settings > Advanced > Developer Mode)
   - Right-click on the user and select "Copy User ID"
   - Format it as `"discord:USERID"` in the config
4. Save the file and restart the resource.

**Note:** Players not in this list will receive an "unauthorized" notification when trying to use the command.

### 4. Creating a Blip

1. Fill in the **Label** (name for your blip).
2. Enter **Coords** (X, Y, Z). Use the "Get Coords" button to auto-fill your current position.
3. Enter **Sprite** and **Color** IDs. Use the "Copy Reference Link" buttons to get the official FiveM documentation for valid IDs.
4. Optionally, set **Scale**, **Secondary Color**, **Flashing**, and **Short Range**.
5. Click **Create Blip**. Confirm in the dialog.
6. A status message will confirm success or show errors if any fields are invalid.

### 5. Viewing & Managing Blips

- Switch to the "Active Blips" list to see all current blips.
- Use the search bar to filter blips.
- Click **Edit** to modify a blip, or **Remove** to delete it (with confirmation).
- Restart Resource

### 6. Editing a Blip

- In the list, click **Edit** on any blip.
- Change any fields as needed and click **Save Changes**.
- Cancel to discard changes.
- Restart Resource

### 7. Removing a Blip

- In the list, click **Remove** on any blip.
- Confirm removal in the dialog.
- Restart Resource 

---

## Integration & Customization

- Supports all frameworks including OX/ESX/QBCore/QBox/Standalone.
- The UI is built with Svelte and can be customized by editing the files in `web/src`.

---

## Support

- **Discord:** https://discord.gg/2q8ZBSWPv7
- **Preview:**
- **Documentation:** https://docs.auradev.dev/blipscreator

---

## Notes

- Only users with appropriate permissions should be allowed to open and use the UI.
- For active blip management, restart the resource after any changes like deletion and editing.

---
