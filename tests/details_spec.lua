-- Details damage and threat charts park from the Currentz chrome lock.
-- Run: lua tests/details_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.UIParent = { name = "UIParent" }

local function fakeFrame(name)
  local frame = { name = name, points = {} }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:SetWidth(width) self.width = width end
  function frame:SetHeight(height) self.height = height end
  function frame:SetSize(width, height)
    self.width, self.height = width, height
  end
  function frame:SetUserPlaced() end
  return frame
end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/details.lua"))()
Addon:SkinDetails()

_G.Details = {
  instances = {
    { meu_id = 1, atributo = 1, modo = 2, baseframe = fakeFrame("DetailsBaseFrame1") },
    { meu_id = 2, atributo = 1, modo = 2, baseframe = fakeFrame("DetailsBaseFrame2") },
    {
      meu_id = 3,
      modo = 4,
      last_raid_plugin = "DETAILS_PLUGIN_TINY_THREAT",
      isLocked = false,
      baseframe = fakeFrame("DetailsBaseFrame3"),
    },
  },
}
function _G.Details:GetInstance(id)
  return self.instances[id]
end

Addon:SkinDetails()

local damage = _G.Details.instances[1].baseframe
local extra = _G.Details.instances[2].baseframe
local threat = _G.Details.instances[3].baseframe
assert(damage.points[1][1] == "RIGHT" and damage.points[1][5] == -194, "damage chart is flush right")
assert(damage.width == 153 and damage.height == 164, "damage chart size matches Currentz")
assert(#extra.points == 0, "closed extra damage chart is left alone")
assert(threat.points[1][1] == "BOTTOMRIGHT" and threat.points[1][5] == 150, "threat chart sits above the micro row")
assert(threat.width == 153 and threat.height == 106, "threat chart size matches Currentz")
assert(_G.Details.instances[3].isLocked == true, "threat chart stays locked")

print("details_spec OK")
