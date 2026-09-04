--[[
  Purpose: Catalog macros for the Macro Library.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.catalog
  Notes: Bodies copy docs/macros/catalog.json. Rebuild with build_catalog.py.
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults.catalog = Addon.Defaults.catalog or {}
local C = Addon.Defaults.catalog

C["shared-t13"] = {
  name = "t13",
  icon = "inv_misc_orb_02",
  body = "#showtooltip\n/use 13",
}

C["shared-t14"] = {
  name = "t14",
  icon = "inv_misc_orb_03",
  body = "#showtooltip\n/use 14",
}

C["shared-pa"] = {
  name = "pa",
  icon = "ability_druid_bash",
  body = "/petattack",
}

C["shared-pf"] = {
  name = "pf",
  icon = "ability_tracking",
  body = "/petfollow",
}

C["w-charge"] = {
  name = "charge",
  icon = "ability_warrior_charge",
  body = "#showtooltip [combat] Intercept; Charge\n/cast [nocombat,nostance:1] Battle Stance; [combat,nostance:3] Berserker Stance\n/cast [nocombat] Charge; Intercept\n/startattack",
}

C["w-bloodrage"] = {
  name = "brage",
  icon = "ability_racial_bloodrage",
  body = "#showtooltip Bloodrage\n/cast Bloodrage\n/startattack",
}

C["w-br"] = {
  name = "br",
  icon = "spell_nature_ancestralguardian",
  body = "#showtooltip Berserker Rage\n/cast [nostance:3] Berserker Stance\n/cast Berserker Rage",
}

C["w-b"] = {
  name = "b",
  icon = "ability_warrior_offensivestance",
  body = "#showtooltip Battle Stance\n/cast Battle Stance\n/startattack",
}

C["w-bs"] = {
  name = "bs",
  icon = "ability_racial_avatar",
  body = "#showtooltip Berserker Stance\n/cast Berserker Stance\n/startattack",
}

C["w-d-def"] = {
  name = "d",
  icon = "ability_warrior_defensivestance",
  body = "#showtooltip Defensive Stance\n/cast Defensive Stance\n/startattack",
}

C["w-h"] = {
  name = "h",
  icon = "ability_rogue_ambush",
  body = "#showtooltip Heroic Strike\n/cast Heroic Strike\n/startattack",
}

C["w-c"] = {
  name = "c",
  icon = "ability_warrior_cleave",
  body = "#showtooltip Cleave\n/cast Cleave\n/startattack",
}

C["w-ww"] = {
  name = "ww",
  icon = "ability_whirlwind",
  body = "#showtooltip Whirlwind\n/cast [nostance:3] Berserker Stance\n/cast Whirlwind\n/startattack",
}

C["w-ex"] = {
  name = "ex",
  icon = "inv_sword_48",
  body = "#showtooltip Execute\n/cast [stance:2] Battle Stance\n/cast Execute\n/startattack",
}

C["w-o"] = {
  name = "o",
  icon = "ability_meleedamage",
  body = "#showtooltip Overpower\n/cast [nostance:1] Battle Stance\n/cast Overpower\n/startattack",
}

C["w-rend"] = {
  name = "rend",
  icon = "ability_gouge",
  body = "#showtooltip Rend\n/cast [stance:3] Battle Stance\n/cast Rend\n/startattack",
}

C["w-s"] = {
  name = "s",
  icon = "ability_warrior_sunder",
  body = "#showtooltip Sunder Armor\n/startattack\n/cast [target=mouseover,harm,nodead][] Sunder Armor",
}

C["w-slam"] = {
  name = "sl",
  icon = "ability_warrior_decisivestrike",
  body = "#showtooltip Slam\n/cast [stance:2] Battle Stance\n/startattack\n/cast Slam",
}

C["w-interrupt"] = {
  name = "wkick",
  icon = "inv_gauntlets_04",
  body = "#showtooltip [stance:3] Pummel; [equipped:Shields] Shield Bash; Pummel\n/stopcasting\n/startattack\n/cast [noequipped:Shields,nostance:3] Berserker Stance\n/cast [stance:3] Pummel; [equipped:Shields] Shield Bash",
}

C["w-major-cd"] = {
  name = "major",
  icon = "ability_warrior_challange",
  body = "#showtooltip\n/cast [stance:1] Retaliation; [stance:2] Shield Wall; Recklessness",
}

C["w-taunt"] = {
  name = "a",
  icon = "spell_nature_reincarnation",
  body = "#showtooltip Taunt\n/cast [nostance:2] Defensive Stance\n/cast [target=mouseover,harm,nodead][] Taunt",
}

C["w-shout"] = {
  name = "bshout",
  icon = "ability_warrior_battleshout",
  body = "#showtooltip [mod:shift] Demoralizing Shout; Battle Shout\n/cast [mod:shift] Demoralizing Shout; Battle Shout",
}

C["w-ds"] = {
  name = "ds",
  icon = "ability_warrior_warcry",
  body = "#showtooltip Demoralizing Shout\n/cast Demoralizing Shout\n/startattack",
}

C["w-hm"] = {
  name = "hm",
  icon = "ability_shockwave",
  body = "#showtooltip Hamstring\n/cast [stance:2] Battle Stance\n/cast Hamstring\n/startattack",
}

C["w-disarm"] = {
  name = "disarm",
  icon = "ability_warrior_disarm",
  body = "#showtooltip Disarm\n/startattack\n/cast [nostance:2] Defensive Stance\n/cast Disarm",
}

C["w-intimid"] = {
  name = "is",
  icon = "ability_golemthunderclap",
  body = "#showtooltip Intimidating Shout\n/cast Intimidating Shout\n/stopattack",
}

C["w-revenge"] = {
  name = "rev",
  icon = "ability_warrior_revenge",
  body = "#showtooltip Revenge\n/cast [nostance:2] Defensive Stance\n/cast Revenge\n/startattack",
}

C["w-sblock"] = {
  name = "sbk",
  icon = "ability_defend",
  body = "#showtooltip Shield Block\n/cast [nostance:2] Defensive Stance\n/cast Shield Block",
}

C["w-mock"] = {
  name = "mb",
  icon = "ability_warrior_punishingblow",
  body = "#showtooltip Mocking Blow\n/cast [nostance:1] Battle Stance\n/cast [target=mouseover,harm,nodead][] Mocking Blow",
}

C["w-chall"] = {
  name = "ch",
  icon = "ability_bullrush",
  body = "#showtooltip Challenging Shout\n/cast Challenging Shout\n/startattack",
}

C["w-tc"] = {
  name = "tc",
  icon = "spell_nature_thunderclap",
  body = "#showtooltip Thunder Clap\n/cast [nostance:1] Battle Stance\n/cast Thunder Clap",
}

C["w-retal"] = {
  name = "ret",
  icon = "ability_warrior_challange",
  body = "#showtooltip Retaliation\n/cast [nostance:1] Battle Stance\n/cast Retaliation",
}

C["w-reck"] = {
  name = "rk",
  icon = "ability_criticalstrike",
  body = "#showtooltip Recklessness\n/cast [nostance:3] Berserker Stance\n/cast Recklessness",
}

C["w-sw"] = {
  name = "sw",
  icon = "ability_warrior_shieldwall",
  body = "#showtooltip Shield Wall\n/cast [nostance:2] Defensive Stance\n/cast Shield Wall",
}

C["w-sweep"] = {
  name = "ss",
  icon = "ability_rogue_slicedice",
  body = "#showtooltip Sweeping Strikes\n/cast [nostance:1] Battle Stance\n/cast Sweeping Strikes",
}

C["w-ms"] = {
  name = "ms",
  icon = "ability_warrior_savageblow",
  body = "#showtooltip Mortal Strike\n/cast Mortal Strike\n/startattack",
}

C["w-deathwish"] = {
  name = "dwish",
  icon = "spell_shadow_deathpact",
  body = "#showtooltip Death Wish\n/cast Death Wish\n/startattack",
}

C["w-bt"] = {
  name = "bt",
  icon = "spell_nature_bloodlust",
  body = "#showtooltip Bloodthirst\n/cast Bloodthirst\n/startattack",
}

C["w-ls"] = {
  name = "ls",
  icon = "spell_holy_ashestoashes",
  body = "#showtooltip Last Stand\n/stopcasting\n/cast Last Stand",
}

C["w-dfdw"] = {
  name = "dfdw",
  icon = "inv_potion_69",
  body = "/use Diamond Flask\n/cast Death Wish",
}

C["w-dual"] = {
  name = "dual",
  icon = "inv_sword_39",
  body = "/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 Mirah's Song",
}

C["w-sh-qs"] = {
  name = "shqs",
  icon = "inv_shield_04",
  body = "/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 Buru's Skull Fragment",
}

C["w-shh"] = {
  name = "shh",
  icon = "inv_shield_06",
  body = "/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 The Immovable Object",
}

C["w-sd-item"] = {
  name = "sd",
  icon = "ability_warrior_shieldwall",
  body = "#showtooltip Shield Wall\n/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 The Immovable Object\n/cast [nostance:2] Defensive Stance\n/cast Shield Wall",
}

C["m-fb"] = {
  name = "f",
  icon = "spell_frost_frostbolt02",
  body = "#showtooltip [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)\n/cqs\n/cast [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)",
}

C["m-fireball"] = {
  name = "fb",
  icon = "spell_fire_flamebolt",
  body = "#showtooltip [mod:shift] Combustion; Fireball\n/cqs\n/cast [mod:shift] Combustion\n/use [mod:shift] Mind Quickening Gem\n/use [mod:shift] Talisman of Ephemeral Power\n/use [mod:shift] Zandalarian Hero Charm\n/cast Fireball;",
}

C["m-blast"] = {
  name = "'",
  icon = "spell_fire_fireball",
  body = "#showtooltip [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)\n/cast [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)",
}

C["m-ae"] = {
  name = "ae",
  icon = "spell_nature_wispsplode",
  body = "#showtooltip [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)\n/cast [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)",
}

C["m-am"] = {
  name = "am",
  icon = "spell_nature_starfall",
  body = "#showtooltip Arcane Missiles\n/cast [nochanneling:Arcane Missiles] Arcane Missiles",
}

C["m-blizz"] = {
  name = "Blizz",
  icon = "spell_frost_icestorm",
  body = "#showtooltip [nomod]Blizzard;[mod:shift]Blizzard(rank 1)\n/cast [nomod]Blizzard;[mod:shift]Blizzard(rank 1)",
}

C["m-cone"] = {
  name = "cone",
  icon = "spell_frost_glacier",
  body = "#showtooltip [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)\n/cast [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)",
}

C["m-fs"] = {
  name = "fs",
  icon = "spell_fire_selfdestruct",
  body = "#showtooltip [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike\n/use [mod:alt] Talisman of Ephemeral Power\n/use [mod:alt] Zandalarian Hero Charm\n/cast [mod:alt] Arcane Power\n/cast [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike",
}

C["m-scorch"] = {
  name = "sc",
  icon = "spell_fire_soulburn",
  body = "#showtooltip Scorch\n/cast Scorch",
}

C["m-pyro"] = {
  name = "py",
  icon = "spell_fire_fireball02",
  body = "#showtooltip Pyroblast\n/cast Presence of Mind\n/cast Pyroblast",
}

C["m-wand"] = {
  name = "shadow",
  icon = "spell_shadow_shadowbolt",
  body = "#showtooltip\n/equip Touch of Chaos\n/cast shoot",
}

C["m-cs"] = {
  name = "CS",
  icon = "spell_frost_iceshock",
  body = "#showtooltip\n/stopcasting\n#/cast [target=mouseover,exists] Counterspell\n/cast Counterspell",
}

C["m-cs-focus"] = {
  name = "CSf",
  icon = "spell_frost_iceshock",
  body = "#showtooltip Counterspell\n/stopcasting\n/cast [target=focus,harm,nodead] Counterspell; Counterspell",
}

C["m-sheep"] = {
  name = "sheep",
  icon = "spell_nature_polymorph",
  body = "#showtooltip [nomod]Polymorph;[mod:shift]Polymorph(rank 1)\n/cast [nomod]Polymorph;[mod:shift]Polymorph(rank 1)",
}

C["m-decurse"] = {
  name = "decurse",
  icon = "spell_nature_removecurse",
  body = "#showtooltip Remove Lesser Curse\n/cast [target=mouseover,exists] Remove Lesser Curse\n/cast Remove Lesser Curse",
}

C["m-ib"] = {
  name = "ib",
  icon = "spell_frost_frost",
  body = "#showtooltip Ice block\n/stopcasting\n/cast Ice block\n/cancelaura Ice block",
}

C["m-ms"] = {
  name = "MS",
  icon = "spell_shadow_detectlesserinvisibility",
  body = "#showtooltip\n/stopcasting\n/cast mana shield",
}

C["m-nova"] = {
  name = "fn",
  icon = "spell_frost_frostnova",
  body = "#showtooltip [mod:shift] Frost Nova; Frost Nova(rank 1)\n/cast [mod:shift] Frost Nova; Frost Nova(rank 1)",
}

C["m-barrier"] = {
  name = "iba",
  icon = "spell_ice_lament",
  body = "#showtooltip Ice Barrier\n/cast Ice Barrier",
}

C["m-ward"] = {
  name = "ward",
  icon = "spell_frost_frostward",
  body = "#showtooltip [mod:shift] Fire Ward; Frost Ward\n/cast [mod:shift] Fire Ward; Frost Ward",
}

C["m-slowfall"] = {
  name = "slowfall",
  icon = "spell_magic_featherfall",
  body = "#showtooltip Slow Fall\n/cast Slow Fall",
}

C["m-dampen"] = {
  name = "dm",
  icon = "spell_nature_abolishmagic",
  body = "#showtooltip [mod:shift] Amplify Magic; Dampen Magic\n/cast [mod:shift] Amplify Magic; Dampen Magic",
}

C["m-csnap"] = {
  name = "snap",
  icon = "spell_frost_wizardmark",
  body = "#showtooltip Cold Snap\n/cast Cold Snap",
}

C["m-nef"] = {
  name = "nef",
  icon = "spell_holy_excorcism_02",
  body = "/use [@cursor] Stratholme Holy Water\n/cast Blast Wave",
}

C["m-sw"] = {
  name = "portsw",
  icon = "spell_arcane_teleportstormwind",
  body = "#showtooltip [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind\n/cast [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind",
}

C["m-if"] = {
  name = "if",
  icon = "spell_arcane_teleportironforge",
  body = "#showtooltip [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge\n/cast [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge",
}

C["m-dar"] = {
  name = "dar",
  icon = "spell_arcane_teleportdarnassus",
  body = "#showtooltip [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus\n/cast [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus",
}

C["m-org"] = {
  name = "org",
  icon = "spell_arcane_teleportorgrimmar",
  body = "#showtooltip [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar\n/cast [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar",
}

C["m-uc"] = {
  name = "uc",
  icon = "spell_arcane_teleportundercity",
  body = "#showtooltip [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity\n/cast [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity",
}

C["m-tb"] = {
  name = "tb",
  icon = "spell_arcane_teleportthunderbluff",
  body = "#showtooltip [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff\n/cast [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff",
}

C["p-judge"] = {
  name = "judge",
  icon = "spell_holy_righteousfury",
  body = "#showtooltip Judgement\n/startattack\n/cast Judgement",
}

C["p-seal"] = {
  name = "seal",
  icon = "ability_thunderbolt",
  body = "#showtooltip\n/cast [mod:shift] Seal of Command; Seal of Righteousness",
}

C["p-hoj"] = {
  name = "hoj",
  icon = "spell_holy_sealofmight",
  body = "#showtooltip Hammer of Justice\n/stopcasting\n/cast Hammer of Justice",
}

C["p-cons"] = {
  name = "cons",
  icon = "spell_holy_innerfire",
  body = "#showtooltip\n/cast [mod:shift] Consecration(Rank 1); Consecration",
}

C["p-how"] = {
  name = "how",
  icon = "ability_thunderclap",
  body = "#showtooltip Hammer of Wrath\n/cast Hammer of Wrath",
}

C["p-exo"] = {
  name = "exo",
  icon = "spell_holy_excorcism_02",
  body = "#showtooltip Exorcism\n/cast Exorcism",
}

C["p-rep"] = {
  name = "rep",
  icon = "spell_holy_prayerofhealing",
  body = "#showtooltip Repentance\n/stopcasting\n/cast Repentance",
}

C["p-bubble"] = {
  name = "bubble",
  icon = "spell_holy_divineintervention",
  body = "#showtooltip Divine Shield\n/cast Divine Shield",
}

C["p-cancel-ds"] = {
  name = "cds",
  icon = "spell_holy_divineintervention",
  body = "/cancelaura Divine Shield",
}

C["p-bop"] = {
  name = "bop",
  icon = "spell_holy_sealofprotection",
  body = "#showtooltip Blessing of Protection\n/cast Blessing of Protection",
}

C["p-cleanse"] = {
  name = "cl",
  icon = "spell_holy_purify",
  body = "#showtooltip Cleanse\n/cast [mod:alt,target=player] Cleanse; [target=mouseover,exists] Cleanse; Cleanse",
}

C["p-fol"] = {
  name = "fol",
  icon = "spell_holy_flashheal",
  body = "#showtooltip\n/cast [mod:alt,target=player] Flash of Light; [mod:shift] Flash of Light(Rank 4); [mod:ctrl] Flash of Light(Rank 1); Flash of Light",
}

C["p-might"] = {
  name = "bom",
  icon = "spell_holy_fistofjustice",
  body = "#showtooltip\n/cast [mod:shift] Blessing of Salvation; [mod:ctrl] Blessing of Wisdom; Blessing of Might",
}

C["p-aura"] = {
  name = "aura",
  icon = "spell_holy_devotionaura",
  body = "#showtooltip\n/cast [mod:shift] Devotion Aura; [mod:ctrl] Retribution Aura; Concentration Aura",
}

C["p-rf"] = {
  name = "rf",
  icon = "spell_holy_sealoffury",
  body = "#showtooltip Righteous Fury\n/cast Righteous Fury",
}

C["p-hs"] = {
  name = "hsh",
  icon = "spell_holy_blessingofprotection",
  body = "#showtooltip Holy Shield\n/cast Holy Shield",
}

C["p-loh"] = {
  name = "loh",
  icon = "spell_holy_layonhands",
  body = "#showtooltip Lay on Hands\n/raid Lay on Hands on %t\n/cast Lay on Hands",
}

C["p-di"] = {
  name = "di",
  icon = "spell_nature_timestop",
  body = "#showtooltip Divine Intervention\n/raid DI on %t\n/cast Divine Intervention",
}

C["p-hl"] = {
  name = "hl",
  icon = "spell_holy_holybolt",
  body = "#showtooltip\n/cast [mod:alt,target=player] Holy Light; [mod:shift] Holy Light(Rank 1); Holy Light",
}

C["p-df"] = {
  name = "df",
  icon = "spell_holy_flashheal",
  body = "#showtooltip Flash of Light\n/cast Divine Favor\n/cast Flash of Light",
}

C["p-shock"] = {
  name = "hsk",
  icon = "spell_holy_searinglight",
  body = "#showtooltip Holy Shock\n/cast Holy Shock",
}

C["p-seal-h"] = {
  name = "sealh",
  icon = "spell_holy_righteousnessaura",
  body = "#showtooltip\n/cast [mod:shift] Seal of Light; Seal of Wisdom",
}

C["p-mount"] = {
  name = "chg",
  icon = "spell_nature_swiftness",
  body = "#showtooltip\n/cast [mod:shift] Summon Warhorse; Summon Charger",
}

C["h-mark"] = {
  name = "hmark",
  icon = "ability_hunter_snipershot",
  body = "#showtooltip Hunter's Mark\n/cast Hunter's Mark",
}

C["h-aspect"] = {
  name = "asp",
  icon = "spell_nature_ravenform",
  body = "#showtooltip\n/cast [mod:shift] Aspect of the Monkey; Aspect of the Hawk",
}

C["h-aimed"] = {
  name = "as",
  icon = "inv_spear_07",
  body = "#showtooltip Aimed Shot\n/cast Aimed Shot",
}

C["h-multi"] = {
  name = "multi",
  icon = "ability_upgrademoonglaive",
  body = "#showtooltip Multi-Shot\n/cast Multi-Shot",
}

C["h-arcane"] = {
  name = "arc",
  icon = "ability_impalingbolt",
  body = "#showtooltip\n/cast [mod:shift] Arcane Shot(Rank 1); Arcane Shot",
}

C["h-sting"] = {
  name = "sting",
  icon = "ability_hunter_quickshot",
  body = "#showtooltip Serpent Sting\n/cast Serpent Sting",
}

C["h-conc"] = {
  name = "conc",
  icon = "spell_frost_stun",
  body = "#showtooltip Concussive Shot\n/cast Concussive Shot",
}

C["h-clip"] = {
  name = "wc",
  icon = "ability_rogue_trip",
  body = "#showtooltip\n/cast [mod:shift] Wing Clip(Rank 1); Wing Clip",
}

C["h-fd"] = {
  name = "fd",
  icon = "ability_rogue_feigndeath",
  body = "#showtooltip Feign Death\n/stopattack\n/stopcasting\n/cast Feign Death",
}

C["h-trap"] = {
  name = "ft",
  icon = "spell_frost_chainsofice",
  body = "#showtooltip Freezing Trap\n/cast Freezing Trap",
}

C["h-rapid"] = {
  name = "rapid",
  icon = "ability_hunter_runningshot",
  body = "#showtooltip Rapid Fire\n/use 13\n/cast Rapid Fire",
}

C["h-tranq"] = {
  name = "tq",
  icon = "spell_nature_drowsy",
  body = "#showtooltip Tranquilizing Shot\n/cast Tranquilizing Shot",
}

C["h-mend"] = {
  name = "mp",
  icon = "ability_hunter_mendpet",
  body = "#showtooltip Mend Pet\n/cast Mend Pet",
}

C["h-call"] = {
  name = "pet",
  icon = "ability_hunter_beastcall",
  body = "#showtooltip Call Pet\n/cast Call Pet",
}

C["h-bw"] = {
  name = "bw",
  icon = "ability_druid_ferociousbite",
  body = "#showtooltip Bestial Wrath\n/cast Bestial Wrath",
}

C["h-cheetah"] = {
  name = "cheetah",
  icon = "ability_mount_jungletiger",
  body = "#showtooltip Aspect of the Cheetah\n/cast Aspect of the Cheetah",
}

C["h-worg"] = {
  name = "worg",
  icon = "ability_hunter_beastcall",
  body = "#showtooltip\n/cast Call Pet\n/use Worg Carrier",
}

C["r-stealth"] = {
  name = "st",
  icon = "ability_stealth",
  body = "#showtooltip Stealth\n/cast Stealth",
}

C["r-ss"] = {
  name = "sinister",
  icon = "spell_shadow_ritualofsacrifice",
  body = "#showtooltip Sinister Strike\n/startattack\n/cast Sinister Strike",
}

C["r-kick"] = {
  name = "kick",
  icon = "ability_kick",
  body = "#showtooltip Kick\n/stopcasting\n/cast Kick",
}

C["r-evis"] = {
  name = "ev",
  icon = "ability_rogue_eviscerate",
  body = "#showtooltip Eviscerate\n/cast Eviscerate",
}

C["r-snd"] = {
  name = "snd",
  icon = "ability_rogue_slicedice",
  body = "#showtooltip Slice and Dice\n/cast Slice and Dice",
}

C["r-rup"] = {
  name = "rup",
  icon = "ability_rogue_rupture",
  body = "#showtooltip Rupture\n/cast Rupture",
}

C["r-ks"] = {
  name = "ks",
  icon = "ability_rogue_kidneyshot",
  body = "#showtooltip Kidney Shot\n/cast Kidney Shot",
}

C["r-gouge"] = {
  name = "g",
  icon = "ability_gouge",
  body = "#showtooltip Gouge\n/stopattack\n/cast Gouge",
}

C["r-cheap"] = {
  name = "cheap",
  icon = "ability_cheapshot",
  body = "#showtooltip Cheap Shot\n/cast [nostealth] Stealth\n/cast Cheap Shot",
}

C["r-ambush"] = {
  name = "ambush",
  icon = "ability_rogue_ambush",
  body = "#showtooltip Ambush\n/cast [nostealth] Stealth\n/cast Ambush",
}

C["r-bf"] = {
  name = "bf",
  icon = "ability_warrior_punishingblow",
  body = "#showtooltip Blade Flurry\n/use 13\n/cast Blade Flurry",
}

C["r-ar"] = {
  name = "ar",
  icon = "spell_shadow_shadowworddominate",
  body = "#showtooltip Adrenaline Rush\n/cast Adrenaline Rush",
}

C["r-eva"] = {
  name = "eva",
  icon = "spell_shadow_shadowward",
  body = "#showtooltip Evasion\n/cast Evasion",
}

C["r-vanish"] = {
  name = "van",
  icon = "ability_vanish",
  body = "#showtooltip Vanish\n/stopattack\n/cast Vanish",
}

C["r-sprint"] = {
  name = "sp",
  icon = "ability_rogue_sprint",
  body = "#showtooltip Sprint\n/cast Sprint",
}

C["r-blind"] = {
  name = "blind",
  icon = "spell_shadow_mindsteal",
  body = "#showtooltip Blind\n/cast Blind",
}

C["r-sap"] = {
  name = "sap",
  icon = "ability_sap",
  body = "#showtooltip\n/cast [nostealth] Stealth\n/cast [mod:shift] Sap; Pick Pocket",
}

C["r-cb"] = {
  name = "coldb",
  icon = "spell_ice_lament",
  body = "#showtooltip Eviscerate\n/cast Cold Blood\n/cast Eviscerate",
}

C["pr-fh"] = {
  name = "fh",
  icon = "spell_holy_flashheal",
  body = "#showtooltip\n/cast [mod:alt,target=player] Flash Heal; [mod:shift] Flash Heal(Rank 4); [mod:ctrl] Flash Heal(Rank 1); Flash Heal",
}

C["pr-gh"] = {
  name = "gh",
  icon = "spell_holy_greaterheal",
  body = "#showtooltip\n/cast [mod:alt,target=player] Greater Heal; [mod:shift] Greater Heal(Rank 1); Greater Heal",
}

C["pr-renew"] = {
  name = "rn",
  icon = "spell_holy_renew",
  body = "#showtooltip\n/cast [mod:alt,target=player] Renew; [mod:shift] Renew(Rank 3); Renew",
}

C["pr-pws"] = {
  name = "pws",
  icon = "spell_holy_powerwordshield",
  body = "#showtooltip\n/cast [mod:alt,target=player] Power Word: Shield; [mod:shift] Power Word: Shield(Rank 1); Power Word: Shield",
}

C["pr-poh"] = {
  name = "poh",
  icon = "spell_holy_prayerofhealing02",
  body = "#showtooltip Prayer of Healing\n/cast Inner Focus\n/cast Prayer of Healing",
}

C["pr-dispel"] = {
  name = "disp",
  icon = "spell_holy_dispelmagic",
  body = "#showtooltip Dispel Magic\n/cast [mod:alt,target=player] Dispel Magic; [target=mouseover,exists] Dispel Magic; Dispel Magic",
}

C["pr-fade"] = {
  name = "fade",
  icon = "spell_magic_lesserinvisibilty",
  body = "#showtooltip Fade\n/cast Fade",
}

C["pr-scream"] = {
  name = "ps",
  icon = "spell_shadow_psychicscream",
  body = "#showtooltip Psychic Scream\n/cast Psychic Scream",
}

C["pr-fw"] = {
  name = "fw",
  icon = "spell_holy_excorcism",
  body = "#showtooltip Fear Ward\n/raid Fear Ward on %t\n/cast [mod:alt,target=player] Fear Ward; Fear Ward",
}

C["pr-fort"] = {
  name = "fort",
  icon = "spell_holy_wordfortitude",
  body = "#showtooltip Power Word: Fortitude\n/cast [mod:alt,target=player] Power Word: Fortitude; Power Word: Fortitude",
}

C["pr-rez"] = {
  name = "rez",
  icon = "spell_holy_resurrection",
  body = "#showtooltip Resurrection\n/cast Resurrection",
}

C["pr-if"] = {
  name = "ifr",
  icon = "spell_holy_innerfire",
  body = "#showtooltip Inner Fire\n/cast Inner Fire",
}

C["pr-nova"] = {
  name = "hn",
  icon = "spell_holy_holynova",
  body = "#showtooltip\n/cast [mod:shift] Holy Nova(Rank 1); Holy Nova",
}

C["pr-wand"] = {
  name = "wand",
  icon = "ability_shootwand",
  body = "#showtooltip Shoot\n/cast Shoot",
}

C["pr-abolish"] = {
  name = "ad",
  icon = "spell_nature_nullifydisease",
  body = "#showtooltip Abolish Disease\n/cast [mod:alt,target=player] Abolish Disease; [target=mouseover,exists] Abolish Disease; Abolish Disease",
}

C["pr-pof"] = {
  name = "pof",
  icon = "spell_holy_prayeroffortitude",
  body = "#showtooltip Prayer of Fortitude\n/cast Prayer of Fortitude",
}

C["pr-spirit"] = {
  name = "pos",
  icon = "spell_holy_prayerofspirit",
  body = "#showtooltip Prayer of Spirit\n/cast Prayer of Spirit",
}

C["pr-swp"] = {
  name = "swp",
  icon = "spell_shadow_shadowwordpain",
  body = "#showtooltip\n/cast [mod:shift] Shadow Word: Pain(Rank 1); Shadow Word: Pain",
}

C["pr-mf"] = {
  name = "mf",
  icon = "spell_shadow_siphonmana",
  body = "#showtooltip Mind Flay\n/cast Mind Flay",
}

C["pr-mb"] = {
  name = "mblast",
  icon = "spell_shadow_unholyfrenzy",
  body = "#showtooltip Mind Blast\n/cast Mind Blast",
}

C["pr-ve"] = {
  name = "ve",
  icon = "spell_shadow_unsummonbuilding",
  body = "#showtooltip Vampiric Embrace\n/cast Vampiric Embrace",
}

C["pr-sf"] = {
  name = "sf",
  icon = "spell_shadow_shadowform",
  body = "#showtooltip Shadowform\n/cast Shadowform",
}

C["pr-silence"] = {
  name = "sil",
  icon = "spell_shadow_impphaseshift",
  body = "#showtooltip Silence\n/stopcasting\n/cast Silence",
}

C["pr-shackle"] = {
  name = "shk",
  icon = "spell_nature_slow",
  body = "#showtooltip Shackle Undead\n/stopcasting\n/cast Shackle Undead",
}

C["pr-healform"] = {
  name = "hf",
  icon = "spell_holy_flashheal",
  body = "#showtooltip Flash Heal\n/cancelaura Shadowform\n/cast [mod:alt,target=player] Flash Heal; Flash Heal",
}

C["s-es"] = {
  name = "es",
  icon = "spell_nature_earthshock",
  body = "#showtooltip Earth Shock\n/stopcasting\n/cast [mod:shift] Earth Shock(Rank 1); Earth Shock",
}

C["s-shock"] = {
  name = "fl",
  icon = "spell_fire_flameshock",
  body = "#showtooltip\n/cast [mod:shift] Frost Shock; Flame Shock",
}

C["s-ss"] = {
  name = "storm",
  icon = "ability_shaman_stormstrike",
  body = "#showtooltip Stormstrike\n/startattack\n/cast Stormstrike",
}

C["s-lb"] = {
  name = "lb",
  icon = "spell_nature_lightning",
  body = "#showtooltip\n/cast [mod:shift] Lightning Bolt(Rank 1); Lightning Bolt",
}

C["s-cl"] = {
  name = "chain",
  icon = "spell_nature_chainlightning",
  body = "#showtooltip Chain Lightning\n/cast Chain Lightning",
}

C["s-ls"] = {
  name = "lshield",
  icon = "spell_nature_lightningshield",
  body = "#showtooltip Lightning Shield\n/cast Lightning Shield",
}

C["s-wf"] = {
  name = "wf",
  icon = "spell_nature_cyclone",
  body = "#showtooltip\n/cast [mod:shift] Flametongue Weapon; Windfury Weapon",
}

C["s-lhw"] = {
  name = "lhw",
  icon = "spell_nature_healingway",
  body = "#showtooltip\n/cast [mod:alt,target=player] Lesser Healing Wave; [mod:shift] Lesser Healing Wave(Rank 4); [mod:ctrl] Lesser Healing Wave(Rank 1); Lesser Healing Wave",
}

C["s-hw"] = {
  name = "hw",
  icon = "spell_nature_magicimmunity",
  body = "#showtooltip\n/cast [mod:alt,target=player] Healing Wave; [mod:shift] Healing Wave(Rank 1); Healing Wave",
}

C["s-ns"] = {
  name = "ns",
  icon = "spell_nature_ravenform",
  body = "#showtooltip Healing Wave\n/cast Nature's Swiftness\n/cast Healing Wave",
}

C["s-purge"] = {
  name = "pg",
  icon = "spell_nature_purge",
  body = "#showtooltip Purge\n/cast [target=mouseover,exists] Purge; Purge",
}

C["s-wolf"] = {
  name = "gw",
  icon = "spell_nature_spiritwolf",
  body = "#showtooltip Ghost Wolf\n/cast Ghost Wolf",
}

C["s-ground"] = {
  name = "gt",
  icon = "spell_nature_groundingtotem",
  body = "#showtooltip\n/cast [mod:shift] Grounding Totem; Windfury Totem",
}

C["s-tremor"] = {
  name = "tt",
  icon = "spell_nature_tremortotem",
  body = "#showtooltip Tremor Totem\n/cast Tremor Totem",
}

C["s-mana"] = {
  name = "mst",
  icon = "spell_nature_manaregentotem",
  body = "#showtooltip Mana Spring Totem\n/cast Mana Spring Totem",
}

C["s-str"] = {
  name = "str",
  icon = "spell_nature_earthbindtotem",
  body = "#showtooltip Strength of Earth Totem\n/cast Strength of Earth Totem",
}

C["s-tide"] = {
  name = "mt",
  icon = "spell_frost_summonwaterelemental",
  body = "#showtooltip Mana Tide Totem\n/cast Mana Tide Totem",
}

C["s-cure"] = {
  name = "cure",
  icon = "spell_nature_nullifypoison",
  body = "#showtooltip Cure Poison\n/cast [mod:alt,target=player] Cure Poison; [target=mouseover,exists] Cure Poison; Cure Poison",
}

C["l-tap"] = {
  name = "lt",
  icon = "spell_shadow_burningspirit",
  body = "#showtooltip\n/cast [mod:shift] Life Tap(Rank 1); Life Tap",
}

C["l-sb"] = {
  name = "sbolt",
  icon = "spell_shadow_shadowbolt",
  body = "#showtooltip\n/cast [mod:shift] Shadow Bolt(Rank 1); Shadow Bolt",
}

C["l-imm"] = {
  name = "imm",
  icon = "spell_fire_immolation",
  body = "#showtooltip Immolate\n/cast Immolate",
}

C["l-corr"] = {
  name = "corr",
  icon = "spell_shadow_abominationexplosion",
  body = "#showtooltip\n/cast [mod:shift] Corruption(Rank 1); Corruption",
}

C["l-coa"] = {
  name = "coa",
  icon = "spell_shadow_curseofsargeras",
  body = "#showtooltip\n/cast [mod:shift] Curse of Agony; Curse of the Elements",
}

C["l-fear"] = {
  name = "fear",
  icon = "spell_shadow_possession",
  body = "#showtooltip\n/stopcasting\n/cast [mod:shift] Fear(Rank 1); Fear",
}

C["l-lock"] = {
  name = "lock",
  icon = "spell_shadow_mindrot",
  body = "#showtooltip Spell Lock\n/stopcasting\n/cast Spell Lock",
}

C["l-sum"] = {
  name = "sum",
  icon = "spell_shadow_twilight",
  body = "/ra Summoning %t\n/rw Summoning %t, click!\n/cast Ritual of Summoning",
}

C["l-ss"] = {
  name = "soulstone",
  icon = "inv_misc_orb_04",
  body = "#showtooltip Major Soulstone\n/raid Soulstone on %t\n/use Major Soulstone",
}

C["l-sac"] = {
  name = "sac",
  icon = "spell_shadow_sacrificialshield",
  body = "#showtooltip Sacrifice\n/cast Sacrifice",
}

C["l-banish"] = {
  name = "ban",
  icon = "spell_shadow_cripple",
  body = "#showtooltip Banish\n/stopcasting\n/cast Banish",
}

C["l-coil"] = {
  name = "dc",
  icon = "spell_shadow_deathcoil",
  body = "#showtooltip Death Coil\n/cast Death Coil",
}

C["l-fel"] = {
  name = "fel",
  icon = "spell_shadow_summonfelhunter",
  body = "#showtooltip\n/cast [mod:shift] Summon Succubus; Summon Felhunter",
}

C["l-armor"] = {
  name = "da",
  icon = "spell_shadow_ragingscream",
  body = "#showtooltip Demon Armor\n/cast Demon Armor",
}

C["l-drain"] = {
  name = "drain",
  icon = "spell_shadow_haunting",
  body = "#showtooltip\n/cast [mod:shift] Drain Soul(Rank 1); Drain Soul",
}

C["l-shadowburn"] = {
  name = "sbn",
  icon = "spell_shadow_scourgebuild",
  body = "#showtooltip Shadowburn\n/cast Shadowburn",
}

C["l-wand"] = {
  name = "lwand",
  icon = "ability_shootwand",
  body = "#showtooltip Shoot\n/cast Shoot",
}

C["d-shred"] = {
  name = "shred",
  icon = "spell_shadow_vampiricaura",
  body = "#showtooltip Shred\n/startattack\n/cast Shred",
}

C["d-fb"] = {
  name = "fbite",
  icon = "ability_druid_ferociousbite",
  body = "#showtooltip\n/cast [mod:shift] Ferocious Bite(Rank 1); Ferocious Bite",
}

C["d-rip"] = {
  name = "rip",
  icon = "ability_ghoulfrenzy",
  body = "#showtooltip Rip\n/cast Rip",
}

C["d-rake"] = {
  name = "rake",
  icon = "ability_druid_disembowel",
  body = "#showtooltip Rake\n/startattack\n/cast Rake",
}

C["d-prowl"] = {
  name = "pr",
  icon = "ability_druid_prowl",
  body = "#showtooltip Prowl\n/cast [noform:3] Cat Form\n/cast Prowl",
}

C["d-maul"] = {
  name = "ml",
  icon = "ability_druid_maul",
  body = "#showtooltip Maul\n/startattack\n/cast Maul",
}

C["d-growl"] = {
  name = "gr",
  icon = "ability_physical_taunt",
  body = "#showtooltip Growl\n/cast [noform:1] Dire Bear Form\n/cast Growl",
}

C["d-bash"] = {
  name = "bash",
  icon = "ability_druid_bash",
  body = "#showtooltip Bash\n/stopcasting\n/cast Bash",
}

C["d-ff"] = {
  name = "ff",
  icon = "spell_nature_faeriefire",
  body = "#showtooltip\n/cast [form:1/3] Faerie Fire (Feral); Faerie Fire",
}

C["d-charge"] = {
  name = "fc",
  icon = "ability_hunter_pet_bear",
  body = "#showtooltip Feral Charge\n/cast Feral Charge",
}

C["d-fr"] = {
  name = "fr",
  icon = "ability_bullrush",
  body = "#showtooltip Frenzied Regeneration\n/cast Frenzied Regeneration",
}

C["d-dash"] = {
  name = "dash",
  icon = "ability_druid_dash",
  body = "#showtooltip Dash\n/cast Dash",
}

C["d-cat"] = {
  name = "cat",
  icon = "ability_druid_catform",
  body = "#showtooltip\n/cast [mod:shift] Travel Form; Cat Form",
}

C["d-bear"] = {
  name = "bear",
  icon = "ability_racial_bearform",
  body = "#showtooltip Dire Bear Form\n/cast Dire Bear Form",
}

C["d-ht"] = {
  name = "ht",
  icon = "spell_nature_healingtouch",
  body = "#showtooltip\n/cancelform\n/cast [mod:alt,target=player] Healing Touch; [mod:shift] Healing Touch(Rank 4); [mod:ctrl] Healing Touch(Rank 1); Healing Touch",
}

C["d-inn"] = {
  name = "inn",
  icon = "spell_nature_lightning",
  body = "#showtooltip Innervate\n/cancelform\n/raid Innervate on %t\n/cast [mod:alt,target=player] Innervate; Innervate",
}

C["d-reb"] = {
  name = "reb",
  icon = "spell_nature_reincarnation",
  body = "#showtooltip Rebirth\n/cancelform\n/raid {rt8} Rebirth on %t {rt8}\n/cast Rebirth",
}

C["d-motw"] = {
  name = "motw",
  icon = "spell_nature_regeneration",
  body = "#showtooltip Mark of the Wild\n/cancelform\n/cast [mod:alt,target=player] Mark of the Wild; Mark of the Wild",
}

C["d-mf"] = {
  name = "mfire",
  icon = "spell_nature_starfall",
  body = "#showtooltip\n/cast [mod:shift] Moonfire(Rank 1); Moonfire",
}

C["d-wrath"] = {
  name = "wr",
  icon = "spell_nature_abolishmagic",
  body = "#showtooltip Wrath\n/cast Wrath",
}

C["d-star"] = {
  name = "stf",
  icon = "spell_arcane_starfire",
  body = "#showtooltip Starfire\n/cast Starfire",
}

C["d-moonkin"] = {
  name = "mk",
  icon = "spell_nature_forceofnature",
  body = "#showtooltip Moonkin Form\n/cast Moonkin Form",
}

C["d-roots"] = {
  name = "er",
  icon = "spell_nature_stranglevines",
  body = "#showtooltip\n/cancelform\n/cast [mod:shift] Entangling Roots(Rank 1); Entangling Roots",
}

C["d-rejuv"] = {
  name = "rej",
  icon = "spell_nature_rejuvenation",
  body = "#showtooltip\n/cancelform\n/cast [mod:alt,target=player] Rejuvenation; [mod:shift] Rejuvenation(Rank 3); Rejuvenation",
}

C["d-swift"] = {
  name = "sm",
  icon = "inv_relics_idolofrejuvenation",
  body = "#showtooltip Swiftmend\n/cancelform\n/cast Swiftmend",
}

C["d-ns"] = {
  name = "dnsw",
  icon = "spell_nature_ravenform",
  body = "#showtooltip Healing Touch\n/cancelform\n/cast Nature's Swiftness\n/cast Healing Touch",
}

C["shared-gotn"] = {
  name = "gotn",
  icon = "spell_holy_holyprotection",
  body = "#showtooltip Gift of the Naaru\n/cast [mod:alt,target=player] Gift of the Naaru; Gift of the Naaru",
}

C["shared-at"] = {
  name = "atorrent",
  icon = "spell_shadow_teleport",
  body = "#showtooltip Arcane Torrent\n/stopcasting\n/cast Arcane Torrent",
}

C["w-cshout"] = {
  name = "cshout",
  icon = "ability_warrior_rallyingcry",
  body = "#showtooltip Commanding Shout\n/cast Commanding Shout\n/startattack",
}

C["w-intervene"] = {
  name = "interv",
  icon = "ability_warrior_victoryrush",
  body = "#showtooltip Intervene\n/cast [nostance:2] Defensive Stance\n/cast [target=mouseover,help,nodead][] Intervene",
}

C["w-reflect"] = {
  name = "reflect",
  icon = "ability_warrior_shieldreflection",
  body = "#showtooltip Spell Reflection\n/stopcasting\n/cast [nostance:2] Defensive Stance\n/cast Spell Reflection",
}

C["w-vrush"] = {
  name = "vrush",
  icon = "ability_warrior_devastate",
  body = "#showtooltip Victory Rush\n/cast [stance:2] Battle Stance\n/cast Victory Rush\n/startattack",
}

C["p-cstrike"] = {
  name = "cstrike",
  icon = "spell_holy_crusaderstrike",
  body = "#showtooltip Crusader Strike\n/startattack\n/cast Crusader Strike",
}

C["p-aw"] = {
  name = "aw",
  icon = "spell_holy_avenginewrath",
  body = "#showtooltip Avenging Wrath\n/use 13\n/cast Avenging Wrath",
}

C["p-rdef"] = {
  name = "rdef",
  icon = "inv_shoulder_37",
  body = "#showtooltip Righteous Defense\n/cast [target=mouseover,help,nodead][] Righteous Defense",
}

C["p-ashield"] = {
  name = "ashield",
  icon = "spell_holy_avengersshield",
  body = "#showtooltip Avenger's Shield\n/startattack\n/cast Avenger's Shield",
}

C["p-sealtbc"] = {
  name = "sealtbc",
  icon = "spell_holy_sealofblood",
  body = "#showtooltip\n/cast Seal of Blood\n/cast Seal of Vengeance\n/cast Seal of the Martyr\n/cast Seal of Corruption",
}

C["p-turne"] = {
  name = "turne",
  icon = "spell_holy_turnundead",
  body = "#showtooltip Turn Evil\n/stopcasting\n/cast Turn Evil",
}

C["p-caura"] = {
  name = "caura",
  icon = "spell_holy_crusaderaura",
  body = "#showtooltip Crusader Aura\n/cast Crusader Aura",
}

C["h-steady"] = {
  name = "steady",
  icon = "ability_hunter_steadyshot",
  body = "#showtooltip Steady Shot\n/cast Steady Shot",
}

C["h-kc"] = {
  name = "kc",
  icon = "ability_hunter_killcommand",
  body = "#showtooltip Kill Command\n/petattack\n/cast Kill Command",
}

C["h-md"] = {
  name = "md",
  icon = "ability_hunter_misdirection",
  body = "#showtooltip Misdirection\n/cast [target=mouseover,help,nodead] Misdirection; [target=pet,exists] Misdirection; Misdirection",
}

C["h-snake"] = {
  name = "snake",
  icon = "ability_hunter_snaketrap",
  body = "#showtooltip Snake Trap\n/cast Snake Trap",
}

C["h-aspv"] = {
  name = "aspv",
  icon = "ability_hunter_aspectoftheviper",
  body = "#showtooltip\n/cast [mod:shift] Aspect of the Viper; [mod:ctrl] Aspect of the Monkey; Aspect of the Hawk",
}

C["r-cloak"] = {
  name = "cloak",
  icon = "spell_shadow_nethercloak",
  body = "#showtooltip Cloak of Shadows\n/stopcasting\n/cast Cloak of Shadows",
}

C["r-dthrow"] = {
  name = "dthrow",
  icon = "inv_throwingknife_06",
  body = "#showtooltip Deadly Throw\n/cast Deadly Throw",
}

C["r-shiv"] = {
  name = "shiv",
  icon = "inv_throwingknife_04",
  body = "#showtooltip Shiv\n/startattack\n/cast Shiv",
}

C["r-env"] = {
  name = "env",
  icon = "ability_rogue_disembowel",
  body = "#showtooltip Envenom\n/cast Envenom",
}

C["r-step"] = {
  name = "step",
  icon = "ability_rogue_shadowstep",
  body = "#showtooltip Shadowstep\n/cast Shadowstep",
}

C["r-mut"] = {
  name = "mut",
  icon = "ability_rogue_shadowstrikes",
  body = "#showtooltip Mutilate\n/startattack\n/cast Mutilate",
}

C["pr-swd"] = {
  name = "swd",
  icon = "spell_shadow_demonicfortitude",
  body = "#showtooltip Shadow Word: Death\n/cast Shadow Word: Death",
}

C["pr-pom"] = {
  name = "pom",
  icon = "spell_holy_prayerofmendingtga",
  body = "#showtooltip Prayer of Mending\n/cast [mod:alt,target=player] Prayer of Mending; Prayer of Mending",
}

C["pr-coh"] = {
  name = "coh",
  icon = "spell_holy_circleofrenewal",
  body = "#showtooltip Circle of Healing\n/cast [mod:alt,target=player] Circle of Healing; Circle of Healing",
}

C["pr-psup"] = {
  name = "psup",
  icon = "spell_holy_painsupression",
  body = "#showtooltip Pain Suppression\n/raid Pain Suppression on %t\n/cast [mod:alt,target=player] Pain Suppression; Pain Suppression",
}

C["pr-mdisp"] = {
  name = "mdisp",
  icon = "spell_arcane_massdispel",
  body = "#showtooltip Mass Dispel\n/stopcasting\n/cast Mass Dispel",
}

C["pr-sfiend"] = {
  name = "sfiend",
  icon = "spell_shadow_shadowfiend",
  body = "#showtooltip Shadowfiend\n/cast Shadowfiend",
}

C["pr-bheal"] = {
  name = "bheal",
  icon = "spell_holy_blindingheal",
  body = "#showtooltip Binding Heal\n/cast Binding Heal",
}

C["pr-vt"] = {
  name = "vt",
  icon = "spell_holy_stoicism",
  body = "#showtooltip Vampiric Touch\n/cast Vampiric Touch",
}

C["pr-cmagic"] = {
  name = "cmagic",
  icon = "spell_arcane_studentofmagic",
  body = "#showtooltip Consume Magic\n/stopcasting\n/cast Consume Magic",
}

C["pr-chast"] = {
  name = "chast",
  icon = "spell_holy_chastise",
  body = "#showtooltip Chastise\n/stopcasting\n/cast Chastise",
}

C["s-bl"] = {
  name = "bl",
  icon = "spell_nature_bloodlust",
  body = "#showtooltip\n/cast Bloodlust\n/cast Heroism",
}

C["s-wshield"] = {
  name = "wshield",
  icon = "ability_shaman_watershield",
  body = "#showtooltip\n/cast [mod:shift] Lightning Shield; Water Shield",
}

C["s-eshield"] = {
  name = "eshield",
  icon = "spell_nature_skinofearth",
  body = "#showtooltip Earth Shield\n/cast [mod:alt,target=player] Earth Shield; Earth Shield",
}

C["s-srage"] = {
  name = "srage",
  icon = "spell_nature_shamanrage",
  body = "#showtooltip Shamanistic Rage\n/cast Shamanistic Rage",
}

C["s-woa"] = {
  name = "woa",
  icon = "spell_nature_slowingtotem",
  body = "#showtooltip Wrath of Air Totem\n/cast Wrath of Air Totem",
}

C["s-towrath"] = {
  name = "towrath",
  icon = "spell_fire_totemofwrath",
  body = "#showtooltip Totem of Wrath\n/cast Totem of Wrath",
}

C["s-eet"] = {
  name = "eet",
  icon = "spell_nature_earthelemental_totem",
  body = "#showtooltip Earth Elemental Totem\n/cast Earth Elemental Totem",
}

C["s-fet"] = {
  name = "fet",
  icon = "spell_fire_elemental_totem",
  body = "#showtooltip Fire Elemental Totem\n/cast Fire Elemental Totem",
}

C["s-tcall"] = {
  name = "tcall",
  icon = "spell_unused",
  body = "#showtooltip Totemic Call\n/cast Totemic Call",
}

C["m-ilance"] = {
  name = "ilance",
  icon = "spell_frost_frostblast",
  body = "#showtooltip Ice Lance\n/cast Ice Lance",
}

C["m-steal"] = {
  name = "steal",
  icon = "spell_arcane_arcane02",
  body = "#showtooltip Spellsteal\n/stopcasting\n/cast Spellsteal",
}

C["m-invis"] = {
  name = "invis",
  icon = "ability_mage_invisibility",
  body = "#showtooltip Invisibility\n/stopcasting\n/cast Invisibility",
}

C["m-molten"] = {
  name = "molten",
  icon = "ability_mage_moltenarmor",
  body = "#showtooltip Molten Armor\n/cast Molten Armor",
}

C["m-ablast"] = {
  name = "ablast",
  icon = "spell_arcane_blast",
  body = "#showtooltip Arcane Blast\n/cqs\n/cast Arcane Blast",
}

C["m-slow"] = {
  name = "mslow",
  icon = "spell_nature_slow",
  body = "#showtooltip Slow\n/cast Slow",
}

C["m-dbreath"] = {
  name = "dbreath",
  icon = "inv_misc_head_dragon_01",
  body = "#showtooltip Dragon's Breath\n/cast Dragon's Breath",
}

C["m-welem"] = {
  name = "welem",
  icon = "spell_frost_summonwaterelemental_2",
  body = "#showtooltip Summon Water Elemental\n/cast Summon Water Elemental",
}

C["m-table"] = {
  name = "mtable",
  icon = "spell_arcane_massdispel",
  body = "#showtooltip Ritual of Refreshment\n/cast Ritual of Refreshment",
}

C["m-gemtbc"] = {
  name = "gemtbc",
  icon = "inv_misc_gem_stone_01",
  body = "#showtooltip Conjure Mana Emerald\n/cast Conjure Mana Emerald",
}

C["m-exodar"] = {
  name = "exodar",
  icon = "spell_arcane_portalexodar",
  body = "#showtooltip [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar\n/cast [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar",
}

C["m-slvr"] = {
  name = "slvr",
  icon = "spell_arcane_portalsilvermoon",
  body = "#showtooltip [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon\n/cast [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon",
}

C["m-shat"] = {
  name = "shat",
  icon = "spell_arcane_portalshattrath",
  body = "#showtooltip [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath\n/cast [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath",
}

C["m-thera"] = {
  name = "thera",
  icon = "spell_arcane_portaltheramore",
  body = "#showtooltip [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore\n/cast [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore",
}

C["m-stonard"] = {
  name = "stonard",
  icon = "spell_arcane_portalstonard",
  body = "#showtooltip [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard\n/cast [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard",
}

C["l-incin"] = {
  name = "incin",
  icon = "spell_fire_burnout",
  body = "#showtooltip Incinerate\n/cast Incinerate",
}

C["l-felarm"] = {
  name = "felarm",
  icon = "spell_shadow_felarmour",
  body = "#showtooltip\n/cast [mod:shift] Demon Armor; Fel Armor",
}

C["l-shatter"] = {
  name = "shatter",
  icon = "spell_arcane_arcane01",
  body = "#showtooltip Soulshatter\n/cast Soulshatter",
}

C["l-souls"] = {
  name = "souls",
  icon = "spell_shadow_shadesofdarkness",
  body = "#showtooltip Ritual of Souls\n/cast Ritual of Souls",
}

C["l-seed"] = {
  name = "seed",
  icon = "spell_shadow_seedofdestruction",
  body = "#showtooltip Seed of Corruption\n/cast Seed of Corruption",
}

C["l-ua"] = {
  name = "ua",
  icon = "spell_shadow_unstableaffliction_3",
  body = "#showtooltip Unstable Affliction\n/cast Unstable Affliction",
}

C["l-sfury"] = {
  name = "sfury",
  icon = "spell_shadow_shadowfury",
  body = "#showtooltip Shadowfury\n/stopcasting\n/cast Shadowfury",
}

C["l-fguard"] = {
  name = "fguard",
  icon = "spell_shadow_summonfelguard",
  body = "#showtooltip Summon Felguard\n/cast Summon Felguard",
}

C["d-mangle"] = {
  name = "mangle",
  icon = "ability_druid_mangle2",
  body = "#showtooltip\n/startattack\n/cast [form:3] Mangle (Cat); Mangle (Bear)",
}

C["d-lbloom"] = {
  name = "lbloom",
  icon = "inv_misc_herb_felblossom",
  body = "#showtooltip Lifebloom\n/cancelform\n/cast [mod:alt,target=player] Lifebloom; Lifebloom",
}

C["d-cyc"] = {
  name = "cyc",
  icon = "spell_nature_earthbind",
  body = "#showtooltip Cyclone\n/stopcasting\n/cast Cyclone",
}

C["d-flight"] = {
  name = "flight",
  icon = "ability_druid_flightform",
  body = "#showtooltip\n/cast [mod:shift] Swift Flight Form; Flight Form",
}

C["d-lac"] = {
  name = "lac",
  icon = "ability_druid_lacerate",
  body = "#showtooltip Lacerate\n/startattack\n/cast Lacerate",
}

C["d-maim"] = {
  name = "maim",
  icon = "ability_druid_mangle-tga",
  body = "#showtooltip Maim\n/cast Maim",
}

C["d-tree"] = {
  name = "tree",
  icon = "ability_druid_treeoflife",
  body = "#showtooltip Tree of Life\n/cast Tree of Life",
}

C["p-gbom"] = {
  name = "gbom",
  icon = "spell_holy_greaterblessingofkings",
  body = "#showtooltip\n/cast [nomod]Greater Blessing of Might;[mod:shift]Greater Blessing of Might(Rank 1)",
}

C["p-crus"] = {
  name = "crus",
  icon = "spell_holy_holysmite",
  body = "#showtooltip\n/cast [nomod]Seal of the Crusader;[mod:shift]Seal of the Crusader(Rank 1)",
}

C["p-bosac"] = {
  name = "bosac",
  icon = "spell_holy_sealofsacrifice",
  body = "#showtooltip\n/cast [nomod]Blessing of Sacrifice;[mod:shift]Blessing of Sacrifice(Rank 1)",
}

C["p-dprot"] = {
  name = "dprot",
  icon = "spell_holy_restoration",
  body = "#showtooltip\n/cast [nomod]Divine Protection;[mod:shift]Divine Protection(Rank 1)",
}

C["p-fraura"] = {
  name = "fraura",
  icon = "spell_fire_sealoffire",
  body = "#showtooltip\n/cast [nomod]Fire Resistance Aura;[mod:shift]Fire Resistance Aura(Rank 1)",
}

C["p-rfaura"] = {
  name = "rfaura",
  icon = "spell_frost_wizardmark",
  body = "#showtooltip\n/cast [nomod]Frost Resistance Aura;[mod:shift]Frost Resistance Aura(Rank 1)",
}

C["p-sraura"] = {
  name = "sraura",
  icon = "spell_shadow_sealofkings",
  body = "#showtooltip\n/cast [nomod]Shadow Resistance Aura;[mod:shift]Shadow Resistance Aura(Rank 1)",
}

C["p-bolight"] = {
  name = "bolight",
  icon = "spell_holy_prayerofhealing02",
  body = "#showtooltip\n/cast [nomod]Blessing of Light;[mod:shift]Blessing of Light(Rank 1)",
}

C["p-gbow"] = {
  name = "gbow",
  icon = "spell_holy_greaterblessingofwisdom",
  body = "#showtooltip\n/cast [nomod]Greater Blessing of Wisdom;[mod:shift]Greater Blessing of Wisdom(Rank 1)",
}

C["p-hwath"] = {
  name = "hwath",
  icon = "spell_holy_excorcism",
  body = "#showtooltip\n/cast [nomod]Holy Wrath;[mod:shift]Holy Wrath(Rank 1)",
}

C["p-redeem"] = {
  name = "redeem",
  icon = "spell_holy_resurrection",
  body = "#showtooltip\n/cast [nomod]Redemption;[mod:shift]Redemption(Rank 1)",
}

C["p-turnu"] = {
  name = "turnu",
  icon = "spell_holy_turnundead",
  body = "#showtooltip\n/cast [nomod]Turn Undead;[mod:shift]Turn Undead(Rank 1)",
}

C["h-wild"] = {
  name = "wild",
  icon = "spell_nature_protectionformnature",
  body = "#showtooltip\n/cast [nomod]Aspect of the Wild;[mod:shift]Aspect of the Wild(Rank 1)",
}

C["h-scare"] = {
  name = "scare",
  icon = "ability_druid_cower",
  body = "#showtooltip\n/cast [nomod]Scare Beast;[mod:shift]Scare Beast(Rank 1)",
}

C["h-dshot"] = {
  name = "dshot",
  icon = "spell_arcane_blink",
  body = "#showtooltip\n/cast [nomod]Distracting Shot;[mod:shift]Distracting Shot(Rank 1)",
}

C["h-scorpid"] = {
  name = "scorpid",
  icon = "ability_hunter_criticalshot",
  body = "#showtooltip\n/cast [nomod]Scorpid Sting;[mod:shift]Scorpid Sting(Rank 1)",
}

C["h-viper"] = {
  name = "viper",
  icon = "ability_hunter_aimedshot",
  body = "#showtooltip\n/cast [nomod]Viper Sting;[mod:shift]Viper Sting(Rank 1)",
}

C["h-volley"] = {
  name = "volley",
  icon = "ability_marksmanship",
  body = "#showtooltip\n/cast [nomod]Volley;[mod:shift]Volley(Rank 1)",
}

C["h-diseng"] = {
  name = "diseng",
  icon = "ability_rogue_feint",
  body = "#showtooltip\n/cast [nomod]Disengage;[mod:shift]Disengage(Rank 1)",
}

C["h-etrap"] = {
  name = "etrap",
  icon = "spell_fire_selfdestruct",
  body = "#showtooltip\n/cast [nomod]Explosive Trap;[mod:shift]Explosive Trap(Rank 1)",
}

C["h-itrap"] = {
  name = "itrap",
  icon = "spell_fire_flameshock",
  body = "#showtooltip\n/cast [nomod]Immolation Trap;[mod:shift]Immolation Trap(Rank 1)",
}

C["h-mongo"] = {
  name = "mongo",
  icon = "ability_hunter_swiftstrike",
  body = "#showtooltip\n/startattack\n/cast [nomod]Mongoose Bite;[mod:shift]Mongoose Bite(Rank 1)",
}

C["h-raptor"] = {
  name = "raptor",
  icon = "ability_meleedamage",
  body = "#showtooltip\n/startattack\n/cast [nomod]Raptor Strike;[mod:shift]Raptor Strike(Rank 1)",
}

C["r-expose"] = {
  name = "expose",
  icon = "ability_warrior_riposte",
  body = "#showtooltip\n/cast [nomod]Expose Armor;[mod:shift]Expose Armor(Rank 1)",
}

C["r-garrote"] = {
  name = "garrote",
  icon = "ability_rogue_garrote",
  body = "#showtooltip\n/cast [nomod]Garrote;[mod:shift]Garrote(Rank 1)",
}

C["r-bstab"] = {
  name = "bstab",
  icon = "ability_backstab",
  body = "#showtooltip\n/startattack\n/cast [nomod]Backstab;[mod:shift]Backstab(Rank 1)",
}

C["r-feint"] = {
  name = "feint",
  icon = "ability_rogue_feint",
  body = "#showtooltip\n/cast [nomod]Feint;[mod:shift]Feint(Rank 1)",
}

C["pr-egrace"] = {
  name = "egrace",
  icon = "spell_holy_elunesgrace",
  body = "#showtooltip\n/cast [nomod]Elune's Grace;[mod:shift]Elune's Grace(Rank 1)",
}

C["pr-fback"] = {
  name = "fback",
  icon = "spell_shadow_ritualofsacrifice",
  body = "#showtooltip\n/cast [nomod]Feedback;[mod:shift]Feedback(Rank 1)",
}

C["pr-mburn"] = {
  name = "mburn",
  icon = "spell_shadow_manaburn",
  body = "#showtooltip\n/cast [nomod]Mana Burn;[mod:shift]Mana Burn(Rank 1)",
}

C["pr-shards"] = {
  name = "shards",
  icon = "spell_arcane_starfire",
  body = "#showtooltip\n/cast [nomod]Starshards;[mod:shift]Starshards(Rank 1)",
}

C["pr-dpray"] = {
  name = "dpray",
  icon = "spell_holy_restoration",
  body = "#showtooltip\n/cast [nomod]Desperate Prayer;[mod:shift]Desperate Prayer(Rank 1)",
}

C["pr-heal"] = {
  name = "heal",
  icon = "spell_holy_heal02",
  body = "#showtooltip\n/cast [mod:alt,target=player] Heal; [mod:shift] Heal(Rank 1); Heal",
}

C["pr-hfire"] = {
  name = "hfire",
  icon = "spell_holy_searinglight",
  body = "#showtooltip\n/cast [nomod]Holy Fire;[mod:shift]Holy Fire(Rank 1)",
}

C["pr-lheal"] = {
  name = "lheal",
  icon = "spell_holy_lesserheal",
  body = "#showtooltip\n/cast [mod:alt,target=player] Lesser Heal; [mod:shift] Lesser Heal(Rank 1); Lesser Heal",
}

C["pr-smite"] = {
  name = "smite",
  icon = "spell_holy_holysmite",
  body = "#showtooltip\n/cast [nomod]Smite;[mod:shift]Smite(Rank 1)",
}

C["pr-dplague"] = {
  name = "dplague",
  icon = "spell_shadow_blackplague",
  body = "#showtooltip\n/cast [nomod]Devouring Plague;[mod:shift]Devouring Plague(Rank 1)",
}

C["pr-hexw"] = {
  name = "hexw",
  icon = "spell_shadow_fingerofdeath",
  body = "#showtooltip\n/cast [nomod]Hex of Weakness;[mod:shift]Hex of Weakness(Rank 1)",
}

C["pr-mc"] = {
  name = "mc",
  icon = "spell_shadow_shadowworddominate",
  body = "#showtooltip\n/cast [nomod]Mind Control;[mod:shift]Mind Control(Rank 1)",
}

C["pr-msoothe"] = {
  name = "msoothe",
  icon = "spell_holy_mindsooth",
  body = "#showtooltip\n/cast [nomod]Mind Soothe;[mod:shift]Mind Soothe(Rank 1)",
}

C["pr-mvis"] = {
  name = "mvis",
  icon = "spell_holy_mindvision",
  body = "#showtooltip\n/cast [nomod]Mind Vision;[mod:shift]Mind Vision(Rank 1)",
}

C["pr-sprot"] = {
  name = "sprot",
  icon = "spell_shadow_antishadow",
  body = "#showtooltip\n/cast [nomod]Shadow Protection;[mod:shift]Shadow Protection(Rank 1)",
}

C["pr-sguard"] = {
  name = "sguard",
  icon = "spell_nature_lightningshield",
  body = "#showtooltip\n/cast [nomod]Shadowguard;[mod:shift]Shadowguard(Rank 1)",
}

C["pr-tow"] = {
  name = "tow",
  icon = "spell_shadow_deadofnight",
  body = "#showtooltip\n/cast [nomod]Touch of Weakness;[mod:shift]Touch of Weakness(Rank 1)",
}

C["s-fnt"] = {
  name = "fnt",
  icon = "spell_fire_sealoffire",
  body = "#showtooltip\n/cast [nomod]Fire Nova Totem;[mod:shift]Fire Nova Totem(Rank 1)",
}

C["s-magma"] = {
  name = "magma",
  icon = "spell_fire_selfdestruct",
  body = "#showtooltip\n/cast [nomod]Magma Totem;[mod:shift]Magma Totem(Rank 1)",
}

C["s-sear"] = {
  name = "sear",
  icon = "spell_fire_searingtotem",
  body = "#showtooltip\n/cast [nomod]Searing Totem;[mod:shift]Searing Totem(Rank 1)",
}

C["s-sclaw"] = {
  name = "sclaw",
  icon = "spell_nature_stoneclawtotem",
  body = "#showtooltip\n/cast [nomod]Stoneclaw Totem;[mod:shift]Stoneclaw Totem(Rank 1)",
}

C["s-frtot"] = {
  name = "frtot",
  icon = "spell_fireresistancetotem_01",
  body = "#showtooltip\n/cast [nomod]Fire Resistance Totem;[mod:shift]Fire Resistance Totem(Rank 1)",
}

C["s-fttot"] = {
  name = "fttot",
  icon = "spell_nature_guardianward",
  body = "#showtooltip\n/cast [nomod]Flametongue Totem;[mod:shift]Flametongue Totem(Rank 1)",
}

C["s-rftot"] = {
  name = "rftot",
  icon = "spell_frostresistancetotem_01",
  body = "#showtooltip\n/cast [nomod]Frost Resistance Totem;[mod:shift]Frost Resistance Totem(Rank 1)",
}

C["s-fbrand"] = {
  name = "fbrand",
  icon = "spell_frost_frostbrand",
  body = "#showtooltip\n/cast [nomod]Frostbrand Weapon;[mod:shift]Frostbrand Weapon(Rank 1)",
}

C["s-goa"] = {
  name = "goa",
  icon = "spell_nature_invisibilitytotem",
  body = "#showtooltip\n/cast [nomod]Grace of Air Totem;[mod:shift]Grace of Air Totem(Rank 1)",
}

C["s-nrtot"] = {
  name = "nrtot",
  icon = "spell_nature_natureresistancetotem",
  body = "#showtooltip\n/cast [nomod]Nature Resistance Totem;[mod:shift]Nature Resistance Totem(Rank 1)",
}

C["s-rbit"] = {
  name = "rbit",
  icon = "spell_nature_rockbiter",
  body = "#showtooltip\n/cast [nomod]Rockbiter Weapon;[mod:shift]Rockbiter Weapon(Rank 1)",
}

C["s-sskin"] = {
  name = "sskin",
  icon = "spell_nature_stoneskintotem",
  body = "#showtooltip\n/cast [nomod]Stoneskin Totem;[mod:shift]Stoneskin Totem(Rank 1)",
}

C["s-wwall"] = {
  name = "wwall",
  icon = "spell_nature_earthbind",
  body = "#showtooltip\n/cast [nomod]Windwall Totem;[mod:shift]Windwall Totem(Rank 1)",
}

C["s-aspirit"] = {
  name = "aspirit",
  icon = "spell_nature_regenerate",
  body = "#showtooltip\n/cast [nomod]Ancestral Spirit;[mod:shift]Ancestral Spirit(Rank 1)",
}

C["s-cheal"] = {
  name = "cheal",
  icon = "spell_nature_healingwavegreater",
  body = "#showtooltip\n/cast [mod:alt,target=player] Chain Heal; [mod:shift] Chain Heal(Rank 1); Chain Heal",
}

C["s-hstot"] = {
  name = "hstot",
  icon = "inv_spear_04",
  body = "#showtooltip\n/cast [nomod]Healing Stream Totem;[mod:shift]Healing Stream Totem(Rank 1)",
}

C["m-ai"] = {
  name = "ai",
  icon = "spell_holy_magicalsentry",
  body = "#showtooltip\n/cast Arcane Intellect;",
}

C["m-cf"] = {
  name = "cf",
  icon = "inv_misc_food_73cinnamonroll",
  body = "#showtooltip\n/cast Conjure Food",
}

C["m-cw"] = {
  name = "cw",
  icon = "inv_drink_18",
  body = "#showtooltip\n/cast Conjure Water",
}

C["m-ma"] = {
  name = "ma",
  icon = "spell_magearmor",
  body = "#showtooltip\n/cast Mage Armor;",
}

C["m-ia"] = {
  name = "ia",
  icon = "spell_frost_frostarmor02",
  body = "#showtooltip\n/cast Ice Armor;",
}

C["l-cor"] = {
  name = "cor",
  icon = "spell_shadow_unholystrength",
  body = "#showtooltip\n/cast [nomod]Curse of Recklessness;[mod:shift]Curse of Recklessness(Rank 1)",
}

C["l-cosh"] = {
  name = "cosh",
  icon = "spell_shadow_curseofachimonde",
  body = "#showtooltip\n/cast [nomod]Curse of Shadow;[mod:shift]Curse of Shadow(Rank 1)",
}

C["l-cot"] = {
  name = "cot",
  icon = "spell_shadow_curseoftounges",
  body = "#showtooltip\n/cast [nomod]Curse of Tongues;[mod:shift]Curse of Tongues(Rank 1)",
}

C["l-cowk"] = {
  name = "cowk",
  icon = "spell_shadow_curseofmannoroth",
  body = "#showtooltip\n/cast [nomod]Curse of Weakness;[mod:shift]Curse of Weakness(Rank 1)",
}

C["l-dlife"] = {
  name = "dlife",
  icon = "spell_shadow_lifedrain02",
  body = "#showtooltip\n/cast [nomod]Drain Life;[mod:shift]Drain Life(Rank 1)",
}

C["l-dmana"] = {
  name = "dmana",
  icon = "spell_shadow_siphonmana",
  body = "#showtooltip\n/cast [nomod]Drain Mana;[mod:shift]Drain Mana(Rank 1)",
}

C["l-howl"] = {
  name = "howl",
  icon = "spell_shadow_deathscream",
  body = "#showtooltip\n/cast [nomod]Howl of Terror;[mod:shift]Howl of Terror(Rank 1)",
}

C["l-dskin"] = {
  name = "dskin",
  icon = "spell_shadow_ragingscream",
  body = "#showtooltip\n/cast [nomod]Demon Skin;[mod:shift]Demon Skin(Rank 1)",
}

C["l-hfunnel"] = {
  name = "hfunnel",
  icon = "spell_shadow_lifedrain",
  body = "#showtooltip\n/cast [nomod]Health Funnel;[mod:shift]Health Funnel(Rank 1)",
}

C["l-sward"] = {
  name = "sward",
  icon = "spell_shadow_antishadow",
  body = "#showtooltip\n/cast [nomod]Shadow Ward;[mod:shift]Shadow Ward(Rank 1)",
}

C["l-subj"] = {
  name = "subj",
  icon = "spell_shadow_enslavedemon",
  body = "#showtooltip\n/cast [nomod]Subjugate Demon;[mod:shift]Subjugate Demon(Rank 1)",
}

C["l-hell"] = {
  name = "hell",
  icon = "spell_fire_incinerate",
  body = "#showtooltip\n/cast [nomod]Hellfire;[mod:shift]Hellfire(Rank 1)",
}

C["l-rof"] = {
  name = "rof",
  icon = "spell_shadow_rainoffire",
  body = "#showtooltip\n/cast [nomod]Rain of Fire;[mod:shift]Rain of Fire(Rank 1)",
}

C["l-spain"] = {
  name = "spain",
  icon = "spell_fire_soulburn",
  body = "#showtooltip\n/cast [nomod]Searing Pain;[mod:shift]Searing Pain(Rank 1)",
}

C["l-sfire"] = {
  name = "sfire",
  icon = "spell_fire_fireball02",
  body = "#showtooltip\n/cast [nomod]Soul Fire;[mod:shift]Soul Fire(Rank 1)",
}

C["d-hib"] = {
  name = "hib",
  icon = "spell_nature_sleep",
  body = "#showtooltip\n/cancelform\n/cast [nomod]Hibernate;[mod:shift]Hibernate(Rank 1)",
}

C["d-cane"] = {
  name = "cane",
  icon = "spell_nature_cyclone",
  body = "#showtooltip\n/cast [nomod]Hurricane;[mod:shift]Hurricane(Rank 1)",
}

C["d-soothe"] = {
  name = "soothe",
  icon = "ability_hunter_beastsoothe",
  body = "#showtooltip\n/cancelform\n/cast [nomod]Soothe Animal;[mod:shift]Soothe Animal(Rank 1)",
}

C["d-thorns"] = {
  name = "thorns",
  icon = "spell_nature_thorns",
  body = "#showtooltip\n/cancelform\n/cast [nomod]Thorns;[mod:shift]Thorns(Rank 1)",
}

C["d-claw"] = {
  name = "claw",
  icon = "ability_druid_rake",
  body = "#showtooltip\n/startattack\n/cast [nomod]Claw;[mod:shift]Claw(Rank 1)",
}

C["d-cower"] = {
  name = "cower",
  icon = "ability_druid_cower",
  body = "#showtooltip\n/cast [nomod]Cower;[mod:shift]Cower(Rank 1)",
}

C["d-dmr"] = {
  name = "dmr",
  icon = "classic_ability_druid_demoralizingroar",
  body = "#showtooltip\n/cast [nomod]Demoralizing Roar;[mod:shift]Demoralizing Roar(Rank 1)",
}

C["d-pounce"] = {
  name = "pounce",
  icon = "ability_druid_supriseattack",
  body = "#showtooltip\n/cast [nomod]Pounce;[mod:shift]Pounce(Rank 1)",
}

C["d-ravage"] = {
  name = "ravage",
  icon = "ability_druid_ravage",
  body = "#showtooltip\n/cast [nomod]Ravage;[mod:shift]Ravage(Rank 1)",
}

C["d-swipe"] = {
  name = "swipe",
  icon = "inv_misc_monsterclaw_03",
  body = "#showtooltip\n/startattack\n/cast [nomod]Swipe;[mod:shift]Swipe(Rank 1)",
}

C["d-tfury"] = {
  name = "tfury",
  icon = "ability_mount_jungletiger",
  body = "#showtooltip\n/cast [nomod]Tiger's Fury;[mod:shift]Tiger's Fury(Rank 1)",
}

C["d-gotw"] = {
  name = "gotw",
  icon = "spell_nature_regeneration",
  body = "#showtooltip\n/cancelform\n/cast [nomod]Gift of the Wild;[mod:shift]Gift of the Wild(Rank 1)",
}

C["d-rgw"] = {
  name = "rgw",
  icon = "spell_nature_resistnature",
  body = "#showtooltip\n/cancelform\n/cast [mod:alt,target=player] Regrowth; [mod:shift] Regrowth(Rank 1); Regrowth",
}

C["d-tranq"] = {
  name = "tranq",
  icon = "spell_nature_tranquility",
  body = "#showtooltip\n/cancelform\n/cast [nomod]Tranquility;[mod:shift]Tranquility(Rank 1)",
}

C["ingame-other-Virene-sb"] = {
  name = "sb",
  icon = "132110",
  body = "/equip Thief's Blade\n/equiip Redbeard Crest",
}

C["ingame-other-Curents-adad"] = {
  name = "adad",
  icon = "135952",
  body = "/tar p",
}

C["ingame-other-Curents-hloe"] = {
  name = "hloe",
  icon = "134400",
  body = "/use Light of Elune\n/use Hearthstone",
}

C["ingame-other-Xavvian-asf"] = {
  name = "asf",
  icon = "134400",
  body = "/4 LF tank scholo",
}

C["ingame-other-WARRIOR-shout"] = {
  name = "shout",
  icon = "ability_warrior_battleshout",
  body = "#showtooltip Battle Shout\n/cast Battle Shout\n/startattack",
}

C["ingame-other-account-pi"] = {
  name = "pi",
  icon = "135939",
  body = "/w Stinkytoez ——————————————————\n/w Stinkytoez {star} • • Requesting Power Infusion • • {star}\n/w Stinkytoez ——————————————————\n/cast Fireball",
}

