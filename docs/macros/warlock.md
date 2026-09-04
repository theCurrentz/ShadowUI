# Warlock

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Warlock core — class-specific

Life Tap, bolts, curses, Spell Lock, summon announce (existing `sum`).

### lt — `l-tap`

```
#showtooltip
/cast [mod:shift] Life Tap(Rank 1); Life Tap
```

### sbolt — `l-sb`

```
#showtooltip
/cast [mod:shift] Shadow Bolt(Rank 1); Shadow Bolt
```

### imm — `l-imm`

```
#showtooltip Immolate
/cast Immolate
```

### corr — `l-corr`

```
#showtooltip
/cast [mod:shift] Corruption(Rank 1); Corruption
```

### coa — `l-coa`

```
#showtooltip
/cast [mod:shift] Curse of Agony; Curse of the Elements
```

### fear — `l-fear`

```
#showtooltip
/stopcasting
/cast [mod:shift] Fear(Rank 1); Fear
```

### lock — `l-lock`

```
#showtooltip Spell Lock
/stopcasting
/cast Spell Lock
```

### sum — `l-sum`

```
/ra Summoning %t
/rw Summoning %t, click!
/cast Ritual of Summoning
```

### soulstone — `l-ss`

```
#showtooltip Major Soulstone
/raid Soulstone on %t
/use Major Soulstone
```

### sac — `l-sac`

```
#showtooltip Sacrifice
/cast Sacrifice
```

### ban — `l-banish`

```
#showtooltip Banish
/stopcasting
/cast Banish
```

### dc — `l-coil`

```
#showtooltip Death Coil
/cast Death Coil
```

### fel — `l-fel`

```
#showtooltip
/cast [mod:shift] Summon Succubus; Summon Felhunter
```

### da — `l-armor`

```
#showtooltip Demon Armor
/cast Demon Armor
```

### drain — `l-drain`

```
#showtooltip
/cast [mod:shift] Drain Soul(Rank 1); Drain Soul
```

### sbn — `l-shadowburn`

```
#showtooltip Shadowburn
/cast Shadowburn
```

### lwand — `l-wand`

```
#showtooltip Shoot
/cast Shoot
```

## Warlock ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### cor — `l-cor`

```
#showtooltip
/cast [nomod]Curse of Recklessness;[mod:shift]Curse of Recklessness(Rank 1)
```

### cosh — `l-cosh`

```
#showtooltip
/cast [nomod]Curse of Shadow;[mod:shift]Curse of Shadow(Rank 1)
```

### cot — `l-cot`

```
#showtooltip
/cast [nomod]Curse of Tongues;[mod:shift]Curse of Tongues(Rank 1)
```

### cowk — `l-cowk`

```
#showtooltip
/cast [nomod]Curse of Weakness;[mod:shift]Curse of Weakness(Rank 1)
```

### dlife — `l-dlife`

```
#showtooltip
/cast [nomod]Drain Life;[mod:shift]Drain Life(Rank 1)
```

### dmana — `l-dmana`

```
#showtooltip
/cast [nomod]Drain Mana;[mod:shift]Drain Mana(Rank 1)
```

### howl — `l-howl`

```
#showtooltip
/cast [nomod]Howl of Terror;[mod:shift]Howl of Terror(Rank 1)
```

### dskin — `l-dskin`

```
#showtooltip
/cast [nomod]Demon Skin;[mod:shift]Demon Skin(Rank 1)
```

### hfunnel — `l-hfunnel`

```
#showtooltip
/cast [nomod]Health Funnel;[mod:shift]Health Funnel(Rank 1)
```

### sward — `l-sward`

```
#showtooltip
/cast [nomod]Shadow Ward;[mod:shift]Shadow Ward(Rank 1)
```

### subj — `l-subj`

```
#showtooltip
/cast [nomod]Subjugate Demon;[mod:shift]Subjugate Demon(Rank 1)
```

### hell — `l-hell`

```
#showtooltip
/cast [nomod]Hellfire;[mod:shift]Hellfire(Rank 1)
```

### rof — `l-rof`

```
#showtooltip
/cast [nomod]Rain of Fire;[mod:shift]Rain of Fire(Rank 1)
```

### spain — `l-spain`

```
#showtooltip
/cast [nomod]Searing Pain;[mod:shift]Searing Pain(Rank 1)
```

### sfire — `l-sfire`

```
#showtooltip
/cast [nomod]Soul Fire;[mod:shift]Soul Fire(Rank 1)
```

## Warlock TBC — class-specific — TBC

TBC armor, filler, soulwell, and talent CCs. Create Soulstone ranks collapsed on the TBC trainer list; the soulstone macro still uses the item.

### incin — `l-incin`

```
#showtooltip Incinerate
/cast Incinerate
```

### felarm — `l-felarm`

```
#showtooltip
/cast [mod:shift] Demon Armor; Fel Armor
```

### shatter — `l-shatter`

```
#showtooltip Soulshatter
/cast Soulshatter
```

### souls — `l-souls`

```
#showtooltip Ritual of Souls
/cast Ritual of Souls
```

### seed — `l-seed`

```
#showtooltip Seed of Corruption
/cast Seed of Corruption
```

### ua — `l-ua`

```
#showtooltip Unstable Affliction
/cast Unstable Affliction
```

### sfury — `l-sfury`

```
#showtooltip Shadowfury
/stopcasting
/cast Shadowfury
```

### fguard — `l-fguard`

```
#showtooltip Summon Felguard
/cast Summon Felguard
```

## Other Xavvian — character-specific Xavvian

In-game macros with no catalog group. Auto-heal keeps them for Export.

### asf — `ingame-other-Xavvian-asf`

Imported from in-game macros-cache.txt.

```
/4 LF tank scholo
```
