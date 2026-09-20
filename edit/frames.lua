--[[
  Purpose: HUD drag hosts for Player Frame, Target Frame, Cast Bar, Range Display,
           the Blizzard Stance Bar, and the Cooldown Manager. Cooldown wrap resize
           snaps columns like a Bar.
  Deps: ShadowUI:SnapFrameToGrid(), ShadowUI:PersistHostPosition(),
        ShadowUI:SnapFrameSize(), ShadowUI:SelectEditOverlay(), ShadowUI:StartEditDragTick()
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
  { id = "player", global = "PlayerFrame", overlay = "ShadowUIPlayerDrag", label = "Player" },
  { id = "target", global = "TargetFrame", overlay = "ShadowUITargetDrag", label = "Target" },
  { id = "stance", overlay = "ShadowUIStanceDrag", label = "Stance",
    resolve = resolveStanceHost },
  { id = "cast", overlay = "ShadowUICastDrag", label = "Cast", resizable = true,
    resolve = function() return Addon.castGroup end,
    visual = function() return Addon.castBar or Addon.castGroup end },
  { id = "range", overlay = "ShadowUIRangeDrag", label = "Range",
    resolve = function() return Addon.rangeDisplay end },
  { id = "cooldown", overlay = "ShadowUICooldownDrag", label = "Cooldowns",
    gridResize = true,
    resolve = function() return Addon.cooldownManager or _G.ShadowUICooldownManager end },
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
  local sizing = false
  local drag
  local origin
  local endMove
  local endSize
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
  local function hostScale(target)
    target = target or currentHost()
    local scale = (target and target.GetScale and target:GetScale()) or 1
    if scale == 0 then
      return 1
    end
    return scale
  end
  local function sizeGridToCursor()
    local target = currentHost()
    if not origin or not target or not Addon.NearestBarLayout then
      return
    end
    local cx, cy = cursor()
    local live = (Addon.ResolveEffective and Addon:ResolveEffective()) or {}
    live = live.layout and live.layout.cooldown or {}
    local shipped = Addon.Defaults and Addon.Defaults.base and Addon.Defaults.base.layout
    shipped = shipped and shipped.cooldown or {}
    local max = math.max(1, live.max or shipped.max or 8)
    local size = live.buttonSize or shipped.buttonSize or 36 * 0.9
    local gap = live.gap
    if gap == nil then
      gap = shipped.gap or 4
    end
    local layout = Addon:NearestBarLayout(max, size, cx - origin.left, origin.top - cy, gap)
    target._previewColumns = layout.columns
    target:ClearAllPoints()
    target:SetSize(layout.width, layout.height)
    target:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", origin.left,
      origin.top - layout.height * hostScale(target))
    overlay:SetAllPoints(target)
    if Addon.RefreshCooldownManager then
      Addon:RefreshCooldownManager()
    end
    if Addon.PaintEditReadout then
      Addon:PaintEditReadout(target, spec.label)
    end
  end
  local function sizeHostToCursor()
    local target = currentHost()
    if not origin or not target then
      return
    end
    local cx, cy = cursor()
    local scale = hostScale(target)
    local width = (cx - origin.left) / scale
    local height = (origin.top - cy) / scale
    local minW, minH, maxW, maxH = 36 * 0.9 * 4, 12, 36 * 0.9 * 16, 72
    if not (IsShiftKeyDown and IsShiftKeyDown()) then
      if Addon.SnapValue then
        width = Addon:SnapValue(width)
      end
      height = math.floor((height or 0) / 4 + 0.5) * 4
    end
    if width < minW then
      width = minW
    end
    if width > maxW then
      width = maxW
    end
    if height < minH then
      height = minH
    end
    if height > maxH then
      height = maxH
    end
    if target.ClearAllPoints then
      target:ClearAllPoints()
    end
    if target.SetSize then
      target:SetSize(width, height)
    end
    placeHost(target, origin.left, origin.top - height * scale)
    if spec.visual then
      overlay:SetAllPoints(spec.visual() or target)
    else
      overlay:SetAllPoints(target)
    end
    if Addon.PaintEditReadout then
      Addon:PaintEditReadout(target, spec.label)
    end
  end
  tick = function()
    if sizing then
      if spec.gridResize then
        sizeGridToCursor()
      else
        sizeHostToCursor()
      end
    elseif drag then
      dragToCursor()
    end
    if (sizing or drag) and IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
      if sizing then
        endSize()
      else
        endMove()
      end
    end
  end
  local function beginMove()
    if not Addon.editMode or sizing or drag then
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
  if spec.resizable or spec.gridResize then
    local grip = CreateFrame("Button", spec.overlay .. "Size", overlay)
    grip:SetSize(12, 12)
    grip:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)
    grip:SetFrameLevel((overlay.GetFrameLevel and overlay:GetFrameLevel() or 200) + 1)
    grip:EnableMouse(true)
    local gripFill = grip:CreateTexture(nil, "ARTWORK")
    gripFill:SetAllPoints(grip)
    gripFill:SetColorTexture(1, 1, 1, 0.85)
    overlay.resizeGrip = grip
    local function beginSize()
      if not Addon.editMode or sizing or drag then
        return
      end
      local target = currentHost()
      if not target then
        return
      end
      sizing = true
      target._shadowUIDragging = true
      if Addon.SelectEditOverlay then
        Addon:SelectEditOverlay(overlay)
      end
      local top = target.GetTop and target:GetTop()
      if not top then
        local scale = hostScale(target)
        top = (target.GetBottom and target:GetBottom() or 0)
          + ((target.GetHeight and target:GetHeight() or 0) * scale)
      end
      origin = {
        left = target.GetLeft and target:GetLeft() or 0,
        top = top,
      }
      startTick()
      if spec.gridResize then
        sizeGridToCursor()
      else
        sizeHostToCursor()
      end
    end
    endSize = function()
      if not sizing then
        return
      end
      local target = currentHost()
      sizing = false
      stopTick()
      if spec.gridResize then
        sizeGridToCursor()
      else
        sizeHostToCursor()
      end
      origin = nil
      if Addon.PersistHostPosition then
        Addon:PersistHostPosition(target, spec.id, true)
      end
      if Addon.HideEditReadout then
        Addon:HideEditReadout()
      end
      if target then
        target._shadowUIDragging = false
      end
    end
    grip:SetScript("OnMouseDown", function(_, button)
      if button == "LeftButton" then
        beginSize()
      end
    end)
    grip:SetScript("OnMouseUp", endSize)
  end
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
        if overlay.resizeGrip then
          overlay.resizeGrip:EnableMouse(editable)
          overlay.resizeGrip:SetShown(editable)
        end
      end
      if frame.SetMovable then
        frame:SetMovable(editable)
      end
      if spec.resizable and frame.SetResizable then
        frame:SetResizable(editable)
        if editable then
          if frame.SetResizeBounds then
            frame:SetResizeBounds(36 * 0.9 * 4, 12, 36 * 0.9 * 16, 72)
          elseif frame.SetMinResize then
            frame:SetMinResize(36 * 0.9 * 4, 12)
            if frame.SetMaxResize then
              frame:SetMaxResize(36 * 0.9 * 16, 72)
            end
          end
        end
      end
    end
  end
end
