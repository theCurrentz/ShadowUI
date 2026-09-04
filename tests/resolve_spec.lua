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
        layout = { bar1 = { scale = 1.1, fadeIdle = 0.5, iconShape = "circle" } },
        keybinds = {},
        variants = {
          Feral = {
            talentTree = 2,
            layout = { bar1 = { scale = 1.2, fadeIdle = 0.2, iconShape = "diamond" } },
            keybinds = {},
          },
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
  base = { layout = { bar1 = { x = 0, y = 0, scale = 1, fadeIdle = 1, iconShape = "square", enabled = true } }, keybinds = {} },
  classes = { DRUID = { layout = { pet = { x = 10, y = 0, enabled = true } }, keybinds = {} } },
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
assert(eff.layout.bar1.fadeIdle == 0.2, "variant fadeIdle wins over class")
assert(eff.layout.bar1.iconShape == "diamond", "variant iconShape wins over class")
assert(eff.layout.bar1.enabled == true, "shipped flag survives")
assert(eff.layout.pet.x == 10, "shipped class delta merges")
local throughBase = Addon:ResolveEffective("DRUID", "Feral", "base")
assert(throughBase.layout.bar1.y == 40, "through Base keeps account Base")
assert(throughBase.layout.bar1.scale == 1, "through Base skips Class and Variant")
assert(throughBase.layout.bar1.fadeIdle == 1, "through Base keeps shipped fadeIdle")
assert(throughBase.layout.bar1.iconShape == "square", "through Base keeps shipped shape")
assert(throughBase.layout.pet == nil, "through Base skips shipped Class")
local throughClass = Addon:ResolveEffective("DRUID", "Feral", "class")
assert(throughClass.layout.bar1.scale == 1.1, "through Class keeps Class")
assert(throughClass.layout.bar1.scale ~= 1.2, "through Class skips Variant")
assert(throughClass.layout.bar1.fadeIdle == 0.5, "through Class keeps Class fadeIdle")
assert(throughClass.layout.bar1.iconShape == "circle", "through Class keeps Class shape")
assert(throughClass.layout.pet.x == 10, "through Class keeps shipped Class")
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

-- Shipped Class Variants merge without an account row and do not leak onto effective config.
reset()
Addon.Defaults.classes.WARRIOR = {
  layout = {},
  keybinds = {
    ["CLICK ShadowUIActionButton3:Keybind"] = "3",
    ["CLICK ShadowUIActionButton13:Keybind"] = "Q",
  },
  variants = {
    Fury = {
      talentTree = 2,
      layout = {},
      keybinds = { ["CLICK ShadowUIActionButton1:Keybind"] = "1" },
    },
    Protection = {
      talentTree = 3,
      layout = {},
      keybinds = { ["CLICK ShadowUIActionButton12:Keybind"] = "H" },
    },
  },
}
account.classes.WARRIOR = { layout = {}, keybinds = {}, variants = {} }
char.variantManual, char.activeVariant = false, nil
local fury = Addon:ResolveEffective("WARRIOR", "Fury")
assert(fury.keybinds["CLICK ShadowUIActionButton3:Keybind"] == "3", "shipped Class Keybind survives")
assert(fury.keybinds["CLICK ShadowUIActionButton1:Keybind"] == "1", "shipped Fury Variant Keybind merges")
assert(fury.keybinds["CLICK ShadowUIActionButton12:Keybind"] == nil, "other Variant keys stay off Fury")
assert(fury.variants == nil, "shipped variants table does not leak onto effective config")
local prot = Addon:ResolveEffective("WARRIOR", "Protection")
assert(prot.keybinds["CLICK ShadowUIActionButton12:Keybind"] == "H", "Protection Variant adds H")
assert(prot.keybinds["CLICK ShadowUIActionButton1:Keybind"] == nil, "Fury keys stay off Protection")

stubTalents({
  { "Arms", "tex", 0, "bg", 0, true },
  { "Fury", "tex", 31, "bg", 0, true },
  { "Protection", "tex", 0, "bg", 0, true },
})
assert(Addon:GetActiveVariantName("WARRIOR") == "Fury", "shipped talent tree selects Variant with empty account variants")

-- Character Layer is a sparse last overlay. through Variant skips it.
reset()
char.layout = { bar1 = { scale = 1.5 } }
char.keybinds = { ["CLICK ShadowUIActionButton1:Keybind"] = "F1" }
account.classes.DRUID.variants.Feral.keybinds = {
  ["CLICK ShadowUIActionButton1:Keybind"] = "1",
}
local withChar = Addon:ResolveEffective("DRUID", "Feral")
assert(withChar.layout.bar1.scale == 1.5, "Character Layout wins over Variant")
assert(withChar.keybinds["CLICK ShadowUIActionButton1:Keybind"] == "F1",
  "Character Keybind wins over Variant")
local throughVariant = Addon:ResolveEffective("DRUID", "Feral", "variant")
assert(throughVariant.layout.bar1.scale == 1.2, "through Variant skips Character")
assert(throughVariant.keybinds["CLICK ShadowUIActionButton1:Keybind"] == "1",
  "through Variant keeps Variant Keybind")

reset()
Addon:WriteLayerDelta("character", "layout", "bar1", { x = 11 })
assert(char.layout.bar1.x == 11, "character Layout patch writes CharDB")
assert(account.base.layout.bar1.x == nil, "character Layout does not write Account")
Addon:WriteLayerDelta("character", "keybinds", "CLICK ShadowUIActionButton2:Keybind", "E")
assert(char.keybinds["CLICK ShadowUIActionButton2:Keybind"] == "E",
  "character Keybind writes CharDB")

-- Bar visual fields inherit Bar → Bar Group → Global → defaults.
local visualLayout = {
  global = { gap = 4, iconShape = "circle" },
  barGroups = {
    Main = { gap = 2, iconShape = "diamond", scale = 1.1, fadeIdle = 0.5 },
    Dead = false,
  },
  bar1 = { group = "Main" },
  bar2 = {},
  bar3 = { group = "Main", gap = 8, iconShape = "square" },
  bar4 = { group = "Missing" },
  bar5 = { group = false },
  bar6 = { group = "Dead" },
}
local grouped = Addon:ResolveBarVisual(visualLayout, "bar1")
assert(grouped.gap == 2, "Bar Group gap wins over Global")
assert(grouped.iconShape == "diamond", "Bar Group shape wins over Global")
assert(grouped.scale == 1.1, "Bar Group scale applies when the Bar has none")
assert(grouped.fadeIdle == 0.5, "Bar Group fade idle applies when the Bar has none")
local ungrouped = Addon:ResolveBarVisual(visualLayout, "bar2")
assert(ungrouped.gap == 4, "ungrouped Bar uses Global gap")
assert(ungrouped.iconShape == "circle", "ungrouped Bar uses Global shape")
assert(ungrouped.scale == 1, "missing scale defaults to 1")
assert(ungrouped.fadeIdle == 1, "missing fade idle defaults to 1")
local overridden = Addon:ResolveBarVisual(visualLayout, "bar3")
assert(overridden.gap == 8, "Bar gap wins over Bar Group")
assert(overridden.iconShape == "square", "Bar shape wins over Bar Group")
assert(overridden.scale == 1.1, "Bar scale still inherits Bar Group when unset")
local missingGroup = Addon:ResolveBarVisual(visualLayout, "bar4")
assert(missingGroup.gap == 4, "unknown Bar Group falls back to Global gap")
local cleared = Addon:ResolveBarVisual(visualLayout, "bar5")
assert(cleared.gap == 4, "cleared Bar Group falls back to Global gap")
local dead = Addon:ResolveBarVisual(visualLayout, "bar6")
assert(dead.gap == 4, "deleted Bar Group falls back to Global gap")
local absent = Addon:ResolveBarVisual(visualLayout, "bar9")
assert(absent.gap == 4, "missing Bar still inherits Global gap")
local empty = Addon:ResolveBarVisual({}, "bar1")
assert(empty.gap == 0 and empty.iconShape == "square", "no Global uses shipped visual defaults")
local applied = Addon:BarLayoutForApply(visualLayout, "bar1", visualLayout.bar1)
assert(applied.gap == 2 and applied.group == "Main", "apply layout keeps Bar fields and fills visuals")

-- A Bar Group's gap above / gap below pads every member Bar the same, so stacked
-- Bars keep one icon size. Per-Bar gapAbove / gapBelow apply only when ungrouped.
-- A 3x4 Bar is still one Row: the same pads apply on every grid line inside it.
local stackLayout = {
  barGroups = { Stack = { gapAbove = 2, gapBelow = 6 } },
  bar1 = { group = "Stack", buttons = 12, columns = 12, gapAbove = 9, gapBelow = 9 },
  bar2 = { group = "Stack", buttons = 12, columns = 12 },
  bar3 = { buttons = 12, columns = 12, gapAbove = 9, gapBelow = 9 },
  bar7 = { buttons = 12, columns = 3, gapAbove = 4, gapBelow = 8 },
}
local groupedPads = Addon:ResolveBarRowGaps(stackLayout, "bar1", stackLayout.bar1)
assert(groupedPads[1].above == 2 and groupedPads[1].below == 6,
  "grouped Bar uses Bar Group row pads")
local groupedEmpty = Addon:ResolveBarRowGaps(stackLayout, "bar2", stackLayout.bar2)
assert(groupedEmpty[1].above == 2 and groupedEmpty[1].below == 6,
  "grouped Bar without pads uses Bar Group row pads")
local ungroupedPads = Addon:ResolveBarRowGaps(stackLayout, "bar3", stackLayout.bar3)
assert(ungroupedPads[1].above == 9 and ungroupedPads[1].below == 9,
  "ungrouped Bar keeps its own gap pads")
local stackedApply = Addon:BarLayoutForApply(stackLayout, "bar1", stackLayout.bar1)
assert(stackedApply.rowGaps[1].above == 2, "apply layout fills Bar Group row pads")
local sidePads = Addon:ResolveBarRowGaps(stackLayout, "bar7", stackLayout.bar7)
assert(sidePads[1].above == 4 and sidePads[4].above == 4 and sidePads[4].below == 8,
  "a 3x4 Bar uses one Gap above and Gap below on every grid line")
local legacy = Addon:ResolveBarRowGaps(
  { bar1 = { buttons = 12, columns = 12, rowGaps = { { above = 3, below = 5 } } } },
  "bar1",
  { buttons = 12, columns = 12, rowGaps = { { above = 3, below = 5 } } }
)
assert(legacy[1].above == 3 and legacy[1].below == 5,
  "legacy rowGaps[1] still reads as this Bar's pads")

print("resolve_spec OK")
