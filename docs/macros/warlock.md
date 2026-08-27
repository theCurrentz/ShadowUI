# Warlock

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Warlock core — class-specific

Life Tap, bolts, curses, Spell Lock, summon announce (existing `sum`).

### lt — `l-tap`

```
#showtooltip
# class-specific WARLOCK all
/cast [mod:shift] Life Tap(Rank 1); Life Tap
```

### sbolt — `l-sb`

```
#showtooltip
# class-specific WARLOCK destruction
/cast [mod:shift] Shadow Bolt(Rank 1); Shadow Bolt
```

### imm — `l-imm`

```
#showtooltip Immolate
# class-specific WARLOCK destruction
/cast Immolate
```

### corr — `l-corr`

```
#showtooltip
# class-specific WARLOCK affliction
/cast [mod:shift] Corruption(Rank 1); Corruption
```

### coa — `l-coa`

```
#showtooltip
# class-specific WARLOCK affliction
/cast [mod:shift] Curse of Agony; Curse of the Elements
```

### fear — `l-fear`

```
#showtooltip
# class-specific WARLOCK affliction
/stopcasting
/cast [mod:shift] Fear(Rank 1); Fear
```

### lock — `l-lock`

```
#showtooltip Spell Lock
# class-specific WARLOCK demonology
/stopcasting
/cast Spell Lock
```

### lpa — `l-pa`

```
# class-specific WARLOCK demonology
/petattack
```

### lpf — `l-pf`

```
# class-specific WARLOCK demonology
/petfollow
```

### sum — `l-sum`

```
# class-specific WARLOCK all
/ra Summoning %t
/rw Summoning %t, click!
/cast Ritual of Summoning
```

### soulstone — `l-ss`

```
#showtooltip Major Soulstone
# class-specific WARLOCK all
/raid Soulstone on %t
/use Major Soulstone
```

### sac — `l-sac`

```
#showtooltip Sacrifice
# class-specific WARLOCK demonology
/cast Sacrifice
```

### ban — `l-banish`

```
#showtooltip Banish
# class-specific WARLOCK demonology
/stopcasting
/cast Banish
```

### dc — `l-coil`

```
#showtooltip Death Coil
# class-specific WARLOCK affliction
/cast Death Coil
```

### fel — `l-fel`

```
#showtooltip
# class-specific WARLOCK demonology
/cast [mod:shift] Summon Succubus; Summon Felhunter
```

### da — `l-armor`

```
#showtooltip Demon Armor
# class-specific WARLOCK all
/cast Demon Armor
```

### drain — `l-drain`

```
#showtooltip
# class-specific WARLOCK affliction
/cast [mod:shift] Drain Soul(Rank 1); Drain Soul
```

### sbn — `l-shadowburn`

```
#showtooltip Shadowburn
# class-specific WARLOCK destruction
/cast Shadowburn
```

### lwand — `l-wand`

```
#showtooltip Shoot
# class-specific WARLOCK all
/cast Shoot
```
