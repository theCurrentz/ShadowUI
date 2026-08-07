--[[
  Purpose: Create flush LibActionButton action buttons.
  Deps: ShadowUI addon table, LibActionButton-1.0
  Public: ShadowUI:CreateBarButton(parent, id, actionSlot)
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local LAB = LibStub("LibActionButton-1.0")

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

function Addon:CreateBarButton(parent, id, actionSlot)
  local name = "ShadowUIActionButton" .. id
  local button = LAB:CreateButton(id, name, parent, CONFIG)

  strip(button.NormalTexture)
  strip(button.PushedTexture)
  strip(button.CheckedTexture)
  strip(button.Border)
  strip(button.SlotBackground)
  strip(button.HighlightTexture)
  strip(button.Flash)

  if button.IconMask then
    button.icon:RemoveMaskTexture(button.IconMask)
    button.IconMask:Hide()
  end
  button.icon:ClearAllPoints()
  button.icon:SetAllPoints(button)
  button.icon:SetTexCoord(0, 1, 0, 1)
  button:SetState(0, "action", actionSlot)
  return button
end
