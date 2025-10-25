--- === AltClipboard ===
---
--- An alternate clipboard for Hammerspoon
--- Allows copying to and pasting from a separate clipboard using alt+cmd+c and alt+cmd+v
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "AltClipboard"
obj.version = "0.1"
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
  return self
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

  -- Create event tap for keydown events
  self.eventTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local flags = event:getFlags()
    local keyCode = event:getKeyCode()

    -- Check for cmd+alt+c (copy to alt clipboard)
    -- keyCode 8 = 'c'
    if keyCode == 8 and flags.cmd and flags.alt then
      return self:handleAltCopy(event)
    end

    -- Check for cmd+alt+v (paste from alt clipboard)
    -- keyCode 9 = 'v'
    if keyCode == 9 and flags.cmd and flags.alt then
      return self:handleAltPaste(event)
    end

    -- Check for cmd+alt+x (cut to alt clipboard)
    -- keyCode 7 = 'x'
    if keyCode == 7 and flags.cmd and flags.alt then
      return self:handleAltCut(event)
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

--- AltClipboard:handleAltCopy(event)
--- Method
--- Handles alt+cmd+c to copy to the alternate clipboard
---
--- Parameters:
---  * event - The keyboard event
---
--- Returns:
---  * false to propagate the modified event
function obj:handleAltCopy(event)
  -- Backup the current system clipboard (all data types)
  local backup = hs.pasteboard.readAllData()

  -- Get the event flags and remove the alt/option key
  local flags = event:getFlags()
  flags.alt = false
  event:setFlags(flags)

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

--- AltClipboard:handleAltCut(event)
--- Method
--- Handles alt+cmd+x to cut to the alternate clipboard
---
--- Parameters:
---  * event - The keyboard event
---
--- Returns:
---  * false to propagate the modified event
function obj:handleAltCut(event)
  -- Backup the current system clipboard (all data types)
  local backup = hs.pasteboard.readAllData()

  -- Get the event flags and remove the alt/option key
  local flags = event:getFlags()
  flags.alt = false
  event:setFlags(flags)

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

--- AltClipboard:handleAltPaste(event)
--- Method
--- Handles alt+cmd+v to paste from the alternate clipboard
---
--- Parameters:
---  * event - The keyboard event
---
--- Returns:
---  * false to propagate the modified event
function obj:handleAltPaste(event)
  -- Backup the current system clipboard (all data types)
  local backup = hs.pasteboard.readAllData()

  -- Put the alt clipboard content into the system clipboard (all data types)
  local altContent = hs.pasteboard.readAllData("alt")
  if altContent then
    hs.pasteboard.writeAllData(altContent)
  end

  -- Get the event flags and remove the alt/option key
  local flags = event:getFlags()
  flags.alt = false
  event:setFlags(flags)

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
