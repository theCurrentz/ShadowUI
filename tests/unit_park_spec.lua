-- Player and target frames park from the Currentz chrome lock.
-- Run: lua tests/unit_park_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local orig = _G[object]
    if type(orig) ~= "function" then
      return
    end
    _G[object] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.UIParent = { name = "UIParent" }

local function fakeFrame(name)
  local frame = { name = name, points = {}, dragRegistered = true }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:SetUserPlaced(placed) self.userPlaced = placed end
  function frame:SetMovable(enabled) self.movable = enabled and true or false end
  function frame:IsMovable() return self.movable ~= false end
  function frame:UnregisterForDrag() self.dragRegistered = false end
  function frame:GetName() return self.name end
  return frame
end

_G.EditModeManagerFrame = {
  ExitEditMode = function(self) self.exited = true end,
}

_G.PlayerFrame = fakeFrame("PlayerFrame")
_G.TargetFrame = fakeFrame("TargetFrame")

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()
Addon:SkinUnitFrames()

local player = _G.PlayerFrame
local target = _G.TargetFrame
assert(player.points[1][1] == "CENTER" and player.points[1][4] == -200, "player sits left of centre")
assert(player.points[1][5] == -179, "player sits with the Currentz cluster")
assert(target.points[1][1] == "CENTER" and target.points[1][4] == 202, "target sits right of centre")
assert(target.points[1][5] == -179, "target matches player height")
assert(player.userPlaced == true, "player keeps the parked place")
assert(player.isLocked == true, "Classic drag stays locked")
assert(player.dragRegistered == false, "Blizzard drag does not move the Player Frame")
assert(player.movable == false, "play mode does not move the Player Frame")

player:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 16, -4)
assert(player.points[#player.points][4] == -200, "Blizzard player anchors must be undone")

function Addon:ResolveEffective()
  return {
    layout = {
      player = { point = "CENTER", x = -162, y = -146 },
      target = { point = "CENTER", x = 162, y = -146 },
    },
  }
end

_G.EditModeManagerFrame:ExitEditMode()
assert(_G.EditModeManagerFrame.exited == true, "Blizzard Edit Mode can exit")
assert(player.points[#player.points][4] == -162, "exit from Blizzard Edit Mode reapplies Layout")
assert(player.points[#player.points][5] == -146, "player follows the Layout park")
assert(target.points[#target.points][4] == 162, "target follows the Layout park")

player:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 16, -4)
assert(player.points[#player.points][4] == -162, "Blizzard Edit Mode cannot keep a different player place")

print("unit_park_spec OK")
