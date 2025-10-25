# AltClipboard.spoon

Provides an alternate clipboard accessible via keyboard shortcuts. Maintain two separate clipboards for more flexible copy/paste workflows.

## Features
- **Dual clipboard system**: Separate alt clipboard alongside your system clipboard
- **Simple shortcuts**: `alt+cmd+c` to copy, `alt+cmd+v` to paste
- **Multi-format support**: Handles text, images, styled text, files, and any clipboard data type
- **Non-destructive**: Your system clipboard remains unchanged during alt clipboard operations


## Install
```bash
mkdir -p ~/.hammerspoon/Spoons
git clone https://github.com/forkd4x/AltClipboard.spoon.git ~/.hammerspoon/Spoons/AltClipboard.spoon
```

## Configure
Add to `~/.hammerspoon/init.lua`
```lua
hs.loadSpoon("AltClipboard")
spoon.AltClipboard:start()
```

## Usage

### Copy/Cut to Alt Clipboard

1. Select any content (text, image, file, etc.)
2. Press `alt+cmd+c` (to copy) or `alt+cmd+x` (to cut)
3. The content is copied to the alt clipboard
4. Your system clipboard remains unchanged

### Paste from Alt Clipboard

1. Place your cursor where you want to paste
2. Press `alt+cmd+v`
3. Content from the alt clipboard is pasted
4. Your system clipboard remains unchanged


## How It Works

AltClipboard uses Hammerspoon's event tap system to intercept keyboard events:

1. **Event Detection**: Watches for `alt+cmd+c` and `alt+cmd+v` key combinations
2. **Clipboard Swapping**: Temporarily swaps clipboard contents before system operations
3. **Flag Manipulation**: Removes the alt flag, letting the system handle `cmd+c`/`cmd+v` normally
4. **Restoration**: Restores the original clipboard after a brief delay

This approach ensures compatibility with all applications and clipboard data types without requiring special permissions beyond what Hammerspoon already needs.
