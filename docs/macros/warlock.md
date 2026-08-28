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

## Warlock ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### cor — `l-cor`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Curse of Recklessness;[mod:shift]Curse of Recklessness(Rank 1)
```

### cosh — `l-cosh`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Curse of Shadow;[mod:shift]Curse of Shadow(Rank 1)
```

### cot — `l-cot`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Curse of Tongues;[mod:shift]Curse of Tongues(Rank 1)
```

### cowk — `l-cowk`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Curse of Weakness;[mod:shift]Curse of Weakness(Rank 1)
```

### dlife — `l-dlife`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Drain Life;[mod:shift]Drain Life(Rank 1)
```

### dmana — `l-dmana`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Drain Mana;[mod:shift]Drain Mana(Rank 1)
```

### howl — `l-howl`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Howl of Terror;[mod:shift]Howl of Terror(Rank 1)
```

### dskin — `l-dskin`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Demon Skin;[mod:shift]Demon Skin(Rank 1)
```

### hfunnel — `l-hfunnel`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Health Funnel;[mod:shift]Health Funnel(Rank 1)
```

### sward — `l-sward`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Shadow Ward;[mod:shift]Shadow Ward(Rank 1)
```

### subj — `l-subj`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Subjugate Demon;[mod:shift]Subjugate Demon(Rank 1)
```

### hell — `l-hell`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Hellfire;[mod:shift]Hellfire(Rank 1)
```

### rof — `l-rof`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Rain of Fire;[mod:shift]Rain of Fire(Rank 1)
```

### spain — `l-spain`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Searing Pain;[mod:shift]Searing Pain(Rank 1)
```

### sfire — `l-sfire`

```
#showtooltip
# class-specific WARLOCK all
/cast [nomod]Soul Fire;[mod:shift]Soul Fire(Rank 1)
```

## Warlock TBC — class-specific — TBC

TBC armor, filler, soulwell, and talent CCs. Create Soulstone ranks collapsed on the TBC trainer list; the soulstone macro still uses the item.

### incin — `l-incin`

```
#showtooltip Incinerate
# class-specific WARLOCK destruction
/cast Incinerate
```

### felarm — `l-felarm`

```
#showtooltip
# class-specific WARLOCK all
/cast [mod:shift] Demon Armor; Fel Armor
```

### shatter — `l-shatter`

```
#showtooltip Soulshatter
# class-specific WARLOCK all
/cast Soulshatter
```

### souls — `l-souls`

```
#showtooltip Ritual of Souls
# class-specific WARLOCK all
/cast Ritual of Souls
```

### seed — `l-seed`

```
#showtooltip Seed of Corruption
# class-specific WARLOCK affliction
/cast Seed of Corruption
```

### ua — `l-ua`

```
#showtooltip Unstable Affliction
# class-specific WARLOCK affliction
/cast Unstable Affliction
```

### sfury — `l-sfury`

```
#showtooltip Shadowfury
# class-specific WARLOCK destruction
/stopcasting
/cast Shadowfury
```

### fguard — `l-fguard`

```
#showtooltip Summon Felguard
# class-specific WARLOCK demonology
/cast Summon Felguard
```

## Other Xavvian — character-specific Xavvian

In-game macros with no catalog group. Auto-heal keeps them for Export.

### asf — `ingame-other-Xavvian-asf`

Imported from in-game macros-cache.txt.

```
/4 LF tank scholo
```
