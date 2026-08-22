--[[
  Purpose: Render a Quartz-like player Cast Bar with Lorti chrome.
  Deps: WoW unit spellcast APIs, ShadowUI:CreateGCDBar()
  Public: ShadowUI:ApplyCastBar(), ShadowUI:ApplyStatusBarGradient(),
          ShadowUI:CastMeterState(), ShadowUI:CombatMeterGroup(),
          ShadowUI:SyncCombatMeterSize(), ShadowUI:ApplyCombatMeterPreview(),
          ShadowUI:PreviewCastBar(), ShadowUI:CastChannelTickFractions()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local BACKDROP = {
  bgFile = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
}
local WIDTH, HEIGHT, ICON = 288, 20, 20
-- Whitemane Currentz Quartz Player lock (CENTER -6.02, -131.98).
local X, Y = -6, -132
local FAIL_SECONDS = 0.45
local ICON_ALPHA = 0.55
-- Interior notches: tick count minus the channel end. Classic Era / SoD ranks.
local CHANNEL_TICKS = {
  [10] = 8, [6141] = 8, [8427] = 8, [10185] = 8, [10186] = 8, [10187] = 8,
  [5143] = 3, [5144] = 4, [5145] = 5, [8416] = 5, [8417] = 5, [10211] = 5,
  [10212] = 5, [25345] = 5,
  [15407] = 3, [17311] = 3, [17312] = 3, [17313] = 3, [17314] = 3, [18807] = 3,
  [689] = 5, [699] = 5, [709] = 5, [7651] = 5, [11699] = 5, [11700] = 5,
  [1120] = 5, [8288] = 5, [8289] = 5, [11675] = 5,
  [5138] = 5, [6226] = 5, [11703] = 5, [11704] = 5,
  [5740] = 4, [6219] = 4, [11677] = 4, [11678] = 4,
  [1949] = 15, [11683] = 15, [11684] = 15,
  [755] = 10, [3698] = 10, [3699] = 10, [3700] = 10, [11693] = 10, [11694] = 10,
  [11695] = 10,
  [16914] = 10, [17401] = 10, [17402] = 10,
  [740] = 4, [8918] = 4, [9862] = 4, [9863] = 4,
  [1510] = 6, [14294] = 6, [14295] = 6,
  [12051] = 4,
}
local PALETTE = {
  cast = { { 0.45, 0.22, 0.04, 1 }, { 1.0, 0.74, 0.18, 1 } },
  channel = { { 0.06, 0.28, 0.10, 1 }, { 0.28, 0.82, 0.36, 1 } },
  fail = { { 0.28, 0.04, 0.04, 1 }, { 0.85, 0.12, 0.12, 1 } },
}

-- SetGradientAlpha was removed from the client; SetGradient takes ColorMixins.
function Addon:ApplyStatusBarGradient(texture, orientation, from, to)
  if not texture then
    return
  end
  if CreateColor and texture.SetGradient then
    local ok = pcall(
      texture.SetGradient,
      texture,
      orientation,
      CreateColor(from[1], from[2], from[3], from[4]),
      CreateColor(to[1], to[2], to[3], to[4])
    )
    if ok then
      return
    end
  end
  texture:SetVertexColor(to[1], to[2], to[3], to[4])
end

function Addon:CastChannelTickFractions(spellId)
  local ticks = CHANNEL_TICKS[spellId]
  if not ticks or ticks < 2 then
    return {}
  end
  local fractions = {}
  for i = 1, ticks - 1 do
    fractions[i] = i / ticks
  end
  return fractions
end

function Addon:CastMeterState(now, startTime, endTime, channel, lagMs)
  if not now or not startTime or not endTime or endTime <= startTime then
    return nil
  end
  local remaining = endTime - now
  if remaining <= 0 then
    return nil
  end
  local duration = endTime - startTime
  local value = channel and remaining or (now - startTime)
  if value < 0 then
    value = 0
  end
  local lag = (lagMs or 0) / 1000
  if lag < 0 then
    lag = 0
  elseif lag > duration then
    lag = duration
  end
  return {
    duration = duration,
    remaining = remaining,
    value = value,
    fillFraction = value / duration,
    lagFraction = lag / duration,
    lagOnRight = not channel,
  }
end

local function hideBlizzardCastBar(frame)
  if not frame then
    return
  end
  if frame.UnregisterAllEvents then
    frame:UnregisterAllEvents()
  end
  frame:Hide()
  frame:SetScript("OnShow", frame.Hide)
  frame.Show = frame.Hide
end

local function paintFill(bar, kind)
  local pair = PALETTE[kind] or PALETTE.cast
  Addon:ApplyStatusBarGradient(bar:GetStatusBarTexture(), "HORIZONTAL", pair[1], pair[2])
end

local function placeSpark(bar, fraction)
  local spark = bar.spark
  if not spark then
    return
  end
  spark:ClearAllPoints()
  spark:SetPoint("CENTER", bar, "LEFT", (bar:GetWidth() or 0) * fraction, 0)
  spark:Show()
end

local function hideTicks(bar)
  if not bar.ticks then
    return
  end
  for _, tick in ipairs(bar.ticks) do
    tick:Hide()
  end
end

local function placeTicks(bar, spellId)
  hideTicks(bar)
  if not spellId then
    return
  end
  local fractions = Addon:CastChannelTickFractions(spellId)
  local width = bar:GetWidth() or 0
  local height = bar:GetHeight() or HEIGHT
  bar.ticks = bar.ticks or {}
  for i, fraction in ipairs(fractions) do
    local tick = bar.ticks[i]
    if not tick then
      tick = bar:CreateTexture(nil, "OVERLAY")
      tick:SetTexture("Interface\\Buttons\\WHITE8X8")
      tick:SetVertexColor(0, 0, 0, 0.7)
      bar.ticks[i] = tick
    end
    tick:ClearAllPoints()
    tick:SetWidth(1)
    tick:SetHeight(height)
    tick:SetPoint("CENTER", bar, "LEFT", width * fraction, 0)
    tick:Show()
  end
end

local function placeLag(bar, state)
  local lag = bar.lag
  if not lag or not state then
    return
  end
  local width = (bar:GetWidth() or 0) * state.lagFraction
  if width < 2 then
    lag:Hide()
    return
  end
  lag:ClearAllPoints()
  lag:SetWidth(width)
  lag:SetHeight(bar:GetHeight() or HEIGHT)
  if state.lagOnRight then
    lag:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
  else
    lag:SetPoint("LEFT", bar, "LEFT", 0, 0)
  end
  lag:Show()
end

local function homeLagMs()
  if not GetNetStats then
    return 0
  end
  local _, _, home = GetNetStats()
  return home or 0
end

local function refreshCast(bar, channel)
  local name, text, texture, startMS, endMS, spellId
  if channel then
    name, text, texture, startMS, endMS, _, _, spellId = UnitChannelInfo("player")
  else
    name, text, texture, startMS, endMS = UnitCastingInfo("player")
  end
  if not name or not startMS or not endMS then
    bar:Hide()
    return
  end

  bar.failUntil = nil
  bar.preview = nil
  bar.startTime = startMS / 1000
  bar.endTime = endMS / 1000
  bar.channel = channel
  bar.lagMs = homeLagMs()
  local state = Addon:CastMeterState(GetTime(), bar.startTime, bar.endTime, channel, bar.lagMs)
  if not state then
    bar:Hide()
    return
  end
  paintFill(bar, channel and "channel" or "cast")
  bar:SetMinMaxValues(0, state.duration)
  bar:SetValue(state.value)
  bar.name:SetText(text or name)
  bar.icon:SetTexture(texture)
  if bar.icon.SetAlpha then
    bar.icon:SetAlpha(ICON_ALPHA)
  end
  placeLag(bar, state)
  placeSpark(bar, state.fillFraction)
  if channel then
    placeTicks(bar, spellId)
  else
    hideTicks(bar)
  end
  bar:Show()
end

local function failCast(bar)
  bar.failUntil = GetTime() + FAIL_SECONDS
  bar.channel = false
  paintFill(bar, "fail")
  bar.name:SetText(INTERRUPTED or "Interrupted")
  if bar.lag then
    bar.lag:Hide()
  end
  hideTicks(bar)
  bar:Show()
end

local function updateCast(bar)
  if Addon.editMode and bar.preview then
    return
  end
  local now = GetTime()
  if bar.failUntil then
    if now >= bar.failUntil then
      bar.failUntil = nil
      bar:Hide()
    end
    return
  end
  local state = Addon:CastMeterState(now, bar.startTime, bar.endTime, bar.channel, bar.lagMs)
  if not state then
    bar:Hide()
    return
  end
  bar:SetValue(state.value)
  bar.time:SetFormattedText("%.1f / %.1f", state.remaining, state.duration)
  placeSpark(bar, state.fillFraction)
end

local function layoutHost(self, id, shipped)
  local layout
  if self.ResolveEffective then
    local resolved = self:ResolveEffective()
    layout = resolved and resolved.layout and resolved.layout[id]
  end
  layout = layout or {}
  return {
    point = layout.point or shipped.point,
    x = layout.x ~= nil and layout.x or shipped.x,
    y = layout.y ~= nil and layout.y or shipped.y,
    width = layout.width ~= nil and layout.width or shipped.width,
    height = layout.height ~= nil and layout.height or shipped.height,
    relativeTo = layout.relativeTo,
    relativePoint = layout.relativePoint or layout.point or shipped.point,
  }
end

function Addon:SyncCombatMeterSize(width, height)
  local group = self.castGroup
  width = width or (group and group.GetWidth and group:GetWidth()) or WIDTH
  height = height or (group and group.GetHeight and group:GetHeight()) or HEIGHT
  local bar = self.castBar
  if bar then
    if bar.SetSize then
      bar:SetSize(width, height)
    end
    if bar.iconFrame and bar.iconFrame.SetSize then
      bar.iconFrame:SetSize(height, height)
    end
    if bar.name and bar.name.ClearAllPoints then
      bar.name:ClearAllPoints()
      bar.name:SetPoint("LEFT", bar, "LEFT", height + 6, 0)
      bar.name:SetPoint("RIGHT", bar, "RIGHT", -72, 0)
    end
    if bar.spark and bar.spark.SetHeight then
      bar.spark:SetHeight(height * 2.4)
    end
  end
  local meterWidth = width
  local swing = self.swingTimer
  if swing then
    if swing.SetWidth then
      swing:SetWidth(meterWidth)
    end
    if swing.main and swing.main.SetWidth then
      swing.main:SetWidth(meterWidth)
    end
    if swing.off and swing.off.SetWidth then
      swing.off:SetWidth(meterWidth)
    end
    if swing.range and swing.range.SetWidth then
      swing.range:SetWidth(meterWidth)
    end
  end
end

function Addon:CombatMeterGroup()
  if self.castGroup then
    return self.castGroup
  end
  local group = CreateFrame("Frame", "ShadowUICastGroup", UIParent)
  group:SetSize(WIDTH, HEIGHT)
  group:SetPoint("CENTER", UIParent, "CENTER", X, Y)
  group:SetFrameStrata("MEDIUM")
  group:SetScript("OnSizeChanged", function(self, width, height)
    Addon:SyncCombatMeterSize(width, height)
  end)
  self.castGroup = group
  return group
end

function Addon:ParkCombatMeterGroup()
  local group = self:CombatMeterGroup()
  local park = layoutHost(self, "cast", {
    point = "CENTER",
    x = X,
    y = Y,
    width = WIDTH,
    height = HEIGHT,
  })
  if group.ClearAllPoints then
    group:ClearAllPoints()
  end
  group:SetPoint(park.point, park.relativeTo or UIParent, park.relativePoint, park.x, park.y)
  if group.SetSize then
    group:SetSize(park.width, park.height)
  end
  self:SyncCombatMeterSize(park.width, park.height)
  return group
end

local function createCastBar()
  local group = Addon:CombatMeterGroup()
  local bar = CreateFrame("StatusBar", "ShadowUICastBar", group, "BackdropTemplate")
  bar:SetSize(WIDTH, HEIGHT)
  bar:SetAllPoints(group)
  bar:SetFrameStrata("MEDIUM")
  bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
  paintFill(bar, "cast")
  bar:SetBackdrop(BACKDROP)
  bar:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
  bar:SetBackdropBorderColor(0, 0, 0, 1)
  Addon:ApplyOuterChrome(bar)

  local iconFrame = CreateFrame("Frame", nil, bar)
  iconFrame:SetSize(ICON, ICON)
  iconFrame:SetPoint("LEFT", bar, "LEFT", 0, 0)
  iconFrame:SetPoint("TOP", bar, "TOP", 0, 0)
  iconFrame:SetPoint("BOTTOM", bar, "BOTTOM", 0, 0)
  bar.iconFrame = iconFrame
  bar.icon = iconFrame:CreateTexture(nil, "ARTWORK")
  bar.icon:SetPoint("TOPLEFT", 0, 0)
  bar.icon:SetPoint("BOTTOMRIGHT", 0, 0)
  if bar.icon.SetTexCoord then
    bar.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
  end
  if bar.icon.SetAlpha then
    bar.icon:SetAlpha(ICON_ALPHA)
  end

  bar.lag = bar:CreateTexture(nil, "BORDER")
  bar.lag:SetTexture("Interface\\Buttons\\WHITE8X8")
  bar.lag:SetVertexColor(0.85, 0.12, 0.12, 0.55)
  bar.lag:Hide()

  bar.spark = bar:CreateTexture(nil, "OVERLAY")
  bar.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  bar.spark:SetWidth(18)
  bar.spark:SetHeight(HEIGHT * 2.4)
  bar.spark:SetVertexColor(1, 1, 1)
  bar.spark:SetBlendMode("ADD")

  bar.name = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  bar.name:SetPoint("LEFT", bar, "LEFT", ICON + 6, 0)
  bar.name:SetPoint("RIGHT", bar, "RIGHT", -72, 0)
  bar.name:SetJustifyH("LEFT")
  pcall(bar.name.SetFont, bar.name, "Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

  bar.time = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  bar.time:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
  bar.time:SetJustifyH("RIGHT")
  pcall(bar.time.SetFont, bar.time, "Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

  bar:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player")
  bar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
  bar:SetScript("OnEvent", function(self, event)
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_DELAYED" then
      refreshCast(self, false)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START"
      or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
      refreshCast(self, true)
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
      failCast(self)
    elseif not self.failUntil then
      if Addon.editMode then
        Addon:PreviewCastBar(true)
      else
        self:Hide()
      end
    end
  end)
  bar:SetScript("OnUpdate", updateCast)
  bar:Hide()
  return bar
end

function Addon:PreviewCastBar(preview)
  local bar = self.castBar
  if not bar then
    return
  end
  if not preview then
    bar.preview = nil
    local live = Addon:CastMeterState(GetTime(), bar.startTime, bar.endTime, bar.channel, bar.lagMs)
    if not live then
      bar:Hide()
    end
    return
  end
  local busy = UnitCastingInfo and (UnitCastingInfo("player") or (UnitChannelInfo and UnitChannelInfo("player")))
  if busy then
    bar.preview = nil
    return
  end
  bar.preview = true
  bar.failUntil = nil
  paintFill(bar, "cast")
  bar:SetMinMaxValues(0, 1)
  bar:SetValue(0.55)
  if bar.name then
    bar.name:SetText("Cast")
  end
  if bar.time then
    bar.time:SetText("")
  end
  placeSpark(bar, 0.55)
  if bar.lag then
    bar.lag:Hide()
  end
  hideTicks(bar)
  bar:Show()
end

function Addon:ApplyCombatMeterPreview()
  local preview = self.editMode == true
  self:PreviewCastBar(preview)
  if self.PreviewGCDBar then
    self:PreviewGCDBar(preview)
  end
  if self.PreviewSwingTimer then
    self:PreviewSwingTimer(preview)
  end
end

function Addon:ApplyCastBar()
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  hideBlizzardCastBar(_G.CastingBarFrame)
  hideBlizzardCastBar(_G.PlayerCastingBarFrame)
  if not self.castBar then
    self.castBar = createCastBar()
    self.gcdBar = self:CreateGCDBar(self.castGroup, self.castBar)
  end
  self:ParkCombatMeterGroup()
  self:ApplyCombatMeterPreview()
  if self.editMode and self.RefreshUnitDragOverlays then
    self:RefreshUnitDragOverlays()
  end
end
