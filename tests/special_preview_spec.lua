-- Layout Edit Mode previews Special Bars for every class.
-- Play mode still hides class-gated bars. Empty pet and possess stay up in edit.
-- ShadowUI does not create stance, aura, or form bars.
-- Run: lua tests/special_preview_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.SetActionBarToggles = function() end
_G.UnitExists = function() return false end
_G.GetPossessInfo = function() return nil end
_G.GetPetActionInfo = function() return nil end
_G.GetSpellInfo = function() return nil end

assert(loadfile(root .. "bars/manager.lua"))()
assert(loadfile(root .. "bars/special.lua"))()
assert(loadfile(root .. "bars/pet.lua"))()

function Addon:GetPlayerClass() return "MAGE" end
function Addon:ApplyActionSlotLock() end
function Addon:StartSpecialBarUpdates() end
function Addon:HideBlizzardBars() end
function Addon:BindPetButton(button)
  button.bound = true
end
function Addon:UpdateBarLayout(bar, cfg)
  bar.layoutButtons = cfg.buttons
end
function Addon:UpdateBarDragOverlay(bar, editable)
  bar.overlayEditable = editable
end
function Addon:CreateBar(barId, cfg)
  local bar = {
    barId = barId,
    buttons = {},
    shown = true,
  }
  function bar:Show() self.shown = true end
  function bar:Hide() self.shown = false end
  function bar:SetShown(shown) self.shown = shown and true or false end
  for i = 1, cfg.buttons or 12 do
    local button = { icon = {} }
    function button:SetState() end
    function button:SetAttribute() end
    function button:SetChecked() end
    function button:SetShown(shown) self.shown = shown and true or false end
    function button.icon:SetTexture(texture) button.texture = texture end
    function button.icon:SetShown(shown) button.iconShown = shown and true or false end
    bar.buttons[i] = button
  end
  return bar
end

Addon.Defaults = {
  base = {
    layout = {
      pet = { enabled = true, buttons = 10 },
      possess = { enabled = true, buttons = 2 },
    },
  },
  classes = {
    WARRIOR = { layout = {} },
    PALADIN = { layout = {} },
    DRUID = { layout = {} },
  },
}

local playLayout = {
  layout = {
    bar1 = { enabled = true, buttons = 12 },
    pet = { enabled = true, buttons = 10 },
    possess = { enabled = true, buttons = 2 },
    stance = { enabled = true, point = "CENTER", x = 0, y = -84 },
    aura = { enabled = true, buttons = 6 },
    form = { enabled = true, buttons = 5 },
  },
}

Addon.editMode = false
Addon:ApplyBars(playLayout)
assert(Addon.bars.bar1, "standard Bar is created")
assert(Addon.bars.pet == nil, "mage must not create a pet bar in play")
assert(Addon.bars.stance == nil, "mage must not create a stance bar")
assert(Addon.bars.aura == nil, "mage must not create an aura bar")
assert(Addon.bars.form == nil, "mage must not create a form bar")

Addon.editMode = true
Addon:ApplyBars(playLayout)
Addon:RefreshSpecialBars()
assert(Addon.bars.pet, "Layout Edit Mode previews the pet bar for every class")
assert(Addon.bars.pet.shown == true, "Layout Edit Mode shows the pet bar with no pet")
assert(Addon.bars.possess, "Layout Edit Mode previews the possess bar for every class")
assert(Addon.bars.possess.shown == true, "Layout Edit Mode shows the possess bar when empty")
assert(Addon.bars.stance == nil, "Layout Edit Mode does not create a stance bar")
assert(Addon.bars.aura == nil, "Layout Edit Mode does not create an aura bar")
assert(Addon.bars.form == nil, "Layout Edit Mode does not create a form bar")
assert(Addon.bars.pet.buttons[1].shown == true, "Layout Edit Mode shows empty pet buttons")

Addon.editMode = false
Addon:ApplyBars(playLayout)
Addon:RefreshSpecialBars()
assert(Addon.bars.pet.shown == false, "play mode hides the mage pet preview")
assert(Addon.bars.possess.shown == false, "play mode hides the empty possess bar")

print("special_preview_spec OK")
