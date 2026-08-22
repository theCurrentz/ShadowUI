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
  -- 1.15.9 Edit Mode copies SetPoint to SetPointBase and replaces SetPoint.
  -- The override notifies Edit Mode, which re-applies the Blizzard layout
  -- during the same call while ShadowUI snapping is on.
  function frame:SetPointBase(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:ClearAllPointsBase()
    self.points = {}
  end
  function frame:ClearAllPoints()
    self:ClearAllPointsBase()
  end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    self:SetPointBase(point, relative, relativePoint, x, y)
    self:SetPointBase("TOPLEFT", _G.UIParent, "TOPLEFT", 16, -4)
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

_G.EditModeSystemMixin = {
  ApplySystemAnchor = function(self)
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 16, -4)
  end,
}

_G.PlayerFrame = fakeFrame("PlayerFrame")
_G.TargetFrame = fakeFrame("TargetFrame")

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()
Addon:SkinUnitFrames()

local player = _G.PlayerFrame
local target = _G.TargetFrame
local function last(frame)
  return frame.points[#frame.points]
end
assert(last(player)[1] == "CENTER" and last(player)[4] == -200, "player sits left of centre")
assert(last(player)[5] == -179, "player sits with the Currentz cluster")
assert(last(target)[1] == "CENTER" and last(target)[4] == 202, "target sits right of centre")
assert(last(target)[5] == -179, "target matches player height")
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

_G.EditModeSystemMixin.ApplySystemAnchor(player)
assert(last(player)[4] == -162, "Edit Mode ApplySystemAnchor cannot keep a different player place")
assert(last(player)[5] == -146, "Edit Mode ApplySystemAnchor keeps the Layout park")

print("unit_park_spec OK")
