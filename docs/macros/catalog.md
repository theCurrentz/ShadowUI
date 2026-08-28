# Macro catalog

Source of truth: [catalog.json](catalog.json). WoW Macro Cursor loads that file. Groups with `gameVersion` TBC show only on Version TBC.

Each body starts with `# <global|class-specific|character-specific> <CLASS> <spec> [Toon]` after `#showtooltip` when the 255 cap allows.

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
- chars: 37

```
#showtooltip
# global ALL all
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
- chars: 37

```
#showtooltip
# global ALL all
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
- chars: 37
- notes: Hunter, Warlock, and any other pet class. One General-tab body.

```
# global ALL all | key (`)
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
- chars: 43
- notes: Shift-backtick. Split from pet attack so Shift is a bind, not a modifier.

```
# global ALL all | key (SHIFT-`)
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
- chars: 206
- notes: Enters Battle for Charge or Berserker for Intercept. Do not add Rend.

```
#showtooltip [combat] Intercept; Charge
# class-specific WARRIOR all | key (T)
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
- chars: 90
- notes: Bloodrage stays separate from Berserker Rage.

```
#showtooltip Bloodrage
# class-specific WARRIOR all | key (F)
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
- chars: 123

```
#showtooltip Berserker Rage
# class-specific WARRIOR all | key (G)
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
- chars: 111

```
#showtooltip Battle Stance
# class-specific WARRIOR all | key (moust button 1)
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
- chars: 117

```
#showtooltip Berserker Stance
# class-specific WARRIOR all | key (mouse button 2)
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
- chars: 117

```
#showtooltip Defensive Stance
# class-specific WARRIOR all | key (mouse button 3)
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
- chars: 98
- notes: Uses maximum rank. Rank 3 has the same listed rage cost and is not a rage-saving option.

```
#showtooltip Heroic Strike
# class-specific WARRIOR all | key (1)
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
- chars: 84

```
#showtooltip Cleave
# class-specific WARRIOR all | key (R)
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
- chars: 126
- notes: Enters Berserker Stance. A stance change can require a second press.

```
#showtooltip Whirlwind
# class-specific WARRIOR all | key (C)
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
- chars: 117
- notes: Leaves Defensive Stance because Execute requires Battle or Berserker Stance.

```
#showtooltip Execute
# class-specific WARRIOR all | key (4)
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
- chars: 123
- notes: Enters Battle Stance. A stance change can require a second press.

```
#showtooltip Overpower
# class-specific WARRIOR all | key (2)
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
- chars: 111
- notes: Leaves Berserker Stance because Rend requires Battle or Defensive Stance.

```
#showtooltip Rend
# class-specific WARRIOR all | key (H)
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
- chars: 129
- notes: Uses a hostile living mouseover, then the current target. Useful for multi-target tanking.

```
#showtooltip Sunder Armor
# class-specific WARRIOR all | key (Q)
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
- chars: 111
- version: TBC
- notes: Trainer-taught filler. TBC uses it on the baseline bar. Leaves Defensive Stance.

```
#showtooltip Slam
# class-specific WARRIOR all | key (L)
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
- chars: 246
- notes: One interrupt replaces separate Pummel and Shield Bash copies. It uses Shield Bash with a shield; otherwise it enters Berserker and uses Pummel.

```
#showtooltip [stance:3] Pummel; [equipped:Shields] Shield Bash; Pummel
# class-specific WARRIOR all | key (G)
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
- chars: 118
- notes: One major cooldown key. The current stance selects the spell.

```
#showtooltip
# class-specific WARRIOR all | key (B)
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
- chars: 138
- notes: Uses a hostile living mouseover, then the current target.

```
#showtooltip Taunt
# class-specific WARRIOR all | key (X)
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
- chars: 147
- notes: Battle Shout normally. Shift uses Demoralizing Shout.

```
#showtooltip [mod:shift] Demoralizing Shout; Battle Shout
# class-specific WARRIOR all | key (Y)
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
- chars: 114
- notes: Dedicated Action Deck copy; `w-shout` also provides Demoralizing Shout on Shift.

```
#showtooltip Demoralizing Shout
# class-specific WARRIOR all | key (SHIFT-B)
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
- chars: 121
- notes: Leaves Defensive Stance because Hamstring requires Battle or Berserker Stance.

```
#showtooltip Hamstring
# class-specific WARRIOR all | key (`)
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
- chars: 126

```
#showtooltip Disarm
# class-specific WARRIOR all | key (shift-c)
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
- chars: 113
- notes: Stops auto-attack so the primary target is not hit immediately after the fear.

```
#showtooltip Intimidating Shout
# class-specific WARRIOR all | key (shift-T)
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
- chars: 122

```
#showtooltip Revenge
# class-specific WARRIOR all | key (2)
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
- chars: 125

```
#showtooltip Shield Block
# class-specific WARRIOR all | key (shift-r)
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
- chars: 155
- notes: Uses a hostile living mouseover, then the current target.

```
#showtooltip Mocking Blow
# class-specific WARRIOR all | key (shift-X)
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
- chars: 106

```
#showtooltip Challenging Shout
# class-specific WARRIOR all | key (X)
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
- chars: 116

```
#showtooltip Thunder Clap
# class-specific WARRIOR all | key (6)
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
- chars: 114

```
#showtooltip Retaliation
# class-specific WARRIOR all | key (Z)
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
- chars: 119

```
#showtooltip Recklessness
# class-specific WARRIOR all | key (Z)
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
- chars: 117
- notes: Requires an equipped shield. Named equip copies stay in the gear kit.

```
#showtooltip Shield Wall
# class-specific WARRIOR all | key (Z)
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
- chars: 125

```
#showtooltip Sweeping Strikes
# class-specific WARRIOR arms | key (T)
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
- chars: 99

```
#showtooltip Mortal Strike
# class-specific WARRIOR arms | key (1)
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
- chars: 93

```
#showtooltip Death Wish
# class-specific WARRIOR fury | key (T)
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
- chars: 95

```
#showtooltip Bloodthirst
# class-specific WARRIOR fury | key (1)
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
- chars: 99
- notes: Stops a cast or queued spell so the emergency defensive can fire immediately.

```
#showtooltip Last Stand
# class-specific WARRIOR protection | key (T)
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
- chars: 85
- notes: Uses Diamond Flask, then Death Wish. The flask can consume the first press; press again after the global cooldown.

```
# character-specific WARRIOR fury Tazzy | key (T)
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
- chars: 120
- notes: Cancels a queued attack, then equips the dual-wield threat set.

```
# character-specific WARRIOR all Tazzy | key (unbound)
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
- chars: 129
- notes: Cancels a queued attack, then equips the alternate shield set. The one-handed weapon goes on before the shield.

```
# character-specific WARRIOR all Tazzy | key (unbound)
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
- chars: 128
- notes: Cancels a queued attack, then equips the mitigation shield set.

```
# character-specific WARRIOR all Tazzy | key (unbound)
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
- chars: 207
- notes: Cancels a queued attack, equips the mitigation set, enters Defensive Stance, then uses Shield Wall. Combat swaps can require repeated presses.

```
#showtooltip Shield Wall
# character-specific WARRIOR all Tazzy | key (unbound)
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
- chars: 97

```
#showtooltip
# class-specific MAGE frost
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
- chars: 230

```
#showtooltip Fireball
# class-specific MAGE fire | key (2)
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
- chars: 93

```
#showtooltip
# class-specific MAGE fire
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
- chars: 107

```
#showtooltip
# class-specific MAGE arcane
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
- chars: 110

```
#showtooltip Arcane Missiles
# class-specific MAGE arcane
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
- chars: 90

```
#showtooltip
# class-specific MAGE frost
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
- chars: 100

```
#showtooltip
# class-specific MAGE frost
/cast [nomod]Cone of Cold; [mod:shift] Cone of Cold(rank 1)
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
- chars: 218

```
#showtooltip
# class-specific MAGE fire
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
- chars: 59

```
#showtooltip Scorch
# class-specific MAGE fire
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
- chars: 88

```
#showtooltip Pyroblast
# class-specific MAGE fire
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
- chars: 85

```
#showtooltip
# character-specific MAGE all Currentz
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
- chars: 116
- notes: Mouseover stays commented, as on disk.

```
#showtooltip
# class-specific MAGE all
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
- chars: 124

```
#showtooltip Counterspell
# class-specific MAGE all
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
- chars: 90

```
#showtooltip
# class-specific MAGE all
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
- chars: 136

```
#showtooltip Remove Lesser Curse
# class-specific MAGE all
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
- chars: 101

```
#showtooltip Ice block
# class-specific MAGE frost
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
- chars: 69

```
#showtooltip
# class-specific MAGE all
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
- chars: 124

```
#showtooltip Frost Nova
# class-specific MAGE frost | key (V / ALT-SHIFT-Q)
/cast [mod:shift] Frost Nova;Frost Nova (rank 1)
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
- chars: 70

```
#showtooltip Ice Barrier
# class-specific MAGE frost
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
- chars: 128

```
#showtooltip [mod:shift] Fire Ward; Frost Ward
# class-specific MAGE all | key (BUTTON3)
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
- chars: 74

```
#showtooltip Slow Fall
# class-specific MAGE all | key (8)
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
- chars: 84

```
#showtooltip
# class-specific MAGE all
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
- chars: 66

```
#showtooltip Cold Snap
# class-specific MAGE frost
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
- chars: 80

```
# class-specific MAGE fire
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
- chars: 104

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind;
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
- chars: 104

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge;
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
- chars: 104

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus;
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
- chars: 91

```
# class-specific MAGE all
/cast [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar;
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
- chars: 91

```
# class-specific MAGE all
/cast [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity;
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
- chars: 99

```
# class-specific MAGE all
/cast [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff;
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
- chars: 88

```
#showtooltip Judgement
# class-specific PALADIN retribution
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
- chars: 106

```
#showtooltip
# class-specific PALADIN retribution
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
- chars: 96

```
#showtooltip Hammer of Justice
# class-specific PALADIN all
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
- chars: 94

```
#showtooltip
# class-specific PALADIN all
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
- chars: 79

```
#showtooltip Hammer of Wrath
# class-specific PALADIN all
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
- chars: 73

```
#showtooltip Exorcism
# class-specific PALADIN retribution
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
- chars: 90

```
#showtooltip Repentance
# class-specific PALADIN retribution
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
- chars: 75

```
#showtooltip Divine Shield
# class-specific PALADIN all
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
- chars: 54

```
# class-specific PALADIN all
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
- chars: 93

```
#showtooltip Blessing of Protection
# class-specific PALADIN all
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
- chars: 131

```
#showtooltip Cleanse
# class-specific PALADIN all
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
- chars: 174

```
#showtooltip
# class-specific PALADIN holy
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
- chars: 131

```
#showtooltip
# class-specific PALADIN all
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
- chars: 122

```
#showtooltip
# class-specific PALADIN all
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
- chars: 84

```
#showtooltip Righteous Fury
# class-specific PALADIN protection
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
- chars: 78

```
#showtooltip Holy Shield
# class-specific PALADIN protection
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
- chars: 99

```
#showtooltip Lay on Hands
# class-specific PALADIN holy
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
- chars: 102

```
#showtooltip Divine Intervention
# class-specific PALADIN all
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
- chars: 127

```
#showtooltip
# class-specific PALADIN holy
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
- chars: 97

```
#showtooltip Flash of Light
# class-specific PALADIN holy
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
- chars: 70

```
#showtooltip Holy Shock
# class-specific PALADIN holy
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
- chars: 90

```
#showtooltip
# class-specific PALADIN holy
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
- chars: 91

```
#showtooltip
# class-specific PALADIN all
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
- chars: 74

```
#showtooltip Hunter's Mark
# class-specific HUNTER all
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
- chars: 99

```
#showtooltip
# class-specific HUNTER all
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
- chars: 77

```
#showtooltip Aimed Shot
# class-specific HUNTER marksmanship
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
- chars: 77

```
#showtooltip Multi-Shot
# class-specific HUNTER marksmanship
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
- chars: 91

```
#showtooltip
# class-specific HUNTER all
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
- chars: 74

```
#showtooltip Serpent Sting
# class-specific HUNTER all
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
- chars: 78

```
#showtooltip Concussive Shot
# class-specific HUNTER all
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
- chars: 87

```
#showtooltip
# class-specific HUNTER all
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
- chars: 95

```
#showtooltip Feign Death
# class-specific HUNTER all
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
- chars: 74

```
#showtooltip Freezing Trap
# class-specific HUNTER all
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
- chars: 85

```
#showtooltip Rapid Fire
# class-specific HUNTER marksmanship
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
- chars: 84

```
#showtooltip Tranquilizing Shot
# class-specific HUNTER all
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
- chars: 74

```
#showtooltip Mend Pet
# class-specific HUNTER beast-mastery
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
- chars: 74

```
#showtooltip Call Pet
# class-specific HUNTER beast-mastery
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
- chars: 84

```
#showtooltip Bestial Wrath
# class-specific HUNTER beast-mastery
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
- chars: 90

```
#showtooltip Aspect of the Cheetah
# class-specific HUNTER all
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
- chars: 93

```
#showtooltip
# character-specific HUNTER beast-mastery Auden
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
- chars: 61

```
#showtooltip Stealth
# class-specific ROGUE all
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
- chars: 93

```
#showtooltip Sinister Strike
# class-specific ROGUE combat
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
- chars: 68

```
#showtooltip Kick
# class-specific ROGUE all
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
- chars: 67

```
#showtooltip Eviscerate
# class-specific ROGUE all
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
- chars: 78

```
#showtooltip Slice and Dice
# class-specific ROGUE combat
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
- chars: 71

```
#showtooltip Rupture
# class-specific ROGUE assassination
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
- chars: 79

```
#showtooltip Kidney Shot
# class-specific ROGUE assassination
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
- chars: 72

```
#showtooltip Gouge
# class-specific ROGUE combat
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
- chars: 93

```
#showtooltip Cheap Shot
# class-specific ROGUE all
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
- chars: 95

```
#showtooltip Ambush
# class-specific ROGUE assassination
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
- chars: 82

```
#showtooltip Blade Flurry
# class-specific ROGUE combat
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
- chars: 80

```
#showtooltip Adrenaline Rush
# class-specific ROGUE combat
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
- chars: 64

```
#showtooltip Evasion
# class-specific ROGUE combat
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
- chars: 76

```
#showtooltip Vanish
# class-specific ROGUE subtlety
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
- chars: 59

```
#showtooltip Sprint
# class-specific ROGUE all
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
- chars: 57

```
#showtooltip Blind
# class-specific ROGUE all
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
- chars: 100

```
#showtooltip
# class-specific ROGUE all
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
- chars: 94

```
#showtooltip Eviscerate
# class-specific ROGUE assassination
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
- chars: 157

```
#showtooltip
# class-specific PRIEST holy
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
- chars: 132

```
#showtooltip
# class-specific PRIEST holy
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
- chars: 111

```
#showtooltip
# class-specific PRIEST holy
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
- chars: 156

```
#showtooltip
# class-specific PRIEST discipline
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
- chars: 101

```
#showtooltip Prayer of Healing
# class-specific PRIEST holy
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
- chars: 157

```
#showtooltip Dispel Magic
# class-specific PRIEST discipline
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
- chars: 56

```
#showtooltip Fade
# class-specific PRIEST all
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
- chars: 79

```
#showtooltip Psychic Scream
# class-specific PRIEST shadow
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
- chars: 130

```
#showtooltip Fear Ward
# class-specific PRIEST discipline
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
- chars: 144

```
#showtooltip Power Word: Fortitude
# class-specific PRIEST discipline
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
- chars: 73

```
#showtooltip Resurrection
# class-specific PRIEST holy
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
- chars: 75

```
#showtooltip Inner Fire
# class-specific PRIEST discipline
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
- chars: 88

```
#showtooltip
# class-specific PRIEST holy
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
- chars: 58

```
#showtooltip Shoot
# class-specific PRIEST all
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
- chars: 163

```
#showtooltip Abolish Disease
# class-specific PRIEST holy
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
- chars: 93

```
#showtooltip Prayer of Fortitude
# class-specific PRIEST discipline
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
- chars: 87

```
#showtooltip Prayer of Spirit
# class-specific PRIEST discipline
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
- chars: 106

```
#showtooltip
# class-specific PRIEST shadow
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
- chars: 69

```
#showtooltip Mind Flay
# class-specific PRIEST shadow
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
- chars: 71

```
#showtooltip Mind Blast
# class-specific PRIEST shadow
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
- chars: 83

```
#showtooltip Vampiric Embrace
# class-specific PRIEST shadow
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
- chars: 71

```
#showtooltip Shadowform
# class-specific PRIEST shadow
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
- chars: 78

```
#showtooltip Silence
# class-specific PRIEST shadow
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
- chars: 92

```
#showtooltip Shackle Undead
# class-specific PRIEST shadow
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
- chars: 130

```
#showtooltip Flash Heal
# class-specific PRIEST shadow
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
- chars: 116

```
#showtooltip Earth Shock
# class-specific SHAMAN all
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
- chars: 91

```
#showtooltip
# class-specific SHAMAN enhancement
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
- chars: 91

```
#showtooltip Stormstrike
# class-specific SHAMAN enhancement
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
- chars: 103

```
#showtooltip
# class-specific SHAMAN elemental
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
- chars: 84

```
#showtooltip Chain Lightning
# class-specific SHAMAN elemental
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
- chars: 80

```
#showtooltip Lightning Shield
# class-specific SHAMAN all
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
- chars: 102

```
#showtooltip
# class-specific SHAMAN enhancement
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
- chars: 200

```
#showtooltip
# class-specific SHAMAN restoration
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
- chars: 139

```
#showtooltip
# class-specific SHAMAN restoration
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
- chars: 105

```
#showtooltip Healing Wave
# class-specific SHAMAN restoration
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
- chars: 97

```
#showtooltip Purge
# class-specific SHAMAN elemental
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
- chars: 68

```
#showtooltip Ghost Wolf
# class-specific SHAMAN all
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
- chars: 90

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 72

```
#showtooltip Tremor Totem
# class-specific SHAMAN all
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
- chars: 82

```
#showtooltip Mana Spring Totem
# class-specific SHAMAN all
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
- chars: 102

```
#showtooltip Strength of Earth Totem
# class-specific SHAMAN enhancement
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
- chars: 86

```
#showtooltip Mana Tide Totem
# class-specific SHAMAN restoration
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
- chars: 154

```
#showtooltip Cure Poison
# class-specific SHAMAN restoration
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
- chars: 86

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 100

```
#showtooltip
# class-specific WARLOCK destruction
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
- chars: 73

```
#showtooltip Immolate
# class-specific WARLOCK destruction
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
- chars: 97

```
#showtooltip
# class-specific WARLOCK affliction
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
- chars: 104

```
#showtooltip
# class-specific WARLOCK affliction
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
- chars: 98

```
#showtooltip
# class-specific WARLOCK affliction
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
- chars: 89

```
#showtooltip Spell Lock
# class-specific WARLOCK demonology
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
- chars: 96

```
# class-specific WARLOCK all
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
- chars: 100

```
#showtooltip Major Soulstone
# class-specific WARLOCK all
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
- chars: 74

```
#showtooltip Sacrifice
# class-specific WARLOCK demonology
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
- chars: 81

```
#showtooltip Banish
# class-specific WARLOCK demonology
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
- chars: 76

```
#showtooltip Death Coil
# class-specific WARLOCK affliction
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
- chars: 100

```
#showtooltip
# class-specific WARLOCK demonology
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
- chars: 71

```
#showtooltip Demon Armor
# class-specific WARLOCK all
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
- chars: 97

```
#showtooltip
# class-specific WARLOCK affliction
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
- chars: 77

```
#showtooltip Shadowburn
# class-specific WARLOCK destruction
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
- chars: 59

```
#showtooltip Shoot
# class-specific WARLOCK all
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
- chars: 72

```
#showtooltip Shred
# class-specific DRUID feral
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
- chars: 98

```
#showtooltip
# class-specific DRUID feral
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
- chars: 55

```
#showtooltip Rip
# class-specific DRUID feral
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
- chars: 70

```
#showtooltip Rake
# class-specific DRUID feral
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
- chars: 85

```
#showtooltip Prowl
# class-specific DRUID feral
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
- chars: 70

```
#showtooltip Maul
# class-specific DRUID feral
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
- chars: 91

```
#showtooltip Growl
# class-specific DRUID feral
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
- chars: 70

```
#showtooltip Bash
# class-specific DRUID feral
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
- chars: 89

```
#showtooltip
# class-specific DRUID all
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
- chars: 73

```
#showtooltip Feral Charge
# class-specific DRUID feral
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
- chars: 91

```
#showtooltip Frenzied Regeneration
# class-specific DRUID feral
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
- chars: 57

```
#showtooltip Dash
# class-specific DRUID feral
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
- chars: 81

```
#showtooltip
# class-specific DRUID feral
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
- chars: 77

```
#showtooltip Dire Bear Form
# class-specific DRUID feral
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
- chars: 187

```
#showtooltip
# class-specific DRUID restoration
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
- chars: 142

```
#showtooltip Innervate
# class-specific DRUID restoration
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
- chars: 113

```
#showtooltip Rebirth
# class-specific DRUID restoration
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
- chars: 141

```
#showtooltip Mark of the Wild
# class-specific DRUID restoration
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
- chars: 88

```
#showtooltip
# class-specific DRUID balance
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
- chars: 61

```
#showtooltip Wrath
# class-specific DRUID balance
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
- chars: 67

```
#showtooltip Starfire
# class-specific DRUID balance
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
- chars: 75

```
#showtooltip Moonkin Form
# class-specific DRUID balance
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
- chars: 116

```
#showtooltip
# class-specific DRUID balance
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
- chars: 150

```
#showtooltip
# class-specific DRUID restoration
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
- chars: 85

```
#showtooltip Swiftmend
# class-specific DRUID restoration
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
- chars: 118

```
#showtooltip Healing Touch
# class-specific DRUID restoration
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
- chars: 114
- version: TBC
- notes: Draenei heal. Alt self.

```
#showtooltip Gift of the Naaru
# global ALL all
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
- chars: 78
- version: TBC
- notes: Blood Elf interrupt. Stops a queued spell first.

```
#showtooltip Arcane Torrent
# global ALL all
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
- chars: 94
- version: TBC
- notes: Health shout. Battle Shout stays on `w-shout`.

```
#showtooltip Commanding Shout
# class-specific WARRIOR all
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
- chars: 136
- version: TBC
- notes: Enters Defensive Stance. Uses a friendly living mouseover, then the current target.

```
#showtooltip Intervene
# class-specific WARRIOR all
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
- chars: 130
- version: TBC
- notes: Requires an equipped shield. Enters Defensive Stance.

```
#showtooltip Spell Reflection
# class-specific WARRIOR all
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
- chars: 117
- version: TBC
- notes: Leaves Defensive Stance. Usable after a killing blow.

```
#showtooltip Victory Rush
# class-specific WARRIOR all
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
- chars: 100
- version: TBC

```
#showtooltip Crusader Strike
# class-specific PALADIN retribution
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
- chars: 85
- version: TBC

```
#showtooltip Avenging Wrath
# class-specific PALADIN all
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
- chars: 116
- version: TBC
- notes: Taunt the mobs on a friendly mouseover, then the current target.

```
#showtooltip Righteous Defense
# class-specific PALADIN all
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
- chars: 101
- version: TBC

```
#showtooltip Avenger's Shield
# class-specific PALADIN protection
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
- chars: 143
- version: TBC
- notes: Horde Blood / Martyr. Alliance Vengeance / Corruption. First learned seal wins.

```
#showtooltip
# class-specific PALADIN retribution
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
- chars: 80
- version: TBC

```
#showtooltip Turn Evil
# class-specific PALADIN all
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
- chars: 75
- version: TBC

```
#showtooltip Crusader Aura
# class-specific PALADIN all
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
- chars: 70
- version: TBC

```
#showtooltip Steady Shot
# class-specific HUNTER all
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
- chars: 93
- version: TBC

```
#showtooltip Kill Command
# class-specific HUNTER beast-mastery
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
- chars: 151
- version: TBC
- notes: Friendly mouseover, then pet, then current target.

```
#showtooltip Misdirection
# class-specific HUNTER all
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
- chars: 68
- version: TBC

```
#showtooltip Snake Trap
# class-specific HUNTER all
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
- chars: 131
- version: TBC
- notes: Hawk normally. Shift is Viper. Ctrl is Monkey. Era `asp` has no Viper line.

```
#showtooltip
# class-specific HUNTER all
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
- chars: 92
- version: TBC

```
#showtooltip Cloak of Shadows
# class-specific ROGUE all
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
- chars: 71
- version: TBC

```
#showtooltip Deadly Throw
# class-specific ROGUE all
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
- chars: 68
- version: TBC

```
#showtooltip Shiv
# class-specific ROGUE all
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
- chars: 71
- version: TBC

```
#showtooltip Envenom
# class-specific ROGUE assassination
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
- chars: 72
- version: TBC

```
#showtooltip Shadowstep
# class-specific ROGUE subtlety
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
- chars: 86
- version: TBC

```
#showtooltip Mutilate
# class-specific ROGUE assassination
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
- chars: 84
- version: TBC

```
#showtooltip Shadow Word: Death
# class-specific PRIEST all
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
- chars: 126
- version: TBC

```
#showtooltip Prayer of Mending
# class-specific PRIEST holy
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
- chars: 126
- version: TBC

```
#showtooltip Circle of Healing
# class-specific PRIEST holy
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
- chars: 158
- version: TBC

```
#showtooltip Pain Suppression
# class-specific PRIEST discipline
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
- chars: 83
- version: TBC

```
#showtooltip Mass Dispel
# class-specific PRIEST all
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
- chars: 70
- version: TBC

```
#showtooltip Shadowfiend
# class-specific PRIEST all
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
- chars: 73
- version: TBC

```
#showtooltip Binding Heal
# class-specific PRIEST holy
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
- chars: 79
- version: TBC

```
#showtooltip Vampiric Touch
# class-specific PRIEST shadow
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
- chars: 87
- version: TBC
- notes: Blood Elf priest racial.

```
#showtooltip Consume Magic
# class-specific PRIEST all
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
- chars: 77
- version: TBC
- notes: Dwarf and Draenei priest racial.

```
#showtooltip Chastise
# class-specific PRIEST all
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
- chars: 78
- version: TBC
- notes: Horde Bloodlust. Alliance Heroism. First learned spell wins.

```
#showtooltip
# class-specific SHAMAN enhancement
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
- chars: 89
- version: TBC

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 118
- version: TBC

```
#showtooltip Earth Shield
# class-specific SHAMAN restoration
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
- chars: 88
- version: TBC

```
#showtooltip Shamanistic Rage
# class-specific SHAMAN enhancement
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
- chars: 84
- version: TBC

```
#showtooltip Wrath of Air Totem
# class-specific SHAMAN all
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
- chars: 82
- version: TBC

```
#showtooltip Totem of Wrath
# class-specific SHAMAN elemental
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
- chars: 90
- version: TBC

```
#showtooltip Earth Elemental Totem
# class-specific SHAMAN all
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
- chars: 88
- version: TBC

```
#showtooltip Fire Elemental Totem
# class-specific SHAMAN all
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
- chars: 72
- version: TBC

```
#showtooltip Totemic Call
# class-specific SHAMAN all
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
- chars: 66
- version: TBC

```
#showtooltip Ice Lance
# class-specific MAGE frost
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
- chars: 79
- version: TBC

```
#showtooltip Spellsteal
# class-specific MAGE all
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
- chars: 83
- version: TBC

```
#showtooltip Invisibility
# class-specific MAGE all
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
- chars: 70
- version: TBC

```
#showtooltip Molten Armor
# class-specific MAGE all
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
- chars: 78
- version: TBC

```
#showtooltip Arcane Blast
# class-specific MAGE arcane
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
- chars: 57
- version: TBC

```
#showtooltip Slow
# class-specific MAGE arcane
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
- chars: 77
- version: TBC

```
#showtooltip Dragon's Breath
# class-specific MAGE fire
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
- chars: 92
- version: TBC

```
#showtooltip Summon Water Elemental
# class-specific MAGE frost
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
- chars: 88
- version: TBC

```
#showtooltip Ritual of Refreshment
# class-specific MAGE all
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
- chars: 86
- version: TBC

```
#showtooltip Conjure Mana Emerald
# class-specific MAGE all
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
- chars: 98
- version: TBC

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar;
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
- chars: 106
- version: TBC

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon;
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
- chars: 104
- version: TBC

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath;
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
- chars: 104
- version: TBC

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore;
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
- chars: 100
- version: TBC

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard;
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
- chars: 77
- version: TBC

```
#showtooltip Incinerate
# class-specific WARLOCK destruction
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
- chars: 82
- version: TBC

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 71
- version: TBC

```
#showtooltip Soulshatter
# class-specific WARLOCK all
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
- chars: 79
- version: TBC

```
#showtooltip Ritual of Souls
# class-specific WARLOCK all
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
- chars: 92
- version: TBC

```
#showtooltip Seed of Corruption
# class-specific WARLOCK affliction
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
- chars: 94
- version: TBC

```
#showtooltip Unstable Affliction
# class-specific WARLOCK affliction
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
- chars: 90
- version: TBC

```
#showtooltip Shadowfury
# class-specific WARLOCK destruction
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
- chars: 86
- version: TBC

```
#showtooltip Summon Felguard
# class-specific WARLOCK demonology
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
- chars: 97
- version: TBC

```
#showtooltip
# class-specific DRUID feral
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
- chars: 120
- version: TBC

```
#showtooltip Lifebloom
# class-specific DRUID restoration
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
- chars: 78
- version: TBC

```
#showtooltip Cyclone
# class-specific DRUID balance
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
- chars: 88
- version: TBC

```
#showtooltip
# class-specific DRUID all
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
- chars: 78
- version: TBC

```
#showtooltip Lacerate
# class-specific DRUID feral
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
- chars: 57
- version: TBC

```
#showtooltip Maim
# class-specific DRUID feral
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
- chars: 79
- version: TBC

```
#showtooltip Tree of Life
# class-specific DRUID restoration
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
- chars: 125

```
#showtooltip
# class-specific PALADIN all
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
- chars: 115

```
#showtooltip
# class-specific PALADIN all
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
- chars: 117

```
#showtooltip
# class-specific PALADIN all
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
- chars: 109

```
#showtooltip
# class-specific PALADIN all
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
- chars: 115

```
#showtooltip
# class-specific PALADIN all
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
- chars: 117

```
#showtooltip
# class-specific PALADIN all
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
- chars: 119

```
#showtooltip
# class-specific PALADIN all
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
- chars: 109

```
#showtooltip
# class-specific PALADIN all
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
- chars: 127

```
#showtooltip
# class-specific PALADIN all
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
- chars: 95

```
#showtooltip
# class-specific PALADIN all
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
- chars: 95

```
#showtooltip
# class-specific PALADIN all
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
- chars: 97

```
#showtooltip
# class-specific PALADIN all
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
- chars: 110

```
#showtooltip
# class-specific HUNTER all
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
- chars: 96

```
#showtooltip
# class-specific HUNTER all
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
- chars: 106

```
#showtooltip
# class-specific HUNTER all
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
- chars: 100

```
#showtooltip
# class-specific HUNTER all
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
- chars: 96

```
#showtooltip
# class-specific HUNTER all
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
- chars: 86

```
#showtooltip
# class-specific HUNTER all
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
- chars: 92

```
#showtooltip
# class-specific HUNTER all
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
- chars: 102

```
#showtooltip
# class-specific HUNTER all
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
- chars: 104

```
#showtooltip
# class-specific HUNTER all
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
- chars: 113

```
#showtooltip
# class-specific HUNTER all
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
- chars: 113

```
#showtooltip
# class-specific HUNTER all
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
- chars: 97

```
#showtooltip
# class-specific ROGUE all
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
- chars: 87

```
#showtooltip
# class-specific ROGUE all
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
- chars: 102

```
#showtooltip
# class-specific ROGUE all
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
- chars: 83

```
#showtooltip
# class-specific ROGUE all
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
- chars: 100

```
#showtooltip
# class-specific PRIEST all
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
- chars: 90

```
#showtooltip
# class-specific PRIEST all
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
- chars: 92

```
#showtooltip
# class-specific PRIEST all
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
- chars: 94

```
#showtooltip
# class-specific PRIEST all
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
- chars: 106

```
#showtooltip
# class-specific PRIEST all
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
- chars: 107

```
#showtooltip
# class-specific PRIEST all
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
- chars: 92

```
#showtooltip
# class-specific PRIEST all
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
- chars: 128

```
#showtooltip
# class-specific PRIEST all
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
- chars: 84

```
#showtooltip
# class-specific PRIEST all
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
- chars: 106

```
#showtooltip
# class-specific PRIEST all
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
- chars: 104

```
#showtooltip
# class-specific PRIEST all
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
- chars: 98

```
#showtooltip
# class-specific PRIEST all
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
- chars: 96

```
#showtooltip
# class-specific PRIEST all
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
- chars: 96

```
#showtooltip
# class-specific PRIEST all
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
- chars: 108

```
#showtooltip
# class-specific PRIEST all
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
- chars: 96

```
#showtooltip
# class-specific PRIEST all
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
- chars: 108

```
#showtooltip
# class-specific PRIEST all
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
- chars: 104

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 96

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 100

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 104

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 116

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 108

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 118

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 108

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 110

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 120

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 106

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 104

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 102

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 106

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 125

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 114

```
#showtooltip
# class-specific SHAMAN all
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
- chars: 82

```
#showtooltip
# class-specific MAGE all | key (ALT-SHIFT-3)
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
- chars: 71

```
#showtooltip
# class-specific MAGE all | key (ALT-6)
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
- chars: 58

```
#showtooltip
# class-specific MAGE all
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
- chars: 70

```
#showtooltip
# class-specific MAGE all | key (ALT-Q)
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
- chars: 75

```
#showtooltip
# class-specific MAGE all | key (ALT-SHIFT-1)
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
- chars: 117

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 105

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 107

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 109

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 95

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 95

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 103

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 95

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 101

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 97

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 105

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 91

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 99

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 99

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 93

```
#showtooltip
# class-specific WARLOCK all
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
- chars: 103

```
#showtooltip
# class-specific DRUID all
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
- chars: 91

```
#showtooltip
# class-specific DRUID all
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
- chars: 111

```
#showtooltip
# class-specific DRUID all
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
- chars: 97

```
#showtooltip
# class-specific DRUID all
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
- chars: 94

```
#showtooltip
# class-specific DRUID all
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
- chars: 83

```
#showtooltip
# class-specific DRUID all
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
- chars: 107

```
#showtooltip
# class-specific DRUID all
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
- chars: 85

```
#showtooltip
# class-specific DRUID all
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
- chars: 85

```
#showtooltip
# class-specific DRUID all
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
- chars: 96

```
#showtooltip
# class-specific DRUID all
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
- chars: 97

```
#showtooltip
# class-specific DRUID all
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
- chars: 117

```
#showtooltip
# class-specific DRUID all
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
- chars: 130

```
#showtooltip
# class-specific DRUID all
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
- chars: 107

```
#showtooltip
# class-specific DRUID all
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
- chars: 96
- notes: Imported from in-game macros-cache.txt.

```
#showtooltip Battle Shout
# class-specific WARRIOR all | key (B)
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

