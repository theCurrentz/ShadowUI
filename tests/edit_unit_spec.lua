-- Player Frame and Target Frame are Layout Edit Mode hosts.
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
    MAGE = { layout = {}, keybinds = {}, variants = { Default = { layout = {}, keybinds = {} } } },
  },
}
local char = { editLayer = "class", activeVariant = "Default", variantManual = true }
function Addon:GetDB() return account end
function Addon:GetCharDB() return char end
function Addon:GetPlayerClass() return "MAGE" end
function Addon:ApplyAll()
  self.applied = (self.applied or 0) + 1
  if self.SkinUnitFrames then
    self:SkinUnitFrames()
  end
end
function Addon:Print() end
function Addon:ShowLayerPicker() end
function Addon:ApplyKeybindSession() end
function Addon:ResolveEffective()
  return { layout = account.classes.MAGE.layout }
end

assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()
assert(loadfile(root .. "edit/mode.lua"))()
assert(loadfile(root .. "edit/frames.lua"))()

Addon:SkinUnitFrames()
Addon:SetEditSession("layout")
Addon:ApplyEditSession(false)

local playerOverlay = _G.ShadowUIPlayerDrag
local targetOverlay = _G.ShadowUITargetDrag
assert(playerOverlay, "Layout Edit Mode paints a Player HUD overlay")
assert(targetOverlay, "Layout Edit Mode paints a Target HUD overlay")
assert(playerOverlay.shown == true, "player overlay shows in Layout Edit Mode")
assert(targetOverlay.shown == true, "target overlay shows in Layout Edit Mode")
assert(playerOverlay.mouse == true, "player overlay receives the drag")
assert(playerOverlay.strata == "DIALOG", "player overlay sits on the HUD dialog strata")
assert(playerOverlay.fontString and playerOverlay.fontString.text == "Player", "overlay names the Player Frame")
assert(targetOverlay.fontString and targetOverlay.fontString.text == "Target", "overlay names the Target Frame")
local stanceOverlay = _G.ShadowUIStanceDrag
assert(stanceOverlay, "Layout Edit Mode paints a Stance HUD overlay")
assert(stanceOverlay.shown == true, "stance overlay shows when the Blizzard bar is up")
assert(stanceOverlay.fontString and stanceOverlay.fontString.text == "Stance", "overlay names the Stance Bar")
assert(playerOverlay.fill and playerOverlay.fill.g > 0.4, "player overlay fill is HUD blue")

playerOverlay.script_OnMouseDown(playerOverlay, "LeftButton")
assert(_G.PlayerFrame.moving == true, "mouse down starts the Player Frame move")
assert(_G.PlayerFrame.movable == true, "ShadowUI edit can move the Player Frame")
_G.PlayerFrame:SetPoint("CENTER", _G.UIParent, "CENTER", 16, -4)
assert(_G.PlayerFrame.points[#_G.PlayerFrame.points][4] == 16, "park does not fight a ShadowUI drag")
_G.PlayerFrame.left, _G.PlayerFrame.bottom = 100, 50
playerOverlay.script_OnMouseUp(playerOverlay, "LeftButton")
assert(_G.PlayerFrame.moving == false, "mouse up stops the Player Frame move")
assert(account.classes.MAGE.layout.player, "player persist writes Layout")
assert(account.classes.MAGE.layout.player.point == "BOTTOMLEFT", "player persist uses the grid origin")
assert(math.abs(account.classes.MAGE.layout.player.x - 97.2) < 0.01, "player persist snaps x")
assert(math.abs(account.classes.MAGE.layout.player.y - 64.8) < 0.01, "player persist snaps y")

_G.PlayerFrame:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 16, -4)
local parked = _G.PlayerFrame.points[#_G.PlayerFrame.points]
assert(parked[1] == "BOTTOMLEFT" and math.abs(parked[4] - 97.2) < 0.01,
  "Blizzard Edit Mode snaps back to the ShadowUI Player Frame")

_G.StanceBarFrame.shown = false
Addon:RefreshUnitDragOverlays()
assert(stanceOverlay.shown == false, "a hidden Blizzard Stance Bar has no edit overlay")
_G.StanceBarFrame.shown = true
Addon:RefreshUnitDragOverlays()
assert(stanceOverlay.shown == true, "a shown Blizzard Stance Bar keeps the edit overlay")

Addon:SetEditSession(nil)
Addon:ApplyEditSession(false)
assert(playerOverlay.shown == false, "play mode hides the player overlay")
assert(_G.PlayerFrame.movable == false, "play mode locks the Player Frame")
assert(stanceOverlay.shown == false, "play mode hides the stance overlay")

print("edit_unit_spec OK")
