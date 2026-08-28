# Shaman

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

Era Shaman is Horde only. TBC Shaman is both factions. Load Shaman TBC for Bloodlust / Heroism and Water Shield.

## Shaman Enhancement — class-specific

Horde Era. Shock interrupt uses /stopcasting and Rank 1 on Shift.

### es — `s-es`

```
#showtooltip Earth Shock
# class-specific SHAMAN all
/stopcasting
/cast [mod:shift] Earth Shock(Rank 1); Earth Shock
```

### fl — `s-shock`

```
#showtooltip
# class-specific SHAMAN enhancement
/cast [mod:shift] Frost Shock; Flame Shock
```

### storm — `s-ss`

```
#showtooltip Stormstrike
# class-specific SHAMAN enhancement
/startattack
/cast Stormstrike
```

### lb — `s-lb`

```
#showtooltip
# class-specific SHAMAN elemental
/cast [mod:shift] Lightning Bolt(Rank 1); Lightning Bolt
```

### chain — `s-cl`

```
#showtooltip Chain Lightning
# class-specific SHAMAN elemental
/cast Chain Lightning
```

### lshield — `s-ls`

```
#showtooltip Lightning Shield
# class-specific SHAMAN all
/cast Lightning Shield
```

### wf — `s-wf`

```
#showtooltip
# class-specific SHAMAN enhancement
/cast [mod:shift] Flametongue Weapon; Windfury Weapon
```

### lhw — `s-lhw`

```
#showtooltip
# class-specific SHAMAN restoration
/cast [mod:alt,target=player] Lesser Healing Wave; [mod:shift] Lesser Healing Wave(Rank 4); [mod:ctrl] Lesser Healing Wave(Rank 1); Lesser Healing Wave
```

### hw — `s-hw`

```
#showtooltip
# class-specific SHAMAN restoration
/cast [mod:alt,target=player] Healing Wave; [mod:shift] Healing Wave(Rank 1); Healing Wave
```

### ns — `s-ns`

```
#showtooltip Healing Wave
# class-specific SHAMAN restoration
/cast Nature's Swiftness
/cast Healing Wave
```

### pg — `s-purge`

```
#showtooltip Purge
# class-specific SHAMAN elemental
/cast [target=mouseover,exists] Purge; Purge
```

### gw — `s-wolf`

```
#showtooltip Ghost Wolf
# class-specific SHAMAN all
/cast Ghost Wolf
```

### gt — `s-ground`

```
#showtooltip
# class-specific SHAMAN all
/cast [mod:shift] Grounding Totem; Windfury Totem
```

### tt — `s-tremor`

```
#showtooltip Tremor Totem
# class-specific SHAMAN all
/cast Tremor Totem
```

### mst — `s-mana`

```
#showtooltip Mana Spring Totem
# class-specific SHAMAN all
/cast Mana Spring Totem
```

### str — `s-str`

```
#showtooltip Strength of Earth Totem
# class-specific SHAMAN enhancement
/cast Strength of Earth Totem
```

### mt — `s-tide`

```
#showtooltip Mana Tide Totem
# class-specific SHAMAN restoration
/cast Mana Tide Totem
```

### cure — `s-cure`

```
#showtooltip Cure Poison
# class-specific SHAMAN restoration
/cast [mod:alt,target=player] Cure Poison; [target=mouseover,exists] Cure Poison; Cure Poison
```

## Shaman ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### fnt — `s-fnt`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Fire Nova Totem;[mod:shift]Fire Nova Totem(Rank 1)
```

### magma — `s-magma`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Magma Totem;[mod:shift]Magma Totem(Rank 1)
```

### sear — `s-sear`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Searing Totem;[mod:shift]Searing Totem(Rank 1)
```

### sclaw — `s-sclaw`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Stoneclaw Totem;[mod:shift]Stoneclaw Totem(Rank 1)
```

### frtot — `s-frtot`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Fire Resistance Totem;[mod:shift]Fire Resistance Totem(Rank 1)
```

### fttot — `s-fttot`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Flametongue Totem;[mod:shift]Flametongue Totem(Rank 1)
```

### rftot — `s-rftot`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Frost Resistance Totem;[mod:shift]Frost Resistance Totem(Rank 1)
```

### fbrand — `s-fbrand`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Frostbrand Weapon;[mod:shift]Frostbrand Weapon(Rank 1)
```

### goa — `s-goa`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Grace of Air Totem;[mod:shift]Grace of Air Totem(Rank 1)
```

### nrtot — `s-nrtot`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Nature Resistance Totem;[mod:shift]Nature Resistance Totem(Rank 1)
```

### rbit — `s-rbit`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Rockbiter Weapon;[mod:shift]Rockbiter Weapon(Rank 1)
```

### sskin — `s-sskin`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Stoneskin Totem;[mod:shift]Stoneskin Totem(Rank 1)
```

### wwall — `s-wwall`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Windwall Totem;[mod:shift]Windwall Totem(Rank 1)
```

### aspirit — `s-aspirit`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Ancestral Spirit;[mod:shift]Ancestral Spirit(Rank 1)
```

### cheal — `s-cheal`

```
#showtooltip
# class-specific SHAMAN all
/cast [mod:alt,target=player] Chain Heal; [mod:shift] Chain Heal(Rank 1); Chain Heal
```

### hstot — `s-hstot`

```
#showtooltip
# class-specific SHAMAN all
/cast [nomod]Healing Stream Totem;[mod:shift]Healing Stream Totem(Rank 1)
```

## Shaman TBC — class-specific — TBC

TBC both factions. Bloodlust and Heroism share one body. Stormstrike stays in Shaman Enhancement.

### bl — `s-bl`

Horde Bloodlust. Alliance Heroism. First learned spell wins.

```
#showtooltip
# class-specific SHAMAN enhancement
/cast Bloodlust
/cast Heroism
```

### wshield — `s-wshield`

```
#showtooltip
# class-specific SHAMAN all
/cast [mod:shift] Lightning Shield; Water Shield
```

### eshield — `s-eshield`

```
#showtooltip Earth Shield
# class-specific SHAMAN restoration
/cast [mod:alt,target=player] Earth Shield; Earth Shield
```

### srage — `s-srage`

```
#showtooltip Shamanistic Rage
# class-specific SHAMAN enhancement
/cast Shamanistic Rage
```

### woa — `s-woa`

```
#showtooltip Wrath of Air Totem
# class-specific SHAMAN all
/cast Wrath of Air Totem
```

### towrath — `s-towrath`

```
#showtooltip Totem of Wrath
# class-specific SHAMAN elemental
/cast Totem of Wrath
```

### eet — `s-eet`

```
#showtooltip Earth Elemental Totem
# class-specific SHAMAN all
/cast Earth Elemental Totem
```

### fet — `s-fet`

```
#showtooltip Fire Elemental Totem
# class-specific SHAMAN all
/cast Fire Elemental Totem
```

### tcall — `s-tcall`

```
#showtooltip Totemic Call
# class-specific SHAMAN all
/cast Totemic Call
```
