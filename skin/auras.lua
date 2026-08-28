--[[
  Purpose: Darken buff and debuff icon chrome the Lorti way, including the outer edge.
  Unused slots stay empty. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place.
  Target auras sit 2px to the right of the Target Frame in horizontal rows at 32px.
  Classic copies TargetFrameMixin.UpdateAuras onto TargetFrame; the instance hook
  keeps that place. 1.15.9 Target Frame auras come from auraPools when present.
  Target of Target auras sit 2px to the right of Target of Target in a horizontal row.
  Deps: ShadowUI:LockVertex(), ShadowUI:ApplyOuterChrome()
  Public: ShadowUI:SkinAuraButton(), ShadowUI:PlaceTargetAuras(), ShadowUI:SkinAuras()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:SkinAuraDuration(button) end
local INSET = 2
local OUTER_PAD = 4
local GROUPS = {
  { "BuffButton", 32 },
  { "DebuffButton", 16 },
  { "TempEnchant", 3 },
  { "TargetFrameBuff", 32 },
  { "TargetFrameDebuff", 16 },
  { "TargetFrameToTBuff", 4 },
  { "TargetFrameToTDebuff", 4 },
  { "FocusFrameBuff", 32 },
  { "FocusFrameDebuff", 16 },
}
local AURA_GAP = 2
local AURA_SPACE = 3
local TARGET_AURA_SIZE = 32
local AURA_ROW_WIDTH = TARGET_AURA_SIZE * 4 + AURA_SPACE * 3

local function inset(region)
  if not region then
    return
  end
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", INSET, -INSET)
  region:SetPoint("BOTTOMRIGHT", -INSET, INSET)
end

local function auraIcon(button, name)
  return button.Icon or button.icon or (name and _G[name .. "Icon"])
end

local function auraBorder(button, name)
  return button.DebuffBorder or button.border or (name and _G[name .. "Border"])
end

local function isDebuff(button, name)
  if button.auraType == "Debuff" or button.auraType == "DeadlyDebuff" then
    return true
  end
  return name and name:find("Debuff")
end

local function hideAuraChrome(button)
  if button.shadowUIChrome and button.shadowUIChrome.Hide then
    button.shadowUIChrome:Hide()
  end
  if button.shadowUIOuter and button.shadowUIOuter.Hide then
    button.shadowUIOuter:Hide()
  end
end

local function auraIsActive(button, name)
  if button.isAuraAnchor then
    return false
  end
  if button.hasValidInfo == false then
    return false
  end
  if button.IsShown and not button:IsShown() then
    return false
  end
  local icon = auraIcon(button, name)
  if not icon then
    return false
  end
  local tex = icon.GetTexture and icon:GetTexture()
  if not tex or tex == "" or tex == 0 then
    return false
  end
  return true
end

function Addon:SkinAuraButton(button)
  if not button then
    return
  end
  local name = button.GetName and button:GetName()
  if not auraIsActive(button, name) then
    hideAuraChrome(button)
    return
  end
  local icon = auraIcon(button, name)
  local chrome = button.shadowUIChrome
  if not chrome and button.CreateTexture then
    chrome = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.shadowUIChrome = chrome
  end
  if chrome then
    chrome:ClearAllPoints()
    if icon then
      chrome:SetPoint("TOPLEFT", icon, "TOPLEFT", -INSET, INSET)
      chrome:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", INSET, -INSET)
    else
      chrome:SetAllPoints(button)
    end
    chrome:SetColorTexture(0.05, 0.05, 0.05, 1)
    chrome:Show()
  end
  self:ApplyOuterChrome(button)
  local outer = button.shadowUIOuter
  if outer then
    if outer.Show then
      outer:Show()
    end
    if icon and outer.ClearAllPoints then
      outer:ClearAllPoints()
      outer:SetPoint("TOPLEFT", icon, "TOPLEFT", -OUTER_PAD, OUTER_PAD)
      outer:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", OUTER_PAD, -OUTER_PAD)
    end
  end
  if icon then
    if not button.Icon then
      inset(icon)
    end
    if icon.SetTexCoord then
      icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    if icon.SetDrawLayer then
      icon:SetDrawLayer("ARTWORK", 0)
    end
  end
  local border = auraBorder(button, name)
  if border and not isDebuff(button, name) then
    self:LockVertex(border, self.DARKEN_BLACK)
  end
  self:SkinAuraDuration(button)
end

local function skinPool(frame)
  if not frame then
    return
  end
  if frame.AuraContainer and frame.AuraContainer.SetClipsChildren then
    frame.AuraContainer:SetClipsChildren(false)
  end
  if frame.SetClipsChildren then
    frame:SetClipsChildren(false)
  end
  for _, button in ipairs(frame.auraFrames or {}) do
    Addon:SkinAuraButton(button)
  end
end

local function collectShown(prefix, count)
  local list = {}
  for i = 1, count do
    local button = _G[prefix .. i]
    if button and button.SetPoint and auraIsActive(button, prefix .. i) then
      list[#list + 1] = button
    end
  end
  return list
end

local function collectPool(frame, template)
  local list = {}
  if not frame or not frame.auraPools or not frame.auraPools.GetPool then
    return list
  end
  local pool = frame.auraPools:GetPool(template)
  if not pool or not pool.EnumerateActive then
    return list
  end
  for button in pool:EnumerateActive() do
    local name = button.GetName and button:GetName()
    if button and button.SetPoint and auraIsActive(button, name) then
      if template:find("Debuff", 1, true) and not button.auraType then
        button.auraType = "Debuff"
      end
      list[#list + 1] = button
    end
  end
  table.sort(list, function(a, b)
    local ay = a.GetTop and a:GetTop()
    local by = b.GetTop and b:GetTop()
    if ay and by and ay ~= by then
      return ay > by
    end
    local ax = a.GetLeft and a:GetLeft()
    local bx = b.GetLeft and b:GetLeft()
    if ax and bx then
      return ax < bx
    end
    return (a.auraInstanceID or 0) < (b.auraInstanceID or 0)
  end)
  return list
end

local function collectFrameAuras(frame, prefix, count, template)
  local fromPool = collectPool(frame, template)
  if #fromPool > 0 then
    return fromPool
  end
  return collectShown(prefix, count)
end

local function skinTargetPools(frame)
  if not frame or not frame.auraPools or not frame.auraPools.GetPool then
    return
  end
  for _, template in ipairs({ "TargetBuffFrameTemplate", "TargetDebuffFrameTemplate" }) do
    for _, button in ipairs(collectPool(frame, template)) do
      Addon:SkinAuraButton(button)
    end
  end
end

local function sizeAura(button, size)
  if not button or not size then
    return
  end
  if button.SetSize then
    button:SetSize(size, size)
  else
    if button.SetWidth then
      button:SetWidth(size)
    end
    if button.SetHeight then
      button:SetHeight(size)
    end
  end
end

local function placeAuraRow(buttons, relative, relPoint, x, y, wrap, size)
  if not relative or #buttons == 0 then
    return
  end
  local rowStart, lastInRow, rowWidth
  for _, button in ipairs(buttons) do
    sizeAura(button, size)
    local w = (button.GetWidth and button:GetWidth()) or size or 21
    if button.ClearAllPoints then
      button:ClearAllPoints()
    end
    if not rowStart then
      button:SetPoint("TOPLEFT", relative, relPoint, x, y)
      rowStart = button
      lastInRow = button
      rowWidth = w
    elseif wrap and rowWidth + AURA_SPACE + w > AURA_ROW_WIDTH then
      button:SetPoint("TOPLEFT", rowStart, "BOTTOMLEFT", 0, -AURA_SPACE)
      rowStart = button
      lastInRow = button
      rowWidth = w
    else
      button:SetPoint("TOPLEFT", lastInRow, "TOPRIGHT", AURA_SPACE, 0)
      lastInRow = button
      rowWidth = rowWidth + AURA_SPACE + w
    end
  end
  return rowStart
end

local function placeAuraGroups(relative, first, second, wrap, size)
  local lowest = placeAuraRow(first, relative, "TOPRIGHT", AURA_GAP, 0, wrap, size)
  if #second == 0 then
    return
  end
  if lowest then
    placeAuraRow(second, lowest, "BOTTOMLEFT", 0, -AURA_SPACE, wrap, size)
  else
    placeAuraRow(second, relative, "TOPRIGHT", AURA_GAP, 0, wrap, size)
  end
end

function Addon:PlaceTargetAuras()
  if self._shadowUIAuraPlace then
    return
  end
  self._shadowUIAuraPlace = true
  local frame = _G.TargetFrame
  local tot = (frame and frame.totFrame) or _G.TargetFrameToT
  if frame and (not frame.IsShown or frame:IsShown()) then
    local buffs = collectFrameAuras(frame, "TargetFrameBuff", 32, "TargetBuffFrameTemplate")
    local debuffs = collectFrameAuras(frame, "TargetFrameDebuff", 16, "TargetDebuffFrameTemplate")
    local unit = frame.unit or "target"
    local friendly = UnitIsFriend and UnitIsFriend("player", unit)
    if friendly then
      placeAuraGroups(frame, buffs, debuffs, true, TARGET_AURA_SIZE)
    else
      placeAuraGroups(frame, debuffs, buffs, true, TARGET_AURA_SIZE)
    end
  end
  if tot and (not tot.IsShown or tot:IsShown()) then
    local totBuffs = collectShown("TargetFrameToTBuff", 4)
    local totDebuffs = collectShown("TargetFrameToTDebuff", 4)
    placeAuraGroups(tot, totDebuffs, totBuffs, false)
  end
  self._shadowUIAuraPlace = nil
end

function Addon:SkinAuras()
  for _, group in ipairs(GROUPS) do
    local prefix, count = group[1], group[2]
    for i = 1, count do
      self:SkinAuraButton(_G[prefix .. i])
    end
  end
  for p = 1, 4 do
    for i = 1, 4 do
      self:SkinAuraButton(_G["PartyMemberFrame" .. p .. "Debuff" .. i])
    end
  end
  skinPool(_G.BuffFrame)
  skinPool(_G.DebuffFrame)
  skinTargetPools(_G.TargetFrame)
  skinTargetPools(_G.FocusFrame)
  self:PlaceTargetAuras()
end

local function restyle()
  Addon:SkinAuras()
end

local function replaceTarget()
  Addon:PlaceTargetAuras()
end

local function watchFrameAuras(frame)
  if not frame or frame._shadowUIAuraHook or not hooksecurefunc then
    return
  end
  if not frame.UpdateAuras then
    return
  end
  frame._shadowUIAuraHook = true
  hooksecurefunc(frame, "UpdateAuras", restyle)
end

if hooksecurefunc then
  if BuffFrame_UpdateAllBuffAnchors then
    hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", restyle)
  end
  if DebuffButton_UpdateAnchors then
    hooksecurefunc("DebuffButton_UpdateAnchors", restyle)
  end
  if TargetFrame_UpdateAuras then
    hooksecurefunc("TargetFrame_UpdateAuras", restyle)
  end
  if TargetFrameMixin and TargetFrameMixin.UpdateAuras then
    hooksecurefunc(TargetFrameMixin, "UpdateAuras", restyle)
  end
  if TargetFrame_UpdateAuraPositions then
    hooksecurefunc("TargetFrame_UpdateAuraPositions", replaceTarget)
  end
  if TargetFrame_UpdateBuffAnchor then
    hooksecurefunc("TargetFrame_UpdateBuffAnchor", replaceTarget)
  end
  if TargetFrame_UpdateDebuffAnchor then
    hooksecurefunc("TargetFrame_UpdateDebuffAnchor", replaceTarget)
  end
  watchFrameAuras(_G.TargetFrame)
  watchFrameAuras(_G.FocusFrame)
  if RefreshDebuffs then
    hooksecurefunc("RefreshDebuffs", function(frame)
      local tot = (_G.TargetFrame and _G.TargetFrame.totFrame) or _G.TargetFrameToT
      if frame == tot or frame == _G.TargetFrameToT then
        Addon:PlaceTargetAuras()
      end
    end)
  end
  if AuraFrameMixin and AuraFrameMixin.UpdateAuraButtons then
    hooksecurefunc(AuraFrameMixin, "UpdateAuraButtons", restyle)
  end
  if AuraContainerMixin and AuraContainerMixin.UpdateGridLayout then
    hooksecurefunc(AuraContainerMixin, "UpdateGridLayout", restyle)
  end
end
