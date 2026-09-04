--[[
  Purpose: Layout Edit Mode (grid drag; Shift skips snap; persist nearest UIParent point)
           and session switching for Keybind Edit Mode.
  Deps: ShadowUI:WriteLayerDelta(), ShadowUI:ApplyAll(), bar frames, edit/keybinds.lua
  Public: SetEditSession(), ApplyEditSession(), ToggleEditMode(), ToggleKeybindMode(),
          RelativeScreenAnchor(), HostVisualRect(), SnapVisualToGrid(), SnapFrameToGrid(),
          FormatEditReadout(), PaintEditReadout(), HideEditReadout(),
          PersistBarPosition(bar, withGrid?), PersistHostPosition(), SnapFrameSize(),
          OnRegenDisabled()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local GRID_SIZE = 36 * 0.9

local function snap(value)
  return math.floor((value or 0) / GRID_SIZE + 0.5) * GRID_SIZE
end

local function shiftSkipsSnap()
  return IsShiftKeyDown and IsShiftKeyDown() == true
end

function Addon:SnapValue(value)
  return snap(value)
end

local UNIT_VISUAL = {
  player = {
    "PlayerPortrait", "PlayerFramePortrait", "PlayerFrameHealthBar",
    "PlayerFrameManaBar", "PlayerName",
  },
  target = {
    "TargetFramePortrait", "TargetFrameHealthBar", "TargetFrameManaBar",
    "TargetFrameName", "TargetFrameTextureFrameName",
  },
}

local function addRegion(rect, region)
  if not region then
    return rect
  end
  if region.IsShown and not region:IsShown() then
    return rect
  end
  local left = region.GetLeft and region:GetLeft()
  local bottom = region.GetBottom and region:GetBottom()
  if left == nil or bottom == nil then
    return rect
  end
  local width = region.GetWidth and region:GetWidth() or 0
  local height = region.GetHeight and region:GetHeight() or 0
  local right = left + width
  local top = bottom + height
  if not rect then
    return { left = left, bottom = bottom, right = right, top = top }
  end
  rect.left = math.min(rect.left, left)
  rect.bottom = math.min(rect.bottom, bottom)
  rect.right = math.max(rect.right, right)
  rect.top = math.max(rect.top, top)
  return rect
end

function Addon:HostVisualRect(frame, layoutId)
  if not frame then
    return
  end
  local rect
  if layoutId == "range" then
    local left = frame.GetLeft and frame:GetLeft()
    local bottom = frame.GetBottom and frame:GetBottom()
    local width = frame.GetWidth and frame:GetWidth() or 0
    local height = frame.GetHeight and frame:GetHeight() or 0
    local tw, th = width, height
    local text = frame.text
    if text and (not text.IsShown or text:IsShown()) then
      local sw = text.GetStringWidth and text:GetStringWidth()
      if not sw or sw <= 0 then
        sw = text.GetWidth and text:GetWidth()
      end
      local sh = text.GetStringHeight and text:GetStringHeight()
      if not sh or sh <= 0 then
        sh = text.GetHeight and text:GetHeight()
      end
      if sw and sw > 0 then
        tw = sw
      end
      if sh and sh > 0 then
        th = sh
      end
    end
    if left and bottom and tw > 0 and th > 0 then
      return left + (width - tw) / 2, bottom + (height - th) / 2, tw, th
    end
  else
    local names = UNIT_VISUAL[layoutId]
    if names then
      for _, name in ipairs(names) do
        rect = addRegion(rect, _G[name])
      end
    end
    rect = addRegion(rect, frame.portrait)
    rect = addRegion(rect, frame.healthbar)
    rect = addRegion(rect, frame.manabar)
    local container = frame.PlayerFrameContainer or frame.TargetFrameContainer
    if container then
      rect = addRegion(rect, container.PlayerPortrait)
      rect = addRegion(rect, container.Portrait)
    end
  end
  if rect then
    return rect.left, rect.bottom, rect.right - rect.left, rect.top - rect.bottom
  end
  local left = frame.GetLeft and frame:GetLeft()
  local bottom = frame.GetBottom and frame:GetBottom()
  local width = frame.GetWidth and frame:GetWidth() or 0
  local height = frame.GetHeight and frame:GetHeight() or 0
  return left, bottom, width, height
end

local SCREEN_POINTS = {
  { name = "CENTER", x = 0.5, y = 0.5 },
  { name = "BOTTOM", x = 0.5, y = 0 },
  { name = "TOP", x = 0.5, y = 1 },
  { name = "LEFT", x = 0, y = 0.5 },
  { name = "RIGHT", x = 1, y = 0.5 },
  { name = "BOTTOMLEFT", x = 0, y = 0 },
  { name = "BOTTOMRIGHT", x = 1, y = 0 },
  { name = "TOPLEFT", x = 0, y = 1 },
  { name = "TOPRIGHT", x = 1, y = 1 },
}

local function screenOffset(point, left, bottom, width, height, screenW, screenH)
  if point == "TOPLEFT" then
    return left, bottom + height - screenH
  elseif point == "TOP" then
    return left + width / 2 - screenW / 2, bottom + height - screenH
  elseif point == "TOPRIGHT" then
    return left + width - screenW, bottom + height - screenH
  elseif point == "LEFT" then
    return left, bottom + height / 2 - screenH / 2
  elseif point == "CENTER" then
    return left + width / 2 - screenW / 2, bottom + height / 2 - screenH / 2
  elseif point == "RIGHT" then
    return left + width - screenW, bottom + height / 2 - screenH / 2
  elseif point == "BOTTOM" then
    return left + width / 2 - screenW / 2, bottom
  elseif point == "BOTTOMRIGHT" then
    return left + width - screenW, bottom
  end
  return left, bottom
end

function Addon:RelativeScreenAnchor(left, bottom, width, height, screenW, screenH)
  left = left or 0
  bottom = bottom or 0
  width = width or 0
  height = height or 0
  if not screenW or not screenH or screenW <= 0 or screenH <= 0 then
    return "BOTTOMLEFT", left, bottom
  end
  local cx = left + width / 2
  local cy = bottom + height / 2
  local bestName = "BOTTOMLEFT"
  local bestDist
  for _, spec in ipairs(SCREEN_POINTS) do
    local dx = cx - spec.x * screenW
    local dy = cy - spec.y * screenH
    local dist = dx * dx + dy * dy
    if not bestDist or dist < bestDist then
      bestName = spec.name
      bestDist = dist
    end
  end
  local x, y = screenOffset(bestName, left, bottom, width, height, screenW, screenH)
  return bestName, x, y
end

local function persistAnchor(self, frame, x, y)
  local width = frame.GetWidth and frame:GetWidth() or 0
  local height = frame.GetHeight and frame:GetHeight() or 0
  local screenW = UIParent and UIParent.GetWidth and UIParent:GetWidth()
  local screenH = UIParent and UIParent.GetHeight and UIParent:GetHeight()
  local point, ox, oy = self:RelativeScreenAnchor(x, y, width, height, screenW, screenH)
  return {
    point = point,
    relativeTo = "UIParent",
    relativePoint = point,
    x = ox,
    y = oy,
  }
end

function Addon:SnapVisualToGrid(left, bottom, width, height)
  if shiftSkipsSnap() then
    return left, bottom
  end
  local x, y = snap(left), snap(bottom)
  local screenW = UIParent and UIParent.GetWidth and UIParent:GetWidth()
  local screenH = UIParent and UIParent.GetHeight and UIParent:GetHeight()
  if screenW and width and width > 0 then
    local centerLeft = screenW / 2 - width / 2
    if math.abs(left - centerLeft) <= GRID_SIZE then
      x = centerLeft
    end
  end
  if screenH and height and height > 0 then
    local centerBottom = screenH / 2 - height / 2
    if math.abs(bottom - centerBottom) <= GRID_SIZE then
      y = centerBottom
    end
  end
  return x, y
end

function Addon:SnapFrameToGrid(frame, layoutId)
  if not frame or not frame.GetLeft or not frame.GetBottom then
    return
  end
  local left, bottom = frame:GetLeft(), frame:GetBottom()
  if not left or not bottom then
    return
  end
  local visLeft, visBottom, visWidth, visHeight = self:HostVisualRect(frame, layoutId)
  visLeft = visLeft or left
  visBottom = visBottom or bottom
  visWidth = visWidth or (frame.GetWidth and frame:GetWidth()) or 0
  visHeight = visHeight or (frame.GetHeight and frame:GetHeight()) or 0
  local x, y = visLeft, visBottom
  if not shiftSkipsSnap() then
    x, y = self:SnapVisualToGrid(visLeft, visBottom, visWidth, visHeight)
  end
  x = left + (x - visLeft)
  y = bottom + (y - visBottom)
  if frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
  return x, y
end

local function formatNum(value)
  value = tonumber(value) or 0
  local rounded = math.floor(value + 0.5)
  if math.abs(value - rounded) < 0.05 then
    return tostring(rounded)
  end
  return string.format("%.1f", value)
end

function Addon:FormatEditReadout(name, point, x, y, width, height)
  return string.format(
    "%s\n%s %s, %s\n%s × %s",
    name or "",
    point or "BOTTOMLEFT",
    formatNum(x),
    formatNum(y),
    formatNum(width),
    formatNum(height)
  )
end

function Addon:EditReadoutForFrame(frame)
  if not frame then
    return "BOTTOMLEFT", 0, 0, 0, 0
  end
  local left = frame.GetLeft and frame:GetLeft() or 0
  local bottom = frame.GetBottom and frame:GetBottom() or 0
  local width = frame.GetWidth and frame:GetWidth() or 0
  local height = frame.GetHeight and frame:GetHeight() or 0
  local screenW = UIParent and UIParent.GetWidth and UIParent:GetWidth()
  local screenH = UIParent and UIParent.GetHeight and UIParent:GetHeight()
  local point, x, y = self:RelativeScreenAnchor(left, bottom, width, height, screenW, screenH)
  return point, x, y, width, height
end

function Addon:EnsureEditReadout()
  if self.editReadout then
    return self.editReadout
  end
  if not CreateFrame then
    return nil
  end
  local chip = CreateFrame("Frame", "ShadowUIEditReadout", UIParent, "BackdropTemplate")
  chip:SetSize(220, 54)
  chip:SetPoint("TOP", UIParent, "TOP", 0, -88)
  chip:SetFrameStrata("FULLSCREEN_DIALOG")
  chip:SetFrameLevel(310)
  if chip.SetBackdrop then
    chip:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
    })
    chip:SetBackdropColor(0, 0, 0, 0.72)
    chip:SetBackdropBorderColor(0.45, 0.81, 1, 0.95)
  end
  local label = chip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("CENTER")
  label:SetTextColor(1, 1, 1, 1)
  if label.SetJustifyH then
    label:SetJustifyH("CENTER")
  end
  chip.fontString = label
  chip:Hide()
  self.editReadout = chip
  return chip
end

function Addon:PaintEditReadout(frame, name)
  local chip = self:EnsureEditReadout()
  if not chip then
    return
  end
  local point, x, y, width, height = self:EditReadoutForFrame(frame)
  if chip.fontString and chip.fontString.SetText then
    chip.fontString:SetText(self:FormatEditReadout(name, point, x, y, width, height))
  end
  if chip.Show then
    chip:Show()
  end
end

function Addon:HideEditReadout()
  local chip = self.editReadout
  if chip and chip.Hide then
    chip:Hide()
  end
end

local function addLine(grid, index, vertical, offset)
  local line = grid.lines[index] or grid:CreateTexture(nil, "BACKGROUND")
  grid.lines[index] = line
  line:SetColorTexture(1, 1, 1, 0.14)
  line:ClearAllPoints()
  if vertical then
    line:SetPoint("TOPLEFT", grid, "TOPLEFT", offset, 0)
    line:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", offset, 0)
    line:SetWidth(1)
  else
    -- Match SnapFrameToGrid: y grows from the bottom of the screen.
    line:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", 0, offset)
    line:SetPoint("BOTTOMRIGHT", grid, "BOTTOMRIGHT", 0, offset)
    line:SetHeight(1)
  end
  line:Show()
end

local function addCenter(grid, key, vertical, offset)
  local line = grid[key] or grid:CreateTexture(nil, "ARTWORK")
  grid[key] = line
  line:SetColorTexture(0.92, 0.35, 0.85, 0.75)
  line:ClearAllPoints()
  if vertical then
    line:SetPoint("TOPLEFT", grid, "TOPLEFT", offset, 0)
    line:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", offset, 0)
    line:SetWidth(1)
  else
    line:SetPoint("BOTTOMLEFT", grid, "BOTTOMLEFT", 0, offset)
    line:SetPoint("BOTTOMRIGHT", grid, "BOTTOMRIGHT", 0, offset)
    line:SetHeight(1)
  end
  line:Show()
end

local function drawGrid(grid)
  local index = 0
  local width = grid:GetWidth() or 0
  local height = grid:GetHeight() or 0
  -- Multiply from an integer index so lines share SnapValue coords (32.4 is not exact).
  for i = 0, math.floor(width / GRID_SIZE) do
    index = index + 1
    addLine(grid, index, true, i * GRID_SIZE)
  end
  for i = 0, math.floor(height / GRID_SIZE) do
    index = index + 1
    addLine(grid, index, false, i * GRID_SIZE)
  end
  for i = index + 1, #grid.lines do
    grid.lines[i]:Hide()
  end
  addCenter(grid, "vCenter", true, width / 2)
  addCenter(grid, "hCenter", false, height / 2)
end

function Addon:CreateEditGrid()
  local grid = CreateFrame("Frame", "ShadowUIEditGrid", UIParent)
  grid:SetAllPoints(UIParent)
  grid:SetFrameStrata("LOW")
  grid:SetFrameLevel(0)
  grid:EnableMouse(false)
  grid.lines = {}
  grid:SetScript("OnSizeChanged", drawGrid)
  drawGrid(grid)
  grid:Hide()
  self.editGrid = grid
  return grid
end

function Addon:SetEditSession(session)
  if session ~= "layout" and session ~= "keybinds" then
    session = nil
  end
  self.editSession = session
  self.editMode = session == "layout"
  self.keybindMode = session == "keybinds"
  return session
end

function Addon:ApplyEditSession(reapply)
  local grid = self.editGrid or self:CreateEditGrid()
  grid:SetShown(self.editMode == true)
  if self.editSession then
    self:ShowLayerPicker()
  elseif self.layerPicker then
    self.layerPicker:Hide()
  end
  if (reapply or self.editMode) and self.ApplyAll then
    self:ApplyAll()
  end
  self:RefreshBarDragOverlays()
  if self.RefreshUnitDragOverlays then
    self:RefreshUnitDragOverlays()
  end
  if self.ApplyKeybindSession then
    self:ApplyKeybindSession()
  end
  if self.ApplyCombatMeterPreview then
    self:ApplyCombatMeterPreview()
  end
end

function Addon:RefreshBarDragOverlays()
  local resolved = self:ResolveEffective() or {}
  local layout = resolved.layout or {}
  for barId, bar in pairs(self.bars or {}) do
    if layout[barId] and self.UpdateBarLayout then
      local applyCfg = layout[barId]
      if self.BarLayoutForApply then
        applyCfg = self:BarLayoutForApply(layout, barId, applyCfg)
      end
      self:UpdateBarLayout(bar, applyCfg)
    end
    local drag = self.editMode == true
    if self.UpdateBarDragOverlay then
      self:UpdateBarDragOverlay(bar, drag)
    end
  end
end

function Addon:SnapFrameSize(frame)
  if not frame or not frame.GetWidth then
    return
  end
  local width = snap(frame:GetWidth())
  local height = math.floor((frame:GetHeight() or 0) / 4 + 0.5) * 4
  local minWidth = GRID_SIZE * 4
  if width < minWidth then
    width = minWidth
  end
  if height < 12 then
    height = 12
  end
  if height > 72 then
    height = 72
  end
  if frame.SetSize then
    frame:SetSize(width, height)
  end
  return width, height
end

function Addon:PersistHostPosition(frame, layoutId, withSize)
  if not self.editMode or not layoutId or not frame then
    return
  end
  local x, y = self:SnapFrameToGrid(frame, layoutId)
  if not x then
    return
  end
  local patch = persistAnchor(self, frame, x, y)
  if withSize then
    if layoutId == "cooldown" and self.NearestBarLayout then
      local live = (self.ResolveEffective and self:ResolveEffective()) or {}
      live = live.layout and live.layout.cooldown or {}
      local shipped = self.Defaults and self.Defaults.base and self.Defaults.base.layout
      shipped = shipped and shipped.cooldown or {}
      local max = math.max(1, live.max or shipped.max or 8)
      local size = live.buttonSize or shipped.buttonSize or GRID_SIZE
      local gap = live.gap
      if gap == nil then
        gap = shipped.gap or 4
      end
      local layout = self:NearestBarLayout(max, size, frame:GetWidth(), frame:GetHeight(), gap)
      patch.columns = layout.columns
      if frame._previewColumns then
        frame._previewColumns = nil
      end
    else
      local width, height = self:SnapFrameSize(frame)
      patch.width = width
      patch.height = height
    end
  end
  self:WriteLayerDelta(self:GetCharDB().editLayer, "layout", layoutId, patch)
  self:ApplyAll()
end

function Addon:PersistBarPosition(bar, withGrid)
  if not self.editMode or not bar or not bar.barId then
    return
  end
  local x, y = self:SnapFrameToGrid(bar)
  if not x then
    return
  end
  local patch = persistAnchor(self, bar, x, y)
  if withGrid and bar.columns then
    patch.columns = bar.columns
  end
  self:WriteLayerDelta(self:GetCharDB().editLayer, "layout", bar.barId, patch)
  self:ApplyAll()
end

function Addon:ToggleEditMode()
  if self.editSession ~= "layout" and InCombatLockdown() then
    self:Print("Cannot edit layout in combat.")
    return
  end
  if self.editSession == "layout" then
    self:SetEditSession(nil)
    self:ApplyEditSession(true)
    return
  end
  self:SetEditSession("layout")
  self:ApplyEditSession(false)
end

function Addon:ToggleKeybindMode()
  if self.editSession ~= "keybinds" then
    if InCombatLockdown() then
      self:Print("Cannot bind keys in combat.")
      return false
    end
    self:SetEditSession("keybinds")
    self:ApplyEditSession(false)
    return true
  end
  self:SetEditSession(nil)
  self:ApplyEditSession(true)
  return true
end

function Addon:OnRegenDisabled()
  if not self.editSession then
    return
  end
  local session = self.editSession
  self:SetEditSession(nil)
  self:ApplyEditSession(true)
  if session == "keybinds" then
    self:Print("Keybind Edit Mode closed for combat.")
  else
    self:Print("Layout Edit Mode closed for combat.")
  end
end
