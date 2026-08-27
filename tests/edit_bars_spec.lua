-- Secure Warrior stance paging and Layout Edit Mode Bar resizing.
-- Run: lua tests/edit_bars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end

assert(loadfile(root .. "bars/grid.lua"))()

local twelve = Addon:ColumnChoices(12)
assert(twelve[1] == 12 and twelve[2] == 6 and twelve[3] == 4, "12-slot Action Bar uses 12, 6, 4 columns")
assert(twelve[4] == 3 and twelve[5] == 2 and twelve[6] == 1, "12-slot Action Bar also uses 3, 2, 1 columns")
assert(#twelve == 6, "12-slot Action Bar has six grids")

local pet = Addon:ColumnChoices(10)
assert(pet[1] == 10 and pet[2] == 5 and pet[3] == 2 and pet[4] == 1, "Pet Bar grids fill 10 slots")

local five = Addon:ColumnChoices(5)
assert(five[1] == 5 and five[2] == 1 and #five == 2, "5-slot grids fill 5 slots")

local row = Addon:LayoutForColumns(12, 12, 36)
assert(row.columns == 12 and row.rows == 1, "12 columns is one row")
assert(row.width == 432 and row.height == 36, "12x1 size is 12 buttons wide")
assert(row.scale == nil, "grid layout does not set scale")

local side = Addon:LayoutForColumns(12, 3, 36)
assert(side.columns == 3 and side.rows == 4, "3 columns is a 3x4 grid")
assert(side.width == 108 and side.height == 144, "3x4 size is 3 buttons wide")

local nearestRow = Addon:NearestBarLayout(12, 36, 432, 36)
assert(nearestRow.columns == 12 and nearestRow.rows == 1, "a wide drag stays a 12-slot row")
assert(nearestRow.scale == nil, "nearest grid does not set scale")

local nearestSix = Addon:NearestBarLayout(12, 36, 216, 72)
assert(nearestSix.columns == 6 and nearestSix.rows == 2, "a 6x2 drag consolidates to two rows")

local nearestThree = Addon:NearestBarLayout(12, 36, 108, 144)
assert(nearestThree.columns == 3 and nearestThree.rows == 4, "a tall drag expands to 3x4")

local nearestPet = Addon:NearestBarLayout(10, 36, 180, 72)
assert(nearestPet.columns == 5 and nearestPet.rows == 2, "Pet Bar resize fills 10 slots")

_G.UIParent = { name = "UIParent", width = 1920, height = 1080, level = 0, strata = "MEDIUM" }
function _G.UIParent:GetEffectiveScale() return 1 end
_G.GetCursorPosition = function() return 0, 0 end
_G.RegisterStateDriver = function(frame, state, driver)
  frame.stateDriver = { state = state, driver = driver }
end

local function fakeTex(parent)
  local tex = { parent = parent }
  function tex:SetAllPoints(target) self.all = target or parent end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  return tex
end

local function fakeFont()
  local fs = { text = "" }
  function fs:SetPoint() end
  function fs:SetText(text) self.text = text or "" end
  function fs:SetTextColor() end
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
    children = {},
    attributes = {},
  }
  function frame:SetFrameStrata(strata) self.strata = strata end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level end
  function frame:EnableMouse(enabled) self.mouse = enabled and true or false end
  function frame:SetMovable(enabled) self.movable = enabled and true or false end
  function frame:SetClampedToScreen() end
  function frame:SetClampRectInsets() end
  function frame:SetScale(scale) self.scale = scale end
  function frame:GetScale() return self.scale end
  function frame:SetSize(width, height)
    self.width, self.height = width, height
  end
  function frame:GetWidth() return self.width end
  function frame:GetHeight() return self.height end
  function frame:SetAllPoints(target) self.allPoints = target end
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
  function frame:GetTop()
    return (self.bottom or 0) + (self.height or 0) * (self.scale or 1)
  end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown == true end
  function frame:SetShown(shown) self.shown = shown and true or false end
  function frame:RegisterForDrag(...) self.dragButtons = { ... } end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:CreateTexture() return fakeTex(self) end
  function frame:CreateFontString() return fakeFont() end
  function frame:SetBackdrop() end
  function frame:SetBackdropColor() end
  function frame:SetBackdropBorderColor() end
  function frame:SetAttribute(key, value) self.attributes[key] = value end
  if parent and parent.children then
    parent.children[#parent.children + 1] = frame
  end
  return frame
end

function Addon:ApplyBarChrome() end
function Addon:CreateBarButton(parent, id, actionSlot)
  local button = CreateFrame("Button", "ShadowUIActionButton" .. id, parent)
  button.id = id
  button.initialAction = actionSlot
  button.states = {}
  function button:SetState(state, kind, action)
    self.states[state] = { kind = kind, action = action }
  end
  return button
end

assert(loadfile(root .. "bars/bar.lua"))()
assert(loadfile(root .. "bars/overlay.lua"))()

Addon.editMode = false
local bar = Addon:CreateBar("bar1", {
  buttons = 12, buttonSize = 36, columns = 12, scale = 1, x = 0, y = 0, point = "CENTER",
})
local overlay = bar.dragOverlay
local grip = overlay.resizeGrip
assert(grip, "Bar overlay has a resize grip")
assert(grip.shown == false, "resize grip stays hidden in play mode")
assert(grip.mouse == false, "resize grip does not eat clicks in play mode")

local paged = Addon:CreateBar("bar2", {
  buttons = 12, buttonSize = 36, columns = 12, scale = 1, x = 0, y = 36, point = "CENTER",
  stancePages = { 73, 85, 97 },
})
assert(paged.buttons[1].name == "ShadowUIActionButton73", "paged Bar keeps Battle slot button names")
assert(paged.buttons[1].states[1].action == 73, "Battle state starts at slot 73")
assert(paged.buttons[1].states[2].action == 85, "Defensive state starts at slot 85")
assert(paged.buttons[1].states[3].action == 97, "Berserker state starts at slot 97")
assert(paged.buttons[12].states[3].action == 108, "Berserker state ends at slot 108")
assert(paged.stateDriver.driver == "[bonusbar:3] 3; [bonusbar:2] 2; [bonusbar:1] 1; 1",
  "bonus-bar driver pages Warrior stances")
assert(paged.attributes["_onstate-page"]:find("ChildUpdate", 1, true), "state driver updates every button")

local formBar = Addon:CreateBar("bar3", {
  buttons = 12, buttonSize = 36, columns = 12, scale = 1, x = 0, y = 72, point = "CENTER",
  stancePages = { 1, 73, 85, 97 },
})
assert(formBar.stateDriver.driver == "[bonusbar:3] 4; [bonusbar:2] 3; [bonusbar:1] 2; 1",
  "Druid driver keeps Caster when no bonus bar")
assert(formBar.buttons[1].states[1].action == 1, "Caster state starts at slot 1")
assert(formBar.buttons[1].states[2].action == 73, "Cat state starts at slot 73")

local stealthBar = Addon:CreateBar("bar4", {
  buttons = 12, buttonSize = 36, columns = 12, scale = 1, x = 0, y = 108, point = "CENTER",
  stancePages = { 1, 73 },
})
assert(stealthBar.stateDriver.driver == "[bonusbar:1] 2; 1",
  "Rogue driver pages Stealth onto bonus bar 1")

Addon.editMode = true
Addon:UpdateBarLayout(bar, { buttons = 12, buttonSize = 36, columns = 12, scale = 1, x = 0, y = 0 })
assert(overlay.shown == true, "overlay shows in Layout Edit Mode")
assert(grip.shown == true, "resize grip shows in Layout Edit Mode")
assert(grip.mouse == true, "resize grip receives the drag")

local patch
function Addon:GetCharDB()
  return { editLayer = "variant" }
end
function Addon:WriteLayerDelta(layer, section, key, value)
  patch = { layer = layer, section = section, key = key, value = value }
end
function Addon:ApplyAll()
  self.applied = (self.applied or 0) + 1
end
assert(loadfile(root .. "edit/mode.lua"))()

Addon.editMode = true
bar.left, bar.bottom = 32.4, 64.8
Addon:PersistBarPosition(bar)
assert(patch.key == "bar1", "move persist writes the Bar")
assert(patch.value.columns == nil, "move persist does not write columns")
assert(patch.value.scale == nil, "move persist does not write scale")

Addon:PersistBarPosition(bar, true)
assert(patch.value.columns == 12, "resize persist writes columns")
assert(patch.value.scale == nil, "resize persist does not write scale")
assert(patch.value.x == 32.4 and patch.value.y == 64.8, "resize persist keeps the snapped place")

local cursorX, cursorY = 0, 0
_G.GetCursorPosition = function() return cursorX, cursorY end
bar.left, bar.bottom = 0, 400
cursorX, cursorY = 108, 292
grip.script_OnMouseDown(grip, "LeftButton")
local updater = grip.script_OnUpdate or overlay.script_OnUpdate
assert(updater, "resize grip tracks the cursor")
updater(grip)
assert(bar.columns == 3, "drag consolidates to 3 columns")
assert(bar.width == 108 and bar.height == 144, "drag expands to 4 rows")
assert(bar.scale == 1, "resize does not change scale")
local last = bar.buttons[12]
assert(last.points[#last.points][4] == 72, "last button sits in column 3")
assert(last.points[#last.points][5] == -108, "last button sits in row 4")
assert(bar.bottom == 292, "top-left stays while the grid grows down")
grip.script_OnMouseUp(grip, "LeftButton")
assert(patch.value.columns == 3, "mouse up writes the new columns")
assert(patch.value.scale == nil, "mouse up does not write scale")

Addon:UpdateBarLayout(bar, { buttons = 12, buttonSize = 36, columns = 12, scale = 1, x = 0, y = 0 })
bar.left, bar.bottom = 0, 400
cursorX, cursorY = 426, 404
overlay.script_OnMouseDown(overlay, "LeftButton")
cursorX, cursorY = 108, 292
updater = overlay.script_OnUpdate or grip.script_OnUpdate
assert(updater, "overlay tracks a corner resize")
updater(overlay)
assert(bar.columns == 3, "overlay corner drag consolidates to 3 columns")
assert(bar.width == 108 and bar.height == 144, "overlay corner drag expands to 4 rows")
overlay.script_OnMouseUp(overlay, "LeftButton")
assert(patch.value.columns == 3, "overlay mouse up writes the new columns")

Addon:UpdateBarLayout(bar, { buttons = 12, buttonSize = 36, columns = 12, scale = 1.2, x = 0, y = 0 })
bar.left, bar.bottom = 0, 400
cursorX, cursorY = 259.2, 356.8
grip.script_OnMouseDown(grip, "LeftButton")
updater = grip.script_OnUpdate or overlay.script_OnUpdate
updater(grip)
assert(bar.columns == 6, "scaled drag still consolidates columns")
assert(bar.scale == 1.2, "resize leaves scale in place")
assert(math.abs(bar.bottom - 356.8) < 0.01, "scaled resize keeps the top-left")
grip.script_OnMouseUp(grip, "LeftButton")
assert(patch.value.columns == 6, "scaled resize writes columns")
assert(patch.value.scale == nil, "scaled resize does not write scale")

print("edit_bars_spec OK")
