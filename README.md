# AltClipboard.spoon

Provides an alternate clipboard accessible via keyboard shortcuts. Maintain two separate clipboards for more flexible copy/paste workflows.

## Features
- **Dual clipboard system**: Separate alt clipboard alongside your system clipboard
- **Customizable shortcuts**: Configure your own keybindings or use defaults (`alt+cmd+c/x/v`)
- **Multi-format support**: Handles text, images, styled text, files, and any clipboard data type
- **Non-destructive**: Your system clipboard remains unchanged during alt clipboard operations


## Install
```bash
mkdir -p ~/.hammerspoon/Spoons
git clone https://github.com/forkd4x/AltClipboard.spoon.git ~/.hammerspoon/Spoons/AltClipboard.spoon
```

## Configure

### Basic Setup
Add to `~/.hammerspoon/init.lua`:
```lua
hs.loadSpoon("AltClipboard")
spoon.AltClipboard:start()
```

### Custom Keybindings
Customize shortcuts using `bindHotKeys()` before `start()`:
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
    cut = { { "shift", "cmd" }, "x" },
    copy = { { "shift", "cmd" }, "c" },
    paste = { { "shift", "cmd" }, "v" },
})
```


## Usage

### Default Shortcuts

1. **Copy to alt clipboard**: Select content, press `alt+cmd+c`
2. **Cut to alt clipboard**: Select content, press `alt+cmd+x`
3. **Paste from alt clipboard**: Press `alt+cmd+v`

Your system clipboard remains unchanged throughout these operations.

### With Custom Keybindings

Use whatever shortcuts you configured with `bindHotKeys()`. The behavior is the same—content is stored in a separate alt clipboard without affecting your system clipboard.


## How It Works

AltClipboard uses Hammerspoon's event tap system to intercept keyboard events:

1. **Event Detection**: Watches for `alt+cmd+c` and `alt+cmd+v` key combinations
2. **Clipboard Swapping**: Temporarily swaps clipboard contents before system operations
3. **Flag Manipulation**: Removes the alt flag, letting the system handle `cmd+c`/`cmd+v` normally
4. **Restoration**: Restores the original clipboard after a brief delay

This approach ensures compatibility with all applications and clipboard data types without requiring special permissions beyond what Hammerspoon already needs.
