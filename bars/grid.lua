--[[
  Purpose: Snap a Bar drag size to a columns/rows grid that fills the slot count.
  Deps: ShadowUI addon table
  Public: ColumnChoices(), LayoutForColumns(), NearestBarLayout()
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

function Addon:LayoutForColumns(buttons, columns, slotSize)
  local count = math.max(1, buttons or 1)
  local cols = math.max(1, math.min(columns or count, count))
  local rows = math.ceil(count / cols)
  local size = slotSize or 36
  return {
    columns = cols,
    rows = rows,
    width = cols * size,
    height = rows * size,
  }
end

function Addon:NearestBarLayout(buttons, slotSize, width, height)
  local aspect = math.max(width or 1, 1) / math.max(height or 1, 1)
  local logAspect = math.log(aspect)
  local choices = self:ColumnChoices(buttons)
  local best = self:LayoutForColumns(buttons, choices[1], slotSize)
  local bestDist = math.huge
  for _, cols in ipairs(choices) do
    local layout = self:LayoutForColumns(buttons, cols, slotSize)
    local layoutLog = math.log(layout.width / layout.height)
    local dist = (layoutLog - logAspect) * (layoutLog - logAspect)
    if dist < bestDist then
      bestDist = dist
      best = layout
    end
  end
  return best
end
