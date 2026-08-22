--[[
  Purpose: Player melee and ranged swing timers in the combat meter group.
  Deps: combat log, UnitAttackSpeed, UnitRangedDamage, ShadowUI:ApplyStatusBarGradient(),
        ShadowUI:CombatMeterGroup(), ShadowUI:ApplyOuterChrome()
  Public: ShadowUI:ApplySwingTimer(), ShadowUI:SwingPulse(),
          ShadowUI:SwingHandleLog(), ShadowUI:SwingReset(),
          ShadowUI:SwingOnSwing(), ShadowUI:SwingOnShot(),
          ShadowUI:SwingSetSpeeds(), ShadowUI:SwingNoteExtraAttack(),
          ShadowUI:SwingApplyParryHaste(), ShadowUI:SwingHandsForClass(),
          ShadowUI:PreviewSwingTimer()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local WIDTH, MAIN_H, OFF_H, RANGE_H, GAP = 288, 8, 6, 6, 0
local SLAM = { [1464] = true, [8820] = true, [11604] = true, [11605] = true }
local RANGED = { [75] = true, [5019] = true, [2480] = true, [7918] = true, [7919] = true, [2764] = true }
local MAIN_HAND = {
  WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true, SHAMAN = true, DRUID = true,
}
local OFF_HAND = {
  WARRIOR = true, HUNTER = true, ROGUE = true, SHAMAN = true,
}
local RANGE_HAND = {
  HUNTER = true, PRIEST = true, MAGE = true, WARLOCK = true,
}

local function playerClass()
  if Addon.GetPlayerClass then
    return Addon:GetPlayerClass()
  end
  if UnitClass then
    local _, classFile = UnitClass("player")
    return classFile
  end
end

function Addon:SwingHandsForClass(classFile)
  classFile = classFile or playerClass()
  return {
    main = MAIN_HAND[classFile] == true,
    off = OFF_HAND[classFile] == true,
    range = RANGE_HAND[classFile] == true,
  }
end

local function paint(bar, from, to)
  bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
  Addon:ApplyStatusBarGradient(bar:GetStatusBarTexture(), "HORIZONTAL", from, to)
  local bg = bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0.015, 0.02, 0.025, 0.32)
  bar.background = bg
end

local function makeBar(name, parent, height, from, to)
  local bar = CreateFrame("StatusBar", name, parent)
  bar:SetHeight(height)
  bar:SetWidth(parent:GetWidth() or WIDTH)
  paint(bar, from, to)
  if Addon.ApplyOuterChrome then
    Addon:ApplyOuterChrome(bar)
  end
  bar:Hide()
  return bar
end

local function stackHands(frame)
  frame.off:ClearAllPoints()
  frame.off:SetPoint("TOPLEFT", frame.main, "BOTTOMLEFT", 0, -GAP)
  frame.range:ClearAllPoints()
  local above = (frame.offSpeed or 0) > 0 and frame.off or frame.main
  frame.range:SetPoint("TOPLEFT", above, "BOTTOMLEFT", 0, -GAP)
end

local function createTimer(group)
  local frame = CreateFrame("Frame", "ShadowUISwingTimer", group)
  frame:SetSize(group:GetWidth() or WIDTH, MAIN_H + GAP + OFF_H + GAP + RANGE_H)
  local host = Addon.gcdBar or group
  frame:SetPoint("TOPLEFT", host, "BOTTOMLEFT", 0, 0)
  frame:SetPoint("TOPRIGHT", host, "BOTTOMRIGHT", 0, 0)
  frame:SetFrameStrata("MEDIUM")
  frame.main = makeBar("ShadowUISwingMain", frame, MAIN_H, { 0.25, 0.38, 0.46, 0.42 }, { 0.62, 0.86, 0.96, 0.62 })
  frame.main:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  frame.off = makeBar("ShadowUISwingOff", frame, OFF_H, { 0.46, 0.32, 0.22, 0.42 }, { 0.96, 0.72, 0.42, 0.62 })
  frame.range = makeBar("ShadowUISwingRange", frame, RANGE_H, { 0.22, 0.42, 0.22, 0.42 }, { 0.45, 0.86, 0.42, 0.62 })
  stackHands(frame)
  frame.lastPulse = GetTime()
  return frame
end

local function paintHand(bar, remaining, speed)
  if not speed or speed <= 0 or not remaining or remaining <= 0 then
    bar:Hide()
    return
  end
  bar:SetMinMaxValues(0, speed)
  bar:SetValue(math.max(0, remaining))
  bar:Show()
end

function Addon:SwingSetSpeeds(frame, mainSpeed, offSpeed, rangeSpeed)
  local hands = self:SwingHandsForClass()
  frame.mainSpeed = (hands.main and mainSpeed) or 0
  frame.offSpeed = (hands.off and offSpeed) or 0
  frame.rangeSpeed = (hands.range and rangeSpeed) or 0
  if frame.mainSpeed <= 0 then
    frame.mainRemaining = 0
    frame.main:Hide()
  end
  if frame.offSpeed <= 0 then
    frame.offRemaining = 0
    frame.off:Hide()
  end
  if frame.rangeSpeed <= 0 then
    frame.rangeRemaining = 0
    frame.range:Hide()
  end
  stackHands(frame)
end

function Addon:SwingReset(frame, hand)
  if hand == "off" then
    if (frame.offSpeed or 0) <= 0 then
      return
    end
    frame.offRemaining = frame.offSpeed
  elseif hand == "range" then
    if (frame.rangeSpeed or 0) <= 0 then
      return
    end
    frame.rangeRemaining = frame.rangeSpeed
  else
    if (frame.mainSpeed or 0) <= 0 then
      return
    end
    frame.mainRemaining = frame.mainSpeed
  end
end

function Addon:SwingNoteExtraAttack(frame)
  frame.skipNextMain = true
end

function Addon:SwingOnSwing(frame, isOffHand)
  if isOffHand then
    self:SwingReset(frame, "off")
    return
  end
  if frame.skipNextMain then
    frame.skipNextMain = false
    return
  end
  self:SwingReset(frame, "main")
end

function Addon:SwingOnShot(frame, spellId)
  if RANGED[spellId] then
    self:SwingReset(frame, "range")
  end
end

function Addon:SwingApplyParryHaste(frame)
  local speed = frame.mainSpeed
  if speed <= 0 then
    return
  end
  local floor = speed * 0.2
  if frame.mainRemaining <= floor then
    return
  end
  frame.mainRemaining = math.max(floor, frame.mainRemaining - speed * 0.4)
end

function Addon:SwingHandleLog(frame, subevent, sourceGUID, destGUID, extra, isOffHand)
  local player = UnitGUID("player")
  if sourceGUID ~= player and not (subevent == "SWING_MISSED" and destGUID == player) then
    return
  end
  if subevent == "SPELL_EXTRA_ATTACKS" then
    self:SwingNoteExtraAttack(frame)
    return
  end
  if subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED" then
    if sourceGUID == player then
      self:SwingOnSwing(frame, isOffHand)
    elseif extra == "PARRY" then
      self:SwingApplyParryHaste(frame)
    end
    return
  end
  if SLAM[extra] then
    self:SwingReset(frame, "main")
    return
  end
  self:SwingOnShot(frame, extra)
end

function Addon:SwingPulse(frame)
  if frame.preview then
    return
  end
  local now = GetTime()
  local elapsed = now - (frame.lastPulse or now)
  frame.lastPulse = now
  frame.mainRemaining = math.max(0, (frame.mainRemaining or 0) - elapsed)
  frame.offRemaining = math.max(0, (frame.offRemaining or 0) - elapsed)
  frame.rangeRemaining = math.max(0, (frame.rangeRemaining or 0) - elapsed)
  paintHand(frame.main, frame.mainRemaining, frame.mainSpeed)
  paintHand(frame.off, frame.offRemaining, frame.offSpeed)
  paintHand(frame.range, frame.rangeRemaining, frame.rangeSpeed)
end

local function readSpeeds()
  local main, off = UnitAttackSpeed("player")
  local range = UnitRangedDamage and UnitRangedDamage("player")
  return main, off, range
end

local function onEvent(frame, event, _, a, b)
  if event == "UNIT_ATTACK_SPEED" or event == "UNIT_RANGEDDAMAGE" then
    Addon:SwingSetSpeeds(frame, readSpeeds())
    return
  end
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    local spellId = type(a) == "number" and a or b
    Addon:SwingOnShot(frame, spellId)
    return
  end
  if event ~= "COMBAT_LOG_EVENT_UNFILTERED" or not CombatLogGetCurrentEventInfo then
    return
  end
  local info = { CombatLogGetCurrentEventInfo() }
  local subevent, sourceGUID, destGUID = info[2], info[4], info[8]
  local extra, isOffHand
  if subevent == "SWING_DAMAGE" then
    isOffHand = info[21]
  elseif subevent == "SWING_MISSED" then
    extra, isOffHand = info[12], info[13]
  else
    extra = info[12]
  end
  Addon:SwingHandleLog(frame, subevent, sourceGUID, destGUID, extra, isOffHand)
end

function Addon:ApplySwingTimer()
  if self.swingTimer then
    return
  end
  local group = self.CombatMeterGroup and self:CombatMeterGroup() or UIParent
  local frame = createTimer(group)
  self.swingTimer = frame
  local main, off = UnitAttackSpeed("player")
  local range = UnitRangedDamage and UnitRangedDamage("player")
  self:SwingSetSpeeds(frame, main, off, range)
  frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  frame:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player")
  frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  pcall(frame.RegisterEvent, frame, "UNIT_RANGEDDAMAGE")
  frame:SetScript("OnEvent", onEvent)
  frame:SetScript("OnUpdate", function(selfFrame) Addon:SwingPulse(selfFrame) end)
  if self.SyncCombatMeterSize then
    self:SyncCombatMeterSize()
  end
end

function Addon:PreviewSwingTimer(preview)
  local frame = self.swingTimer
  if not frame then
    return
  end
  frame.preview = preview and true or nil
  if not preview then
    stackHands(frame)
    self:SwingPulse(frame)
    return
  end
  local width = frame:GetWidth() or WIDTH
  frame.off:ClearAllPoints()
  frame.off:SetPoint("TOPLEFT", frame.main, "BOTTOMLEFT", 0, 0)
  frame.range:ClearAllPoints()
  frame.range:SetPoint("TOPLEFT", frame.off, "BOTTOMLEFT", 0, 0)
  for _, hand in ipairs({ "main", "off", "range" }) do
    local bar = frame[hand]
    if bar.SetWidth then
      bar:SetWidth(width)
    end
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0.65)
    bar:Show()
  end
end
