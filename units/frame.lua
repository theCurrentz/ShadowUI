--[[
  Purpose: Build a ShadowUI Unit Frame host and its Widget regions from Layout.
           Kind comes from UNIT_WIDGET_KIND. PlaceUnitWidgets sets anchors.
           Live unit paint is RefreshUnitFrame; it is a no-op without unit APIs.
  Deps: ShadowUI:PlaceUnitWidgets(), ShadowUI:UnitFrameLayoutForApply()
  Public: ShadowUI:CreateUnitWidget(), ShadowUI:CreateUnitFrame(),
          ShadowUI:UpdateUnitFrameLayout(), ShadowUI:RefreshUnitFrame()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local HOST_NAME = {
  player = "ShadowUIPlayerFrame",
  target = "ShadowUITargetFrame",
}

local function ensureWidgets(host)
  host.widgets = host.widgets or {}
  return host.widgets
end

local function widgetName(host, id)
  return "ShadowUI" .. tostring(host.unitFrameId or "Unit") .. tostring(id)
end

local function makeTexture(host, id)
  if not host.CreateTexture then
    return nil
  end
  local tex = host:CreateTexture(widgetName(host, id), "ARTWORK")
  return tex
end

local function makeFont(host, id)
  if not host.CreateFontString then
    return nil
  end
  local fs = host:CreateFontString(widgetName(host, id), "OVERLAY", "GameFontNormalSmall")
  if fs.SetJustifyH then
    fs:SetJustifyH("CENTER")
  end
  return fs
end

local function makeFrame(host, kind, id)
  if not CreateFrame then
    return nil
  end
  local name = widgetName(host, id)
  if kind == "statusbar" then
    local ok, bar = pcall(CreateFrame, "StatusBar", name, host)
    if ok and bar then
      return bar
    end
  end
  local ok, frame = pcall(CreateFrame, "Frame", name, host)
  if ok then
    return frame
  end
  return CreateFrame("Frame", name, host)
end

local function widgetTexture(region)
  if region and region.texture then
    return region.texture
  end
  return region
end

function Addon:CreateUnitWidget(host, widgetId)
  if not host or not widgetId then
    return nil
  end
  local widgets = ensureWidgets(host)
  if widgets[widgetId] then
    return widgets[widgetId]
  end
  local kind = (self.UNIT_WIDGET_KIND or {})[widgetId]
  local region
  if kind == "texture" then
    region = makeFrame(host, "frame", widgetId)
    if region and region.CreateTexture then
      local tex = region:CreateTexture(widgetName(host, widgetId) .. "Tex", "ARTWORK")
      if tex and tex.SetAllPoints then
        tex:SetAllPoints(region)
      end
      region.texture = tex
    end
    if not region then
      region = makeTexture(host, widgetId)
    end
  elseif kind == "fontstring" then
    region = makeFont(host, widgetId)
  elseif kind == "statusbar" or kind == "frame" then
    region = makeFrame(host, kind, widgetId)
  end
  if not region then
    return nil
  end
  widgets[widgetId] = region
  region.widgetId = widgetId
  return region
end

local function bindUnit(host, token)
  if host.SetAttribute then
    pcall(host.SetAttribute, host, "unit", token)
    pcall(host.SetAttribute, host, "*type1", "target")
    pcall(host.SetAttribute, host, "*type2", "togglemenu")
  end
  host.unitToken = token
  if host.RegisterForClicks then
    pcall(host.RegisterForClicks, host, "AnyUp")
  end
end

function Addon:CreateUnitFrame(id, token)
  if not CreateFrame or not id then
    return nil
  end
  token = token or (self.UNIT_FRAME_TOKENS and self.UNIT_FRAME_TOKENS[id]) or id
  local name = HOST_NAME[id] or ("ShadowUI" .. id .. "Frame")
  local host
  local ok, frame = pcall(CreateFrame, "Button", name, UIParent, "SecureUnitButtonTemplate")
  if ok and frame then
    host = frame
  else
    host = CreateFrame("Button", name, UIParent)
  end
  host.unitFrameId = id
  ensureWidgets(host)
  bindUnit(host, token)
  if host.SetMovable then
    host:SetMovable(false)
  end
  if host.EnableMouse then
    host:EnableMouse(true)
  end
  return host
end

function Addon:UpdateUnitFrameLayout(host, frameLayout)
  if not host or type(frameLayout) ~= "table" then
    return
  end
  frameLayout = frameLayout or {}
  for _, widgetId in ipairs(self.UNIT_WIDGET_ORDER or {}) do
    local spec = frameLayout[widgetId]
    local region = host.widgets and host.widgets[widgetId]
    if spec and spec.enabled ~= false then
      if not region then
        region = self:CreateUnitWidget(host, widgetId)
      end
      if region and region.Show then
        region:Show()
      end
    elseif region and region.Hide then
      region:Hide()
    end
  end
  if self.PlaceUnitWidgets then
    self:PlaceUnitWidgets(host, frameLayout)
  end
  local rel = _G[frameLayout.relativeTo or "UIParent"] or UIParent
  if host.ClearAllPoints then
    host:ClearAllPoints()
  end
  if host.SetPoint then
    host:SetPoint(
      frameLayout.point or "CENTER",
      rel,
      frameLayout.relativePoint or frameLayout.point or "CENTER",
      frameLayout.x or 0,
      frameLayout.y or 0
    )
  end
end

function Addon:RefreshUnitFrame(host)
  if not host then
    return
  end
  local token = host.unitToken
  if not token then
    return
  end
  local exists = true
  if UnitExists then
    exists = UnitExists(token) == true
  end
  local widgets = host.widgets or {}
  if widgets.name and widgets.name.SetText and UnitName then
    widgets.name:SetText(UnitName(token) or "")
  end
  if widgets.health and widgets.health.SetMinMaxValues and UnitHealth then
    local max = (UnitHealthMax and UnitHealthMax(token)) or 1
    widgets.health:SetMinMaxValues(0, max)
    widgets.health:SetValue(UnitHealth(token) or 0)
  end
  if widgets.power and widgets.power.SetMinMaxValues and UnitPower then
    local max = (UnitPowerMax and UnitPowerMax(token)) or 1
    widgets.power:SetMinMaxValues(0, max)
    widgets.power:SetValue(UnitPower(token) or 0)
  end
  if widgets.portrait and SetPortraitTexture then
    pcall(SetPortraitTexture, widgetTexture(widgets.portrait), token)
  end
  if widgets.level and widgets.level.SetText and UnitLevel then
    local level = UnitLevel(token)
    widgets.level:SetText(level and tostring(level) or "")
  end
  return exists
end
