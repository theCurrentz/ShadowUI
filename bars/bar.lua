--[[
  Purpose: Create and lay out standard action bar frames.
  Deps: ShadowUI:CreateBarButton()
  Public: ShadowUI:CreateBar(), ShadowUI:UpdateBarLayout()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local BACKDROP = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
}

function Addon:UpdateBarLayout(bar, cfg)
  local count = #bar.buttons
  local size = cfg.buttonSize or 36
  local columns = math.max(1, math.min(cfg.columns or count, count))
  local rows = math.ceil(count / columns)

  bar:SetScale(cfg.scale or 1)
  bar:SetSize(columns * size, rows * size)
  bar:ClearAllPoints()
  bar:SetPoint(
    cfg.point or "CENTER",
    _G[cfg.relativeTo or "UIParent"] or UIParent,
    cfg.relativePoint or cfg.point or "CENTER",
    cfg.x or 0,
    cfg.y or 0
  )

  for i, button in ipairs(bar.buttons) do
    local column = (i - 1) % columns
    local row = math.floor((i - 1) / columns)
    button:ClearAllPoints()
    button:SetSize(size, size)
    button:SetPoint("TOPLEFT", bar, "TOPLEFT", column * size, -row * size)
  end

  local editable = self.editMode == true
  bar:SetMovable(editable)
  bar.dragOverlay:SetFrameLevel(bar:GetFrameLevel() + 100)
  bar.dragOverlay:EnableMouse(editable)
  bar.dragOverlay:SetShown(editable)
end

function Addon:CreateBar(barId, cfg)
  local page = tonumber(barId:match("^bar(%d+)$"))
  assert(page, "CreateBar requires a standard action bar id")

  local bar = CreateFrame(
    "Frame",
    "ShadowUIBar" .. page,
    UIParent,
    "SecureHandlerStateTemplate,BackdropTemplate"
  )
  bar:SetFrameStrata("MEDIUM")
  bar:SetBackdrop(BACKDROP)
  bar:SetBackdropColor(0, 0, 0, 1)
  bar:SetClampedToScreen(true)
  bar.buttons = {}

  local dragOverlay = CreateFrame("Frame", nil, bar)
  dragOverlay:SetAllPoints(bar)
  dragOverlay:RegisterForDrag("LeftButton")
  dragOverlay:SetScript("OnDragStart", function()
    if Addon.editMode then
      bar:StartMoving()
    end
  end)
  dragOverlay:SetScript("OnDragStop", function()
    bar:StopMovingOrSizing()
  end)
  bar.dragOverlay = dragOverlay

  local shadow = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
  shadow:SetColorTexture(0, 0, 0, 0.35)
  shadow:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
  shadow:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
  bar.shadow = shadow

  local firstSlot = (page - 1) * 12
  for i = 1, cfg.buttons or 12 do
    bar.buttons[i] = self:CreateBarButton(bar, firstSlot + i, firstSlot + i)
  end

  self:UpdateBarLayout(bar, cfg)
  return bar
end
