-- Checks sim dump rects match layout_spec bar math and fixed cast chrome.
-- Run: lua tests/sim_layout_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local dump = assert(loadfile(root .. "sim/dump_layout.lua"))()
local Rect = dump.Rect
local data = dump.build()
local Addon = dump.Addon

local function mergeLayout(classFile)
  local eff = { layout = {} }
  Addon:SparseMerge(eff, Addon.Defaults.base or {})
  Addon:SparseMerge(eff, Addon.Defaults.classes[classFile] or {})
  return eff.layout
end

local function find(list, id)
  for _, item in ipairs(list) do
    if item.id == id then return item end
  end
end

assert(data.grid == 12, "chrome snap must tile 1920x1080")
assert(data.screen.width == 1920 and data.screen.height == 1080)
assert(data.screen.width % data.grid == 0 and data.screen.height % data.grid == 0, "stage must fill the grid")

for classFile, pack in pairs(data.classes) do
  local layout = mergeLayout(classFile)
  for _, bar in ipairs(pack.bars) do
    local cfg = layout[bar.id]
    assert(cfg, classFile .. " missing " .. bar.id)
    local html = Rect.htmlBox(cfg, 1920, 1080)
    assert(math.abs(bar.html.left - html.left) < 0.01, bar.id .. " html left")
    assert(math.abs(bar.html.top - html.top) < 0.01, bar.id .. " html top")
    local back = Rect.fromHtml(cfg.point, html, 1920, 1080)
    assert(math.abs(back.x - bar.x) < 0.01, bar.id .. " roundtrip x")
    assert(math.abs(back.y - bar.y) < 0.01, bar.id .. " roundtrip y")
  end
  local function onGrid(value, label)
    assert(value % data.grid == 0, classFile .. " " .. label .. " off grid: " .. tostring(value))
  end
  for _, widget in ipairs(pack.chrome) do
    onGrid(widget.html.left, widget.id .. " left")
    onGrid(widget.html.top, widget.id .. " top")
    onGrid(widget.html.width, widget.id .. " width")
    onGrid(widget.html.height, widget.id .. " height")
  end
end

local chrome = data.classes.WARRIOR.chrome
local cast = find(chrome, "castbar")
local gcd = find(chrome, "gcd")
assert(cast and gcd, "cast chrome")
local castBox = Rect.wowBox("castbar", cast)
local gcdBox = Rect.wowBox("gcd", gcd)
assert(cast.lock == "gcd" and gcd.lock == "castbar", "cast and gcd lock")
assert(castBox.left == -144 and castBox.right == 144, "cast width 288")
assert(castBox.top == -120 and castBox.bottom == -144, "cast at CENTER 0,-132 height 24")
assert(gcdBox.left == castBox.left and gcdBox.right == castBox.right, "gcd shares cast width")
assert(gcdBox.top == -144 and gcdBox.bottom == -156, "gcd sits on the grid under cast")
local swing = find(chrome, "swing")
assert(swing and swing.lock == "gcd", "swing locks to the combat meter group")
assert(swing.width == 288, "swing shares cast width")
assert(swing.hands.main and swing.hands.off and not swing.hands.range, "warrior has melee swing")
local swingBox = Rect.wowBox("swing", swing)
assert(swingBox.left == castBox.left and swingBox.right == castBox.right, "swing shares cast width")
assert(swingBox.top == gcdBox.bottom, "swing sits under gcd")
assert(swing.height == 24, "warrior swing is main plus off-hand")
local hunterSwing = find(data.classes.HUNTER.chrome, "swing")
assert(hunterSwing.hands.main and hunterSwing.hands.off and hunterSwing.hands.range, "hunter has all swing hands")
assert(hunterSwing.height == 36, "hunter swing is three lanes")
local mageSwing = find(data.classes.MAGE.chrome, "swing")
assert(not mageSwing.hands.main and not mageSwing.hands.off and mageSwing.hands.range, "mage has wand only")
assert(mageSwing.height == 12, "mage swing is one lane")
local paladinSwing = find(data.classes.PALADIN.chrome, "swing")
assert(paladinSwing.hands.main and not paladinSwing.hands.off, "paladin has main-hand only")
assert(not find(chrome, "manaTicker"), "warrior has no mana ticker")
assert(find(data.classes.MAGE.chrome, "manaTicker"), "mage shows mana ticker")
assert(find(chrome, "chat"), "chat chrome")
assert(find(chrome, "chat").x == 36 and find(chrome, "chat").y == 24, "chat sits on the grid")
assert(find(chrome, "chat").width == 612, "chat width sits on the grid")
assert(find(chrome, "player").x == -198 and find(chrome, "target").x == 198, "unit frames sit on the grid")
assert(find(chrome, "minimap").x == 0 and find(chrome, "minimap").y == 0,
  "minimap is flush to the top-right")
assert(find(chrome, "detailsDamage").point == "RIGHT", "damage chart is flush right")
assert(find(chrome, "detailsThreat").point == "BOTTOMRIGHT", "threat chart sits on the right edge")
assert(cast.persist == true, "harness may drag cast")
assert(find(chrome, "player").persist == true, "harness may drag player")
assert(find(chrome, "xp").persist == true, "harness may drag XP")
assert(find(chrome, "rep").persist == true, "harness may drag reputation")
local range = find(chrome, "range")
assert(range, "range chrome")
assert(range.x == -6 and range.y == -174, "range sits on the grid near Currentz")
assert(range.width == 108 and range.height == 36, "range size sits on the grid")
local shields = find(chrome, "shields")
assert(shields, "shield chrome")
assert(shields.lock == "player", "Shield Row locks to the Player Frame")
assert(find(chrome, "player").lock == "shields", "player keeps the Shield Row")
assert(shields.persist == false, "harness does not drag the Shield Row alone")
assert(shields.x == -198, "Shield Row shares player x")
assert(shields.y == -114, "Shield Row sits above the Player Frame")
assert(shields.width == 108 and shields.height == 36, "Shield Row size sits on the grid")

print("sim_layout_spec OK")
