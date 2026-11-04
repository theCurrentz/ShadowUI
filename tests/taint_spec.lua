-- ApplySkins must not call protected methods on Forever hosts.
-- pcall still pops ADDON_ACTION_FORBIDDEN, so the call must not happen.
-- Run: lua tests/taint_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    local orig = _G[object]
    if type(orig) ~= "function" then
      return
    end
    _G[object] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  if type(orig) ~= "function" then
    object[method] = fn
    return
  end
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.UIParent = { name = "UIParent" }
function _G.UIParent:GetWidth() return 1920 end

local forbidden = {}
local function note(name, method)
  forbidden[#forbidden + 1] = name .. ":" .. method
end

local function protect(frame, method)
  frame[method] = function(self)
    note(self.name or "?", method)
    error(method .. " is protected")
  end
end

_G.CreateFrame = function(_, name, parent, template)
  local frame = {
    name = name,
    parent = parent or _G.UIParent,
    template = template,
    shown = true,
    points = {},
  }
  if name then
    _G[name] = frame
  end
  function frame:SetParent(nextParent) self.parent = nextParent end
  function frame:GetParent() return self.parent end
  function frame:SetFrameStrata() end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function frame:GetWidth() return self.width or 28 end
  function frame:GetHeight() return self.height or 58 end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function frame:SetBackdrop() end
  function frame:SetBackdropBorderColor() end
  function frame:SetAlpha() end
  function frame:SetClipsChildren() end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown end
  function frame:EnableMouse() end
  function frame:SetScript() end
  function frame:HookScript() end
  function frame:GetRegions() end
  return frame
end

local function fakeButton(name)
  local button = {
    name = name,
    parent = _G.UIParent,
    shown = true,
    points = {},
    layoutIndex = 1,
  }
  function button:GetName() return self.name end
  function button:SetParent(frame) self.parent = frame end
  function button:GetParent() return self.parent end
  function button:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function button:GetWidth() return self.width or 28 end
  function button:GetHeight() return self.height or 58 end
  function button:GetFrameLevel() return 4 end
  function button:SetFrameLevel() end
  function button:Show() self.shown = true end
  function button:Hide() self.shown = false end
  function button:IsShown() return self.shown end
  function button:ClearAllPoints() self.points = {} end
  function button:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function button:SetAlpha() end
  function button:SetScript() end
  function button:HookScript() end
  function button:SetClipsChildren() end
  function button:EnableMouse() end
  function button:SetHitRectInsets() end
  _G[name] = button
  return button
end

local extras = {
  "StoreMicroButton",
  "AchievementMicroButton",
  "EJMicroButton",
  "CollectionsMicroButton",
  "GuildMicroButton",
  "HelpMicroButton",
  "CharacterBag0Slot",
  "KeyRingButton",
}
for _, name in ipairs(extras) do
  local button = fakeButton(name)
  protect(button, "Hide")
  protect(button, "SetScript")
  protect(button, "SetAlpha")
  protect(button, "HookScript")
end

fakeButton("CharacterMicroButton")
protect(_G.CharacterMicroButton, "HookScript")
protect(_G.CharacterMicroButton, "SetAlpha")
fakeButton("MainMenuBarBackpackButton")
_G.MainMenuBarBackpackButton.width = 37
_G.MainMenuBarBackpackButton.height = 37
protect(_G.MainMenuBarBackpackButton, "HookScript")
protect(_G.MainMenuBarBackpackButton, "SetAlpha")
fakeButton("SpellbookMicroButton")
fakeButton("SocialsMicroButton")
fakeButton("MainMenuMicroButton")
_G.MICRO_BUTTONS = {
  "CharacterMicroButton",
  "SpellbookMicroButton",
  "SocialsMicroButton",
  "MainMenuMicroButton",
  "HelpMicroButton",
}

local bagsBar = _G.CreateFrame("Frame", "MicroButtonAndBagsBar", _G.UIParent)
protect(bagsBar, "Hide")
protect(bagsBar, "SetPoint")
local bagsArt = { name = "MicroBagBar" }
function bagsArt:Hide() end
function bagsArt:SetAlpha() end
function bagsBar:GetRegions()
  return bagsArt
end

function Addon:GetCharDB()
  return { useShadowUIMenu = true }
end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/micro.lua"))()
Addon:SkinMicroAndBags()

assert(#forbidden == 0, "micro extras must not Hide/SetScript/SetAlpha: " .. table.concat(forbidden, ", "))
assert(_G.StoreMicroButton.parent == _G.UIParent, "Store stays on its Blizzard parent")
assert(_G.HelpMicroButton.parent == _G.UIParent, "Help stays on its Blizzard parent")
assert(_G.StoreMicroButton.layoutIndex == 1, "Store keeps layoutIndex")
assert(bagsBar.shown, "MicroButtonAndBagsBar stays shown")
assert(#bagsBar.points == 0, "MicroButtonAndBagsBar is not moved")
assert(bagsBar.shadowUIOuter and bagsBar.shadowUIOuter.shown ~= false,
  "the combined bar border gets an Outer Edge")

print("taint_spec OK")
