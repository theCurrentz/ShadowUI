-- Checks shipped layouts stay clear of each other and the cast bar.
-- BOTTOM-anchored bars use bottom-edge coordinates; CENTER bars use screen centre.
-- Run: lua tests/layout_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "defaults/base.lua"))()
for _, class in ipairs({
  "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
  "SHAMAN", "MAGE", "WARLOCK", "DRUID",
}) do
  assert(loadfile(root .. "defaults/classes/" .. class .. ".lua"))()
end

local LIMIT = 360
local CAST = { name = "castbar", point = "CENTER", left = -150, right = 144, top = -118, bottom = -146 }

local function rect(id, cfg)
  local size = cfg.buttonSize or 36
  local columns = math.max(1, math.min(cfg.columns or cfg.buttons, cfg.buttons))
  local width = columns * size
  local height = math.ceil(cfg.buttons / columns) * size
  local point = cfg.point or "CENTER"
  if point == "BOTTOM" then
    return {
      name = id, point = point,
      left = cfg.x - width / 2, right = cfg.x + width / 2,
      bottom = cfg.y, top = cfg.y + height,
    }
  end
  return {
    name = id, point = point,
    left = cfg.x - width / 2, right = cfg.x + width / 2,
    top = cfg.y + height / 2, bottom = cfg.y - height / 2,
  }
end

local function overlaps(a, b)
  local eps = 1e-6
  return a.left + eps < b.right and b.left + eps < a.right
    and a.bottom + eps < b.top and b.bottom + eps < a.top
end

local function collect(layouts)
  local rects = {}
  for _, layout in ipairs(layouts) do
    for id, cfg in pairs(layout) do
      if cfg.enabled ~= false and cfg.buttons then
        rects[#rects + 1] = rect(id, cfg)
      end
    end
  end
  table.sort(rects, function(a, b) return a.name < b.name end)
  return rects
end

local function group(rects, point)
  local out = {}
  for _, r in ipairs(rects) do
    if r.point == point then
      out[#out + 1] = r
    end
  end
  return out
end

local function checkGroup(label, rects, limit)
  for i, a in ipairs(rects) do
    if limit then
      assert(a.top <= limit and a.bottom >= -limit,
        label .. " " .. a.name .. " leaves the +/-" .. limit .. " band")
    else
      assert(a.bottom >= 0, label .. " " .. a.name .. " goes below the screen edge")
    end
    for j = i + 1, #rects do
      assert(not overlaps(a, rects[j]),
        label .. " " .. a.name .. " overlaps " .. rects[j].name)
    end
  end
end

local function check(label, layouts)
  local rects = collect(layouts)
  local center = group(rects, "CENTER")
  center[#center + 1] = CAST
  checkGroup(label, center, LIMIT)
  checkGroup(label, group(rects, "BOTTOM"), nil)
  return #rects
end

local base = Addon.Defaults.base.layout
local enabled = 0
for _, cfg in pairs(base) do
  if cfg.enabled ~= false then enabled = enabled + 1 end
end
assert(enabled == 12, "expected 6 rows, two 3x4 sides, bar9, bar10, pet, and possess, got " .. enabled)
for i = 1, 6 do
  local cfg = base["bar" .. i]
  assert(cfg.enabled ~= false, "bar" .. i .. " must ship enabled")
  assert(cfg.point == "BOTTOM", "bar" .. i .. " must sit on the bottom edge")
  assert(cfg.columns == 12, "bar" .. i .. " must be a horizontal row")
end
assert(base.bar7.columns == 3 and base.bar8.columns == 3, "bar7 and bar8 must be 3x4")
assert(base.bar7.x < 0 and base.bar8.x > 0, "bar7 left, bar8 right")
for _, id in ipairs({ "bar9", "bar10" }) do
  assert(base[id].enabled ~= false, id .. " must ship enabled")
  assert(base[id].point == "BOTTOM", id .. " must sit on the bottom edge")
  assert(base[id].columns == 12, id .. " must be a horizontal row")
end
assert(base.bar9.y > base.possess.y, "bar9 sits above possess")
assert(base.bar10.y > base.bar9.y, "bar10 sits above bar9")
assert(base.bar1.y > base.bar6.y, "bar1 is the top row of the reversed stack")
assert(base.bar6.y < base.bar5.y, "rows stack downward toward bar6")
assert(base.bar6.y == 0, "bar6 must hug the screen bottom")
assert(base.bar7.y == 0 and base.bar8.y == 0, "side stacks must hug the screen bottom")
local mageLayout = Addon.Defaults.classes.MAGE.layout
assert(mageLayout.bar2.firstSlot == 61, "mage bar2 shows old bar6 slots")
assert(mageLayout.bar3.firstSlot == 13, "mage bar3 shows old bar2 slots")
assert(mageLayout.bar4.firstSlot == 25, "mage bar4 shows old bar3 slots")
assert(mageLayout.bar5.firstSlot == 37, "mage bar5 shows old bar4 slots")
assert(mageLayout.bar6.firstSlot == 49, "mage bar6 shows old bar5 slots")
local warriorLayout = Addon.Defaults.classes.WARRIOR.layout
assert(warriorLayout.bar1.stancePages[1] == 73, "warrior bar1 Battle page starts at slot 73")
assert(warriorLayout.bar1.stancePages[2] == 85, "warrior bar1 Defensive page starts at slot 85")
assert(warriorLayout.bar1.stancePages[3] == 97, "warrior bar1 Berserker page starts at slot 97")
assert(warriorLayout.bar2.firstSlot == 1, "warrior bar2 keeps the first fixed page")
assert(warriorLayout.bar7.firstSlot == 61, "warrior bar7 keeps the last fixed base page")
assert(warriorLayout.bar8.firstSlot == 109, "warrior bar8 holds fixed stance buttons")
assert(warriorLayout.bar9.enabled == false and warriorLayout.bar10.enabled == false,
  "warrior hides bars that would duplicate stance pages")
local druidLayout = Addon.Defaults.classes.DRUID.layout
assert(druidLayout.bar1.stancePages[1] == 1, "druid bar1 Caster page starts at slot 1")
assert(druidLayout.bar1.stancePages[2] == 73, "druid bar1 Cat page starts at slot 73")
assert(druidLayout.bar1.stancePages[4] == 97, "druid bar1 Bear page starts at slot 97")
assert(druidLayout.bar7.enabled == false and druidLayout.bar9.enabled == false,
  "druid hides bars that would duplicate form pages")
local rogueLayout = Addon.Defaults.classes.ROGUE.layout
assert(rogueLayout.bar1.stancePages[1] == 1, "rogue bar1 Open page starts at slot 1")
assert(rogueLayout.bar1.stancePages[2] == 73, "rogue bar1 Stealth page starts at slot 73")
assert(rogueLayout.bar7.enabled == false, "rogue hides the bar that would duplicate Stealth")

print("base: " .. check("base", { base }) .. " rects clear")
for class, data in pairs(Addon.Defaults.classes) do
  local merged = Addon:DeepCopy(base)
  Addon:SparseMerge(merged, data.layout)
  local count = check(class, { merged })
  print(class .. ": " .. count .. " rects clear")
end
print("layout_spec OK")
