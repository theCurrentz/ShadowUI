--[[
  Purpose: Apply Lorti icon chrome and Outer Edge to ItemRack worn-item and menu
           buttons. The minimap ItemRack icon stays on the square map.
  Deps: ShadowUI:ApplyOuterChrome(); optional ItemRack
  Public: ShadowUI:SkinItemRackButton(), ShadowUI:SkinItemRack()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local CROP = 0.07
local INSET = 2
local WORN_LAST = 20

local function strip(texture)
  if not texture then
    return
  end
  pcall(texture.SetTexture, texture, "")
  if texture.SetAlpha then
    texture:SetAlpha(0)
  end
  if texture.Hide then
    texture:Hide()
  end
end

local function inset(region)
  if not region then
    return
  end
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", INSET, -INSET)
  region:SetPoint("BOTTOMRIGHT", -INSET, INSET)
end

local function skinCooldown(button)
  local cooldown = button.cooldown
  if not cooldown or button.shadowUICooldownSkinned then
    return
  end
  button.shadowUICooldownSkinned = true
  inset(cooldown)
  if cooldown.SetDrawSwipe then
    cooldown:SetDrawSwipe(true)
  end
  if cooldown.SetSwipeColor then
    cooldown:SetSwipeColor(0, 0, 0, 0.8)
  end
  if cooldown.SetDrawEdge then
    cooldown:SetDrawEdge(true)
  end
  if cooldown.SetDrawBling then
    cooldown:SetDrawBling(true)
  end
  if button.GetFrameLevel and cooldown.SetFrameLevel then
    cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
  end
end

local function itemIcon(button, name)
  return button.icon or button.Icon or (name and _G[name .. "Icon"])
end

function Addon:SkinItemRackButton(button)
  if not button then
    return
  end
  local name = button.GetName and button:GetName()
  local chrome = button.shadowUIChrome
  if not chrome and button.CreateTexture then
    chrome = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.shadowUIChrome = chrome
  end
  if chrome then
    chrome:ClearAllPoints()
    chrome:SetAllPoints(button)
    chrome:SetColorTexture(0.05, 0.05, 0.05, 1)
    chrome:Show()
  end
  self:ApplyOuterChrome(button)
  strip(button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture()))
  strip(button.Border)
  strip(button.SlotBackground)
  strip(button.Flash)
  strip(button.FloatingBG)
  strip(button.IconBorder)
  local icon = itemIcon(button, name)
  if icon then
    if button.IconMask then
      if icon.RemoveMaskTexture then
        icon:RemoveMaskTexture(button.IconMask)
      end
      button.IconMask:Hide()
    end
    inset(icon)
    if icon.SetTexCoord then
      icon:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
    end
    if icon.SetDrawLayer then
      icon:SetDrawLayer("ARTWORK", 0)
    end
  end
  skinCooldown(button)
end

local function watchLateButtons()
  local rack = _G.ItemRack
  if hooksecurefunc and rack and not Addon._itemRackHook then
    Addon._itemRackHook = true
    if rack.CreateMenuButton then
      hooksecurefunc(rack, "CreateMenuButton", function()
        Addon:SkinItemRack()
      end)
    end
    if rack.InitButtons then
      hooksecurefunc(rack, "InitButtons", function()
        Addon:SkinItemRack()
      end)
    end
    if rack.UpdateButtons then
      hooksecurefunc(rack, "UpdateButtons", function()
        Addon:SkinItemRack()
      end)
    end
  end
  if C_Timer and C_Timer.After and not Addon._itemRackRetry then
    Addon._itemRackRetry = true
    C_Timer.After(1, function()
      Addon:SkinItemRack()
    end)
  end
  if Addon._itemRackWatch or not CreateFrame then
    return
  end
  Addon._itemRackWatch = true
  local watch = CreateFrame("Frame", "ShadowUIItemRackWatch")
  if watch.RegisterEvent then
    watch:RegisterEvent("ADDON_LOADED")
  end
  if watch.SetScript then
    watch:SetScript("OnEvent", function(_, _, name)
      if name == "ItemRack" then
        Addon:SkinItemRack()
      end
    end)
  end
end

function Addon:SkinItemRack()
  for i = 0, WORN_LAST do
    self:SkinItemRackButton(_G["ItemRackButton" .. i])
  end
  local i = 1
  while _G["ItemRackMenu" .. i] do
    self:SkinItemRackButton(_G["ItemRackMenu" .. i])
    i = i + 1
  end
  watchLateButtons()
end
