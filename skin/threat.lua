--[[
  Purpose: Paint the Threat Bar as a bubble tab on the Target Frame portrait.
  The bubble is one circle that floats on the 45-degree (top-right) portrait edge,
  slightly off the rim so it does not cover the face.
  Fill is one vertical lighting gradient of the threat colour. The fill host
  sits at 50% opacity so the portrait shows through. Classic SetGradient keeps
  ColorMixin RGB and drops texture alpha, so the fill frame is the glass. The
  Darken stroke stays opaque.
  Colour bands: dark glass below 70%, yellow-to-orange at 70-88%,
  orange-to-deep-orange at 88-99%, red-to-deep-red at 100% and above. Percent
  can exceed 100.
  Threat Number sits centred on the bubble at size 9. Native NumericalThreat stays hidden (Blizzard Hide).
  Hide at 0%. Solo still shows the tab.
  A thick circular Darken stroke matches Target Frame chrome. Nested inner
  discs, offset drops, and square Outer Edge stay hidden.
  Aggro Glow is a subtle halo around the Target Frame silhouette (bars +
  circular portrait), not the rectangular bounding box. It matches the native
  flash when that texture exists. Blood red while the target attacks the player.
  Orange at mid-high threat without aggro.
  Deps: UnitDetailedThreatSituation, UnitClassification, ShadowUI:ApplyStatusBarGradient()
  Public: ShadowUI:ThreatCaption(), ShadowUI:ThreatBarColor(), ShadowUI:ThreatBarGradient(),
          ShadowUI:TargetHasAggro(), ShadowUI:AggroGlowColor(), ShadowUI:AggroGlowLayout(),
          ShadowUI:SkinTargetThreat()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local SIZE = 32
local STROKE = 3
local FILL = SIZE - STROKE * 2
local FONT_SIZE = 9
local OVERLAP = 4
local CIRCLE = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
local WARN = 70
local HIGH = 88
local FULL = 100
local YELLOW = { 1.0, 0.85, 0.18 }
local ORANGE = { 1.0, 0.50, 0.06 }
local DEEP_ORANGE = { 0.78, 0.22, 0.00 }
local RED = { 0.95, 0.10, 0.08 }
local DEEP_RED = { 0.45, 0.00, 0.00 }
local BLOOD = { 0.75, 0.0, 0.0 }
local DARKEN = { 0.05, 0.05, 0.05, 1 }
local TAB_ALPHA = 0.5
local GLOW_ALPHA = 0.4
local GLOW_FLASH = "Interface\\TargetingFrame\\UI-TargetingFrame-Flash"
local GLOW_MINUS = "Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash"

function Addon:ThreatCaption(percent)
  if not percent or percent <= 0 then
    return nil
  end
  local n = math.floor(percent + 0.5)
  if n == 0 then
    return nil
  end
  return n .. "%"
end

function Addon:ThreatBarColor(percent)
  local p = percent or 0
  if p >= FULL then
    return RED[1], RED[2], RED[3]
  end
  if p >= HIGH then
    return ORANGE[1], ORANGE[2], ORANGE[3]
  end
  if p >= WARN then
    return YELLOW[1], YELLOW[2], YELLOW[3]
  end
  return 0, 0, 0
end

function Addon:TargetHasAggro(unit)
  if not unit or not UnitDetailedThreatSituation then
    return false
  end
  local isTanking = UnitDetailedThreatSituation("player", unit)
  return not not isTanking
end

function Addon:ThreatBarGradient(percent)
  local p = percent or 0
  if p >= FULL then
    return { DEEP_RED[1], DEEP_RED[2], DEEP_RED[3], 1 },
      { RED[1], RED[2], RED[3], 1 }
  end
  if p >= HIGH then
    return { DEEP_ORANGE[1], DEEP_ORANGE[2], DEEP_ORANGE[3], 1 },
      { ORANGE[1], ORANGE[2], ORANGE[3], 1 }
  end
  if p >= WARN then
    return { ORANGE[1], ORANGE[2], ORANGE[3], 1 },
      { YELLOW[1], YELLOW[2], YELLOW[3], 1 }
  end
  return { 0, 0, 0, 1 }, { 0.08, 0.08, 0.08, 1 }
end

local function threatPercent(unit)
  if not UnitDetailedThreatSituation then
    return nil
  end
  local isTanking, _, scaled, raw = UnitDetailedThreatSituation("player", unit)
  local percent = scaled or raw
  if percent == nil and isTanking then
    return 100
  end
  return percent
end

function Addon:AggroGlowColor(unit)
  if Addon:TargetHasAggro(unit) then
    return BLOOD[1], BLOOD[2], BLOOD[3]
  end
  local percent = threatPercent(unit)
  if percent and percent >= WARN then
    return ORANGE[1], ORANGE[2], ORANGE[3]
  end
  return nil
end

function Addon:AggroGlowLayout(classification)
  if classification == "minus" then
    return GLOW_MINUS, 256, 128, -24, 0, 0, 1, 0, 1
  end
  if classification == "worldboss" or classification == "elite"
      or classification == "rareelite" or classification == "rare" then
    return GLOW_FLASH, 242, 112, -22, 9, 0, 0.9453125, 0.181640625, 0.400390625
  end
  return GLOW_FLASH, 242, 93, -24, 0, 0, 0.9453125, 0, 0.181640625
end

local function muteFlash(frame)
  local name = frame.GetName and frame:GetName()
  local container = frame.TargetFrameContainer
  local native = (container and (container.Flash or container.flash))
    or frame.threatIndicator or frame.flash or (name and _G[name .. "Flash"])
  if native and native ~= frame.shadowUIAggroGlow and native.Hide then
    native:Hide()
  end
end

local function muteNative(frame)
  local name = frame.GetName and frame:GetName()
  local native = frame.threatNumericIndicator or (name and _G[name .. "NumericalThreat"])
  if native and native ~= frame.shadowUIThreat and native.Hide then
    native:Hide()
  end
end

local function portrait(frame)
  local container = frame.TargetFrameContainer
  if container and container.Portrait then
    return container.Portrait
  end
  if frame.portrait then
    return frame.portrait
  end
  local name = frame.GetName and frame:GetName()
  if name then
    local tex = _G[name .. "Portrait"]
    if tex then
      return tex
    end
  end
  return frame
end

local function circle(tab, layer, sub)
  local tex = tab:CreateTexture(nil, layer)
  if tex.SetDrawLayer then
    tex:SetDrawLayer(layer, sub or 0)
  end
  if tex.SetTexture then
    tex:SetTexture(CIRCLE)
  end
  return tex
end

local function hideLayer(tex)
  if tex and tex.Hide then
    tex:Hide()
  end
end

local function paintCircle(tex, host, size, r, g, b, a)
  if not tex then
    return
  end
  if tex.SetSize then
    tex:SetSize(size, size)
  end
  if tex.ClearAllPoints then
    tex:ClearAllPoints()
  end
  if tex.SetPoint then
    tex:SetPoint("CENTER", host, "CENTER", 0, 0)
  end
  if tex.SetVertexColor then
    tex:SetVertexColor(r, g, b, a)
  end
  if tex.SetAlpha then
    tex:SetAlpha(1)
  end
  if tex.Show then
    tex:Show()
  end
end

local function layoutText(fs, tab)
  if not fs then
    return
  end
  if fs.ClearAllPoints then
    fs:ClearAllPoints()
  end
  if fs.SetPoint then
    fs:SetPoint("CENTER", tab, "CENTER", 0, 0)
  end
  if fs.SetWidth then
    fs:SetWidth(SIZE)
  end
  if fs.SetHeight then
    fs:SetHeight(FILL)
  end
  if fs.SetWordWrap then
    fs:SetWordWrap(false)
  end
  if fs.SetMaxLines then
    fs:SetMaxLines(1)
  end
  if fs.SetFont then
    local path = _G.STANDARD_TEXT_FONT
    if fs.GetFont then
      path = fs:GetFont() or path
    end
    if path then
      fs:SetFont(path, FONT_SIZE, "OUTLINE")
    end
  end
end

local function layerFrame(tab, key, extraLevel)
  local layer = tab[key]
  if layer then
    if layer.SetFrameLevel and tab.GetFrameLevel then
      layer:SetFrameLevel(tab:GetFrameLevel() + extraLevel)
    end
    return layer
  end
  if not CreateFrame then
    return nil
  end
  layer = CreateFrame("Frame", nil, tab)
  if layer.SetFrameLevel and tab.GetFrameLevel then
    layer:SetFrameLevel(tab:GetFrameLevel() + extraLevel)
  end
  if layer.EnableMouse then
    layer:EnableMouse(false)
  end
  tab[key] = layer
  return layer
end

local function raiseAbovePortrait(tab, frame)
  if not tab or not tab.SetFrameLevel or not frame then
    return
  end
  local level = (frame.GetFrameLevel and frame:GetFrameLevel()) or 0
  local port = portrait(frame)
  local parent = port and port.GetParent and port:GetParent()
  if parent and parent.GetFrameLevel then
    level = math.max(level, parent:GetFrameLevel() or 0)
  end
  tab:SetFrameLevel(level + 8)
end

local function ensureText(tab, textHost)
  if tab.text or tab.font then
    return tab.text or tab.font
  end
  if not textHost or not textHost.CreateFontString then
    return nil
  end
  local fs = textHost:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  if fs.SetJustifyH then
    fs:SetJustifyH("CENTER")
  end
  if fs.SetJustifyV then
    fs:SetJustifyV("MIDDLE")
  end
  tab.text = fs
  tab.font = fs
  return fs
end

local function ensureLayers(tab)
  hideLayer(tab.shadowUIOuter)
  hideLayer(tab.drop)
  hideLayer(tab.inner)
  if not tab.rim then
    tab.rim = circle(tab, "BACKGROUND", 0)
  end
  local fillHost = layerFrame(tab, "fillHost", 0)
  if fillHost then
    if fillHost.SetSize then
      fillHost:SetSize(FILL, FILL)
    end
    if fillHost.ClearAllPoints then
      fillHost:ClearAllPoints()
    end
    if fillHost.SetPoint then
      fillHost:SetPoint("CENTER", tab, "CENTER", 0, 0)
    end
    if fillHost.SetAlpha then
      fillHost:SetAlpha(TAB_ALPHA)
    end
  end
  if not tab.fill then
    tab.fill = circle(fillHost or tab, "ARTWORK", 0)
  end
  local textHost = layerFrame(tab, "textHost", 2)
  if textHost then
    if textHost.SetAllPoints then
      textHost:SetAllPoints(tab)
    end
    if textHost.SetAlpha then
      textHost:SetAlpha(1)
    end
  end
  paintCircle(tab.rim, tab, SIZE, DARKEN[1], DARKEN[2], DARKEN[3], DARKEN[4])
  paintCircle(tab.fill, fillHost or tab, FILL, DARKEN[1], DARKEN[2], DARKEN[3], DARKEN[4])
  layoutText(ensureText(tab, textHost or tab), tab)
end

local function host(frame)
  if not frame then
    return nil
  end
  muteNative(frame)
  local tab = frame.shadowUIThreat
  if tab then
    raiseAbovePortrait(tab, frame)
    ensureLayers(tab)
    return tab
  end
  if not CreateFrame then
    return nil
  end
  tab = CreateFrame("Frame", nil, frame)
  if tab.SetSize then
    tab:SetSize(SIZE, SIZE)
  end
  raiseAbovePortrait(tab, frame)
  if tab.SetScript then
    tab:SetScript("OnUpdate", function()
      Addon:SkinTargetThreat()
    end)
  end
  frame.shadowUIThreat = tab
  ensureLayers(tab)
  return tab
end

local function place(tab, frame)
  if not tab or not tab.SetPoint or not frame then
    return
  end
  local port = portrait(frame)
  if tab.ClearAllPoints then
    tab:ClearAllPoints()
  end
  tab:SetPoint("CENTER", port, "TOPRIGHT", -OVERLAP, -OVERLAP)
  if tab.SetSize then
    tab:SetSize(SIZE, SIZE)
  end
end

local function setText(tab, text)
  local fs = tab.text or tab.font
  if fs and fs.SetText then
    fs:SetText(text)
  elseif tab.SetText then
    tab:SetText(text)
  end
end

local function paintFill(tab, percent)
  local fill = tab.fill
  if not fill then
    return
  end
  hideLayer(tab.inner)
  hideLayer(tab.drop)
  local from, to = Addon:ThreatBarGradient(percent)
  if fill.SetSize then
    fill:SetSize(FILL, FILL)
  end
  if Addon.ApplyStatusBarGradient then
    Addon:ApplyStatusBarGradient(fill, "VERTICAL", from, to)
  elseif fill.SetVertexColor then
    fill:SetVertexColor(to[1], to[2], to[3], to[4])
  end
  if fill.SetAlpha then
    fill:SetAlpha(1)
  end
  if tab.fillHost and tab.fillHost.SetAlpha then
    tab.fillHost:SetAlpha(TAB_ALPHA)
  end
end

local function paint(frame, unit)
  local tab = host(frame)
  if not tab then
    return
  end
  place(tab, frame)
  local percent = threatPercent(unit)
  local text = Addon:ThreatCaption(percent)
  if not text then
    if tab.Hide then
      tab:Hide()
    end
    return
  end
  setText(tab, text)
  paintFill(tab, percent)
  if tab.Show then
    tab:Show()
  end
end

local function glowParent(frame)
  return frame.TargetFrameContainer or frame
end

local function nativeFlash(frame)
  local container = frame.TargetFrameContainer
  if container then
    return container.Flash or container.flash or container.threatIndicator
  end
  local name = frame.GetName and frame:GetName()
  return frame.threatIndicator or frame.flash or (name and _G[name .. "Flash"])
end

local function placeGlow(glow, frame)
  local unit = frame.unit or "target"
  local classification = UnitClassification and UnitClassification(unit)
  local path, w, h, x, y, u0, u1, v0, v1 = Addon:AggroGlowLayout(classification)
  local flash = nativeFlash(frame)
  local parent = glowParent(frame)
  if glow.ClearAllPoints then
    glow:ClearAllPoints()
  end
  if flash and glow.SetAllPoints then
    glow:SetAllPoints(flash)
  else
    if glow.SetPoint then
      glow:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    end
    if glow.SetSize then
      glow:SetSize(w, h)
    end
  end
  local fill = glow.fill
  if fill and fill.SetTexture then
    fill:SetTexture(path)
  end
  if fill and fill.SetTexCoord then
    fill:SetTexCoord(u0, u1, v0, v1)
  end
end

local function glowHost(frame)
  local glow = frame.shadowUIAggroGlow
  if glow then
    return glow
  end
  if not CreateFrame then
    return nil
  end
  glow = CreateFrame("Frame", nil, frame)
  if glow.SetFrameLevel and frame.GetFrameLevel then
    glow:SetFrameLevel(frame:GetFrameLevel())
  end
  if glow.EnableMouse then
    glow:EnableMouse(false)
  end
  local fill = glow:CreateTexture(nil, "BACKGROUND")
  if fill.SetAllPoints then
    fill:SetAllPoints(glow)
  end
  if fill.SetBlendMode then
    fill:SetBlendMode("ADD")
  end
  glow.fill = fill
  frame.shadowUIAggroGlow = glow
  return glow
end

local function paintGlowHue(glow, r, g, b)
  local fill = glow.fill
  if fill and fill.SetVertexColor then
    fill:SetVertexColor(r, g, b, GLOW_ALPHA)
  end
end

local function paintAggroGlow(frame, unit)
  if not frame or frame ~= _G.TargetFrame then
    return
  end
  muteFlash(frame)
  local glow = glowHost(frame)
  if not glow then
    return
  end
  local r, g, b = Addon:AggroGlowColor(unit)
  if not r then
    if glow.Hide then
      glow:Hide()
    end
    return
  end
  placeGlow(glow, frame)
  paintGlowHue(glow, r, g, b)
  if glow.Show then
    glow:Show()
  end
end

function Addon:SkinTargetThreat()
  if self.RegisterEvent and not self._threatEvents then
    self._threatEvents = true
    pcall(self.RegisterEvent, self, "PLAYER_TARGET_CHANGED", "SkinTargetThreat")
    pcall(self.RegisterEvent, self, "UNIT_THREAT_SITUATION_UPDATE", "SkinTargetThreat")
    pcall(self.RegisterEvent, self, "UNIT_THREAT_LIST_UPDATE", "SkinTargetThreat")
  end
  paint(_G.TargetFrame, "target")
  paintAggroGlow(_G.TargetFrame, "target")
end
