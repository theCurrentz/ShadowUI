-- ShadowUI Unit Frames create from Baseline Layout and stay hidden until cutover.
-- HideBlizzardUnitFrames runs only when UnitFramesAreLive.
-- Run: lua tests/unit_frame_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent" }

local frames = {}
_G.CreateFrame = function(kind, name, parent, template)
  local frame = {
    kind = kind,
    name = name,
    parent = parent,
    template = template,
    shown = true,
    points = {},
    children = {},
    widgets = {},
  }
  function frame:SetSize(w, h) self.width, self.height = w, h end
  function frame:SetWidth(w) self.width = w end
  function frame:SetHeight(h) self.height = h end
  function frame:GetWidth() return self.width or 0 end
  function frame:GetHeight() return self.height or 0 end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:GetPoint()
    local p = self.points[1]
    if not p then
      return nil
    end
    return p[1], p[2], p[3], p[4], p[5]
  end
  function frame:SetAttribute(key, value) self[key] = value end
  function frame:RegisterForClicks() end
  function frame:SetMovable(v) self.movable = v end
  function frame:EnableMouse(v) self.mouse = v end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetMinMaxValues(minV, maxV) self.minV, self.maxV = minV, maxV end
  function frame:SetValue(value) self.value = value end
  function frame:SetText(text) self.text = text end
  function frame:SetJustifyH() end
  function frame:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function frame:CreateTexture(childName)
    local tex = _G.CreateFrame("Texture", childName, self)
    self.children[#self.children + 1] = tex
    return tex
  end
  function frame:CreateFontString(childName)
    local fs = _G.CreateFrame("FontString", childName, self)
    self.children[#self.children + 1] = fs
    return fs
  end
  function frame:UnregisterAllEvents() self.events = {} end
  frames[name] = frame
  return frame
end

_G.PlayerFrame = _G.CreateFrame("Button", "PlayerFrame", _G.UIParent)
_G.TargetFrame = _G.CreateFrame("Button", "TargetFrame", _G.UIParent)
_G.UnitExists = function(unit) return unit == "player" or unit == "target" end
_G.UnitName = function(unit) return unit == "player" and "Tazzy" or "Dummy" end
_G.UnitHealth = function() return 50 end
_G.UnitHealthMax = function() return 100 end
_G.UnitPower = function() return 20 end
_G.UnitPowerMax = function() return 100 end
_G.UnitLevel = function() return 60 end
_G.SetPortraitTexture = function(tex, unit) tex.portraitUnit = unit end

assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "units/layout.lua"))()
assert(loadfile(root .. "units/frame.lua"))()
assert(loadfile(root .. "units/apply.lua"))()
assert(loadfile(root .. "defaults/base.lua"))()
assert(loadfile(root .. "defaults/units.lua"))()

function Addon:GetDB()
  return { defaultProfile = "Default", profiles = { Default = { layout = {}, keybinds = {} } } }
end
function Addon:GetCharDB()
  return { activeProfile = nil }
end
function Addon:GetPlayerClass() return "WARRIOR" end

assert(Addon:UnitFramesAreLive() == false, "cutover is off")

local cfg = Addon:ResolveEffective("WARRIOR")
Addon:ApplyUnitFrames(cfg)
local player = Addon.unitFrames.player
local target = Addon.unitFrames.target
assert(player and target, "Apply creates Player and Target hosts")
assert(player.name == "ShadowUIPlayerFrame", "Player host name is ShadowUI")
assert(player.template == "SecureUnitButtonTemplate", "host is a secure unit button")
assert(player.unit == "player", "Player binds the player Unit Token")
assert(target.unit == "target", "Target binds the target Unit Token")
assert(player.shown == false, "Player host stays hidden before cutover")
assert(target.shown == false, "Target host stays hidden before cutover")
assert(_G.PlayerFrame.shown == true, "Blizzard PlayerFrame stays until cutover")
assert(_G.TargetFrame.shown == true, "Blizzard TargetFrame stays until cutover")
assert(player.widgets.portrait.width == 64, "Player portrait uses Baseline size")
assert(target.widgets.portrait.points[1][4] == 126, "Target portrait uses mirrored x")
assert(player.widgets.auras == nil, "Player does not build target-only Widgets")
assert(target.widgets.auras, "Target builds the aura Widget")
assert(target.widgets.spellBar, "Target builds the spell bar Widget")
assert(player.widgets.name.text == "Tazzy", "Refresh paints the player name")
assert(player.widgets.health.value == 50, "Refresh paints health")

Addon.unitFrameMode = true
Addon:ApplyUnitFrames(cfg)
assert(player.shown == true, "Unit Frame Designer previews the ShadowUI host")
assert(_G.PlayerFrame.shown == true, "Designer preview does not hide Blizzard")
Addon.unitFrameMode = false
Addon:ApplyUnitFrames(cfg)
assert(player.shown == false, "leaving Designer hides the preview host")

Addon.UnitFramesAreLive = function() return true end
Addon:ApplyUnitFrames(cfg)
assert(player.shown == true, "live cutover shows the ShadowUI Player Frame")
assert(_G.PlayerFrame.shown == false, "live cutover hides Blizzard PlayerFrame")
assert(_G.TargetFrame.shown == false, "live cutover hides Blizzard TargetFrame")
assert(_G.PlayerFrame.Show == false or type(_G.PlayerFrame.Show) == "function", "Blizzard Show is locked")
-- hideStay replaces Show with a no-op
_G.PlayerFrame:Show()
assert(_G.PlayerFrame.shown == false, "Blizzard PlayerFrame cannot Show after hide")

print("unit_frame_spec OK")
