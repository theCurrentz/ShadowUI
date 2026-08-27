# Priest

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Priest Holy / Disc — class-specific

Alt self. Shift cheap rank. Ctrl Rank 1. Mouseover on dispel.

### fh — `pr-fh`

```
#showtooltip
# class-specific PRIEST holy
/cast [mod:alt,target=player] Flash Heal; [mod:shift] Flash Heal(Rank 4); [mod:ctrl] Flash Heal(Rank 1); Flash Heal
```

### gh — `pr-gh`

```
#showtooltip
# class-specific PRIEST holy
/cast [mod:alt,target=player] Greater Heal; [mod:shift] Greater Heal(Rank 1); Greater Heal
```

### rn — `pr-renew`

```
#showtooltip
# class-specific PRIEST holy
/cast [mod:alt,target=player] Renew; [mod:shift] Renew(Rank 3); Renew
```

### pws — `pr-pws`

```
#showtooltip
# class-specific PRIEST discipline
/cast [mod:alt,target=player] Power Word: Shield; [mod:shift] Power Word: Shield(Rank 1); Power Word: Shield
```

### poh — `pr-poh`

```
#showtooltip Prayer of Healing
# class-specific PRIEST holy
/cast Inner Focus
/cast Prayer of Healing
```

### disp — `pr-dispel`

```
#showtooltip Dispel Magic
# class-specific PRIEST discipline
/cast [mod:alt,target=player] Dispel Magic; [target=mouseover,exists] Dispel Magic; Dispel Magic
```

### fade — `pr-fade`

```
#showtooltip Fade
# class-specific PRIEST all
/cast Fade
```

### ps — `pr-scream`

```
#showtooltip Psychic Scream
# class-specific PRIEST shadow
/cast Psychic Scream
```

### fw — `pr-fw`

```
#showtooltip Fear Ward
# class-specific PRIEST discipline
/raid Fear Ward on %t
/cast [mod:alt,target=player] Fear Ward; Fear Ward
```

### pi — `pr-pi`

```
#showtooltip Power Infusion
# class-specific PRIEST discipline
/raid PI on %t
/cast [mod:alt,target=player] Power Infusion; Power Infusion
```

### fort — `pr-fort`

```
#showtooltip Power Word: Fortitude
# class-specific PRIEST discipline
/cast [mod:alt,target=player] Power Word: Fortitude; Power Word: Fortitude
```

### rez — `pr-rez`

```
#showtooltip Resurrection
# class-specific PRIEST holy
/cast Resurrection
```

### ifr — `pr-if`

```
#showtooltip Inner Fire
# class-specific PRIEST discipline
/cast Inner Fire
```

### hn — `pr-nova`

```
#showtooltip
# class-specific PRIEST holy
/cast [mod:shift] Holy Nova(Rank 1); Holy Nova
```

### wand — `pr-wand`

```
#showtooltip Shoot
# class-specific PRIEST all
/cast Shoot
```

### ad — `pr-abolish`

```
#showtooltip Abolish Disease
# class-specific PRIEST holy
/cast [mod:alt,target=player] Abolish Disease; [target=mouseover,exists] Abolish Disease; Abolish Disease
```

### pof — `pr-pof`

```
#showtooltip Prayer of Fortitude
# class-specific PRIEST discipline
/cast Prayer of Fortitude
```

### pos — `pr-spirit`

```
#showtooltip Prayer of Spirit
# class-specific PRIEST discipline
/cast Prayer of Spirit
```

## Priest Shadow — class-specific

Dots and form. Cancel form to heal.

### swp — `pr-swp`

```
#showtooltip
# class-specific PRIEST shadow
/cast [mod:shift] Shadow Word: Pain(Rank 1); Shadow Word: Pain
```

### mf — `pr-mf`

```
#showtooltip Mind Flay
# class-specific PRIEST shadow
/cast Mind Flay
```

### mblast — `pr-mb`

```
#showtooltip Mind Blast
# class-specific PRIEST shadow
/cast Mind Blast
```

### ve — `pr-ve`

```
#showtooltip Vampiric Embrace
# class-specific PRIEST shadow
/cast Vampiric Embrace
```

### sf — `pr-sf`

```
#showtooltip Shadowform
# class-specific PRIEST shadow
/cast Shadowform
```

### sil — `pr-silence`

```
#showtooltip Silence
# class-specific PRIEST shadow
/stopcasting
/cast Silence
```

### shk — `pr-shackle`

```
#showtooltip Shackle Undead
# class-specific PRIEST shadow
/stopcasting
/cast Shackle Undead
```

### hf — `pr-healform`

```
#showtooltip Flash Heal
# class-specific PRIEST shadow
/cancelaura Shadowform
/cast [mod:alt,target=player] Flash Heal; Flash Heal
```
