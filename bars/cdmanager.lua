--[[
  Purpose: Queue tracked class cooldowns with insert and pop. Layout host cooldown.
           Queue icons use action-icon chrome, a 0.07 crop, and Outer Edge.
  Deps:           ShadowUI:CooldownSpellList(), ShadowUI:ParkFrame(), ShadowUI:Ease(),
          ShadowUI:BarGridMetrics()
  Public: ShadowUI:CooldownQueueState(), ShadowUI:CooldownQueueDiff(),
          ShadowUI:CooldownQueueCap(), ShadowUI:CooldownDirection(),
          ShadowUI:CooldownGridMetrics(), ShadowUI:CooldownSlotOffset(),
          ShadowUI:CooldownPopDrop(), ShadowUI:CooldownShiftCoord(),
          ShadowUI:SpellInfoIcon(), ShadowUI:CooldownSpellKey(),
          ShadowUI:PinCooldownClock(), ShadowUI:ActionBarSpellIds(),
          ShadowUI:SkinCooldownIcon(), ShadowUI:ApplyCooldownManager()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local INSERT_DUR = 0.2
local POP_DUR = 0.2
local SHIFT_DUR = 0.2
local DROP_PX = 14
local MIN_DURATION = 2
local SIZE = 36 * 0.9
local DEFAULT_MAX = 8
local CROP = 0.07
local INSET = 2
local DIRECTIONS = { right = true, left = true, up = true, down = true }

local OUTER_PAD = 4

local function pinInset(region, icon)
  if not region then
    return
  end
  if region.ClearAllPoints then
    region:ClearAllPoints()
  end
  if region.SetPoint then
    region:SetPoint("TOPLEFT", icon, "TOPLEFT", INSET, -INSET)
    region:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -INSET, INSET)
  end
end

local function placeOuter(icon, outer)
  if not outer then
    return
  end
  if outer.SetParent then
    outer:SetParent(icon)
  end
  local parent = icon.GetParent and icon:GetParent()
  if parent and parent.SetClipsChildren then
    parent:SetClipsChildren(false)
  end
  if icon.SetClipsChildren then
    icon:SetClipsChildren(false)
  end
  if outer.ClearAllPoints then
    outer:ClearAllPoints()
  end
  if outer.SetPoint then
    outer:SetPoint("TOPLEFT", icon, "TOPLEFT", -OUTER_PAD, OUTER_PAD)
    outer:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", OUTER_PAD, -OUTER_PAD)
  end
  if icon.GetFrameLevel and outer.SetFrameLevel then
    local level = icon:GetFrameLevel()
    if level > 0 then
      outer:SetFrameLevel(level - 1)
    end
  end
  if Addon.PaintOuterChrome then
    Addon:PaintOuterChrome(outer)
  end
end

function Addon:SkinCooldownIcon(icon, size)
  if not icon then
    return
  end
  size = size or SIZE
  if icon.SetSize then
    icon:SetSize(size, size)
  elseif icon.SetWidth and icon.SetHeight then
    icon:SetWidth(size)
    icon:SetHeight(size)
  end
  local chrome = icon.shadowUIChrome
  if not chrome and icon.CreateTexture then
    chrome = icon:CreateTexture(nil, "BACKGROUND", nil, -8)
    icon.shadowUIChrome = chrome
  end
  if chrome then
    chrome:ClearAllPoints()
    chrome:SetAllPoints(icon)
    chrome:SetColorTexture(0.05, 0.05, 0.05, 1)
    chrome:Show()
  end
  if self.ApplyOuterChrome then
    placeOuter(icon, self:ApplyOuterChrome(icon, "square"))
  end
  if icon.shadowUIOuter and icon.shadowUIOuter.Show then
    icon.shadowUIOuter:Show()
  end
  local tex = icon.texture or icon.icon or icon.Icon
  if tex then
    pinInset(tex, icon)
    if tex.SetTexCoord then
      tex:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
    end
    if tex.SetDrawLayer then
      tex:SetDrawLayer("ARTWORK", 0)
    end
  end
  local swipe = icon.swipe
  if swipe and not icon.shadowUICooldownSkinned then
    icon.shadowUICooldownSkinned = true
    pinInset(swipe, icon)
    if swipe.SetDrawSwipe then
      swipe:SetDrawSwipe(true)
    end
    if swipe.SetDrawEdge then
      swipe:SetDrawEdge(true)
    end
  end
end

local function remainingText(remaining)
  if Addon.FormatCooldownCount then
    return Addon:FormatCooldownCount(remaining)
  end
  if remaining >= 60 then
    return string.format("%dm", math.floor(remaining / 60 + 0.5))
  end
  return string.format("%d", math.ceil(remaining - 1e-6))
end

function Addon:CooldownHiddenStore()
  local classFile = self.GetPlayerClass and self:GetPlayerClass()
  if not classFile or not self.GetDB then
    return nil
  end
  local db = self:GetDB()
  db.classes = db.classes or {}
  db.classes[classFile] = db.classes[classFile]
    or { layout = {}, keybinds = {}, variants = {} }
  local classAcc = db.classes[classFile]
  classAcc.cooldownHidden = classAcc.cooldownHidden or {}
  return classAcc.cooldownHidden
end

function Addon:CooldownSpellHidden(spellId)
  local hidden = self:CooldownHiddenStore()
  return hidden and hidden[spellId] == true
end

function Addon:SetCooldownSpellHidden(spellId, hidden)
  local store = self:CooldownHiddenStore()
  if not store then
    return
  end
  if hidden then
    store[spellId] = true
  else
    store[spellId] = nil
  end
end

function Addon:CooldownQueueState(now, entries)
  local out = {}
  for _, entry in ipairs(entries or {}) do
    local startTime = entry.start or entry.startTime
    local duration = entry.duration
    if startTime and duration and duration >= MIN_DURATION then
      local remaining = startTime + duration - now
      if remaining > 0 then
        out[#out + 1] = {
          spellId = entry.spellId,
          icon = entry.icon,
          start = startTime,
          duration = duration,
          remaining = remaining,
          text = remainingText(remaining),
          keybind = entry.keybind,
        }
      end
    end
  end
  table.sort(out, function(a, b)
    if a.remaining == b.remaining then
      return (a.spellId or 0) < (b.spellId or 0)
    end
    return a.remaining < b.remaining
  end)
  return out
end

function Addon:CooldownQueueDiff(prevIds, nextIds)
  local prevSet, nextSet = {}, {}
  for _, id in ipairs(prevIds or {}) do
    prevSet[id] = true
  end
  for _, id in ipairs(nextIds or {}) do
    nextSet[id] = true
  end
  local insert, remove, keep = {}, {}, {}
  for _, id in ipairs(nextIds or {}) do
    if prevSet[id] then
      keep[#keep + 1] = id
    else
      insert[#insert + 1] = id
    end
  end
  for _, id in ipairs(prevIds or {}) do
    if not nextSet[id] then
      remove[#remove + 1] = id
    end
  end
  return { insert = insert, remove = remove, keep = keep }
end

function Addon:CooldownQueueCap(queue, max)
  queue = queue or {}
  max = math.max(1, max or #queue)
  if #queue <= max then
    return queue
  end
  local out = {}
  for i = 1, max do
    out[i] = queue[i]
  end
  return out
end

function Addon:CooldownDirection(cfg)
  cfg = cfg or {}
  local dir = cfg.direction
  if type(dir) == "string" then
    dir = dir:lower()
    if DIRECTIONS[dir] then
      return dir
    end
  end
  if cfg.vertical == true then
    return "down"
  end
  return "right"
end

local function defaultColumns(direction, max)
  if direction == "up" or direction == "down" then
    return 1
  end
  return max
end

function Addon:CooldownGridMetrics(cfg)
  cfg = cfg or {}
  local direction = self:CooldownDirection(cfg)
  local max = math.max(1, cfg.max or cfg.count or 1)
  local columns = cfg.columns or defaultColumns(direction, max)
  columns = math.max(1, math.min(columns, max))
  local size = cfg.buttonSize or SIZE
  local gap = cfg.gap or 4
  if self.BarGridMetrics then
    return self:BarGridMetrics(max, columns, size, gap)
  end
  local rows = math.ceil(max / columns)
  return {
    columns = columns,
    rows = rows,
    width = columns * size + (columns - 1) * gap,
    height = rows * size + (rows - 1) * gap,
  }
end

function Addon:CooldownSlotCell(index, columns, rows, direction)
  local i = math.max(0, (index or 1) - 1)
  columns = math.max(1, columns or 1)
  rows = math.max(1, rows or 1)
  local col, row
  if direction == "down" then
    row = i % rows
    col = math.floor(i / rows)
  elseif direction == "up" then
    row = (rows - 1) - (i % rows)
    col = math.floor(i / rows)
  elseif direction == "left" then
    col = (columns - 1) - (i % columns)
    row = math.floor(i / columns)
  else
    col = i % columns
    row = math.floor(i / columns)
  end
  return col, row
end

function Addon:CooldownSlotOffset(index, count, cfg)
  cfg = cfg or {}
  local size = cfg.buttonSize or SIZE
  local gap = cfg.gap or 4
  local step = size + gap
  local direction = self:CooldownDirection(cfg)
  local max = math.max(1, cfg.max or count or 1)
  local columns = cfg.columns or defaultColumns(direction, max)
  local grid = self:CooldownGridMetrics({
    max = max,
    columns = columns,
    buttonSize = size,
    gap = gap,
    direction = direction,
  })
  local col, row = self:CooldownSlotCell(index, grid.columns, grid.rows, direction)
  local x = -grid.width / 2 + size / 2 + col * step
  local y = grid.height / 2 - size / 2 - row * step
  return x, y
end

function Addon:CooldownInsertAlpha(t, dur)
  dur = dur or INSERT_DUR
  if not t or t <= 0 then
    return 0
  end
  if t >= dur then
    return 1
  end
  local p = t / dur
  if self.Ease then
    p = self:Ease(p)
  end
  return p
end

function Addon:CooldownPopAlpha(t, dur)
  dur = dur or POP_DUR
  if not t or t <= 0 then
    return 1
  end
  if t >= dur then
    return 0
  end
  local p = t / dur
  if self.Ease then
    p = self:Ease(p)
  end
  return 1 - p
end

function Addon:CooldownPopDrop(t, dur)
  dur = dur or POP_DUR
  if not t or t <= 0 then
    return 0
  end
  if t >= dur then
    return DROP_PX
  end
  local p = t / dur
  if self.Ease then
    p = self:Ease(p)
  end
  return DROP_PX * p
end

function Addon:CooldownShiftCoord(from, to, t, dur)
  if from == nil then
    return to
  end
  if to == nil then
    return from
  end
  dur = dur or SHIFT_DUR
  if not t or t <= 0 then
    return from
  end
  if t >= dur then
    return to
  end
  local p = t / dur
  if self.Ease then
    p = self:Ease(p)
  end
  return from + (to - from) * p
end

local ACTION_SLOTS = 120

function Addon:LooksLikeSpellIcon(value)
  if type(value) == "number" then
    return value > 0
  end
  if type(value) ~= "string" or value == "" then
    return false
  end
  local lower = value:lower()
  if lower:find("^interface") or lower:find("[\\/]") then
    return true
  end
  return value:match("^%d+$") ~= nil
end

function Addon:SpellInfoName(spellId)
  if not spellId or not GetSpellInfo then
    return nil
  end
  local name = GetSpellInfo(spellId)
  return name
end

function Addon:SpellInfoIcon(spellId, fallback)
  if spellId and GetSpellInfo then
    local _, second, third = GetSpellInfo(spellId)
    -- Classic: name, rank, icon. Rank is not a texture.
    -- Some clients put the icon in the second return.
    if self:LooksLikeSpellIcon(second) then
      return second
    end
    if self:LooksLikeSpellIcon(third) then
      return third
    end
  end
  if spellId and GetSpellTexture then
    local tex = GetSpellTexture(spellId)
    if tex then
      return tex
    end
  end
  if spellId and C_Spell and C_Spell.GetSpellTexture then
    local tex = C_Spell.GetSpellTexture(spellId)
    if tex then
      return tex
    end
  end
  return fallback
end

local function spellCooldown(spellId, name)
  local startTime, duration, enabled = 0, 0, 1
  if not GetSpellCooldown then
    return startTime, duration, enabled
  end
  startTime, duration, enabled = GetSpellCooldown(spellId)
  if (not duration or duration == 0) and name then
    startTime, duration, enabled = GetSpellCooldown(name)
  end
  return startTime or 0, duration or 0, enabled
end

local function macroSpellId(macroId)
  if not GetMacroSpell then
    return nil
  end
  local name, _, id = GetMacroSpell(macroId)
  if type(id) == "number" then
    return id, name
  end
  if name and GetSpellInfo then
    local _, _, _, _, _, _, sid = GetSpellInfo(name)
    if type(sid) == "number" then
      return sid, name
    end
  end
  return nil, name
end

function Addon:ActionBarSpellIds()
  local ids = {}
  if not GetActionInfo then
    return ids
  end
  for slot = 1, ACTION_SLOTS do
    local actionType, id = GetActionInfo(slot)
    local spellId
    if actionType == "spell" then
      spellId = id
    elseif actionType == "macro" then
      spellId = macroSpellId(id)
    end
    if type(spellId) == "number" then
      local icon
      if GetActionTexture then
        icon = GetActionTexture(slot)
      end
      ids[spellId] = { spellId = spellId, icon = icon, slot = slot }
    end
  end
  return ids
end

function Addon:CooldownSpellKey(spellId, name)
  name = name or self:SpellInfoName(spellId)
  if type(name) == "string" then
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name ~= "" then
      return name:lower()
    end
  end
  if spellId then
    return "id:" .. tostring(spellId)
  end
end

-- Classic GetSpellCooldown can return start ≈ now and the full duration on every
-- poll (SPELL_UPDATE_COOLDOWN / energy tick). Keep the first clock so remaining
-- counts down and the swipe does not restart.
-- While the spell is active (Stealth), enabled is 0 and start is always now.
-- Keep the enter clock until it ends, then stay idle until the effect drops.
function Addon:PinCooldownClock(key, startTime, duration, now, enabled)
  startTime = startTime or 0
  duration = duration or 0
  now = now or 0
  self._cooldownPins = self._cooldownPins or {}
  self._cooldownActiveSkip = self._cooldownActiveSkip or {}
  if enabled == 0 then
    if not key then
      return 0, 0
    end
    if self._cooldownActiveSkip[key] then
      return 0, 0
    end
    local pin = self._cooldownPins[key]
    if pin then
      local pinRemaining = pin.start + pin.duration - now
      if pinRemaining > 0 then
        return pin.start, pin.duration
      end
      self._cooldownPins[key] = nil
      self._cooldownActiveSkip[key] = true
      return 0, 0
    end
    if duration >= MIN_DURATION then
      local pinStart = startTime
      if pinStart <= 0 then
        pinStart = now
      end
      self._cooldownPins[key] = { start = pinStart, duration = duration }
      return pinStart, duration
    end
    return 0, 0
  end
  if key then
    self._cooldownActiveSkip[key] = nil
  end
  local remaining = startTime + duration - now
  if not key or duration < MIN_DURATION or remaining <= 0 then
    if key then
      self._cooldownPins[key] = nil
    end
    return startTime, duration
  end
  local pin = self._cooldownPins[key]
  if not pin then
    self._cooldownPins[key] = { start = startTime, duration = duration }
    return startTime, duration
  end
  local pinRemaining = pin.start + pin.duration - now
  if pinRemaining <= 0 then
    self._cooldownPins[key] = { start = startTime, duration = duration }
    return startTime, duration
  end
  if duration > pin.duration + 0.5 then
    self._cooldownPins[key] = { start = startTime, duration = duration }
    return startTime, duration
  end
  local apiRemaining = remaining
  if apiRemaining + 0.5 < pinRemaining then
    self._cooldownPins[key] = { start = startTime, duration = duration }
    return startTime, duration
  end
  return pin.start, pin.duration
end

function Addon:TrackedCooldownEntries(now)
  now = now or (GetTime and GetTime()) or 0
  local hiddenKeys = {}
  for _, spell in ipairs(self:CooldownSpellList()) do
    if self:CooldownSpellHidden(spell.spellId) then
      local key = self:CooldownSpellKey(spell.spellId, spell.label)
      if key then
        hiddenKeys[key] = true
      end
    end
  end
  local groups = {}
  local function addSpell(spellId, icon, name, fromList)
    if not spellId then
      return
    end
    local liveName = name or self:SpellInfoName(spellId)
    local key = self:CooldownSpellKey(spellId, liveName)
    if not key or hiddenKeys[key] or self:CooldownSpellHidden(spellId) then
      return
    end
    local liveIcon = self:SpellInfoIcon(spellId, icon)
    local startTime, duration, enabled = spellCooldown(spellId, liveName)
    local existing = groups[key]
    if existing then
      local oldEnd = (existing.start or 0) + (existing.duration or 0)
      local newEnd = (startTime or 0) + (duration or 0)
      if newEnd > oldEnd then
        existing.start = startTime
        existing.duration = duration
      end
      if enabled == 0 then
        existing.enabled = 0
      end
      if liveIcon and not existing.icon then
        existing.icon = liveIcon
      elseif liveIcon and not fromList then
        existing.icon = liveIcon
      end
      if not existing.fromList and type(spellId) == "number" and spellId > (existing.spellId or 0) then
        existing.spellId = spellId
      end
      return
    end
    groups[key] = {
      spellId = spellId,
      icon = liveIcon or icon,
      start = startTime,
      duration = duration,
      enabled = enabled,
      fromList = fromList == true,
    }
  end
  for _, spell in ipairs(self:CooldownSpellList()) do
    addSpell(spell.spellId, spell.icon, spell.label, true)
  end
  for spellId, info in pairs(self:ActionBarSpellIds()) do
    addSpell(spellId, info.icon, nil, false)
  end
  local raw = {}
  for _, entry in pairs(groups) do
    local key = self:CooldownSpellKey(entry.spellId)
    entry.start, entry.duration = self:PinCooldownClock(
      key, entry.start, entry.duration, now, entry.enabled)
    raw[#raw + 1] = entry
  end
  return self:CooldownQueueState(now, raw)
end

local function layoutCfg(self)
  local shipped = self.Defaults and self.Defaults.base and self.Defaults.base.layout
  shipped = shipped and shipped.cooldown or {}
  local live
  if self.ResolveEffective then
    local resolved = self:ResolveEffective()
    live = resolved and resolved.layout and resolved.layout.cooldown
  end
  live = live or {}
  local merged = {
    direction = live.direction or shipped.direction,
    vertical = live.vertical,
    max = live.max ~= nil and live.max or shipped.max,
    buttonSize = live.buttonSize or shipped.buttonSize or SIZE,
    gap = live.gap ~= nil and live.gap or shipped.gap or 4,
  }
  if merged.vertical == nil then
    merged.vertical = shipped.vertical == true
  end
  local host = self.cooldownManager or _G.ShadowUICooldownManager
  local direction = self:CooldownDirection(merged)
  local columns = live.columns
  if host and host._previewColumns then
    columns = host._previewColumns
  elseif columns == nil and live.direction == nil and live.vertical == true then
    columns = 1
  else
    columns = columns or shipped.columns
  end
  merged.columns = columns
  local max = math.max(1, math.min(24, merged.max or DEFAULT_MAX))
  local columns = merged.columns or defaultColumns(direction, max)
  columns = math.max(1, math.min(columns, max))
  return {
    point = live.point or shipped.point or "CENTER",
    relativeTo = live.relativeTo or shipped.relativeTo,
    relativePoint = live.relativePoint or shipped.relativePoint or live.point or "CENTER",
    x = live.x ~= nil and live.x or shipped.x or 0,
    y = live.y ~= nil and live.y or shipped.y or -96,
    scale = live.scale or shipped.scale or 1,
    gap = merged.gap,
    vertical = direction == "up" or direction == "down",
    direction = direction,
    max = max,
    columns = columns,
    enabled = live.enabled ~= false and shipped.enabled ~= false,
    buttonSize = merged.buttonSize,
  }
end

local function ensureHost()
  local host = Addon.cooldownManager or _G.ShadowUICooldownManager
  if host then
    Addon.cooldownManager = host
    return host
  end
  if not CreateFrame then
    return nil
  end
  host = CreateFrame("Frame", "ShadowUICooldownManager", UIParent)
  host:SetSize(36, 36)
  host:SetFrameStrata("MEDIUM")
  if host.SetClipsChildren then
    host:SetClipsChildren(false)
  end
  host.icons = {}
  host.byId = {}
  host.prevIds = {}
  Addon.cooldownManager = host
  return host
end

local function makeIcon(host)
  local icon = CreateFrame("Frame", nil, host)
  icon:SetSize(SIZE, SIZE)
  local tex = icon:CreateTexture(nil, "ARTWORK")
  tex:SetAllPoints()
  icon.texture = tex
  local swipe = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
  swipe:SetAllPoints()
  if swipe.SetDrawSwipe then
    swipe:SetDrawSwipe(true)
  end
  if swipe.SetDrawEdge then
    swipe:SetDrawEdge(true)
  end
  if swipe.SetHideCountdownNumbers then
    swipe:SetHideCountdownNumbers(true)
  end
  icon.swipe = swipe
  Addon:SkinCooldownIcon(icon, SIZE)
  local count = icon:CreateFontString(nil, "OVERLAY")
  local path = _G.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
  count:SetFont(path, 12, "OUTLINE")
  count:SetTextColor(1, 0.82, 0, 1)
  count:SetPoint("CENTER")
  icon.count = count
  host.icons[#host.icons + 1] = icon
  return icon
end

local function acquireIcon(host, spellId)
  host.byId = host.byId or {}
  local icon = host.byId[spellId]
  if icon then
    return icon
  end
  for _, existing in ipairs(host.icons) do
    if existing._free then
      icon = existing
      break
    end
  end
  if not icon then
    icon = makeIcon(host)
  end
  icon._free = false
  icon.spellId = spellId
  icon.anim = nil
  icon.fromX, icon.fromY = nil, nil
  icon.toX, icon.toY = nil, nil
  icon.moveT0 = nil
  icon._x, icon._y = nil, nil
  host.byId[spellId] = icon
  return icon
end

local function placeAt(icon, x, y)
  icon._x, icon._y = x, y
  icon:ClearAllPoints()
  icon:SetPoint("CENTER", icon:GetParent(), "CENTER", x, y)
end

local function fillIcon(icon, entry, size)
  icon:SetSize(size, size)
  if icon.texture and entry.icon then
    icon.texture:SetTexture(entry.icon)
  end
  Addon:SkinCooldownIcon(icon, size)
  if icon.swipe and icon.swipe.SetCooldown then
    if icon._cdStart ~= entry.start or icon._cdDuration ~= entry.duration then
      icon.swipe:SetCooldown(entry.start, entry.duration)
      icon._cdStart = entry.start
      icon._cdDuration = entry.duration
    end
  end
  if icon.count then
    icon.count:SetText(entry.text or "")
  end
end

local function visualPos(self, icon, now)
  local t = now - (icon.moveT0 or now)
  local x = self:CooldownShiftCoord(icon.fromX or icon._x, icon.toX or icon._x, t, SHIFT_DUR)
  local y = self:CooldownShiftCoord(icon.fromY or icon._y, icon.toY or icon._y, t, SHIFT_DUR)
  return x or 0, y or 0
end

function Addon:RefreshCooldownManager()
  local host = self.cooldownManager or _G.ShadowUICooldownManager
  if not host then
    return
  end
  host.byId = host.byId or {}
  local cfg = layoutCfg(self)
  local show = cfg.enabled or self.editMode == true
  if not show then
    host:Hide()
    return
  end
  host:Show()
  local queue = self:CooldownQueueCap(self:TrackedCooldownEntries(), cfg.max)
  if self.editMode == true then
    local placeholders = {}
    for i = 1, cfg.max do
      placeholders[i] = queue[i] or {
        spellId = -i,
        icon = "Interface\\Icons\\INV_Misc_QuestionMark",
        start = 0,
        duration = 0,
        text = "",
      }
    end
    queue = placeholders
  end
  local nextIds = {}
  local nextSet = {}
  for i, entry in ipairs(queue) do
    nextIds[i] = entry.spellId
    nextSet[entry.spellId] = entry
  end
  local now = GetTime and GetTime() or 0
  local diff = self:CooldownQueueDiff(host.prevIds, nextIds)
  for _, id in ipairs(diff.remove) do
    local icon = host.byId[id]
    if icon and not (icon.anim and icon.anim.kind == "pop") then
      local x, y = visualPos(self, icon, now)
      icon.anim = { kind = "pop", t0 = now, fromX = x, fromY = y }
    end
  end
  local liveCount = #queue
  local size = cfg.buttonSize or SIZE
  local grid = self:CooldownGridMetrics(cfg)
  if host.SetSize then
    host:SetSize(grid.width, grid.height)
  end
  host.columns = grid.columns
  for i, entry in ipairs(queue) do
    local icon = acquireIcon(host, entry.spellId)
    fillIcon(icon, entry, size)
    local destX, destY = self:CooldownSlotOffset(i, math.max(1, liveCount), cfg)
    if icon._x == nil then
      icon.fromX, icon.fromY = destX, destY
      icon.toX, icon.toY = destX, destY
      icon.moveT0 = now
      icon.anim = { kind = "insert", t0 = now }
    elseif icon.toX ~= destX or icon.toY ~= destY then
      local visX, visY = visualPos(self, icon, now)
      icon.fromX, icon.fromY = visX, visY
      icon.toX, icon.toY = destX, destY
      icon.moveT0 = now
    end
    local x, y = visualPos(self, icon, now)
    placeAt(icon, x, y)
    local a = 1
    if icon.anim and icon.anim.kind == "insert" then
      a = self:CooldownInsertAlpha(now - icon.anim.t0, INSERT_DUR)
      if a >= 1 then
        icon.anim = nil
      end
    end
    icon:SetAlpha(a)
    icon:Show()
  end
  local done = {}
  for id, icon in pairs(host.byId) do
    if not nextSet[id] then
      local anim = icon.anim
      if not anim or anim.kind ~= "pop" then
        local x, y = visualPos(self, icon, now)
        anim = { kind = "pop", t0 = now, fromX = x, fromY = y }
        icon.anim = anim
      end
      local dt = now - anim.t0
      local a = self:CooldownPopAlpha(dt, POP_DUR)
      local drop = self:CooldownPopDrop(dt, POP_DUR)
      local x, y = anim.fromX, anim.fromY
      if cfg.direction == "up" or cfg.direction == "down" then
        x = anim.fromX + drop
      else
        y = anim.fromY - drop
      end
      placeAt(icon, x, y)
      icon:SetAlpha(a)
      if a <= 0 then
        icon:Hide()
        icon.anim = nil
        icon._free = true
        icon.spellId = nil
        icon._cdStart, icon._cdDuration = nil, nil
        icon._x, icon._y = nil, nil
        icon.fromX, icon.fromY = nil, nil
        icon.toX, icon.toY = nil, nil
        done[#done + 1] = id
      else
        icon:Show()
      end
    end
  end
  for _, id in ipairs(done) do
    host.byId[id] = nil
  end
  host.prevIds = nextIds
end

function Addon:ApplyCooldownManager()
  local host = ensureHost()
  if not host then
    return
  end
  local cfg = layoutCfg(self)
  local grid = self:CooldownGridMetrics(cfg)
  if host.SetScale then
    host:SetScale(cfg.scale or 1)
  end
  if host.SetClipsChildren then
    host:SetClipsChildren(false)
  end
  if self.ParkFrame then
    self:ParkFrame(host, cfg.point, cfg.x, cfg.y, grid.width, grid.height,
      cfg.relativeTo, cfg.relativePoint)
  end
  if cfg.enabled or self.editMode == true then
    host:Show()
  else
    host:Hide()
  end
  if not host._shadowUITick then
    host._shadowUITick = true
    host:SetScript("OnUpdate", function(_, elapsed)
      host._acc = (host._acc or 0) + (elapsed or 0)
      if host._acc < 0.05 then
        return
      end
      host._acc = 0
      Addon:RefreshCooldownManager()
    end)
  end
  if self.RegisterEvent and not self._cooldownEvents then
    self._cooldownEvents = true
    pcall(self.RegisterEvent, self, "SPELL_UPDATE_COOLDOWN", "RefreshCooldownManager")
    pcall(self.RegisterEvent, self, "PLAYER_ENTERING_WORLD", "RefreshCooldownManager")
  end
  self:RefreshCooldownManager()
  if self.RefreshUnitDragOverlays then
    self:RefreshUnitDragOverlays()
  end
end
