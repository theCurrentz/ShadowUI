--[[
  Purpose: Paint a subtle class-coloured ring on Target Frame and Focus Frame
  circular portraits. The ring sits behind the portrait so only the rim shows.
  It is 2px larger than the portrait so it stays flush with the circular chrome.
  Fill is one vertical lighting gradient of the class colour.
  The ring is only for player units. Non-player portraits stay full original:
  no ring, no gradient, no wash. Player Frame stays native.
  Deps: UnitClass, UnitIsPlayer, RAID_CLASS_COLORS, ShadowUI:ApplyStatusBarGradient()
  Public: ShadowUI:PortraitClassColor(), ShadowUI:PortraitRingGradient(),
          ShadowUI:SkinPortraitRings()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local CIRCLE = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"
local RING_EXTRA = 2
local CLASS_COLORS = {
  WARRIOR = { 0.78, 0.61, 0.43 },
  PALADIN = { 0.96, 0.55, 0.73 },
  HUNTER = { 0.67, 0.83, 0.45 },
  ROGUE = { 1.00, 0.96, 0.41 },
  PRIEST = { 1.00, 1.00, 1.00 },
  SHAMAN = { 0.00, 0.44, 0.87 },
  MAGE = { 0.41, 0.80, 0.94 },
  WARLOCK = { 0.58, 0.51, 0.79 },
  DRUID = { 1.00, 0.49, 0.04 },
}

local function clamp(n)
  return math.max(0, math.min(1, n))
end

function Addon:PortraitClassColor(classFile)
  if not classFile then
    return nil
  end
  local key = string.upper(classFile)
  local live = RAID_CLASS_COLORS and RAID_CLASS_COLORS[key]
  if live and live.r then
    return live.r, live.g, live.b
  end
  local color = CLASS_COLORS[key]
  if not color then
    return nil
  end
  return color[1], color[2], color[3]
end

function Addon:PortraitRingGradient(r, g, b)
  return { r * 0.42, g * 0.42, b * 0.42, 0.28 },
    { clamp(r * 1.12), clamp(g * 1.12), clamp(b * 1.12), 0.52 }
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
end

local function unitClass(unit)
  if not UnitClass then
    return nil
  end
  local _, classFile = UnitClass(unit)
  return classFile
end

local function isPlayerUnit(unit)
  return UnitIsPlayer and UnitIsPlayer(unit)
end

local function restorePortrait(port)
  if not port then
    return
  end
  if port.SetDesaturated then
    port:SetDesaturated(false)
  end
  if port.SetVertexColor then
    port:SetVertexColor(1, 1, 1, 1)
  end
  if port.SetAlpha then
    port:SetAlpha(1)
  end
end

local function host(frame)
  local ring = frame.shadowUIPortraitRing
  if ring then
    return ring
  end
  if not frame.CreateTexture then
    return nil
  end
  ring = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
  if ring.SetDrawLayer then
    ring:SetDrawLayer("BACKGROUND", -1)
  end
  if ring.SetTexture then
    ring:SetTexture(CIRCLE)
  end
  frame.shadowUIPortraitRing = ring
  return ring
end

local function paintRing(ring, port, r, g, b)
  local w = (port.GetWidth and port:GetWidth()) or 64
  local h = (port.GetHeight and port:GetHeight()) or w
  if ring.SetSize then
    ring:SetSize(w + RING_EXTRA, h + RING_EXTRA)
  end
  if ring.ClearAllPoints then
    ring:ClearAllPoints()
  end
  if ring.SetPoint then
    ring:SetPoint("CENTER", port, "CENTER", 0, 0)
  end
  local from, to = Addon:PortraitRingGradient(r, g, b)
  if Addon.ApplyStatusBarGradient then
    Addon:ApplyStatusBarGradient(ring, "VERTICAL", from, to)
  elseif ring.SetVertexColor then
    ring:SetVertexColor(to[1], to[2], to[3], to[4])
  end
end

local function hideRing(frame)
  local ring = frame.shadowUIPortraitRing
  if ring and ring.Hide then
    ring:Hide()
  end
end

local function isTotPortrait(frame, port)
  local tot = frame.totFrame
  if not tot and frame.GetName then
    tot = _G[frame:GetName() .. "ToT"]
  end
  if not tot or not port then
    return false
  end
  if port == tot then
    return true
  end
  local parent = port.GetParent and port:GetParent()
  return parent == tot
end

local function paint(frame, unit)
  if not frame then
    return
  end
  local port = portrait(frame)
  if isTotPortrait(frame, port) then
    port = nil
  end
  local r, g, b = Addon:PortraitClassColor(unitClass(unit))
  if not isPlayerUnit(unit) or not port or not r then
    hideRing(frame)
    if port and not isPlayerUnit(unit) then
      restorePortrait(port)
    end
    return
  end
  local ring = host(frame)
  if not ring or ring == port then
    return
  end
  paintRing(ring, port, r, g, b)
  if ring.Show then
    ring:Show()
  end
end

local function watchFaction(frame)
  if not frame or frame._shadowUIPortraitFaction or not hooksecurefunc then
    return
  end
  if not frame.CheckFaction then
    return
  end
  frame._shadowUIPortraitFaction = true
  hooksecurefunc(frame, "CheckFaction", function()
    Addon:SkinPortraitRings()
  end)
end

function Addon:SkinPortraitRings()
  if self.RegisterEvent and not self._portraitRingEvents then
    self._portraitRingEvents = true
    pcall(self.RegisterEvent, self, "PLAYER_TARGET_CHANGED", "SkinPortraitRings")
    pcall(self.RegisterEvent, self, "PLAYER_FOCUS_CHANGED", "SkinPortraitRings")
    pcall(self.RegisterEvent, self, "PLAYER_ENTERING_WORLD", "SkinPortraitRings")
  end
  if hooksecurefunc and TargetFrame_CheckFaction and not self._portraitFactionHook then
    self._portraitFactionHook = true
    hooksecurefunc("TargetFrame_CheckFaction", function()
      Addon:SkinPortraitRings()
    end)
  end
  watchFaction(_G.TargetFrame)
  watchFaction(_G.FocusFrame)
  paint(_G.TargetFrame, "target")
  paint(_G.FocusFrame, "focus")
end
