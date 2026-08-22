-- Loads core/resolve.lua against a stub addon table. Run: lua tests/resolve_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()

local account, char
local function reset()
  account = {
    base = { layout = { bar1 = { y = 40 } }, keybinds = {} },
    classes = {
      DRUID = {
        layout = { bar1 = { scale = 1.1 } },
        keybinds = {},
        variants = {
          Feral = { talentTree = 2, layout = { bar1 = { scale = 1.2 } }, keybinds = {} },
        },
      },
    },
  }
  char = { activeVariant = nil, editLayer = "variant", variantManual = false }
end
function Addon:GetDB() return account end
function Addon:GetCharDB() return char end
function Addon:GetPlayerClass() return "DRUID" end
Addon.Defaults = {
  base = { layout = { bar1 = { x = 0, y = 0, scale = 1, enabled = true } }, keybinds = {} },
  classes = { DRUID = { layout = { form = { x = 10, y = -84, enabled = true } }, keybinds = {} } },
}

local function stubTalents(tabs)
  _G.GetNumTalentTabs = function() return #tabs end
  _G.GetTalentTabInfo = function(i) return table.unpack(tabs[i]) end
end

reset()

-- Sparse merge keeps untouched fields and copies nested tables by value.
local eff = Addon:ResolveEffective("DRUID", "Feral")
assert(eff.layout.bar1.x == 0, "base x survives")
assert(eff.layout.bar1.y == 40, "account base wins over shipped base")
assert(eff.layout.bar1.scale == 1.2, "variant wins over class")
assert(eff.layout.bar1.enabled == true, "shipped flag survives")
assert(eff.layout.form.x == 10, "shipped class delta merges")
Addon.Defaults.base.layout.bar1.x = 99
assert(eff.layout.bar1.x == 0, "resolve does not alias shipped defaults")
Addon.Defaults.base.layout.bar1.x = 0

-- Talent point slot differs by client: 3rd on Classic Era, 5th when modernized.
assert(Addon:TalentPointsFromTabInfo("Feral", "tex", 31, "bg", 0, true) == 31, "classic shape")
assert(Addon:TalentPointsFromTabInfo(1, "Feral", "desc", "tex", 41) == 41, "modern shape")
assert(Addon:TalentPointsFromTabInfo("Feral", "tex") == 0, "no numeric slot")
assert(Addon:TalentPointsFromTabInfo(nil, nil, nil, nil, nil) == 0, "empty returns zero")

stubTalents({
  { "Balance", "tex", 8, "bg", 0, true },
  { "Feral", "tex", 31, "bg", 0, true },
  { "Resto", "tex", 0, "bg", 0, true },
})
assert(Addon:GetPrimaryTalentTree() == 2, "classic returns highest tab")

stubTalents({
  { 1, "Balance", "desc", "tex", 5 },
  { 2, "Feral", "desc", "tex", 3 },
  { 3, "Resto", "desc", "tex", 34 },
})
assert(Addon:GetPrimaryTalentTree() == 3, "modern returns highest tab")

stubTalents({ { "Balance", "tex", 0 }, { "Feral", "tex", 0 } })
assert(Addon:GetPrimaryTalentTree() == nil, "no points spent means no tree")

_G.GetNumTalentTabs, _G.GetTalentTabInfo = nil, nil
assert(Addon:GetPrimaryTalentTree() == nil, "missing talent API does not error")

-- Variant selection: talent bind when automatic, stored name when manual.
stubTalents({ { "Balance", "tex", 8 }, { "Feral", "tex", 31 } })
assert(Addon:GetActiveVariantName("DRUID") == "Feral", "talent tree selects variant")
char.variantManual, char.activeVariant = true, "Balance"
assert(Addon:GetActiveVariantName("DRUID") == "Balance", "manual override wins")

-- Layer writes land in the selected layer only.
reset()
Addon:WriteLayerDelta("base", "layout", "bar1", { x = 5 })
assert(account.base.layout.bar1.x == 5 and account.base.layout.bar1.y == 40, "base patch merges")
Addon:WriteLayerDelta("class", "layout", "bar2", { x = 7 })
assert(account.classes.DRUID.layout.bar2.x == 7, "class patch merges")
char.variantManual, char.activeVariant = true, "Feral"
Addon:WriteLayerDelta("variant", "layout", "bar1", { y = 9 })
assert(account.classes.DRUID.variants.Feral.layout.bar1.y == 9, "variant patch merges")
assert(account.classes.DRUID.variants.Feral.layout.bar1.scale == 1.2, "variant keeps siblings")

-- Scalar Keybind writes replace the binding name; false is a tombstone.
Addon:WriteLayerDelta("base", "keybinds", "CLICK ShadowUIActionButton1:Keybind", "Q")
assert(account.base.keybinds["CLICK ShadowUIActionButton1:Keybind"] == "Q", "base keybind is a string")
Addon:WriteLayerDelta("base", "keybinds", "CLICK ShadowUIActionButton1:Keybind", false)
assert(account.base.keybinds["CLICK ShadowUIActionButton1:Keybind"] == false, "false unbinds on the layer")

print("resolve_spec OK")
