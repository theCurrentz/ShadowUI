# Mage

## Teleport vs portal (hold Shift for portal)

Alliance:

```
#showtooltip
/cast [mod:shift] Portal: Stormwind; Teleport: Stormwind
```

```
#showtooltip
/cast [mod:shift] Portal: Ironforge; Teleport: Ironforge
```

```
#showtooltip
/cast [mod:shift] Portal: Darnassus; Teleport: Darnassus
```

Horde:

```
#showtooltip
/cast [mod:shift] Portal: Orgrimmar; Teleport: Orgrimmar
```

```
#showtooltip
/cast [mod:shift] Portal: Undercity; Teleport: Undercity
```

```
#showtooltip
/cast [mod:shift] Portal: Thunder Bluff; Teleport: Thunder Bluff
```

One city per macro. You cannot fit every city under 255 characters with full names.

## Counterspell

```
#showtooltip Counterspell
/stopcasting
/cast Counterspell
```

Focus kick (set `/focus` first):

```
#showtooltip Counterspell
/stopcasting
/cast [target=focus,harm,nodead] Counterspell; Counterspell
```

## Polymorph

```
#showtooltip Polymorph
/stopcasting
/cast [mod:shift] Polymorph(Rank 1); Polymorph
```

Pig / turtle are items or later ranks — Era base sheep is **Polymorph**. Shift Rank 1 for low damage.

## Frostbolt

Shift Rank 1 (kite / tag / wand setup):

```
#showtooltip
/cast [mod:shift] Frostbolt(Rank 1); Frostbolt
```

## Fireball / Scorch / Pyroblast

```
#showtooltip
/cast [mod:shift] Fireball(Rank 1); Fireball
```

```
#showtooltip Scorch
/cast Scorch
```

```
#showtooltip Pyroblast
/cast Pyroblast
```

Presence of Mind + Pyroblast:

```
#showtooltip Pyroblast
/cast Presence of Mind
/cast Pyroblast
```

## Fire Blast (instant filler)

```
#showtooltip Fire Blast
/cast Fire Blast
```

## Frost Nova / Cone of Cold / Blizzard

```
#showtooltip Frost Nova
/cast Frost Nova
```

```
#showtooltip Cone of Cold
/cast Cone of Cold
```

Shift Rank 1 (mana, still slows):

```
#showtooltip
/cast [mod:shift] Blizzard(Rank 1); Blizzard
```

## Arcane Explosion / Arcane Missiles / Arcane Power

Shift Rank 1 farm:

```
#showtooltip
/cast [mod:shift] Arcane Explosion(Rank 1); Arcane Explosion
```

```
#showtooltip Arcane Missiles
/cast Arcane Missiles
```

```
#showtooltip Arcane Power
/cast Arcane Power
```

Combustion (fire talent):

```
#showtooltip Combustion
/cast Combustion
```

Cold Snap:

```
#showtooltip Cold Snap
/cast Cold Snap
```

## Ice Block / Ice Barrier / Mana Shield / Fire Ward / Frost Ward

```
#showtooltip Ice Block
/cast Ice Block
```

Cancel Ice Block:

```
/cancelaura Ice Block
```

```
#showtooltip Ice Barrier
/cast Ice Barrier
```

```
#showtooltip Mana Shield
/cast Mana Shield
```

```
#showtooltip Fire Ward
/cast Fire Ward
```

```
#showtooltip Frost Ward
/cast Frost Ward
```

Shift Fire Ward, else Frost Ward:

```
#showtooltip
/cast [mod:shift] Fire Ward; Frost Ward
```

## Blink / Evocation

```
#showtooltip Blink
/cast Blink
```

```
#showtooltip Evocation
/cast Evocation
```

## Remove Lesser Curse

```
#showtooltip Remove Lesser Curse
/cast [mod:alt,target=player] Remove Lesser Curse; Remove Lesser Curse
```

## Slow Fall

```
#showtooltip Slow Fall
/cast [mod:alt,target=player] Slow Fall; Slow Fall
```

## Dampen Magic / Amplify Magic

```
#showtooltip
/cast [mod:shift] Amplify Magic; Dampen Magic
```

```
#showtooltip Dampen Magic
/cast [mod:alt,target=player] Dampen Magic; Dampen Magic
```

## Mana gem

Use the highest gem you have. Names:

```
#showtooltip Mana Ruby
/use Mana Ruby
```

```
#showtooltip Mana Citrine
/use Mana Citrine
```

Conjure:

```
#showtooltip Conjure Mana Ruby
/cast Conjure Mana Ruby
```

## Conjure food / water

```
#showtooltip Conjure Water
/cast Conjure Water
```

```
#showtooltip Conjure Food
/cast Conjure Food
```

Trade water (target a player, then):

```
/cast Conjure Water
```

There is no safe one-button trade-all in 255 characters without `/script`. Trade by hand or use a small helper addon.

## Wand

```
#showtooltip Shoot
/cast Shoot
```

## Mage Armor / Ice Armor / Molten Armor

Molten Armor is TBC. Era:

```
#showtooltip
/cast [mod:shift] Mage Armor; Ice Armor
```

```
#showtooltip Frost Armor
/cast Frost Armor
```

Low-level Frost Armor vs Ice Armor: use the spell you trained.

## SoD note

SoD adds Regeneration, extra runes, and sometimes extra teleports by phase. Keep Shift = portal, no modifier = teleport. Counterspell still starts with `/stopcasting`.
