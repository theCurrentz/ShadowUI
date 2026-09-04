--[[
  Purpose: Slow AceGUI options scrolling. AceConfig maps the bar to 0-1000;
           Blizzard UIPanelScrollBarTemplate then steps by half the bar height.
  Deps: AceGUI-3.0, AceConfigDialog-3.0
  Public: ShadowUI.OptionsScrollBarDelta(), ShadowUI:TameOptionsScrollFrame(),
          ShadowUI:TameOptionsSlider(), ShadowUI:InstallOptionsScrollHooks()
]]
local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

-- Pixels of content per mouse-wheel notch or bar arrow click.
-- AceGUI ScrollFrame uses 45px; that skips too much of a long options page.
Addon.OPTIONS_SCROLL_PIXELS = 18

function Addon.OptionsScrollBarDelta(overflowPx, pixels)
  pixels = pixels or Addon.OPTIONS_SCROLL_PIXELS
  if not overflowPx or overflowPx <= 0 then
    return 0
  end
  return 1000 * pixels / overflowPx
end

function Addon:TameOptionsSlider(widget)
  if not widget or widget._suiWheelOff then
    return widget
  end
  widget._suiWheelOff = true
  local slider = widget.slider
  if slider then
    if slider.EnableMouseWheel then
      slider:EnableMouseWheel(false)
    end
    if slider.SetScript then
      slider:SetScript("OnMouseWheel", nil)
    end
  end
  return widget
end

function Addon:TameOptionsScrollFrame(widget)
  if not widget or widget._suiScrollTamed then
    return widget
  end
  widget._suiScrollTamed = true
  local origFix = widget.FixScroll
  local function applyStep(self)
    if not self.scrollbar then
      return
    end
    local view = self.scrollframe and self.scrollframe.GetHeight and self.scrollframe:GetHeight() or 0
    local content = self.content and self.content.GetHeight and self.content:GetHeight() or 0
    local step = Addon.OptionsScrollBarDelta(content - view)
    if step < 1 then
      step = 1
    end
    self.scrollbar.scrollStep = step
  end
  function widget:MoveScroll(value)
    if not self.scrollBarShown or not self.scrollbar then
      return
    end
    local view = self.scrollframe and self.scrollframe.GetHeight and self.scrollframe:GetHeight() or 0
    local content = self.content and self.content.GetHeight and self.content:GetHeight() or 0
    local step = Addon.OptionsScrollBarDelta(content - view)
    if step <= 0 then
      return
    end
    local status = self.status or self.localstatus or {}
    local delta = value < 0 and step or -step
    local nextValue = (status.scrollvalue or 0) + delta
    if nextValue < 0 then
      nextValue = 0
    end
    if nextValue > 1000 then
      nextValue = 1000
    end
    status.scrollvalue = nextValue
    self.scrollbar:SetValue(nextValue)
  end
  function widget:FixScroll(...)
    if origFix then
      origFix(self, ...)
    end
    applyStep(self)
  end
  applyStep(widget)
  return widget
end

function Addon:InstallOptionsScrollHooks()
  if self._optionsScrollHooked then
    return
  end
  local AceGUI = LibStub("AceGUI-3.0", true)
  local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
  if not AceGUI or not AceGUI.Create then
    return
  end
  self._optionsScrollHooked = true
  local origCreate = AceGUI.Create
  function AceGUI:Create(widgetType, ...)
    local widget = origCreate(self, widgetType, ...)
    local open = AceConfigDialog and AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames.ShadowUI
    if open then
      if widgetType == "ScrollFrame" then
        Addon:TameOptionsScrollFrame(widget)
      elseif widgetType == "Slider" then
        Addon:TameOptionsSlider(widget)
      end
    end
    return widget
  end
end

Addon:InstallOptionsScrollHooks()
