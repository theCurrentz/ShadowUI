--[[
  Purpose: Shipped WARRIOR stance layout and Action Deck.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.classes.WARRIOR
  Notes: actions[] is the Action Deck. Every entry body-matches; collisions use createName.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local act = Addon.Defaults.act
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
  keybinds = {
    ["CLICK ShadowUIActionButton1:Keybind"] = "1",
    ["CLICK ShadowUIActionButton2:Keybind"] = "2",
    ["CLICK ShadowUIActionButton3:Keybind"] = "3",
    ["CLICK ShadowUIActionButton4:Keybind"] = "4",
    ["CLICK ShadowUIActionButton5:Keybind"] = "5",
    ["CLICK ShadowUIActionButton6:Keybind"] = "`",
    ["CLICK ShadowUIActionButton7:Keybind"] = "SHIFT-Q",
    ["CLICK ShadowUIActionButton8:Keybind"] = "SHIFT-E",
    ["CLICK ShadowUIActionButton9:Keybind"] = "SHIFT-R",
    ["CLICK ShadowUIActionButton10:Keybind"] = "SHIFT-F",
    ["CLICK ShadowUIActionButton11:Keybind"] = "SHIFT-T",
    ["CLICK ShadowUIActionButton12:Keybind"] = "N",
    ["CLICK ShadowUIActionButton13:Keybind"] = "SHIFT-G",
    ["CLICK ShadowUIActionButton14:Keybind"] = "SHIFT-C",
    ["CLICK ShadowUIActionButton15:Keybind"] = "SHIFT-V",
    ["CLICK ShadowUIActionButton16:Keybind"] = "SHIFT-B",
    ["CLICK ShadowUIActionButton17:Keybind"] = "SHIFT-X",
    ["CLICK ShadowUIActionButton18:Keybind"] = "SHIFT-Z",
    ["CLICK ShadowUIActionButton19:Keybind"] = "SHIFT-H",
    ["CLICK ShadowUIActionButton20:Keybind"] = "SHIFT-N",
    ["CLICK ShadowUIActionButton21:Keybind"] = "6",
    ["CLICK ShadowUIActionButton22:Keybind"] = "7",
    ["CLICK ShadowUIActionButton23:Keybind"] = "8",
    ["CLICK ShadowUIActionButton24:Keybind"] = "9",
    ["CLICK ShadowUIActionButton25:Keybind"] = "SHIFT-1",
    ["CLICK ShadowUIActionButton26:Keybind"] = "SHIFT-2",
    ["CLICK ShadowUIActionButton27:Keybind"] = "SHIFT-3",
    ["CLICK ShadowUIActionButton28:Keybind"] = "SHIFT-4",
    ["CLICK ShadowUIActionButton29:Keybind"] = "SHIFT-5",
    ["CLICK ShadowUIActionButton30:Keybind"] = "SHIFT-`",
    ["CLICK ShadowUIActionButton31:Keybind"] = "ALT-1",
    ["CLICK ShadowUIActionButton32:Keybind"] = "ALT-2",
    ["CLICK ShadowUIActionButton33:Keybind"] = "ALT-3",
    ["CLICK ShadowUIActionButton34:Keybind"] = "ALT-4",
    ["CLICK ShadowUIActionButton35:Keybind"] = "ALT-5",
    ["CLICK ShadowUIActionButton36:Keybind"] = "ALT-6",
    ["CLICK ShadowUIActionButton37:Keybind"] = "ALT-Q",
    ["CLICK ShadowUIActionButton38:Keybind"] = "ALT-E",
    ["CLICK ShadowUIActionButton39:Keybind"] = "ALT-R",
    ["CLICK ShadowUIActionButton40:Keybind"] = "ALT-F",
    ["CLICK ShadowUIActionButton41:Keybind"] = "ALT-T",
    ["CLICK ShadowUIActionButton42:Keybind"] = "ALT-G",
    ["CLICK ShadowUIActionButton43:Keybind"] = "ALT-C",
    ["CLICK ShadowUIActionButton44:Keybind"] = "ALT-V",
    ["CLICK ShadowUIActionButton45:Keybind"] = "ALT-B",
    ["CLICK ShadowUIActionButton46:Keybind"] = "ALT-X",
    ["CLICK ShadowUIActionButton47:Keybind"] = "ALT-Z",
    ["CLICK ShadowUIActionButton48:Keybind"] = "0",
    ["CLICK ShadowUIActionButton49:Keybind"] = "CTRL-Q",
    ["CLICK ShadowUIActionButton50:Keybind"] = "CTRL-E",
    ["CLICK ShadowUIActionButton51:Keybind"] = "CTRL-R",
    ["CLICK ShadowUIActionButton52:Keybind"] = "CTRL-F",
    ["CLICK ShadowUIActionButton53:Keybind"] = "CTRL-T",
    ["CLICK ShadowUIActionButton54:Keybind"] = "CTRL-G",
    ["CLICK ShadowUIActionButton55:Keybind"] = "CTRL-C",
    ["CLICK ShadowUIActionButton56:Keybind"] = "CTRL-V",
    ["CLICK ShadowUIActionButton57:Keybind"] = "CTRL-B",
    ["CLICK ShadowUIActionButton58:Keybind"] = "CTRL-1",
    ["CLICK ShadowUIActionButton59:Keybind"] = "CTRL-2",
    ["CLICK ShadowUIActionButton60:Keybind"] = "CTRL-3",
    ["CLICK ShadowUIActionButton61:Keybind"] = "BUTTON5",
    ["CLICK ShadowUIActionButton62:Keybind"] = "BUTTON4",
    ["CLICK ShadowUIActionButton63:Keybind"] = "BUTTON3",
    ["CLICK ShadowUIActionButton64:Keybind"] = "ALT-SHIFT-1",
    ["CLICK ShadowUIActionButton65:Keybind"] = "ALT-SHIFT-2",
    ["CLICK ShadowUIActionButton66:Keybind"] = "ALT-SHIFT-3",
    ["CLICK ShadowUIActionButton67:Keybind"] = "F1",
    ["CLICK ShadowUIActionButton68:Keybind"] = "ALT-SHIFT-Q",
    ["CLICK ShadowUIActionButton69:Keybind"] = "ALT-SHIFT-E",
    ["CLICK ShadowUIActionButton70:Keybind"] = "ALT-SHIFT-R",
    ["CLICK ShadowUIActionButton71:Keybind"] = "ALT-SHIFT-F",
    ["CLICK ShadowUIActionButton72:Keybind"] = "ALT-SHIFT-C",
    ["CLICK ShadowUIActionButton73:Keybind"] = "Q",
    ["CLICK ShadowUIActionButton74:Keybind"] = "E",
    ["CLICK ShadowUIActionButton75:Keybind"] = "R",
    ["CLICK ShadowUIActionButton76:Keybind"] = "F",
    ["CLICK ShadowUIActionButton77:Keybind"] = "T",
    ["CLICK ShadowUIActionButton78:Keybind"] = "G",
    ["CLICK ShadowUIActionButton79:Keybind"] = "C",
    ["CLICK ShadowUIActionButton80:Keybind"] = "V",
    ["CLICK ShadowUIActionButton81:Keybind"] = "B",
    ["CLICK ShadowUIActionButton82:Keybind"] = "X",
    ["CLICK ShadowUIActionButton83:Keybind"] = "Z",
    ["CLICK ShadowUIActionButton84:Keybind"] = "H",
  },
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
        [3] = act("w-revenge", "rev", { match = "Revenge" }),
        [4] = act("w-bloodrage", "brage", { match = "Bloodrage" }),
        [5] = act("w-hm", "hm", {
          match = HAMSTRING_MATCH,
          createName = "suiHamstring",
        }),
        [6] = act("w-tc", "tc", { match = "Thunder Clap" }),
        [8] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [9] = act("w-intimid", "is", {
          match = INTIMIDATING_MATCH,
          createName = "suiFear",
        }),
        [10] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [11] = act("w-reck", "rk", { match = "Recklessness" }),
        [12] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [13] = act("w-disarm", "disarm", {
          match = DISARM_MATCH,
          createName = "disarm",
        }),
        [14] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [15] = act("w-chall", "ch", {
          match = "Challenging Shout",
          createName = "challshout",
        }),
        [16] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [17] = act("w-dual", "dual", { match = "/equipslot 17 Mirah's Song" }),
        [18] = act("w-shh", "shh", { match = "/equipslot 17 The Immovable Object" }),
        [19] = act("shared-t13", "t13", { match = "/use 13" }),
        [20] = act("shared-t14", "t14", { match = "/use 14" }),
        [21] = act("w-retal", "ret", { match = "Retaliation" }),
        [22] = act("spell:20600", "Perception", {
          kind = "spell",
          spellId = 20600,
        }),
        [24] = act("spell:8690", "Hearthstone", {
          kind = "spell",
          spellId = 8690,
        }),
        [25] = act("spell:7919", "Shoot Crossbow", {
          kind = "spell",
          spellId = 7919,
        }),
        [26] = act("w-sw", "sw", { match = "Shield Wall" }),
        [27] = act("w-dfdw", "dfdw", { match = "/cast Death Wish" }),
        [28] = act("w-ls", "ls", { match = "Last Stand" }),
        [61] = act("w-b", "b", { match = "Battle Stance" }),
        [62] = act("w-bs", "bs", {
          match = "Berserker Stance",
          createName = "bstan",
        }),
        [63] = act("w-d-def", "d", {
          match = "Defensive Stance",
          notMatch = "Disarm",
          createName = "defstan",
        }),
        [73] = act("w-s", "s", { match = "Sunder Armor" }),
        [74] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [75] = act("w-ww", "ww", { match = "Whirlwind" }),
        [76] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [77] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
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
        [81] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [82] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [83] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [84] = act("w-rend", "rend", { match = "Rend" }),
        [85] = act("w-s", "s", { match = "Sunder Armor" }),
        [86] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [87] = act("w-ww", "ww", { match = "Whirlwind" }),
        [88] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [89] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
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
        [93] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [94] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [95] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [96] = act("w-rend", "rend", { match = "Rend" }),
        [97] = act("w-s", "s", { match = "Sunder Armor" }),
        [98] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [99] = act("w-ww", "ww", { match = "Whirlwind" }),
        [100] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [101] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
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
        [105] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [106] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [107] = act("w-sblock", "sbk", { match = "Shield Block" }),
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
        [3] = act("w-revenge", "rev", { match = "Revenge" }),
        [4] = act("w-bloodrage", "brage", { match = "Bloodrage" }),
        [5] = act("w-hm", "hm", {
          match = HAMSTRING_MATCH,
          createName = "suiHamstring",
        }),
        [6] = act("w-tc", "tc", { match = "Thunder Clap" }),
        [8] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [9] = act("w-intimid", "is", {
          match = INTIMIDATING_MATCH,
          createName = "suiFear",
        }),
        [10] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [11] = act("w-reck", "rk", { match = "Recklessness" }),
        [12] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [13] = act("w-disarm", "disarm", {
          match = DISARM_MATCH,
          createName = "disarm",
        }),
        [14] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [15] = act("w-chall", "ch", {
          match = "Challenging Shout",
          createName = "challshout",
        }),
        [16] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [17] = act("w-dual", "dual", { match = "/equipslot 17 Mirah's Song" }),
        [18] = act("w-shh", "shh", { match = "/equipslot 17 The Immovable Object" }),
        [19] = act("shared-t13", "t13", { match = "/use 13" }),
        [20] = act("shared-t14", "t14", { match = "/use 14" }),
        [21] = act("w-retal", "ret", { match = "Retaliation" }),
        [22] = act("spell:20600", "Perception", {
          kind = "spell",
          spellId = 20600,
        }),
        [24] = act("spell:8690", "Hearthstone", {
          kind = "spell",
          spellId = 8690,
        }),
        [25] = act("spell:7919", "Shoot Crossbow", {
          kind = "spell",
          spellId = 7919,
        }),
        [26] = act("w-sw", "sw", { match = "Shield Wall" }),
        [27] = act("w-dfdw", "dfdw", { match = "/cast Death Wish" }),
        [28] = act("w-ls", "ls", { match = "Last Stand" }),
        [61] = act("w-b", "b", { match = "Battle Stance" }),
        [62] = act("w-bs", "bs", {
          match = "Berserker Stance",
          createName = "bstan",
        }),
        [63] = act("w-d-def", "d", {
          match = "Defensive Stance",
          notMatch = "Disarm",
          createName = "defstan",
        }),
        [73] = act("w-s", "s", { match = "Sunder Armor" }),
        [74] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [75] = act("w-ww", "ww", { match = "Whirlwind" }),
        [76] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [77] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
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
        [81] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [82] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [83] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [84] = act("w-rend", "rend", { match = "Rend" }),
        [85] = act("w-s", "s", { match = "Sunder Armor" }),
        [86] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [87] = act("w-ww", "ww", { match = "Whirlwind" }),
        [88] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [89] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
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
        [93] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [94] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [95] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [96] = act("w-rend", "rend", { match = "Rend" }),
        [97] = act("w-s", "s", { match = "Sunder Armor" }),
        [98] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [99] = act("w-ww", "ww", { match = "Whirlwind" }),
        [100] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [101] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
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
        [105] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [106] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [107] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [108] = act("w-rend", "rend", { match = "Rend" }),
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
        [3] = act("w-revenge", "rev", { match = "Revenge" }),
        [4] = act("w-bloodrage", "brage", { match = "Bloodrage" }),
        [5] = act("w-hm", "hm", {
          match = HAMSTRING_MATCH,
          createName = "suiHamstring",
        }),
        [6] = act("w-tc", "tc", { match = "Thunder Clap" }),
        [8] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [9] = act("w-intimid", "is", {
          match = INTIMIDATING_MATCH,
          createName = "suiFear",
        }),
        [10] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [11] = act("w-reck", "rk", { match = "Recklessness" }),
        [12] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [13] = act("w-disarm", "disarm", {
          match = DISARM_MATCH,
          createName = "disarm",
        }),
        [14] = act("w-mock", "mb", {
          match = "Mocking Blow",
          createName = "mockblow",
        }),
        [15] = act("w-chall", "ch", {
          match = "Challenging Shout",
          createName = "challshout",
        }),
        [16] = act("w-ds", "ds", {
          match = "Demoralizing Shout",
          createName = "demoral",
        }),
        [17] = act("w-dual", "dual", { match = "/equipslot 17 Mirah's Song" }),
        [18] = act("w-shh", "shh", { match = "/equipslot 17 The Immovable Object" }),
        [19] = act("shared-t13", "t13", { match = "/use 13" }),
        [20] = act("shared-t14", "t14", { match = "/use 14" }),
        [21] = act("w-retal", "ret", { match = "Retaliation" }),
        [22] = act("spell:20600", "Perception", {
          kind = "spell",
          spellId = 20600,
        }),
        [24] = act("spell:8690", "Hearthstone", {
          kind = "spell",
          spellId = 8690,
        }),
        [25] = act("spell:7919", "Shoot Crossbow", {
          kind = "spell",
          spellId = 7919,
        }),
        [26] = act("w-sw", "sw", { match = "Shield Wall" }),
        [27] = act("w-dfdw", "dfdw", { match = "/cast Death Wish" }),
        [28] = act("w-ls", "ls", { match = "Last Stand" }),
        [61] = act("w-b", "b", { match = "Battle Stance" }),
        [62] = act("w-bs", "bs", {
          match = "Berserker Stance",
          createName = "bstan",
        }),
        [63] = act("w-d-def", "d", {
          match = "Defensive Stance",
          notMatch = "Disarm",
          createName = "defstan",
        }),
        [73] = act("w-s", "s", { match = "Sunder Armor" }),
        [74] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [75] = act("w-ww", "ww", { match = "Whirlwind" }),
        [76] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [77] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
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
        [81] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [82] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [83] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [84] = act("w-rend", "rend", { match = "Rend" }),
        [85] = act("w-s", "s", { match = "Sunder Armor" }),
        [86] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [87] = act("w-ww", "ww", { match = "Whirlwind" }),
        [88] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [89] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
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
        [93] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [94] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [95] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [96] = act("w-rend", "rend", { match = "Rend" }),
        [97] = act("w-s", "s", { match = "Sunder Armor" }),
        [98] = act("w-bt", "bt", {
          match = "Bloodthirst",
          createName = "bloodthirst",
        }),
        [99] = act("w-ww", "ww", { match = "Whirlwind" }),
        [100] = act("w-c", "c", {
          match = "Cleave",
          notMatch = "Cannibalize",
          createName = "cleave",
        }),
        [101] = act("w-charge", "charge", {
          match = CHARGE_MATCH,
          createName = "suiCharge",
        }),
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
        [105] = act("w-shout", "bshout", {
          match = SHOUT_MATCH,
          createName = "shout",
        }),
        [106] = act("w-br", "br", {
          match = BERSERKER_RAGE_MATCH,
          createName = "suiBersRage",
        }),
        [107] = act("w-sblock", "sbk", { match = "Shield Block" }),
        [108] = act("w-rend", "rend", { match = "Rend" }),
        [109] = false,
        [110] = false,
        [111] = false,
      },
    },
  },
}
