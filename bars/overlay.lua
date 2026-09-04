--[[
  Purpose: HUD overlay drag and column/row resize for Bars in Layout Edit Mode.
  Deps: ShadowUI:PlaceBarButtons(), ShadowUI:NearestBarLayout(), ShadowUI:PersistBarPosition()
  Public: ShadowUI:SelectEditOverlay(), ShadowUI:UpdateBarDragOverlay(),
          ShadowUI:AttachBarDragOverlay()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local HUD_BLUE = { 0.0, 0.447, 0.875 }
local HUD_FILL = 0.33
local HUD_FILL_SELECTED = 0.45
local SPECIAL_NAMES = {
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
  if overlay.resizeGrip then
    overlay.resizeGrip:EnableMouse(show)
    overlay.resizeGrip:SetShown(show)
    if overlay.resizeGrip.SetFrameLevel then
      overlay.resizeGrip:SetFrameLevel((overlay.GetFrameLevel and overlay:GetFrameLevel() or 200) + 5)
    end
  end
  paintOverlay(overlay, false)
end

function Addon:AttachBarDragOverlay(bar)
  local overlayName = (bar.GetName and bar:GetName() or "ShadowUIBar") .. "Drag"
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
  local sizing
  local endPointer
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
  local function barScale()
    local scale = (bar.GetScale and bar:GetScale()) or 1
    if scale == 0 then
      return 1
    end
    return scale
  end
  local function cursorOnResizeGrip()
    local cx, cy = cursor()
    local scale = barScale()
    local left = (bar.GetLeft and bar:GetLeft()) or 0
    local bottom = (bar.GetBottom and bar:GetBottom()) or 0
    local width = ((bar.GetWidth and bar:GetWidth()) or 0) * scale
    local size = 12
    return cx >= left + width - size
      and cx <= left + width
      and cy >= bottom
      and cy <= bottom + size
  end
  local function dragToCursor()
    if not drag then
      return
    end
    local cx, cy = cursor()
    local x, y = cx + drag.dx, cy + drag.dy
    local width = (bar.GetWidth and bar:GetWidth() or 0) * barScale()
    local height = (bar.GetHeight and bar:GetHeight() or 0) * barScale()
    if Addon.SnapVisualToGrid then
      x, y = Addon:SnapVisualToGrid(x, y, width, height)
    elseif Addon.SnapValue then
      x, y = Addon:SnapValue(x), Addon:SnapValue(y)
    end
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    dragOverlay:SetAllPoints(bar)
    if Addon.PaintEditReadout then
      Addon:PaintEditReadout(bar, barLabel(bar.barId))
    end
  end
  local function sizeToCursor()
    if not sizing or not Addon.NearestBarLayout then
      return
    end
    local cx, cy = cursor()
    local gap = bar.gap or 0
    local layout = Addon:NearestBarLayout(
      #bar.buttons,
      bar.buttonSize or 36,
      cx - sizing.left,
      sizing.top - cy,
      gap,
      bar.rowGaps
    )
    Addon:PlaceBarButtons(bar, layout.columns, bar.buttonSize or 36, gap, bar.rowGaps)
    local scale = barScale()
    bar:ClearAllPoints()
    bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", sizing.left, sizing.top - layout.height * scale)
    dragOverlay:SetAllPoints(bar)
    if Addon.PaintEditReadout then
      Addon:PaintEditReadout(bar, barLabel(bar.barId))
    end
  end
  local function tick()
    if sizing then
      sizeToCursor()
    elseif drag then
      dragToCursor()
    end
    if (sizing or drag) and IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
      endPointer()
    end
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
    if Addon.HideEditReadout then
      Addon:HideEditReadout()
    end
  end
  local function endSize()
    if not sizing then
      return
    end
    dragOverlay:SetScript("OnUpdate", nil)
    sizeToCursor()
    sizing = nil
    if Addon.PersistBarPosition then
      Addon:PersistBarPosition(bar, true)
    end
    if Addon.HideEditReadout then
      Addon:HideEditReadout()
    end
  end
  endPointer = function()
    if sizing then
      endSize()
    elseif drag then
      endMove()
    end
  end
  local function beginSize(_, button)
    if button and button ~= "LeftButton" then
      return
    end
    if not Addon.editMode or drag or sizing then
      return
    end
    Addon:SelectEditOverlay(dragOverlay)
    local top = bar.GetTop and bar:GetTop()
    if not top then
      local scale = barScale()
      top = (bar.GetBottom and bar:GetBottom() or 0) + ((bar.GetHeight and bar:GetHeight() or 0) * scale)
    end
    sizing = {
      left = bar.GetLeft and bar:GetLeft() or 0,
      top = top,
    }
    dragOverlay:SetScript("OnUpdate", tick)
    sizeToCursor()
  end
  local function beginMove(_, button)
    if button ~= "LeftButton" or not Addon.editMode or drag or sizing then
      return
    end
    if cursorOnResizeGrip() then
      beginSize(_, button)
      return
    end
    Addon:SelectEditOverlay(dragOverlay)
    local cx, cy = cursor()
    drag = {
      dx = (bar.GetLeft and bar:GetLeft() or 0) - cx,
      dy = (bar.GetBottom and bar:GetBottom() or 0) - cy,
    }
    dragOverlay:SetScript("OnUpdate", tick)
    dragToCursor()
  end
  dragOverlay:SetScript("OnMouseDown", beginMove)
  dragOverlay:SetScript("OnMouseUp", endPointer)
  local grip = CreateFrame("Frame", overlayName .. "Size", dragOverlay)
  grip:SetSize(12, 12)
  grip:SetPoint("BOTTOMRIGHT", dragOverlay, "BOTTOMRIGHT", 0, 0)
  grip:SetFrameLevel((dragOverlay.GetFrameLevel and dragOverlay:GetFrameLevel() or 200) + 5)
  grip:EnableMouse(true)
  local gripFill = grip:CreateTexture(nil, "ARTWORK")
  gripFill:SetAllPoints(grip)
  gripFill:SetColorTexture(1, 1, 1, 0.85)
  grip:SetScript("OnMouseDown", beginSize)
  grip:SetScript("OnMouseUp", endPointer)
  grip:Hide()
  dragOverlay.resizeGrip = grip
  dragOverlay:Hide()
  bar.dragOverlay = dragOverlay
  return dragOverlay
end
