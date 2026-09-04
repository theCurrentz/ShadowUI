-- /shadowui AceGUI scroll steps a short pixel distance, not half the bar height.
-- Range sliders in the panel do not eat the mouse wheel.
-- Run: lua tests/options_scroll_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
local created = {}
local acegui = {
  Create = function(_, widgetType)
    local widget = { type = widgetType }
    if widgetType == "ScrollFrame" then
      widget.FixScroll = function() end
      widget.scrollbar = {}
      widget.scrollframe = { GetHeight = function() return 400 end }
      widget.content = { GetHeight = function() return 1400 end }
    elseif widgetType == "Slider" then
      widget.slider = {
        EnableMouseWheel = function(self, on)
          self.wheel = on
        end,
        SetScript = function(self, name, fn)
          self[name] = fn
        end,
        OnMouseWheel = function() end,
        wheel = true,
      }
    end
    created[#created + 1] = widget
    return widget
  end,
}
local dialog = { OpenFrames = { ShadowUI = {} } }
_G.LibStub = function(name, silent)
  if name == "AceAddon-3.0" then
    return { GetAddon = function() return Addon end }
  end
  if name == "AceGUI-3.0" then
    return acegui
  end
  if name == "AceConfigDialog-3.0" then
    return dialog
  end
  if silent then
    return nil
  end
  error("unexpected LibStub " .. tostring(name))
end

assert(loadfile(root .. "options/scroll.lua"))()

assert(Addon.OPTIONS_SCROLL_PIXELS == 18, "wheel step is 18px of content")
assert(Addon.OptionsScrollBarDelta(0) == 0, "no overflow means no step")
assert(Addon.OptionsScrollBarDelta(-10) == 0, "negative overflow means no step")
assert(Addon.OptionsScrollBarDelta(1000, 18) == 18, "1000px overflow maps 18px to 18 of 1000")
assert(math.abs(Addon.OptionsScrollBarDelta(2000, 18) - 9) < 0.0001, "longer page uses a smaller bar delta")
assert(Addon.OptionsScrollBarDelta(1000, 45) == 45, "AceGUI 45px step is larger than ShadowUI")

local setValue
local widget = {
  scrollBarShown = true,
  status = { scrollvalue = 0 },
  scrollbar = {
    SetValue = function(_, value)
      setValue = value
    end,
  },
  scrollframe = { GetHeight = function() return 400 end },
  content = { GetHeight = function() return 1400 end },
  FixScroll = function(self)
    self.fixed = true
  end,
}
Addon:TameOptionsScrollFrame(widget)
assert(math.abs(widget.scrollbar.scrollStep - 18) < 0.0001, "bar arrow step matches 18px of 1000px overflow")
widget:MoveScroll(-1)
assert(math.abs(setValue - 18) < 0.0001, "wheel down moves 18px, not AceGUI 45px")
widget.status.scrollvalue = 18
widget:MoveScroll(1)
assert(math.abs(setValue - 0) < 0.0001, "wheel up moves back 18px")
widget.status.scrollvalue = 0
widget.status.scrollvalue = 0
widget:MoveScroll(-1)
widget:MoveScroll(-1)
assert(math.abs(setValue - 36) < 0.0001, "two notches stay under AceGUI's single 45px jump")
widget:FixScroll()
assert(widget.fixed, "FixScroll still runs AceGUI layout")
assert(Addon:TameOptionsScrollFrame(widget) == widget, "tame is idempotent")

local slider = {
  slider = {
    EnableMouseWheel = function(self, on)
      self.wheel = on
    end,
    SetScript = function(self, name, fn)
      self[name] = fn
    end,
    OnMouseWheel = function() end,
    wheel = true,
  },
}
Addon:TameOptionsSlider(slider)
assert(slider.slider.wheel == false, "range slider does not capture the wheel")
assert(slider.slider.OnMouseWheel == nil, "range slider wheel script is cleared")

created = {}
local hookedScroll = acegui:Create("ScrollFrame")
assert(hookedScroll._suiScrollTamed, "ScrollFrame created while options are open is tamed")
local hookedSlider = acegui:Create("Slider")
assert(hookedSlider._suiWheelOff, "Slider created while options are open drops wheel")
dialog.OpenFrames.ShadowUI = nil
local other = acegui:Create("ScrollFrame")
assert(not other._suiScrollTamed, "ScrollFrame outside ShadowUI options is not tamed")

local toc = assert(io.open(root .. "ShadowUI.toc", "r")):read("*a")
assert(toc:find("options\\scroll.lua", 1, true), "Era TOC loads options scroll")
local tocTbc = assert(io.open(root .. "ShadowUI_TBC.toc", "r")):read("*a")
assert(tocTbc:find("options\\scroll.lua", 1, true), "TBC TOC loads options scroll")

print("options_scroll_spec OK")
