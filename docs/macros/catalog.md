# Macro catalog

Source of truth: [catalog.json](catalog.json). WoW Macro Cursor loads that file. Groups with `gameVersion` TBC show only on Version TBC.

Scope, class, and spec live on the catalog record. Do not put `# class-specific` comments in the body.

- Macros: **391**
- Groups: **45**
- Cap: 120 account + 18 character. Body 255. Name 16.

## Groups

| Group | Version | Scope | Character | Class | Spec | Tab | Count |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [shared-core](#shared-core) | both | global | — | ALL | all | account | 4 |
| [warrior-core](#warrior-core) | both | class | — | WARRIOR | all | account | 30 |
| [warrior-arms](#warrior-arms) | both | class | — | WARRIOR | arms | character | 2 |
| [warrior-fury](#warrior-fury) | both | class | — | WARRIOR | fury | character | 2 |
| [warrior-prot](#warrior-prot) | both | class | — | WARRIOR | protection | character | 1 |
| [warrior-gear](#warrior-gear) | both | character | Tazzy | WARRIOR | all | character | 5 |
| [mage-filler](#mage-filler) | both | class | — | MAGE | all | account | 10 |
| [mage-currentz](#mage-currentz) | both | character | Currentz | MAGE | all | account | 1 |
| [mage-control](#mage-control) | both | class | — | MAGE | all | account | 13 |
| [mage-ports-alliance](#mage-ports-alliance) | both | class | — | MAGE | all | character | 3 |
| [mage-ports-horde](#mage-ports-horde) | both | class | — | MAGE | all | account | 3 |
| [paladin-ret](#paladin-ret) | both | class | — | PALADIN | retribution | character | 18 |
| [paladin-holy](#paladin-holy) | both | class | — | PALADIN | holy | character | 5 |
| [hunter-core](#hunter-core) | both | class | — | HUNTER | all | character | 16 |
| [hunter-auden](#hunter-auden) | both | character | Auden | HUNTER | beast-mastery | account | 1 |
| [rogue-combat](#rogue-combat) | both | class | — | ROGUE | combat | character | 18 |
| [priest-holy](#priest-holy) | both | class | — | PRIEST | holy | character | 17 |
| [priest-shadow](#priest-shadow) | both | class | — | PRIEST | shadow | character | 8 |
| [shaman-enhance](#shaman-enhance) | both | class | — | SHAMAN | enhancement | character | 18 |
| [warlock-core](#warlock-core) | both | class | — | WARLOCK | all | character | 17 |
| [druid-feral](#druid-feral) | both | class | — | DRUID | feral | character | 18 |
| [druid-balance](#druid-balance) | both | class | — | DRUID | balance | character | 8 |
| [shared-tbc](#shared-tbc) | TBC | global | — | ALL | all | account | 2 |
| [warrior-tbc](#warrior-tbc) | TBC | class | — | WARRIOR | all | character | 4 |
| [paladin-tbc](#paladin-tbc) | TBC | class | — | PALADIN | all | character | 7 |
| [hunter-tbc](#hunter-tbc) | TBC | class | — | HUNTER | all | character | 5 |
| [rogue-tbc](#rogue-tbc) | TBC | class | — | ROGUE | all | character | 6 |
| [priest-tbc](#priest-tbc) | TBC | class | — | PRIEST | all | character | 10 |
| [shaman-tbc](#shaman-tbc) | TBC | class | — | SHAMAN | all | character | 9 |
| [mage-tbc](#mage-tbc) | TBC | class | — | MAGE | all | character | 15 |
| [warlock-tbc](#warlock-tbc) | TBC | class | — | WARLOCK | all | character | 8 |
| [druid-tbc](#druid-tbc) | TBC | class | — | DRUID | all | character | 7 |
| [paladin-ranks](#paladin-ranks) | both | class | — | PALADIN | all | account | 12 |
| [hunter-ranks](#hunter-ranks) | both | class | — | HUNTER | all | account | 11 |
| [rogue-ranks](#rogue-ranks) | both | class | — | ROGUE | all | account | 4 |
| [priest-ranks](#priest-ranks) | both | class | — | PRIEST | all | account | 17 |
| [shaman-ranks](#shaman-ranks) | both | class | — | SHAMAN | all | account | 16 |
| [mage-ranks](#mage-ranks) | both | class | — | MAGE | all | account | 5 |
| [warlock-ranks](#warlock-ranks) | both | class | — | WARLOCK | all | account | 15 |
| [druid-ranks](#druid-ranks) | both | class | — | DRUID | all | account | 14 |
| [other-Virene](#other-Virene) | both | character | Virene | PALADIN | all | character | 1 |
| [other-Curents](#other-Curents) | both | character | Curents | ALL | all | character | 2 |
| [other-Xavvian](#other-Xavvian) | both | character | Xavvian | WARLOCK | all | character | 1 |
| [other-WARRIOR](#other-WARRIOR) | both | class | — | WARRIOR | all | account | 1 |
| [other-account](#other-account) | both | global | — | ALL | all | account | 1 |

## Records

### shared-core

General-tab utilities that need a macro: assist, focus, trinket slots, pet attack / follow, and cursor items. Put potions, the hearthstone, and racials on the bar. Class spells stay in class groups.

#### shared-t13

- name: `t13`
- scope: global
- class: ALL
- spec: all
- character: —
- tab: account
- icon: `inv_misc_orb_02`
- source: plan
- chars: 20

```
#showtooltip
/use 13
```

#### shared-t14

- name: `t14`
- scope: global
- class: ALL
- spec: all
- character: —
- tab: account
- icon: `inv_misc_orb_03`
- source: plan
- chars: 20

```
#showtooltip
/use 14
```

#### shared-pa

- name: `pa`
- scope: global
- class: ALL
- spec: all
- character: —
- tab: account
- icon: `ability_druid_bash`
- source: existing
- chars: 10
- notes: Hunter, Warlock, and any other pet class. One General-tab body.

```
/petattack
```

#### shared-pf

- name: `pf`
- scope: global
- class: ALL
- spec: all
- character: —
- tab: account
- icon: `ability_tracking`
- source: existing
- chars: 10
- notes: Shift-backtick. Split from pet attack so Shift is a bind, not a modifier.

```
/petfollow
```

### warrior-core

Useful macros for non-talent Warrior abilities. Load this complete set on the General tab; named gear swaps stay character-specific.

#### w-charge

- name: `charge`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_charge`
- source: hybrid
- chars: 167
- notes: Enters Battle for Charge or Berserker for Intercept. Do not add Rend.

```
#showtooltip [combat] Intercept; Charge
/cast [nocombat,nostance:1] Battle Stance; [combat,nostance:3] Berserker Stance
/cast [nocombat] Charge; Intercept
/startattack
```

#### w-bloodrage

- name: `brage`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_racial_bloodrage`
- source: plan
- chars: 51
- notes: Bloodrage stays separate from Berserker Rage.

```
#showtooltip Bloodrage
/cast Bloodrage
/startattack
```

#### w-br

- name: `br`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `spell_nature_ancestralguardian`
- source: hybrid
- chars: 84

```
#showtooltip Berserker Rage
/cast [nostance:3] Berserker Stance
/cast Berserker Rage
```

#### w-b

- name: `b`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_offensivestance`
- source: existing
- chars: 59

```
#showtooltip Battle Stance
/cast Battle Stance
/startattack
```

#### w-bs

- name: `bs`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_racial_avatar`
- source: existing
- chars: 65

```
#showtooltip Berserker Stance
/cast Berserker Stance
/startattack
```

#### w-d-def

- name: `d`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_defensivestance`
- source: existing
- chars: 65

```
#showtooltip Defensive Stance
/cast Defensive Stance
/startattack
```

#### w-h

- name: `h`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_rogue_ambush`
- source: existing
- chars: 59
- notes: Uses maximum rank. Rank 3 has the same listed rage cost and is not a rage-saving option.

```
#showtooltip Heroic Strike
/cast Heroic Strike
/startattack
```

#### w-c

- name: `c`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_cleave`
- source: existing
- chars: 45

```
#showtooltip Cleave
/cast Cleave
/startattack
```

#### w-ww

- name: `ww`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_whirlwind`
- source: hybrid
- chars: 87
- notes: Enters Berserker Stance. A stance change can require a second press.

```
#showtooltip Whirlwind
/cast [nostance:3] Berserker Stance
/cast Whirlwind
/startattack
```

#### w-ex

- name: `ex`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `inv_sword_48`
- source: hybrid
- chars: 78
- notes: Leaves Defensive Stance because Execute requires Battle or Berserker Stance.

```
#showtooltip Execute
/cast [stance:2] Battle Stance
/cast Execute
/startattack
```

#### w-o

- name: `o`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_meleedamage`
- source: hybrid
- chars: 84
- notes: Enters Battle Stance. A stance change can require a second press.

```
#showtooltip Overpower
/cast [nostance:1] Battle Stance
/cast Overpower
/startattack
```

#### w-rend

- name: `rend`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_gouge`
- source: hybrid
- chars: 72
- notes: Leaves Berserker Stance because Rend requires Battle or Defensive Stance.

```
#showtooltip Rend
/cast [stance:3] Battle Stance
/cast Rend
/startattack
```

#### w-s

- name: `s`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_sunder`
- source: hybrid
- chars: 90
- notes: Uses a hostile living mouseover, then the current target. Useful for multi-target tanking.

```
#showtooltip Sunder Armor
/startattack
/cast [target=mouseover,harm,nodead][] Sunder Armor
```

#### w-slam

- name: `sl`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_decisivestrike`
- source: plan
- chars: 72
- version: TBC
- notes: Trainer-taught filler. TBC uses it on the baseline bar. Leaves Defensive Stance.

```
#showtooltip Slam
/cast [stance:2] Battle Stance
/startattack
/cast Slam
```

#### w-interrupt

- name: `wkick`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `inv_gauntlets_04`
- source: plan
- chars: 207
- notes: One interrupt replaces separate Pummel and Shield Bash copies. It uses Shield Bash with a shield; otherwise it enters Berserker and uses Pummel.

```
#showtooltip [stance:3] Pummel; [equipped:Shields] Shield Bash; Pummel
/stopcasting
/startattack
/cast [noequipped:Shields,nostance:3] Berserker Stance
/cast [stance:3] Pummel; [equipped:Shields] Shield Bash
```

#### w-major-cd

- name: `major`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_challange`
- source: plan
- chars: 79
- notes: One major cooldown key. The current stance selects the spell.

```
#showtooltip
/cast [stance:1] Retaliation; [stance:2] Shield Wall; Recklessness
```

#### w-taunt

- name: `a`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `spell_nature_reincarnation`
- source: hybrid
- chars: 99
- notes: Uses a hostile living mouseover, then the current target.

```
#showtooltip Taunt
/cast [nostance:2] Defensive Stance
/cast [target=mouseover,harm,nodead][] Taunt
```

#### w-shout

- name: `bshout`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_battleshout`
- source: hybrid
- chars: 108
- notes: Battle Shout normally. Shift uses Demoralizing Shout.

```
#showtooltip [mod:shift] Demoralizing Shout; Battle Shout
/cast [mod:shift] Demoralizing Shout; Battle Shout
```

#### w-ds

- name: `ds`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_warcry`
- source: existing
- chars: 69
- notes: Dedicated Demoralizing Shout copy; `w-shout` also provides Demoralizing Shout on Shift.

```
#showtooltip Demoralizing Shout
/cast Demoralizing Shout
/startattack
```

#### w-hm

- name: `hm`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_shockwave`
- source: hybrid
- chars: 82
- notes: Leaves Defensive Stance because Hamstring requires Battle or Berserker Stance.

```
#showtooltip Hamstring
/cast [stance:2] Battle Stance
/cast Hamstring
/startattack
```

#### w-disarm

- name: `disarm`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_disarm`
- source: hybrid
- chars: 81

```
#showtooltip Disarm
/startattack
/cast [nostance:2] Defensive Stance
/cast Disarm
```

#### w-intimid

- name: `is`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_golemthunderclap`
- source: plan
- chars: 68
- notes: Stops auto-attack so the primary target is not hit immediately after the fear.

```
#showtooltip Intimidating Shout
/cast Intimidating Shout
/stopattack
```

#### w-revenge

- name: `rev`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_revenge`
- source: plan
- chars: 83

```
#showtooltip Revenge
/cast [nostance:2] Defensive Stance
/cast Revenge
/startattack
```

#### w-sblock

- name: `sbk`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_defend`
- source: plan
- chars: 80

```
#showtooltip Shield Block
/cast [nostance:2] Defensive Stance
/cast Shield Block
```

#### w-mock

- name: `mb`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_punishingblow`
- source: plan
- chars: 110
- notes: Uses a hostile living mouseover, then the current target.

```
#showtooltip Mocking Blow
/cast [nostance:1] Battle Stance
/cast [target=mouseover,harm,nodead][] Mocking Blow
```

#### w-chall

- name: `ch`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_bullrush`
- source: plan
- chars: 67

```
#showtooltip Challenging Shout
/cast Challenging Shout
/startattack
```

#### w-tc

- name: `tc`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `spell_nature_thunderclap`
- source: plan
- chars: 77

```
#showtooltip Thunder Clap
/cast [nostance:1] Battle Stance
/cast Thunder Clap
```

#### w-retal

- name: `ret`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_challange`
- source: plan
- chars: 75

```
#showtooltip Retaliation
/cast [nostance:1] Battle Stance
/cast Retaliation
```

#### w-reck

- name: `rk`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_criticalstrike`
- source: plan
- chars: 80

```
#showtooltip Recklessness
/cast [nostance:3] Berserker Stance
/cast Recklessness
```

#### w-sw

- name: `sw`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_shieldwall`
- source: hybrid
- chars: 78
- notes: Requires an equipped shield. Named equip copies stay in the gear kit.

```
#showtooltip Shield Wall
/cast [nostance:2] Defensive Stance
/cast Shield Wall
```

### warrior-arms

Only active abilities unlocked by Arms talents.

#### w-sweep

- name: `ss`
- scope: class
- class: WARRIOR
- spec: arms
- character: —
- tab: character
- icon: `ability_rogue_slicedice`
- source: plan
- chars: 85

```
#showtooltip Sweeping Strikes
/cast [nostance:1] Battle Stance
/cast Sweeping Strikes
```

#### w-ms

- name: `ms`
- scope: class
- class: WARRIOR
- spec: arms
- character: —
- tab: character
- icon: `ability_warrior_savageblow`
- source: existing
- chars: 59

```
#showtooltip Mortal Strike
/cast Mortal Strike
/startattack
```

### warrior-fury

Useful macros for Fury talent abilities. Piercing Howl needs no wrapper; drag the spell itself to an unmanaged slot.

#### w-deathwish

- name: `dwish`
- scope: class
- class: WARRIOR
- spec: fury
- character: —
- tab: character
- icon: `spell_shadow_deathpact`
- source: plan
- chars: 53

```
#showtooltip Death Wish
/cast Death Wish
/startattack
```

#### w-bt

- name: `bt`
- scope: class
- class: WARRIOR
- spec: fury
- character: —
- tab: character
- icon: `spell_nature_bloodlust`
- source: existing
- chars: 55

```
#showtooltip Bloodthirst
/cast Bloodthirst
/startattack
```

### warrior-prot

Only active abilities unlocked by Protection talents. A Fury/Protection build usually adds only Last Stand; Concussion Blow and Shield Slam require deeper Protection talents.

#### w-ls

- name: `ls`
- scope: class
- class: WARRIOR
- spec: protection
- character: —
- tab: character
- icon: `spell_holy_ashestoashes`
- source: plan
- chars: 53
- notes: Stops a cast or queued spell so the emergency defensive can fire immediately.

```
#showtooltip Last Stand
/stopcasting
/cast Last Stand
```

### warrior-gear

Character-specific Nightslayer Tazzy cooldown and equipment macros. Swap this group when the gear kit changes.

#### w-dfdw

- name: `dfdw`
- scope: character
- class: WARRIOR
- spec: fury
- character: Tazzy
- tab: character
- icon: `inv_potion_69`
- source: existing
- chars: 35
- notes: Uses Diamond Flask, then Death Wish. The flask can consume the first press; press again after the global cooldown.

```
/use Diamond Flask
/cast Death Wish
```

#### w-dual

- name: `dual`
- scope: character
- class: WARRIOR
- spec: all
- character: Tazzy
- tab: character
- icon: `inv_sword_39`
- source: existing
- chars: 65
- notes: Cancels a queued attack, then equips the dual-wield threat set.

```
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 Mirah's Song
```

#### w-sh-qs

- name: `shqs`
- scope: character
- class: WARRIOR
- spec: all
- character: Tazzy
- tab: character
- icon: `inv_shield_04`
- source: existing
- chars: 74
- notes: Cancels a queued attack, then equips the alternate shield set. The one-handed weapon goes on before the shield.

```
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 Buru's Skull Fragment
```

#### w-shh

- name: `shh`
- scope: character
- class: WARRIOR
- spec: all
- character: Tazzy
- tab: character
- icon: `inv_shield_06`
- source: existing
- chars: 73
- notes: Cancels a queued attack, then equips the mitigation shield set.

```
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 The Immovable Object
```

#### w-sd-item

- name: `sd`
- scope: character
- class: WARRIOR
- spec: all
- character: Tazzy
- tab: character
- icon: `ability_warrior_shieldwall`
- source: existing
- chars: 152
- notes: Cancels a queued attack, equips the mitigation set, enters Defensive Stance, then uses Shield Wall. Combat swaps can require repeated presses.

```
#showtooltip Shield Wall
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 The Immovable Object
/cast [nostance:2] Defensive Stance
/cast Shield Wall
```

### mage-filler

Existing Currentz fillers. /cqs and [nomod]/[mod:shift] downranks stay.

#### m-fb

- name: `f`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: account
- icon: `spell_frost_frostbolt02`
- source: existing
- chars: 115

```
#showtooltip [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)
/cqs
/cast [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)
```

#### m-fireball

- name: `fb`
- scope: class
- class: MAGE
- spec: fire
- character: —
- tab: account
- icon: `spell_fire_flamebolt`
- source: existing
- chars: 217

```
#showtooltip [mod:shift] Combustion; Fireball
/cqs
/cast [mod:shift] Combustion
/use [mod:shift] Mind Quickening Gem
/use [mod:shift] Talisman of Ephemeral Power
/use [mod:shift] Zandalarian Hero Charm
/cast Fireball;
```

#### m-blast

- name: `'`
- scope: class
- class: MAGE
- spec: fire
- character: —
- tab: account
- icon: `spell_fire_fireball`
- source: existing
- chars: 114

```
#showtooltip [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)
/cast [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)
```

#### m-ae

- name: `ae`
- scope: class
- class: MAGE
- spec: arcane
- character: —
- tab: account
- icon: `spell_nature_wispsplode`
- source: existing
- chars: 138

```
#showtooltip [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)
/cast [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)
```

#### m-am

- name: `am`
- scope: class
- class: MAGE
- spec: arcane
- character: —
- tab: account
- icon: `spell_nature_starfall`
- source: existing
- chars: 81

```
#showtooltip Arcane Missiles
/cast [nochanneling:Arcane Missiles] Arcane Missiles
```

#### m-blizz

- name: `Blizz`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: account
- icon: `spell_frost_icestorm`
- source: existing
- chars: 106

```
#showtooltip [nomod]Blizzard;[mod:shift]Blizzard(rank 1)
/cast [nomod]Blizzard;[mod:shift]Blizzard(rank 1)
```

#### m-cone

- name: `cone`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: account
- icon: `spell_frost_glacier`
- source: existing
- chars: 122

```
#showtooltip [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)
/cast [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)
```

#### m-fs

- name: `fs`
- scope: class
- class: MAGE
- spec: fire
- character: —
- tab: account
- icon: `spell_fire_selfdestruct`
- source: existing
- chars: 254

```
#showtooltip [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike
/use [mod:alt] Talisman of Ephemeral Power
/use [mod:alt] Zandalarian Hero Charm
/cast [mod:alt] Arcane Power
/cast [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike
```

#### m-scorch

- name: `sc`
- scope: class
- class: MAGE
- spec: fire
- character: —
- tab: account
- icon: `spell_fire_soulburn`
- source: plan
- chars: 32

```
#showtooltip Scorch
/cast Scorch
```

#### m-pyro

- name: `py`
- scope: class
- class: MAGE
- spec: fire
- character: —
- tab: account
- icon: `spell_fire_fireball02`
- source: plan
- chars: 61

```
#showtooltip Pyroblast
/cast Presence of Mind
/cast Pyroblast
```

### mage-currentz

Character-specific Currentz. Touch of Chaos wand and named Naxx shells. Generic Shoot stays in mage-filler.

#### m-wand

- name: `shadow`
- scope: character
- class: MAGE
- spec: all
- character: Currentz
- tab: account
- icon: `spell_shadow_shadowbolt`
- source: existing
- chars: 46

```
#showtooltip
/equip Touch of Chaos
/cast shoot
```

### mage-control

Kicks, sheep, block, decurse. Existing bodies win.

#### m-cs

- name: `CS`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_frost_iceshock`
- source: existing
- chars: 90
- notes: Mouseover stays commented, as on disk.

```
#showtooltip
/stopcasting
#/cast [target=mouseover,exists] Counterspell
/cast Counterspell
```

#### m-cs-focus

- name: `CSf`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_frost_iceshock`
- source: plan
- chars: 98

```
#showtooltip Counterspell
/stopcasting
/cast [target=focus,harm,nodead] Counterspell; Counterspell
```

#### m-sheep

- name: `sheep`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_nature_polymorph`
- source: existing
- chars: 110

```
#showtooltip [nomod]Polymorph;[mod:shift]Polymorph(rank 1)
/cast [nomod]Polymorph;[mod:shift]Polymorph(rank 1)
```

#### m-decurse

- name: `decurse`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_nature_removecurse`
- source: existing
- chars: 110

```
#showtooltip Remove Lesser Curse
/cast [target=mouseover,exists] Remove Lesser Curse
/cast Remove Lesser Curse
```

#### m-ib

- name: `ib`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: account
- icon: `spell_frost_frost`
- source: existing
- chars: 73

```
#showtooltip Ice block
/stopcasting
/cast Ice block
/cancelaura Ice block
```

#### m-ms

- name: `MS`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_detectlesserinvisibility`
- source: existing
- chars: 43

```
#showtooltip
/stopcasting
/cast mana shield
```

#### m-nova

- name: `fn`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: account
- icon: `spell_frost_frostnova`
- source: plan
- chars: 104

```
#showtooltip [mod:shift] Frost Nova; Frost Nova(rank 1)
/cast [mod:shift] Frost Nova; Frost Nova(rank 1)
```

#### m-barrier

- name: `iba`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: account
- icon: `spell_ice_lament`
- source: plan
- chars: 42

```
#showtooltip Ice Barrier
/cast Ice Barrier
```

#### m-ward

- name: `ward`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_frost_frostward`
- source: plan
- chars: 86

```
#showtooltip [mod:shift] Fire Ward; Frost Ward
/cast [mod:shift] Fire Ward; Frost Ward
```

#### m-slowfall

- name: `slowfall`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_magic_featherfall`
- source: plan
- chars: 38

```
#showtooltip Slow Fall
/cast Slow Fall
```

#### m-dampen

- name: `dm`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_nature_abolishmagic`
- source: plan
- chars: 98

```
#showtooltip [mod:shift] Amplify Magic; Dampen Magic
/cast [mod:shift] Amplify Magic; Dampen Magic
```

#### m-csnap

- name: `snap`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: account
- icon: `spell_frost_wizardmark`
- source: plan
- chars: 38

```
#showtooltip Cold Snap
/cast Cold Snap
```

#### m-nef

- name: `nef`
- scope: class
- class: MAGE
- spec: fire
- character: —
- tab: account
- icon: `spell_holy_excorcism_02`
- source: existing
- chars: 53

```
/use [@cursor] Stratholme Holy Water
/cast Blast Wave
```

### mage-ports-alliance

Existing Currentz IF/SW plus Darnassus from the plan. Shift = portal.

#### m-sw

- name: `portsw`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_teleportstormwind`
- source: existing
- chars: 136

```
#showtooltip [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind
/cast [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind
```

#### m-if

- name: `if`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_teleportironforge`
- source: existing
- chars: 136

```
#showtooltip [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge
/cast [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge
```

#### m-dar

- name: `dar`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_teleportdarnassus`
- source: plan
- chars: 136

```
#showtooltip [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus
/cast [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus
```

### mage-ports-horde

Existing WARKEYS Orgrimmar / Undercity / Thunder Bluff.

#### m-org

- name: `org`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_arcane_teleportorgrimmar`
- source: existing
- chars: 136

```
#showtooltip [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar
/cast [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar
```

#### m-uc

- name: `uc`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_arcane_teleportundercity`
- source: existing
- chars: 136

```
#showtooltip [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity
/cast [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity
```

#### m-tb

- name: `tb`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_arcane_teleportthunderbluff`
- source: existing
- chars: 152

```
#showtooltip [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff
/cast [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff
```

### paladin-ret

Alliance Era ret. Seal + judge + stun + consecrate.

#### p-judge

- name: `judge`
- scope: class
- class: PALADIN
- spec: retribution
- character: —
- tab: character
- icon: `spell_holy_righteousfury`
- source: plan
- chars: 51

```
#showtooltip Judgement
/startattack
/cast Judgement
```

#### p-seal

- name: `seal`
- scope: class
- class: PALADIN
- spec: retribution
- character: —
- tab: character
- icon: `ability_thunderbolt`
- source: plan
- chars: 69

```
#showtooltip
/cast [mod:shift] Seal of Command; Seal of Righteousness
```

#### p-hoj

- name: `hoj`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_sealofmight`
- source: plan
- chars: 67

```
#showtooltip Hammer of Justice
/stopcasting
/cast Hammer of Justice
```

#### p-cons

- name: `cons`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_innerfire`
- source: plan
- chars: 65

```
#showtooltip
/cast [mod:shift] Consecration(Rank 1); Consecration
```

#### p-how

- name: `how`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `ability_thunderclap`
- source: plan
- chars: 50

```
#showtooltip Hammer of Wrath
/cast Hammer of Wrath
```

#### p-exo

- name: `exo`
- scope: class
- class: PALADIN
- spec: retribution
- character: —
- tab: character
- icon: `spell_holy_excorcism_02`
- source: plan
- chars: 36

```
#showtooltip Exorcism
/cast Exorcism
```

#### p-rep

- name: `rep`
- scope: class
- class: PALADIN
- spec: retribution
- character: —
- tab: character
- icon: `spell_holy_prayerofhealing`
- source: plan
- chars: 53

```
#showtooltip Repentance
/stopcasting
/cast Repentance
```

#### p-bubble

- name: `bubble`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_divineintervention`
- source: plan
- chars: 46

```
#showtooltip Divine Shield
/cast Divine Shield
```

#### p-cancel-ds

- name: `cds`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_divineintervention`
- source: plan
- chars: 25

```
/cancelaura Divine Shield
```

#### p-bop

- name: `bop`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_sealofprotection`
- source: plan
- chars: 64

```
#showtooltip Blessing of Protection
/cast Blessing of Protection
```

#### p-cleanse

- name: `cl`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_purify`
- source: hybrid
- chars: 102

```
#showtooltip Cleanse
/cast [mod:alt,target=player] Cleanse; [target=mouseover,exists] Cleanse; Cleanse
```

#### p-fol

- name: `fol`
- scope: class
- class: PALADIN
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_flashheal`
- source: plan
- chars: 144

```
#showtooltip
/cast [mod:alt,target=player] Flash of Light; [mod:shift] Flash of Light(Rank 4); [mod:ctrl] Flash of Light(Rank 1); Flash of Light
```

#### p-might

- name: `bom`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_fistofjustice`
- source: plan
- chars: 102

```
#showtooltip
/cast [mod:shift] Blessing of Salvation; [mod:ctrl] Blessing of Wisdom; Blessing of Might
```

#### p-aura

- name: `aura`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_devotionaura`
- source: plan
- chars: 93

```
#showtooltip
/cast [mod:shift] Devotion Aura; [mod:ctrl] Retribution Aura; Concentration Aura
```

#### p-rf

- name: `rf`
- scope: class
- class: PALADIN
- spec: protection
- character: —
- tab: character
- icon: `spell_holy_sealoffury`
- source: plan
- chars: 48

```
#showtooltip Righteous Fury
/cast Righteous Fury
```

#### p-hs

- name: `hsh`
- scope: class
- class: PALADIN
- spec: protection
- character: —
- tab: character
- icon: `spell_holy_blessingofprotection`
- source: plan
- chars: 42

```
#showtooltip Holy Shield
/cast Holy Shield
```

#### p-loh

- name: `loh`
- scope: class
- class: PALADIN
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_layonhands`
- source: plan
- chars: 69

```
#showtooltip Lay on Hands
/raid Lay on Hands on %t
/cast Lay on Hands
```

#### p-di

- name: `di`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_timestop`
- source: plan
- chars: 73

```
#showtooltip Divine Intervention
/raid DI on %t
/cast Divine Intervention
```

### paladin-holy

Heals. Alt self. Shift cheap rank.

#### p-hl

- name: `hl`
- scope: class
- class: PALADIN
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_holybolt`
- source: plan
- chars: 97

```
#showtooltip
/cast [mod:alt,target=player] Holy Light; [mod:shift] Holy Light(Rank 1); Holy Light
```

#### p-df

- name: `df`
- scope: class
- class: PALADIN
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_flashheal`
- source: plan
- chars: 67

```
#showtooltip Flash of Light
/cast Divine Favor
/cast Flash of Light
```

#### p-shock

- name: `hsk`
- scope: class
- class: PALADIN
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_searinglight`
- source: plan
- chars: 40

```
#showtooltip Holy Shock
/cast Holy Shock
```

#### p-seal-h

- name: `sealh`
- scope: class
- class: PALADIN
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_righteousnessaura`
- source: plan
- chars: 60

```
#showtooltip
/cast [mod:shift] Seal of Light; Seal of Wisdom
```

#### p-mount

- name: `chg`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_swiftness`
- source: plan
- chars: 62

```
#showtooltip
/cast [mod:shift] Summon Warhorse; Summon Charger
```

### hunter-core

Mark, shots, Feign Death, pet. 18 or fewer.

#### h-mark

- name: `hmark`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_hunter_snipershot`
- source: plan
- chars: 46

```
#showtooltip Hunter's Mark
/cast Hunter's Mark
```

#### h-aspect

- name: `asp`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `spell_nature_ravenform`
- source: plan
- chars: 71

```
#showtooltip
/cast [mod:shift] Aspect of the Monkey; Aspect of the Hawk
```

#### h-aimed

- name: `as`
- scope: class
- class: HUNTER
- spec: marksmanship
- character: —
- tab: character
- icon: `inv_spear_07`
- source: plan
- chars: 40

```
#showtooltip Aimed Shot
/cast Aimed Shot
```

#### h-multi

- name: `multi`
- scope: class
- class: HUNTER
- spec: marksmanship
- character: —
- tab: character
- icon: `ability_upgrademoonglaive`
- source: plan
- chars: 40

```
#showtooltip Multi-Shot
/cast Multi-Shot
```

#### h-arcane

- name: `arc`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_impalingbolt`
- source: plan
- chars: 63

```
#showtooltip
/cast [mod:shift] Arcane Shot(Rank 1); Arcane Shot
```

#### h-sting

- name: `sting`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_hunter_quickshot`
- source: plan
- chars: 46

```
#showtooltip Serpent Sting
/cast Serpent Sting
```

#### h-conc

- name: `conc`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `spell_frost_stun`
- source: plan
- chars: 50

```
#showtooltip Concussive Shot
/cast Concussive Shot
```

#### h-clip

- name: `wc`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_rogue_trip`
- source: plan
- chars: 59

```
#showtooltip
/cast [mod:shift] Wing Clip(Rank 1); Wing Clip
```

#### h-fd

- name: `fd`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_rogue_feigndeath`
- source: plan
- chars: 67

```
#showtooltip Feign Death
/stopattack
/stopcasting
/cast Feign Death
```

#### h-trap

- name: `ft`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `spell_frost_chainsofice`
- source: plan
- chars: 46

```
#showtooltip Freezing Trap
/cast Freezing Trap
```

#### h-rapid

- name: `rapid`
- scope: class
- class: HUNTER
- spec: marksmanship
- character: —
- tab: character
- icon: `ability_hunter_runningshot`
- source: plan
- chars: 48

```
#showtooltip Rapid Fire
/use 13
/cast Rapid Fire
```

#### h-tranq

- name: `tq`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `spell_nature_drowsy`
- source: plan
- chars: 56

```
#showtooltip Tranquilizing Shot
/cast Tranquilizing Shot
```

#### h-mend

- name: `mp`
- scope: class
- class: HUNTER
- spec: beast-mastery
- character: —
- tab: character
- icon: `ability_hunter_mendpet`
- source: plan
- chars: 36

```
#showtooltip Mend Pet
/cast Mend Pet
```

#### h-call

- name: `pet`
- scope: class
- class: HUNTER
- spec: beast-mastery
- character: —
- tab: character
- icon: `ability_hunter_beastcall`
- source: plan
- chars: 36

```
#showtooltip Call Pet
/cast Call Pet
```

#### h-bw

- name: `bw`
- scope: class
- class: HUNTER
- spec: beast-mastery
- character: —
- tab: character
- icon: `ability_druid_ferociousbite`
- source: plan
- chars: 46

```
#showtooltip Bestial Wrath
/cast Bestial Wrath
```

#### h-cheetah

- name: `cheetah`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_mount_jungletiger`
- source: plan
- chars: 62

```
#showtooltip Aspect of the Cheetah
/cast Aspect of the Cheetah
```

### hunter-auden

Character-specific Auden. Worg Carrier from the 372399535 account.

#### h-worg

- name: `worg`
- scope: character
- class: HUNTER
- spec: beast-mastery
- character: Auden
- tab: account
- icon: `ability_hunter_beastcall`
- source: existing
- chars: 45

```
#showtooltip
/cast Call Pet
/use Worg Carrier
```

### rogue-combat

Openers, Kick, finishers. /startattack on builders.

#### r-stealth

- name: `st`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `ability_stealth`
- source: plan
- chars: 34

```
#showtooltip Stealth
/cast Stealth
```

#### r-ss

- name: `sinister`
- scope: class
- class: ROGUE
- spec: combat
- character: —
- tab: character
- icon: `spell_shadow_ritualofsacrifice`
- source: plan
- chars: 63

```
#showtooltip Sinister Strike
/startattack
/cast Sinister Strike
```

#### r-kick

- name: `kick`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `ability_kick`
- source: plan
- chars: 41

```
#showtooltip Kick
/stopcasting
/cast Kick
```

#### r-evis

- name: `ev`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `ability_rogue_eviscerate`
- source: plan
- chars: 40

```
#showtooltip Eviscerate
/cast Eviscerate
```

#### r-snd

- name: `snd`
- scope: class
- class: ROGUE
- spec: combat
- character: —
- tab: character
- icon: `ability_rogue_slicedice`
- source: plan
- chars: 48

```
#showtooltip Slice and Dice
/cast Slice and Dice
```

#### r-rup

- name: `rup`
- scope: class
- class: ROGUE
- spec: assassination
- character: —
- tab: character
- icon: `ability_rogue_rupture`
- source: plan
- chars: 34

```
#showtooltip Rupture
/cast Rupture
```

#### r-ks

- name: `ks`
- scope: class
- class: ROGUE
- spec: assassination
- character: —
- tab: character
- icon: `ability_rogue_kidneyshot`
- source: plan
- chars: 42

```
#showtooltip Kidney Shot
/cast Kidney Shot
```

#### r-gouge

- name: `g`
- scope: class
- class: ROGUE
- spec: combat
- character: —
- tab: character
- icon: `ability_gouge`
- source: plan
- chars: 42

```
#showtooltip Gouge
/stopattack
/cast Gouge
```

#### r-cheap

- name: `cheap`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `ability_cheapshot`
- source: plan
- chars: 66

```
#showtooltip Cheap Shot
/cast [nostealth] Stealth
/cast Cheap Shot
```

#### r-ambush

- name: `ambush`
- scope: class
- class: ROGUE
- spec: assassination
- character: —
- tab: character
- icon: `ability_rogue_ambush`
- source: plan
- chars: 58

```
#showtooltip Ambush
/cast [nostealth] Stealth
/cast Ambush
```

#### r-bf

- name: `bf`
- scope: class
- class: ROGUE
- spec: combat
- character: —
- tab: character
- icon: `ability_warrior_punishingblow`
- source: plan
- chars: 52

```
#showtooltip Blade Flurry
/use 13
/cast Blade Flurry
```

#### r-ar

- name: `ar`
- scope: class
- class: ROGUE
- spec: combat
- character: —
- tab: character
- icon: `spell_shadow_shadowworddominate`
- source: plan
- chars: 50

```
#showtooltip Adrenaline Rush
/cast Adrenaline Rush
```

#### r-eva

- name: `eva`
- scope: class
- class: ROGUE
- spec: combat
- character: —
- tab: character
- icon: `spell_shadow_shadowward`
- source: plan
- chars: 34

```
#showtooltip Evasion
/cast Evasion
```

#### r-vanish

- name: `van`
- scope: class
- class: ROGUE
- spec: subtlety
- character: —
- tab: character
- icon: `ability_vanish`
- source: plan
- chars: 44

```
#showtooltip Vanish
/stopattack
/cast Vanish
```

#### r-sprint

- name: `sp`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `ability_rogue_sprint`
- source: plan
- chars: 32

```
#showtooltip Sprint
/cast Sprint
```

#### r-blind

- name: `blind`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_mindsteal`
- source: plan
- chars: 30

```
#showtooltip Blind
/cast Blind
```

#### r-sap

- name: `sap`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `ability_sap`
- source: plan
- chars: 73

```
#showtooltip
/cast [nostealth] Stealth
/cast [mod:shift] Sap; Pick Pocket
```

#### r-cb

- name: `coldb`
- scope: class
- class: ROGUE
- spec: assassination
- character: —
- tab: character
- icon: `spell_ice_lament`
- source: plan
- chars: 57

```
#showtooltip Eviscerate
/cast Cold Blood
/cast Eviscerate
```

### priest-holy

Alt self. Shift cheap rank. Ctrl Rank 1. Mouseover on dispel.

#### pr-fh

- name: `fh`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_flashheal`
- source: plan
- chars: 128

```
#showtooltip
/cast [mod:alt,target=player] Flash Heal; [mod:shift] Flash Heal(Rank 4); [mod:ctrl] Flash Heal(Rank 1); Flash Heal
```

#### pr-gh

- name: `gh`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_greaterheal`
- source: plan
- chars: 103

```
#showtooltip
/cast [mod:alt,target=player] Greater Heal; [mod:shift] Greater Heal(Rank 1); Greater Heal
```

#### pr-renew

- name: `rn`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_renew`
- source: plan
- chars: 82

```
#showtooltip
/cast [mod:alt,target=player] Renew; [mod:shift] Renew(Rank 3); Renew
```

#### pr-pws

- name: `pws`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_powerwordshield`
- source: plan
- chars: 121

```
#showtooltip
/cast [mod:alt,target=player] Power Word: Shield; [mod:shift] Power Word: Shield(Rank 1); Power Word: Shield
```

#### pr-poh

- name: `poh`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_prayerofhealing02`
- source: plan
- chars: 72

```
#showtooltip Prayer of Healing
/cast Inner Focus
/cast Prayer of Healing
```

#### pr-dispel

- name: `disp`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_dispelmagic`
- source: hybrid
- chars: 122

```
#showtooltip Dispel Magic
/cast [mod:alt,target=player] Dispel Magic; [target=mouseover,exists] Dispel Magic; Dispel Magic
```

#### pr-fade

- name: `fade`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: character
- icon: `spell_magic_lesserinvisibilty`
- source: plan
- chars: 28

```
#showtooltip Fade
/cast Fade
```

#### pr-scream

- name: `ps`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_shadow_psychicscream`
- source: plan
- chars: 48

```
#showtooltip Psychic Scream
/cast Psychic Scream
```

#### pr-fw

- name: `fw`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_excorcism`
- source: plan
- chars: 95

```
#showtooltip Fear Ward
/raid Fear Ward on %t
/cast [mod:alt,target=player] Fear Ward; Fear Ward
```

#### pr-fort

- name: `fort`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_wordfortitude`
- source: plan
- chars: 109

```
#showtooltip Power Word: Fortitude
/cast [mod:alt,target=player] Power Word: Fortitude; Power Word: Fortitude
```

#### pr-rez

- name: `rez`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_resurrection`
- source: plan
- chars: 44

```
#showtooltip Resurrection
/cast Resurrection
```

#### pr-if

- name: `ifr`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_innerfire`
- source: plan
- chars: 40

```
#showtooltip Inner Fire
/cast Inner Fire
```

#### pr-nova

- name: `hn`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_holynova`
- source: plan
- chars: 59

```
#showtooltip
/cast [mod:shift] Holy Nova(Rank 1); Holy Nova
```

#### pr-wand

- name: `wand`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: character
- icon: `ability_shootwand`
- source: plan
- chars: 30

```
#showtooltip Shoot
/cast Shoot
```

#### pr-abolish

- name: `ad`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_nature_nullifydisease`
- source: hybrid
- chars: 134

```
#showtooltip Abolish Disease
/cast [mod:alt,target=player] Abolish Disease; [target=mouseover,exists] Abolish Disease; Abolish Disease
```

#### pr-pof

- name: `pof`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_prayeroffortitude`
- source: plan
- chars: 58

```
#showtooltip Prayer of Fortitude
/cast Prayer of Fortitude
```

#### pr-spirit

- name: `pos`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_prayerofspirit`
- source: plan
- chars: 52

```
#showtooltip Prayer of Spirit
/cast Prayer of Spirit
```

### priest-shadow

Dots and form. Cancel form to heal.

#### pr-swp

- name: `swp`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_shadow_shadowwordpain`
- source: plan
- chars: 75

```
#showtooltip
/cast [mod:shift] Shadow Word: Pain(Rank 1); Shadow Word: Pain
```

#### pr-mf

- name: `mf`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_shadow_siphonmana`
- source: plan
- chars: 38

```
#showtooltip Mind Flay
/cast Mind Flay
```

#### pr-mb

- name: `mblast`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_shadow_unholyfrenzy`
- source: plan
- chars: 40

```
#showtooltip Mind Blast
/cast Mind Blast
```

#### pr-ve

- name: `ve`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_shadow_unsummonbuilding`
- source: plan
- chars: 52

```
#showtooltip Vampiric Embrace
/cast Vampiric Embrace
```

#### pr-sf

- name: `sf`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_shadow_shadowform`
- source: plan
- chars: 40

```
#showtooltip Shadowform
/cast Shadowform
```

#### pr-silence

- name: `sil`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_shadow_impphaseshift`
- source: plan
- chars: 47

```
#showtooltip Silence
/stopcasting
/cast Silence
```

#### pr-shackle

- name: `shk`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_nature_slow`
- source: plan
- chars: 61

```
#showtooltip Shackle Undead
/stopcasting
/cast Shackle Undead
```

#### pr-healform

- name: `hf`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_holy_flashheal`
- source: plan
- chars: 99

```
#showtooltip Flash Heal
/cancelaura Shadowform
/cast [mod:alt,target=player] Flash Heal; Flash Heal
```

### shaman-enhance

Horde Era. Shock interrupt uses /stopcasting and Rank 1 on Shift.

#### s-es

- name: `es`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_earthshock`
- source: plan
- chars: 88

```
#showtooltip Earth Shock
/stopcasting
/cast [mod:shift] Earth Shock(Rank 1); Earth Shock
```

#### s-shock

- name: `fl`
- scope: class
- class: SHAMAN
- spec: enhancement
- character: —
- tab: character
- icon: `spell_fire_flameshock`
- source: plan
- chars: 55

```
#showtooltip
/cast [mod:shift] Frost Shock; Flame Shock
```

#### s-ss

- name: `storm`
- scope: class
- class: SHAMAN
- spec: enhancement
- character: —
- tab: character
- icon: `ability_shaman_stormstrike`
- source: plan
- chars: 55

```
#showtooltip Stormstrike
/startattack
/cast Stormstrike
```

#### s-lb

- name: `lb`
- scope: class
- class: SHAMAN
- spec: elemental
- character: —
- tab: character
- icon: `spell_nature_lightning`
- source: plan
- chars: 69

```
#showtooltip
/cast [mod:shift] Lightning Bolt(Rank 1); Lightning Bolt
```

#### s-cl

- name: `chain`
- scope: class
- class: SHAMAN
- spec: elemental
- character: —
- tab: character
- icon: `spell_nature_chainlightning`
- source: plan
- chars: 50

```
#showtooltip Chain Lightning
/cast Chain Lightning
```

#### s-ls

- name: `lshield`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_lightningshield`
- source: plan
- chars: 52

```
#showtooltip Lightning Shield
/cast Lightning Shield
```

#### s-wf

- name: `wf`
- scope: class
- class: SHAMAN
- spec: enhancement
- character: —
- tab: character
- icon: `spell_nature_cyclone`
- source: plan
- chars: 66

```
#showtooltip
/cast [mod:shift] Flametongue Weapon; Windfury Weapon
```

#### s-lhw

- name: `lhw`
- scope: class
- class: SHAMAN
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_healingway`
- source: plan
- chars: 164

```
#showtooltip
/cast [mod:alt,target=player] Lesser Healing Wave; [mod:shift] Lesser Healing Wave(Rank 4); [mod:ctrl] Lesser Healing Wave(Rank 1); Lesser Healing Wave
```

#### s-hw

- name: `hw`
- scope: class
- class: SHAMAN
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_magicimmunity`
- source: plan
- chars: 103

```
#showtooltip
/cast [mod:alt,target=player] Healing Wave; [mod:shift] Healing Wave(Rank 1); Healing Wave
```

#### s-ns

- name: `ns`
- scope: class
- class: SHAMAN
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_ravenform`
- source: plan
- chars: 69

```
#showtooltip Healing Wave
/cast Nature's Swiftness
/cast Healing Wave
```

#### s-purge

- name: `pg`
- scope: class
- class: SHAMAN
- spec: elemental
- character: —
- tab: character
- icon: `spell_nature_purge`
- source: hybrid
- chars: 63

```
#showtooltip Purge
/cast [target=mouseover,exists] Purge; Purge
```

#### s-wolf

- name: `gw`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_spiritwolf`
- source: plan
- chars: 40

```
#showtooltip Ghost Wolf
/cast Ghost Wolf
```

#### s-ground

- name: `gt`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_groundingtotem`
- source: plan
- chars: 62

```
#showtooltip
/cast [mod:shift] Grounding Totem; Windfury Totem
```

#### s-tremor

- name: `tt`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_tremortotem`
- source: plan
- chars: 44

```
#showtooltip Tremor Totem
/cast Tremor Totem
```

#### s-mana

- name: `mst`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_manaregentotem`
- source: plan
- chars: 54

```
#showtooltip Mana Spring Totem
/cast Mana Spring Totem
```

#### s-str

- name: `str`
- scope: class
- class: SHAMAN
- spec: enhancement
- character: —
- tab: character
- icon: `spell_nature_earthbindtotem`
- source: plan
- chars: 66

```
#showtooltip Strength of Earth Totem
/cast Strength of Earth Totem
```

#### s-tide

- name: `mt`
- scope: class
- class: SHAMAN
- spec: restoration
- character: —
- tab: character
- icon: `spell_frost_summonwaterelemental`
- source: plan
- chars: 50

```
#showtooltip Mana Tide Totem
/cast Mana Tide Totem
```

#### s-cure

- name: `cure`
- scope: class
- class: SHAMAN
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_nullifypoison`
- source: hybrid
- chars: 118

```
#showtooltip Cure Poison
/cast [mod:alt,target=player] Cure Poison; [target=mouseover,exists] Cure Poison; Cure Poison
```

### warlock-core

Life Tap, bolts, curses, Spell Lock, summon announce (existing `sum`).

#### l-tap

- name: `lt`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_burningspirit`
- source: plan
- chars: 57

```
#showtooltip
/cast [mod:shift] Life Tap(Rank 1); Life Tap
```

#### l-sb

- name: `sbolt`
- scope: class
- class: WARLOCK
- spec: destruction
- character: —
- tab: character
- icon: `spell_shadow_shadowbolt`
- source: plan
- chars: 63

```
#showtooltip
/cast [mod:shift] Shadow Bolt(Rank 1); Shadow Bolt
```

#### l-imm

- name: `imm`
- scope: class
- class: WARLOCK
- spec: destruction
- character: —
- tab: character
- icon: `spell_fire_immolation`
- source: plan
- chars: 36

```
#showtooltip Immolate
/cast Immolate
```

#### l-corr

- name: `corr`
- scope: class
- class: WARLOCK
- spec: affliction
- character: —
- tab: character
- icon: `spell_shadow_abominationexplosion`
- source: plan
- chars: 61

```
#showtooltip
/cast [mod:shift] Corruption(Rank 1); Corruption
```

#### l-coa

- name: `coa`
- scope: class
- class: WARLOCK
- spec: affliction
- character: —
- tab: character
- icon: `spell_shadow_curseofsargeras`
- source: plan
- chars: 68

```
#showtooltip
/cast [mod:shift] Curse of Agony; Curse of the Elements
```

#### l-fear

- name: `fear`
- scope: class
- class: WARLOCK
- spec: affliction
- character: —
- tab: character
- icon: `spell_shadow_possession`
- source: plan
- chars: 62

```
#showtooltip
/stopcasting
/cast [mod:shift] Fear(Rank 1); Fear
```

#### l-lock

- name: `lock`
- scope: class
- class: WARLOCK
- spec: demonology
- character: —
- tab: character
- icon: `spell_shadow_mindrot`
- source: plan
- chars: 53

```
#showtooltip Spell Lock
/stopcasting
/cast Spell Lock
```

#### l-sum

- name: `sum`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_twilight`
- source: existing
- chars: 67

```
/ra Summoning %t
/rw Summoning %t, click!
/cast Ritual of Summoning
```

#### l-ss

- name: `soulstone`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: character
- icon: `inv_misc_orb_04`
- source: plan
- chars: 71

```
#showtooltip Major Soulstone
/raid Soulstone on %t
/use Major Soulstone
```

#### l-sac

- name: `sac`
- scope: class
- class: WARLOCK
- spec: demonology
- character: —
- tab: character
- icon: `spell_shadow_sacrificialshield`
- source: plan
- chars: 38

```
#showtooltip Sacrifice
/cast Sacrifice
```

#### l-banish

- name: `ban`
- scope: class
- class: WARLOCK
- spec: demonology
- character: —
- tab: character
- icon: `spell_shadow_cripple`
- source: plan
- chars: 45

```
#showtooltip Banish
/stopcasting
/cast Banish
```

#### l-coil

- name: `dc`
- scope: class
- class: WARLOCK
- spec: affliction
- character: —
- tab: character
- icon: `spell_shadow_deathcoil`
- source: plan
- chars: 40

```
#showtooltip Death Coil
/cast Death Coil
```

#### l-fel

- name: `fel`
- scope: class
- class: WARLOCK
- spec: demonology
- character: —
- tab: character
- icon: `spell_shadow_summonfelhunter`
- source: plan
- chars: 64

```
#showtooltip
/cast [mod:shift] Summon Succubus; Summon Felhunter
```

#### l-armor

- name: `da`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_ragingscream`
- source: plan
- chars: 42

```
#showtooltip Demon Armor
/cast Demon Armor
```

#### l-drain

- name: `drain`
- scope: class
- class: WARLOCK
- spec: affliction
- character: —
- tab: character
- icon: `spell_shadow_haunting`
- source: plan
- chars: 61

```
#showtooltip
/cast [mod:shift] Drain Soul(Rank 1); Drain Soul
```

#### l-shadowburn

- name: `sbn`
- scope: class
- class: WARLOCK
- spec: destruction
- character: —
- tab: character
- icon: `spell_shadow_scourgebuild`
- source: plan
- chars: 40

```
#showtooltip Shadowburn
/cast Shadowburn
```

#### l-wand

- name: `lwand`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: character
- icon: `ability_shootwand`
- source: plan
- chars: 30

```
#showtooltip Shoot
/cast Shoot
```

### druid-feral

Cat/bear. /cancelform before heals. Form numbers: 1 bear, 3 cat.

#### d-shred

- name: `shred`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `spell_shadow_vampiricaura`
- source: plan
- chars: 43

```
#showtooltip Shred
/startattack
/cast Shred
```

#### d-fb

- name: `fbite`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_ferociousbite`
- source: plan
- chars: 69

```
#showtooltip
/cast [mod:shift] Ferocious Bite(Rank 1); Ferocious Bite
```

#### d-rip

- name: `rip`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_ghoulfrenzy`
- source: plan
- chars: 26

```
#showtooltip Rip
/cast Rip
```

#### d-rake

- name: `rake`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_disembowel`
- source: plan
- chars: 41

```
#showtooltip Rake
/startattack
/cast Rake
```

#### d-prowl

- name: `pr`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_prowl`
- source: plan
- chars: 56

```
#showtooltip Prowl
/cast [noform:3] Cat Form
/cast Prowl
```

#### d-maul

- name: `ml`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_maul`
- source: plan
- chars: 41

```
#showtooltip Maul
/startattack
/cast Maul
```

#### d-growl

- name: `gr`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_physical_taunt`
- source: plan
- chars: 62

```
#showtooltip Growl
/cast [noform:1] Dire Bear Form
/cast Growl
```

#### d-bash

- name: `bash`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_bash`
- source: plan
- chars: 41

```
#showtooltip Bash
/stopcasting
/cast Bash
```

#### d-ff

- name: `ff`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: character
- icon: `spell_nature_faeriefire`
- source: plan
- chars: 62

```
#showtooltip
/cast [form:1/3] Faerie Fire (Feral); Faerie Fire
```

#### d-charge

- name: `fc`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_hunter_pet_bear`
- source: plan
- chars: 44

```
#showtooltip Feral Charge
/cast Feral Charge
```

#### d-fr

- name: `fr`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_bullrush`
- source: plan
- chars: 62

```
#showtooltip Frenzied Regeneration
/cast Frenzied Regeneration
```

#### d-dash

- name: `dash`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_dash`
- source: plan
- chars: 28

```
#showtooltip Dash
/cast Dash
```

#### d-cat

- name: `cat`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_catform`
- source: plan
- chars: 52

```
#showtooltip
/cast [mod:shift] Travel Form; Cat Form
```

#### d-bear

- name: `bear`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_racial_bearform`
- source: plan
- chars: 48

```
#showtooltip Dire Bear Form
/cast Dire Bear Form
```

#### d-ht

- name: `ht`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_healingtouch`
- source: plan
- chars: 152

```
#showtooltip
/cancelform
/cast [mod:alt,target=player] Healing Touch; [mod:shift] Healing Touch(Rank 4); [mod:ctrl] Healing Touch(Rank 1); Healing Touch
```

#### d-inn

- name: `inn`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_lightning`
- source: plan
- chars: 107

```
#showtooltip Innervate
/cancelform
/raid Innervate on %t
/cast [mod:alt,target=player] Innervate; Innervate
```

#### d-reb

- name: `reb`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_reincarnation`
- source: plan
- chars: 78

```
#showtooltip Rebirth
/cancelform
/raid {rt8} Rebirth on %t {rt8}
/cast Rebirth
```

#### d-motw

- name: `motw`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_regeneration`
- source: plan
- chars: 106

```
#showtooltip Mark of the Wild
/cancelform
/cast [mod:alt,target=player] Mark of the Wild; Mark of the Wild
```

### druid-balance

Moonkin and healer extras.

#### d-mf

- name: `mfire`
- scope: class
- class: DRUID
- spec: balance
- character: —
- tab: character
- icon: `spell_nature_starfall`
- source: plan
- chars: 57

```
#showtooltip
/cast [mod:shift] Moonfire(Rank 1); Moonfire
```

#### d-wrath

- name: `wr`
- scope: class
- class: DRUID
- spec: balance
- character: —
- tab: character
- icon: `spell_nature_abolishmagic`
- source: plan
- chars: 30

```
#showtooltip Wrath
/cast Wrath
```

#### d-star

- name: `stf`
- scope: class
- class: DRUID
- spec: balance
- character: —
- tab: character
- icon: `spell_arcane_starfire`
- source: plan
- chars: 36

```
#showtooltip Starfire
/cast Starfire
```

#### d-moonkin

- name: `mk`
- scope: class
- class: DRUID
- spec: balance
- character: —
- tab: character
- icon: `spell_nature_forceofnature`
- source: plan
- chars: 44

```
#showtooltip Moonkin Form
/cast Moonkin Form
```

#### d-roots

- name: `er`
- scope: class
- class: DRUID
- spec: balance
- character: —
- tab: character
- icon: `spell_nature_stranglevines`
- source: plan
- chars: 85

```
#showtooltip
/cancelform
/cast [mod:shift] Entangling Roots(Rank 1); Entangling Roots
```

#### d-rejuv

- name: `rej`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_rejuvenation`
- source: plan
- chars: 115

```
#showtooltip
/cancelform
/cast [mod:alt,target=player] Rejuvenation; [mod:shift] Rejuvenation(Rank 3); Rejuvenation
```

#### d-swift

- name: `sm`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `inv_relics_idolofrejuvenation`
- source: plan
- chars: 50

```
#showtooltip Swiftmend
/cancelform
/cast Swiftmend
```

#### d-ns

- name: `dnsw`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_ravenform`
- source: plan
- chars: 83

```
#showtooltip Healing Touch
/cancelform
/cast Nature's Swiftness
/cast Healing Touch
```

### shared-tbc

TBC racial wrappers that need a modifier or stopcasting. Blood Elf and Draenei passives stay on the bar. Mana Tap is a plain racial.

#### shared-gotn

- name: `gotn`
- scope: global
- class: ALL
- spec: all
- character: —
- tab: account
- icon: `spell_holy_holyprotection`
- source: plan
- chars: 97
- version: TBC
- notes: Draenei heal. Alt self.

```
#showtooltip Gift of the Naaru
/cast [mod:alt,target=player] Gift of the Naaru; Gift of the Naaru
```

#### shared-at

- name: `atorrent`
- scope: global
- class: ALL
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_teleport`
- source: plan
- chars: 61
- version: TBC
- notes: Blood Elf interrupt. Stops a queued spell first.

```
#showtooltip Arcane Torrent
/stopcasting
/cast Arcane Torrent
```

### warrior-tbc

TBC trainer abilities. Slam sits in Warrior core on TBC. Stance Mastery is passive.

#### w-cshout

- name: `cshout`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: character
- icon: `ability_warrior_rallyingcry`
- source: plan
- chars: 65
- version: TBC
- notes: Health shout. Battle Shout stays on `w-shout`.

```
#showtooltip Commanding Shout
/cast Commanding Shout
/startattack
```

#### w-intervene

- name: `interv`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: character
- icon: `ability_warrior_victoryrush`
- source: plan
- chars: 107
- version: TBC
- notes: Enters Defensive Stance. Uses a friendly living mouseover, then the current target.

```
#showtooltip Intervene
/cast [nostance:2] Defensive Stance
/cast [target=mouseover,help,nodead][] Intervene
```

#### w-reflect

- name: `reflect`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: character
- icon: `ability_warrior_shieldreflection`
- source: plan
- chars: 101
- version: TBC
- notes: Requires an equipped shield. Enters Defensive Stance.

```
#showtooltip Spell Reflection
/stopcasting
/cast [nostance:2] Defensive Stance
/cast Spell Reflection
```

#### w-vrush

- name: `vrush`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: character
- icon: `ability_warrior_devastate`
- source: plan
- chars: 88
- version: TBC
- notes: Leaves Defensive Stance. Usable after a killing blow.

```
#showtooltip Victory Rush
/cast [stance:2] Battle Stance
/cast Victory Rush
/startattack
```

### paladin-tbc

TBC baseline and talent buttons. Paladin is both factions. Seal of Command stays on `p-seal`.

#### p-cstrike

- name: `cstrike`
- scope: class
- class: PALADIN
- spec: retribution
- character: —
- tab: character
- icon: `spell_holy_crusaderstrike`
- source: plan
- chars: 63
- version: TBC

```
#showtooltip Crusader Strike
/startattack
/cast Crusader Strike
```

#### p-aw

- name: `aw`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_avenginewrath`
- source: plan
- chars: 56
- version: TBC

```
#showtooltip Avenging Wrath
/use 13
/cast Avenging Wrath
```

#### p-rdef

- name: `rdef`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `inv_shoulder_37`
- source: plan
- chars: 87
- version: TBC
- notes: Taunt the mobs on a friendly mouseover, then the current target.

```
#showtooltip Righteous Defense
/cast [target=mouseover,help,nodead][] Righteous Defense
```

#### p-ashield

- name: `ashield`
- scope: class
- class: PALADIN
- spec: protection
- character: —
- tab: character
- icon: `spell_holy_avengersshield`
- source: plan
- chars: 65
- version: TBC

```
#showtooltip Avenger's Shield
/startattack
/cast Avenger's Shield
```

#### p-sealtbc

- name: `sealtbc`
- scope: class
- class: PALADIN
- spec: retribution
- character: —
- tab: character
- icon: `spell_holy_sealofblood`
- source: plan
- chars: 106
- version: TBC
- notes: Horde Blood / Martyr. Alliance Vengeance / Corruption. First learned seal wins.

```
#showtooltip
/cast Seal of Blood
/cast Seal of Vengeance
/cast Seal of the Martyr
/cast Seal of Corruption
```

#### p-turne

- name: `turne`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_turnundead`
- source: plan
- chars: 51
- version: TBC

```
#showtooltip Turn Evil
/stopcasting
/cast Turn Evil
```

#### p-caura

- name: `caura`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: character
- icon: `spell_holy_crusaderaura`
- source: plan
- chars: 46
- version: TBC

```
#showtooltip Crusader Aura
/cast Crusader Aura
```

### hunter-tbc

TBC shots, Kill Command, Misdirection, and Viper. Readiness is gone. Bestial Wrath stays in Hunter core.

#### h-steady

- name: `steady`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_hunter_steadyshot`
- source: plan
- chars: 42
- version: TBC

```
#showtooltip Steady Shot
/cast Steady Shot
```

#### h-kc

- name: `kc`
- scope: class
- class: HUNTER
- spec: beast-mastery
- character: —
- tab: character
- icon: `ability_hunter_killcommand`
- source: plan
- chars: 55
- version: TBC

```
#showtooltip Kill Command
/petattack
/cast Kill Command
```

#### h-md

- name: `md`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_hunter_misdirection`
- source: plan
- chars: 123
- version: TBC
- notes: Friendly mouseover, then pet, then current target.

```
#showtooltip Misdirection
/cast [target=mouseover,help,nodead] Misdirection; [target=pet,exists] Misdirection; Misdirection
```

#### h-snake

- name: `snake`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_hunter_snaketrap`
- source: plan
- chars: 40
- version: TBC

```
#showtooltip Snake Trap
/cast Snake Trap
```

#### h-aspv

- name: `aspv`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: character
- icon: `ability_hunter_aspectoftheviper`
- source: plan
- chars: 103
- version: TBC
- notes: Hawk normally. Shift is Viper. Ctrl is Monkey. Era `asp` has no Viper line.

```
#showtooltip
/cast [mod:shift] Aspect of the Viper; [mod:ctrl] Aspect of the Monkey; Aspect of the Hawk
```

### rogue-tbc

TBC Cloak, finishers, Shiv, and talent openers. Anesthetic Poison is an item; drag it to the bar.

#### r-cloak

- name: `cloak`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_nethercloak`
- source: plan
- chars: 65
- version: TBC

```
#showtooltip Cloak of Shadows
/stopcasting
/cast Cloak of Shadows
```

#### r-dthrow

- name: `dthrow`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `inv_throwingknife_06`
- source: plan
- chars: 44
- version: TBC

```
#showtooltip Deadly Throw
/cast Deadly Throw
```

#### r-shiv

- name: `shiv`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: character
- icon: `inv_throwingknife_04`
- source: plan
- chars: 41
- version: TBC

```
#showtooltip Shiv
/startattack
/cast Shiv
```

#### r-env

- name: `env`
- scope: class
- class: ROGUE
- spec: assassination
- character: —
- tab: character
- icon: `ability_rogue_disembowel`
- source: plan
- chars: 34
- version: TBC

```
#showtooltip Envenom
/cast Envenom
```

#### r-step

- name: `step`
- scope: class
- class: ROGUE
- spec: subtlety
- character: —
- tab: character
- icon: `ability_rogue_shadowstep`
- source: plan
- chars: 40
- version: TBC

```
#showtooltip Shadowstep
/cast Shadowstep
```

#### r-mut

- name: `mut`
- scope: class
- class: ROGUE
- spec: assassination
- character: —
- tab: character
- icon: `ability_rogue_shadowstrikes`
- source: plan
- chars: 49
- version: TBC

```
#showtooltip Mutilate
/startattack
/cast Mutilate
```

### priest-tbc

TBC trainer and talent heals. Fear Ward is baseline. Blood Elf Consume Magic and Draenei/Dwarf Chastise stay here because they need stopcasting.

#### pr-swd

- name: `swd`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_demonicfortitude`
- source: plan
- chars: 56
- version: TBC

```
#showtooltip Shadow Word: Death
/cast Shadow Word: Death
```

#### pr-pom

- name: `pom`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_prayerofmendingtga`
- source: plan
- chars: 97
- version: TBC

```
#showtooltip Prayer of Mending
/cast [mod:alt,target=player] Prayer of Mending; Prayer of Mending
```

#### pr-coh

- name: `coh`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_circleofrenewal`
- source: plan
- chars: 97
- version: TBC

```
#showtooltip Circle of Healing
/cast [mod:alt,target=player] Circle of Healing; Circle of Healing
```

#### pr-psup

- name: `psup`
- scope: class
- class: PRIEST
- spec: discipline
- character: —
- tab: character
- icon: `spell_holy_painsupression`
- source: plan
- chars: 123
- version: TBC

```
#showtooltip Pain Suppression
/raid Pain Suppression on %t
/cast [mod:alt,target=player] Pain Suppression; Pain Suppression
```

#### pr-mdisp

- name: `mdisp`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_massdispel`
- source: plan
- chars: 55
- version: TBC

```
#showtooltip Mass Dispel
/stopcasting
/cast Mass Dispel
```

#### pr-sfiend

- name: `sfiend`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_shadowfiend`
- source: plan
- chars: 42
- version: TBC

```
#showtooltip Shadowfiend
/cast Shadowfiend
```

#### pr-bheal

- name: `bheal`
- scope: class
- class: PRIEST
- spec: holy
- character: —
- tab: character
- icon: `spell_holy_blindingheal`
- source: plan
- chars: 44
- version: TBC

```
#showtooltip Binding Heal
/cast Binding Heal
```

#### pr-vt

- name: `vt`
- scope: class
- class: PRIEST
- spec: shadow
- character: —
- tab: character
- icon: `spell_holy_stoicism`
- source: plan
- chars: 48
- version: TBC

```
#showtooltip Vampiric Touch
/cast Vampiric Touch
```

#### pr-cmagic

- name: `cmagic`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_studentofmagic`
- source: plan
- chars: 59
- version: TBC
- notes: Blood Elf priest racial.

```
#showtooltip Consume Magic
/stopcasting
/cast Consume Magic
```

#### pr-chast

- name: `chast`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: character
- icon: `spell_holy_chastise`
- source: plan
- chars: 49
- version: TBC
- notes: Dwarf and Draenei priest racial.

```
#showtooltip Chastise
/stopcasting
/cast Chastise
```

### shaman-tbc

TBC both factions. Bloodlust and Heroism share one body. Stormstrike stays in Shaman Enhancement.

#### s-bl

- name: `bl`
- scope: class
- class: SHAMAN
- spec: enhancement
- character: —
- tab: character
- icon: `spell_nature_bloodlust`
- source: plan
- chars: 42
- version: TBC
- notes: Horde Bloodlust. Alliance Heroism. First learned spell wins.

```
#showtooltip
/cast Bloodlust
/cast Heroism
```

#### s-wshield

- name: `wshield`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `ability_shaman_watershield`
- source: plan
- chars: 61
- version: TBC

```
#showtooltip
/cast [mod:shift] Lightning Shield; Water Shield
```

#### s-eshield

- name: `eshield`
- scope: class
- class: SHAMAN
- spec: restoration
- character: —
- tab: character
- icon: `spell_nature_skinofearth`
- source: plan
- chars: 82
- version: TBC

```
#showtooltip Earth Shield
/cast [mod:alt,target=player] Earth Shield; Earth Shield
```

#### s-srage

- name: `srage`
- scope: class
- class: SHAMAN
- spec: enhancement
- character: —
- tab: character
- icon: `spell_nature_shamanrage`
- source: plan
- chars: 52
- version: TBC

```
#showtooltip Shamanistic Rage
/cast Shamanistic Rage
```

#### s-woa

- name: `woa`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_slowingtotem`
- source: plan
- chars: 56
- version: TBC

```
#showtooltip Wrath of Air Totem
/cast Wrath of Air Totem
```

#### s-towrath

- name: `towrath`
- scope: class
- class: SHAMAN
- spec: elemental
- character: —
- tab: character
- icon: `spell_fire_totemofwrath`
- source: plan
- chars: 48
- version: TBC

```
#showtooltip Totem of Wrath
/cast Totem of Wrath
```

#### s-eet

- name: `eet`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_nature_earthelemental_totem`
- source: plan
- chars: 62
- version: TBC

```
#showtooltip Earth Elemental Totem
/cast Earth Elemental Totem
```

#### s-fet

- name: `fet`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_fire_elemental_totem`
- source: plan
- chars: 60
- version: TBC

```
#showtooltip Fire Elemental Totem
/cast Fire Elemental Totem
```

#### s-tcall

- name: `tcall`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: character
- icon: `spell_unused`
- source: plan
- chars: 44
- version: TBC

```
#showtooltip Totemic Call
/cast Totemic Call
```

### mage-tbc

TBC trainer and talent buttons plus Outland ports. Shift still opens a portal on the city macros. Ice Block stays in Mage control.

#### m-ilance

- name: `ilance`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: character
- icon: `spell_frost_frostblast`
- source: plan
- chars: 38
- version: TBC

```
#showtooltip Ice Lance
/cast Ice Lance
```

#### m-steal

- name: `steal`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_arcane02`
- source: plan
- chars: 53
- version: TBC

```
#showtooltip Spellsteal
/stopcasting
/cast Spellsteal
```

#### m-invis

- name: `invis`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `ability_mage_invisibility`
- source: plan
- chars: 57
- version: TBC

```
#showtooltip Invisibility
/stopcasting
/cast Invisibility
```

#### m-molten

- name: `molten`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `ability_mage_moltenarmor`
- source: plan
- chars: 44
- version: TBC

```
#showtooltip Molten Armor
/cast Molten Armor
```

#### m-ablast

- name: `ablast`
- scope: class
- class: MAGE
- spec: arcane
- character: —
- tab: character
- icon: `spell_arcane_blast`
- source: plan
- chars: 49
- version: TBC

```
#showtooltip Arcane Blast
/cqs
/cast Arcane Blast
```

#### m-slow

- name: `mslow`
- scope: class
- class: MAGE
- spec: arcane
- character: —
- tab: character
- icon: `spell_nature_slow`
- source: plan
- chars: 28
- version: TBC

```
#showtooltip Slow
/cast Slow
```

#### m-dbreath

- name: `dbreath`
- scope: class
- class: MAGE
- spec: fire
- character: —
- tab: character
- icon: `inv_misc_head_dragon_01`
- source: plan
- chars: 50
- version: TBC

```
#showtooltip Dragon's Breath
/cast Dragon's Breath
```

#### m-welem

- name: `welem`
- scope: class
- class: MAGE
- spec: frost
- character: —
- tab: character
- icon: `spell_frost_summonwaterelemental_2`
- source: plan
- chars: 64
- version: TBC

```
#showtooltip Summon Water Elemental
/cast Summon Water Elemental
```

#### m-table

- name: `mtable`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_massdispel`
- source: plan
- chars: 62
- version: TBC

```
#showtooltip Ritual of Refreshment
/cast Ritual of Refreshment
```

#### m-gemtbc

- name: `gemtbc`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `inv_misc_gem_stone_01`
- source: plan
- chars: 60
- version: TBC

```
#showtooltip Conjure Mana Emerald
/cast Conjure Mana Emerald
```

#### m-exodar

- name: `exodar`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_portalexodar`
- source: plan
- chars: 124
- version: TBC

```
#showtooltip [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar
/cast [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar
```

#### m-slvr

- name: `slvr`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_portalsilvermoon`
- source: plan
- chars: 140
- version: TBC

```
#showtooltip [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon
/cast [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon
```

#### m-shat

- name: `shat`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_portalshattrath`
- source: plan
- chars: 136
- version: TBC

```
#showtooltip [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath
/cast [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath
```

#### m-thera

- name: `thera`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_portaltheramore`
- source: plan
- chars: 136
- version: TBC

```
#showtooltip [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore
/cast [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore
```

#### m-stonard

- name: `stonard`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_portalstonard`
- source: plan
- chars: 128
- version: TBC

```
#showtooltip [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard
/cast [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard
```

### warlock-tbc

TBC armor, filler, soulwell, and talent CCs. Create Soulstone ranks collapsed on the TBC trainer list; the soulstone macro still uses the item.

#### l-incin

- name: `incin`
- scope: class
- class: WARLOCK
- spec: destruction
- character: —
- tab: character
- icon: `spell_fire_burnout`
- source: plan
- chars: 40
- version: TBC

```
#showtooltip Incinerate
/cast Incinerate
```

#### l-felarm

- name: `felarm`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_felarmour`
- source: plan
- chars: 53
- version: TBC

```
#showtooltip
/cast [mod:shift] Demon Armor; Fel Armor
```

#### l-shatter

- name: `shatter`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: character
- icon: `spell_arcane_arcane01`
- source: plan
- chars: 42
- version: TBC

```
#showtooltip Soulshatter
/cast Soulshatter
```

#### l-souls

- name: `souls`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: character
- icon: `spell_shadow_shadesofdarkness`
- source: plan
- chars: 50
- version: TBC

```
#showtooltip Ritual of Souls
/cast Ritual of Souls
```

#### l-seed

- name: `seed`
- scope: class
- class: WARLOCK
- spec: affliction
- character: —
- tab: character
- icon: `spell_shadow_seedofdestruction`
- source: plan
- chars: 56
- version: TBC

```
#showtooltip Seed of Corruption
/cast Seed of Corruption
```

#### l-ua

- name: `ua`
- scope: class
- class: WARLOCK
- spec: affliction
- character: —
- tab: character
- icon: `spell_shadow_unstableaffliction_3`
- source: plan
- chars: 58
- version: TBC

```
#showtooltip Unstable Affliction
/cast Unstable Affliction
```

#### l-sfury

- name: `sfury`
- scope: class
- class: WARLOCK
- spec: destruction
- character: —
- tab: character
- icon: `spell_shadow_shadowfury`
- source: plan
- chars: 53
- version: TBC

```
#showtooltip Shadowfury
/stopcasting
/cast Shadowfury
```

#### l-fguard

- name: `fguard`
- scope: class
- class: WARLOCK
- spec: demonology
- character: —
- tab: character
- icon: `spell_shadow_summonfelguard`
- source: plan
- chars: 50
- version: TBC

```
#showtooltip Summon Felguard
/cast Summon Felguard
```

### druid-tbc

TBC forms and feral/resto buttons. Flight Form is trainer-taught. Swift Flight Form is Restoration.

#### d-mangle

- name: `mangle`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_mangle2`
- source: plan
- chars: 68
- version: TBC

```
#showtooltip
/startattack
/cast [form:3] Mangle (Cat); Mangle (Bear)
```

#### d-lbloom

- name: `lbloom`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `inv_misc_herb_felblossom`
- source: plan
- chars: 85
- version: TBC

```
#showtooltip Lifebloom
/cancelform
/cast [mod:alt,target=player] Lifebloom; Lifebloom
```

#### d-cyc

- name: `cyc`
- scope: class
- class: DRUID
- spec: balance
- character: —
- tab: character
- icon: `spell_nature_earthbind`
- source: plan
- chars: 47
- version: TBC

```
#showtooltip Cyclone
/stopcasting
/cast Cyclone
```

#### d-flight

- name: `flight`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: character
- icon: `ability_druid_flightform`
- source: plan
- chars: 61
- version: TBC

```
#showtooltip
/cast [mod:shift] Swift Flight Form; Flight Form
```

#### d-lac

- name: `lac`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_lacerate`
- source: plan
- chars: 49
- version: TBC

```
#showtooltip Lacerate
/startattack
/cast Lacerate
```

#### d-maim

- name: `maim`
- scope: class
- class: DRUID
- spec: feral
- character: —
- tab: character
- icon: `ability_druid_mangle-tga`
- source: plan
- chars: 28
- version: TBC

```
#showtooltip Maim
/cast Maim
```

#### d-tree

- name: `tree`
- scope: class
- class: DRUID
- spec: restoration
- character: —
- tab: character
- icon: `ability_druid_treeoflife`
- source: plan
- chars: 44
- version: TBC

```
#showtooltip Tree of Life
/cast Tree of Life
```

### paladin-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### p-gbom

- name: `gbom`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_greaterblessingofkings`
- source: plan
- chars: 96

```
#showtooltip
/cast [nomod]Greater Blessing of Might;[mod:shift]Greater Blessing of Might(Rank 1)
```

#### p-crus

- name: `crus`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_holysmite`
- source: plan
- chars: 86

```
#showtooltip
/cast [nomod]Seal of the Crusader;[mod:shift]Seal of the Crusader(Rank 1)
```

#### p-bosac

- name: `bosac`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_sealofsacrifice`
- source: plan
- chars: 88

```
#showtooltip
/cast [nomod]Blessing of Sacrifice;[mod:shift]Blessing of Sacrifice(Rank 1)
```

#### p-dprot

- name: `dprot`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_restoration`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Divine Protection;[mod:shift]Divine Protection(Rank 1)
```

#### p-fraura

- name: `fraura`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_fire_sealoffire`
- source: plan
- chars: 86

```
#showtooltip
/cast [nomod]Fire Resistance Aura;[mod:shift]Fire Resistance Aura(Rank 1)
```

#### p-rfaura

- name: `rfaura`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_frost_wizardmark`
- source: plan
- chars: 88

```
#showtooltip
/cast [nomod]Frost Resistance Aura;[mod:shift]Frost Resistance Aura(Rank 1)
```

#### p-sraura

- name: `sraura`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_sealofkings`
- source: plan
- chars: 90

```
#showtooltip
/cast [nomod]Shadow Resistance Aura;[mod:shift]Shadow Resistance Aura(Rank 1)
```

#### p-bolight

- name: `bolight`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_prayerofhealing02`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Blessing of Light;[mod:shift]Blessing of Light(Rank 1)
```

#### p-gbow

- name: `gbow`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_greaterblessingofwisdom`
- source: plan
- chars: 98

```
#showtooltip
/cast [nomod]Greater Blessing of Wisdom;[mod:shift]Greater Blessing of Wisdom(Rank 1)
```

#### p-hwath

- name: `hwath`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_excorcism`
- source: plan
- chars: 66

```
#showtooltip
/cast [nomod]Holy Wrath;[mod:shift]Holy Wrath(Rank 1)
```

#### p-redeem

- name: `redeem`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_resurrection`
- source: plan
- chars: 66

```
#showtooltip
/cast [nomod]Redemption;[mod:shift]Redemption(Rank 1)
```

#### p-turnu

- name: `turnu`
- scope: class
- class: PALADIN
- spec: all
- character: —
- tab: account
- icon: `spell_holy_turnundead`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Turn Undead;[mod:shift]Turn Undead(Rank 1)
```

### hunter-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### h-wild

- name: `wild`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `spell_nature_protectionformnature`
- source: plan
- chars: 82

```
#showtooltip
/cast [nomod]Aspect of the Wild;[mod:shift]Aspect of the Wild(Rank 1)
```

#### h-scare

- name: `scare`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `ability_druid_cower`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Scare Beast;[mod:shift]Scare Beast(Rank 1)
```

#### h-dshot

- name: `dshot`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `spell_arcane_blink`
- source: plan
- chars: 78

```
#showtooltip
/cast [nomod]Distracting Shot;[mod:shift]Distracting Shot(Rank 1)
```

#### h-scorpid

- name: `scorpid`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `ability_hunter_criticalshot`
- source: plan
- chars: 72

```
#showtooltip
/cast [nomod]Scorpid Sting;[mod:shift]Scorpid Sting(Rank 1)
```

#### h-viper

- name: `viper`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `ability_hunter_aimedshot`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Viper Sting;[mod:shift]Viper Sting(Rank 1)
```

#### h-volley

- name: `volley`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `ability_marksmanship`
- source: plan
- chars: 58

```
#showtooltip
/cast [nomod]Volley;[mod:shift]Volley(Rank 1)
```

#### h-diseng

- name: `diseng`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `ability_rogue_feint`
- source: plan
- chars: 64

```
#showtooltip
/cast [nomod]Disengage;[mod:shift]Disengage(Rank 1)
```

#### h-etrap

- name: `etrap`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `spell_fire_selfdestruct`
- source: plan
- chars: 74

```
#showtooltip
/cast [nomod]Explosive Trap;[mod:shift]Explosive Trap(Rank 1)
```

#### h-itrap

- name: `itrap`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `spell_fire_flameshock`
- source: plan
- chars: 76

```
#showtooltip
/cast [nomod]Immolation Trap;[mod:shift]Immolation Trap(Rank 1)
```

#### h-mongo

- name: `mongo`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `ability_hunter_swiftstrike`
- source: plan
- chars: 85

```
#showtooltip
/startattack
/cast [nomod]Mongoose Bite;[mod:shift]Mongoose Bite(Rank 1)
```

#### h-raptor

- name: `raptor`
- scope: class
- class: HUNTER
- spec: all
- character: —
- tab: account
- icon: `ability_meleedamage`
- source: plan
- chars: 85

```
#showtooltip
/startattack
/cast [nomod]Raptor Strike;[mod:shift]Raptor Strike(Rank 1)
```

### rogue-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### r-expose

- name: `expose`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_riposte`
- source: plan
- chars: 70

```
#showtooltip
/cast [nomod]Expose Armor;[mod:shift]Expose Armor(Rank 1)
```

#### r-garrote

- name: `garrote`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: account
- icon: `ability_rogue_garrote`
- source: plan
- chars: 60

```
#showtooltip
/cast [nomod]Garrote;[mod:shift]Garrote(Rank 1)
```

#### r-bstab

- name: `bstab`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: account
- icon: `ability_backstab`
- source: plan
- chars: 75

```
#showtooltip
/startattack
/cast [nomod]Backstab;[mod:shift]Backstab(Rank 1)
```

#### r-feint

- name: `feint`
- scope: class
- class: ROGUE
- spec: all
- character: —
- tab: account
- icon: `ability_rogue_feint`
- source: plan
- chars: 56

```
#showtooltip
/cast [nomod]Feint;[mod:shift]Feint(Rank 1)
```

### priest-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### pr-egrace

- name: `egrace`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_elunesgrace`
- source: plan
- chars: 72

```
#showtooltip
/cast [nomod]Elune's Grace;[mod:shift]Elune's Grace(Rank 1)
```

#### pr-fback

- name: `fback`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_ritualofsacrifice`
- source: plan
- chars: 62

```
#showtooltip
/cast [nomod]Feedback;[mod:shift]Feedback(Rank 1)
```

#### pr-mburn

- name: `mburn`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_manaburn`
- source: plan
- chars: 64

```
#showtooltip
/cast [nomod]Mana Burn;[mod:shift]Mana Burn(Rank 1)
```

#### pr-shards

- name: `shards`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_arcane_starfire`
- source: plan
- chars: 66

```
#showtooltip
/cast [nomod]Starshards;[mod:shift]Starshards(Rank 1)
```

#### pr-dpray

- name: `dpray`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_restoration`
- source: plan
- chars: 78

```
#showtooltip
/cast [nomod]Desperate Prayer;[mod:shift]Desperate Prayer(Rank 1)
```

#### pr-heal

- name: `heal`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_heal02`
- source: plan
- chars: 79

```
#showtooltip
/cast [mod:alt,target=player] Heal; [mod:shift] Heal(Rank 1); Heal
```

#### pr-hfire

- name: `hfire`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_searinglight`
- source: plan
- chars: 64

```
#showtooltip
/cast [nomod]Holy Fire;[mod:shift]Holy Fire(Rank 1)
```

#### pr-lheal

- name: `lheal`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_lesserheal`
- source: plan
- chars: 100

```
#showtooltip
/cast [mod:alt,target=player] Lesser Heal; [mod:shift] Lesser Heal(Rank 1); Lesser Heal
```

#### pr-smite

- name: `smite`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_holysmite`
- source: plan
- chars: 56

```
#showtooltip
/cast [nomod]Smite;[mod:shift]Smite(Rank 1)
```

#### pr-dplague

- name: `dplague`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_blackplague`
- source: plan
- chars: 78

```
#showtooltip
/cast [nomod]Devouring Plague;[mod:shift]Devouring Plague(Rank 1)
```

#### pr-hexw

- name: `hexw`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_fingerofdeath`
- source: plan
- chars: 76

```
#showtooltip
/cast [nomod]Hex of Weakness;[mod:shift]Hex of Weakness(Rank 1)
```

#### pr-mc

- name: `mc`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_shadowworddominate`
- source: plan
- chars: 70

```
#showtooltip
/cast [nomod]Mind Control;[mod:shift]Mind Control(Rank 1)
```

#### pr-msoothe

- name: `msoothe`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_mindsooth`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Mind Soothe;[mod:shift]Mind Soothe(Rank 1)
```

#### pr-mvis

- name: `mvis`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_holy_mindvision`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Mind Vision;[mod:shift]Mind Vision(Rank 1)
```

#### pr-sprot

- name: `sprot`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_antishadow`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Shadow Protection;[mod:shift]Shadow Protection(Rank 1)
```

#### pr-sguard

- name: `sguard`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_nature_lightningshield`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Shadowguard;[mod:shift]Shadowguard(Rank 1)
```

#### pr-tow

- name: `tow`
- scope: class
- class: PRIEST
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_deadofnight`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Touch of Weakness;[mod:shift]Touch of Weakness(Rank 1)
```

### shaman-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### s-fnt

- name: `fnt`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_fire_sealoffire`
- source: plan
- chars: 76

```
#showtooltip
/cast [nomod]Fire Nova Totem;[mod:shift]Fire Nova Totem(Rank 1)
```

#### s-magma

- name: `magma`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_fire_selfdestruct`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Magma Totem;[mod:shift]Magma Totem(Rank 1)
```

#### s-sear

- name: `sear`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_fire_searingtotem`
- source: plan
- chars: 72

```
#showtooltip
/cast [nomod]Searing Totem;[mod:shift]Searing Totem(Rank 1)
```

#### s-sclaw

- name: `sclaw`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_stoneclawtotem`
- source: plan
- chars: 76

```
#showtooltip
/cast [nomod]Stoneclaw Totem;[mod:shift]Stoneclaw Totem(Rank 1)
```

#### s-frtot

- name: `frtot`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_fireresistancetotem_01`
- source: plan
- chars: 88

```
#showtooltip
/cast [nomod]Fire Resistance Totem;[mod:shift]Fire Resistance Totem(Rank 1)
```

#### s-fttot

- name: `fttot`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_guardianward`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Flametongue Totem;[mod:shift]Flametongue Totem(Rank 1)
```

#### s-rftot

- name: `rftot`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_frostresistancetotem_01`
- source: plan
- chars: 90

```
#showtooltip
/cast [nomod]Frost Resistance Totem;[mod:shift]Frost Resistance Totem(Rank 1)
```

#### s-fbrand

- name: `fbrand`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_frost_frostbrand`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Frostbrand Weapon;[mod:shift]Frostbrand Weapon(Rank 1)
```

#### s-goa

- name: `goa`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_invisibilitytotem`
- source: plan
- chars: 82

```
#showtooltip
/cast [nomod]Grace of Air Totem;[mod:shift]Grace of Air Totem(Rank 1)
```

#### s-nrtot

- name: `nrtot`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_natureresistancetotem`
- source: plan
- chars: 92

```
#showtooltip
/cast [nomod]Nature Resistance Totem;[mod:shift]Nature Resistance Totem(Rank 1)
```

#### s-rbit

- name: `rbit`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_rockbiter`
- source: plan
- chars: 78

```
#showtooltip
/cast [nomod]Rockbiter Weapon;[mod:shift]Rockbiter Weapon(Rank 1)
```

#### s-sskin

- name: `sskin`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_stoneskintotem`
- source: plan
- chars: 76

```
#showtooltip
/cast [nomod]Stoneskin Totem;[mod:shift]Stoneskin Totem(Rank 1)
```

#### s-wwall

- name: `wwall`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_earthbind`
- source: plan
- chars: 74

```
#showtooltip
/cast [nomod]Windwall Totem;[mod:shift]Windwall Totem(Rank 1)
```

#### s-aspirit

- name: `aspirit`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_regenerate`
- source: plan
- chars: 78

```
#showtooltip
/cast [nomod]Ancestral Spirit;[mod:shift]Ancestral Spirit(Rank 1)
```

#### s-cheal

- name: `cheal`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `spell_nature_healingwavegreater`
- source: plan
- chars: 97

```
#showtooltip
/cast [mod:alt,target=player] Chain Heal; [mod:shift] Chain Heal(Rank 1); Chain Heal
```

#### s-hstot

- name: `hstot`
- scope: class
- class: SHAMAN
- spec: all
- character: —
- tab: account
- icon: `inv_spear_04`
- source: plan
- chars: 86

```
#showtooltip
/cast [nomod]Healing Stream Totem;[mod:shift]Healing Stream Totem(Rank 1)
```

### mage-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### m-ai

- name: `ai`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_holy_magicalsentry`
- source: plan
- chars: 36

```
#showtooltip
/cast Arcane Intellect;
```

#### m-cf

- name: `cf`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `inv_misc_food_73cinnamonroll`
- source: plan
- chars: 31

```
#showtooltip
/cast Conjure Food
```

#### m-cw

- name: `cw`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `inv_drink_18`
- source: plan
- chars: 32

```
#showtooltip
/cast Conjure Water
```

#### m-ma

- name: `ma`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_magearmor`
- source: plan
- chars: 30

```
#showtooltip
/cast Mage Armor;
```

#### m-ia

- name: `ia`
- scope: class
- class: MAGE
- spec: all
- character: —
- tab: account
- icon: `spell_frost_frostarmor02`
- source: plan
- chars: 29

```
#showtooltip
/cast Ice Armor;
```

### warlock-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### l-cor

- name: `cor`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_unholystrength`
- source: plan
- chars: 88

```
#showtooltip
/cast [nomod]Curse of Recklessness;[mod:shift]Curse of Recklessness(Rank 1)
```

#### l-cosh

- name: `cosh`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_curseofachimonde`
- source: plan
- chars: 76

```
#showtooltip
/cast [nomod]Curse of Shadow;[mod:shift]Curse of Shadow(Rank 1)
```

#### l-cot

- name: `cot`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_curseoftounges`
- source: plan
- chars: 78

```
#showtooltip
/cast [nomod]Curse of Tongues;[mod:shift]Curse of Tongues(Rank 1)
```

#### l-cowk

- name: `cowk`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_curseofmannoroth`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Curse of Weakness;[mod:shift]Curse of Weakness(Rank 1)
```

#### l-dlife

- name: `dlife`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_lifedrain02`
- source: plan
- chars: 66

```
#showtooltip
/cast [nomod]Drain Life;[mod:shift]Drain Life(Rank 1)
```

#### l-dmana

- name: `dmana`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_siphonmana`
- source: plan
- chars: 66

```
#showtooltip
/cast [nomod]Drain Mana;[mod:shift]Drain Mana(Rank 1)
```

#### l-howl

- name: `howl`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_deathscream`
- source: plan
- chars: 74

```
#showtooltip
/cast [nomod]Howl of Terror;[mod:shift]Howl of Terror(Rank 1)
```

#### l-dskin

- name: `dskin`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_ragingscream`
- source: plan
- chars: 66

```
#showtooltip
/cast [nomod]Demon Skin;[mod:shift]Demon Skin(Rank 1)
```

#### l-hfunnel

- name: `hfunnel`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_lifedrain`
- source: plan
- chars: 72

```
#showtooltip
/cast [nomod]Health Funnel;[mod:shift]Health Funnel(Rank 1)
```

#### l-sward

- name: `sward`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_antishadow`
- source: plan
- chars: 68

```
#showtooltip
/cast [nomod]Shadow Ward;[mod:shift]Shadow Ward(Rank 1)
```

#### l-subj

- name: `subj`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_enslavedemon`
- source: plan
- chars: 76

```
#showtooltip
/cast [nomod]Subjugate Demon;[mod:shift]Subjugate Demon(Rank 1)
```

#### l-hell

- name: `hell`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_fire_incinerate`
- source: plan
- chars: 62

```
#showtooltip
/cast [nomod]Hellfire;[mod:shift]Hellfire(Rank 1)
```

#### l-rof

- name: `rof`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_shadow_rainoffire`
- source: plan
- chars: 70

```
#showtooltip
/cast [nomod]Rain of Fire;[mod:shift]Rain of Fire(Rank 1)
```

#### l-spain

- name: `spain`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_fire_soulburn`
- source: plan
- chars: 70

```
#showtooltip
/cast [nomod]Searing Pain;[mod:shift]Searing Pain(Rank 1)
```

#### l-sfire

- name: `sfire`
- scope: class
- class: WARLOCK
- spec: all
- character: —
- tab: account
- icon: `spell_fire_fireball02`
- source: plan
- chars: 64

```
#showtooltip
/cast [nomod]Soul Fire;[mod:shift]Soul Fire(Rank 1)
```

### druid-ranks

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

#### d-hib

- name: `hib`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `spell_nature_sleep`
- source: plan
- chars: 76

```
#showtooltip
/cancelform
/cast [nomod]Hibernate;[mod:shift]Hibernate(Rank 1)
```

#### d-cane

- name: `cane`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `spell_nature_cyclone`
- source: plan
- chars: 64

```
#showtooltip
/cast [nomod]Hurricane;[mod:shift]Hurricane(Rank 1)
```

#### d-soothe

- name: `soothe`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `ability_hunter_beastsoothe`
- source: plan
- chars: 84

```
#showtooltip
/cancelform
/cast [nomod]Soothe Animal;[mod:shift]Soothe Animal(Rank 1)
```

#### d-thorns

- name: `thorns`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `spell_nature_thorns`
- source: plan
- chars: 70

```
#showtooltip
/cancelform
/cast [nomod]Thorns;[mod:shift]Thorns(Rank 1)
```

#### d-claw

- name: `claw`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `ability_druid_rake`
- source: plan
- chars: 67

```
#showtooltip
/startattack
/cast [nomod]Claw;[mod:shift]Claw(Rank 1)
```

#### d-cower

- name: `cower`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `ability_druid_cower`
- source: plan
- chars: 56

```
#showtooltip
/cast [nomod]Cower;[mod:shift]Cower(Rank 1)
```

#### d-dmr

- name: `dmr`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `classic_ability_druid_demoralizingroar`
- source: plan
- chars: 80

```
#showtooltip
/cast [nomod]Demoralizing Roar;[mod:shift]Demoralizing Roar(Rank 1)
```

#### d-pounce

- name: `pounce`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `ability_druid_supriseattack`
- source: plan
- chars: 58

```
#showtooltip
/cast [nomod]Pounce;[mod:shift]Pounce(Rank 1)
```

#### d-ravage

- name: `ravage`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `ability_druid_ravage`
- source: plan
- chars: 58

```
#showtooltip
/cast [nomod]Ravage;[mod:shift]Ravage(Rank 1)
```

#### d-swipe

- name: `swipe`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `inv_misc_monsterclaw_03`
- source: plan
- chars: 69

```
#showtooltip
/startattack
/cast [nomod]Swipe;[mod:shift]Swipe(Rank 1)
```

#### d-tfury

- name: `tfury`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `ability_mount_jungletiger`
- source: plan
- chars: 70

```
#showtooltip
/cast [nomod]Tiger's Fury;[mod:shift]Tiger's Fury(Rank 1)
```

#### d-gotw

- name: `gotw`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `spell_nature_regeneration`
- source: plan
- chars: 90

```
#showtooltip
/cancelform
/cast [nomod]Gift of the Wild;[mod:shift]Gift of the Wild(Rank 1)
```

#### d-rgw

- name: `rgw`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `spell_nature_resistnature`
- source: plan
- chars: 103

```
#showtooltip
/cancelform
/cast [mod:alt,target=player] Regrowth; [mod:shift] Regrowth(Rank 1); Regrowth
```

#### d-tranq

- name: `tranq`
- scope: class
- class: DRUID
- spec: all
- character: —
- tab: account
- icon: `spell_nature_tranquility`
- source: plan
- chars: 80

```
#showtooltip
/cancelform
/cast [nomod]Tranquility;[mod:shift]Tranquility(Rank 1)
```

### other-Virene

In-game macros with no catalog group. Auto-heal keeps them for Export.

#### ingame-other-Virene-sb

- name: `sb`
- scope: character
- class: PALADIN
- spec: all
- character: Virene
- tab: character
- icon: `132110`
- source: ingame
- chars: 43
- notes: Imported from in-game macros-cache.txt.

```
/equip Thief's Blade
/equiip Redbeard Crest
```

### other-Curents

In-game macros with no catalog group. Auto-heal keeps them for Export.

#### ingame-other-Curents-adad

- name: `adad`
- scope: character
- class: ALL
- spec: all
- character: Curents
- tab: character
- icon: `135952`
- source: ingame
- chars: 6
- notes: Imported from in-game macros-cache.txt.

```
/tar p
```

#### ingame-other-Curents-hloe

- name: `hloe`
- scope: character
- class: ALL
- spec: all
- character: Curents
- tab: character
- icon: `134400`
- source: ingame
- chars: 36
- notes: Imported from in-game macros-cache.txt.

```
/use Light of Elune
/use Hearthstone
```

### other-Xavvian

In-game macros with no catalog group. Auto-heal keeps them for Export.

#### ingame-other-Xavvian-asf

- name: `asf`
- scope: character
- class: WARLOCK
- spec: all
- character: Xavvian
- tab: character
- icon: `134400`
- source: ingame
- chars: 17
- notes: Imported from in-game macros-cache.txt.

```
/4 LF tank scholo
```

### other-WARRIOR

In-game macros with no catalog group. Auto-heal keeps them for Export.

#### ingame-other-WARRIOR-shout

- name: `shout`
- scope: class
- class: WARRIOR
- spec: all
- character: —
- tab: account
- icon: `ability_warrior_battleshout`
- source: ingame
- chars: 57
- notes: Imported from in-game macros-cache.txt.

```
#showtooltip Battle Shout
/cast Battle Shout
/startattack
```

### other-account

In-game macros with no catalog group. Auto-heal keeps them for Export.

#### ingame-other-account-pi

- name: `pi`
- scope: global
- class: ALL
- spec: all
- character: —
- tab: account
- icon: `135939`
- source: ingame
- chars: 142
- notes: Imported from in-game macros-cache.txt.

```
/w Stinkytoez ——————————————————
/w Stinkytoez {star} • • Requesting Power Infusion • • {star}
/w Stinkytoez ——————————————————
/cast Fireball
```

