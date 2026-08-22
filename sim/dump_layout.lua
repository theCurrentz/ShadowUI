--[[
  Purpose: Dump shipped Base+Class layouts to sim/layout.json.
  Deps: core/resolve.lua SparseMerge, defaults, cast/swing.lua, sim/rect.lua, sim/chrome.lua
  Run: lua sim/dump_layout.lua
]]

local function findRoot()
  local src = (arg and arg[0] or ""):gsub("\\", "/")
  return src:match("^(.*)sim/dump_layout%.lua$")
    or src:match("^(.*)tests/")
    or ""
end

local root = findRoot()
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "cast/swing.lua"))()
assert(loadfile(root .. "defaults/base.lua"))()

local CLASSES = {
  "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
  "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}
for _, class in ipairs(CLASSES) do
  assert(loadfile(root .. "defaults/classes/" .. class .. ".lua"))()
end

local Rect = assert(loadfile(root .. "sim/rect.lua"))()
local chrome = assert(loadfile(root .. "sim/chrome.lua"))()
local SCREEN = { width = 1920, height = 1080 }
local CLASS_KEYS = { stance = true, aura = true, form = true }

local function encode(value)
  local kind = type(value)
  if value == nil then
    return "null"
  elseif kind == "boolean" then
    return value and "true" or "false"
  elseif kind == "number" then
    if math.floor(value) == value then
      return string.format("%.0f", value)
    end
    return tostring(value)
  elseif kind == "string" then
    return '"' .. value:gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
  elseif kind == "table" then
    local n, count = #value, 0
    for _ in pairs(value) do count = count + 1 end
    if n > 0 and count == n then
      local parts = {}
      for i = 1, n do
        parts[i] = encode(value[i])
      end
      return "[" .. table.concat(parts, ",") .. "]"
    end
    local keys = {}
    for k in pairs(value) do
      keys[#keys + 1] = tostring(k)
    end
    table.sort(keys)
    local parts = {}
    for _, k in ipairs(keys) do
      local item = value[k]
      if item == nil then
        for orig, v in pairs(value) do
          if tostring(orig) == k then item = v break end
        end
      end
      parts[#parts + 1] = encode(k) .. ":" .. encode(item)
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  error("cannot encode " .. kind)
end

local function widgetFrom(id, cfg, persist, target, kind)
  local copy = Addon:DeepCopy(cfg)
  copy.id = id
  copy.persist = persist
  copy.target = target
  copy.kind = kind or "bar"
  copy.hideFor = nil
  local html = Rect.htmlBox(cfg, SCREEN.width, SCREEN.height)
  -- Chrome snaps to 12px. Bars keep buttonSize so a 32.4px icon does not round to 36.
  if kind ~= "bar" then
    html = Rect.snapBox(html)
  end
  copy.html = html
  copy.width = html.width
  copy.height = html.height
  return copy
end

local function resolveClass(classFile)
  local eff = { layout = {}, keybinds = {} }
  Addon:SparseMerge(eff, Addon.Defaults.base or {})
  Addon:SparseMerge(eff, Addon.Defaults.classes[classFile] or {})
  return eff
end

local function chromeFor(classFile)
  local list = {}
  for _, cfg in ipairs(chrome) do
    if not (cfg.hideFor and cfg.hideFor[classFile]) then
      local spec = Addon:DeepCopy(cfg)
      if spec.id == "swing" then
        spec.hands = Addon:SwingHandsForClass(classFile)
        local n = (spec.hands.main and 1 or 0)
          + (spec.hands.off and 1 or 0)
          + (spec.hands.range and 1 or 0)
        spec.width = 288
        spec.height = math.max(1, n) * 12
        spec.y = -156 - spec.height / 2
      end
      list[#list + 1] = widgetFrom(spec.id, spec, spec.persist ~= false, "chrome", spec.kind)
      list[#list].label = spec.label
      list[#list].hands = spec.hands
    end
  end
  return list
end

local function barsFor(classFile)
  local layout = resolveClass(classFile).layout or {}
  local ids = {}
  for id in pairs(layout) do
    ids[#ids + 1] = id
  end
  table.sort(ids)
  local list = {}
  for _, id in ipairs(ids) do
    local cfg = layout[id]
    if cfg.enabled ~= false and id ~= "player" and id ~= "target"
      and id ~= "cast" and id ~= "range" then
      local target = CLASS_KEYS[id] and "class" or "base"
      list[#list + 1] = widgetFrom(id, cfg, true, target, "bar")
    end
  end
  return list
end

local function build()
  local classes = {}
  for _, classFile in ipairs(CLASSES) do
    classes[classFile] = {
      chrome = chromeFor(classFile),
      bars = barsFor(classFile),
    }
  end
  return {
    screen = SCREEN,
    grid = Rect.snapSize(),
    classes = classes,
  }
end

local data = build()
if arg and arg[0] and arg[0]:gsub("\\", "/"):match("sim/dump_layout%.lua$") then
  local json = encode(data)
  local jsonFile = assert(io.open(root .. "sim/layout.json", "w"))
  jsonFile:write(json)
  jsonFile:close()
  print("wrote sim/layout.json")
end

return {
  build = function() return data end,
  encode = encode,
  Rect = Rect,
  Addon = Addon,
  SCREEN = SCREEN,
}
