--[[
  Purpose: Create and lay out standard action bar frames.
  Deps: ShadowUI:CreateBarButton(), ShadowUI:ApplyBarChrome(), ShadowUI:AttachBarDragOverlay()
  Public: ShadowUI:FirstActionSlot(), ShadowUI:CreateBar(), ShadowUI:PlaceBarButtons(),
          ShadowUI:UpdateBarLayout()
  Notes: PlaceBarButtons uses Gap between as space between slots. Gap above
         and gap below on this Bar pad inside each slot and shrink the icon.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:PlaceBarButtons(bar, columns, size, gap, rowGaps)
  local count = #bar.buttons
  if self.SnapBarColumns then
    columns = self:SnapBarColumns(count, columns or count)
  else
    columns = math.max(1, math.min(columns or count, count))
  end
  gap = gap or 0
  bar.buttonSize = size
  bar.columns = columns
  bar.gap = gap
  bar.rowGaps = rowGaps
  local metrics
  if self.BarGridMetrics then
    metrics = self:BarGridMetrics(count, columns, size, gap, rowGaps)
  else
    local rows = math.ceil(count / columns)
    metrics = {
      columns = columns,
      rows = rows,
      width = columns * size + (columns - 1) * gap,
      height = rows * size + (rows - 1) * gap,
    }
  end
  bar:SetSize(metrics.width, metrics.height)
  local step = size + gap
  for i, button in ipairs(bar.buttons) do
    local column = (i - 1) % columns
    local row = math.floor((i - 1) / columns)
    local top = metrics.rowTop and metrics.rowTop[row + 1] or (row * step)
    local pad = metrics.rowPad and metrics.rowPad[row + 1]
    local iconSize = pad and pad.icon or size
    local above = pad and pad.above or 0
    button:ClearAllPoints()
    button:SetSize(iconSize, iconSize)
    button:SetPoint("TOPLEFT", bar, "TOPLEFT", column * step + (size - iconSize) / 2, -(top + above))
  end
  if bar.dragOverlay and bar.dragOverlay.SetAllPoints then
    bar.dragOverlay:SetAllPoints(bar)
  end
end

function Addon:UpdateBarLayout(bar, cfg)
  local size = cfg.buttonSize or 36
  self:PlaceBarButtons(bar, cfg.columns or #bar.buttons, size, cfg.gap or 0, cfg.rowGaps)
  bar:SetScale(cfg.scale or 1)
  bar.iconShape = cfg.iconShape or "square"
  bar.fadeIdle = cfg.fadeIdle
  bar:ClearAllPoints()
  bar:SetPoint(
    cfg.point or "CENTER",
    _G[cfg.relativeTo or "UIParent"] or UIParent,
    cfg.relativePoint or cfg.point or "CENTER",
    cfg.x or 0,
    cfg.y or 0
  )

  local editable = self.editMode == true
  bar:SetMovable(editable)
  if self.UpdateBarDragOverlay then
    self:UpdateBarDragOverlay(bar, editable)
  end
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
  bar.barId = barId

  local firstSlot = self:FirstActionSlot(barId, cfg)
  for i = 1, cfg.buttons or 12 do
    local slot = firstSlot + i - 1
    bar.buttons[i] = self:CreateBarButton(bar, slot, slot)
  end

  if self.AttachBarDragOverlay then
    self:AttachBarDragOverlay(bar)
  end
  self:UpdateBarLayout(bar, cfg)
  return bar
end
