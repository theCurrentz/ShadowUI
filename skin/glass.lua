--[[
  Purpose: Layered translucent chrome approximating Apple liquid glass.
  Deps: ShadowUI addon table, optional ApplyStatusBarGradient
  Public: ShadowUI:GetTheme(), ShadowUI:SetTheme(), ShadowUI:ApplyGlassPanel(),
          ShadowUI:ClearGlassPanel()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local FILL = { 0.14, 0.16, 0.2, 0.42 }
local SHEEN_FROM = { 1, 1, 1, 0.28 }
local SHEEN_TO = { 1, 1, 1, 0 }
local RIM_LIT = { 1, 1, 1, 0.42 }
local RIM_DIM = { 1, 1, 1, 0.16 }
local KEYS = { "glassFill", "glassSheen", "glassRimT", "glassRimB", "glassRimL", "glassRimR" }

local function layer(frame, key, drawLayer, subLevel)
  local texture = frame[key]
  if not texture then
    texture = frame:CreateTexture(nil, drawLayer, nil, subLevel)
    frame[key] = texture
  end
  return texture
end

local function paint(texture, color)
  texture:SetColorTexture(color[1], color[2], color[3], color[4])
  texture:Show()
end

function Addon:GetTheme()
  local char = self.GetCharDB and self:GetCharDB()
  return (char and char.theme == "glass") and "glass" or "matte"
end

function Addon:SetTheme(name)
  name = type(name) == "string" and name:match("^%s*(.-)%s*$"):lower() or ""
  if name ~= "glass" and name ~= "matte" then
    self:Print("Theme must be glass or matte.")
    return false
  end
  self:GetCharDB().theme = name
  self:ApplySkins()
  return true
end

function Addon:ClearGlassPanel(frame)
  if not frame then
    return
  end
  for _, key in ipairs(KEYS) do
    local texture = frame[key]
    if texture then
      texture:Hide()
    end
  end
end

function Addon:ApplyGlassPanel(frame)
  if not frame or not frame.CreateTexture then
    return
  end
  if frame.SetBackdropColor then
    frame:SetBackdropColor(0, 0, 0, 0)
  end
  if frame.shadowUIBackdrop then
    frame.shadowUIBackdrop:Hide()
  end

  local fill = layer(frame, "glassFill", "BACKGROUND", -7)
  fill:ClearAllPoints()
  fill:SetAllPoints(frame)
  paint(fill, FILL)

  local sheen = layer(frame, "glassSheen", "BORDER", 1)
  sheen:ClearAllPoints()
  sheen:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
  sheen:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
  sheen:SetHeight(7)
  if sheen.SetBlendMode then
    sheen:SetBlendMode("ADD")
  end
  paint(sheen, SHEEN_FROM)
  if self.ApplyStatusBarGradient then
    self:ApplyStatusBarGradient(sheen, "VERTICAL", SHEEN_FROM, SHEEN_TO)
  end

  local top = layer(frame, "glassRimT", "OVERLAY", 0)
  top:ClearAllPoints()
  top:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  top:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  top:SetHeight(1)
  paint(top, RIM_LIT)

  local left = layer(frame, "glassRimL", "OVERLAY", 0)
  left:ClearAllPoints()
  left:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
  left:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  left:SetWidth(1)
  paint(left, RIM_LIT)

  local bottom = layer(frame, "glassRimB", "OVERLAY", 0)
  bottom:ClearAllPoints()
  bottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  bottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  bottom:SetHeight(1)
  paint(bottom, RIM_DIM)

  local right = layer(frame, "glassRimR", "OVERLAY", 0)
  right:ClearAllPoints()
  right:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  right:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  right:SetWidth(1)
  paint(right, RIM_DIM)
end
