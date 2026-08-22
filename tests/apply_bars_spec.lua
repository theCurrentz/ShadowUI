-- ApplyBars must create ShadowUI bars before it hides Blizzard bars.
-- If create throws after the hide, the player is left with no bars.
-- Run: lua tests/apply_bars_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.SetActionBarToggles = function() end

assert(loadfile(root .. "bars/manager.lua"))()

local events = {}
function Addon:GetPlayerClass() return "MAGE" end
function Addon:CreateBar(barId, cfg)
  events[#events + 1] = { "create", barId }
  return {
    buttons = {},
    configEnabled = nil,
    Show = function(self) events[#events + 1] = { "show", barId } end,
    Hide = function() end,
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
function Addon:UpdateBarLayout()
  events[#events + 1] = { "layout" }
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
print("apply_bars_spec OK")
