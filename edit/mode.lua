--[[
  Purpose: Layout Edit Mode (grid drag; Shift skips snap) and session switching for Keybind Edit Mode.
  Deps: ShadowUI:WriteLayerDelta(), ShadowUI:ApplyAll(), bar frames, edit/keybinds.lua
  Public: SetEditSession(), ApplyEditSession(), ToggleEditMode(), ToggleKeybindMode(),
          PersistBarPosition(), PersistHostPosition(), SnapFrameSize(), OnRegenDisabled()
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

function Addon:SnapFrameToGrid(frame)
  if not frame or not frame.GetLeft or not frame.GetBottom then
    return
  end
  local left, bottom = frame:GetLeft(), frame:GetBottom()
  if not left or not bottom then
    return
  end
  local x, y = left, bottom
  if not shiftSkipsSnap() then
    x, y = snap(left), snap(bottom)
  end
  if frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
  return x, y
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
  addCenter(grid, "vCenter", true, snap(width / 2))
  addCenter(grid, "hCenter", false, snap(height / 2))
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
  self:RefreshBarDragOverlays()
  if self.RefreshUnitDragOverlays then
    self:RefreshUnitDragOverlays()
  end
  if self.ApplyKeybindSession then
    self:ApplyKeybindSession()
  end
  if reapply then
    self:ApplyAll()
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
      self:UpdateBarLayout(bar, layout[barId])
    elseif self.UpdateBarDragOverlay then
      self:UpdateBarDragOverlay(bar, self.editMode == true)
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
  local x, y = self:SnapFrameToGrid(frame)
  if not x then
    return
  end
  local patch = {
    point = "BOTTOMLEFT",
    relativeTo = "UIParent",
    relativePoint = "BOTTOMLEFT",
    x = x,
    y = y,
  }
  if withSize then
    local width, height = self:SnapFrameSize(frame)
    patch.width = width
    patch.height = height
  end
  self:WriteLayerDelta(self:GetCharDB().editLayer, "layout", layoutId, patch)
  self:ApplyAll()
end

function Addon:PersistBarPosition(bar)
  self:PersistHostPosition(bar, bar and bar.barId)
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
