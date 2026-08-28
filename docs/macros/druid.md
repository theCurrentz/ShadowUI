# Druid

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

**Forms (typical Era index):** `1` Bear, `2` Aquatic, `3` Cat, `4` Travel. Test `form:N` if a macro misses.
TBC adds Flight Form. Swift Flight Form is a Restoration talent. Tree of Life is Restoration.

## Druid Balance / Resto extras — class-specific

Moonkin and healer extras.

### mfire — `d-mf`

```
#showtooltip
# class-specific DRUID balance
/cast [mod:shift] Moonfire(Rank 1); Moonfire
```

### wr — `d-wrath`

```
#showtooltip Wrath
# class-specific DRUID balance
/cast Wrath
```

### stf — `d-star`

```
#showtooltip Starfire
# class-specific DRUID balance
/cast Starfire
```

### mk — `d-moonkin`

```
#showtooltip Moonkin Form
# class-specific DRUID balance
/cast Moonkin Form
```

### er — `d-roots`

```
#showtooltip
# class-specific DRUID balance
/cancelform
/cast [mod:shift] Entangling Roots(Rank 1); Entangling Roots
```

### rej — `d-rejuv`

```
#showtooltip
# class-specific DRUID restoration
/cancelform
/cast [mod:alt,target=player] Rejuvenation; [mod:shift] Rejuvenation(Rank 3); Rejuvenation
```

### sm — `d-swift`

```
#showtooltip Swiftmend
# class-specific DRUID restoration
/cancelform
/cast Swiftmend
```

### dnsw — `d-ns`

```
#showtooltip Healing Touch
# class-specific DRUID restoration
/cancelform
/cast Nature's Swiftness
/cast Healing Touch
```

## Druid Feral — class-specific

Cat/bear. /cancelform before heals. Form numbers: 1 bear, 3 cat.

### shred — `d-shred`

```
#showtooltip Shred
# class-specific DRUID feral
/startattack
/cast Shred
```

### fbite — `d-fb`

```
#showtooltip
# class-specific DRUID feral
/cast [mod:shift] Ferocious Bite(Rank 1); Ferocious Bite
```

### rip — `d-rip`

```
#showtooltip Rip
# class-specific DRUID feral
/cast Rip
```

### rake — `d-rake`

```
#showtooltip Rake
# class-specific DRUID feral
/startattack
/cast Rake
```

### pr — `d-prowl`

```
#showtooltip Prowl
# class-specific DRUID feral
/cast [noform:3] Cat Form
/cast Prowl
```

### ml — `d-maul`

```
#showtooltip Maul
# class-specific DRUID feral
/startattack
/cast Maul
```

### gr — `d-growl`

```
#showtooltip Growl
# class-specific DRUID feral
/cast [noform:1] Dire Bear Form
/cast Growl
```

### bash — `d-bash`

```
#showtooltip Bash
# class-specific DRUID feral
/stopcasting
/cast Bash
```

### ff — `d-ff`

```
#showtooltip
# class-specific DRUID all
/cast [form:1/3] Faerie Fire (Feral); Faerie Fire
```

### fc — `d-charge`

```
#showtooltip Feral Charge
# class-specific DRUID feral
/cast Feral Charge
```

### fr — `d-fr`

```
#showtooltip Frenzied Regeneration
# class-specific DRUID feral
/cast Frenzied Regeneration
```

### dash — `d-dash`

```
#showtooltip Dash
# class-specific DRUID feral
/cast Dash
```

### cat — `d-cat`

```
#showtooltip
# class-specific DRUID feral
/cast [mod:shift] Travel Form; Cat Form
```

### bear — `d-bear`

```
#showtooltip Dire Bear Form
# class-specific DRUID feral
/cast Dire Bear Form
```

### ht — `d-ht`

```
#showtooltip
# class-specific DRUID restoration
/cancelform
/cast [mod:alt,target=player] Healing Touch; [mod:shift] Healing Touch(Rank 4); [mod:ctrl] Healing Touch(Rank 1); Healing Touch
```

### inn — `d-inn`

```
#showtooltip Innervate
# class-specific DRUID restoration
/cancelform
/raid Innervate on %t
/cast [mod:alt,target=player] Innervate; Innervate
```

### reb — `d-reb`

```
#showtooltip Rebirth
# class-specific DRUID restoration
/cancelform
/raid {rt8} Rebirth on %t {rt8}
/cast Rebirth
```

### motw — `d-motw`

```
#showtooltip Mark of the Wild
# class-specific DRUID restoration
/cancelform
/cast [mod:alt,target=player] Mark of the Wild; Mark of the Wild
```

## Druid ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### hib — `d-hib`

```
#showtooltip
# class-specific DRUID all
/cancelform
/cast [nomod]Hibernate;[mod:shift]Hibernate(Rank 1)
```

### cane — `d-cane`

```
#showtooltip
# class-specific DRUID all
/cast [nomod]Hurricane;[mod:shift]Hurricane(Rank 1)
```

### soothe — `d-soothe`

```
#showtooltip
# class-specific DRUID all
/cancelform
/cast [nomod]Soothe Animal;[mod:shift]Soothe Animal(Rank 1)
```

### thorns — `d-thorns`

```
#showtooltip
# class-specific DRUID all
/cancelform
/cast [nomod]Thorns;[mod:shift]Thorns(Rank 1)
```

### claw — `d-claw`

```
#showtooltip
# class-specific DRUID all
/startattack
/cast [nomod]Claw;[mod:shift]Claw(Rank 1)
```

### cower — `d-cower`

```
#showtooltip
# class-specific DRUID all
/cast [nomod]Cower;[mod:shift]Cower(Rank 1)
```

### dmr — `d-dmr`

```
#showtooltip
# class-specific DRUID all
/cast [nomod]Demoralizing Roar;[mod:shift]Demoralizing Roar(Rank 1)
```

### pounce — `d-pounce`

```
#showtooltip
# class-specific DRUID all
/cast [nomod]Pounce;[mod:shift]Pounce(Rank 1)
```

### ravage — `d-ravage`

```
#showtooltip
# class-specific DRUID all
/cast [nomod]Ravage;[mod:shift]Ravage(Rank 1)
```

### swipe — `d-swipe`

```
#showtooltip
# class-specific DRUID all
/startattack
/cast [nomod]Swipe;[mod:shift]Swipe(Rank 1)
```

### tfury — `d-tfury`

```
#showtooltip
# class-specific DRUID all
/cast [nomod]Tiger's Fury;[mod:shift]Tiger's Fury(Rank 1)
```

### gotw — `d-gotw`

```
#showtooltip
# class-specific DRUID all
/cancelform
/cast [nomod]Gift of the Wild;[mod:shift]Gift of the Wild(Rank 1)
```

### rgw — `d-rgw`

```
#showtooltip
# class-specific DRUID all
/cancelform
/cast [mod:alt,target=player] Regrowth; [mod:shift] Regrowth(Rank 1); Regrowth
```

### tranq — `d-tranq`

```
#showtooltip
# class-specific DRUID all
/cancelform
/cast [nomod]Tranquility;[mod:shift]Tranquility(Rank 1)
```

## Druid TBC — class-specific — TBC

TBC forms and feral/resto buttons. Flight Form is trainer-taught. Swift Flight Form is Restoration.

### mangle — `d-mangle`

```
#showtooltip
# class-specific DRUID feral
/startattack
/cast [form:3] Mangle (Cat); Mangle (Bear)
```

### lbloom — `d-lbloom`

```
#showtooltip Lifebloom
# class-specific DRUID restoration
/cancelform
/cast [mod:alt,target=player] Lifebloom; Lifebloom
```

### cyc — `d-cyc`

```
#showtooltip Cyclone
# class-specific DRUID balance
/stopcasting
/cast Cyclone
```

### flight — `d-flight`

```
#showtooltip
# class-specific DRUID all
/cast [mod:shift] Swift Flight Form; Flight Form
```

### lac — `d-lac`

```
#showtooltip Lacerate
# class-specific DRUID feral
/startattack
/cast Lacerate
```

### maim — `d-maim`

```
#showtooltip Maim
# class-specific DRUID feral
/cast Maim
```

### tree — `d-tree`

```
#showtooltip Tree of Life
# class-specific DRUID restoration
/cast Tree of Life
```
