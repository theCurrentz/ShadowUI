--[[
  Purpose: Catalog macros used by the Warrior Action Deck (CreateMacro if missing).
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.catalog
  Notes: Bodies copy docs/macros/catalog.json. Rebuild with build_catalog.py.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults.catalog = Addon.Defaults.catalog or {}
local C = Addon.Defaults.catalog

C["w-hm"] = {
  name = "hm",
  icon = "ability_shockwave",
  body = "#showtooltip Hamstring\n# class-specific WARRIOR all | key (`)\n/cast [stance:2] Battle Stance\n/cast Hamstring\n/startattack",
}

C["w-charge"] = {
  name = "charge",
  icon = "ability_warrior_charge",
  body = "#showtooltip [combat] Intercept; Charge\n# class-specific WARRIOR all | key (T)\n/cast [nocombat,nostance:1] Battle Stance; [combat,nostance:3] Berserker Stance\n/cast [nocombat] Charge; Intercept\n/startattack",
}

C["w-c"] = {
  name = "c",
  icon = "ability_warrior_cleave",
  body = "#showtooltip Cleave\n# class-specific WARRIOR all | key (R)\n/cast Cleave\n/startattack",
}

C["w-interrupt"] = {
  name = "wkick",
  icon = "inv_gauntlets_04",
  body = "#showtooltip [stance:3] Pummel; [equipped:Shields] Shield Bash; Pummel\n# class-specific WARRIOR all | key (G)\n/stopcasting\n/startattack\n/cast [noequipped:Shields,nostance:3] Berserker Stance\n/cast [stance:3] Pummel; [equipped:Shields] Shield Bash",
}

C["w-bloodrage"] = {
  name = "brage",
  icon = "ability_racial_bloodrage",
  body = "#showtooltip Bloodrage\n# class-specific WARRIOR all | key (F)\n/cast Bloodrage\n/startattack",
}

C["w-intimid"] = {
  name = "is",
  icon = "ability_golemthunderclap",
  body = "#showtooltip Intimidating Shout\n# class-specific WARRIOR all | key (shift-T)\n/cast Intimidating Shout\n/stopattack",
}

C["w-disarm"] = {
  name = "disarm",
  icon = "ability_warrior_disarm",
  body = "#showtooltip Disarm\n# class-specific WARRIOR all | key (shift-c)\n/startattack\n/cast [nostance:2] Defensive Stance\n/cast Disarm",
}

C["w-br"] = {
  name = "br",
  icon = "spell_nature_ancestralguardian",
  body = "#showtooltip Berserker Rage\n# class-specific WARRIOR all | key (G)\n/cast [nostance:3] Berserker Stance\n/cast Berserker Rage",
}

C["w-shout"] = {
  name = "bshout",
  icon = "ability_warrior_battleshout",
  body = "#showtooltip [mod:shift] Demoralizing Shout; Battle Shout\n# class-specific WARRIOR all | key (Y)\n/cast [mod:shift] Demoralizing Shout; Battle Shout",
}

C["w-o"] = {
  name = "o",
  icon = "ability_meleedamage",
  body = "#showtooltip Overpower\n# class-specific WARRIOR all | key (2)\n/cast [nostance:1] Battle Stance\n/cast Overpower\n/startattack",
}

C["w-h"] = {
  name = "h",
  icon = "ability_rogue_ambush",
  body = "#showtooltip Heroic Strike\n# class-specific WARRIOR all | key (1)\n/cast Heroic Strike\n/startattack",
}

C["w-ex"] = {
  name = "ex",
  icon = "inv_sword_48",
  body = "#showtooltip Execute\n# class-specific WARRIOR all | key (4)\n/cast [stance:2] Battle Stance\n/cast Execute\n/startattack",
}

C["w-rend"] = {
  name = "rend",
  icon = "ability_gouge",
  body = "#showtooltip Rend\n# class-specific WARRIOR all | key (6)\n/cast [stance:3] Battle Stance\n/cast Rend\n/startattack",
}

C["w-tc"] = {
  name = "tc",
  icon = "spell_nature_thunderclap",
  body = "#showtooltip Thunder Clap\n# class-specific WARRIOR all | key (6)\n/cast [nostance:1] Battle Stance\n/cast Thunder Clap",
}

C["w-ds"] = {
  name = "ds",
  icon = "ability_warrior_warcry",
  body = "#showtooltip Demoralizing Shout\n# class-specific WARRIOR all | key (Shift-V)\n/cast Demoralizing Shout\n/startattack",
}

C["w-major-cd"] = {
  name = "major",
  icon = "ability_warrior_challange",
  body = "#showtooltip\n# class-specific WARRIOR all | key (B)\n/cast [stance:1] Retaliation; [stance:2] Shield Wall; Recklessness",
}

C["w-mock"] = {
  name = "mb",
  icon = "ability_warrior_punishingblow",
  body = "#showtooltip Mocking Blow\n# class-specific WARRIOR all | key (shift-X)\n/cast [nostance:1] Battle Stance\n/cast [target=mouseover,harm,nodead][] Mocking Blow",
}

C["w-revenge"] = {
  name = "rev",
  icon = "ability_warrior_revenge",
  body = "#showtooltip Revenge\n# class-specific WARRIOR all | key (2)\n/cast [nostance:2] Defensive Stance\n/cast Revenge\n/startattack",
}

C["w-s"] = {
  name = "s",
  icon = "ability_warrior_sunder",
  body = "#showtooltip Sunder Armor\n# class-specific WARRIOR all | key (Q)\n/startattack\n/cast [target=mouseover,harm,nodead][] Sunder Armor",
}

C["w-sblock"] = {
  name = "sbk",
  icon = "ability_defend",
  body = "#showtooltip Shield Block\n# class-specific WARRIOR all | key (shift-r)\n/cast [nostance:2] Defensive Stance\n/cast Shield Block",
}

C["w-taunt"] = {
  name = "a",
  icon = "spell_nature_reincarnation",
  body = "#showtooltip Taunt\n# class-specific WARRIOR all | key (X)\n/cast [nostance:2] Defensive Stance\n/cast [target=mouseover,harm,nodead][] Taunt",
}

C["w-ww"] = {
  name = "ww",
  icon = "ability_whirlwind",
  body = "#showtooltip Whirlwind\n# class-specific WARRIOR all | key (C)\n/cast [nostance:3] Berserker Stance\n/cast Whirlwind\n/startattack",
}

C["w-chall"] = {
  name = "ch",
  icon = "ability_bullrush",
  body = "#showtooltip Challenging Shout\n# class-specific WARRIOR all | key (X)\n/cast Challenging Shout\n/startattack",
}

C["w-b"] = {
  name = "b",
  icon = "ability_warrior_offensivestance",
  body = "#showtooltip Battle Stance\n# class-specific WARRIOR all | key (moust button 1)\n/cast Battle Stance\n/startattack",
}

C["w-d-def"] = {
  name = "d",
  icon = "ability_warrior_defensivestance",
  body = "#showtooltip Defensive Stance\n# class-specific WARRIOR all | key (mouse button 3)\n/cast Defensive Stance\n/startattack",
}

C["w-bs"] = {
  name = "bs",
  icon = "ability_racial_avatar",
  body = "#showtooltip Berserker Stance\n# class-specific WARRIOR all | key (mouse button 2)\n/cast Berserker Stance\n/startattack",
}

C["w-sweep"] = {
  name = "ss",
  icon = "ability_rogue_slicedice",
  body = "#showtooltip Sweeping Strikes\n# class-specific WARRIOR arms | key (T)\n/cast [nostance:1] Battle Stance\n/cast Sweeping Strikes",
}

C["w-ms"] = {
  name = "ms",
  icon = "ability_warrior_savageblow",
  body = "#showtooltip Mortal Strike\n# class-specific WARRIOR arms | key (1)\n/cast Mortal Strike\n/startattack",
}

C["w-deathwish"] = {
  name = "dwish",
  icon = "spell_shadow_deathpact",
  body = "#showtooltip Death Wish\n# class-specific WARRIOR fury | key (T)\n/cast Death Wish\n/startattack",
}

C["w-bt"] = {
  name = "bt",
  icon = "spell_nature_bloodlust",
  body = "#showtooltip Bloodthirst\n# class-specific WARRIOR fury | key (1)\n/cast Bloodthirst\n/startattack",
}

C["w-ls"] = {
  name = "ls",
  icon = "spell_holy_ashestoashes",
  body = "#showtooltip Last Stand\n# class-specific WARRIOR protection | key (T)\n/stopcasting\n/cast Last Stand",
}

C["w-sslam"] = {
  name = "ssl",
  icon = "inv_shield_05",
  body = "#showtooltip Shield Slam\n# class-specific WARRIOR protection | key (1)\n/startattack\n/cast Shield Slam",
}

C["w-concussion"] = {
  name = "cb",
  icon = "ability_thunderbolt",
  body = "#showtooltip Concussion Blow\n# class-specific WARRIOR protection | key (7)\n/startattack\n/cast Concussion Blow",
}

C["w-retal"] = {
  name = "ret",
  icon = "ability_warrior_challange",
  body = "#showtooltip Retaliation\n# class-specific WARRIOR all | key (Z)\n/cast [nostance:1] Battle Stance\n/cast Retaliation",
}

