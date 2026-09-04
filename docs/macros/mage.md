# Mage

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

Existing Currentz style: `/cqs`, `[nomod]` max rank, `[mod:shift]` Rank 1, `#showtooltip` copies those conditions, `(rank 1)` has no space, `@cursor` ground spells, Ice Block toggle.
TBC adds Outland city ports plus Theramore and Stonard. Shift still opens a portal.

## Mage control — class-specific

Kicks, sheep, block, decurse. Existing bodies win.

### CS — `m-cs`

Mouseover stays commented, as on disk.

```
#showtooltip
/stopcasting
#/cast [target=mouseover,exists] Counterspell
/cast Counterspell
```

### CSf — `m-cs-focus`

```
#showtooltip Counterspell
/stopcasting
/cast [target=focus,harm,nodead] Counterspell; Counterspell
```

### sheep — `m-sheep`

```
#showtooltip [nomod]Polymorph;[mod:shift]Polymorph(rank 1)
/cast [nomod]Polymorph;[mod:shift]Polymorph(rank 1)
```

### decurse — `m-decurse`

```
#showtooltip Remove Lesser Curse
/cast [target=mouseover,exists] Remove Lesser Curse
/cast Remove Lesser Curse
```

### ib — `m-ib`

```
#showtooltip Ice block
/stopcasting
/cast Ice block
/cancelaura Ice block
```

### MS — `m-ms`

```
#showtooltip
/stopcasting
/cast mana shield
```

### fn — `m-nova`

```
#showtooltip [mod:shift] Frost Nova; Frost Nova(rank 1)
/cast [mod:shift] Frost Nova; Frost Nova(rank 1)
```

### iba — `m-barrier`

```
#showtooltip Ice Barrier
/cast Ice Barrier
```

### ward — `m-ward`

```
#showtooltip [mod:shift] Fire Ward; Frost Ward
/cast [mod:shift] Fire Ward; Frost Ward
```

### slowfall — `m-slowfall`

```
#showtooltip Slow Fall
/cast Slow Fall
```

### dm — `m-dampen`

```
#showtooltip [mod:shift] Amplify Magic; Dampen Magic
/cast [mod:shift] Amplify Magic; Dampen Magic
```

### snap — `m-csnap`

```
#showtooltip Cold Snap
/cast Cold Snap
```

### nef — `m-nef`

```
/use [@cursor] Stratholme Holy Water
/cast Blast Wave
```

## Mage filler — class-specific

Existing Currentz fillers. /cqs and [nomod]/[mod:shift] downranks stay.

### f — `m-fb`

```
#showtooltip [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)
/cqs
/cast [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)
```

### fb — `m-fireball`

```
#showtooltip [mod:shift] Combustion; Fireball
/cqs
/cast [mod:shift] Combustion
/use [mod:shift] Mind Quickening Gem
/use [mod:shift] Talisman of Ephemeral Power
/use [mod:shift] Zandalarian Hero Charm
/cast Fireball;
```

### ' — `m-blast`

```
#showtooltip [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)
/cast [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)
```

### ae — `m-ae`

```
#showtooltip [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)
/cast [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)
```

### am — `m-am`

```
#showtooltip Arcane Missiles
/cast [nochanneling:Arcane Missiles] Arcane Missiles
```

### Blizz — `m-blizz`

```
#showtooltip [nomod]Blizzard;[mod:shift]Blizzard(rank 1)
/cast [nomod]Blizzard;[mod:shift]Blizzard(rank 1)
```

### cone — `m-cone`

```
#showtooltip [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)
/cast [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)
```

### fs — `m-fs`

```
#showtooltip [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike
/use [mod:alt] Talisman of Ephemeral Power
/use [mod:alt] Zandalarian Hero Charm
/cast [mod:alt] Arcane Power
/cast [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike
```

### sc — `m-scorch`

```
#showtooltip Scorch
/cast Scorch
```

### py — `m-pyro`

```
#showtooltip Pyroblast
/cast Presence of Mind
/cast Pyroblast
```

## Mage ports Alliance — class-specific

Existing Currentz IF/SW plus Darnassus from the plan. Shift = portal.

### portsw — `m-sw`

```
#showtooltip [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind
/cast [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind
```

### if — `m-if`

```
#showtooltip [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge
/cast [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge
```

### dar — `m-dar`

```
#showtooltip [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus
/cast [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus
```

## Mage ports Horde — class-specific

Existing WARKEYS Orgrimmar / Undercity / Thunder Bluff.

### org — `m-org`

```
#showtooltip [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar
/cast [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar
```

### uc — `m-uc`

```
#showtooltip [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity
/cast [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity
```

### tb — `m-tb`

```
#showtooltip [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff
/cast [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff
```

## Mage ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### ai — `m-ai`

```
#showtooltip
/cast Arcane Intellect;
```

### cf — `m-cf`

```
#showtooltip
/cast Conjure Food
```

### cw — `m-cw`

```
#showtooltip
/cast Conjure Water
```

### ma — `m-ma`

```
#showtooltip
/cast Mage Armor;
```

### ia — `m-ia`

```
#showtooltip
/cast Ice Armor;
```

## Mage TBC — class-specific — TBC

TBC trainer and talent buttons plus Outland ports. Shift still opens a portal on the city macros. Ice Block stays in Mage control.

### ilance — `m-ilance`

```
#showtooltip Ice Lance
/cast Ice Lance
```

### steal — `m-steal`

```
#showtooltip Spellsteal
/stopcasting
/cast Spellsteal
```

### invis — `m-invis`

```
#showtooltip Invisibility
/stopcasting
/cast Invisibility
```

### molten — `m-molten`

```
#showtooltip Molten Armor
/cast Molten Armor
```

### ablast — `m-ablast`

```
#showtooltip Arcane Blast
/cqs
/cast Arcane Blast
```

### mslow — `m-slow`

```
#showtooltip Slow
/cast Slow
```

### dbreath — `m-dbreath`

```
#showtooltip Dragon's Breath
/cast Dragon's Breath
```

### welem — `m-welem`

```
#showtooltip Summon Water Elemental
/cast Summon Water Elemental
```

### mtable — `m-table`

```
#showtooltip Ritual of Refreshment
/cast Ritual of Refreshment
```

### gemtbc — `m-gemtbc`

```
#showtooltip Conjure Mana Emerald
/cast Conjure Mana Emerald
```

### exodar — `m-exodar`

```
#showtooltip [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar
/cast [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar
```

### slvr — `m-slvr`

```
#showtooltip [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon
/cast [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon
```

### shat — `m-shat`

```
#showtooltip [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath
/cast [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath
```

### thera — `m-thera`

```
#showtooltip [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore
/cast [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore
```

### stonard — `m-stonard`

```
#showtooltip [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard
/cast [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard
```

## Currentz kit — character-specific Currentz

Character-specific Currentz. Touch of Chaos wand and named Naxx shells. Generic Shoot stays in mage-filler.

### shadow — `m-wand`

```
#showtooltip
/equip Touch of Chaos
/cast shoot
```
