-- Unit Frame Designer is a visual studio inside /shadowui, not HUD chips.
-- Run: lua tests/edit_units_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent", width = 1920, height = 1080, level = 0, strata = "MEDIUM" }
function _G.UIParent:GetWidth() return self.width end
function _G.UIParent:GetHeight() return self.height end
function _G.UIParent:GetEffectiveScale() return 1 end
local cursor = { x = 0, y = 0 }
_G.GetCursorPosition = function() return cursor.x, cursor.y end

local function fakeTex(parent)
  local tex = { parent = parent, points = {}, shown = true }
  function tex:SetAllPoints(target) self.all = target or parent end
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetWidth(width) self.width = width end
  function tex:SetHeight(height) self.height = height end
  function tex:SetSize(width, height)
    self.width, self.height = width, height
  end
  function tex:SetTexture(file) self.file = file end
  function tex:SetTexCoord(l, r, t, b)
    self.texCoord = { l, r, t, b }
  end
  function tex:SetVertexColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:Show() self.shown = true end
  function tex:Hide() self.shown = false end
  function tex:SetShown(shown) self.shown = shown and true or false end
  return tex
end

local function fakeFont()
  local fs = { text = "", points = {} }
  function fs:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function fs:ClearAllPoints() self.points = {} end
  function fs:SetText(text) self.text = text or "" end
  function fs:GetText() return self.text end
  function fs:SetTextColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function fs:SetJustifyH(justify) self.justify = justify end
  function fs:SetPoint(...) self.points[#self.points + 1] = { ... } end
  return fs
end

_G.CreateFrame = function(kind, name, parent, template)
  local frame = {
    kind = kind,
    name = name,
    parent = parent,
    template = template,
    shown = true,
    mouse = false,
    level = parent and (parent.level or 0) + 1 or 0,
    points = {},
    width = 0,
    height = 0,
  }
  if name then
    _G[name] = frame
  end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level end
  function frame:EnableMouse(enabled) self.mouse = enabled and true or false end
  function frame:SetSize(width, height)
    self.width, self.height = width, height
  end
  function frame:GetWidth() return self.width or 0 end
  function frame:GetHeight() return self.height or 0 end
  function frame:SetWidth(w) self.width = w end
  function frame:SetHeight(h) self.height = h end
  function frame:SetAllPoints(target) self.allPoints = target end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
    local point = self.points[#self.points]
    if point[1] == "BOTTOMLEFT" and type(point[#point - 1]) == "number" then
      self.left = point[#point - 1]
      self.bottom = point[#point]
    elseif point[1] == "TOPLEFT" and type(point[3]) == "number" then
      -- TOPLEFT x, y relative to parent
    end
  end
  function frame:GetLeft() return self.left or 0 end
  function frame:GetBottom() return self.bottom or 0 end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown == true end
  function frame:SetShown(shown) self.shown = shown and true or false end
  function frame:SetClipsChildren() end
  function frame:SetScale(scale) self.scale = scale end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:CreateTexture()
    return fakeTex(self)
  end
  function frame:CreateFontString()
    local fs = fakeFont()
    self.fontString = self.fontString or fs
    return fs
  end
  function frame:SetBackdrop() end
  function frame:SetBackdropColor() end
  function frame:SetBackdropBorderColor() end
  function frame:SetText(text) self.text = text end
  function frame:GetText() return self.text end
  function frame:SetAutoFocus() end
  function frame:ClearFocus() end
  return frame
end

local account = {
  defaultProfile = "Default",
  profiles = {
    Default = { layout = {}, keybinds = {}, actions = {} },
  },
}
function Addon:GetDB() return account end
function Addon:GetCharDB() return { activeProfile = "Default" } end
function Addon:GetPlayerClass() return "MAGE" end
function Addon:Print() end
local opened
function Addon:OpenOptions() opened = true end

assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "units/layout.lua"))()
assert(loadfile(root .. "defaults/base.lua"))()
assert(loadfile(root .. "defaults/units.lua"))()
assert(loadfile(root .. "edit/units.lua"))()

Addon:CreateUnitStudio(UIParent)
Addon:RefreshUnitStudio()
local studio = Addon.unitStudio
assert(studio and studio.frame, "studio lives in a panel frame")
assert(studio.frame.name == "ShadowUIUnitStudio", "studio is not a world HUD overlay")
assert(_G.ShadowUIWidgetDragplayerportrait == nil, "Designer does not paint world Widget chips")
local portrait = studio.nodes.portrait
local healthText = studio.nodes.healthText
local art = studio.nodes.art
assert(portrait and portrait.shown, "canvas paints the portrait")
assert(portrait.mock and portrait.mock.face, "portrait mock uses a face texture")
assert(math.abs((portrait.rectLeft or 0) - 42) < 0.01, "canvas uses host-local portrait x")
assert(healthText, "canvas paints Status Text")
assert(healthText.fontString.text == "7432 / 10000", "Status Text shows mock health")
assert(studio.nodes.name.fontString.text == "Player", "name mock is a unit name, not a stub label")
assert(art and art.mock and art.mock.chrome, "Frame Art mock uses targeting-frame chrome")
assert(tostring(art.mock.chrome.file or ""):find("UI-TargetingFrame", 1, true),
  "Frame Art uses the Classic targeting-frame texture")
assert(art.mock.chrome.texCoord and art.mock.chrome.texCoord[1] == 1
  and art.mock.chrome.texCoord[2] == 0.09375
  and art.mock.chrome.texCoord[4] == 0.78125,
  "Player Frame Art uses the Blizzard PlayerFrameTexture crop")
assert(studio.nodes.health.mock and studio.nodes.health.mock.bar, "health mock is a status bar fill")
assert(art.resizeGrip.shown == false, "resize grip is hidden until a Widget is selected")
assert(studio.nodes.health.resizeGrip.shown == false, "unselected Widgets have no grip")
assert(studio.host.points[1] and studio.host.points[1][1] == "CENTER", "preview sits in the canvas centre")
assert(studio.guide == nil, "canvas does not draw anchor guide lines")
assert(studio.treeRows[1] and studio.treeRows[1].label.text:find("Health Text", 1, true),
  "tree lists front stack Widgets first")

Addon:SelectStudioWidget("art")
assert(art.resizeGrip.shown == true, "selected Frame Art shows a crop grip")
Addon:SetSelectedWidgetSize(216, 100)
Addon:SetSelectedWidgetOffset(16, 0)
assert(math.abs((art.mock.chrome.texCoord[1] or 0) - 0.9375) < 0.0001,
  "resizing Frame Art crops the targeting-frame atlas")
Addon:NudgeWidgetStack("player", "art", 8)
assert(account.profiles.Default.layout.player.art.stack == 9, "Front/Back writes Widget stack")

Addon:SelectStudioWidget("healthText")
assert(Addon.selectedStudioWidget == "healthText", "tree/canvas select the Widget")
assert(studio.inspector.widgetId == "healthText", "inspector follows the canvas selection")
assert(studio.inspector.anchor.text:find("health", 1, true), "inspector shows SetPoint relativeTo")
assert(healthText.resizeGrip.shown == true, "selected Widget shows one resize grip")
assert(studio.nodes.health.resizeGrip.shown == false, "unselected Widgets have no grip")

studio.host.left, studio.host.bottom = 0, 0
cursor.x, cursor.y = (healthText.rectLeft or 0) + 4, (healthText.rectBottom or 0) + 4
healthText.script_OnMouseDown(healthText, "LeftButton")
cursor.x = cursor.x + 0
cursor.y = cursor.y - 6
healthText.script_OnUpdate(healthText)
healthText.script_OnMouseUp(healthText, "LeftButton")
local patch = account.profiles.Default.layout.player.healthText
assert(patch.relativeTo == "health", "canvas drag keeps Status Text on health")
assert(patch.point == "CENTER", "canvas drag keeps CENTER")
assert(patch.y == -6, "a 6px drop on the canvas is offset y -6")

Addon:SetSelectedWidgetOffset(2, -8)
assert(account.profiles.Default.layout.player.healthText.x == 2, "inspector offset writes x")
assert(account.profiles.Default.layout.player.healthText.y == -8, "inspector offset writes y")

Addon:SetSelectedWidgetSize(130, 16)
assert(account.profiles.Default.layout.player.healthText.width == 130, "inspector size writes width")

Addon:SelectStudioWidget("health")
Addon:SetSelectedWidgetAnchor("TOPLEFT", "portrait", "TOPRIGHT")
assert(account.profiles.Default.layout.player.health.relativeTo == "portrait",
  "inspector retargets relativeTo")

Addon.studioFrameId = "target"
Addon.selectedStudioWidget = nil
Addon:RefreshUnitStudio()
assert(studio.nodes.nameBackground and studio.nodes.nameBackground.shown,
  "Target canvas includes Name Background")
assert(studio.nodes.name.fontString.text == "Arthas", "Target mock uses the hostile unit name")
assert(art.mock.chrome.texCoord and art.mock.chrome.texCoord[1] == 0.09375
  and art.mock.chrome.texCoord[2] == 1,
  "Target Frame Art flips the targeting-frame atlas")

opened = false
Addon:OpenUnitFrameDesigner()
assert(opened == true, "Designer opens the ShadowUI options panel")
assert(Addon.unitFrameMode ~= true, "Designer is not a world Edit Mode session")

print("edit_units_spec OK")
