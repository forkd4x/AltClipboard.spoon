--- === AltClipboard ===
---
--- An alternate clipboard for Hammerspoon
--- Allows copying to and pasting from a separate clipboard using alt+cmd+c and alt+cmd+v
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AltClipboard"
obj.version = "0.2"
obj.author = "forkd4x"
obj.homepage = "https://github.com/forkd4x/AltClipboard.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Internal state
obj.eventTap = nil

--- AltClipboard:init()
--- Method
--- Initializes the AltClipboard spoon
---
--- Parameters:
---  * None
---
--- Returns:
---  * The AltClipboard object
function obj:init()
  -- Default keybindings
  self.keys = {
    cut = { { "alt", "cmd" }, "x" },
    copy = { { "alt", "cmd" }, "c" },
    paste = { { "alt", "cmd" }, "v" },
  }
  return self
end

--- AltClipboard:bindHotKeys(keys)
--- Method
--- Configures custom keybindings for cut, copy, and paste operations
---
--- Parameters:
---  * keys - A table with optional `cut`, `copy`, and `paste` keys, each containing
---           a table with two elements: modifiers and key character
---           Modifiers can be a table like {"shift", "cmd"} or a string like "shift,cmd"
---           Example: { cut = { "shift,cmd", "x" }, copy = { {"shift", "cmd"}, "c" } }
---
--- Returns:
---  * The AltClipboard object
function obj:bindHotKeys(keys)
  if keys.cut then
    self.keys.cut = keys.cut
  end
  if keys.copy then
    self.keys.copy = keys.copy
  end
  if keys.paste then
    self.keys.paste = keys.paste
  end
  return self
end

--- AltClipboard:parseModifiers(modifiers)
--- Method
--- Parses modifier flags from a string or table format
---
--- Parameters:
---  * modifiers - Either a table like {"shift", "cmd"} or a string like "shift,cmd"
---
--- Returns:
---  * A table of modifier flags (e.g., {shift = true, cmd = true})
function obj:parseModifiers(modifiers)
  local flags = {}
  local modList = modifiers

  -- Convert string to table if needed
  if type(modifiers) == "string" then
    modList = {}
    for mod in string.gmatch(modifiers, "([^,]+)") do
      table.insert(modList, mod:match("^%s*(.-)%s*$")) -- trim whitespace
    end
  end

  -- Build flags table
  for _, mod in ipairs(modList) do
    flags[mod] = true
  end

  return flags
end

--- AltClipboard:start()
--- Method
--- Starts the AltClipboard event tap
---
--- Parameters:
---  * None
---
--- Returns:
---  * The AltClipboard object
function obj:start()
  if self.eventTap then
    self.eventTap:stop()
  end

  -- Build key configurations with parsed modifiers and key codes
  local copyMods = self:parseModifiers(self.keys.copy[1])
  local copyKeyCode = hs.keycodes.map[self.keys.copy[2]]

  local pasteMods = self:parseModifiers(self.keys.paste[1])
  local pasteKeyCode = hs.keycodes.map[self.keys.paste[2]]

  local cutMods = self:parseModifiers(self.keys.cut[1])
  local cutKeyCode = hs.keycodes.map[self.keys.cut[2]]

  -- Create event tap for keydown events
  self.eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local flags = event:getFlags()
    local keyCode = event:getKeyCode()

    -- Helper function to check if current flags match target modifiers
    local function flagsMatch(targetMods)
      for mod, _ in pairs(targetMods) do
        if not flags[mod] then
          return false
        end
      end
      -- Ensure no extra modifiers are pressed (except fn, which is often ignored)
      for flag, value in pairs(flags) do
        if value and flag ~= "fn" and not targetMods[flag] then
          return false
        end
      end
      return true
    end

    -- Check for copy keybinding
    if keyCode == copyKeyCode and flagsMatch(copyMods) then
      return self:handleAltCopy(event, copyMods)
    end

    -- Check for paste keybinding
    if keyCode == pasteKeyCode and flagsMatch(pasteMods) then
      return self:handleAltPaste(event, pasteMods)
    end

    -- Check for cut keybinding
    if keyCode == cutKeyCode and flagsMatch(cutMods) then
      return self:handleAltCut(event, cutMods)
    end

    return false
  end)

  self.eventTap:start()
  return self
end

--- AltClipboard:stop()
--- Method
--- Stops the AltClipboard event tap
---
--- Parameters:
---  * None
---
--- Returns:
---  * The AltClipboard object
function obj:stop()
  if self.eventTap then
    self.eventTap:stop()
  end
  return self
end

--- AltClipboard:handleAltCopy(event, originalMods)
--- Method
--- Handles custom keybinding to copy to the alternate clipboard
---
--- Parameters:
---  * event - The keyboard event
---  * originalMods - The original modifier keys that triggered this action
---
--- Returns:
---  * false to propagate the modified event
function obj:handleAltCopy(event, originalMods)
  -- Backup the current system clipboard (all data types)
  local backup = hs.pasteboard.readAllData()

  -- Replace the original modifiers with cmd only (standard copy shortcut)
  local newFlags = { cmd = true }
  event:setFlags(newFlags)

  -- Set a timer to restore the backup after the system processes cmd+c
  hs.timer.doAfter(0.1, function()
    -- Store what was just copied into our alt clipboard pasteboard (all data types)
    local copiedContent = hs.pasteboard.readAllData()
    if copiedContent then
      hs.pasteboard.writeAllData("alt", copiedContent)
    end

    -- Restore the original clipboard contents
    if backup then
      hs.pasteboard.writeAllData(backup)
    end
  end)

  -- Return false to allow the modified event (cmd+c without alt) to propagate
  return false
end

--- AltClipboard:handleAltCut(event, originalMods)
--- Method
--- Handles custom keybinding to cut to the alternate clipboard
---
--- Parameters:
---  * event - The keyboard event
---  * originalMods - The original modifier keys that triggered this action
---
--- Returns:
---  * false to propagate the modified event
function obj:handleAltCut(event, originalMods)
  -- Backup the current system clipboard (all data types)
  local backup = hs.pasteboard.readAllData()

  -- Replace the original modifiers with cmd only (standard cut shortcut)
  local newFlags = { cmd = true }
  event:setFlags(newFlags)

  -- Set a timer to restore the backup after the system processes cmd+x
  hs.timer.doAfter(0.1, function()
    -- Store what was just cut into our alt clipboard pasteboard (all data types)
    local cutContent = hs.pasteboard.readAllData()
    if cutContent then
      hs.pasteboard.writeAllData("alt", cutContent)
    end

    -- Restore the original clipboard contents
    if backup then
      hs.pasteboard.writeAllData(backup)
    end
  end)

  -- Return false to allow the modified event (cmd+x without alt) to propagate
  return false
end

--- AltClipboard:handleAltPaste(event, originalMods)
--- Method
--- Handles custom keybinding to paste from the alternate clipboard
---
--- Parameters:
---  * event - The keyboard event
---  * originalMods - The original modifier keys that triggered this action
---
--- Returns:
---  * false to propagate the modified event
function obj:handleAltPaste(event, originalMods)
  -- Backup the current system clipboard (all data types)
  local backup = hs.pasteboard.readAllData()

  -- Put the alt clipboard content into the system clipboard (all data types)
  local altContent = hs.pasteboard.readAllData("alt")
  if altContent then
    hs.pasteboard.writeAllData(altContent)
  end

  -- Replace the original modifiers with cmd only (standard paste shortcut)
  local newFlags = { cmd = true }
  event:setFlags(newFlags)

  -- Set a timer to restore the backup after the system processes cmd+v
  hs.timer.doAfter(0.1, function()
    -- Restore the original clipboard contents
    if backup then
      hs.pasteboard.writeAllData(backup)
    end
  end)

  -- Return false to allow the modified event (cmd+v without alt) to propagate
  return false
end

return obj
