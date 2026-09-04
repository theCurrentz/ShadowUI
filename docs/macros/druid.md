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
/cast [mod:shift] Moonfire(Rank 1); Moonfire
```

### wr — `d-wrath`

```
#showtooltip Wrath
/cast Wrath
```

### stf — `d-star`

```
#showtooltip Starfire
/cast Starfire
```

### mk — `d-moonkin`

```
#showtooltip Moonkin Form
/cast Moonkin Form
```

### er — `d-roots`

```
#showtooltip
/cancelform
/cast [mod:shift] Entangling Roots(Rank 1); Entangling Roots
```

### rej — `d-rejuv`

```
#showtooltip
/cancelform
/cast [mod:alt,target=player] Rejuvenation; [mod:shift] Rejuvenation(Rank 3); Rejuvenation
```

### sm — `d-swift`

```
#showtooltip Swiftmend
/cancelform
/cast Swiftmend
```

### dnsw — `d-ns`

```
#showtooltip Healing Touch
/cancelform
/cast Nature's Swiftness
/cast Healing Touch
```

## Druid Feral — class-specific

Cat/bear. /cancelform before heals. Form numbers: 1 bear, 3 cat.

### shred — `d-shred`

```
#showtooltip Shred
/startattack
/cast Shred
```

### fbite — `d-fb`

```
#showtooltip
/cast [mod:shift] Ferocious Bite(Rank 1); Ferocious Bite
```

### rip — `d-rip`

```
#showtooltip Rip
/cast Rip
```

### rake — `d-rake`

```
#showtooltip Rake
/startattack
/cast Rake
```

### pr — `d-prowl`

```
#showtooltip Prowl
/cast [noform:3] Cat Form
/cast Prowl
```

### ml — `d-maul`

```
#showtooltip Maul
/startattack
/cast Maul
```

### gr — `d-growl`

```
#showtooltip Growl
/cast [noform:1] Dire Bear Form
/cast Growl
```

### bash — `d-bash`

```
#showtooltip Bash
/stopcasting
/cast Bash
```

### ff — `d-ff`

```
#showtooltip
/cast [form:1/3] Faerie Fire (Feral); Faerie Fire
```

### fc — `d-charge`

```
#showtooltip Feral Charge
/cast Feral Charge
```

### fr — `d-fr`

```
#showtooltip Frenzied Regeneration
/cast Frenzied Regeneration
```

### dash — `d-dash`

```
#showtooltip Dash
/cast Dash
```

### cat — `d-cat`

```
#showtooltip
/cast [mod:shift] Travel Form; Cat Form
```

### bear — `d-bear`

```
#showtooltip Dire Bear Form
/cast Dire Bear Form
```

### ht — `d-ht`

```
#showtooltip
/cancelform
/cast [mod:alt,target=player] Healing Touch; [mod:shift] Healing Touch(Rank 4); [mod:ctrl] Healing Touch(Rank 1); Healing Touch
```

### inn — `d-inn`

```
#showtooltip Innervate
/cancelform
/raid Innervate on %t
/cast [mod:alt,target=player] Innervate; Innervate
```

### reb — `d-reb`

```
#showtooltip Rebirth
/cancelform
/raid {rt8} Rebirth on %t {rt8}
/cast Rebirth
```

### motw — `d-motw`

```
#showtooltip Mark of the Wild
/cancelform
/cast [mod:alt,target=player] Mark of the Wild; Mark of the Wild
```

## Druid ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### hib — `d-hib`

```
#showtooltip
/cancelform
/cast [nomod]Hibernate;[mod:shift]Hibernate(Rank 1)
```

### cane — `d-cane`

```
#showtooltip
/cast [nomod]Hurricane;[mod:shift]Hurricane(Rank 1)
```

### soothe — `d-soothe`

```
#showtooltip
/cancelform
/cast [nomod]Soothe Animal;[mod:shift]Soothe Animal(Rank 1)
```

### thorns — `d-thorns`

```
#showtooltip
/cancelform
/cast [nomod]Thorns;[mod:shift]Thorns(Rank 1)
```

### claw — `d-claw`

```
#showtooltip
/startattack
/cast [nomod]Claw;[mod:shift]Claw(Rank 1)
```

### cower — `d-cower`

```
#showtooltip
/cast [nomod]Cower;[mod:shift]Cower(Rank 1)
```

### dmr — `d-dmr`

```
#showtooltip
/cast [nomod]Demoralizing Roar;[mod:shift]Demoralizing Roar(Rank 1)
```

### pounce — `d-pounce`

```
#showtooltip
/cast [nomod]Pounce;[mod:shift]Pounce(Rank 1)
```

### ravage — `d-ravage`

```
#showtooltip
/cast [nomod]Ravage;[mod:shift]Ravage(Rank 1)
```

### swipe — `d-swipe`

```
#showtooltip
/startattack
/cast [nomod]Swipe;[mod:shift]Swipe(Rank 1)
```

### tfury — `d-tfury`

```
#showtooltip
/cast [nomod]Tiger's Fury;[mod:shift]Tiger's Fury(Rank 1)
```

### gotw — `d-gotw`

```
#showtooltip
/cancelform
/cast [nomod]Gift of the Wild;[mod:shift]Gift of the Wild(Rank 1)
```

### rgw — `d-rgw`

```
#showtooltip
/cancelform
/cast [mod:alt,target=player] Regrowth; [mod:shift] Regrowth(Rank 1); Regrowth
```

### tranq — `d-tranq`

```
#showtooltip
/cancelform
/cast [nomod]Tranquility;[mod:shift]Tranquility(Rank 1)
```

## Druid TBC — class-specific — TBC

TBC forms and feral/resto buttons. Flight Form is trainer-taught. Swift Flight Form is Restoration.

### mangle — `d-mangle`

```
#showtooltip
/startattack
/cast [form:3] Mangle (Cat); Mangle (Bear)
```

### lbloom — `d-lbloom`

```
#showtooltip Lifebloom
/cancelform
/cast [mod:alt,target=player] Lifebloom; Lifebloom
```

### cyc — `d-cyc`

```
#showtooltip Cyclone
/stopcasting
/cast Cyclone
```

### flight — `d-flight`

```
#showtooltip
/cast [mod:shift] Swift Flight Form; Flight Form
```

### lac — `d-lac`

```
#showtooltip Lacerate
/startattack
/cast Lacerate
```

### maim — `d-maim`

```
#showtooltip Maim
/cast Maim
```

### tree — `d-tree`

```
#showtooltip Tree of Life
/cast Tree of Life
```
