--[[
  Purpose: Snap a Bar drag size to a columns/grid that fills the slot count.
  Deps: ShadowUI addon table
  Public: ColumnChoices(), SnapBarColumns(), BarGridMetrics(), LayoutForColumns(),
          NearestBarLayout()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:ColumnChoices(buttons)
  local count = math.max(1, buttons or 1)
  local cols = {}
  for c = count, 1, -1 do
    if count % c == 0 then
      cols[#cols + 1] = c
    end
  end
  return cols
end

function Addon:SnapBarColumns(buttons, columns)
  local choices = self:ColumnChoices(buttons)
  local want = columns or choices[1]
  local best = choices[1]
  local bestDist = math.abs(best - want)
  for _, cols in ipairs(choices) do
    local dist = math.abs(cols - want)
    if dist < bestDist then
      best = cols
      bestDist = dist
    end
  end
  return best
end

function Addon:BarGridMetrics(buttons, columns, slotSize, gap, rowGaps)
  local count = math.max(1, buttons or 1)
  local cols = math.max(1, math.min(columns or count, count))
  local rows = math.ceil(count / cols)
  local size = slotSize or 36
  local space = gap or 0
  local rowTop = {}
  local rowPad = {}
  for r = 1, rows do
    rowTop[r] = (r - 1) * (size + space)
    local rg = rowGaps and rowGaps[r] or {}
    local above = math.max(0, rg.above or 0)
    local below = math.max(0, rg.below or 0)
    local pad = above + below
    local icon = size
    if pad >= size then
      local scale = (size - 1) / pad
      above = above * scale
      below = below * scale
      icon = 1
    elseif pad > 0 then
      icon = size - pad
    end
    rowPad[r] = { above = above, icon = icon }
  end
  return {
    columns = cols,
    rows = rows,
    width = cols * size + (cols - 1) * space,
    height = rows * size + (rows - 1) * space,
    rowTop = rowTop,
    rowPad = rowPad,
  }
end

function Addon:LayoutForColumns(buttons, columns, slotSize, gap, rowGaps)
  local metrics = self:BarGridMetrics(buttons, columns, slotSize, gap, rowGaps)
  return {
    columns = metrics.columns,
    rows = metrics.rows,
    width = metrics.width,
    height = metrics.height,
  }
end

function Addon:NearestBarLayout(buttons, slotSize, width, height, gap, rowGaps)
  local aspect = math.max(width or 1, 1) / math.max(height or 1, 1)
  local logAspect = math.log(aspect)
  local choices = self:ColumnChoices(buttons)
  local best = self:LayoutForColumns(buttons, choices[1], slotSize, gap, rowGaps)
  local bestDist = math.huge
  for _, cols in ipairs(choices) do
    local layout = self:LayoutForColumns(buttons, cols, slotSize, gap, rowGaps)
    local layoutLog = math.log(layout.width / layout.height)
    local dist = (layoutLog - logAspect) * (layoutLog - logAspect)
    if dist < bestDist then
      bestDist = dist
      best = layout
    end
  end
  return best
end
