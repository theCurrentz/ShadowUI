# Paladin

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

Era Paladin is Alliance only. TBC Paladin is both factions. Load Paladin TBC for Crusader Strike, Avenging Wrath, and Blood / Vengeance seals.

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

## Paladin ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### gbom — `p-gbom`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Greater Blessing of Might;[mod:shift]Greater Blessing of Might(Rank 1)
```

### crus — `p-crus`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Seal of the Crusader;[mod:shift]Seal of the Crusader(Rank 1)
```

### bosac — `p-bosac`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Blessing of Sacrifice;[mod:shift]Blessing of Sacrifice(Rank 1)
```

### dprot — `p-dprot`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Divine Protection;[mod:shift]Divine Protection(Rank 1)
```

### fraura — `p-fraura`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Fire Resistance Aura;[mod:shift]Fire Resistance Aura(Rank 1)
```

### rfaura — `p-rfaura`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Frost Resistance Aura;[mod:shift]Frost Resistance Aura(Rank 1)
```

### sraura — `p-sraura`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Shadow Resistance Aura;[mod:shift]Shadow Resistance Aura(Rank 1)
```

### bolight — `p-bolight`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Blessing of Light;[mod:shift]Blessing of Light(Rank 1)
```

### gbow — `p-gbow`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Greater Blessing of Wisdom;[mod:shift]Greater Blessing of Wisdom(Rank 1)
```

### hwath — `p-hwath`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Holy Wrath;[mod:shift]Holy Wrath(Rank 1)
```

### redeem — `p-redeem`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Redemption;[mod:shift]Redemption(Rank 1)
```

### turnu — `p-turnu`

```
#showtooltip
# class-specific PALADIN all
/cast [nomod]Turn Undead;[mod:shift]Turn Undead(Rank 1)
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

## Paladin TBC — class-specific — TBC

TBC baseline and talent buttons. Paladin is both factions. Seal of Command stays on `p-seal`.

### cstrike — `p-cstrike`

```
#showtooltip Crusader Strike
# class-specific PALADIN retribution
/startattack
/cast Crusader Strike
```

### aw — `p-aw`

```
#showtooltip Avenging Wrath
# class-specific PALADIN all
/use 13
/cast Avenging Wrath
```

### rdef — `p-rdef`

Taunt the mobs on a friendly mouseover, then the current target.

```
#showtooltip Righteous Defense
# class-specific PALADIN all
/cast [target=mouseover,help,nodead][] Righteous Defense
```

### ashield — `p-ashield`

```
#showtooltip Avenger's Shield
# class-specific PALADIN protection
/startattack
/cast Avenger's Shield
```

### sealtbc — `p-sealtbc`

Horde Blood / Martyr. Alliance Vengeance / Corruption. First learned seal wins.

```
#showtooltip
# class-specific PALADIN retribution
/cast Seal of Blood
/cast Seal of Vengeance
/cast Seal of the Martyr
/cast Seal of Corruption
```

### turne — `p-turne`

```
#showtooltip Turn Evil
# class-specific PALADIN all
/stopcasting
/cast Turn Evil
```

### caura — `p-caura`

```
#showtooltip Crusader Aura
# class-specific PALADIN all
/cast Crusader Aura
```

## Other Virene — character-specific Virene

In-game macros with no catalog group. Auto-heal keeps them for Export.

### sb — `ingame-other-Virene-sb`

Imported from in-game macros-cache.txt.

```
/equip Thief's Blade
/equiip Redbeard Crest
```
