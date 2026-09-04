# Warrior

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

**Stances:** `1` Battle, `2` Defensive, `3` Berserker.

Warrior core contains useful macros for non-talent abilities. Arms, Fury, and Protection contain only useful wrappers for abilities unlocked by that talent tree.
Piercing Howl needs no macro logic, so drag the spell itself to an unmanaged slot.
For Fury, load Warrior core + Warrior Fury. For Fury/Protection, add Last Stand separately if learned; do not add Concussion Blow or Shield Slam unless the build unlocks them.

Catalog bodies stay stance-aware. On a matching stance page, the stance line is a no-op.
Charge / Intercept share `E`; Shield Bash / Pummel share `F`; the three major stance cooldowns share `Z`.
A stance change can require a second key press after the stance cooldown. Shield Slam and Shield Wall require an equipped shield.
On TBC, load Warrior TBC for Commanding Shout, Intervene, Spell Reflection, and Victory Rush. Slam is in Warrior core on that Version.

## Warrior core — class-specific

Useful macros for non-talent Warrior abilities. Load this complete set on the General tab; named gear swaps stay character-specific.

### charge — `w-charge`

Enters Battle for Charge or Berserker for Intercept. Do not add Rend.

```
#showtooltip [combat] Intercept; Charge
/cast [nocombat,nostance:1] Battle Stance; [combat,nostance:3] Berserker Stance
/cast [nocombat] Charge; Intercept
/startattack
```

### brage — `w-bloodrage`

Bloodrage stays separate from Berserker Rage.

```
#showtooltip Bloodrage
/cast Bloodrage
/startattack
```

### br — `w-br`

```
#showtooltip Berserker Rage
/cast [nostance:3] Berserker Stance
/cast Berserker Rage
```

### b — `w-b`

```
#showtooltip Battle Stance
/cast Battle Stance
/startattack
```

### bs — `w-bs`

```
#showtooltip Berserker Stance
/cast Berserker Stance
/startattack
```

### d — `w-d-def`

```
#showtooltip Defensive Stance
/cast Defensive Stance
/startattack
```

### h — `w-h`

Uses maximum rank. Rank 3 has the same listed rage cost and is not a rage-saving option.

```
#showtooltip Heroic Strike
/cast Heroic Strike
/startattack
```

### c — `w-c`

```
#showtooltip Cleave
/cast Cleave
/startattack
```

### ww — `w-ww`

Enters Berserker Stance. A stance change can require a second press.

```
#showtooltip Whirlwind
/cast [nostance:3] Berserker Stance
/cast Whirlwind
/startattack
```

### ex — `w-ex`

Leaves Defensive Stance because Execute requires Battle or Berserker Stance.

```
#showtooltip Execute
/cast [stance:2] Battle Stance
/cast Execute
/startattack
```

### o — `w-o`

Enters Battle Stance. A stance change can require a second press.

```
#showtooltip Overpower
/cast [nostance:1] Battle Stance
/cast Overpower
/startattack
```

### rend — `w-rend`

Leaves Berserker Stance because Rend requires Battle or Defensive Stance.

```
#showtooltip Rend
/cast [stance:3] Battle Stance
/cast Rend
/startattack
```

### s — `w-s`

Uses a hostile living mouseover, then the current target. Useful for multi-target tanking.

```
#showtooltip Sunder Armor
/startattack
/cast [target=mouseover,harm,nodead][] Sunder Armor
```

### sl — `w-slam`

Trainer-taught filler. TBC uses it on the baseline bar. Leaves Defensive Stance.

```
#showtooltip Slam
/cast [stance:2] Battle Stance
/startattack
/cast Slam
```

### wkick — `w-interrupt`

One interrupt replaces separate Pummel and Shield Bash copies. It uses Shield Bash with a shield; otherwise it enters Berserker and uses Pummel.

```
#showtooltip [stance:3] Pummel; [equipped:Shields] Shield Bash; Pummel
/stopcasting
/startattack
/cast [noequipped:Shields,nostance:3] Berserker Stance
/cast [stance:3] Pummel; [equipped:Shields] Shield Bash
```

### major — `w-major-cd`

One major cooldown key. The current stance selects the spell.

```
#showtooltip
/cast [stance:1] Retaliation; [stance:2] Shield Wall; Recklessness
```

### a — `w-taunt`

Uses a hostile living mouseover, then the current target.

```
#showtooltip Taunt
/cast [nostance:2] Defensive Stance
/cast [target=mouseover,harm,nodead][] Taunt
```

### bshout — `w-shout`

Battle Shout normally. Shift uses Demoralizing Shout.

```
#showtooltip [mod:shift] Demoralizing Shout; Battle Shout
/cast [mod:shift] Demoralizing Shout; Battle Shout
```

### ds — `w-ds`

Dedicated Demoralizing Shout copy; `w-shout` also provides Demoralizing Shout on Shift.

```
#showtooltip Demoralizing Shout
/cast Demoralizing Shout
/startattack
```

### hm — `w-hm`

Leaves Defensive Stance because Hamstring requires Battle or Berserker Stance.

```
#showtooltip Hamstring
/cast [stance:2] Battle Stance
/cast Hamstring
/startattack
```

### disarm — `w-disarm`

```
#showtooltip Disarm
/startattack
/cast [nostance:2] Defensive Stance
/cast Disarm
```

### is — `w-intimid`

Stops auto-attack so the primary target is not hit immediately after the fear.

```
#showtooltip Intimidating Shout
/cast Intimidating Shout
/stopattack
```

### rev — `w-revenge`

```
#showtooltip Revenge
/cast [nostance:2] Defensive Stance
/cast Revenge
/startattack
```

### sbk — `w-sblock`

```
#showtooltip Shield Block
/cast [nostance:2] Defensive Stance
/cast Shield Block
```

### mb — `w-mock`

Uses a hostile living mouseover, then the current target.

```
#showtooltip Mocking Blow
/cast [nostance:1] Battle Stance
/cast [target=mouseover,harm,nodead][] Mocking Blow
```

### ch — `w-chall`

```
#showtooltip Challenging Shout
/cast Challenging Shout
/startattack
```

### tc — `w-tc`

```
#showtooltip Thunder Clap
/cast [nostance:1] Battle Stance
/cast Thunder Clap
```

### ret — `w-retal`

```
#showtooltip Retaliation
/cast [nostance:1] Battle Stance
/cast Retaliation
```

### rk — `w-reck`

```
#showtooltip Recklessness
/cast [nostance:3] Berserker Stance
/cast Recklessness
```

### sw — `w-sw`

Requires an equipped shield. Named equip copies stay in the gear kit.

```
#showtooltip Shield Wall
/cast [nostance:2] Defensive Stance
/cast Shield Wall
```

## Warrior Arms — class-specific

Only active abilities unlocked by Arms talents.

### ss — `w-sweep`

```
#showtooltip Sweeping Strikes
/cast [nostance:1] Battle Stance
/cast Sweeping Strikes
```

### ms — `w-ms`

```
#showtooltip Mortal Strike
/cast Mortal Strike
/startattack
```

## Warrior Fury — class-specific

Useful macros for Fury talent abilities. Piercing Howl needs no wrapper; drag the spell itself to an unmanaged slot.

### dwish — `w-deathwish`

```
#showtooltip Death Wish
/cast Death Wish
/startattack
```

### bt — `w-bt`

```
#showtooltip Bloodthirst
/cast Bloodthirst
/startattack
```

## Warrior Protection — class-specific

Only active abilities unlocked by Protection talents. A Fury/Protection build usually adds only Last Stand; Concussion Blow and Shield Slam require deeper Protection talents.

### ls — `w-ls`

Stops a cast or queued spell so the emergency defensive can fire immediately.

```
#showtooltip Last Stand
/stopcasting
/cast Last Stand
```

## Warrior TBC — class-specific — TBC

TBC trainer abilities. Slam sits in Warrior core on TBC. Stance Mastery is passive.

### cshout — `w-cshout`

Health shout. Battle Shout stays on `w-shout`.

```
#showtooltip Commanding Shout
/cast Commanding Shout
/startattack
```

### interv — `w-intervene`

Enters Defensive Stance. Uses a friendly living mouseover, then the current target.

```
#showtooltip Intervene
/cast [nostance:2] Defensive Stance
/cast [target=mouseover,help,nodead][] Intervene
```

### reflect — `w-reflect`

Requires an equipped shield. Enters Defensive Stance.

```
#showtooltip Spell Reflection
/stopcasting
/cast [nostance:2] Defensive Stance
/cast Spell Reflection
```

### vrush — `w-vrush`

Leaves Defensive Stance. Usable after a killing blow.

```
#showtooltip Victory Rush
/cast [stance:2] Battle Stance
/cast Victory Rush
/startattack
```

## Tazzy gear kit — character-specific Tazzy

Character-specific Nightslayer Tazzy cooldown and equipment macros. Swap this group when the gear kit changes.

### dfdw — `w-dfdw`

Uses Diamond Flask, then Death Wish. The flask can consume the first press; press again after the global cooldown.

```
/use Diamond Flask
/cast Death Wish
```

### dual — `w-dual`

Cancels a queued attack, then equips the dual-wield threat set.

```
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 Mirah's Song
```

### shqs — `w-sh-qs`

Cancels a queued attack, then equips the alternate shield set. The one-handed weapon goes on before the shield.

```
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 Buru's Skull Fragment
```

### shh — `w-shh`

Cancels a queued attack, then equips the mitigation shield set.

```
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 The Immovable Object
```

### sd — `w-sd-item`

Cancels a queued attack, equips the mitigation set, enters Defensive Stance, then uses Shield Wall. Combat swaps can require repeated presses.

```
#showtooltip Shield Wall
/stopcasting
/equipslot 16 Quel'Serrar
/equipslot 17 The Immovable Object
/cast [nostance:2] Defensive Stance
/cast Shield Wall
```

## Warrior other — class-specific

In-game macros with no catalog group. Auto-heal keeps them for Export.

### shout — `ingame-other-WARRIOR-shout`

Imported from in-game macros-cache.txt.

```
#showtooltip Battle Shout
/cast Battle Shout
/startattack
```
