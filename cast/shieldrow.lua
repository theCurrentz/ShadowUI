--[[
  Purpose: Colour-coded Shield Row locked to the Player Frame.
  Deps: ShadowUI:ShieldInfo(), ShadowUI:ShieldAbsorbMax(), ShadowUI:ShieldFill(),
        ShadowUI:ShieldApplyAbsorb(), ShadowUI:ShieldAbsorbFromInfo()
  Public: ShadowUI:ApplyShields(), ShadowUI:ShieldSyncAuras(),
          ShadowUI:ShieldRowPaint(), ShadowUI:ShieldRowPulse(),
          ShadowUI:ShieldRowSlotX()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local SIZE, GAP, ROW_H, OFFSET = 22, 6, 36, 4
local ROW_ALPHA, ICON_ALPHA = 0.70, 0.42
local STIFFNESS, DAMPING, ENTER_Y = 220, 16, 14
local MAX_ICONS = 6

function Addon:ShieldRowSlotX(index)
  return (math.max(index or 1, 1) - 1) * (SIZE + GAP)
end

-- Classic SetMask plus SetTexCoord samples the mask UVs and paints stripes.
-- SetPortraitToTexture is the unit-portrait oval crop and keeps spell art intact.
local function applyArt(tex, path)
  if not tex or not path then
    return
  end
  if SetPortraitToTexture and pcall(SetPortraitToTexture, tex, path) then
    return
  end
  if tex.SetTexture then
    tex:SetTexture(path)
  end
end

local function makeIcon(row)
  local icon = CreateFrame("Frame", nil, row)
  icon:SetSize(SIZE, SIZE)
  local art = icon:CreateTexture(nil, "ARTWORK")
  art:SetAllPoints()
  art:SetAlpha(ICON_ALPHA)
  icon.art = art
  local clip = CreateFrame("Frame", nil, icon)
  clip:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", 0, 0)
  clip:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
  clip:SetHeight(SIZE)
  if clip.SetClipsChildren then
    clip:SetClipsChildren(true)
  end
  icon.clip = clip
  local fill = clip:CreateTexture(nil, "OVERLAY")
  fill:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
  fill:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
  icon.fill = fill
  local percent = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  percent:SetPoint("TOP", icon, "BOTTOM", 0, -1)
  percent:SetJustifyH("CENTER")
  percent:SetFont("Fonts\\FRIZQT__.TTF", 7, "OUTLINE")
  icon.percent = percent
  icon.x, icon.y, icon.vx, icon.vy = 0, 0, 0, 0
  icon.alpha, icon.targetAlpha = 0, 0
  icon:Hide()
  return icon
end

local function placeIcon(icon)
  icon:ClearAllPoints()
  icon:SetPoint("TOPLEFT", icon:GetParent() or icon, "TOPLEFT", icon.x, icon.y)
  icon:SetAlpha(icon.alpha)
end

local function spring(pos, vel, target, dt)
  vel = vel + (target - pos) * STIFFNESS * dt
  vel = vel * math.max(0, 1 - DAMPING * dt)
  return pos + vel * dt, vel
end

local function playerAuras()
  local list = {}
  if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
    local i = 1
    while true do
      local data = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
      if not data then
        break
      end
      if data.spellId then
        list[#list + 1] = { spellId = data.spellId, expires = data.expirationTime }
      end
      i = i + 1
    end
    return list
  end
  if not UnitBuff then
    return list
  end
  local i = 1
  while true do
    local name, _, _, _, _, expires, _, _, _, spellId = UnitBuff("player", i)
    if not name then
      break
    end
    if spellId then
      list[#list + 1] = { spellId = spellId, expires = expires }
    end
    i = i + 1
  end
  return list
end

function Addon:ShieldSyncAuras(row, auras, talents, bonusFor)
  if not row then
    return
  end
  local previous = row.shields or {}
  local nextShields = {}
  for _, aura in ipairs(auras or {}) do
    local info = self:ShieldInfo(aura.spellId)
    if info then
      local existing
      for _, shield in ipairs(previous) do
        if shield.spellId == aura.spellId then
          existing = shield
          break
        end
      end
      local bonus = 0
      if type(bonusFor) == "function" then
        bonus = bonusFor(aura.spellId) or 0
      elseif type(bonusFor) == "number" then
        bonus = bonusFor
      end
      local max = self:ShieldAbsorbMax(aura.spellId, bonus, talents)
      if existing then
        existing.max = max
        if existing.remaining > max then
          existing.remaining = max
        end
        if aura.expires and existing.expires and aura.expires > existing.expires then
          existing.remaining = max
        end
        existing.expires = aura.expires
        nextShields[#nextShields + 1] = existing
      else
        nextShields[#nextShields + 1] = {
          spellId = aura.spellId,
          remaining = max,
          max = max,
          expires = aura.expires,
        }
      end
    end
  end
  row.shields = nextShields
  local live = #nextShields
  for i, icon in ipairs(row.icons or {}) do
    if i > live then
      icon.targetAlpha = 0
    end
  end
end

function Addon:ShieldRowPaint(row)
  if not row then
    return
  end
  local shields = row.shields or {}
  for i, shield in ipairs(shields) do
    local icon = row.icons[i]
    if not icon then
      icon = makeIcon(row)
      row.icons[i] = icon
    end
    local info = self:ShieldInfo(shield.spellId)
    local fill = self:ShieldFill(shield.remaining, shield.max)
    local color = info and info.color or { 1, 1, 1 }
    local path = info and info.icon
    applyArt(icon.art, path)
    applyArt(icon.fill, path)
    if icon.art.SetVertexColor then
      icon.art:SetVertexColor(color[1], color[2], color[3], ICON_ALPHA)
    end
    if icon.fill.SetVertexColor then
      icon.fill:SetVertexColor(color[1], color[2], color[3], 1)
    end
    if icon.clip and icon.clip.SetHeight then
      icon.clip:SetHeight(SIZE * fill.ratio)
    end
    icon.percent:SetText(fill.text)
    if not icon.shown and icon.alpha == 0 then
      icon.x = self:ShieldRowSlotX(i)
      icon.y = ENTER_Y
      icon.vx, icon.vy = 0, 0
    end
    icon.targetX = self:ShieldRowSlotX(i)
    icon.targetY = 0
    icon.targetAlpha = 1
    icon:Show()
    icon.shown = true
  end
  for i = #shields + 1, #(row.icons or {}) do
    local icon = row.icons[i]
    icon.targetAlpha = 0
  end
end

function Addon:ShieldRowPulse(row, dt)
  if not row then
    return
  end
  dt = dt or 0
  self:ShieldRowPaint(row)
  for _, icon in ipairs(row.icons or {}) do
    local targetX = icon.targetX or icon.x or 0
    local targetY = icon.targetY or 0
    icon.x, icon.vx = spring(icon.x or 0, icon.vx or 0, targetX, dt)
    icon.y, icon.vy = spring(icon.y or 0, icon.vy or 0, targetY, dt)
    icon.alpha, icon.va = spring(icon.alpha or 0, icon.va or 0, icon.targetAlpha or 0, dt)
    if (icon.targetAlpha or 0) <= 0 and (icon.alpha or 0) < 0.03 then
      icon.alpha = 0
      icon:Hide()
      icon.shown = false
    end
    placeIcon(icon)
  end
end

local function refresh(row)
  Addon:ShieldSyncAuras(row, playerAuras(), Addon:ShieldTalentsFromClient(), function(spellId)
    return Addon:ShieldBonusFromClient(spellId)
  end)
  Addon:ShieldRowPaint(row)
end

local function onEvent(row, event)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" then
    if not CombatLogGetCurrentEventInfo then
      return
    end
    local info = { CombatLogGetCurrentEventInfo() }
    if info[8] ~= UnitGUID("player") then
      return
    end
    local amount, school, auraId = Addon:ShieldAbsorbFromInfo(info[2], info)
    Addon:ShieldApplyAbsorb(row.shields, amount, school, auraId)
    Addon:ShieldRowPaint(row)
    return
  end
  refresh(row)
end

function Addon:ApplyShields()
  if not self.shieldRow then
    local row = CreateFrame("Frame", "ShadowUIShieldRow", PlayerFrame or UIParent)
    row:SetSize(160, ROW_H)
    row:SetFrameStrata("MEDIUM")
    row:SetAlpha(ROW_ALPHA)
    row.icons = {}
    row.shields = {}
    for _ = 1, MAX_ICONS do
      row.icons[#row.icons + 1] = makeIcon(row)
    end
    row:RegisterEvent("UNIT_AURA")
    row:RegisterEvent("PLAYER_ENTERING_WORLD")
    row:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    pcall(row.RegisterUnitEvent, row, "UNIT_AURA", "player")
    row:SetScript("OnEvent", onEvent)
    row:SetScript("OnUpdate", function(selfRow)
      local now = GetTime and GetTime() or 0
      local last = selfRow.lastPulse or now
      selfRow.lastPulse = now
      Addon:ShieldRowPulse(selfRow, math.max(0, now - last))
    end)
    self.shieldRow = row
  end
  local row = self.shieldRow
  row:ClearAllPoints()
  local host = PlayerName or PlayerFrame or UIParent
  row:SetPoint("BOTTOMLEFT", host, "TOPLEFT", 0, OFFSET)
  row:SetAlpha(ROW_ALPHA)
  row:Show()
end
