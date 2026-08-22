--[[
  Purpose: Create and lay out standard action bar frames.
  Deps: ShadowUI:CreateBarButton(), ShadowUI:ApplyBarChrome()
  Public: ShadowUI:FirstActionSlot(), ShadowUI:CreateBar(), ShadowUI:UpdateBarLayout(),
          ShadowUI:UpdateBarDragOverlay()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local HUD_BLUE = { 0.0, 0.447, 0.875 }
local HUD_FILL = 0.33
local HUD_FILL_SELECTED = 0.45
local SPECIAL_NAMES = {
  stance = "Stance",
  aura = "Aura",
  form = "Form",
  pet = "Pet",
  possess = "Possess",
}

local function barLabel(barId)
  return SPECIAL_NAMES[barId] or (tostring(barId or ""):gsub("^bar", "Bar "))
end

local function paintOverlay(overlay, selected)
  if overlay.fill then
    local alpha = selected and HUD_FILL_SELECTED or HUD_FILL
    overlay.fill:SetColorTexture(HUD_BLUE[1], HUD_BLUE[2], HUD_BLUE[3], alpha)
  end
  if overlay.SetBackdropBorderColor then
    if selected then
      overlay:SetBackdropBorderColor(1, 0.82, 0.1, 1)
    else
      overlay:SetBackdropBorderColor(0.45, 0.81, 1, 0.95)
    end
  end
end

function Addon:SelectEditOverlay(overlay)
  local seen = false
  for _, bar in pairs(self.bars or {}) do
    if bar.dragOverlay then
      local selected = bar.dragOverlay == overlay
      seen = seen or selected
      paintOverlay(bar.dragOverlay, selected)
    end
  end
  for _, host in pairs(self.unitHosts or {}) do
    if host.overlay then
      local selected = host.overlay == overlay
      seen = seen or selected
      paintOverlay(host.overlay, selected)
    end
  end
  if overlay and not seen then
    paintOverlay(overlay, true)
  end
end

function Addon:UpdateBarDragOverlay(bar, editable)
  local overlay = bar.dragOverlay
  if not overlay then
    return
  end
  overlay:SetAllPoints(bar)
  if overlay.fontString then
    overlay.fontString:SetText(barLabel(bar.barId))
  end
  if overlay.SetFrameStrata then
    overlay:SetFrameStrata("DIALOG")
  end
  if overlay.SetFrameLevel then
    overlay:SetFrameLevel(200)
  end
  local show = editable == true and bar.configEnabled ~= false
  if show and bar.IsShown and not bar:IsShown() then
    show = false
  end
  overlay:EnableMouse(show)
  overlay:SetShown(show)
  paintOverlay(overlay, false)
end

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
  self:UpdateBarDragOverlay(bar, editable)
end

function Addon:FirstActionSlot(barId, cfg)
  if cfg and type(cfg.firstSlot) == "number" then
    return cfg.firstSlot
  end
  local page = tonumber((barId or ""):match("^bar(%d+)$"))
  if not page then
    return nil
  end
  return (page - 1) * 12 + 1
end

function Addon:CreateBar(barId, cfg)
  local page = tonumber(barId:match("^bar(%d+)$"))
  assert(page, "CreateBar requires a standard action bar id")

  -- SecureHandlerStateTemplate must be the only template so WrapScript exists.
  -- BackdropTemplate on the same CreateFrame can fail on Classic Era.
  local bar = CreateFrame("Frame", "ShadowUIBar" .. page, UIParent, "SecureHandlerStateTemplate")
  bar:SetFrameStrata("MEDIUM")
  bar:SetClampedToScreen(true)
  if bar.SetClampRectInsets then
    bar:SetClampRectInsets(0, 0, 0, 0)
  end
  self:ApplyBarChrome(bar)
  bar.buttons = {}

  -- Parent to UIParent at DIALOG so the overlay sits above secure buttons.
  -- A child of the Bar cannot rise above MEDIUM strata.
  local overlayName = "ShadowUIBar" .. page .. "Drag"
  local ok, dragOverlay = pcall(CreateFrame, "Button", overlayName, UIParent, "BackdropTemplate")
  if not ok or not dragOverlay then
    dragOverlay = CreateFrame("Button", overlayName, UIParent)
  end
  dragOverlay:SetFrameStrata("DIALOG")
  dragOverlay:SetFrameLevel(200)
  dragOverlay:SetAllPoints(bar)
  dragOverlay:EnableMouse(false)
  dragOverlay:RegisterForDrag("LeftButton")
  if dragOverlay.SetBackdrop then
    dragOverlay:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
    })
    dragOverlay:SetBackdropColor(0, 0, 0, 0)
    dragOverlay:SetBackdropBorderColor(0.45, 0.81, 1, 0.95)
  end
  local fill = dragOverlay:CreateTexture(nil, "ARTWORK")
  fill:SetAllPoints(dragOverlay)
  fill:SetColorTexture(HUD_BLUE[1], HUD_BLUE[2], HUD_BLUE[3], HUD_FILL)
  dragOverlay.fill = fill
  local label = dragOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("CENTER")
  label:SetTextColor(1, 1, 1, 1)
  dragOverlay.fontString = label
  dragOverlay.bar = bar
  local drag
  local function cursor()
    local scale = 1
    if UIParent.GetEffectiveScale then
      scale = UIParent:GetEffectiveScale() or 1
    end
    local cx, cy = 0, 0
    if GetCursorPosition then
      cx, cy = GetCursorPosition()
    end
    return cx / scale, cy / scale
  end
  local function dragToCursor()
    if not drag or not Addon.SnapValue then
      return
    end
    local cx, cy = cursor()
    local x = Addon:SnapValue(cx + drag.dx)
    local y = Addon:SnapValue(cy + drag.dy)
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    dragOverlay:SetAllPoints(bar)
  end
  local function beginMove(_, button)
    if button ~= "LeftButton" or not Addon.editMode or drag then
      return
    end
    Addon:SelectEditOverlay(dragOverlay)
    local cx, cy = cursor()
    drag = {
      dx = (bar.GetLeft and bar:GetLeft() or 0) - cx,
      dy = (bar.GetBottom and bar:GetBottom() or 0) - cy,
    }
    dragOverlay:SetScript("OnUpdate", dragToCursor)
    dragToCursor()
  end
  local function endMove()
    if not drag then
      return
    end
    dragOverlay:SetScript("OnUpdate", nil)
    dragToCursor()
    drag = nil
    if Addon.PersistBarPosition then
      Addon:PersistBarPosition(bar)
    end
  end
  dragOverlay:SetScript("OnMouseDown", beginMove)
  dragOverlay:SetScript("OnMouseUp", endMove)
  dragOverlay:Hide()
  bar.dragOverlay = dragOverlay
  bar.barId = barId

  local firstSlot = self:FirstActionSlot(barId, cfg)
  for i = 1, cfg.buttons or 12 do
    local slot = firstSlot + i - 1
    bar.buttons[i] = self:CreateBarButton(bar, slot, slot)
  end

  self:UpdateBarLayout(bar, cfg)
  return bar
end
