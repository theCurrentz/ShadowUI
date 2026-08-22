--[[
  Purpose: Darken bag, vendor, character, and tracking chrome the Lorti way.
  Deps: ShadowUI:LockVertex(), ShadowUI:DarkenNamed(), ShadowUI:DarkenFrameRegions()
  Public: ShadowUI:SkinWindowFrames(), ShadowUI:OnDarkenAddonLoaded()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local GREY_NAMES = {
  "LootFrameBg",
  "LootFrameRightBorder",
  "LootFrameLeftBorder",
  "LootFrameTopBorder",
  "LootFrameBottomBorder",
  "LootFrameTopRightCorner",
  "LootFrameTopLeftCorner",
  "LootFrameBotRightCorner",
  "LootFrameBotLeftCorner",
  "LootFrameInsetInsetTopRightCorner",
  "LootFrameInsetInsetTopLeftCorner",
  "LootFrameInsetInsetBotRightCorner",
  "LootFrameInsetInsetBotLeftCorner",
  "LootFrameInsetInsetRightBorder",
  "LootFrameInsetInsetLeftBorder",
  "LootFrameInsetInsetTopBorder",
  "LootFrameInsetInsetBottomBorder",
  "LootFramePortraitFrame",
  "MerchantFrameTopBorder",
  "MerchantFrameBtnCornerRight",
  "MerchantFrameBtnCornerLeft",
  "MerchantFrameBottomRightBorder",
  "MerchantFrameBottomLeftBorder",
  "MerchantFrameButtonBottomBorder",
  "MerchantFrameBg",
  "ReputationDetailCorner",
  "ReputationDetailDivider",
}

local BLACK_NAMES = {
  "LootFrameInsetBg",
  "LootFrameTitleBg",
  "MerchantFrameTitleBg",
}

local REGION_FRAMES = {
  "BankFrame",
  "PaperDollFrame",
  "SpellBookFrame",
  "SkillFrame",
  "ReputationFrame",
  "PVPFrame",
  "PetPaperDollFrame",
  "MerchantFrame",
}

local BAR_NAMES = {
  "SlidingActionBarTexture0",
  "SlidingActionBarTexture1",
  "MainMenuBarTexture0",
  "MainMenuBarTexture1",
  "MainMenuBarTexture2",
  "MainMenuBarTexture3",
  "MainMenuMaxLevelBar0",
  "MainMenuMaxLevelBar1",
  "MainMenuMaxLevelBar2",
  "MainMenuMaxLevelBar3",
}

local GRYPHON_NAMES = {
  "MainMenuBarLeftEndCap",
  "MainMenuBarRightEndCap",
  "StanceBarLeft",
  "StanceBarMiddle",
  "StanceBarRight",
}

local function skinClock()
  local stopwatch = _G.StopwatchFrame
  if stopwatch and stopwatch.GetRegions then
    Addon:LockVertex(stopwatch:GetRegions(), Addon.DARKEN_GREY)
  end
  local tab = _G.StopwatchTabFrame
  if tab and tab.GetRegions then
    Addon:LockVertex(tab:GetRegions(), Addon.DARKEN_GREY)
  end
end

function Addon:OnDarkenAddonLoaded(_, name)
  if name == "Blizzard_TimeManager" then
    skinClock()
  end
end

function Addon:SkinWindowFrames()
  local grey = self.DARKEN_GREY
  local black = self.DARKEN_BLACK
  local bar = self.DARKEN_BAR
  self:DarkenNamed(GREY_NAMES, grey)
  self:DarkenNamed(BLACK_NAMES, black)
  self:DarkenNamed(BAR_NAMES, bar)
  self:DarkenNamed(GRYPHON_NAMES, grey)
  for i = 0, 4 do
    self:LockVertex(_G["MainMenuXPBarTexture" .. i], bar)
  end
  local status = _G.ReputationWatchBar and _G.ReputationWatchBar.StatusBar
  for i = 0, 3 do
    self:DarkenChild(status, "WatchBarTexture" .. i, bar)
    self:DarkenChild(status, "XPBarTexture" .. i, bar)
  end
  for i = 1, 11 do
    local prefix = "ContainerFrame" .. i
    self:DarkenNamed({
      prefix .. "BackgroundTop",
      prefix .. "BackgroundMiddle1",
      prefix .. "BackgroundBottom",
    }, grey)
  end
  for _, name in ipairs(REGION_FRAMES) do
    self:DarkenFrameRegions(_G[name], grey)
  end
  skinClock()
end
