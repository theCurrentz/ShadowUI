--[[
  Purpose: Combo points sit above the Target Frame portrait, not on it.
           Five pips always show. Empty pips are a hollow ring (inner
           transparent, 50% black border). Filled pips are a red dartboard
           (circle in a circle) with a short ADD rim glow. A newly filled
           point pops in on the Chrome bezier. At five
           points the row grows slightly on that same ease. Native ComboFrame
           and ComboPointPlayerFrame stay hidden.
  Deps: GetComboPoints, ShadowUI:Ease()
  Public: ShadowUI:ComboPointPopScale(), ShadowUI:ComboPointFullScale(),
          ShadowUI:TickComboPointPop(), ShadowUI:SkinComboPoints()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local MAX = 5
local SIZE = 14
local GAP = 4
local ABOVE = 12
local RIGHT = 6
local FILL_INSET = 4
local CORE_INSET = 8
local GLOW_PAD = 4
local POP = 1.35
local POP_DUR = 0.16
local FULL = 1.16
local FULL_DUR = 0.24
local CIRCLE = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
local RING = "Interface\\AddOns\\ShadowUI\\media\\outer_shadow_circle"
local RED_FROM = { 0.42, 0.00, 0.00, 1 }
local RED_TO = { 1.0, 0.16, 0.10, 1 }
local CORE_FROM = { 0.85, 0.08, 0.04, 1 }
local CORE_TO = { 1.0, 0.42, 0.22, 1 }
local RIM_FILL = { 0.18, 0.00, 0.00, 1 }
local GLOW = { 1.0, 0.16, 0.06, 0.2 }
local RIM_A = 0.5

local function easeT(addon, t)
  if addon.Ease then
    return addon:Ease(t)
  end
  return t
end

function Addon:ComboPointPopScale(t)
  if t <= 0 then
    return POP
  end
  if t >= 1 then
    return 1
  end
  return POP - (POP - 1) * easeT(self, t)
end

function Addon:ComboPointFullScale(t)
  if t <= 0 then
    return 1
  end
  if t >= 1 then
    return FULL
  end
  return 1 + (FULL - 1) * easeT(self, t)
end

local function hideStay(region)
  if not region then
    return
  end
  if region.Hide then
    region:Hide()
  end
  if region._shadowUIHideStay then
    return
  end
  region._shadowUIHideStay = true
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

local function muteNative()
  hideStay(_G.ComboFrame)
  hideStay(_G.ComboPointPlayerFrame)
  for i = 1, MAX do
    hideStay(_G["ComboPoint" .. i])
  end
end

local function portrait(frame)
  if not frame then
    return nil
  end
  if Addon.CrowdControlPortraitRegion then
    local port = Addon:CrowdControlPortraitRegion(frame)
    if port then
      return port
    end
  end
  local container = frame.TargetFrameContainer
  if container and (container.Portrait or container.portrait) then
    return container.Portrait or container.portrait
  end
  if frame.portrait then
    return frame.portrait
  end
  local name = frame.GetName and frame:GetName()
  return name and _G[name .. "Portrait"]
end

local function comboClass()
  if not UnitClass then
    return true
  end
  local _, class = UnitClass("player")
  return class == "ROGUE" or class == "DRUID"
end

local function colorTex(tex, from, to)
  if not tex then
    return
  end
  if Addon.ApplyStatusBarGradient then
    Addon:ApplyStatusBarGradient(tex, "VERTICAL", from, to)
  elseif tex.SetVertexColor then
    tex:SetVertexColor(to[1], to[2], to[3], to[4])
  end
end

local function paintPip(pip, filled)
  local visual = pip.visual
  if not visual then
    return
  end
  local rim = pip.rim
  local fill = pip.fill
  local core = pip.core
  local glow = pip.glow
  if filled then
    if rim then
      if rim.SetTexture then
        rim:SetTexture(CIRCLE)
      end
      if rim.SetVertexColor then
        rim:SetVertexColor(RIM_FILL[1], RIM_FILL[2], RIM_FILL[3], RIM_FILL[4])
      end
      if rim.Show then
        rim:Show()
      end
    end
    colorTex(fill, RED_FROM, RED_TO)
    if fill and fill.Show then
      fill:Show()
    end
    colorTex(core, CORE_FROM, CORE_TO)
    if core and core.Show then
      core:Show()
    end
    if glow then
      if glow.SetVertexColor then
        glow:SetVertexColor(GLOW[1], GLOW[2], GLOW[3], GLOW[4])
      end
      if glow.Show then
        glow:Show()
      end
    end
  else
    if rim then
      if rim.SetTexture then
        rim:SetTexture(RING)
      end
      if rim.SetVertexColor then
        rim:SetVertexColor(0, 0, 0, RIM_A)
      end
      if rim.Show then
        rim:Show()
      end
    end
    if fill and fill.Hide then
      fill:Hide()
    end
    if core and core.Hide then
      core:Hide()
    end
    if glow and glow.Hide then
      glow:Hide()
    end
  end
end

local function ensureVisual(pip)
  if pip.visual then
    return pip.visual
  end
  if not CreateFrame then
    return nil
  end
  local visual = CreateFrame("Frame", nil, pip)
  if visual.SetSize then
    visual:SetSize(SIZE, SIZE)
  end
  if visual.SetPoint then
    visual:SetPoint("CENTER", pip, "CENTER", 0, 0)
  end
  if visual.EnableMouse then
    visual:EnableMouse(false)
  end
  pip.visual = visual

  local glow = visual:CreateTexture(nil, "BACKGROUND")
  pip.glow = glow
  if glow.SetTexture then
    glow:SetTexture(RING)
  end
  if glow.SetBlendMode then
    glow:SetBlendMode("ADD")
  end
  if glow.SetDrawLayer then
    glow:SetDrawLayer("BACKGROUND", -1)
  end
  if glow.SetSize then
    glow:SetSize(SIZE + GLOW_PAD, SIZE + GLOW_PAD)
  end
  if glow.ClearAllPoints then
    glow:ClearAllPoints()
  end
  if glow.SetPoint then
    glow:SetPoint("CENTER", visual, "CENTER", 0, 0)
  end
  if glow.Hide then
    glow:Hide()
  end

  local rim = visual:CreateTexture(nil, "BACKGROUND")
  pip.rim = rim
  if rim.SetTexture then
    rim:SetTexture(RING)
  end
  if rim.SetAllPoints then
    rim:SetAllPoints(visual)
  end

  local fill = visual:CreateTexture(nil, "ARTWORK")
  pip.fill = fill
  if fill.SetTexture then
    fill:SetTexture(CIRCLE)
  end
  if fill.SetSize then
    fill:SetSize(SIZE - FILL_INSET, SIZE - FILL_INSET)
  end
  if fill.ClearAllPoints then
    fill:ClearAllPoints()
  end
  if fill.SetPoint then
    fill:SetPoint("CENTER", visual, "CENTER", 0, 0)
  end
  if fill.Hide then
    fill:Hide()
  end

  local core = visual:CreateTexture(nil, "OVERLAY")
  pip.core = core
  if core.SetTexture then
    core:SetTexture(CIRCLE)
  end
  if core.SetSize then
    core:SetSize(SIZE - CORE_INSET, SIZE - CORE_INSET)
  end
  if core.ClearAllPoints then
    core:ClearAllPoints()
  end
  if core.SetPoint then
    core:SetPoint("CENTER", visual, "CENTER", 0, 0)
  end
  if core.Hide then
    core:Hide()
  end
  return visual
end

local function ensurePip(host, index)
  local pip = host.pips[index]
  if pip then
    ensureVisual(pip)
    return pip
  end
  if not CreateFrame then
    return nil
  end
  pip = CreateFrame("Frame", nil, host)
  if pip.SetSize then
    pip:SetSize(SIZE, SIZE)
  end
  if pip.SetPoint then
    pip:SetPoint("LEFT", host, "LEFT", (index - 1) * (SIZE + GAP), 0)
  end
  if pip.EnableMouse then
    pip:EnableMouse(false)
  end
  host.pips[index] = pip
  ensureVisual(pip)
  return pip
end

local function ensureHost(frame)
  local host = frame.shadowUICombo
  if host then
    return host
  end
  if not CreateFrame then
    return nil
  end
  host = CreateFrame("Frame", nil, frame)
  host.pips = {}
  if host.SetSize then
    host:SetSize(MAX * SIZE + (MAX - 1) * GAP, SIZE)
  end
  if host.SetFrameLevel and frame.GetFrameLevel then
    host:SetFrameLevel(frame:GetFrameLevel() + 6)
  end
  if host.EnableMouse then
    host:EnableMouse(false)
  end
  if host.SetScript then
    host:SetScript("OnUpdate", function(self)
      Addon:TickComboPointPop(self)
    end)
  end
  for i = 1, MAX do
    ensurePip(host, i)
  end
  frame.shadowUICombo = host
  return host
end

local function pipPopScale(addon, pip, now)
  if not pip or not pip._shadowUIPopStart then
    return 1
  end
  local t = (now - pip._shadowUIPopStart) / POP_DUR
  if t >= 1 then
    pip._shadowUIPopStart = nil
    return 1
  end
  return addon:ComboPointPopScale(t)
end

local function hostFullScale(addon, host, now)
  if not host or not host._shadowUIFullStart then
    return 1
  end
  local t = (now - host._shadowUIFullStart) / FULL_DUR
  return addon:ComboPointFullScale(t)
end

local function applyPipScale(addon, host, now)
  local full = hostFullScale(addon, host, now)
  for i = 1, MAX do
    local pip = host.pips[i]
    local visual = pip and pip.visual
    if visual and visual.SetScale then
      visual:SetScale(pipPopScale(addon, pip, now) * full)
    end
  end
end

function Addon:TickComboPointPop(host)
  if not host or not host.pips then
    return
  end
  applyPipScale(self, host, GetTime and GetTime() or 0)
end

local function comboCount()
  if not GetComboPoints then
    return 0
  end
  local n = GetComboPoints("player", "target") or 0
  if n < 0 then
    return 0
  end
  if n > MAX then
    return MAX
  end
  return n
end

local function eventIsValid(event)
  if C_EventUtils and C_EventUtils.IsEventValid then
    return C_EventUtils.IsEventValid(event)
  end
  return true
end

local function startEvents(addon)
  if addon._comboEvents or not addon.RegisterEvent then
    return
  end
  addon._comboEvents = true
  -- AceEvent queues RegisterEvent during Fire; pcall does not cover OnUsed.
  -- Era and TBC fire PLAYER_COMBO_POINTS. UNIT_COMBO_POINTS is Wrath and errors.
  for _, event in ipairs({
    "PLAYER_TARGET_CHANGED",
    "PLAYER_COMBO_POINTS",
    "PLAYER_ENTERING_WORLD",
  }) do
    if eventIsValid(event) then
      pcall(addon.RegisterEvent, addon, event, "SkinComboPoints")
    end
  end
end

function Addon:SkinComboPoints()
  startEvents(self)
  if hooksecurefunc and ComboFrame_Update and not self._comboFrameHook then
    self._comboFrameHook = true
    hooksecurefunc("ComboFrame_Update", function()
      Addon:SkinComboPoints()
    end)
  end
  muteNative()
  local frame = _G.TargetFrame
  if not frame then
    return
  end
  local host = ensureHost(frame)
  if not host then
    return
  end
  local port = portrait(frame)
  if host.ClearAllPoints then
    host:ClearAllPoints()
  end
  if host.SetPoint and port then
    host:SetPoint("BOTTOM", port, "TOP", RIGHT, ABOVE)
  end
  if not comboClass() then
    if host.Hide then
      host:Hide()
    end
    return
  end
  local n = comboCount()
  local prev = host._shadowUIComboCount or 0
  local now = GetTime and GetTime() or 0
  for i = 1, MAX do
    local pip = ensurePip(host, i)
    if pip then
      if pip.Show then
        pip:Show()
      end
      pip.shown = true
      paintPip(pip, i <= n)
      if i <= n and i > prev then
        pip._shadowUIPopStart = now
      elseif i > n then
        pip._shadowUIPopStart = nil
      end
    end
  end
  if n == MAX then
    if prev < MAX then
      host._shadowUIFullStart = now
    end
  else
    host._shadowUIFullStart = nil
  end
  host._shadowUIComboCount = n
  applyPipScale(self, host, now)
  if host.Show then
    host:Show()
  end
end
