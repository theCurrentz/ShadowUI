--[[
  Purpose: Dock micro buttons plus a single bag button flush to the screen
  bottom-right. Buttons keep native Blizzard size and art in native-size
  hosts (no clip, no Outer Edge). Shop stays hidden. When MicroMenu exists,
  hosts stay on that menu so Blizzard Edit Mode Layout can read centres.
  /shadowui can switch this Micro Cluster off and restore the default
  Blizzard menu.
  Deps: Blizzard micro and container buttons
  Public: ShadowUI:SkinMicroAndBags()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local MICRO = 28
local NATIVE_H = 58
local MICRO_BUTTONS = {
  "CharacterMicroButton",
  "SpellbookMicroButton",
  "TalentMicroButton",
  "QuestLogMicroButton",
  "SocialsMicroButton",
  "GuildMicroButton",
  "LFDMicroButton",
  "WorldMapMicroButton",
  "CollectionsMicroButton",
  "EJMicroButton",
  "MainMenuMicroButton",
  "HelpMicroButton",
}
local EXTRA_BAGS = {
  "CharacterBag0Slot",
  "CharacterBag1Slot",
  "CharacterBag2Slot",
  "CharacterBag3Slot",
  "KeyRingButton",
}

local holder
local snapping

local function useShadowUIMenu()
  local get = Addon.GetCharDB
  if not get then
    return true
  end
  local char = get(Addon)
  return not char or char.useShadowUIMenu ~= false
end

local function ensureHolder()
  if holder then
    return holder
  end
  holder = CreateFrame("Frame", "ShadowUIMicroCluster", UIParent)
  holder:SetFrameStrata("HIGH")
  if holder.SetFrameLevel then
    holder:SetFrameLevel(200)
  end
  holder:SetSize(MICRO, NATIVE_H)
  holder:Show()
  return holder
end

local function isClusterHost(frame)
  if not frame then
    return false
  end
  if frame == holder or frame == _G.MicroMenu then
    return true
  end
  local parent = frame.GetParent and frame:GetParent()
  return parent == holder or parent == _G.MicroMenu
end

local function captureNative(button, defaultW, defaultH)
  if button._shadowUINativeH then
    return
  end
  local width = (button.GetWidth and button:GetWidth()) or defaultW
  local height = (button.GetHeight and button:GetHeight()) or defaultH
  button._shadowUINativeW = width
  button._shadowUINativeH = height
end

local function hideOuter(host)
  if host and host.shadowUIOuter and host.shadowUIOuter.Hide then
    host.shadowUIOuter:Hide()
  end
end

local function ensureHost(button, parent)
  local host = button._shadowUIHost
  if not host then
    host = CreateFrame("Frame", nil, parent)
    button._shadowUIHost = host
  elseif host.SetParent then
    host:SetParent(parent)
  end
  local width = button._shadowUINativeW or MICRO
  local height = button._shadowUINativeH or NATIVE_H
  if host.SetSize then
    host:SetSize(width, height)
  elseif host.SetWidth then
    host:SetWidth(width)
    host:SetHeight(height)
  end
  if host.Show then
    host:Show()
  end
  host.ignoreInLayout = true
  if button.layoutIndex then
    host.layoutIndex = button.layoutIndex
    button._shadowUILayoutIndex = button.layoutIndex
    button.layoutIndex = nil
  elseif button._shadowUILayoutIndex then
    host.layoutIndex = button._shadowUILayoutIndex
  end
  button.ignoreInLayout = true
  hideOuter(host)
  return host
end

local function dropHost(button)
  local host = button._shadowUIHost or button._shadowUIClip
  if not host then
    return
  end
  if host.Hide then
    host:Hide()
  end
  host.layoutIndex = nil
  hideOuter(host)
end

local function restoreLayoutIndex(button)
  if button._shadowUILayoutIndex then
    button.layoutIndex = button._shadowUILayoutIndex
    button._shadowUILayoutIndex = nil
  end
end

local function hideExtra(name)
  local button = _G[name]
  if not button then
    return
  end
  if button.layoutIndex then
    button._shadowUILayoutIndex = button.layoutIndex
    button.layoutIndex = nil
  end
  if holder and button.SetParent then
    button:SetParent(holder)
  end
  dropHost(button)
  hideOuter(button)
  button:Hide()
  if button.SetScript then
    button:SetScript("OnShow", button.Hide)
  end
end

local function watch(button)
  if button._shadowUIWatch or not hooksecurefunc then
    return
  end
  button._shadowUIWatch = true
  hooksecurefunc(button, "SetPoint", function(self)
    if snapping then
      return
    end
    -- Nested in a native-size host, or GridLayout SetPoint on MicroMenu children.
    local parent = self.GetParent and self:GetParent()
    if parent and (parent == self._shadowUIHost or parent == _G.MicroMenu) then
      return
    end
    Addon:SkinMicroAndBags()
  end)
  hooksecurefunc(button, "SetParent", function(self, parent)
    if snapping or isClusterHost(parent) then
      return
    end
    Addon:SkinMicroAndBags()
  end)
end

local function fit(button, parent, width, height)
  watch(button)
  button:SetParent(parent)
  if button.SetAlpha then
    button:SetAlpha(1)
  end
  if width and height then
    if button.SetSize then
      button:SetSize(width, height)
    elseif button.SetWidth then
      button:SetWidth(width)
      button:SetHeight(height)
    end
  end
end

local function nativeSize(button, defaultW, defaultH)
  captureNative(button, defaultW, defaultH)
  local width = button._shadowUINativeW or defaultW
  local height = button._shadowUINativeH or defaultH
  if not width or width <= 0 then
    width = defaultW
    button._shadowUINativeW = defaultW
  end
  if not height or height <= 0 then
    height = defaultH
    button._shadowUINativeH = defaultH
  end
  return width, height
end

local function watchMenuLayout(menu)
  if not menu or menu._shadowUILayout or not hooksecurefunc or not menu.Layout then
    return
  end
  menu._shadowUILayout = true
  hooksecurefunc(menu, "Layout", function()
    if snapping or Addon._skinMicroThen then
      return
    end
    if useShadowUIMenu() then
      Addon:SkinMicroAndBags()
    end
  end)
end

local function restoreBlizzardMenu()
  if holder then
    holder:Hide()
  end
  local art = _G.MainMenuBarArtFrame or UIParent
  if art.SetScript then
    art:SetScript("OnShow", nil)
  end
  if art.Show then
    art:Show()
  end
  if art ~= UIParent and art.SetParent then
    art:SetParent(UIParent)
    if art.ClearAllPoints then
      art:ClearAllPoints()
    end
    if art.SetPoint then
      art:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
    end
  end
  local menu = _G.MicroMenu
  local container = _G.MicroMenuContainer
  if container then
    container._shadowUIPark = nil
    if container.Show then
      container:Show()
    end
  end
  local menuParent = (menu and container) or art
  if UpdateMicroButtonsParent then
    UpdateMicroButtonsParent(menuParent)
  elseif menu then
    menu:SetParent(menuParent)
  end
  local bagHost = {
    MainMenuBarBackpackButton = true,
  }
  for _, name in ipairs(EXTRA_BAGS) do
    bagHost[name] = true
  end
  local names = {
    "MainMenuBarBackpackButton",
  }
  for _, name in ipairs(MICRO_BUTTONS) do
    names[#names + 1] = name
  end
  for _, name in ipairs(EXTRA_BAGS) do
    names[#names + 1] = name
  end
  names[#names + 1] = "AchievementMicroButton"
  names[#names + 1] = "StoreMicroButton"
  names[#names + 1] = "GuildMicroButton"
  for _, name in ipairs(names) do
    local button = _G[name]
    if button then
      watch(button)
      restoreLayoutIndex(button)
      dropHost(button)
      hideOuter(button)
      if button._shadowUINativeH and button.SetSize then
        button:SetSize(button._shadowUINativeW, button._shadowUINativeH)
      end
      if button.SetScript then
        button:SetScript("OnShow", nil)
      end
      local host = art
      if menu and not bagHost[name] then
        host = menu
      end
      button:SetParent(host)
      button:Show()
    end
  end
  if MoveMicroButtons then
    MoveMicroButtons()
  end
  if UpdateMicroButtons then
    UpdateMicroButtons()
  end
end

function Addon:SkinMicroAndBags()
  if self._skinMicroThen then
    return
  end
  self._skinMicroThen = true
  snapping = true

  if not useShadowUIMenu() then
    restoreBlizzardMenu()
    snapping = nil
    self._skinMicroThen = nil
    return
  end

  local cluster = ensureHolder()
  cluster:ClearAllPoints()
  cluster:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, -2)
  cluster:Show()
  if cluster.SetAlpha then
    cluster:SetAlpha(1)
  end

  for _, name in ipairs(EXTRA_BAGS) do
    hideExtra(name)
  end
  -- Classic Era uses SocialsMicroButton (Friends / Guild). GuildMicroButton
  -- exists on some clients but does not open a frame.
  local socials = _G.SocialsMicroButton
  if socials then
    hideExtra("GuildMicroButton")
  end
  hideExtra("AchievementMicroButton")
  hideExtra("StoreMicroButton")

  local menu = _G.MicroMenu
  local container = _G.MicroMenuContainer
  if UpdateMicroButtonsParent then
    UpdateMicroButtonsParent(cluster)
  end
  if menu then
    watchMenuLayout(menu)
    fit(menu, cluster)
    if menu.SetClipsChildren then
      menu:SetClipsChildren(false)
    end
    if menu.Show then
      menu:Show()
    end
  end
  if container then
    if self.ParkFrame then
      self:ParkFrame(container, "BOTTOMRIGHT", 0, 0)
    end
    if container.Hide then
      container:Hide()
    end
  end

  local bag = _G.MainMenuBarBackpackButton
  local bagW, bagH
  if bag then
    bagW, bagH = nativeSize(bag, MICRO, MICRO)
    fit(bag, cluster, bagW, bagH)
    hideOuter(bag)
    dropHost(bag)
    bag:Show()
    bag:ClearAllPoints()
    bag:SetPoint("BOTTOMRIGHT", cluster, "BOTTOMRIGHT", 0, 0)
  end

  if menu then
    menu:ClearAllPoints()
    if bag then
      menu:SetPoint("BOTTOMRIGHT", bag, "BOTTOMLEFT", 0, 0)
    else
      menu:SetPoint("BOTTOMRIGHT", cluster, "BOTTOMRIGHT", 0, 0)
    end
  end

  local row = {}
  local microParent = menu or cluster
  for _, name in ipairs(MICRO_BUTTONS) do
    if name ~= "GuildMicroButton" or not socials then
      local button = _G[name]
      if button then
        restoreLayoutIndex(button)
        dropHost(button)
        hideOuter(button)
        local width, height = nativeSize(button, MICRO, NATIVE_H)
        local host = ensureHost(button, microParent)
        fit(button, host, width, height)
        button:ClearAllPoints()
        button:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 0, 0)
        if button.SetScript then
          button:SetScript("OnShow", nil)
        end
        if host.Show then
          host:Show()
        end
        button:Show()
        row[#row + 1] = host
      end
    end
  end
  for i = #row, 1, -1 do
    local host = row[i]
    host:ClearAllPoints()
    if i == #row then
      if bag then
        host:SetPoint("BOTTOMRIGHT", bag, "BOTTOMLEFT", 0, 0)
      else
        host:SetPoint("BOTTOMRIGHT", cluster, "BOTTOMRIGHT", 0, 0)
      end
    else
      host:SetPoint("BOTTOMRIGHT", row[i + 1], "BOTTOMLEFT", 2, 0)
    end
  end
  local rowWidth = bagW or 0
  local rowHeight = bagH or NATIVE_H
  for _, host in ipairs(row) do
    local width = host.width or (host.GetWidth and host:GetWidth()) or MICRO
    local height = host.height or (host.GetHeight and host:GetHeight()) or NATIVE_H
    rowWidth = rowWidth + width
    if height > rowHeight then
      rowHeight = height
    end
  end
  if cluster.SetSize then
    cluster:SetSize(math.max(rowWidth, MICRO), math.max(rowHeight, NATIVE_H))
  end
  if menu and menu.SetSize then
    local menuWidth = rowWidth - (bagW or 0)
    menu:SetSize(math.max(menuWidth, MICRO), math.max(rowHeight, NATIVE_H))
  end

  snapping = nil
  self._skinMicroThen = nil
end

local function restyle()
  Addon:SkinMicroAndBags()
end

if hooksecurefunc then
  hooksecurefunc("UpdateMicroButtons", restyle)
  if MoveMicroButtons then
    hooksecurefunc("MoveMicroButtons", restyle)
  end
  if UpdateMicroButtonsParent then
    hooksecurefunc("UpdateMicroButtonsParent", restyle)
  end
  if ActionBarController_UpdateAll then
    hooksecurefunc("ActionBarController_UpdateAll", restyle)
  end
end
