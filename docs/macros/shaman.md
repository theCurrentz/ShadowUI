# Shaman (Horde in Classic Era)

## Earth Shock interrupt

```
#showtooltip Earth Shock
/stopcasting
/cast [mod:shift] Earth Shock(Rank 1); Earth Shock
```

Shift Rank 1 still interrupts and costs less mana.

## Flame Shock / Frost Shock

```
#showtooltip Flame Shock
/cast Flame Shock
```

```
#showtooltip Frost Shock
/cast Frost Shock
```

Shift Frost, else Flame:

```
#showtooltip
/cast [mod:shift] Frost Shock; Flame Shock
```

## Lightning Bolt / Chain Lightning ranks

```
#showtooltip
/cast [mod:shift] Lightning Bolt(Rank 1); Lightning Bolt
```

```
#showtooltip Chain Lightning
/cast Chain Lightning
```

## Stormstrike (enh talent)

```
#showtooltip Stormstrike
/startattack
/cast Stormstrike
```

## Lightning Shield

```
#showtooltip Lightning Shield
/cast Lightning Shield
```

## Weapon imbues

```
#showtooltip
/cast [mod:shift] Flametongue Weapon; Windfury Weapon
```

```
#showtooltip Rockbiter Weapon
/cast Rockbiter Weapon
```

```
#showtooltip Frostbrand Weapon
/cast Frostbrand Weapon
```

Two-hand vs off-hand: Classic imbue applies to the weapon you have in the enchant UI sense — Windfury on main-hand is the usual enhance play. Off-hand often Flametongue. Put two macros if you dual wield.

## Ghost Wolf

```
#showtooltip Ghost Wolf
/cast Ghost Wolf
```

## Astral Recall

```
#showtooltip Astral Recall
/cast Astral Recall
```

## Purge

```
#showtooltip Purge
/cast Purge
```

## Cure Poison / Cure Disease

```
#showtooltip Cure Poison
/cast [mod:alt,target=player] Cure Poison; Cure Poison
```

```
#showtooltip Cure Disease
/cast [mod:alt,target=player] Cure Disease; Cure Disease
```

## Healing Wave / Lesser Healing Wave ranks

Alt self. Shift LHW Rank 4. Ctrl LHW Rank 1.

```
#showtooltip
/cast [mod:alt,target=player] Lesser Healing Wave; [mod:shift] Lesser Healing Wave(Rank 4); [mod:ctrl] Lesser Healing Wave(Rank 1); Lesser Healing Wave
```

Healing Wave. Shift Rank 1:

```
#showtooltip
/cast [mod:alt,target=player] Healing Wave; [mod:shift] Healing Wave(Rank 1); Healing Wave
```

## Chain Heal

```
#showtooltip Chain Heal
/cast [mod:alt,target=player] Chain Heal; Chain Heal
```

## Nature's Swiftness + heal (resto talent)

```
#showtooltip Healing Wave
/cast Nature's Swiftness
/cast Healing Wave
```

## Totems — earth

```
#showtooltip Stoneskin Totem
/cast Stoneskin Totem
```

```
#showtooltip Strength of Earth Totem
/cast Strength of Earth Totem
```

```
#showtooltip Earthbind Totem
/cast Earthbind Totem
```

```
#showtooltip Stoneclaw Totem
/cast Stoneclaw Totem
```

```
#showtooltip Tremor Totem
/cast Tremor Totem
```

```
#showtooltip Earth Elemental Totem
```

Earth Elemental is TBC. Skip in Era.

## Totems — fire

```
#showtooltip Searing Totem
/cast Searing Totem
```

```
#showtooltip Magma Totem
/cast Magma Totem
```

```
#showtooltip Fire Nova Totem
/cast Fire Nova Totem
```

```
#showtooltip Frost Resistance Totem
/cast Frost Resistance Totem
```

```
#showtooltip Flametongue Totem
/cast Flametongue Totem
```

## Totems — water

```
#showtooltip Healing Stream Totem
/cast Healing Stream Totem
```

```
#showtooltip Mana Spring Totem
/cast Mana Spring Totem
```

```
#showtooltip Poison Cleansing Totem
/cast Poison Cleansing Totem
```

```
#showtooltip Disease Cleansing Totem
/cast Disease Cleansing Totem
```

```
#showtooltip Fire Resistance Totem
/cast Fire Resistance Totem
```

```
#showtooltip Mana Tide Totem
/cast Mana Tide Totem
```

## Totems — air

```
#showtooltip Grace of Air Totem
/cast Grace of Air Totem
```

```
#showtooltip Windfury Totem
/cast Windfury Totem
```

```
#showtooltip Grounding Totem
/cast Grounding Totem
```

```
#showtooltip Windwall Totem
/cast Windwall Totem
```

```
#showtooltip Sentry Totem
/cast Sentry Totem
```

```
#showtooltip Tranquil Air Totem
/cast Tranquil Air Totem
```

```
#showtooltip Nature Resistance Totem
/cast Nature Resistance Totem
```

Modifier air (grounding vs WF):

```
#showtooltip
/cast [mod:shift] Grounding Totem; Windfury Totem
```

## Totem recall

```
#showtooltip Totemic Recall
```

Totemic Recall is TBC. In Era you drop a new totem of that element to replace it, or walk out of range.

## Reincarnation

Reincarnation is an auto-rez talent, not a `/cast` you fire on a corpse. Do not macro it.

## Far Sight

```
#showtooltip Far Sight
/cast Far Sight
```

## Water Breathing / Water Walking

```
#showtooltip Water Breathing
/cast [mod:alt,target=player] Water Breathing; Water Breathing
```

```
#showtooltip Water Walking
/cast [mod:alt,target=player] Water Walking; Water Walking
```

## SoD note

SoD Shaman exists on Alliance. Extra runes (for example Lava Lash, Dual Wield) use `/startattack` + `/cast`. Shocks still use `/stopcasting` on the interrupt key.
