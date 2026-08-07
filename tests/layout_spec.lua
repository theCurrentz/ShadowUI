-- Checks shipped layouts stay on screen and clear of each other and the cast bar.
-- Run: lua tests/layout_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "defaults/base.lua"))()
for _, class in ipairs({
  "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
  "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}) do
  assert(loadfile(root .. "defaults/classes/" .. class .. ".lua"))()
end

local LIMIT = 360
-- Cast bar plus the GCD sliver beneath it, from cast/castbar.lua and cast/gcd.lua.
local CAST = { name = "castbar", left = -216, right = 216, top = -110, bottom = -135 }

local function rect(id, cfg)
  local size = cfg.buttonSize or 36
  local columns = math.max(1, math.min(cfg.columns or cfg.buttons, cfg.buttons))
  local width = columns * size
  local height = math.ceil(cfg.buttons / columns) * size
  return {
    name = id,
    left = cfg.x - width / 2, right = cfg.x + width / 2,
    top = cfg.y + height / 2, bottom = cfg.y - height / 2,
  }
end

local function overlaps(a, b)
  return a.left < b.right and b.left < a.right and a.bottom < b.top and b.bottom < a.top
end

local function collect(layouts)
  local rects = {}
  for _, layout in ipairs(layouts) do
    for id, cfg in pairs(layout) do
      if cfg.enabled ~= false then
        rects[#rects + 1] = rect(id, cfg)
      end
    end
  end
  table.sort(rects, function(a, b) return a.name < b.name end)
  return rects
end

local function check(label, layouts)
  local rects = collect(layouts)
  rects[#rects + 1] = CAST
  for i, a in ipairs(rects) do
    assert(a.top <= LIMIT and a.bottom >= -LIMIT,
      label .. " " .. a.name .. " leaves the +/-" .. LIMIT .. " band")
    for j = i + 1, #rects do
      assert(not overlaps(a, rects[j]),
        label .. " " .. a.name .. " overlaps " .. rects[j].name)
    end
  end
  return #rects
end

local base = Addon.Defaults.base.layout
local enabled = 0
for _, cfg in pairs(base) do
  if cfg.enabled ~= false then enabled = enabled + 1 end
end
assert(enabled == 8, "expected 6 action bars plus pet and possess, got " .. enabled)
for _, id in ipairs({ "bar7", "bar8", "bar9", "bar10" }) do
  assert(base[id].enabled == false, id .. " must ship disabled")
end

print("base: " .. check("base", { base }) .. " rects clear")
for class, data in pairs(Addon.Defaults.classes) do
  local count = check(class, { base, data.layout })
  print(class .. ": " .. count .. " rects clear")
end
print("layout_spec OK")
