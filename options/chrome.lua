--[[
  Purpose: Darken the /shadowui AceConfigDialog host and AceGUI controls.
           Drops DialogBox parchment for ChatFrame fill plus Darken colours.
  Deps: AceGUI-3.0, AceConfigDialog-3.0, ShadowUI Darken colours
  Public: ShadowUI:SkinOptionsPane(), ShadowUI:SkinOptionsHost(),
          ShadowUI:SkinOptionsWidget(), ShadowUI:InstallOptionsChromeHooks()
]]
local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local unpack = unpack or table.unpack

Addon.OPTIONS_PANE_BACKDROP = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local function black()
  return Addon.DARKEN_BLACK or { 0.05, 0.05, 0.05 }
end

local function grey()
  return Addon.DARKEN_GREY or { 0.35, 0.35, 0.35 }
end

local function isDialogArt(path)
  if path == 131080 then
    return true
  end
  if type(path) == "string" and path:find("DialogFrame", 1, true) then
    return true
  end
  return false
end

local function hideDialogArt(region)
  if not region then
    return
  end
  local path = region.GetTexture and region:GetTexture()
  if isDialogArt(path) and region.Hide then
    region:Hide()
  end
end

local function tint(region, color)
  if not region or not color then
    return
  end
  if Addon.LockVertex then
    Addon:LockVertex(region, color)
    return
  end
  if region.SetVertexColor then
    region:SetVertexColor(color[1], color[2], color[3])
  end
end

local function tintFrame(frame, color)
  if not frame then
    return
  end
  if Addon.DarkenFrameRegions then
    Addon:DarkenFrameRegions(frame, color)
    return
  end
  if not frame.GetRegions then
    return
  end
  for _, region in ipairs({ frame:GetRegions() }) do
    tint(region, color)
  end
end

function Addon:SkinOptionsPane(frame)
  if not frame then
    return frame
  end
  if frame.SetBackdrop then
    frame:SetBackdrop(self.OPTIONS_PANE_BACKDROP)
  end
  local fill = black()
  local edge = grey()
  if frame.SetBackdropColor then
    frame:SetBackdropColor(fill[1], fill[2], fill[3], 0.94)
  end
  if frame.SetBackdropBorderColor then
    frame:SetBackdropBorderColor(edge[1], edge[2], edge[3], 1)
  end
  return frame
end

function Addon:SkinOptionsHost(widget)
  if not widget then
    return widget
  end
  local frame = widget.frame or widget
  self:SkinOptionsPane(frame)
  if widget.titlebg and widget.titlebg.Hide then
    widget.titlebg:Hide()
  end
  if frame.GetRegions then
    for _, region in ipairs({ frame:GetRegions() }) do
      hideDialogArt(region)
    end
  end
  if frame.GetChildren then
    for _, child in ipairs({ frame:GetChildren() }) do
      tintFrame(child, grey())
    end
  end
  if self.ApplyOuterChrome then
    self:ApplyOuterChrome(frame)
  end
  widget._suiOptionsChrome = true
  return widget
end

function Addon:SkinOptionsWidget(widget, widgetType)
  if not widget then
    return widget
  end
  widgetType = widgetType or widget.type
  if widgetType == "Frame" then
    return self:SkinOptionsHost(widget)
  end
  if widgetType == "TreeGroup" then
    self:SkinOptionsPane(widget.treeframe)
    self:SkinOptionsPane(widget.border)
  elseif widgetType == "InlineGroup" then
    local content = widget.content
    local border = content and content.GetParent and content:GetParent()
    self:SkinOptionsPane(border or widget.frame)
  elseif widgetType == "Dropdown-Pullout" then
    self:SkinOptionsPane(widget.frame)
  end
  if widget.checkbg then
    tint(widget.checkbg, grey())
  end
  tintFrame(widget.frame, grey())
  widget._suiOptionsChrome = true
  return widget
end

function Addon:InstallOptionsChromeHooks()
  if self._optionsChromeHooked then
    return
  end
  local AceGUI = LibStub("AceGUI-3.0", true)
  local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
  if not AceGUI or not AceGUI.Create then
    return
  end
  self._optionsChromeHooked = true
  local origCreate = AceGUI.Create
  function AceGUI:Create(widgetType, ...)
    local widget = origCreate(self, widgetType, ...)
    local open = AceConfigDialog and AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames.ShadowUI
    if open and widget then
      Addon:SkinOptionsWidget(widget, widgetType)
    end
    return widget
  end
  if AceConfigDialog and AceConfigDialog.Open then
    local origOpen = AceConfigDialog.Open
    function AceConfigDialog:Open(appName, ...)
      origOpen(self, appName, ...)
      if appName == "ShadowUI" then
        local host = self.OpenFrames and self.OpenFrames.ShadowUI
        if host then
          Addon:SkinOptionsHost(host)
        end
      end
    end
  end
end

Addon:InstallOptionsChromeHooks()
