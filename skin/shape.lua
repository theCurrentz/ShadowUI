--[[
  Purpose: Per-Bar and Micro Cluster icon shape. Square keeps current chrome.
           Circle and diamond use CreateMaskTexture plus AddMaskTexture, or
           Classic SetMask when CreateMaskTexture is missing. Matching Outer
           Edge drops sit outside the mask. Press glow uses a mask sized to
           the glow so a 4px inset stays a circle or diamond. A drawable
           CreateTexture overlay is not a mask.
  Deps: ShadowUI addon table; media/mask_diamond.tga; media/mask_roundrect.tga;
        media/outer_shadow_roundrect.tga (2:1 drop); Blizzard TempPortraitAlphaMask
  Public: ShadowUI:IconMaskFile(), ShadowUI:RoundRectMaskFile(),
          ShadowUI:OuterEdgeFile(), ShadowUI:ApplyIconShape()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local DIAMOND_MASK = "Interface\\AddOns\\ShadowUI\\media\\mask_diamond"
local ROUND_MASK = "Interface\\AddOns\\ShadowUI\\media\\mask_roundrect"
local MASK_WRAP = "CLAMPTOBLACKADDITIVE"
local OUTER = {
  square = "Interface\\AddOns\\ShadowUI\\media\\outer_shadow",
  circle = "Interface\\AddOns\\ShadowUI\\media\\outer_shadow_circle",
  diamond = "Interface\\AddOns\\ShadowUI\\media\\outer_shadow_diamond",
  roundrect = "Interface\\AddOns\\ShadowUI\\media\\outer_shadow_roundrect",
}

function Addon:RoundRectMaskFile()
  return ROUND_MASK
end

function Addon:IconMaskFile(shape)
  if shape == "circle" then
    return CIRCLE_MASK
  end
  if shape == "diamond" then
    return DIAMOND_MASK
  end
  return nil
end

function Addon:OuterEdgeFile(shape)
  return OUTER[shape] or OUTER.square
end

local function collectRegions(button)
  local icon = button.icon or button.Icon
  local hover = button.HighlightTexture
  if not hover and button.GetHighlightTexture then
    hover = button:GetHighlightTexture()
  end
  local pressed = button.PushedTexture
  if not pressed and button.GetPushedTexture then
    pressed = button:GetPushedTexture()
  end
  local normal = button.NormalTexture
  if not normal and button.GetNormalTexture then
    normal = button:GetNormalTexture()
  end
  local regions = {}
  local function add(region)
    if region then
      regions[#regions + 1] = region
    end
  end
  add(button.shadowUIChrome)
  add(icon)
  add(hover)
  add(pressed)
  add(normal)
  return regions
end

local function isMaskTexture(tex)
  return tex and tex.IsObjectType and tex:IsObjectType("MaskTexture")
end

local function canMaskRegion(region)
  if not region then
    return false
  end
  -- Cooldown is a frame. AddMaskTexture on it errors.
  if region.SetDrawSwipe then
    return false
  end
  return region.AddMaskTexture or region.SetMask
end

local function discardDrawableMask(button, mask, regions)
  if not mask or isMaskTexture(mask) then
    return mask
  end
  for _, region in ipairs(regions) do
    if region and region.RemoveMaskTexture then
      pcall(region.RemoveMaskTexture, region, mask)
    end
  end
  if mask.Hide then
    mask:Hide()
  end
  button.shadowUIShapeMask = nil
  return nil
end

local function clearRegionMask(region, mask)
  if mask and region.RemoveMaskTexture then
    pcall(region.RemoveMaskTexture, region, mask)
  end
  if region.SetMask then
    region:SetMask("")
  end
end

-- Size this mask to the glow, not the button. A button-sized circle on a 4px
-- inset square clips the corners and leaves a squircle.
local function applyGlowMask(button, file)
  local glow = button.shadowUIPressGlow
  if not glow or not canMaskRegion(glow) then
    return
  end
  local mask = button.shadowUIPressMask
  if mask and not isMaskTexture(mask) then
    if glow.RemoveMaskTexture then
      pcall(glow.RemoveMaskTexture, glow, mask)
    end
    if mask.Hide then
      mask:Hide()
    end
    button.shadowUIPressMask = nil
    mask = nil
  end
  if not file then
    clearRegionMask(glow, mask)
    if mask and mask.Hide then
      mask:Hide()
    end
    return
  end
  if not mask and button.CreateMaskTexture then
    mask = button:CreateMaskTexture()
    button.shadowUIPressMask = mask
  end
  if mask then
    if mask.SetTexture then
      mask:SetTexture(file, MASK_WRAP, MASK_WRAP)
    end
    if mask.SetAllPoints then
      mask:SetAllPoints(glow)
    end
    if mask.Show then
      mask:Show()
    end
  end
  if mask and glow.AddMaskTexture then
    if glow.RemoveMaskTexture then
      pcall(glow.RemoveMaskTexture, glow, mask)
    end
    glow:AddMaskTexture(mask)
  elseif glow.SetMask then
    glow:SetMask(file)
    if glow.SetTexCoord then
      glow:SetTexCoord(0, 1, 0, 1)
    end
  end
end

function Addon:ApplyIconShape(button, shape)
  if not button then
    return
  end
  shape = shape or "square"
  local file = self:IconMaskFile(shape)
  local regions = collectRegions(button)
  local mask = discardDrawableMask(button, button.shadowUIShapeMask, regions)
  if not file then
    for _, region in ipairs(regions) do
      if canMaskRegion(region) then
        clearRegionMask(region, mask)
      end
    end
    if mask and mask.Hide then
      mask:Hide()
    end
    button.shadowUIShape = "square"
    applyGlowMask(button, nil)
    return
  end
  if not mask and button.CreateMaskTexture then
    mask = button:CreateMaskTexture()
    button.shadowUIShapeMask = mask
  end
  if mask then
    if mask.SetTexture then
      mask:SetTexture(file, MASK_WRAP, MASK_WRAP)
    end
    if mask.SetAllPoints then
      mask:SetAllPoints(button)
    end
    if mask.Show then
      mask:Show()
    end
  end
  for _, region in ipairs(regions) do
    if not canMaskRegion(region) then
      -- skip
    elseif mask and region.AddMaskTexture then
      if region.RemoveMaskTexture then
        pcall(region.RemoveMaskTexture, region, mask)
      end
      region:AddMaskTexture(mask)
    elseif region.SetMask then
      region:SetMask(file)
      if region.SetTexCoord then
        region:SetTexCoord(0, 1, 0, 1)
      end
    end
  end
  button.shadowUIShape = shape
  applyGlowMask(button, file)
end
