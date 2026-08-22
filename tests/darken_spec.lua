-- Lorti chrome is SetVertexColor on existing art. Darkest unit frames stay
-- dark after Blizzard resets them. Window frames use the grey value.
-- Run: lua tests/darken_spec.lua
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
_G.TargetFrame_CheckClassification = function() end
_G.NUM_RAID_GROUPS = 1

local function fakeTex(name)
  local tex = { name = name, r = 1, g = 1, b = 1 }
  function tex:SetVertexColor(r, g, b)
    self.r, self.g, self.b = r, g, b
  end
  function tex:GetName()
    return self.name
  end
  function tex:IsObjectType(kind)
    return kind == "Texture"
  end
  return tex
end

local function fakeFrame(name, regions)
  local frame = { name = name }
  function frame:GetRegions()
    return unpack(regions)
  end
  return frame
end

_G.PlayerFrameTexture = fakeTex("PlayerFrameTexture")
_G.PetFrameTexture = fakeTex("PetFrameTexture")
_G.TargetFrameTextureFrameTexture = fakeTex("TargetFrameTextureFrameTexture")
_G.PartyMemberFrame1Texture = fakeTex("PartyMemberFrame1Texture")
_G.MainMenuXPBarTexture0 = fakeTex("MainMenuXPBarTexture0")
_G.LootFrameTitleBg = fakeTex("LootFrameTitleBg")
_G.MainMenuBarLeftEndCap = fakeTex("MainMenuBarLeftEndCap")
_G.MerchantFramePortrait = fakeTex("MerchantFramePortrait")
_G.PaperDollFrame = fakeFrame("PaperDollFrame", {
  fakeTex("PaperDollFramePortrait"),
  fakeTex("PaperDollFrameBorder"),
})
_G.TargetFrame = {
  borderTexture = fakeTex("TargetFrameBorder"),
}
_G.ReputationWatchBar = {
  StatusBar = {
    WatchBarTexture0 = fakeTex("WatchBarTexture0"),
  },
}

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()
assert(loadfile(root .. "skin/windows.lua"))()
Addon:SkinDarken()

local function eq(tex, r, g, b, msg)
  assert(tex.r == r and tex.g == g and tex.b == b, msg)
end

eq(_G.PlayerFrameTexture, 0.05, 0.05, 0.05, "player frame chrome is Lorti darkest")
eq(_G.PetFrameTexture, 0.05, 0.05, 0.05, "pet frame chrome is Lorti darkest")
eq(_G.PartyMemberFrame1Texture, 0.05, 0.05, 0.05, "party frame chrome is Lorti darkest")
eq(_G.TargetFrame.borderTexture, 0.05, 0.05, 0.05, "target frame chrome is Lorti darkest")
eq(_G.LootFrameTitleBg, 0.05, 0.05, 0.05, "loot title is Lorti darkest")
eq(_G.MainMenuXPBarTexture0, 0.2, 0.2, 0.2, "XP bar art is Lorti bar grey")
eq(_G.MainMenuBarLeftEndCap, 0.35, 0.35, 0.35, "gryphon art is Lorti window grey")
eq(_G.ReputationWatchBar.StatusBar.WatchBarTexture0, 0.2, 0.2, 0.2, "reputation art is Lorti bar grey")
eq(_G.PaperDollFrame:GetRegions(), 1, 1, 1, "character portrait stays native")
local _, border = _G.PaperDollFrame:GetRegions()
eq(border, 0.35, 0.35, 0.35, "character window chrome is Lorti grey")
eq(_G.MerchantFramePortrait, 1, 1, 1, "merchant portrait stays native")

_G.PlayerFrameTexture:SetVertexColor(1, 1, 1)
eq(_G.PlayerFrameTexture, 0.05, 0.05, 0.05, "Blizzard cannot reset the player frame color")

_G.TargetFrame.borderTexture:SetVertexColor(1, 1, 1)
_G.TargetFrame_CheckClassification(_G.TargetFrame)
eq(_G.TargetFrame.borderTexture, 0.05, 0.05, 0.05, "target classification keeps the dark chrome")

Addon:LockVertex(nil, Addon.DARKEN_BLACK)
Addon:DarkenNamed({ "MissingFrameTexture" }, Addon.DARKEN_BLACK)
Addon:DarkenFrameRegions(nil, Addon.DARKEN_BLACK)

print("darken_spec OK")
