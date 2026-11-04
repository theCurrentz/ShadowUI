--[[
  Purpose: HUD drag hosts for the Blizzard Stance Bar.
  Deps: ShadowUI:SnapFrameToGrid(), ShadowUI:PersistHostPosition(),
        ShadowUI:SelectEditOverlay(), ShadowUI:StartEditDragTick()
  Public: ShadowUI:RefreshUnitDragOverlays()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local HUD_BLUE = { 0.0, 0.447, 0.875 }
local HUD_FILL = 0.33
local STANCE_NAMES = { "StanceBar", "StanceBarFrame", "ShapeshiftBarFrame" }
local STANCE_BUTTONS = { "StanceButton", "ShapeshiftButton" }

local function resolveStanceHost()
  local fallback
  for _, name in ipairs(STANCE_NAMES) do
    local frame = _G[name]
    if frame then
      fallback = fallback or frame
      if not frame.IsShown or frame:IsShown() then
        return frame
      end
    end
  end
  return fallback
end

local function includeRect(rect, left, bottom, width, height)
  if left == nil or bottom == nil then
    return rect
  end
  local right = left + (width or 0)
  local top = bottom + (height or 0)
  if not rect then
    return { left = left, bottom = bottom, right = right, top = top }
  end
  rect.left = math.min(rect.left, left)
  rect.bottom = math.min(rect.bottom, bottom)
  rect.right = math.max(rect.right, right)
  rect.top = math.max(rect.top, top)
  return rect
end

local function stanceOverlayRect(frame)
  local rect
  for _, prefix in ipairs(STANCE_BUTTONS) do
    for i = 1, 10 do
      local button = _G[prefix .. i]
      if button and (not button.IsShown or button:IsShown()) then
        rect = includeRect(
          rect,
          button.GetLeft and button:GetLeft(),
          button.GetBottom and button:GetBottom(),
          button.GetWidth and button:GetWidth(),
          button.GetHeight and button:GetHeight()
        )
      end
    end
  end
  if frame then
    local width = frame.GetWidth and frame:GetWidth() or 0
    local height = frame.GetHeight and frame:GetHeight() or 0
    if width > 0 and height > 0 then
      rect = includeRect(
        rect,
        frame.GetLeft and frame:GetLeft(),
        frame.GetBottom and frame:GetBottom(),
        width,
        height
      )
    end
  end
  if not rect then
    return nil
  end
  return rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom
end

local function placeVisualOverlay(overlay, frame, layoutId)
  if Addon.HostVisualRect then
    local left, bottom, width, height = Addon:HostVisualRect(frame, layoutId)
    if left and width and width > 0 and height and height > 0 then
      overlay:ClearAllPoints()
      overlay:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
      overlay:SetSize(width, height)
      return
    end
  end
  overlay:SetAllPoints(frame)
end

local function placeStanceOverlay(overlay, frame)
  local left, bottom, width, height = stanceOverlayRect(frame)
  if left and width > 0 and height > 0 then
    overlay:ClearAllPoints()
    overlay:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
    overlay:SetSize(width, height)
    return
  end
  overlay:SetAllPoints(frame)
end

local HOSTS = {
  { id = "stance", overlay = "ShadowUIStanceDrag", label = "Stance",
    resolve = resolveStanceHost },
}

local function paint(overlay)
  if overlay.fill then
    overlay.fill:SetColorTexture(HUD_BLUE[1], HUD_BLUE[2], HUD_BLUE[3], HUD_FILL)
  end
  if overlay.SetBackdropBorderColor then
    overlay:SetBackdropBorderColor(0.45, 0.81, 1, 0.95)
  end
end

local function createOverlay(host, spec)
  if not CreateFrame then
    return nil
  end
  local visual = spec.visual and spec.visual() or host
  local ok, overlay = pcall(CreateFrame, "Button", spec.overlay, UIParent, "BackdropTemplate")
  if not ok or not overlay then
    overlay = CreateFrame("Button", spec.overlay, UIParent)
  end
  overlay:SetFrameStrata("DIALOG")
  overlay:SetFrameLevel(200)
  overlay:SetAllPoints(visual or host)
  overlay:EnableMouse(false)
  if overlay.SetBackdrop then
    overlay:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
    })
    overlay:SetBackdropColor(0, 0, 0, 0)
    overlay:SetBackdropBorderColor(0.45, 0.81, 1, 0.95)
  end
  local fill = overlay:CreateTexture(nil, "ARTWORK")
  fill:SetAllPoints(overlay)
  fill:SetColorTexture(HUD_BLUE[1], HUD_BLUE[2], HUD_BLUE[3], HUD_FILL)
  overlay.fill = fill
  local label = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("CENTER")
  label:SetTextColor(1, 1, 1, 1)
  label:SetText(spec.label)
  overlay.fontString = label
  overlay.host = host
  overlay.hostId = spec.id
  local drag
  local endMove
  local tick
  local function currentHost()
    return overlay.host or host
  end
  local function cursor()
    if Addon.EditCursor then
      return Addon:EditCursor()
    end
    local scale = 1
    if UIParent and UIParent.GetEffectiveScale then
      scale = UIParent:GetEffectiveScale() or 1
    end
    local cx, cy = 0, 0
    if GetCursorPosition then
      cx, cy = GetCursorPosition()
    end
    return cx / scale, cy / scale
  end
  local function startTick()
    if Addon.StartEditDragTick then
      Addon:StartEditDragTick(tick)
    else
      overlay:SetScript("OnUpdate", tick)
    end
  end
  local function stopTick()
    if Addon.StopEditDragTick then
      Addon:StopEditDragTick()
    else
      overlay:SetScript("OnUpdate", nil)
    end
  end
  local function placeHost(target, x, y)
    local clear = target.ClearAllPointsBase or target.ClearAllPoints
    local setPoint = target.SetPointBase or target.SetPoint
    if clear then
      clear(target)
    end
    if setPoint then
      setPoint(target, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
    end
  end
  local function dragToCursor()
    local target = currentHost()
    if not drag or not target then
      return
    end
    local cx, cy = cursor()
    local x, y = cx + drag.dx, cy + drag.dy
    if not (IsShiftKeyDown and IsShiftKeyDown()) then
      local visLeft, visBottom, visWidth, visHeight
      if Addon.HostVisualRect then
        visLeft, visBottom, visWidth, visHeight = Addon:HostVisualRect(target, spec.id)
      end
      visLeft = visLeft or (target.GetLeft and target:GetLeft()) or x
      visBottom = visBottom or (target.GetBottom and target:GetBottom()) or y
      visWidth = visWidth or (target.GetWidth and target:GetWidth()) or 0
      visHeight = visHeight or (target.GetHeight and target:GetHeight()) or 0
      local insetX = visLeft - ((target.GetLeft and target:GetLeft()) or visLeft)
      local insetY = visBottom - ((target.GetBottom and target:GetBottom()) or visBottom)
      local snapX, snapY = x + insetX, y + insetY
      if Addon.SnapVisualToGrid then
        snapX, snapY = Addon:SnapVisualToGrid(snapX, snapY, visWidth, visHeight)
      elseif Addon.SnapValue then
        snapX, snapY = Addon:SnapValue(snapX), Addon:SnapValue(snapY)
      end
      x, y = snapX - insetX, snapY - insetY
    end
    placeHost(target, x, y)
    if spec.id == "stance" then
      placeStanceOverlay(overlay, target)
    else
      placeVisualOverlay(overlay, target, spec.id)
    end
    if Addon.PaintEditReadout then
      Addon:PaintEditReadout(target, spec.label)
    end
  end
  tick = function()
    if drag then
      dragToCursor()
    end
    if drag and IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
      endMove()
    end
  end
  local function beginMove()
    if not Addon.editMode or drag then
      return
    end
    local target = currentHost()
    if not target then
      return
    end
    target._shadowUIDragging = true
    if target.SetMovable then
      target:SetMovable(true)
    end
    if Addon.SelectEditOverlay then
      Addon:SelectEditOverlay(overlay)
    end
    local cx, cy = cursor()
    local left = target.GetLeft and target:GetLeft()
    local bottom = target.GetBottom and target:GetBottom()
    if left == nil or bottom == nil then
      left, bottom = stanceOverlayRect(target)
    end
    drag = {
      dx = (left or 0) - cx,
      dy = (bottom or 0) - cy,
    }
    startTick()
    dragToCursor()
  end
  endMove = function()
    local target = currentHost()
    if not drag then
      return
    end
    stopTick()
    dragToCursor()
    drag = nil
    if Addon.PersistHostPosition then
      Addon:PersistHostPosition(target, spec.id)
    end
    if Addon.HideEditReadout then
      Addon:HideEditReadout()
    end
    if target then
      target._shadowUIDragging = false
    end
  end
  overlay:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" then
      beginMove()
    end
  end)
  overlay:SetScript("OnMouseUp", endMove)
  overlay:Hide()
  paint(overlay)
  return overlay
end

local function hostFrame(spec)
  if spec.resolve then
    return spec.resolve()
  end
  if spec.global then
    return _G[spec.global]
  end
end

function Addon:RefreshUnitDragOverlays()
  self.unitHosts = self.unitHosts or {}
  local editable = self.editMode == true
  for _, spec in ipairs(HOSTS) do
    local frame = hostFrame(spec)
    if frame then
      local host = self.unitHosts[spec.id]
      if not host then
        host = { id = spec.id, overlay = createOverlay(frame, spec) }
        self.unitHosts[spec.id] = host
      end
      host.frame = frame
      local overlay = host.overlay
      if overlay then
        overlay.host = frame
        if spec.id == "stance" then
          placeStanceOverlay(overlay, frame)
        elseif spec.visual then
          overlay:SetAllPoints(spec.visual() or frame)
        else
          placeVisualOverlay(overlay, frame, spec.id)
        end
        local show = editable
        if spec.id == "stance" and frame.IsShown and not frame:IsShown() then
          show = false
        end
        overlay:EnableMouse(show)
        overlay:SetShown(show)
      end
      if frame.SetMovable then
        frame:SetMovable(editable)
      end
    end
  end
end
