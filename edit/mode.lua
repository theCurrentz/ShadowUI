--[[
  Purpose: Toggle bar editing, draw a snap grid, and persist dragged positions.
  Deps: ShadowUI:WriteLayerDelta(), ShadowUI:ApplyAll(), bar frames
  Public: ShadowUI:ToggleEditMode(), ShadowUI:PersistBarPosition()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local GRID_SIZE = 36

local function snap(value)
  return math.floor((value or 0) / GRID_SIZE + 0.5) * GRID_SIZE
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
    line:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -offset)
    line:SetPoint("TOPRIGHT", grid, "TOPRIGHT", 0, -offset)
    line:SetHeight(1)
  end
  line:Show()
end

local function drawGrid(grid)
  local index = 0
  for x = 0, grid:GetWidth(), GRID_SIZE do
    index = index + 1
    addLine(grid, index, true, x)
  end
  for y = 0, grid:GetHeight(), GRID_SIZE do
    index = index + 1
    addLine(grid, index, false, y)
  end
  for i = index + 1, #grid.lines do
    grid.lines[i]:Hide()
  end
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

function Addon:RefreshBarDragOverlays()
  local layout = self:ResolveEffective().layout or {}
  for barId, bar in pairs(self.bars or {}) do
    if layout[barId] then
      self:UpdateBarLayout(bar, layout[barId])
    end
  end
end

function Addon:PersistBarPosition(bar)
  if not self.editMode or not bar.barId then
    return
  end
  local point, relativeFrame, relativePoint, x, y = bar:GetPoint(1)
  local relativeTo = relativeFrame and relativeFrame:GetName() or "UIParent"
  self:WriteLayerDelta(self:GetCharDB().editLayer, "layout", bar.barId, {
    point = point or "CENTER",
    relativeTo = relativeTo ~= "" and relativeTo or "UIParent",
    relativePoint = relativePoint or point or "CENTER",
    x = snap(x),
    y = snap(y),
  })
  self:ApplyAll()
end

function Addon:ToggleEditMode()
  self.editMode = not self.editMode
  local grid = self.editGrid or self:CreateEditGrid()
  grid:SetShown(self.editMode)
  if self.editMode then
    self:ShowLayerPicker()
    self:RefreshBarDragOverlays()
  else
    if self.layerPicker then
      self.layerPicker:Hide()
    end
    self:ApplyAll()
  end
end
