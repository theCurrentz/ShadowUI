# Paladin

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Paladin Holy — class-specific

Heals. Alt self. Shift cheap rank.

### hl — `p-hl`

```
#showtooltip
# class-specific PALADIN holy
/cast [mod:alt,target=player] Holy Light; [mod:shift] Holy Light(Rank 1); Holy Light
```

### df — `p-df`

```
#showtooltip Flash of Light
# class-specific PALADIN holy
/cast Divine Favor
/cast Flash of Light
```

### hsk — `p-shock`

```
#showtooltip Holy Shock
# class-specific PALADIN holy
/cast Holy Shock
```

### sealh — `p-seal-h`

```
#showtooltip
# class-specific PALADIN holy
/cast [mod:shift] Seal of Light; Seal of Wisdom
```

### chg — `p-mount`

```
#showtooltip
# class-specific PALADIN all
/cast [mod:shift] Summon Warhorse; Summon Charger
```

## Paladin Retribution — class-specific

Alliance Era ret. Seal + judge + stun + consecrate.

### judge — `p-judge`

```
#showtooltip Judgement
# class-specific PALADIN retribution
/startattack
/cast Judgement
```

### seal — `p-seal`

```
#showtooltip
# class-specific PALADIN retribution
/cast [mod:shift] Seal of Command; Seal of Righteousness
```

### hoj — `p-hoj`

```
#showtooltip Hammer of Justice
# class-specific PALADIN all
/stopcasting
/cast Hammer of Justice
```

### cons — `p-cons`

```
#showtooltip
# class-specific PALADIN all
/cast [mod:shift] Consecration(Rank 1); Consecration
```

### how — `p-how`

```
#showtooltip Hammer of Wrath
# class-specific PALADIN all
/cast Hammer of Wrath
```

### exo — `p-exo`

```
#showtooltip Exorcism
# class-specific PALADIN retribution
/cast Exorcism
```

### rep — `p-rep`

```
#showtooltip Repentance
# class-specific PALADIN retribution
/stopcasting
/cast Repentance
```

### bubble — `p-bubble`

```
#showtooltip Divine Shield
# class-specific PALADIN all
/cast Divine Shield
```

### cds — `p-cancel-ds`

```
# class-specific PALADIN all
/cancelaura Divine Shield
```

### bop — `p-bop`

```
#showtooltip Blessing of Protection
# class-specific PALADIN all
/cast Blessing of Protection
```

### cl — `p-cleanse`

```
#showtooltip Cleanse
# class-specific PALADIN all
/cast [mod:alt,target=player] Cleanse; [target=mouseover,exists] Cleanse; Cleanse
```

### fol — `p-fol`

```
#showtooltip
# class-specific PALADIN holy
/cast [mod:alt,target=player] Flash of Light; [mod:shift] Flash of Light(Rank 4); [mod:ctrl] Flash of Light(Rank 1); Flash of Light
```

### bom — `p-might`

```
#showtooltip
# class-specific PALADIN all
/cast [mod:shift] Blessing of Salvation; [mod:ctrl] Blessing of Wisdom; Blessing of Might
```

### aura — `p-aura`

```
#showtooltip
# class-specific PALADIN all
/cast [mod:shift] Devotion Aura; [mod:ctrl] Retribution Aura; Concentration Aura
```

### rf — `p-rf`

```
#showtooltip Righteous Fury
# class-specific PALADIN protection
/cast Righteous Fury
```

### hsh — `p-hs`

```
#showtooltip Holy Shield
# class-specific PALADIN protection
/cast Holy Shield
```

### loh — `p-loh`

```
#showtooltip Lay on Hands
# class-specific PALADIN holy
/raid Lay on Hands on %t
/cast Lay on Hands
```

### di — `p-di`

```
#showtooltip Divine Intervention
# class-specific PALADIN all
/raid DI on %t
/cast Divine Intervention
```
