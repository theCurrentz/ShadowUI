-- Cast Bar, Range Display, and Cooldown Manager are Layout Edit Mode hosts.
-- Run: lua tests/edit_meters_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent", width = 1920, height = 1080, level = 0, strata = "MEDIUM" }
function _G.UIParent:GetWidth() return self.width end
function _G.UIParent:GetHeight() return self.height end
_G.GetCursorPosition = function() return 0, 0 end
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
  function fs:SetJustifyH(justify) self.justify = justify end
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
    scale = 1,
    movable = false,
    resizable = false,
    moving = false,
    sizing = false,
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
  function frame:SetResizeBounds(minW, minH, maxW, maxH)
    self.minW, self.minH, self.maxW, self.maxH = minW, minH, maxW, maxH
  end
  function frame:SetMinResize(minW, minH) self.minW, self.minH = minW, minH end
  function frame:SetMaxResize(maxW, maxH) self.maxW, self.maxH = maxW, maxH end
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
  function frame:GetScale() return self.scale or 1 end
  function frame:GetTop()
    return (self.bottom or 0) + (self.height or 0) * (self.scale or 1)
  end
  function frame:GetName() return self.name end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown == true end
  function frame:SetShown(shown) self.shown = shown and true or false end
  function frame:RegisterForDrag(...) self.dragButtons = { ... } end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:StartMoving() self.moving = true end
  function frame:StartSizing(edge)
    self.sizing = true
    self.sizeEdge = edge
  end
  function frame:StopMovingOrSizing()
    self.moving = false
    self.sizing = false
  end
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
end
function Addon:Print() end
function Addon:ShowLayerPicker() end
function Addon:ApplyKeybindSession() end
function Addon:ResolveEffective()
  return { layout = account.classes.MAGE.layout }
end

assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "bars/grid.lua"))()
assert(loadfile(root .. "edit/mode.lua"))()
assert(loadfile(root .. "edit/frames.lua"))()

local group = CreateFrame("Frame", "ShadowUICastGroup", UIParent)
group:SetSize(288, 20)
Addon.castGroup = group
local castBar = CreateFrame("StatusBar", "ShadowUICastBar", group)
castBar:SetAllPoints(group)
Addon.castBar = castBar
local icon = CreateFrame("Frame", nil, castBar)
icon:SetSize(20, 20)
castBar.iconFrame = icon
local range = CreateFrame("Frame", "ShadowUIRangeDisplay", UIParent)
range:SetSize(112, 36)
Addon.rangeDisplay = range

Addon:SetEditSession("layout")
Addon:ApplyEditSession(false)

local castOverlay = _G.ShadowUICastDrag
local rangeOverlay = _G.ShadowUIRangeDrag
assert(castOverlay, "Layout Edit Mode paints a Cast HUD overlay")
assert(rangeOverlay, "Layout Edit Mode paints a Range HUD overlay")
assert(castOverlay.shown == true, "cast overlay shows in Layout Edit Mode")
assert(rangeOverlay.shown == true, "range overlay shows in Layout Edit Mode")
assert(castOverlay.mouse == true, "cast overlay receives the drag")
assert(rangeOverlay.mouse == true, "range overlay receives the drag")
assert(castOverlay.fontString and castOverlay.fontString.text == "Cast", "overlay names the Cast Bar")
assert(rangeOverlay.fontString and rangeOverlay.fontString.text == "Range", "overlay names the Range Display")
assert(castOverlay.allPoints == castBar, "Cast overlay matches the Cast Bar")
assert(castOverlay.resizeGrip, "Cast overlay has a resize grip")
assert(rangeOverlay.resizeGrip == nil, "Range overlay does not resize")
local cd = CreateFrame("Frame", "ShadowUICooldownManager", UIParent)
cd:SetSize(32.4, 32.4)
cd.left, cd.bottom = 100, 50
Addon.cooldownManager = cd
Addon:RefreshUnitDragOverlays()
local cdOverlay = _G.ShadowUICooldownDrag
assert(cdOverlay, "Layout Edit Mode paints a Cooldown Manager HUD overlay")
assert(cdOverlay.resizeGrip, "Cooldown overlay has a resize grip")
assert(cdOverlay.fontString and cdOverlay.fontString.text == "Cooldowns",
  "overlay names the Cooldown Manager")
assert(group.resizable == true, "Cast group can resize in Layout Edit Mode")

range.left, range.bottom = 100, 50
rangeOverlay.script_OnMouseDown(rangeOverlay, "LeftButton")
assert(rangeOverlay.script_OnUpdate, "Range drag follows the cursor so it can snap to centre")
assert(range.moving ~= true, "Range does not use Blizzard StartMoving")
rangeOverlay.script_OnMouseUp(rangeOverlay, "LeftButton")
assert(account.classes.MAGE.layout.range, "range persist writes Layout")
assert(account.classes.MAGE.layout.range.point == "BOTTOMLEFT", "range persist uses the grid origin")
assert(math.abs(account.classes.MAGE.layout.range.x - 97.2) < 0.01, "range persist snaps x")
assert(math.abs(account.classes.MAGE.layout.range.y - 64.8) < 0.01, "range persist snaps y")

local grip = castOverlay.resizeGrip
group.left, group.bottom = 200, 80
group.width, group.height = 200, 20
grip.script_OnMouseDown(grip, "LeftButton")
assert(group.sizing == true, "resize grip starts Cast Bar sizing")
assert(group.sizeEdge == "BOTTOMRIGHT", "Cast Bar resizes from the bottom-right")
grip.script_OnMouseUp(grip, "LeftButton")
assert(account.classes.MAGE.layout.cast, "cast persist writes Layout")
assert(math.abs(account.classes.MAGE.layout.cast.width - 194.4) < 0.01, "cast persist snaps width")
assert(account.classes.MAGE.layout.cast.height == 20, "cast persist snaps height to 4px")

cd.width, cd.height = 4 * 32.4 + 3 * 4, 2 * 32.4 + 4
cd.left, cd.bottom = 100, 50
account.classes.MAGE.layout.cooldown = { max = 8, gap = 4, buttonSize = 32.4 }
Addon:PersistHostPosition(cd, "cooldown", true)
assert(account.classes.MAGE.layout.cooldown.columns == 4,
  "Cooldown Manager resize writes columns")
assert(account.classes.MAGE.layout.cooldown.width == nil,
  "Cooldown Manager resize does not write pixel size")

range.text = fakeFont()
range.text.GetLeft = function() return 120 end
range.text.GetBottom = function() return 80 end
range.text.GetStringWidth = function() return 48 end
range.text.GetStringHeight = function() return 18 end
range.text.IsShown = function() return true end
range.left, range.bottom = 100, 50
Addon:SetEditSession("layout")
Addon:RefreshUnitDragOverlays()
assert(rangeOverlay.width == 48 and rangeOverlay.height == 18,
  "Range HUD overlay matches the numbers, not the 112x36 pad")
local visLeft = Addon:HostVisualRect(range, "range")
assert(math.abs(visLeft - (100 + (112 - 48) / 2)) < 0.01,
  "Range numbers stay geometrically centred in the host")

range.left, range.bottom = 890, 500
Addon:SetEditSession("layout")
Addon:PersistHostPosition(range, "range")
assert(account.classes.MAGE.layout.range.point == "CENTER", "a Range host near the cross stores CENTER")
assert(math.abs(account.classes.MAGE.layout.range.x) < 0.01, "Range x is 0 on the vertical midline")
assert(math.abs(account.classes.MAGE.layout.range.y) < 0.01, "Range y is 0 on the horizontal midline")

range.left, range.bottom = 100, 50
rangeOverlay.script_OnMouseDown(rangeOverlay, "LeftButton")
local chip = _G.ShadowUIEditReadout
assert(chip and chip.shown == true, "drag shows an x/y readout")
assert(chip.fontString.text:find("×", 1, true), "readout shows frame size")
assert(chip.fontString.text:find("Range", 1, true), "readout names the host")
rangeOverlay.script_OnMouseUp(rangeOverlay, "LeftButton")
assert(chip.shown == false, "mouse up hides the readout")

Addon:SetEditSession(nil)
Addon:ApplyEditSession(false)
assert(castOverlay.shown == false, "play mode hides the cast overlay")
assert(rangeOverlay.shown == false, "play mode hides the range overlay")
assert(group.movable == false, "play mode locks the Cast Bar")
assert(group.resizable == false, "play mode locks Cast Bar size")

print("edit_meters_spec OK")
