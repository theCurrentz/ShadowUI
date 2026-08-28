-- Combined inventory and bank replace Blizzard bag windows. Search, sort,
-- Darken, Outer Edge, and the Rainbow Organizer live on those frames.
-- Parked: TOC does not load skin/bags.lua. These specs still load the files.
-- Run: lua tests/bags_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    local orig = _G[object]
    if type(orig) ~= "function" then
      return
    end
    _G[object] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  object[method] = function(...)
    orig(...)
    fn(...)
  end
end
_G.UIParent = { name = "UIParent" }
_G.BACKPACK_CONTAINER = 0
_G.BANK_CONTAINER = -1
_G.KEYRING_CONTAINER = -2
_G.NUM_BAG_SLOTS = 4
_G.NUM_BANKBAGSLOTS = 6
_G.ITEM_QUALITY_COLORS = {
  [0] = { r = 0.62, g = 0.62, b = 0.62 },
  [1] = { r = 1, g = 1, b = 1 },
  [2] = { r = 0.12, g = 1, b = 0 },
  [3] = { r = 0, g = 0.44, b = 0.87 },
  [4] = { r = 0.64, g = 0.21, b = 0.93 },
}

local function fakeTex()
  local tex = { points = {} }
  function tex:SetTexture(path) self.path = path end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetVertexColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetBlendMode(mode) self.blend = mode end
  function tex:SetAllPoints(host) self.all = host end
  function tex:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function tex:SetSize(w, h) self.w, self.h = w, h end
  function tex:SetTexCoord() end
  function tex:Show() self.shown = true end
  function tex:Hide() self.shown = false end
  function tex:SetShown(shown) self.shown = shown and true or false end
  return tex
end

_G.CreateFrame = function(kind, name, parent, template)
  local frame = {
    kind = kind,
    name = name,
    parent = parent,
    template = template,
    points = {},
    shown = true,
    scripts = {},
    id = 0,
    text = "",
  }
  function frame:SetParent(nextParent) self.parent = nextParent end
  function frame:GetParent() return self.parent end
  function frame:SetFrameStrata() end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level or 4 end
  function frame:SetToplevel() end
  function frame:SetMovable() end
  function frame:EnableMouse() end
  function frame:SetClampedToScreen() end
  function frame:RegisterForDrag() end
  function frame:RegisterForClicks() end
  function frame:SetSize(width, height)
    self.width, self.height = width, height
  end
  function frame:GetWidth() return self.width or 1 end
  function frame:GetHeight() return self.height or 1 end
  function frame:SetWidth(width) self.width = width end
  function frame:SetHeight(height) self.height = height end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetAllPoints(host) self.all = host end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a)
    self.fill = { r, g, b, a }
  end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown end
  function frame:SetScript(event, fn) self.scripts[event] = fn end
  function frame:HookScript(event, fn)
    local prev = self.scripts[event]
    self.scripts[event] = function(...)
      if prev then prev(...) end
      fn(...)
    end
  end
  function frame:RegisterEvent() end
  function frame:SetID(id) self.id = id end
  function frame:GetID() return self.id end
  function frame:SetText(text) self.text = text end
  function frame:GetText() return self.text end
  function frame:SetAutoFocus() end
  function frame:SetMaxLetters() end
  function frame:SetJustifyH() end
  function frame:SetFontObject() end
  function frame:SetTextColor() end
  function frame:CreateTexture()
    return fakeTex()
  end
  function frame:CreateFontString()
    local fs = fakeTex()
    function fs:SetFontObject() end
    function fs:SetText(text) fs.text = text end
    function fs:SetJustifyH() end
    function fs:SetTextColor() end
    return fs
  end
  if name then
    _G[name] = frame
  end
  if template == "ContainerFrameItemButtonTemplate" then
    frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
  end
  return frame
end

local function fakeBlizzard(name)
  local frame = _G.CreateFrame("Frame", name, _G.UIParent)
  frame.shown = true
  return frame
end

_G.ContainerFrame1 = fakeBlizzard("ContainerFrame1")
_G.ContainerFrame2 = fakeBlizzard("ContainerFrame2")
_G.BankFrame = fakeBlizzard("BankFrame")
_G.ToggleBackpack = function()
  _G.ContainerFrame1:Show()
end
_G.OpenBackpack = function()
  _G.ContainerFrame1:Show()
end
_G.CloseBackpack = function()
  _G.ContainerFrame1:Hide()
end
_G.ToggleBag = function()
  _G.ContainerFrame1:Show()
end
_G.OpenAllBags = function()
  _G.ContainerFrame1:Show()
end
_G.CloseAllBags = function()
  _G.ContainerFrame1:Hide()
end
_G.ToggleAllBags = function()
  _G.ContainerFrame1:Show()
end

local sortedBags, sortedBank = 0, 0
_G.C_Container = {
  SortBags = function() sortedBags = sortedBags + 1 end,
  SortBankBags = function() sortedBank = sortedBank + 1 end,
}

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/rainbow.lua"))()
assert(loadfile(root .. "skin/bags.lua"))()

local invBags = Addon:BagIDs("inventory")
assert(invBags[1] == 0, "inventory starts at the backpack")
assert(invBags[2] == 1 and invBags[5] == 4, "inventory includes the four bag slots")
local bankBags = Addon:BagIDs("bank")
assert(bankBags[1] == -1, "bank starts at the bank container")
assert(bankBags[2] == 5 and bankBags[#bankBags] == 10, "bank includes purchased bank bags")

function Addon:GetBagNumSlots(bag)
  if bag == 0 then return 4 end
  if bag == 1 then return 2 end
  if bag == -1 then return 2 end
  return 0
end

local items = {
  [0] = {
    [1] = { itemID = 6948, quality = 1, classID = 15, subclassID = 4, name = "Hearthstone", hyperlink = "|Hitem:6948|h[Hearthstone]|h" },
    [2] = { itemID = 2770, quality = 1, classID = 7, subclassID = 7, name = "Copper Ore", hyperlink = "|Hitem:2770|h[Copper Ore]|h" },
    [3] = {},
    [4] = { itemID = 159, quality = 0, classID = 4, subclassID = 1, name = "Tattered Cloth Vest" },
  },
  [1] = {
    [1] = { itemID = 2901, quality = 1, classID = 2, subclassID = 14, name = "Mining Pick" },
    [2] = { itemID = 118, quality = 1, classID = 0, subclassID = 1, name = "Minor Healing Potion" },
  },
  [-1] = {
    [1] = { itemID = 2770, quality = 1, classID = 7, subclassID = 7, name = "Copper Ore" },
    [2] = {},
  },
}
function Addon:GetBagItemInfo(bag, slot)
  return items[bag] and items[bag][slot] or {}
end

local slots = Addon:CollectBagSlots("inventory")
assert(#slots == 6, "inventory collects every backpack and bag slot")
assert(slots[1].bag == 0 and slots[5].bag == 1, "slots come from every bag, then Rainbow Organizer groups them")
assert(Addon:BagItemMatches(items[0][1], "hearth"), "search matches item name")
assert(not Addon:BagItemMatches(items[0][2], "hearth"), "search hides other filled items")
assert(not Addon:BagItemMatches({}, "hearth"), "search hides empty slots")
local found = Addon:CollectBagSlots("inventory", "hearth")
assert(#found == 1 and found[1].info.itemID == 6948, "search returns only Hearthstone")

Addon:SkinBags()
local inventory = Addon.bagFrames.inventory
local bank = Addon.bagFrames.bank
assert(inventory, "inventory frame exists without a second addon")
assert(bank, "bank frame exists without a second addon")
assert(inventory.fill[1] == 0.05 and inventory.fill[4] >= 0.9, "inventory fill is Darken black")
assert(inventory.shadowUIOuter, "inventory keeps an Outer Edge")
assert(inventory.shadowUIOuter.backdrop.edgeFile:find("outer_shadow", 1, true),
  "inventory Outer Edge uses the Lorti shadow")
assert(bank.shadowUIOuter, "bank keeps an Outer Edge")
assert(inventory.search, "inventory has search")
assert(inventory.sort, "inventory has sort")
assert(bank.search and bank.sort, "bank has search and sort")

_G.ToggleBackpack()
assert(inventory.shown, "backpack toggle opens ShadowUI inventory")
assert(_G.ContainerFrame1.shown == false, "Blizzard bag windows stay hidden")
assert(_G.ContainerFrame2.shown == false, "extra Blizzard bag windows stay hidden")

Addon:HideBagFrame("inventory")
_G.OpenAllBags()
assert(inventory.shown, "OpenAllBags opens ShadowUI inventory")

_G.BankFrame.scripts.OnShow(_G.BankFrame)
assert(bank.shown, "the bank NPC opens ShadowUI bank")
assert(_G.BankFrame.shown == false, "Blizzard BankFrame stays hidden")
assert(inventory.shown, "the bank NPC also opens inventory")

Addon:SortBagFrame("inventory")
assert(sortedBags == 1, "inventory sort uses the client bag sort")
Addon:SortBagFrame("bank")
assert(sortedBank == 1, "bank sort uses the client bank sort")

Addon:RefreshBagFrame("inventory")
local group = inventory.itemGroup
assert(group.buttons[1].info.itemID == 6948, "Rainbow Organizer puts Hearthstone first")
assert(group.buttons[2].info.itemID == 2901, "fixtures follow Hearthstone even from another bag")
assert(group.buttons[2].points[1][2] == group, "items sit on one grid, not on bag frames")
assert(#group.buttons[1].points == 1, "a bag slot cannot keep the template BOTTOMRIGHT stretch")
assert(group.buttons[1].width == 37 and group.buttons[1].height == 37,
  "a bag slot keeps the slot size")
assert(group.buttons[2].points[1][5] < group.buttons[1].points[1][5] - 37,
  "categories get padding and a new row")

local epic = group.buttons[1]
epic.info = { itemID = 19862, quality = 4, classID = 4, subclassID = 4, name = "Doom's Edge" }
epic.IconBorder = fakeTex()
epic.IconGlow = fakeTex()
Addon:PaintBagQuality(epic)
assert(math.abs(epic.IconBorder.r - 0.64) < 0.02, "quality border uses epic purple")
assert(epic.IconGlow.blend == "ADD", "quality also uses an ADD glow")
local qualityR = epic.IconBorder.r
Addon:PaintRainbowGlow(epic)
assert(epic.IconBorder.r == qualityR, "Rainbow Organizer does not replace quality chrome")
assert(epic.shadowUIRainbow, "category glow sits in addition to quality")

inventory.search.text = "ore"
inventory.search.scripts.OnTextChanged(inventory.search)
local visible = 0
for _, button in ipairs(group.buttons) do
  if button.shown ~= false and button.info and button.info.itemID then
    visible = visible + 1
    assert(button.info.itemID == 2770, "live search keeps matching items")
  end
end
assert(visible == 1, "live search filters the grid")

print("bags_spec OK")
