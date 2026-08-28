-- Rainbow Organizer groups bag items by category, not by bag. Glow sits
-- outside item quality chrome. Empty slots follow junk.
-- Parked: TOC does not load skin/rainbow.lua. These specs still load the file.
-- Run: lua tests/rainbow_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.CreateFrame = function(_, _, parent, template)
  local frame = { points = {}, parent = parent, template = template, shown = true }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:EnableMouse(on) self.mouse = on end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:SetTexture(path) tex.path = path end
    function tex:SetBlendMode(mode) tex.blend = mode end
    function tex:SetPoint(...) tex.points[#tex.points + 1] = { ... } end
    function tex:SetAllPoints(host) tex.all = host end
    function tex:SetSize(w, h) tex.w, tex.h = w, h end
    function tex:SetVertexColor(r, g, b, a)
      tex.r, tex.g, tex.b, tex.a = r, g, b, a
    end
    function tex:Show() tex.shown = true end
    function tex:Hide() tex.shown = false end
    frame.glow = tex
    return tex
  end
  return frame
end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/rainbow.lua"))()

local function info(spec)
  return spec
end

assert(Addon:ClassifyBagItem(nil) == "empty", "missing info is empty")
assert(Addon:ClassifyBagItem({}) == "empty", "no itemID is empty")
assert(Addon:ClassifyBagItem(info({ itemID = 6948, quality = 1, classID = 15, subclassID = 4, name = "Hearthstone" })) == "hearthstone",
  "Hearthstone is first")
assert(Addon:ClassifyBagItem(info({ itemID = 18984, quality = 2, classID = 7, subclassID = 3, name = "Dimensional Ripper - Everlook" })) == "hearthstone",
  "engineering teleporters sit with Hearthstone")
assert(Addon:ClassifyBagItem(info({ itemID = 1132, quality = 3, classID = 15, subclassID = 5, name = "Horn of the Timber Wolf" })) == "mounts",
  "mount subclass is mounts")
assert(Addon:ClassifyBagItem(info({ itemID = 2901, quality = 1, classID = 2, subclassID = 14, equipLoc = "", name = "Mining Pick" })) == "fixture",
  "mining pick is a profession fixture")
assert(Addon:ClassifyBagItem(info({ itemID = 6256, quality = 1, classID = 2, subclassID = 20, equipLoc = "INVTYPE_FISHINGPOLE", name = "Fishing Pole" })) == "fixture",
  "fishing pole is a profession fixture")
assert(Addon:ClassifyBagItem(info({ itemID = 2901, quality = 0, classID = 2, subclassID = 14, name = "Mining Pick" })) == "fixture",
  "a gray profession fixture is not junk")
assert(Addon:ClassifyBagItem(info({ itemID = 117, quality = 2, classID = 4, subclassID = 1, equipLoc = "INVTYPE_CHEST" })) == "gear",
  "armor is gear")
assert(Addon:ClassifyBagItem(info({ itemID = 118, quality = 3, classID = 2, subclassID = 7, equipLoc = "INVTYPE_WEAPON" })) == "gear",
  "weapons are gear")
assert(Addon:ClassifyBagItem(info({ itemID = 118, quality = 1, classID = 0, subclassID = 1, name = "Minor Healing Potion" })) == "consumable",
  "potions are consumables")
assert(Addon:ClassifyBagItem(info({ itemID = 2512, quality = 1, classID = 6, subclassID = 2, name = "Rough Arrow" })) == "consumable",
  "projectiles sit with consumables")
assert(Addon:ClassifyBagItem(info({ itemID = 2770, quality = 1, classID = 7, subclassID = 7, name = "Copper Ore" })) == "material",
  "ore is profession material")
assert(Addon:ClassifyBagItem(info({ itemID = 2406, quality = 1, classID = 9, subclassID = 1, name = "Pattern: Fine Leather Boots" })) == "material",
  "recipes sit with profession materials")
assert(Addon:ClassifyBagItem(info({ itemID = 3087, quality = 1, classID = 12, subclassID = 0, name = "Mug of Shimmer Stout" })) == "quest",
  "quest items keep their own group")
assert(Addon:ClassifyBagItem(info({ itemID = 159, quality = 0, classID = 4, subclassID = 1, name = "Tattered Cloth Vest" })) == "junk",
  "poor gear is junk")
assert(Addon:ClassifyBagItem(info({ itemID = 2589, quality = 1, classID = 7, subclassID = 5, name = "Linen Cloth" })) == "material",
  "cloth is profession material, not junk")
assert(Addon:ClassifyBagItem(info({ itemID = 414, quality = 0, classID = 0, subclassID = 5, name = "Dalaran Sharp" })) == "junk",
  "poor consumables are junk")

local order = Addon:RainbowCategoryOrder()
local rank = {}
for i, id in ipairs(order) do
  rank[id] = i
end
assert(rank.hearthstone < rank.mounts, "Hearthstone before mounts")
assert(rank.mounts < rank.fixture, "mounts before profession fixtures")
assert(rank.fixture < rank.gear, "fixtures before gear")
assert(rank.gear < rank.consumable, "gear before consumables")
assert(rank.consumable < rank.material, "consumables before profession materials")
assert(rank.material < rank.quest, "materials before quest")
assert(rank.quest < rank.other, "quest before leftover items")
assert(rank.other < rank.junk, "leftovers before junk")
assert(rank.junk < rank.empty, "junk before empty slots")

local function fakeButton(item, bag)
  local button = { info = item, bag = bag, points = {}, scale = 1 }
  function button:SetPoint(...) self.points = { ... } end
  function button:SetScale(scale) self.scale = scale end
  function button:GetFrameLevel() return 4 end
  function button:CreateTexture()
    return _G.CreateFrame().glow
  end
  return button
end

local junk = fakeButton({ itemID = 159, quality = 0, classID = 4, subclassID = 1 }, 1)
local ore = fakeButton({ itemID = 2770, quality = 1, classID = 7, subclassID = 7 }, 0)
local pick = fakeButton({ itemID = 2901, quality = 1, classID = 2, subclassID = 14, name = "Mining Pick" }, 4)
local hearth = fakeButton({ itemID = 6948, quality = 1, classID = 15, subclassID = 4, name = "Hearthstone" }, 3)
local empty = fakeButton({}, 2)
local buttons = { junk, ore, empty, pick, hearth }
Addon:SortRainbowButtons(buttons)
assert(buttons[1] == hearth, "sort puts Hearthstone first")
assert(buttons[2] == pick, "sort puts fixtures after Hearthstone")
assert(buttons[3] == ore, "sort puts materials after fixtures")
assert(buttons[4] == junk, "sort puts junk after materials")
assert(buttons[5] == empty, "empty slots trail")

local group = { width = 0, height = 0 }
function group:SetSize(width, height)
  self.width, self.height = width, height
end
Addon:PlaceRainbowButtons(group, buttons, { columns = 10, scale = 1, size = 40 })
assert(hearth.points[2] == group, "items parent to the item group, not a bag")
assert(hearth.points[4] == 0 and hearth.points[5] == 0, "first category starts at the origin")
assert(pick.points[5] < 0, "later categories sit below earlier ones")
assert(ore.points[4] == 0, "a new category starts a new row, not a bag column")
assert(pick.points[5] < hearth.points[5] - 40, "categories get extra padding, not bag breaks")
assert(group.height > 40 * 4, "category gaps grow the grid")

local sameA = fakeButton({ itemID = 117, quality = 2, classID = 4, subclassID = 1 }, 0)
local sameB = fakeButton({ itemID = 118, quality = 3, classID = 4, subclassID = 1 }, 3)
Addon:PlaceRainbowButtons(group, { sameA, sameB }, { columns = 10, scale = 1, size = 40 })
assert(sameA.points[4] == 0 and sameB.points[4] == 40,
  "same category stays on one row until the column count fills")
assert(sameA.points[5] == sameB.points[5], "same category does not insert bag padding")

-- ContainerFrameItemButtonTemplate anchors BOTTOMRIGHT. A second TOPLEFT
-- without a clear stretches the slot across the item group.
local stretched = fakeButton({ itemID = 6948, quality = 1, classID = 15, subclassID = 4, name = "Hearthstone" }, 0)
stretched.points = { { "BOTTOMRIGHT", group, "BOTTOMRIGHT", 0, 0 } }
stretched.width, stretched.height = 200, 400
function stretched:ClearAllPoints() self.points = {} end
function stretched:SetPoint(...) self.points[#self.points + 1] = { ... } end
function stretched:SetSize(width, height)
  self.width, self.height = width, height
end
Addon:PlaceRainbowButtons(group, { stretched }, { columns = 10, scale = 1, size = 40 })
assert(#stretched.points == 1, "a bag slot cannot keep the template BOTTOMRIGHT stretch")
assert(stretched.points[1][1] == "TOPLEFT", "a bag slot sits on TOPLEFT of the item group")
assert(stretched.width == 40 and stretched.height == 40, "a bag slot keeps the grid size")

local quality = { r = 0.64, g = 0.21, b = 0.93, a = 0.5 }
local iconGlow = { r = quality.r, g = quality.g, b = quality.b, a = quality.a }
local iconBorder = { r = quality.r, g = quality.g, b = quality.b }
function iconGlow:SetVertexColor() error("must not overwrite quality glow") end
function iconBorder:SetVertexColor() error("must not overwrite quality border") end
function iconGlow:SetShown() end
function iconBorder:SetShown() end
local epic = fakeButton({ itemID = 19862, quality = 4, classID = 4, subclassID = 4 }, 0)
epic.IconGlow = iconGlow
epic.IconBorder = iconBorder
Addon:PaintRainbowGlow(epic)
local ring = epic.shadowUIRainbow
assert(ring, "Rainbow Organizer paints a category ring")
assert(ring.template == "BackdropTemplate", "category ring uses a backdrop edge")
assert(ring.border and ring.border[3] == 1, "gear ring is steel blue")
assert(ring.glow and ring.glow.blend == "ADD", "category ring also glows")
assert(iconGlow.r == 0.64 and iconGlow.b == 0.93, "quality glow stays")
assert(iconBorder.r == 0.64, "quality border stays")

Addon:PaintRainbowGlow(empty)
assert(not empty.shadowUIRainbow or empty.shadowUIRainbow.shown == false,
  "empty slots have no category glow")

print("rainbow_spec OK")
