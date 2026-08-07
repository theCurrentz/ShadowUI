-- Covers client API shape handling: status bar gradients and pet action returns.
-- Run: lua tests/api_shapes_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "cast/castbar.lua"))()
assert(loadfile(root .. "bars/pet.lua"))()

local function fakeTexture(gradient)
  local tex = { calls = {} }
  function tex:SetVertexColor(...) self.calls[#self.calls + 1] = { "vertex", ... } end
  if gradient then
    function tex:SetGradient(...) self.calls[#self.calls + 1] = { "gradient", ... } end
  end
  return tex
end

_G.CreateColor = function(r, g, b, a) return { r = r, g = g, b = b, a = a } end

local tex = fakeTexture(true)
Addon:ApplyStatusBarGradient(tex, "HORIZONTAL", { 0, 0.1, 0.2, 1 }, { 0.3, 0.4, 0.5, 1 })
assert(#tex.calls == 1 and tex.calls[1][1] == "gradient", "uses SetGradient when available")
assert(tex.calls[1][2] == "HORIZONTAL", "passes orientation")
assert(tex.calls[1][3].g == 0.1 and tex.calls[1][4].b == 0.5, "passes both ColorMixins")

tex = fakeTexture(false)
Addon:ApplyStatusBarGradient(tex, "HORIZONTAL", { 0, 0, 0, 1 }, { 0.3, 0.4, 0.5, 1 })
assert(tex.calls[1][1] == "vertex", "falls back when SetGradient is missing")
assert(tex.calls[1][2] == 0.3, "fallback uses the end colour")

tex = fakeTexture(true)
function tex:SetGradient() error("removed") end
Addon:ApplyStatusBarGradient(tex, "VERTICAL", { 0, 0, 0, 1 }, { 1, 1, 1, 1 })
assert(tex.calls[1][1] == "vertex", "falls back when SetGradient errors")

_G.CreateColor = nil
tex = fakeTexture(true)
Addon:ApplyStatusBarGradient(tex, "HORIZONTAL", { 0, 0, 0, 1 }, { 1, 1, 1, 1 })
assert(tex.calls[1][1] == "vertex", "falls back when CreateColor is missing")
Addon:ApplyStatusBarGradient(nil, "HORIZONTAL", { 0, 0, 0, 1 }, { 1, 1, 1, 1 })

local function fakeBar(count)
  local bar = { buttons = {} }
  function bar:SetShown(shown) self.shown = shown end
  for i = 1, count do
    local button = { icon = {} }
    function button.icon:SetTexture(texture) button.texture = texture end
    function button.icon:SetShown(shown) button.iconShown = shown end
    function button:SetChecked(checked) self.checked = checked end
    function button:SetShown(shown) self.shown = shown end
    bar.buttons[i] = button
  end
  return bar
end

_G.UnitExists = function() return true end
_G.PET_ATTACK_TEXTURE = "Interface\\Icons\\ABILITY_GhoulFrenzy"

-- Modernized: (name, texture, isToken, isActive). Token names resolve through _G.
_G.GetPetActionInfo = function(index)
  if index == 1 then return "PET_ACTION_ATTACK", "PET_ATTACK_TEXTURE", true, true end
  if index == 2 then return "Growl", "Interface\\Icons\\Ability_Physical_Taunt", false, false end
  return nil
end
local bar = fakeBar(3)
Addon:RefreshPetBar(bar)
assert(bar.buttons[1].texture == _G.PET_ATTACK_TEXTURE, "modern token resolves to a path")
assert(bar.buttons[1].checked == true, "modern active flag read")
assert(bar.buttons[2].texture == "Interface\\Icons\\Ability_Physical_Taunt", "plain path kept")
assert(bar.buttons[3].shown == false, "empty slot hidden")
assert(bar.shown == true, "bar shown while a pet exists")

-- Vanilla: (name, subtext, texture, isToken, isActive).
_G.GetPetActionInfo = function(index)
  if index == 1 then return "PET_ACTION_ATTACK", nil, "PET_ATTACK_TEXTURE", 1, 1 end
  return "Growl", "", "Interface\\Icons\\Ability_Physical_Taunt", nil, nil
end
bar = fakeBar(2)
Addon:RefreshPetBar(bar)
assert(bar.buttons[1].texture == _G.PET_ATTACK_TEXTURE, "vanilla token resolves to a path")
assert(bar.buttons[1].checked == true, "vanilla numeric active flag read")
assert(bar.buttons[2].texture == "Interface\\Icons\\Ability_Physical_Taunt", "vanilla path kept")

_G.GetPetActionInfo = function() return "Unknown", "MISSING_GLOBAL_TEXTURE", true, false end
bar = fakeBar(1)
Addon:RefreshPetBar(bar)
assert(bar.buttons[1].texture == "MISSING_GLOBAL_TEXTURE", "unresolved token keeps its value")

print("api_shapes_spec OK")
