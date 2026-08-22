-- Layout Edit Mode paints a HUD overlay above action buttons so Bars drag.
-- Run: lua tests/edit_hud_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end

local combat = false
_G.InCombatLockdown = function() return combat end
_G.UIParent = { name = "UIParent", width = 1920, height = 1080, level = 0, strata = "MEDIUM" }
function _G.UIParent:GetWidth() return self.width end
function _G.UIParent:GetHeight() return self.height end
function _G.UIParent:GetEffectiveScale() return 1 end
_G.GetCursorPosition = function() return 0, 0 end

local function fakeFont(parent)
  local fs = { parent = parent, text = "", points = {}, justify = "CENTER" }
  function fs:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function fs:SetAllPoints(target) self.all = target end
  function fs:SetText(text) self.text = text or "" end
  function fs:SetTextColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function fs:SetJustifyH(justify) self.justify = justify end
  function fs:SetFont() end
  return fs
end

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
    moving = false,
    movable = false,
    lines = {},
    buttons = {},
  }
  function frame:SetFrameStrata(strata) self.strata = strata end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level end
  function frame:EnableMouse(enabled) self.mouse = enabled and true or false end
  function frame:SetMovable(enabled) self.movable = enabled and true or false end
  function frame:SetClampedToScreen() self.clamped = true end
  function frame:SetClampRectInsets() end
  function frame:SetToplevel(enabled) self.toplevel = enabled and true or false end
  function frame:SetScale(scale) self.scale = scale end
  function frame:GetScale() return self.scale end
  function frame:SetSize(width, height)
    self.width, self.height = width, height
  end
  function frame:GetWidth() return self.width end
  function frame:GetHeight() return self.height end
  function frame:SetWidth(width) self.width = width end
  function frame:SetHeight(height) self.height = height end
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
  function frame:GetPoint()
    local point = self.points[1]
    if not point then
      return "CENTER", _G.UIParent, "CENTER", 0, 0
    end
    return point[1], point[2], point[3], point[4], point[5]
  end
  function frame:GetName() return self.name end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown == true end
  function frame:SetShown(shown) self.shown = shown and true or false end
  function frame:RegisterForDrag(...) self.dragButtons = { ... } end
  function frame:RegisterForClicks(...) self.clicks = { ... } end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:StartMoving() self.moving = true end
  function frame:StopMovingOrSizing() self.moving = false end
  function frame:IsMoving() return self.moving == true end
  function frame:CreateTexture()
    local tex = fakeTex(self)
    self.textures = self.textures or {}
    self.textures[#self.textures + 1] = tex
    return tex
  end
  function frame:CreateFontString(_, _, template)
    local fs = fakeFont(self)
    fs.template = template
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
  function frame:SetFontString(fs) self.label = fs end
  function frame:SetText(text)
    self.text = text
    if self.label then
      self.label:SetText(text)
    end
  end
  return frame
end

function Addon:ApplyBarChrome() end
function Addon:CreateBarButton(parent, id)
  local button = CreateFrame("Button", "ShadowUIActionButton" .. id, parent)
  button.mouse = true
  return button
end
function Addon:GetCharDB()
  return { editLayer = "variant" }
end
function Addon:Print() end
function Addon:ApplyAll() self.applied = (self.applied or 0) + 1 end
function Addon:WriteLayerDelta() end
function Addon:ResolveEffective()
  return { layout = { bar1 = { buttons = 2, buttonSize = 36, columns = 2, x = 0, y = 0 } } }
end
function Addon:ApplyKeybindSession() end

assert(loadfile(root .. "bars/bar.lua"))()
assert(loadfile(root .. "edit/mode.lua"))()
assert(loadfile(root .. "edit/layer.lua"))()

Addon.editMode = false
local bar = Addon:CreateBar("bar1", {
  buttons = 2, buttonSize = 36, columns = 2, x = 0, y = 0, point = "CENTER",
})
local overlay = bar.dragOverlay
assert(overlay, "CreateBar makes a drag overlay")
assert(overlay.shown == false, "overlay stays hidden in play mode")
assert(overlay.mouse == false, "overlay does not eat clicks in play mode")

Addon.editMode = true
Addon:UpdateBarLayout(bar, { buttons = 2, buttonSize = 36, columns = 2, x = 0, y = 0 })
assert(overlay.kind == "Button", "overlay is a Button so it wins hit tests")
assert(overlay.parent == _G.UIParent, "overlay is not trapped under the Bar strata")
assert(overlay.strata == "DIALOG", "overlay sits on the HUD dialog strata")
assert(overlay.shown == true, "overlay shows in Layout Edit Mode")
assert(overlay.mouse == true, "overlay receives the drag")
assert(overlay.fill, "overlay paints a HUD fill")
assert(overlay.fill.r == 0 and overlay.fill.g > 0.4 and overlay.fill.b > 0.8,
  "overlay fill is Blizzard HUD blue")
assert(overlay.fill.a > 0.2 and overlay.fill.a < 0.55, "overlay fill stays translucent")
assert(overlay.fontString and overlay.fontString.text == "Bar 1", "overlay names the Bar")
assert(bar.movable == true, "Bar can move while the overlay is shown")

bar.left, bar.bottom = 100, 50
Addon:SnapFrameToGrid(bar)
assert(bar.points[#bar.points][1] == "BOTTOMLEFT", "snap uses the screen bottom-left origin")
assert(math.abs(bar.points[#bar.points][4] - 97.2) < 0.01, "100 snaps to 97.2")
assert(math.abs(bar.points[#bar.points][5] - 64.8) < 0.01, "50 snaps to 64.8")

overlay.script_OnMouseDown(overlay, "LeftButton")
overlay.script_OnMouseUp(overlay, "LeftButton")

local grid = Addon:CreateEditGrid()
local horiz
for _, line in ipairs(grid.lines) do
  if line.points[1] and line.points[1][1] == "BOTTOMLEFT" and line.points[1][3] == "BOTTOMLEFT" then
    horiz = line
    break
  end
end
assert(horiz, "horizontal grid lines grow from the bottom so they match snap")
Addon:SetEditSession("layout")
Addon:ApplyEditSession(false)
assert(grid.shown == true, "grid shows in Layout Edit Mode")
assert(grid.vCenter and grid.hCenter, "grid paints centre guides")
assert(grid.vCenter.r > 0.7 and grid.vCenter.b > 0.7 and grid.vCenter.g < 0.5,
  "centre guides are magenta")
-- 1920×1080: pixel centre is 960×540. Nearest 32.4 snap is 972 and 550.8.
assert(grid.vCenter.points[1][4] == 972, "vertical centre sits on the snap grid")
assert(grid.hCenter.points[1][5] == 550.8, "horizontal centre sits on the snap grid")
local vOnGrid, hOnGrid
for _, line in ipairs(grid.lines) do
  if line.points[1] and line.points[1][4] == 972 then
    vOnGrid = true
  end
  if line.points[1] and line.points[1][5] == 550.8 then
    hOnGrid = true
  end
end
assert(vOnGrid, "a white vertical line shares the centre x")
assert(hOnGrid, "a white horizontal line shares the centre y")

local picker = Addon.layerPicker
assert(picker, "layer picker shows in Layout Edit Mode")
assert(picker.title.text == "Layout Edit Mode", "picker uses the HUD title")
assert(picker.done, "picker has a Done control")
assert(picker.done.mouse == true, "Done receives mouse")
assert(picker.done.clicks, "Done registers for clicks")
assert(picker:GetWidth() >= 320, "picker is a HUD-sized panel")
assert(picker.strata == "FULLSCREEN_DIALOG", "picker sits above HUD overlays")

Addon.bars = { bar1 = bar }
Addon:SetEditSession("layout")
Addon:ApplyEditSession(false)
local close = picker.done.script_OnMouseUp or picker.done.script_OnClick
assert(close, "Done has a mouse handler")
close(picker.done, "LeftButton")
assert(Addon.editSession == nil, "Done ends Layout Edit Mode")
assert(overlay.shown == false, "Done hides HUD overlays")
assert(picker.shown == false, "Done hides the picker")

combat = true
Addon:SetEditSession(nil)
Addon.editMode = false
Addon:ToggleEditMode()
assert(Addon.editMode == false, "layout toggle does not start in combat")

combat = false
Addon:SetEditSession("layout")
Addon:ApplyEditSession(false)
combat = true
Addon:OnRegenDisabled()
assert(Addon.editSession == nil, "combat closes Layout Edit Mode")
assert(overlay.shown == false, "combat hides the HUD overlay")

print("edit_hud_spec OK")
