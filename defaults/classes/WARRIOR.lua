--[[
  Purpose: Shipped WARRIOR stance layout and Action Deck.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.WARRIOR
  Notes: actions[] is the Action Deck. Every entry body-matches; collisions use createName.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local HAMSTRING_MATCH = "/cast [stance:2] Battle Stance\n/cast Hamstring"
local CHARGE_MATCH = "/cast [nocombat,nostance:1] Battle Stance; [combat,nostance:3] Berserker Stance\n/cast [nocombat] Charge; Intercept"
local INTERRUPT_MATCH = "/stopcasting\n/startattack\n/cast [noequipped:Shields,nostance:3] Berserker Stance\n/cast [stance:3] Pummel; [equipped:Shields] Shield Bash"
local EXECUTE_MATCH = "/cast [stance:2] Battle Stance\n/cast Execute"
local INTIMIDATING_MATCH = "/cast Intimidating Shout\n/stopattack"
local SHOUT_MATCH = "[mod:shift] Demoralizing Shout; Battle Shout"
local DISARM_MATCH = "/cast [nostance:2] Defensive Stance\n/cast Disarm"
local BERSERKER_RAGE_MATCH = "/cast [nostance:3] Berserker Stance\n/cast Berserker Rage"
local HEROIC_STRIKE_MATCH = "/cast Heroic Strike"
local MAJOR_COOLDOWN_MATCH = "/cast [stance:1] Retaliation; [stance:2] Shield Wall; Recklessness"
local SWEEPING_STRIKES_MATCH = "/cast [nostance:1] Battle Stance\n/cast Sweeping Strikes"

-- actions[] is the Action Deck: catalog id + in-game macro name + required
-- body match. Physical keys live on Base.
local function act(id, name, extra)
  local entry = extra or {}
  entry.id = id
  entry.name = name
  return entry
end

Addon.Defaults.classes.WARRIOR = {
  layout = {
    -- The main Bar follows the three Warrior stance pages. The remaining
    -- Bars expose every non-stance Action Slot once.
    bar1 = { stancePages = { 73, 85, 97 } },
    bar2 = { firstSlot = 1 },
    bar3 = { firstSlot = 13 },
    bar4 = { firstSlot = 25 },
    bar5 = { firstSlot = 37 },
    bar6 = { firstSlot = 49 },
    bar7 = { firstSlot = 61 },
    bar8 = { firstSlot = 109 },
    bar9 = { enabled = false },
    bar10 = { enabled = false },
  },
  deckSlots = {
    { 1, 12 },
    { 73, 111 },
  },
  keybinds = {},
  actions = {
    -- Fixed utility row.
    [1] = act("w-hm", "hm", {
      match = HAMSTRING_MATCH, createName = "suiHamstring",
    }),
    [2] = act("w-charge", "charge", {
      match = CHARGE_MATCH, createName = "suiCharge",
    }),
    [3] = act("w-c", "c", {
      match = "Cleave", notMatch = "Cannibalize", createName = "cleave",
    }),
    [4] = act("w-interrupt", "wkick", {
      match = INTERRUPT_MATCH, createName = "suiKick",
    }),
    [5] = act("w-bloodrage", "brage", { match = "Bloodrage" }),
    [6] = act("w-intimid", "is", {
      match = INTIMIDATING_MATCH, createName = "suiFear",
    }),
    [7] = act("w-disarm", "disarm", { match = DISARM_MATCH, createName = "disarm" }),
    [9] = act("w-br", "br", {
      match = BERSERKER_RAGE_MATCH, createName = "suiBersRage",
    }),
    [10] = act("w-shout", "bshout", { match = SHOUT_MATCH, createName = "shout" }),

    -- Battle: signature on 1 comes from the Variant.
    [74] = act("w-o", "o", { match = "Overpower" }),
    [75] = act("w-h", "h", {
      match = HEROIC_STRIKE_MATCH, createName = "suiHeroic",
    }),
    [76] = act("w-ex", "ex", {
      match = EXECUTE_MATCH, createName = "suiExecute",
    }),
    [77] = act("w-rend", "rend", { match = "Rend" }),
    [78] = act("w-tc", "tc", { match = "Thunder Clap" }),
    [79] = act("w-ds", "ds", {
      match = "Demoralizing Shout", createName = "demoral",
    }),
    [82] = act("w-major-cd", "major", {
      match = MAJOR_COOLDOWN_MATCH, createName = "suiMajor",
    }),
    [83] = act("w-mock", "mb", {
      match = "Mocking Blow", createName = "mockblow",
    }),

    -- Defensive.
    [86] = act("w-revenge", "rev", { match = "Revenge" }),
    [87] = act("w-h", "h", {
      match = HEROIC_STRIKE_MATCH, createName = "suiHeroic",
    }),
    [88] = act("w-ex", "ex", {
      match = EXECUTE_MATCH, createName = "suiExecute",
    }),
    [89] = act("w-s", "s", { match = "Sunder Armor" }),
    [90] = act("w-sblock", "sbk", { match = "Shield Block" }),
    [91] = act("w-ds", "ds", {
      match = "Demoralizing Shout", createName = "demoral",
    }),
    [94] = act("w-major-cd", "major", {
      match = MAJOR_COOLDOWN_MATCH, createName = "suiMajor",
    }),
    [95] = act("w-taunt", "a", { match = "Taunt", createName = "taunt" }),

    -- Berserker.
    [98] = act("w-ww", "ww", { match = "Whirlwind" }),
    [99] = act("w-h", "h", {
      match = HEROIC_STRIKE_MATCH, createName = "suiHeroic",
    }),
    [100] = act("w-ex", "ex", {
      match = EXECUTE_MATCH, createName = "suiExecute",
    }),
    [101] = act("w-s", "s", { match = "Sunder Armor" }),
    [102] = act("w-br", "br", {
      match = BERSERKER_RAGE_MATCH, createName = "suiBersRage",
    }),
    [103] = act("w-ds", "ds", {
      match = "Demoralizing Shout", createName = "demoral",
    }),
    [106] = act("w-major-cd", "major", {
      match = MAJOR_COOLDOWN_MATCH, createName = "suiMajor",
    }),
    [107] = act("w-chall", "ch", {
      match = "Challenging Shout", createName = "challshout",
    }),

    -- Stances stay fixed while the main Bar pages.
    [109] = act("w-b", "b", { match = "Battle Stance" }),
    [110] = act("w-d-def", "d", {
      match = "Defensive Stance", notMatch = "Disarm", createName = "defstan",
    }),
    [111] = act("w-bs", "bs", {
      match = "Berserker Stance", createName = "bstan",
    }),
  },
  variants = {
    Arms = {
      talentTree = 1,
      layout = {},
      keybinds = {},
      actions = {
        [1] = act("w-h", "h", {
          match = HEROIC_STRIKE_MATCH,
          createName = "suiHeroic",
        }),
        [2] = act("w-o", "o", { match = "Overpower" }),
        [3] = act("w-ww", "ww", { match = "Whirlwind" }),
        [4] = act("w-bloodrage", "brage", { match = "Bloodrage" }),
        [5] = act("w-hm", "hm", {
          match = HAMSTRING_MATCH,
          createName = "suiHamstring",
        }),
        [6] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [8] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [9] = false,
        [10] = act("w-retal", "ret", { match = "Retaliation" }),
        [11] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [12] = act("w-reck", "rk", { match = "Recklessness" }),
        [73] = act("w-s", "s", { match = "Sunder Armor" }),
        [74] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [75] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
        [76] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [78] = act("w-interrupt", "wkick", {
          match = INTERRUPT_MATCH,
          createName = "suiKick",
        }),
        [79] = act("w-ex", "ex", {
          match = EXECUTE_MATCH,
          createName = "suiExecute",
        }),
        [80] = act("w-taunt", "a", {
          match = "Taunt",
          createName = "taunt",
        }),
        [81] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [82] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [83] = act("w-dual", "dual", { match = "equipslot" }),
        [84] = act("w-rend", "rend", { match = "Rend" }),
        [85] = act("w-s", "s", { match = "Sunder Armor" }),
        [86] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [87] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
        [88] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [89] = act("w-rend", "rend", { match = "Rend" }),
        [90] = act("w-interrupt", "wkick", {
          match = INTERRUPT_MATCH,
          createName = "suiKick",
        }),
        [91] = act("w-ex", "ex", {
          match = EXECUTE_MATCH,
          createName = "suiExecute",
        }),
        [92] = act("w-taunt", "a", {
          match = "Taunt",
          createName = "taunt",
        }),
        [93] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [94] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [95] = act("w-dual", "dual", { match = "equipslot" }),
        [96] = act("w-rend", "rend", { match = "Rend" }),
        [97] = act("w-s", "s", { match = "Sunder Armor" }),
        [98] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [99] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
        [100] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [101] = act("w-rend", "rend", { match = "Rend" }),
        [102] = act("w-interrupt", "wkick", {
          match = INTERRUPT_MATCH,
          createName = "suiKick",
        }),
        [103] = act("w-ex", "ex", {
          match = EXECUTE_MATCH,
          createName = "suiExecute",
        }),
        [104] = act("w-taunt", "a", {
          match = "Taunt",
          createName = "taunt",
        }),
        [105] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [106] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [107] = act("w-dual", "dual", { match = "equipslot" }),
        [108] = act("w-rend", "rend", { match = "Rend" }),
        [109] = false,
        [110] = false,
        [111] = false,
      },
    },
    Fury = {
      talentTree = 2,
      layout = {},
      keybinds = {},
      actions = {
        [1] = act("w-h", "h", {
          match = HEROIC_STRIKE_MATCH,
          createName = "suiHeroic",
        }),
        [2] = act("w-o", "o", { match = "Overpower" }),
        [3] = act("w-ww", "ww", { match = "Whirlwind" }),
        [4] = act("w-bloodrage", "brage", { match = "Bloodrage" }),
        [5] = act("w-hm", "hm", {
          match = HAMSTRING_MATCH,
          createName = "suiHamstring",
        }),
        [6] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [8] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [9] = act("w-intimid", "is", {
          match = INTIMIDATING_MATCH,
          createName = "suiFear",
        }),
        [10] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [11] = act("w-major-cd", "major", {
          match = MAJOR_COOLDOWN_MATCH,
          createName = "suiMajor",
        }),
        [12] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [73] = act("w-s", "s", { match = "Sunder Armor" }),
        [74] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [75] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
        [76] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [78] = act("w-interrupt", "wkick", {
          match = INTERRUPT_MATCH,
          createName = "suiKick",
        }),
        [79] = act("w-ex", "ex", {
          match = EXECUTE_MATCH,
          createName = "suiExecute",
        }),
        [80] = act("w-taunt", "a", {
          match = "Taunt",
          createName = "taunt",
        }),
        [81] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [82] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [83] = act("w-dual", "dual", { match = "equipslot" }),
        [84] = act("w-rend", "rend", { match = "Rend" }),
        [85] = act("w-s", "s", { match = "Sunder Armor" }),
        [97] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [109] = false,
        [110] = false,
        [111] = false,
      },
    },
    Protection = {
      talentTree = 3,
      layout = {},
      keybinds = {},
      actions = {
        [1] = act("w-h", "h", {
          match = HEROIC_STRIKE_MATCH,
          createName = "suiHeroic",
        }),
        [2] = act("w-o", "o", { match = "Overpower" }),
        [3] = act("w-ww", "ww", { match = "Whirlwind" }),
        [4] = act("w-bloodrage", "brage", { match = "Bloodrage" }),
        [5] = act("w-hm", "hm", {
          match = HAMSTRING_MATCH,
          createName = "suiHamstring",
        }),
        [6] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [8] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [9] = false,
        [10] = act("w-retal", "ret", { match = "Retaliation" }),
        [11] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [12] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [73] = act("w-s", "s", { match = "Sunder Armor" }),
        [74] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [75] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
        [76] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [78] = act("w-interrupt", "wkick", {
          match = INTERRUPT_MATCH,
          createName = "suiKick",
        }),
        [79] = act("w-ex", "ex", {
          match = EXECUTE_MATCH,
          createName = "suiExecute",
        }),
        [80] = act("w-taunt", "a", {
          match = "Taunt",
          createName = "taunt",
        }),
        [81] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [82] = false,
        [83] = act("w-dual", "dual", { match = "equipslot" }),
        [84] = act("w-rend", "rend", { match = "Rend" }),
        [85] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [97] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
      },
    },
  },
}
