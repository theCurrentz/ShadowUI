# Mage

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

Existing Currentz style: `/cqs`, `[nomod]` max rank, `[mod:shift]` Rank 1, `@cursor` ground spells, Ice Block toggle.
TBC adds Outland city ports plus Theramore and Stonard. Shift still opens a portal.

## Mage control — class-specific

Kicks, sheep, block, decurse. Existing bodies win.

### CS — `m-cs`

Mouseover stays commented, as on disk.

```
#showtooltip
# class-specific MAGE all
/stopcasting
#/cast [target=mouseover,exists] Counterspell
/cast Counterspell
```

### CSf — `m-cs-focus`

```
#showtooltip Counterspell
# class-specific MAGE all
/stopcasting
/cast [target=focus,harm,nodead] Counterspell; Counterspell
```

### sheep — `m-sheep`

```
#showtooltip
# class-specific MAGE all
/cast [nomod]Polymorph;[mod:shift]Polymorph(rank 1)
```

### decurse — `m-decurse`

```
#showtooltip Remove Lesser Curse
# class-specific MAGE all
/cast [target=mouseover,exists] Remove Lesser Curse
/cast Remove Lesser Curse
```

### ib — `m-ib`

```
#showtooltip Ice block
# class-specific MAGE frost
/stopcasting
/cast Ice block
/cancelaura Ice block
```

### MS — `m-ms`

```
#showtooltip
# class-specific MAGE all
/stopcasting
/cast mana shield
```

### fn — `m-nova`

```
#showtooltip Frost Nova
# class-specific MAGE frost | key (V / ALT-SHIFT-Q)
/cast [mod:shift] Frost Nova;Frost Nova (rank 1)
```

### iba — `m-barrier`

```
#showtooltip Ice Barrier
# class-specific MAGE frost
/cast Ice Barrier
```

### ward — `m-ward`

```
#showtooltip [mod:shift] Fire Ward; Frost Ward
# class-specific MAGE all | key (BUTTON3)
/cast [mod:shift] Fire Ward; Frost Ward
```

### slowfall — `m-slowfall`

```
#showtooltip Slow Fall
# class-specific MAGE all | key (8)
/cast Slow Fall
```

### dm — `m-dampen`

```
#showtooltip
# class-specific MAGE all
/cast [mod:shift] Amplify Magic; Dampen Magic
```

### snap — `m-csnap`

```
#showtooltip Cold Snap
# class-specific MAGE frost
/cast Cold Snap
```

### nef — `m-nef`

```
# class-specific MAGE fire
/use [@cursor] Stratholme Holy Water
/cast Blast Wave
```

## Mage filler — class-specific

Existing Currentz fillers. /cqs and [nomod]/[mod:shift] downranks stay.

### f — `m-fb`

```
#showtooltip
# class-specific MAGE frost
/cqs
/cast [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)
```

### fb — `m-fireball`

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

### ' — `m-blast`

```
#showtooltip
# class-specific MAGE fire
/cast [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)
```

### ae — `m-ae`

```
#showtooltip
# class-specific MAGE arcane
/cast [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)
```

### am — `m-am`

```
#showtooltip Arcane Missiles
# class-specific MAGE arcane
/cast [nochanneling:Arcane Missiles] Arcane Missiles
```

### Blizz — `m-blizz`

```
#showtooltip
# class-specific MAGE frost
/cast [nomod]Blizzard;[mod:shift]Blizzard(rank 1)
```

### cone — `m-cone`

```
#showtooltip
# class-specific MAGE frost
/cast [nomod]Cone of Cold; [mod:shift] Cone of Cold(rank 1)
```

### fs — `m-fs`

```
#showtooltip
# class-specific MAGE fire
/use [mod:alt] Talisman of Ephemeral Power
/use [mod:alt] Zandalarian Hero Charm
/cast [mod:alt] Arcane Power
/cast [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike
```

### sc — `m-scorch`

```
#showtooltip Scorch
# class-specific MAGE fire
/cast Scorch
```

### py — `m-pyro`

```
#showtooltip Pyroblast
# class-specific MAGE fire
/cast Presence of Mind
/cast Pyroblast
```

## Mage ports Alliance — class-specific

Existing Currentz IF/SW plus Darnassus from the plan. Shift = portal.

### portsw — `m-sw`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind;
```

### if — `m-if`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge;
```

### dar — `m-dar`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus;
```

## Mage ports Horde — class-specific

Existing WARKEYS Orgrimmar / Undercity / Thunder Bluff.

### org — `m-org`

```
# class-specific MAGE all
/cast [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar;
```

### uc — `m-uc`

```
# class-specific MAGE all
/cast [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity;
```

### tb — `m-tb`

```
# class-specific MAGE all
/cast [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff;
```

## Mage ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### ai — `m-ai`

```
#showtooltip
# class-specific MAGE all | key (ALT-SHIFT-3)
/cast Arcane Intellect;
```

### cf — `m-cf`

```
#showtooltip
# class-specific MAGE all | key (ALT-6)
/cast Conjure Food
```

### cw — `m-cw`

```
#showtooltip
# class-specific MAGE all
/cast Conjure Water
```

### ma — `m-ma`

```
#showtooltip
# class-specific MAGE all | key (ALT-Q)
/cast Mage Armor;
```

### ia — `m-ia`

```
#showtooltip
# class-specific MAGE all | key (ALT-SHIFT-1)
/cast Ice Armor;
```

## Mage TBC — class-specific — TBC

TBC trainer and talent buttons plus Outland ports. Shift still opens a portal on the city macros. Ice Block stays in Mage control.

### ilance — `m-ilance`

```
#showtooltip Ice Lance
# class-specific MAGE frost
/cast Ice Lance
```

### steal — `m-steal`

```
#showtooltip Spellsteal
# class-specific MAGE all
/stopcasting
/cast Spellsteal
```

### invis — `m-invis`

```
#showtooltip Invisibility
# class-specific MAGE all
/stopcasting
/cast Invisibility
```

### molten — `m-molten`

```
#showtooltip Molten Armor
# class-specific MAGE all
/cast Molten Armor
```

### ablast — `m-ablast`

```
#showtooltip Arcane Blast
# class-specific MAGE arcane
/cqs
/cast Arcane Blast
```

### mslow — `m-slow`

```
#showtooltip Slow
# class-specific MAGE arcane
/cast Slow
```

### dbreath — `m-dbreath`

```
#showtooltip Dragon's Breath
# class-specific MAGE fire
/cast Dragon's Breath
```

### welem — `m-welem`

```
#showtooltip Summon Water Elemental
# class-specific MAGE frost
/cast Summon Water Elemental
```

### mtable — `m-table`

```
#showtooltip Ritual of Refreshment
# class-specific MAGE all
/cast Ritual of Refreshment
```

### gemtbc — `m-gemtbc`

```
#showtooltip Conjure Mana Emerald
# class-specific MAGE all
/cast Conjure Mana Emerald
```

### exodar — `m-exodar`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar;
```

### slvr — `m-slvr`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon;
```

### shat — `m-shat`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath;
```

### thera — `m-thera`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore;
```

### stonard — `m-stonard`

```
#showtooltip
# class-specific MAGE all
/cast [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard;
```

## Currentz kit — character-specific Currentz

Character-specific Currentz. Touch of Chaos wand and named Naxx shells. Generic Shoot stays in mage-filler.

### shadow — `m-wand`

```
#showtooltip
# character-specific MAGE all Currentz
/equip Touch of Chaos
/cast shoot
```
