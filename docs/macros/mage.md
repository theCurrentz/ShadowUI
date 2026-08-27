# Mage

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

Existing Currentz style: `/cqs`, `[nomod]` max rank, `[mod:shift]` Rank 1, `@cursor` ground spells, Ice Block toggle.

## Mage burst — class-specific

Existing SpellQueueWindow + trinket + PoM set. Do not shorten.

### ap + PoM — `m-appom`

```
# class-specific MAGE arcane
/run local _,_,lagHome = GetNetStats() s = lagHome * 2
/console SpellQueueWindow s
/cast !Presence of Mind
/use [mod:shift]Zandalarian Hero Charm
/use [mod:shift]Talisman of Ephemeral Power
/cast !Arcane Power
/cast Frostbolt
```

### PoM + fb — `m-pomfb`

```
# class-specific MAGE frost
/run local _,_,lagHome = GetNetStats() s = lagHome * 2
/console SpellQueueWindow s
/cast !Presence of Mind
/use [mod:shift]Zandalarian Hero Charm
/use [mod:shift]Talisman of Ephemeral Power
/cast Frostbolt
```

### mqg — `m-mqg`

```
# class-specific MAGE frost
/run local _,_,lagHome = GetNetStats() s = lagHome * 2
/console SpellQueueWindow s
/use Mind Quickening Gem
/cast Frostbolt
```

### toep +fb — `m-toep`

```
# class-specific MAGE frost
/run local _,_,lagHome = GetNetStats() s = lagHome * 2
/console SpellQueueWindow s
/use Talisman of Ephemeral Power
/cast Frostbolt;[mod:shift]
```

### zhc — `m-zhc`

```
# class-specific MAGE frost
/run local _,_,lagHome = GetNetStats() s = lagHome * 2
/console SpellQueueWindow s
/use item:19950
/cast Frostbolt;[mod:shift]
```

### ap — `m-ap`

```
#showtooltip Arcane Power
# class-specific MAGE arcane
/cast Arcane Power
```

### comb — `m-comb`

```
#showtooltip Combustion
# class-specific MAGE fire
/cast Combustion
```

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
/ra SHEEPING %t
/y SHEEPING %t
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
# class-specific MAGE frost
/cast Frost Nova
```

### blink — `m-blink`

```
#showtooltip Blink
# class-specific MAGE all
/cast Blink
```

### evo — `m-evo`

```
#showtooltip Evocation
# class-specific MAGE all
/cast Evocation
```

### iba — `m-barrier`

```
#showtooltip Ice Barrier
# class-specific MAGE frost
/cast Ice Barrier
```

### ward — `m-ward`

```
#showtooltip
# class-specific MAGE all
/cast [mod:shift] Fire Ward; Frost Ward
```

### slowfall — `m-slowfall`

```
#showtooltip Slow Fall
# class-specific MAGE all
/cast [mod:alt,target=player] Slow Fall; Slow Fall
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
# class-specific MAGE fire
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
/cqs
/cast Scorch
```

### py — `m-pyro`

```
#showtooltip Pyroblast
# class-specific MAGE fire
/cast Presence of Mind
/cast Pyroblast
```

### shoot — `m-shoot`

```
#showtooltip Shoot
# class-specific MAGE all
/cast Shoot
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

### water — `m-water`

```
#showtooltip Conjure Water
# class-specific MAGE all
/cast Conjure Water
```

### food — `m-food`

```
#showtooltip Conjure Food
# class-specific MAGE all
/cast Conjure Food
```

### gem — `m-gem`

```
#showtooltip Mana Ruby
# class-specific MAGE all
/use Mana Ruby
```

### arm — `m-armor`

```
#showtooltip
# class-specific MAGE all
/cast [mod:shift] Mage Armor; Ice Armor
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

## Currentz kit — character-specific Currentz

Character-specific Currentz. Touch of Chaos wand and named Naxx shells. Generic Shoot stays in mage-filler.

### shadow — `m-wand`

```
#showtooltip
# character-specific MAGE all Currentz
/equip Touch of Chaos
/cast shoot
```

### prot — `m-prot`

Named items. Edit names if another toon uses different shells.

```
#showtooltip
# character-specific MAGE all Currentz
/use The Burrower's Shell
/use Loatheb's Reflection
```
