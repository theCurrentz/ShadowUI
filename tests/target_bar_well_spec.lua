-- Target Frame bar well must not cover the top half of an empty health slot.
-- Classic CheckClassification sizes TargetFrameBackground to 25px from y=-26.
-- Health is 12px at y=-45, so that well covers only the top half of the slot.
-- Run: lua tests/target_bar_well_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local unpack = unpack or table.unpack
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local name = object
    local orig = _G[name]
    if type(orig) ~= "function" then
      return
    end
    _G[name] = function(...)
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

local function fakeTex(name)
  local tex = { name = name, shown = true, h = 25, y = -26 }
  function tex:Hide()
    self.shown = false
  end
  function tex:Show()
    self.shown = true
  end
  function tex:SetSize(_, h)
    self.h = h
  end
  function tex:SetPoint(_, _, _, _, y)
    self.y = y
  end
  return tex
end

_G.TargetFrame_CheckClassification = function() end
_G.TargetFrameMixin = {
  CheckClassification = function(self)
    local bg = self.Background
    if bg then
      bg:Show()
      bg:SetSize(119, 25)
      bg:SetPoint("TOPRIGHT", self, "TOPRIGHT", -89.5, -26)
    end
  end,
}

local well = fakeTex("TargetFrameBackground")
_G.TargetFrame = {
  borderTexture = fakeTex("TargetFrameBorder"),
  Background = well,
}
function _G.TargetFrame:GetName()
  return "TargetFrame"
end
function _G.TargetFrame:CheckClassification()
  _G.TargetFrameMixin.CheckClassification(self)
end

function Addon:ParkFrame() end
function Addon:WatchBlizzardUnitEdit() end

assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()

Addon:SkinUnitFrames()
_G.TargetFrame:CheckClassification()

assert(well.shown == false, "target bar well stays hidden after classification")
well:Show()
assert(well.shown == false, "Blizzard cannot show the target bar well again")
assert(not (well.h == 25 and well.y == -26 and well.shown), "well must not cover half the health slot")

print("target_bar_well_spec OK")
