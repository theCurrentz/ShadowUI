--[[
  Purpose: Rainbow Organizer — group bag items by category with a coloured
           glow that sits outside item quality chrome. Categories are not bags.
  Parked: ShadowUI.toc does not load this file. It loads only with bags.lua.
  Deps: ShadowUI chrome
  Public: ShadowUI:ClassifyBagItem(), ShadowUI:RainbowCategoryOrder(),
          ShadowUI:RainbowCategoryColor(), ShadowUI:SortRainbowButtons(),
          ShadowUI:PlaceRainbowButtons(), ShadowUI:LayoutRainbowGroup(),
          ShadowUI:PaintRainbowGlow()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local ORDER = {
  "hearthstone",
  "mounts",
  "fixture",
  "gear",
  "consumable",
  "material",
  "quest",
  "other",
  "junk",
  "empty",
}

local RANK = {}
for i, id in ipairs(ORDER) do
  RANK[id] = i
end

-- Steel-blue gear uses a full blue channel so it reads apart from quality.
local COLORS = {
  hearthstone = { 1.00, 0.82, 0.20 },
  mounts = { 0.85, 0.35, 1.00 },
  fixture = { 1.00, 0.55, 0.15 },
  gear = { 0.35, 0.65, 1.00 },
  consumable = { 0.35, 1.00, 0.40 },
  material = { 0.20, 0.90, 0.85 },
  quest = { 1.00, 0.95, 0.35 },
  other = { 0.75, 0.75, 1.00 },
  junk = { 0.55, 0.45, 0.35 },
}

local HEARTH_IDS = {
  [6948] = true,  -- Hearthstone
  [18984] = true, -- Dimensional Ripper - Everlook
  [18986] = true, -- Ultrasafe Transporter: Gadgetzan
}

local FIXTURE_IDS = {
  [2901] = true,  -- Mining Pick
  [7005] = true,  -- Skinning Knife
  [5956] = true,  -- Blacksmith Hammer
  [6219] = true,  -- Arclight Spanner
  [10498] = true, -- Gyromatic Micro-Adjuster
  [6218] = true,  -- Runed Copper Rod
  [6339] = true,  -- Runed Silver Rod
  [11130] = true, -- Runed Golden Rod
  [11145] = true, -- Runed Truesilver Rod
  [16207] = true, -- Runed Arcanite Rod
  [9149] = true,  -- Philosopher's Stone
  [6256] = true,  -- Fishing Pole
  [6365] = true,  -- Strong Fishing Pole
  [6366] = true,  -- Darkwood Fishing Pole
  [6367] = true,  -- Big Iron Fishing Pole
  [12225] = true, -- Blump Family Fishing Pole
  [19022] = true, -- Nat Pagle's Extreme Angler FC-5000
  [19970] = true, -- Arcanite Fishing Pole
}

local CLASS = {
  consumable = 0,
  container = 1,
  weapon = 2,
  gem = 3,
  armor = 4,
  reagent = 5,
  projectile = 6,
  tradegoods = 7,
  recipe = 9,
  quiver = 11,
  quest = 12,
  questitem = 12,
  key = 13,
  miscellaneous = 15,
  profession = 19,
}

local SUB_MOUNT = 5
local SUB_FISHING = 20
local GAP = 0.55
local RING_PAD = 3
local GLOW_SIZE = 82

local function enumClass(name, fallback)
  local itemClass = _G.Enum and _G.Enum.ItemClass and _G.Enum.ItemClass[name]
  return itemClass or fallback
end

local function classId(name)
  return enumClass(name:gsub("^%l", string.upper), CLASS[name])
end

local function itemMeta(info)
  local itemID = info.itemID
  local quality = info.quality
  local classID = info.classID
  local subclassID = info.subclassID
  local equipLoc = info.equipLoc
  local name = info.name
  if classID ~= nil then
    return itemID, quality, classID, subclassID, equipLoc, name
  end
  local get = (_G.C_Item and _G.C_Item.GetItemInfoInstant) or _G.GetItemInfoInstant
  local id = itemID or info.hyperlink
  if get and id then
    local instantId, _, _, instantEquip, _, instantClass, instantSub = get(id)
    itemID = itemID or instantId
    equipLoc = equipLoc or instantEquip
    classID = instantClass
    subclassID = instantSub
  end
  if not name and itemID and _G.GetItemInfo then
    name = GetItemInfo(itemID)
  end
  return itemID, quality, classID, subclassID, equipLoc, name
end

function Addon:RainbowCategoryOrder()
  return ORDER
end

function Addon:RainbowCategoryColor(category)
  return COLORS[category]
end

function Addon:ClassifyBagItem(info)
  if not info or not info.itemID then
    return "empty"
  end
  local itemID, quality, classID, subclassID, equipLoc, name = itemMeta(info)
  if not itemID then
    return "empty"
  end
  local lower = type(name) == "string" and name:lower() or ""
  if HEARTH_IDS[itemID] or lower:find("hearthstone", 1, true)
      or lower:find("dimensional ripper", 1, true)
      or lower:find("ultrasafe transporter", 1, true) then
    return "hearthstone"
  end
  if classID == classId("miscellaneous") and subclassID == SUB_MOUNT then
    return "mounts"
  end
  if FIXTURE_IDS[itemID] or equipLoc == "INVTYPE_FISHINGPOLE"
      or (classID == classId("weapon") and subclassID == SUB_FISHING) then
    return "fixture"
  end
  if classID == classId("questitem") or classID == CLASS.quest then
    return "quest"
  end
  if (quality or 1) == 0 then
    return "junk"
  end
  if classID == classId("armor") or classID == classId("weapon")
      or classID == classId("gem") then
    return "gear"
  end
  if classID == classId("consumable") or classID == classId("projectile")
      or classID == CLASS.quiver then
    return "consumable"
  end
  if classID == classId("tradegoods") or classID == classId("reagent")
      or classID == classId("recipe") or classID == classId("profession") then
    return "material"
  end
  return "other"
end

function Addon:SortRainbowButtons(buttons)
  table.sort(buttons, function(a, b)
    local ca = RANK[self:ClassifyBagItem(a.info)] or RANK.other
    local cb = RANK[self:ClassifyBagItem(b.info)] or RANK.other
    if ca ~= cb then
      return ca < cb
    end
    local qa = (a.info and a.info.quality) or -1
    local qb = (b.info and b.info.quality) or -1
    if qa ~= qb then
      return qa > qb
    end
    local ia = (a.info and a.info.itemID) or 0
    local ib = (b.info and b.info.itemID) or 0
    return ia < ib
  end)
  return buttons
end

function Addon:PlaceRainbowButtons(group, buttons, traits)
  traits = traits or {}
  local columns = traits.columns or 10
  local scale = traits.scale or 1
  local size = traits.size or 39
  local slot = traits.slot or size
  local transposed = traits.transposed
  local x, y = 0, 0
  local prev
  for _, button in ipairs(buttons) do
    local category = self:ClassifyBagItem(button.info)
    if prev and category ~= prev then
      x, y = 0, y + 1 + GAP
    elseif x == columns then
      x, y = 0, y + 1
    end
    if button.ClearAllPoints then
      button:ClearAllPoints()
    end
    if button.SetSize then
      button:SetSize(slot, slot)
    end
    if button.SetPoint then
      local px, py = size * x, -size * y
      if transposed then
        px, py = size * y, -size * x
      end
      button:SetPoint("TOPLEFT", group, "TOPLEFT", px, py)
    end
    if button.SetScale then
      button:SetScale(scale)
    end
    x = x + 1
    prev = category
  end
  local width = math.max(columns * size * scale, 1)
  local height = math.max((y + 1) * size * scale, 1)
  if transposed then
    width, height = height, width
  end
  if group.SetSize then
    group:SetSize(width, height)
  end
  return width, height
end

function Addon:LayoutRainbowGroup(group)
  if not group or group._shadowUIRainbowLock then
    return
  end
  local buttons = group.buttons
  if not buttons or #buttons == 0 then
    return
  end
  group._shadowUIRainbowLock = true
  local columns, scale, size, transposed = 10, 1, 39, false
  if group.LayoutTraits then
    columns, scale, size, transposed = group:LayoutTraits()
  end
  self:SortRainbowButtons(buttons)
  self:PlaceRainbowButtons(group, buttons, {
    columns = columns,
    scale = scale,
    size = size,
    slot = group.slotSize or size,
    transposed = transposed,
  })
  for _, button in ipairs(buttons) do
    self:PaintRainbowGlow(button)
  end
  group._shadowUIRainbowLock = nil
end

function Addon:PaintRainbowGlow(button)
  if not button then
    return
  end
  local category = self:ClassifyBagItem(button.info)
  local color = COLORS[category]
  local ring = button.shadowUIRainbow
  if not color then
    if ring and ring.Hide then
      ring:Hide()
    end
    return
  end
  if not ring and CreateFrame then
    local ok, frame = pcall(CreateFrame, "Frame", nil, button, "BackdropTemplate")
    ring = (ok and frame) or CreateFrame("Frame", nil, button)
    button.shadowUIRainbow = ring
    if ring.EnableMouse then
      ring:EnableMouse(false)
    end
    if ring.SetPoint then
      ring:ClearAllPoints()
      ring:SetPoint("TOPLEFT", button, "TOPLEFT", -RING_PAD, RING_PAD)
      ring:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", RING_PAD, -RING_PAD)
    end
    if ring.SetBackdrop then
      ring:SetBackdrop({
        edgeFile = "Interface\\AddOns\\ShadowUI\\media\\outer_shadow",
        tile = false,
        tileSize = 32,
        edgeSize = 5,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
      })
    end
    if ring.CreateTexture then
      local glow = ring:CreateTexture(nil, "ARTWORK", nil, 7)
      ring.glow = glow
      if glow.SetTexture then
        glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
      end
      if glow.SetBlendMode then
        glow:SetBlendMode("ADD")
      end
      if glow.SetPoint then
        glow:SetPoint("CENTER")
      end
      if glow.SetSize then
        glow:SetSize(GLOW_SIZE, GLOW_SIZE)
      end
    end
  end
  if not ring then
    return
  end
  if ring.SetBackdropBorderColor then
    ring:SetBackdropBorderColor(color[1], color[2], color[3], 0.9)
  end
  local glow = ring.glow
  if glow and glow.SetVertexColor then
    glow:SetVertexColor(color[1], color[2], color[3], 0.55)
  end
  if ring.Show then
    ring:Show()
  end
end
