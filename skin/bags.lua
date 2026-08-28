--[[
  Purpose: Combined inventory and bank windows. Search, client sort, Darken,
           Outer Edge, and the Rainbow Organizer. Blizzard bag windows stay hidden.
  Parked: ShadowUI.toc does not load this file. ApplySkins does not call SkinBags.
  Deps: ShadowUI:ApplyOuterChrome(), ShadowUI:LayoutRainbowGroup(),
        ShadowUI:PaintRainbowGlow(), ShadowUI:PaintBagQuality()
  Public: ShadowUI:BagIDs(), ShadowUI:GetBagNumSlots(), ShadowUI:GetBagItemInfo(),
          ShadowUI:CollectBagSlots(), ShadowUI:BagItemMatches(),
          ShadowUI:EnsureBagFrame(), ShadowUI:RefreshBagFrame(),
          ShadowUI:ShowBagFrame(), ShadowUI:HideBagFrame(), ShadowUI:ToggleBagFrame(),
          ShadowUI:SortBagFrame(), ShadowUI:SkinBags()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local FILL = { 0.05, 0.05, 0.05, 0.92 }
local SLOT = 37
local GAP = 2
local SIZE = SLOT + GAP
local COLUMNS = { inventory = 10, bank = 14 }
local TITLE = { inventory = "Inventory", bank = "Bank" }

local function container()
  return _G.C_Container
end

function Addon:BagIDs(kind)
  if kind == "bank" then
    local bags = { _G.BANK_CONTAINER or -1 }
    local first = (_G.NUM_BAG_SLOTS or 4) + 1
    local last = first + (_G.NUM_BANKBAGSLOTS or 6) - 1
    for i = first, last do
      bags[#bags + 1] = i
    end
    return bags
  end
  local bags = { _G.BACKPACK_CONTAINER or 0 }
  for i = 1, _G.NUM_BAG_SLOTS or 4 do
    bags[#bags + 1] = i
  end
  if _G.KEYRING_CONTAINER then
    bags[#bags + 1] = _G.KEYRING_CONTAINER
  end
  return bags
end

function Addon:GetBagNumSlots(bag)
  local get = (container() and container().GetContainerNumSlots) or _G.GetContainerNumSlots
  if not get then
    return 0
  end
  return get(bag) or 0
end

function Addon:GetBagItemInfo(bag, slot)
  local get = (container() and container().GetContainerItemInfo) or _G.GetContainerItemInfo
  if not get then
    return {}
  end
  local info = get(bag, slot)
  if type(info) == "table" then
    local name = info.itemName
    if not name and info.itemID and _G.GetItemInfo then
      name = GetItemInfo(info.itemID)
    end
    return {
      itemID = info.itemID,
      quality = info.quality,
      hyperlink = info.hyperlink,
      iconFileID = info.iconFileID,
      stackCount = info.stackCount,
      isLocked = info.isLocked,
      name = name,
      classID = info.classID,
      subclassID = info.subclassID,
      equipLoc = info.equipLoc,
    }
  end
  local icon, count, locked, quality, _, _, link, _, _, itemID = get(bag, slot)
  local name, classID, subclassID, equipLoc
  if itemID and _G.GetItemInfoInstant then
    local _, _, _, loc, _, class, sub = GetItemInfoInstant(itemID)
    equipLoc, classID, subclassID = loc, class, sub
  end
  if itemID and _G.GetItemInfo then
    name = GetItemInfo(itemID)
  end
  return {
    itemID = itemID,
    quality = quality,
    hyperlink = link,
    iconFileID = icon,
    stackCount = count,
    isLocked = locked,
    name = name,
    classID = classID,
    subclassID = subclassID,
    equipLoc = equipLoc,
  }
end

function Addon:BagItemMatches(info, search)
  if not search or search == "" then
    return true
  end
  if not info or not info.itemID then
    return false
  end
  local needle = search:lower()
  local name = info.name and info.name:lower() or ""
  local link = info.hyperlink and info.hyperlink:lower() or ""
  return name:find(needle, 1, true) and true
    or link:find(needle, 1, true) and true
    or tostring(info.itemID):find(needle, 1, true) and true
    or false
end

function Addon:CollectBagSlots(kind, search)
  local slots = {}
  for _, bag in ipairs(self:BagIDs(kind)) do
    local count = self:GetBagNumSlots(bag)
    for slot = 1, count do
      local info = self:GetBagItemInfo(bag, slot) or {}
      if self:BagItemMatches(info, search) then
        slots[#slots + 1] = { bag = bag, slot = slot, info = info }
      end
    end
  end
  return slots
end

function Addon:PaintBagQuality(button)
  if not button then
    return
  end
  local quality = button.info and button.info.quality
  local colors = _G.ITEM_QUALITY_COLORS
  local color = colors and quality and colors[quality]
  local show = color and quality and quality > 1
  if not button.IconBorder and button.CreateTexture then
    button.IconBorder = button:CreateTexture(nil, "OVERLAY")
    button.IconBorder:SetAllPoints(button)
  end
  if not button.IconGlow and button.CreateTexture then
    local glow = button:CreateTexture(nil, "OVERLAY", nil, -1)
    glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    glow:SetBlendMode("ADD")
    glow:SetPoint("CENTER")
    glow:SetSize(67, 67)
    button.IconGlow = glow
  end
  if show then
    if button.IconBorder and button.IconBorder.SetVertexColor then
      button.IconBorder:SetVertexColor(color.r, color.g, color.b, 1)
    end
    if button.IconGlow then
      if button.IconGlow.SetVertexColor then
        button.IconGlow:SetVertexColor(color.r, color.g, color.b, 0.5)
      end
      if button.IconGlow.SetBlendMode then
        button.IconGlow:SetBlendMode("ADD")
      end
      if button.IconGlow.Show then
        button.IconGlow:Show()
      end
    end
    if button.IconBorder and button.IconBorder.Show then
      button.IconBorder:Show()
    end
  else
    if button.IconGlow and button.IconGlow.Hide then
      button.IconGlow:Hide()
    end
    if button.IconBorder and button.IconBorder.Hide then
      button.IconBorder:Hide()
    end
  end
end

local function itemIcon(button)
  if button.icon or button.Icon then
    return button.icon or button.Icon
  end
  if button.GetName then
    local named = _G[button:GetName() .. "IconTexture"]
    if named then
      return named
    end
  end
  if button.CreateTexture then
    button.icon = button:CreateTexture(nil, "ARTWORK")
    return button.icon
  end
end

local function hideRegion(region)
  if not region then
    return
  end
  if region.SetAlpha then
    region:SetAlpha(0)
  end
  if region.Hide then
    region:Hide()
  end
end

local function setIcon(button, info)
  local icon = itemIcon(button)
  button.icon = icon
  if not icon then
    return
  end
  local texture
  if info and info.iconFileID then
    texture = info.iconFileID
  elseif info and info.itemID and _G.GetItemIcon then
    texture = GetItemIcon(info.itemID)
  else
    texture = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"
  end
  if _G.SetItemButtonTexture then
    SetItemButtonTexture(button, texture)
  elseif icon.SetTexture then
    icon:SetTexture(texture)
    if icon.Show then
      icon:Show()
    end
  end
  if icon.ClearAllPoints then
    icon:ClearAllPoints()
  end
  if icon.SetAllPoints then
    icon:SetAllPoints(button)
  end
  if _G.SetItemButtonCount then
    SetItemButtonCount(button, info and info.stackCount or 0)
  end
end

local function clickButton(button, mouse)
  local bag, slot = button.bag, button.GetID and button:GetID()
  if not bag or not slot then
    return
  end
  if _G.HandleModifiedItemClick and button.info and button.info.hyperlink then
    if HandleModifiedItemClick(button.info.hyperlink) then
      return
    end
  end
  local api = container()
  if mouse == "RightButton" then
    local use = (api and api.UseContainerItem) or _G.UseContainerItem
    if use then
      use(bag, slot)
    end
    return
  end
  local pickup = (api and api.PickupContainerItem) or _G.PickupContainerItem
  if pickup then
    pickup(bag, slot)
  end
end

local function makeItemButton(group, index)
  local parent = group.GetParent and group:GetParent()
  local name = parent and ((parent.GetName and parent:GetName()) or parent.name)
  local ok, button = pcall(CreateFrame, "Button", name and (name .. "Item" .. index), group, "ContainerFrameItemButtonTemplate")
  if not ok or not button then
    button = CreateFrame("Button", name and (name .. "Item" .. index), group, "ItemButtonTemplate")
  end
  if not button then
    button = CreateFrame("Button", nil, group)
  end
  if button.ClearAllPoints then
    button:ClearAllPoints()
  end
  button:SetSize(SLOT, SLOT)
  hideRegion(button.BattlepayItemTexture)
  hideRegion(button.NewItemTexture)
  hideRegion(button.flash)
  hideRegion(button.BagStaticBottom)
  hideRegion(button.BagStaticTop)
  if button.GetNormalTexture then
    hideRegion(button:GetNormalTexture())
  end
  if button.RegisterForClicks then
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  end
  if button.SetScript then
    button:SetScript("OnClick", clickButton)
    button:SetScript("OnEnter", function(self)
      if _G.GameTooltip and GameTooltip.SetBagItem and self.bag then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetBagItem(self.bag, self:GetID())
      end
    end)
    button:SetScript("OnLeave", function()
      if _G.GameTooltip and GameTooltip.Hide then
        GameTooltip:Hide()
      end
    end)
  end
  return button
end

function Addon:HideBlizzardBags()
  for i = 1, 13 do
    local frame = _G["ContainerFrame" .. i]
    if frame and frame.Hide then
      frame:Hide()
    end
  end
  local combined = _G.ContainerFrameCombinedBags
  if combined and combined.Hide then
    combined:Hide()
  end
end

function Addon:HideBlizzardBank()
  local bank = _G.BankFrame
  if bank and bank.Hide then
    bank:Hide()
  end
end

function Addon:EnsureBagFrame(kind)
  self.bagFrames = self.bagFrames or {}
  local frame = self.bagFrames[kind]
  if frame then
    return frame
  end
  if not CreateFrame then
    return
  end
  local name = kind == "bank" and "ShadowUIBank" or "ShadowUIInventory"
  local ok, created = pcall(CreateFrame, "Frame", name, UIParent, "BackdropTemplate")
  frame = (ok and created) or CreateFrame("Frame", name, UIParent)
  frame.kind = kind
  frame.columns = COLUMNS[kind] or 10
  if frame.SetFrameStrata then
    frame:SetFrameStrata("HIGH")
  end
  if frame.SetToplevel then
    frame:SetToplevel(true)
  end
  if frame.SetMovable then
    frame:SetMovable(true)
  end
  if frame.EnableMouse then
    frame:EnableMouse(true)
  end
  if frame.SetClampedToScreen then
    frame:SetClampedToScreen(true)
  end
  if frame.RegisterForDrag then
    frame:RegisterForDrag("LeftButton")
  end
  if frame.SetScript then
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  end
  if frame.SetBackdrop then
    frame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
      insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(FILL[1], FILL[2], FILL[3], FILL[4])
    frame:SetBackdropBorderColor(0, 0, 0, 1)
  end
  self:ApplyOuterChrome(frame)

  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 12, -10)
  if title.SetText then
    title:SetText(TITLE[kind])
  end
  frame.title = title

  local close = CreateFrame("Button", name .. "Close", frame, "UIPanelCloseButton")
  if close.SetPoint then
    close:SetPoint("TOPRIGHT", -4, -4)
  end
  if close.SetScript then
    close:SetScript("OnClick", function()
      Addon:HideBagFrame(kind)
      if kind == "bank" and _G.CloseBankFrame then
        CloseBankFrame()
      end
    end)
  end
  frame.close = close

  local sort = CreateFrame("Button", name .. "Sort", frame, "UIPanelButtonTemplate")
  sort:SetSize(48, 20)
  sort:SetPoint("TOPRIGHT", close, "TOPLEFT", -4, -6)
  if sort.SetText then
    sort:SetText("Sort")
  end
  if sort.SetScript then
    sort:SetScript("OnClick", function()
      Addon:SortBagFrame(kind)
    end)
  end
  frame.sort = sort

  local search = CreateFrame("EditBox", name .. "Search", frame, "InputBoxTemplate")
  search:SetSize(140, 20)
  search:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  search:SetPoint("RIGHT", sort, "LEFT", -8, 0)
  if search.SetAutoFocus then
    search:SetAutoFocus(false)
  end
  if search.SetScript then
    search:SetScript("OnTextChanged", function(self)
      frame.searchText = self.GetText and self:GetText() or self.text
      Addon:RefreshBagFrame(kind)
    end)
    search:SetScript("OnEscapePressed", function(self)
      if self.ClearFocus then
        self:ClearFocus()
      end
    end)
    search:SetScript("OnEnterPressed", function(self)
      if self.ClearFocus then
        self:ClearFocus()
      end
    end)
  end
  frame.search = search

  local group = CreateFrame("Frame", name .. "Items", frame)
  group:SetPoint("TOPLEFT", 12, -48)
  group.columns = frame.columns
  group.slotSize = SLOT
  function group:LayoutTraits()
    return self.columns or 10, 1, SIZE, false
  end
  group.pool = {}
  group.buttons = {}
  frame.itemGroup = group

  if kind == "inventory" then
    frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -50, 100)
  else
    frame:SetPoint("LEFT", UIParent, "LEFT", 95, 0)
  end
  frame:Hide()

  if frame.RegisterEvent then
    frame:RegisterEvent("BAG_UPDATE")
    frame:RegisterEvent("BAG_UPDATE_DELAYED")
    frame:RegisterEvent("ITEM_LOCK_CHANGED")
    frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
    frame:RegisterEvent("PLAYER_MONEY")
    frame:SetScript("OnEvent", function(self)
      if self.IsShown and self:IsShown() then
        Addon:RefreshBagFrame(kind)
      end
    end)
  end

  self.bagFrames[kind] = frame
  return frame
end

function Addon:RefreshBagFrame(kind)
  local frame = self.bagFrames and self.bagFrames[kind] or self:EnsureBagFrame(kind)
  if not frame or not frame.itemGroup then
    return
  end
  local search = frame.searchText
  if (not search or search == "") and frame.search and frame.search.GetText then
    search = frame.search:GetText()
  end
  local slots = self:CollectBagSlots(kind, search)
  local group = frame.itemGroup
  group.columns = frame.columns
  local buttons = {}
  for i, slot in ipairs(slots) do
    local button = group.pool[i] or makeItemButton(group, i)
    group.pool[i] = button
    button.bag = slot.bag
    button.info = slot.info
    if button.SetID then
      button:SetID(slot.slot)
    end
    if button.SetSize then
      button:SetSize(SLOT, SLOT)
    end
    setIcon(button, slot.info)
    self:PaintBagQuality(button)
    if button.Show then
      button:Show()
    end
    buttons[i] = button
  end
  for i = #slots + 1, #(group.pool) do
    local extra = group.pool[i]
    if extra and extra.Hide then
      extra:Hide()
    end
  end
  group.buttons = buttons
  self:LayoutRainbowGroup(group)
  local width = math.max((group.width or group.GetWidth and group:GetWidth() or 1) + 24, 220)
  local height = (group.height or group.GetHeight and group:GetHeight() or 1) + 60
  frame:SetSize(width, height)
end

local function hideOtherBagAddons()
  local bagnon = _G.Bagnon
  if bagnon and bagnon.Frames and bagnon.Frames.Hide then
    pcall(bagnon.Frames.Hide, bagnon.Frames, "inventory")
    pcall(bagnon.Frames.Hide, bagnon.Frames, "bank")
  end
end

function Addon:ShowBagFrame(kind)
  local frame = self:EnsureBagFrame(kind)
  if not frame then
    return
  end
  self:RefreshBagFrame(kind)
  if frame.Show then
    frame:Show()
  end
  self:HideBlizzardBags()
  if kind == "bank" then
    self:HideBlizzardBank()
  end
  hideOtherBagAddons()
end

function Addon:HideBagFrame(kind)
  local frame = self.bagFrames and self.bagFrames[kind]
  if frame and frame.Hide then
    frame:Hide()
  end
end

function Addon:ToggleBagFrame(kind)
  local frame = self.bagFrames and self.bagFrames[kind]
  if frame and frame.IsShown and frame:IsShown() then
    self:HideBagFrame(kind)
    return
  end
  self:ShowBagFrame(kind)
end

function Addon:SortBagFrame(kind)
  local api = container()
  if kind == "bank" then
    local sort = (api and api.SortBankBags) or _G.SortBankBags
    if sort then
      sort()
    end
  else
    local sort = (api and api.SortBags) or _G.SortBags
    if sort then
      sort()
    end
  end
end

function Addon:HookBagToggles()
  if self._bagToggleHook then
    return
  end
  self._bagToggleHook = true
  local function wrap(name, fn)
    if _G[name] then
      _G[name] = fn
    end
  end
  wrap("ToggleBackpack", function()
    Addon:ToggleBagFrame("inventory")
  end)
  wrap("OpenBackpack", function()
    Addon:ShowBagFrame("inventory")
  end)
  wrap("CloseBackpack", function()
    Addon:HideBagFrame("inventory")
  end)
  wrap("ToggleBag", function()
    Addon:ToggleBagFrame("inventory")
  end)
  wrap("OpenBag", function()
    Addon:ShowBagFrame("inventory")
  end)
  wrap("CloseBag", function()
    Addon:HideBagFrame("inventory")
  end)
  wrap("OpenAllBags", function()
    Addon:ShowBagFrame("inventory")
  end)
  wrap("CloseAllBags", function()
    Addon:HideBagFrame("inventory")
    Addon:HideBagFrame("bank")
  end)
  wrap("ToggleAllBags", function()
    Addon:ToggleBagFrame("inventory")
  end)
  local bank = _G.BankFrame
  if bank and bank.HookScript then
    bank:HookScript("OnShow", function(self)
      if self.Hide then
        self:Hide()
      end
      Addon:ShowBagFrame("bank")
      Addon:ShowBagFrame("inventory")
    end)
  end
  if CreateFrame and not self._bagBankWatch then
    self._bagBankWatch = true
    local watch = CreateFrame("Frame", "ShadowUIBagWatch")
    if watch.RegisterEvent then
      watch:RegisterEvent("BANKFRAME_OPENED")
      watch:RegisterEvent("BANKFRAME_CLOSED")
    end
    if watch.SetScript then
      watch:SetScript("OnEvent", function(_, event)
        if event == "BANKFRAME_OPENED" then
          Addon:ShowBagFrame("bank")
          Addon:ShowBagFrame("inventory")
          Addon:HideBlizzardBank()
        else
          Addon:HideBagFrame("bank")
        end
      end)
    end
  end
end

function Addon:SkinBags()
  self:EnsureBagFrame("inventory")
  self:EnsureBagFrame("bank")
  self:HookBagToggles()
end

function Addon:SkinBagnon()
  self:SkinBags()
end
