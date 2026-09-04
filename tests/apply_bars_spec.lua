-- ApplyBars must create ShadowUI bars before it skins Blizzard bars.
-- If create throws after that restyle, the player is left with no bars.
-- Run: lua tests/apply_bars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.SetActionBarToggles = function() end

assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "bars/manager.lua"))()

local events = {}
function Addon:GetPlayerClass() return "MAGE" end
function Addon:CreateBar(barId, cfg)
  events[#events + 1] = { "create", barId }
  return {
    buttons = {},
    configEnabled = nil,
    Show = function(self) events[#events + 1] = { "show", barId } end,
    Hide = function() events[#events + 1] = { "hide", barId } end,
  }
end
function Addon:CreateSpecialBar(barId)
  events[#events + 1] = { "create-special", barId }
  return {
    buttons = {},
    Show = function() end,
    Hide = function() end,
  }
end
function Addon:UpdateBarLayout(bar, cfg)
  events[#events + 1] = { "layout", bar.barId or cfg }
  bar.lastLayout = cfg
end
function Addon:StartSpecialBarUpdates() end
function Addon:RefreshSpecialBars() end
function Addon:ApplyActionSlotLock() end

local hiddenBeforeCreate = false
function Addon:HideBlizzardBars()
  for _, event in ipairs(events) do
    if event[1] == "create" then
      events[#events + 1] = { "hide-blizzard" }
      return
    end
  end
  hiddenBeforeCreate = true
  events[#events + 1] = { "hide-blizzard" }
end

Addon:ApplyBars({
  layout = {
    bar1 = { enabled = true, buttons = 12 },
    bar2 = { enabled = true, buttons = 12 },
    pet = { enabled = true, buttons = 10 },
  },
})

assert(not hiddenBeforeCreate, "HideBlizzardBars ran before any ShadowUI bar existed")
assert(Addon.bars.bar1, "bar1 must be created")
assert(Addon.bars.bar2, "bar2 must be created")
assert(Addon.bars.pet == nil, "mage must not create a pet bar")

Addon:ApplyBars({
  layout = {
    bar1 = { enabled = true, buttons = 12 },
    bar2 = { enabled = false, buttons = 12 },
  },
})
assert(Addon.bars.bar2.configEnabled == false, "disabled Bar stays created but off")
local hidBar2 = false
for _, event in ipairs(events) do
  if event[1] == "hide" and event[2] == "bar2" then
    hidBar2 = true
  end
end
assert(hidBar2, "disabled Bar hides")

Addon:ApplyBars({
  layout = {
    bar9 = { enabled = false, buttons = 12 },
  },
})
assert(Addon.bars.bar9, "disabled standard Bar is still created")
assert(Addon.bars.bar9.configEnabled == false, "disabled standard Bar stays off")

local shown = false
local hidden = false
local extra = {
  specialId = nil,
  configEnabled = false,
  Show = function() shown = true end,
  Hide = function() hidden = true end,
}
Addon.bars.bar10 = extra
Addon:ShowBarsForActionPlacement(true)
assert(shown, "a pickup shows a disabled standard Bar")
Addon:ShowBarsForActionPlacement(false)
assert(hidden, "ending a pickup hides a disabled standard Bar")

local petShown = false
Addon.bars.pet = {
  specialId = "pet",
  configEnabled = false,
  Show = function() petShown = true end,
  Hide = function() end,
}
Addon:ShowBarsForActionPlacement(true)
assert(not petShown, "a pickup does not show a Special Bar that is off")

Addon:ApplyBars({
  layout = {
    global = { gap = 4, iconShape = "circle" },
    barGroups = { Main = { members = { bar1 = true }, gap = 2 } },
    bar1 = { enabled = true, buttons = 12 },
  },
})
assert(Addon.bars.global == nil, "Global is not a Bar")
assert(Addon.bars.barGroups == nil, "Bar Groups is not a Bar")
assert(Addon.bars.bar1.lastLayout.gap == 4, "ApplyBars fills Global gap")
assert(Addon.bars.bar1.lastLayout.iconShape == "circle", "ApplyBars fills Global shape")

Addon:ApplyBars({
  layout = {
    barGroups = { Stack = { gapAbove = 2, gapBelow = 6 } },
    bar1 = {
      enabled = true, buttons = 12, group = "Stack",
      gapAbove = 9, gapBelow = 9,
    },
    bar3 = { enabled = true, buttons = 12, group = "Stack" },
  },
})
assert(Addon.bars.bar1.lastLayout.rowGaps[1].above == 2
  and Addon.bars.bar1.lastLayout.rowGaps[1].below == 6,
  "grouped Bar apply uses Bar Group row pads")
assert(Addon.bars.bar3.lastLayout.rowGaps[1].above == 2
  and Addon.bars.bar3.lastLayout.rowGaps[1].below == 6,
  "every grouped Bar gets the same row pads")

print("apply_bars_spec OK")
