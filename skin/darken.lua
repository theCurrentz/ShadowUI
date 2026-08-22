--[[
  Purpose: Recolor Blizzard chrome with Lorti vertex colors and keep those colors.
  Deps: named FrameXML textures
  Public: ShadowUI:LockVertex(), ShadowUI:LockBackdropBorder(), ShadowUI:DarkenNamed(),
          ShadowUI:DarkenFrameRegions(), ShadowUI:SkinDarken()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local unpack = unpack or table.unpack

-- Lorti UI Classic: darkest chrome, window grey, bar art.
Addon.DARKEN_BLACK = { 0.05, 0.05, 0.05 }
Addon.DARKEN_GREY = { 0.35, 0.35, 0.35 }
Addon.DARKEN_BAR = { 0.2, 0.2, 0.2 }

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
  hooksecurefunc(region, "SetVertexColor", function(self, nr, ng, nb)
    if self._shadowUIPainting or sameColor(nr, ng, nb, color) then
      return
    end
    self._shadowUIPainting = true
    self:SetVertexColor(color[1], color[2], color[3])
    self._shadowUIPainting = nil
  end)
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
  self:SkinUnitFrames()
  self:SkinWindowFrames()
  if self._darkenEvents or not self.RegisterEvent then
    return
  end
  self._darkenEvents = true
  pcall(self.RegisterEvent, self, "GROUP_ROSTER_UPDATE", "SkinRaidFrames")
  pcall(self.RegisterEvent, self, "ADDON_LOADED", "OnDarkenAddonLoaded")
end
