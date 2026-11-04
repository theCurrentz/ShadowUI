-- Stance Bar is a Layout Edit Mode host. Player Frame and Target Frame stay Blizzard.
-- Run: lua tests/edit_unit_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
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
    return
  end
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent", width = 1920, height = 1080, level = 0, strata = "MEDIUM" }
function _G.UIParent:GetWidth() return self.width end
function _G.UIParent:GetHeight() return self.height end
function _G.UIParent:GetEffectiveScale() return 1 end
local cursor = { x = 0, y = 0 }
_G.GetCursorPosition = function() return cursor.x, cursor.y end
_G.IsShiftKeyDown = function() return false end

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
  function tex:Show() self.shown = true end
  function tex:Hide() self.shown = false end
  return tex
end

local function fakeFont()
  local fs = { text = "", points = {} }
  function fs:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function fs:SetText(text) self.text = text or "" end
  function fs:SetTextColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
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
    strata = (parent and parent.strata) or "MEDIUM",
    points = {},
    width = 0,
    height = 0,
    movable = false,
    moving = false,
    lines = {},
  }
  if name then
    _G[name] = frame
  end
  function frame:SetFrameStrata(strata) self.strata = strata end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level end
  function frame:EnableMouse(enabled) self.mouse = enabled and true or false end
  function frame:SetMovable(enabled) self.movable = enabled and true or false end
  function frame:SetResizable(enabled) self.resizable = enabled and true or false end
  function frame:SetClampedToScreen() self.clamped = true end
  function frame:SetToplevel(enabled) self.toplevel = enabled and true or false end
  function frame:SetSize(width, height)
    self.width, self.height = width, height
  end
  function frame:GetWidth() return self.width end
  function frame:GetHeight() return self.height end
  function frame:SetAllPoints(target)
    self.allPoints = target
    if target and target.GetWidth then
      self.width = target:GetWidth()
      self.height = target:GetHeight()
    end
  end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
    local point = self.points[#self.points]
    if point[1] == "BOTTOMLEFT" and type(point[4]) == "number" then
      self.left = point[4]
      self.bottom = point[5]
    end
  end
  function frame:GetLeft() return self.left end
  function frame:GetBottom() return self.bottom end
  function frame:GetName() return self.name end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown == true end
  function frame:SetShown(shown) self.shown = shown and true or false end
  function frame:RegisterForDrag(...) self.dragButtons = { ... } end
  function frame:UnregisterForDrag() self.dragRegistered = false end
  function frame:SetUserPlaced(placed) self.userPlaced = placed end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:StartMoving() self.moving = true end
  function frame:StopMovingOrSizing() self.moving = false end
  function frame:CreateTexture()
    local tex = fakeTex(self)
    self.textures = self.textures or {}
    self.textures[#self.textures + 1] = tex
    return tex
  end
  function frame:CreateFontString()
    local fs = fakeFont()
    self.fontString = fs
    return fs
  end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a)
    self.backdropColor = { r, g, b, a }
  end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.backdropBorder = { r, g, b, a }
  end
  return frame
end

local function fakeUnit(name, width, height)
  local frame = CreateFrame("Frame", name, UIParent)
  frame.width, frame.height = width, height
  return frame
end

_G.PlayerFrame = fakeUnit("PlayerFrame", 232, 100)
_G.TargetFrame = fakeUnit("TargetFrame", 232, 100)
_G.StanceBarFrame = fakeUnit("StanceBarFrame", 108, 36)

local account = {
  base = { layout = {}, keybinds = {} },
  classes = {
    MAGE = { layout = {}, keybinds = {} },
  },
}
local char = { activeProfile = "Default" }
function Addon:GetDB() return account end
function Addon:GetCharDB() return char end
function Addon:GetPlayerClass() return "MAGE" end
function Addon:GetProfile() return account.classes.MAGE end
function Addon:ApplyAll()
  self.applied = (self.applied or 0) + 1
end
function Addon:Print() end
function Addon:ShowLayerPicker() end
function Addon:ApplyKeybindSession() end
function Addon:ResolveEffective()
  return { layout = account.classes.MAGE.layout }
end

assert(loadfile(root .. "core/resolve.lua"))()
function Addon:GetProfile() return account.classes.MAGE end
assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()
assert(loadfile(root .. "edit/mode.lua"))()
assert(loadfile(root .. "edit/frames.lua"))()

Addon:SetEditSession("layout")
Addon:ApplyEditSession(false)

assert(_G.ShadowUIPlayerDrag == nil, "Player Frame is not a Layout Edit Mode host")
assert(_G.ShadowUITargetDrag == nil, "Target Frame is not a Layout Edit Mode host")
local stanceOverlay = _G.ShadowUIStanceDrag
assert(stanceOverlay, "Layout Edit Mode paints a Stance HUD overlay")
assert(stanceOverlay.shown == true, "stance overlay shows when the Blizzard bar is up")
assert(stanceOverlay.fontString and stanceOverlay.fontString.text == "Stance", "overlay names the Stance Bar")

_G.StanceBarFrame.shown = false
Addon:RefreshUnitDragOverlays()
assert(stanceOverlay.shown == false, "a hidden Blizzard Stance Bar has no edit overlay")
_G.StanceBarFrame.shown = true
Addon:RefreshUnitDragOverlays()
assert(stanceOverlay.shown == true, "a shown Blizzard Stance Bar keeps the edit overlay")

_G.StanceBarFrame.shown = false
_G.StanceBar = fakeUnit("StanceBar", 36, 36)
_G.StanceBar.left, _G.StanceBar.bottom = 40, 20
Addon:RefreshUnitDragOverlays()
assert(stanceOverlay.host == _G.StanceBar, "1.15 StanceBar is the Layout Edit Mode host")
assert(stanceOverlay.shown == true, "a shown StanceBar keeps the edit overlay")

_G.IsShiftKeyDown = function() return true end
cursor.x, cursor.y = 120, 60
stanceOverlay.script_OnMouseDown(stanceOverlay, "LeftButton")
cursor.x, cursor.y = 160, 90
Addon.editDragTicker.script_OnUpdate(Addon.editDragTicker)
assert(_G.StanceBar.left == 80 and _G.StanceBar.bottom == 50,
  "Layout Edit Mode drags the Stance Bar with the cursor")
stanceOverlay.script_OnMouseUp(stanceOverlay, "LeftButton")
assert(account.classes.MAGE.layout.stance, "stance persist writes Layout")
assert(account.classes.MAGE.layout.stance.point == "BOTTOMLEFT", "stance persist uses the grid origin")
assert(account.classes.MAGE.layout.stance.x == 80, "stance persist keeps Shift-skip x")
assert(account.classes.MAGE.layout.stance.y == 50, "stance persist keeps Shift-skip y")

_G.StanceBar.width, _G.StanceBar.height = 0, 0
local stealth = fakeUnit("StanceButton1", 30, 30)
stealth.left, stealth.bottom = 40, 20
Addon:RefreshUnitDragOverlays()
assert(stanceOverlay.width >= 30 and stanceOverlay.height >= 30,
  "a Stance Bar with no size still has a drag overlay over the stealth button")
assert(stanceOverlay.mouse == true, "the stealth overlay receives the drag")

Addon:SetEditSession(nil)
Addon:ApplyEditSession(false)
assert(stanceOverlay.shown == false, "play mode hides the stance overlay")

print("edit_unit_spec OK")
