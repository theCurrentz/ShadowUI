--[[
  Purpose: When the player or target is crowd-controlled, overlay the portrait
           with that spell icon and remaining time.
  Deps: UnitAura / C_UnitAuras
  Public: ShadowUI:CrowdControlKind(), ShadowUI:CrowdControlKindFromAura(),
          ShadowUI:SelectCrowdControl(), ShadowUI:CrowdControlPortraitState(),
          ShadowUI:CrowdControlPortraitRegion(), ShadowUI:HideLeftoverPortraits(),
          ShadowUI:SkinCrowdControlPortraits()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local RANK = {
  stun = 1,
  incapacitate = 2,
  fear = 3,
  disorient = 4,
  sleep = 5,
  silence = 6,
}
-- Classic Era and TBC Crowd Control, including ranks so UnitAura spell IDs match.
local CC = {
  -- Polymorph / Sap / Gouge / Freeze / Repentance / Shackle / Banish
  [118] = "incapacitate", [12824] = "incapacitate", [12825] = "incapacitate",
  [12826] = "incapacitate", [28271] = "incapacitate", [28272] = "incapacitate",
  [6770] = "incapacitate", [2070] = "incapacitate", [11297] = "incapacitate",
  [1776] = "incapacitate", [1777] = "incapacitate", [8629] = "incapacitate",
  [11285] = "incapacitate", [11286] = "incapacitate", [38764] = "incapacitate",
  [2094] = "disorient", [19503] = "disorient", [31661] = "disorient",
  [3355] = "incapacitate", [14308] = "incapacitate", [14309] = "incapacitate",
  [20066] = "incapacitate", [9484] = "incapacitate", [9485] = "incapacitate",
  [10955] = "incapacitate", [710] = "incapacitate", [18647] = "incapacitate",
  [33786] = "incapacitate", [51514] = "incapacitate",
  -- Fear / horror
  [5782] = "fear", [6213] = "fear", [6215] = "fear",
  [5484] = "fear", [17928] = "fear",
  [8122] = "fear", [8124] = "fear", [10888] = "fear", [10890] = "fear",
  [5246] = "fear", [20511] = "fear",
  [1513] = "fear", [14326] = "fear", [14327] = "fear",
  [6358] = "fear", [6789] = "fear", [17925] = "fear", [17926] = "fear",
  [27223] = "fear",
  -- Stun
  [1833] = "stun", [408] = "stun", [8643] = "stun",
  [5211] = "stun", [6798] = "stun", [8983] = "stun",
  [9005] = "stun", [9823] = "stun", [9827] = "stun", [27006] = "stun",
  [853] = "stun", [5588] = "stun", [5589] = "stun", [10308] = "stun",
  [20549] = "stun", [7922] = "stun",
  [20253] = "stun", [20614] = "stun", [20615] = "stun", [25273] = "stun",
  [12809] = "stun", [5530] = "stun", [22570] = "stun", [49802] = "stun",
  -- Sleep / Hibernate / Wyvern Sting (include NPC Sleep so a zzz matches)
  [2637] = "sleep", [18657] = "sleep", [18658] = "sleep",
  [19386] = "sleep", [24132] = "sleep", [24133] = "sleep", [27068] = "sleep",
  [700] = "sleep", [1090] = "sleep", [2937] = "sleep",
  [8398] = "sleep", [8399] = "sleep", [12098] = "sleep", [15970] = "sleep",
  [20663] = "sleep", [31292] = "sleep", [3636] = "sleep", [8040] = "sleep",
  -- Silence / spell lock
  [15487] = "silence", [19244] = "silence", [19647] = "silence",
  [18469] = "silence", [18425] = "silence", [18498] = "silence",
  [24259] = "silence", [34490] = "silence", [1330] = "silence",
}

local NAME_KIND = {}

local function rememberNames()
  if not GetSpellInfo then
    return
  end
  for spellId, kind in pairs(CC) do
    local name = GetSpellInfo(spellId)
    if type(name) == "string" and name ~= "" then
      NAME_KIND[name] = kind
    end
  end
end

function Addon:CrowdControlKind(spellId)
  return spellId and CC[spellId] or nil
end

function Addon:CrowdControlKindFromAura(spellId, name)
  local kind = spellId and CC[spellId]
  if kind then
    return kind
  end
  if type(name) == "string" and name ~= "" then
    if not next(NAME_KIND) then
      rememberNames()
    end
    return NAME_KIND[name]
  end
end

function Addon:SelectCrowdControl(auras)
  local best
  for _, aura in ipairs(auras or {}) do
    local kind = aura.kind or self:CrowdControlKindFromAura(aura.spellId, aura.name)
    local rank = kind and RANK[kind]
    if rank then
      aura.kind = kind
      if not best then
        best = aura
      else
        local bestRank = RANK[best.kind] or 99
        if rank < bestRank then
          best = aura
        elseif rank == bestRank and (aura.remaining or 0) > (best.remaining or 0) then
          best = aura
        end
      end
    end
  end
  return best
end

local function formatSeconds(remaining)
  if not remaining or remaining <= 0 then
    return nil
  end
  if Addon.FormatShortDuration then
    return Addon:FormatShortDuration(remaining)
  end
  if remaining >= 60 then
    return string.format("%dm", math.floor(remaining / 60 + 0.5))
  end
  return string.format("%d", math.ceil(remaining - 1e-6))
end

function Addon:CrowdControlPortraitState(now, aura)
  if not aura or not aura.icon then
    return nil
  end
  local duration = tonumber(aura.duration) or 0
  local expiration = tonumber(aura.expirationTime) or 0
  local remaining = expiration - (now or 0)
  local state = { icon = aura.icon }
  if duration > 0 and remaining > 0 then
    state.duration = duration
    state.startTime = expiration - duration
    state.remaining = remaining
    state.text = formatSeconds(remaining)
  end
  return state
end

local function eachAura(unit, filter, fn)
  local any = false
  if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
    for i = 1, 40 do
      local data = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
      if not data then
        break
      end
      any = true
      fn(data.spellId, data.icon, data.duration, data.expirationTime, data.name)
    end
  end
  if any or not UnitAura then
    return
  end
  for i = 1, 40 do
    local name, icon, _, _, duration, expiration, _, _, _, spellId = UnitAura(unit, i, filter)
    if not name then
      break
    end
    fn(spellId, icon, duration, expiration, name)
  end
end

function Addon:CrowdControlAuraOn(unit)
  if not unit then
    return nil
  end
  local now = GetTime and GetTime() or 0
  local found = {}
  local function take(spellId, icon, duration, expiration, name)
    local kind = Addon:CrowdControlKindFromAura(spellId, name)
    if not kind then
      return
    end
    found[#found + 1] = {
      spellId = spellId,
      name = name,
      icon = icon,
      duration = duration or 0,
      expirationTime = expiration or 0,
      remaining = (expiration or 0) - now,
      kind = kind,
    }
  end
  eachAura(unit, "HARMFUL", take)
  -- Sleep on some NPC casts is still HARMFUL; HELPFUL is a fallback if spellId
  -- was missing from the first pass.
  if #found == 0 then
    eachAura(unit, "HELPFUL", take)
  end
  return self:SelectCrowdControl(found)
end

local HOSTS = {
  { unit = "player", frame = "PlayerFrame" },
  { unit = "target", frame = "TargetFrame" },
}

local function hideChip(region)
  if not region then
    return
  end
  if region.Hide then
    region:Hide()
  end
  if region._shadowUIChipLock then
    local orig = region._shadowUIChipSetAlpha
    if orig then
      orig(region, 0)
    end
    return
  end
  region._shadowUIChipLock = true
  local origSetAlpha = region.SetAlpha
  region._shadowUIChipSetAlpha = origSetAlpha
  if origSetAlpha then
    origSetAlpha(region, 0)
    region.SetAlpha = function(self)
      origSetAlpha(self, 0)
    end
  end
  if region.Show then
    region.Show = function(self)
      if self.Hide then
        self:Hide()
      end
    end
  end
  if region.SetShown then
    region.SetShown = function(self)
      if self.Hide then
        self:Hide()
      end
    end
  end
end

local function containerOf(frame)
  if not frame then
    return nil
  end
  if frame.PlayerFrameContainer then
    return frame.PlayerFrameContainer
  end
  if frame.TargetFrameContainer then
    return frame.TargetFrameContainer
  end
  if not frame.GetChildren then
    return nil
  end
  local kids = { frame:GetChildren() }
  for i = 1, #kids do
    local child = kids[i]
    local n = child.GetName and child:GetName() or ""
    if n:find("FrameContainer") and (child.Portrait or child.portrait or child.PlayerPortrait) then
      return child
    end
  end
end

local function leftoverGlobal(frame)
  if not frame then
    return nil
  end
  if frame.PlayerFrameContainer or frame == _G.PlayerFrame then
    return _G.PlayerPortrait
  end
  if frame.TargetFrameContainer or frame == _G.TargetFrame then
    return _G.TargetFramePortrait
  end
end

local LIVE_MIN = 48

local function widthOf(port)
  if not port or not port.GetWidth then
    return 0
  end
  return tonumber(port:GetWidth()) or 0
end

local function onContainer(region, container)
  if not region or not container then
    return false
  end
  if not region.GetParent then
    return true
  end
  return region:GetParent() == container
end

-- Prefer the live portrait hole. A leftover chip can be named PlayerPortrait.
local function pickOnContainer(order, container, leftover)
  local fallback
  for i = 1, #order do
    local port = order[i]
    if port and onContainer(port, container) then
      local leftoverChip = leftover and port == leftover and widthOf(port) < LIVE_MIN
      if not leftoverChip then
        if widthOf(port) >= LIVE_MIN then
          return port
        end
        if not fallback then
          fallback = port
        end
      end
    end
  end
  return fallback
end

function Addon:CrowdControlPortraitRegion(frame)
  if not frame then
    return nil
  end
  -- Live hole is the container portrait (>= 48px). Leftover globals and chips
  -- can still be named PlayerPortrait / Portrait.
  local container = containerOf(frame)
  if container then
    local leftover = leftoverGlobal(frame)
    local order
    if frame.PlayerFrameContainer then
      order = { container.PlayerPortrait, container.Portrait, container.portrait }
    else
      order = { container.Portrait, container.portrait, container.PlayerPortrait }
    end
    local port = pickOnContainer(order, container, leftover)
    if port then
      return port, container
    end
  end
  if frame.portrait or frame.Portrait then
    local port = frame.portrait or frame.Portrait
    if port ~= leftoverGlobal(frame) then
      return port, frame
    end
  end
  local name = frame.GetName and frame:GetName()
  if name and _G[name .. "Portrait"] and _G[name .. "Portrait"] ~= leftoverGlobal(frame) then
    return _G[name .. "Portrait"], frame
  end
  if _G.PlayerPortrait and frame == _G.PlayerFrame then
    return _G.PlayerPortrait, frame
  end
  if _G.TargetFramePortrait and frame == _G.TargetFrame then
    return _G.TargetFramePortrait, frame
  end
end

local function hideNamedPortraits(host, live)
  if not host then
    return
  end
  if host.GetRegions then
    local regions = { host:GetRegions() }
    for i = 1, #regions do
      local r = regions[i]
      local n = r.GetName and r:GetName()
      if r ~= live and n and n:find("Portrait") and widthOf(r) < LIVE_MIN then
        hideChip(r)
      end
    end
  end
  if host.GetChildren then
    local kids = { host:GetChildren() }
    for i = 1, #kids do
      local child = kids[i]
      local n = child.GetName and child:GetName()
      if child ~= live and n and n:find("Portrait") and not n:find("Container")
        and widthOf(child) < LIVE_MIN then
        hideChip(child)
      end
    end
  end
end

function Addon:HideLeftoverPortraits(frame, live)
  if not frame then
    return
  end
  local container = containerOf(frame)
  local chips = {}
  local function addChip(chip)
    if chip then
      chips[#chips + 1] = chip
    end
  end
  addChip(container and container.Portrait)
  addChip(container and container.portrait)
  addChip(container and container.PlayerPortrait)
  addChip(frame.portrait)
  addChip(frame.Portrait)
  addChip(frame.PlayerPortrait)
  addChip(_G.PlayerPortrait)
  addChip(_G.TargetFramePortrait)
  local name = frame.GetName and frame:GetName()
  if name then
    chips[#chips + 1] = _G[name .. "Portrait"]
  end
  for _, chip in ipairs(chips) do
    if chip and chip ~= live and widthOf(chip) < LIVE_MIN then
      hideChip(chip)
    end
  end
  hideNamedPortraits(frame, live)
  hideNamedPortraits(container, live)
end

local function restorePortrait(portrait)
  if not portrait then
    return
  end
  if portrait._shadowUICCHidden and portrait.SetAlpha then
    portrait:SetAlpha(portrait._shadowUICCAlpha or 1)
  end
  portrait._shadowUICCHidden = nil
end

local function hidePortrait(portrait)
  if not portrait or not portrait.SetAlpha then
    return
  end
  if not portrait._shadowUICCHidden then
    portrait._shadowUICCAlpha = portrait.GetAlpha and portrait:GetAlpha() or 1
    portrait._shadowUICCHidden = true
  end
  portrait:SetAlpha(0)
end

local function ensureOverlay(portrait, parent)
  if not portrait then
    return nil
  end
  parent = parent or (portrait.GetParent and portrait:GetParent()) or portrait
  local holder = parent.shadowUICCHolder
  if holder then
    return holder, parent
  end
  if CreateFrame then
    holder = CreateFrame("Frame", nil, parent)
  elseif parent.CreateFrame then
    holder = parent:CreateFrame("Frame")
  end
  if not holder then
    return nil
  end
  parent.shadowUICCHolder = holder
  if holder.SetAllPoints then
    holder:SetAllPoints(portrait)
  end
  if parent.GetFrameLevel and holder.SetFrameLevel then
    holder:SetFrameLevel((parent:GetFrameLevel() or 0) + 8)
  end
  if holder.EnableMouse then
    holder:EnableMouse(false)
  end
  local overlay = holder.shadowUICCIcon
  if not overlay and holder.CreateTexture then
    overlay = holder:CreateTexture(nil, "OVERLAY", nil, 7)
    holder.shadowUICCIcon = overlay
    if overlay.SetAllPoints then
      overlay:SetAllPoints(holder)
    end
  end
  local swipe = holder.shadowUICCSwipe
  if not swipe and CreateFrame then
    local ok, created = pcall(CreateFrame, "Cooldown", nil, holder, "CooldownFrameTemplate")
    if ok then
      swipe = created
    else
      swipe = CreateFrame("Cooldown", nil, holder)
    end
  end
  if swipe then
    holder.shadowUICCSwipe = swipe
    if swipe.SetAllPoints then
      swipe:SetAllPoints(holder)
    end
    if swipe.SetDrawEdge then
      swipe:SetDrawEdge(true)
    end
    if swipe.SetDrawSwipe then
      swipe:SetDrawSwipe(true)
    end
    if swipe.SetHideCountdownNumbers then
      swipe:SetHideCountdownNumbers(true)
    end
    if holder.GetFrameLevel and swipe.SetFrameLevel then
      swipe:SetFrameLevel(holder:GetFrameLevel() + 1)
    end
  end
  local text = holder.shadowUICCText
  if not text and holder.CreateFontString then
    text = holder:CreateFontString(nil, "OVERLAY")
    holder.shadowUICCText = text
    if text.SetPoint then
      text:SetPoint("CENTER", holder, "CENTER", 0, 0)
    end
    local path = _G.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    if text.SetFont then
      text:SetFont(path, 12, "OUTLINE")
    end
    if text.SetTextColor then
      text:SetTextColor(1, 0.82, 0, 1)
    end
    if text.SetDrawLayer then
      text:SetDrawLayer("OVERLAY", 7)
    end
  end
  return holder, parent
end

local function paintHost(spec)
  local frame = _G[spec.frame]
  if not frame then
    return
  end
  local portrait, parent = Addon:CrowdControlPortraitRegion(frame)
  if not portrait then
    return
  end
  Addon:HideLeftoverPortraits(frame, portrait)
  local holder = ensureOverlay(portrait, parent)
  if not holder then
    return
  end
  local overlay = holder.shadowUICCIcon
  local aura = Addon:CrowdControlAuraOn(spec.unit)
  local state = Addon:CrowdControlPortraitState(GetTime and GetTime() or 0, aura)
  if not state then
    restorePortrait(portrait)
    if holder.Hide then
      holder:Hide()
    end
    if overlay and overlay.Hide then
      overlay:Hide()
    end
    if holder.shadowUICCSwipe and holder.shadowUICCSwipe.Hide then
      holder.shadowUICCSwipe:Hide()
    end
    if holder.shadowUICCText and holder.shadowUICCText.Hide then
      holder.shadowUICCText:Hide()
    end
    return
  end
  restorePortrait(portrait)
  if spec.unit == "player" then
    local contextual = frame.PlayerFrameContent and frame.PlayerFrameContent.PlayerFrameContentContextual
    local restLoop = contextual and contextual.PlayerRestLoop
    for _, icon in ipairs({ restLoop, _G.PlayerRestIcon, _G.PlayerRestGlow }) do
      if icon and icon.Hide then
        icon:Hide()
      end
    end
  end
  if holder.SetSize then
    local size = (portrait.GetWidth and portrait:GetWidth()) or 60
    holder:SetSize(size, size)
  end
  if holder.SetAllPoints then
    holder:SetAllPoints(portrait)
  end
  if holder.Show then
    holder:Show()
  end
  if overlay then
    if overlay.SetTexture then
      overlay:SetTexture(state.icon)
    end
    if SetPortraitToTexture then
      pcall(SetPortraitToTexture, overlay, state.icon)
    end
    if overlay.Show then
      overlay:Show()
    end
  end
  local swipe = holder.shadowUICCSwipe
  if swipe then
    if state.startTime and swipe.SetCooldown then
      swipe:SetCooldown(state.startTime, state.duration)
      if swipe.Show then
        swipe:Show()
      end
    elseif swipe.Hide then
      swipe:Hide()
    end
  end
  local text = holder.shadowUICCText
  if text then
    if state.text then
      text:SetText(state.text)
      if text.Show then
        text:Show()
      end
    elseif text.Hide then
      text:Hide()
    end
  end
end

function Addon:SkinCrowdControlPortraits()
  for _, spec in ipairs(HOSTS) do
    paintHost(spec)
  end
end

local function startEvents()
  if Addon._ccPortraitEvents then
    return
  end
  Addon._ccPortraitEvents = true
  if Addon.RegisterEvent then
    for _, event in ipairs({
      "UNIT_AURA",
      "PLAYER_TARGET_CHANGED",
      "PLAYER_ENTERING_WORLD",
      "UNIT_PORTRAIT_UPDATE",
    }) do
      pcall(Addon.RegisterEvent, Addon, event, "SkinCrowdControlPortraits")
    end
  end
  if CreateFrame then
    local ticker = CreateFrame("Frame")
    ticker:SetScript("OnUpdate", function(self, elapsed)
      self.elapsed = (self.elapsed or 0) + (elapsed or 0)
      if self.elapsed < 0.2 then
        return
      end
      self.elapsed = 0
      Addon:SkinCrowdControlPortraits()
    end)
    Addon._ccPortraitTicker = ticker
  end
end

function Addon:ApplyCrowdControlPortraits()
  startEvents()
  self:SkinCrowdControlPortraits()
end
