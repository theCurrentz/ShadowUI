--[[
  Purpose: Create flush LibActionButton action buttons with flat state overlays.
  Deps: ShadowUI addon table, LibActionButton-1.0
  Public: ShadowUI:CreateBarButton(parent, id, actionSlot)
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local LAB = LibStub("LibActionButton-1.0")
local WHITE = "Interface\\Buttons\\WHITE8X8"

local CONFIG = {
  outOfRangeColoring = "button",
  colors = {
    range = { 0.8, 0.1, 0.1 },
    mana = { 0.5, 0.5, 1 },
  },
  hideElements = {
    border = true,
    borderIfEmpty = true,
    equipped = true,
    macro = true,
  },
}

local function strip(texture)
  if texture then
    texture:SetTexture(nil)
    texture:SetAlpha(0)
    texture:Hide()
  end
end

-- Flat additive wash sized to the button instead of the 52x51 Blizzard art.
local function flatten(button, texture, r, g, b, a)
  if not texture then
    return
  end
  texture:SetTexture(WHITE)
  texture:SetVertexColor(r, g, b, a)
  texture:SetBlendMode("ADD")
  texture:ClearAllPoints()
  texture:SetAllPoints(button)
  texture:SetAlpha(1)
end

function Addon:CreateBarButton(parent, id, actionSlot)
  local name = "ShadowUIActionButton" .. id
  local button = LAB:CreateButton(id, name, parent, CONFIG)

  -- LAB only re-sizes and re-anchors its own art when the button is unskinned;
  -- claiming the skin keeps the overlays below flush with the icon.
  button.MasqueSkinned = true

  strip(button.NormalTexture)
  strip(button.PushedTexture)
  strip(button.Border)
  strip(button.SlotBackground)
  strip(button.Flash)
  flatten(button, button.CheckedTexture, 1, 0.82, 0.25, 0.32)
  flatten(button, button.HighlightTexture, 1, 1, 1, 0.16)

  if button.IconMask then
    button.icon:RemoveMaskTexture(button.IconMask)
    button.IconMask:Hide()
  end
  button.icon:ClearAllPoints()
  button.icon:SetAllPoints(button)
  button.icon:SetTexCoord(0, 1, 0, 1)
  if button.cooldown then
    button.cooldown:ClearAllPoints()
    button.cooldown:SetAllPoints(button)
  end
  button:SetState(0, "action", actionSlot)
  return button
end
