# AltClipboard - Hammerspoon Spoon

## Project Overview

AltClipboard is a Hammerspoon spoon that provides an alternate clipboard accessible via keyboard shortcuts. This allows users to maintain two separate clipboards: the system clipboard and an "alt" clipboard, enabling more flexible copy/paste workflows.

## Features

- **Customizable keybindings**: Configure your own keyboard shortcuts for cut, copy, and paste operations
- **Default shortcuts**: alt+cmd+c (copy), alt+cmd+x (cut), alt+cmd+v (paste)
- **Multi-format support**: Handles text, images, styled text, files, and any other clipboard data type
- **Non-destructive**: Preserves the system clipboard during alt clipboard operations

## How It Works

### Architecture

The spoon uses Hammerspoon's `eventtap` API to intercept keyboard events:

1. **Event Detection**: Watches for `keyDown` events matching alt+cmd+c, alt+cmd+x, or alt+cmd+v
2. **Flag Manipulation**: Removes the alt/option flag from the event before propagating it
3. **Clipboard Swapping**: Uses timers to swap clipboard contents before and after system copy/cut/paste operations
4. **Multi-format Storage**: Uses `hs.pasteboard.readAllData()` and `hs.pasteboard.writeAllData()` to preserve all clipboard data types

### Copy Flow (alt+cmd+c)

1. User presses alt+cmd+c
2. System clipboard is backed up using `readAllData()`
3. Alt flag is removed from the event
4. Event propagates as cmd+c, triggering normal system copy
5. After 0.5s delay:
   - Newly copied content is read from system clipboard
   - Content is saved to the "alt" pasteboard
   - Original system clipboard is restored

### Cut Flow (alt+cmd+x)

1. User presses alt+cmd+x
2. System clipboard is backed up using `readAllData()`
3. Alt flag is removed from the event
4. Event propagates as cmd+x, triggering normal system cut (copies and deletes selection)
5. After 0.1s delay:
   - Newly cut content is read from system clipboard
   - Content is saved to the "alt" pasteboard
   - Original system clipboard is restored

### Paste Flow (alt+cmd+v)

1. User presses alt+cmd+v
2. System clipboard is backed up using `readAllData()`
3. Alt clipboard content is loaded into system clipboard
4. Alt flag is removed from the event
5. Event propagates as cmd+v, triggering normal system paste
6. After 0.1s delay:
   - Original system clipboard is restored

## Development History

### Initial Implementation

- Created basic spoon structure with metadata and lifecycle methods (`init`, `start`, `stop`)
- Implemented eventtap to watch for alt+cmd+c and alt+cmd+v key combinations
- Used event flag manipulation to convert alt+cmd+c/v into cmd+c/v
- Implemented timer-based clipboard backup and restoration

### Cut Support Addition

- Added support for alt+cmd+x to cut content to the alternate clipboard
- Works identically to copy, but removes the selected content after saving to alt clipboard
- Uses cmd+x under the hood (keyCode 7)

### Image Support Fix

**Problem**: Initially used `hs.pasteboard.getContents()` and `hs.pasteboard.setContents()`, which only handle text data. Images and other rich clipboard formats were not working.

**Solution**: Switched to `hs.pasteboard.readAllData()` and `hs.pasteboard.writeAllData()` to handle all clipboard data types including:
- Plain text
- Rich/styled text
- Images (PNG, JPG, etc.)
- Files and URLs
- Any other clipboard format

### API Parameter Order

**Issue**: Discovered that `hs.pasteboard.writeAllData()` takes parameters in the order `(pasteboardName, data)` rather than `(data, pasteboardName)`.

**Fix**: Updated all calls to use correct parameter order:
```lua
hs.pasteboard.writeAllData("alt", copiedContent)  -- Correct
```

### Customizable Keybindings (v0.2)

**Feature**: Added ability to customize keyboard shortcuts for cut, copy, and paste operations.

**Implementation**:
- Added `self.keys` table in `init()` method with default keybindings
- Created `bindHotKeys()` method to allow users to override defaults
- Created `parseModifiers()` helper method to parse modifiers from string or table format
- Updated `start()` method to dynamically build key configurations using `hs.keycodes.map`
- Implemented `flagsMatch()` helper to check if event flags match target modifiers exactly
- Updated all handler methods to accept `originalMods` parameter and set flags to `{ cmd = true }`

**Key Design Decisions**:
- Modifiers can be specified as table `{"shift", "cmd"}` or string `"shift,cmd"` for flexibility
- Uses exact modifier matching (no extra modifiers allowed except `fn`)
- Handler methods convert custom shortcuts to standard system shortcuts (cmd+c/x/v)
- Maintains backward compatibility with default alt+cmd shortcuts

## Technical Details

### Key Components

- **Eventtap**: Monitors keyboard events at system level
- **Named Pasteboard**: Uses "alt" as the pasteboard name for alternate clipboard storage
- **Timer Delays**: 0.5s delays allow system copy/paste operations to complete before clipboard restoration
- **Flag Manipulation**: Modifies event flags to transform alt+cmd shortcuts into regular cmd shortcuts

### File Structure

```
AltClipboard.spoon/
└── init.lua          # Main spoon implementation
```

## Installation

1. Copy the `AltClipboard.spoon` directory to `~/.hammerspoon/Spoons/`
2. Add to your `~/.hammerspoon/init.lua`:
```lua
hs.loadSpoon("AltClipboard")
spoon.AltClipboard:start()
```
3. Reload Hammerspoon configuration

## Usage

### Basic Usage (Default Keybindings)

1. **Copy to alt clipboard**: Select text/image and press alt+cmd+c
2. **Cut to alt clipboard**: Select text/image and press alt+cmd+x (copies and removes selection)
3. **Paste from alt clipboard**: Press alt+cmd+v wherever you want to paste
4. Your system clipboard remains unchanged throughout these operations

### Customizing Keybindings

You can customize the keyboard shortcuts using the `bindHotKeys()` method. Call this before `start()`:

```lua
hs.loadSpoon("AltClipboard")
spoon.AltClipboard:bindHotKeys({
    cut = { "shift,cmd", "x" },
    copy = { "shift,cmd", "c" },
    paste = { "shift,cmd", "v" },
})
spoon.AltClipboard:start()
```

Modifiers can also be specified as a table:

```lua
spoon.AltClipboard:bindHotKeys({
    cut = { {"shift", "cmd"}, "x" },
    copy = { {"shift", "cmd"}, "c" },
    paste = { {"shift", "cmd"}, "v" },
})
```

You can customize individual operations without affecting others:

```lua
-- Only change the paste keybinding
spoon.AltClipboard:bindHotKeys({
    paste = { "ctrl,alt", "v" },
})
```

**Supported modifiers**: `cmd`, `shift`, `alt`, `ctrl`

## Future Enhancements

Potential improvements for future development:
- Multiple alternate clipboards (alt1, alt2, etc.)
- Clipboard history for the alt clipboard
- Visual indicators showing alt clipboard status
- Persistence of alt clipboard across Hammerspoon reloads
- Support for more complex key combinations (triple modifiers, etc.)
