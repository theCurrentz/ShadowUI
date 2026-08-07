--[[
  Purpose: Darken and dock Blizzard micro and bag buttons.
  Deps: Blizzard micro and container buttons
  Public: ShadowUI:SkinMicroAndBags()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local MICRO_BUTTONS = {
  "CharacterMicroButton",
  "SpellbookMicroButton",
  "TalentMicroButton",
  "AchievementMicroButton",
  "QuestLogMicroButton",
  "SocialsMicroButton",
  "GuildMicroButton",
  "LFDMicroButton",
  "WorldMapMicroButton",
  "CollectionsMicroButton",
  "EJMicroButton",
  "StoreMicroButton",
  "MainMenuMicroButton",
  "HelpMicroButton",
}
local BAG_BUTTONS = {
  "MainMenuBarBackpackButton",
  "CharacterBag0Slot",
  "CharacterBag1Slot",
  "CharacterBag2Slot",
  "CharacterBag3Slot",
  "KeyRingButton",
}

local function darken(button)
  for _, method in ipairs({
    "GetNormalTexture",
    "GetPushedTexture",
    "GetDisabledTexture",
  }) do
    local texture = button[method](button)
    if texture then
      texture:SetVertexColor(0.45, 0.45, 0.45)
    end
  end
end

local function collect(names)
  local buttons = {}
  for _, name in ipairs(names) do
    local button = _G[name]
    if button then
      button:SetParent(UIParent)
      darken(button)
      buttons[#buttons + 1] = button
    end
  end
  return buttons
end

function Addon:SkinMicroAndBags()
  local bags = collect(BAG_BUTTONS)
  for i, button in ipairs(bags) do
    button:ClearAllPoints()
    if i == 1 then
      button:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -8, 8)
    else
      button:SetPoint("RIGHT", bags[i - 1], "LEFT", -2, 0)
    end
  end

  local micro = collect(MICRO_BUTTONS)
  for i = #micro, 1, -1 do
    local button = micro[i]
    button:ClearAllPoints()
    if i == #micro then
      local anchor = bags[1] or UIParent
      local point = bags[1] and "TOPRIGHT" or "BOTTOMRIGHT"
      button:SetPoint("BOTTOMRIGHT", anchor, point, 0, bags[1] and 2 or 8)
    else
      button:SetPoint("RIGHT", micro[i + 1], "LEFT", -2, 0)
    end
  end
end
