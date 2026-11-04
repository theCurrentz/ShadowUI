--[[
  Purpose: Recolor Blizzard chrome with Lorti vertex colors and keep those colors.
  Deps: named FrameXML textures, ShadowUI:GetCharDB()
  Public: ShadowUI:LockVertex(), ShadowUI:LockBackdropBorder(), ShadowUI:DarkenNamed(),
          ShadowUI:DarkenFrameRegions(), ShadowUI:RefreshDarkenPalette(), ShadowUI:SkinDarken()
  Notes: LockVertex also hooks SetTexture and SetAtlas. Those APIs reset vertex color.
         Character darkness (default 1) scales the live DARKEN_* tables in place so
         existing LockVertex hooks pick up the new values.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local unpack = unpack or table.unpack

-- Shipped Lorti bases at Character darkness 1.
local BASE_BLACK = 0.05
local BASE_GREY = 0.35
local BASE_BAR = 0.2
local BASE_SOFT = 0.14

-- Live palette. LockVertex closes over these tables; mutate in place only.
Addon.DARKEN_BLACK = { BASE_BLACK, BASE_BLACK, BASE_BLACK }
Addon.DARKEN_GREY = { BASE_GREY, BASE_GREY, BASE_GREY }
Addon.DARKEN_BAR = { BASE_BAR, BASE_BAR, BASE_BAR }
-- Target/Focus Frame Art. Darker than bar grey, not base black.
Addon.DARKEN_SOFT = { BASE_SOFT, BASE_SOFT, BASE_SOFT }

local function scaleChannel(base, darkness)
  if darkness >= 1 then
    return base
  end
  if darkness <= 0 then
    return 1
  end
  return 1 - darkness * (1 - base)
end

local function paintPalette(color, base, darkness)
  local v = scaleChannel(base, darkness)
  color[1], color[2], color[3] = v, v, v
end

function Addon:RefreshDarkenPalette()
  local darkness = 1
  local char = self.GetCharDB and self:GetCharDB()
  if char and type(char.darkness) == "number" then
    darkness = char.darkness
  end
  if darkness < 0 then
    darkness = 0
  elseif darkness > 1 then
    darkness = 1
  end
  paintPalette(self.DARKEN_BLACK, BASE_BLACK, darkness)
  paintPalette(self.DARKEN_GREY, BASE_GREY, darkness)
  paintPalette(self.DARKEN_BAR, BASE_BAR, darkness)
  paintPalette(self.DARKEN_SOFT, BASE_SOFT, darkness)
end

local function sameColor(nr, ng, nb, color)
  return nr == color[1] and ng == color[2] and nb == color[3]
end

function Addon:LockVertex(region, color)
  if not region or not region.SetVertexColor or not color then
    return
  end
  region:SetVertexColor(color[1], color[2], color[3])
  if region._shadowUILocked then
    return
  end
  region._shadowUILocked = true
  if not hooksecurefunc then
    return
  end
  local function relock(self)
    if self._shadowUIPainting then
      return
    end
    self._shadowUIPainting = true
    self:SetVertexColor(color[1], color[2], color[3])
    self._shadowUIPainting = nil
  end
  hooksecurefunc(region, "SetVertexColor", function(self, nr, ng, nb)
    if self._shadowUIPainting or sameColor(nr, ng, nb, color) then
      return
    end
    relock(self)
  end)
  -- SetTexture / SetAtlas reset vertex color without calling SetVertexColor.
  if region.SetTexture then
    hooksecurefunc(region, "SetTexture", relock)
  end
  if region.SetAtlas then
    hooksecurefunc(region, "SetAtlas", relock)
  end
end

function Addon:DarkenNamed(names, color)
  for _, name in ipairs(names) do
    self:LockVertex(_G[name], color)
  end
end

function Addon:DarkenChild(parent, key, color)
  if parent then
    self:LockVertex(parent[key], color)
  end
end

function Addon:DarkenFrameRegions(frame, color, nameFragment)
  if not frame or not frame.GetRegions then
    return
  end
  for _, region in ipairs({ frame:GetRegions() }) do
    if region and region.SetVertexColor then
      local skip = region.IsObjectType and not region:IsObjectType("Texture")
      local name = region.GetName and region:GetName() or ""
      if not skip and name:find("Portrait") then
        skip = true
      end
      if not skip and nameFragment and not name:find(nameFragment) then
        skip = true
      end
      if not skip then
        self:LockVertex(region, color)
      end
    end
  end
end

function Addon:LockBackdropBorder(frame, color)
  if not frame or not frame.SetBackdropBorderColor or not color then
    return
  end
  frame:SetBackdropBorderColor(color[1], color[2], color[3])
  if frame._shadowUIBorderLocked or not hooksecurefunc then
    return
  end
  frame._shadowUIBorderLocked = true
  hooksecurefunc(frame, "SetBackdropBorderColor", function(self, r, g, b)
    if self._shadowUIPainting or sameColor(r, g, b, color) then
      return
    end
    self._shadowUIPainting = true
    self:SetBackdropBorderColor(color[1], color[2], color[3])
    self._shadowUIPainting = nil
  end)
end

function Addon:SkinUnitFrames() end
function Addon:SkinRaidFrames() end
function Addon:SkinWindowFrames() end
function Addon:OnDarkenAddonLoaded() end

function Addon:SkinDarken()
  self:RefreshDarkenPalette()
  self:SkinUnitFrames()
  self:SkinWindowFrames()
  if self._darkenEvents or not self.RegisterEvent then
    return
  end
  self._darkenEvents = true
  pcall(self.RegisterEvent, self, "GROUP_ROSTER_UPDATE", "SkinRaidFrames")
  pcall(self.RegisterEvent, self, "ADDON_LOADED", "OnDarkenAddonLoaded")
end
