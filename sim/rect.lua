--[[
  Purpose: Map ShadowUI layout points onto HTML pixels (origin top-left).
  Deps: none
  Public: size, wowBox, htmlBox, fromHtml, snap
  Mapping:
    CENTER — x/y from screen centre; WoW Y is up.
    BOTTOM — x from horizontal centre; y is the bottom edge from screen bottom.
    TOP — x from horizontal centre; y from screen top (negative is down).
    TOPLEFT / TOPRIGHT / BOTTOMLEFT / BOTTOMRIGHT — offset from that corner.
    RIGHT — flush to the right edge; y is the vertical centre offset.
]]

local Rect = {}
-- 12 tiles 1920x1080. Action buttons are 32.4px (90% of 36).
local SNAP = 12

function Rect.snapSize()
  return SNAP
end

function Rect.snap(value)
  return math.floor((value or 0) / SNAP + 0.5) * SNAP
end

function Rect.snapBox(box)
  return {
    left = Rect.snap(box.left),
    top = Rect.snap(box.top),
    width = math.max(SNAP, Rect.snap(box.width)),
    height = math.max(SNAP, Rect.snap(box.height)),
  }
end

function Rect.size(cfg)
  if cfg.width and cfg.height then
    return cfg.width, cfg.height
  end
  local size = cfg.buttonSize or 36
  local buttons = cfg.buttons or 1
  local columns = math.max(1, math.min(cfg.columns or buttons, buttons))
  return columns * size, math.ceil(buttons / columns) * size
end

function Rect.wowBox(id, cfg)
  local width, height = Rect.size(cfg)
  local x, y = cfg.x or 0, cfg.y or 0
  local point = cfg.point or "CENTER"
  if point == "BOTTOM" then
    return {
      name = id, point = point,
      left = x - width / 2, right = x + width / 2,
      bottom = y, top = y + height,
    }
  end
  return {
    name = id, point = point,
    left = x - width / 2, right = x + width / 2,
    top = y + height / 2, bottom = y - height / 2,
  }
end

function Rect.htmlBox(cfg, sw, sh)
  local w, h = Rect.size(cfg)
  local x, y = cfg.x or 0, cfg.y or 0
  local point = cfg.point or "CENTER"
  local left, top
  if point == "BOTTOM" then
    left = sw / 2 + x - w / 2
    top = sh - (y + h)
  elseif point == "TOP" then
    left = sw / 2 + x - w / 2
    top = -y
  elseif point == "TOPRIGHT" then
    left = sw + x - w
    top = -y
  elseif point == "BOTTOMRIGHT" then
    left = sw + x - w
    top = sh - y - h
  elseif point == "TOPLEFT" then
    left = x
    top = -y
  elseif point == "BOTTOMLEFT" then
    left = x
    top = sh - y - h
  elseif point == "RIGHT" then
    left = sw + x - w
    top = sh / 2 - (y + h / 2)
  else
    left = sw / 2 + x - w / 2
    top = sh / 2 - (y + h / 2)
  end
  return { left = left, top = top, width = w, height = h }
end

function Rect.fromHtml(point, box, sw, sh)
  local w, h, left, top = box.width, box.height, box.left, box.top
  point = point or "CENTER"
  if point == "BOTTOM" then
    return { x = left + w / 2 - sw / 2, y = sh - (top + h) }
  elseif point == "TOP" then
    return { x = left + w / 2 - sw / 2, y = -top }
  elseif point == "TOPRIGHT" then
    return { x = left + w - sw, y = -top }
  elseif point == "BOTTOMRIGHT" then
    return { x = left + w - sw, y = sh - (top + h) }
  elseif point == "TOPLEFT" then
    return { x = left, y = -top }
  elseif point == "BOTTOMLEFT" then
    return { x = left, y = sh - (top + h) }
  elseif point == "RIGHT" then
    return { x = left + w - sw, y = sh / 2 - (top + h / 2) }
  end
  return { x = left + w / 2 - sw / 2, y = sh / 2 - (top + h / 2) }
end

return Rect
