# Paladin

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

Era Paladin is Alliance only. TBC Paladin is both factions. Load Paladin TBC for Crusader Strike, Avenging Wrath, and Blood / Vengeance seals.

## Paladin Holy — class-specific

Heals. Alt self. Shift cheap rank.

### hl — `p-hl`

```
#showtooltip
/cast [mod:alt,target=player] Holy Light; [mod:shift] Holy Light(Rank 1); Holy Light
```

### df — `p-df`

```
#showtooltip Flash of Light
/cast Divine Favor
/cast Flash of Light
```

### hsk — `p-shock`

```
#showtooltip Holy Shock
/cast Holy Shock
```

### sealh — `p-seal-h`

```
#showtooltip
/cast [mod:shift] Seal of Light; Seal of Wisdom
```

### chg — `p-mount`

```
#showtooltip
/cast [mod:shift] Summon Warhorse; Summon Charger
```

## Paladin ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### gbom — `p-gbom`

```
#showtooltip
/cast [nomod]Greater Blessing of Might;[mod:shift]Greater Blessing of Might(Rank 1)
```

### crus — `p-crus`

```
#showtooltip
/cast [nomod]Seal of the Crusader;[mod:shift]Seal of the Crusader(Rank 1)
```

### bosac — `p-bosac`

```
#showtooltip
/cast [nomod]Blessing of Sacrifice;[mod:shift]Blessing of Sacrifice(Rank 1)
```

### dprot — `p-dprot`

```
#showtooltip
/cast [nomod]Divine Protection;[mod:shift]Divine Protection(Rank 1)
```

### fraura — `p-fraura`

```
#showtooltip
/cast [nomod]Fire Resistance Aura;[mod:shift]Fire Resistance Aura(Rank 1)
```

### rfaura — `p-rfaura`

```
#showtooltip
/cast [nomod]Frost Resistance Aura;[mod:shift]Frost Resistance Aura(Rank 1)
```

### sraura — `p-sraura`

```
#showtooltip
/cast [nomod]Shadow Resistance Aura;[mod:shift]Shadow Resistance Aura(Rank 1)
```

### bolight — `p-bolight`

```
#showtooltip
/cast [nomod]Blessing of Light;[mod:shift]Blessing of Light(Rank 1)
```

### gbow — `p-gbow`

```
#showtooltip
/cast [nomod]Greater Blessing of Wisdom;[mod:shift]Greater Blessing of Wisdom(Rank 1)
```

### hwath — `p-hwath`

```
#showtooltip
/cast [nomod]Holy Wrath;[mod:shift]Holy Wrath(Rank 1)
```

### redeem — `p-redeem`

```
#showtooltip
/cast [nomod]Redemption;[mod:shift]Redemption(Rank 1)
```

### turnu — `p-turnu`

```
#showtooltip
/cast [nomod]Turn Undead;[mod:shift]Turn Undead(Rank 1)
```

## Paladin Retribution — class-specific

Alliance Era ret. Seal + judge + stun + consecrate.

### judge — `p-judge`

```
#showtooltip Judgement
/startattack
/cast Judgement
```

### seal — `p-seal`

```
#showtooltip
/cast [mod:shift] Seal of Command; Seal of Righteousness
```

### hoj — `p-hoj`

```
#showtooltip Hammer of Justice
/stopcasting
/cast Hammer of Justice
```

### cons — `p-cons`

```
#showtooltip
/cast [mod:shift] Consecration(Rank 1); Consecration
```

### how — `p-how`

```
#showtooltip Hammer of Wrath
/cast Hammer of Wrath
```

### exo — `p-exo`

```
#showtooltip Exorcism
/cast Exorcism
```

### rep — `p-rep`

```
#showtooltip Repentance
/stopcasting
/cast Repentance
```

### bubble — `p-bubble`

```
#showtooltip Divine Shield
/cast Divine Shield
```

### cds — `p-cancel-ds`

```
/cancelaura Divine Shield
```

### bop — `p-bop`

```
#showtooltip Blessing of Protection
/cast Blessing of Protection
```

### cl — `p-cleanse`

```
#showtooltip Cleanse
/cast [mod:alt,target=player] Cleanse; [target=mouseover,exists] Cleanse; Cleanse
```

### fol — `p-fol`

```
#showtooltip
/cast [mod:alt,target=player] Flash of Light; [mod:shift] Flash of Light(Rank 4); [mod:ctrl] Flash of Light(Rank 1); Flash of Light
```

### bom — `p-might`

```
#showtooltip
/cast [mod:shift] Blessing of Salvation; [mod:ctrl] Blessing of Wisdom; Blessing of Might
```

### aura — `p-aura`

```
#showtooltip
/cast [mod:shift] Devotion Aura; [mod:ctrl] Retribution Aura; Concentration Aura
```

### rf — `p-rf`

```
#showtooltip Righteous Fury
/cast Righteous Fury
```

### hsh — `p-hs`

```
#showtooltip Holy Shield
/cast Holy Shield
```

### loh — `p-loh`

```
#showtooltip Lay on Hands
/raid Lay on Hands on %t
/cast Lay on Hands
```

### di — `p-di`

```
#showtooltip Divine Intervention
/raid DI on %t
/cast Divine Intervention
```

## Paladin TBC — class-specific — TBC

TBC baseline and talent buttons. Paladin is both factions. Seal of Command stays on `p-seal`.

### cstrike — `p-cstrike`

```
#showtooltip Crusader Strike
/startattack
/cast Crusader Strike
```

### aw — `p-aw`

```
#showtooltip Avenging Wrath
/use 13
/cast Avenging Wrath
```

### rdef — `p-rdef`

Taunt the mobs on a friendly mouseover, then the current target.

```
#showtooltip Righteous Defense
/cast [target=mouseover,help,nodead][] Righteous Defense
```

### ashield — `p-ashield`

```
#showtooltip Avenger's Shield
/startattack
/cast Avenger's Shield
```

### sealtbc — `p-sealtbc`

Horde Blood / Martyr. Alliance Vengeance / Corruption. First learned seal wins.

```
#showtooltip
/cast Seal of Blood
/cast Seal of Vengeance
/cast Seal of the Martyr
/cast Seal of Corruption
```

### turne — `p-turne`

```
#showtooltip Turn Evil
/stopcasting
/cast Turn Evil
```

### caura — `p-caura`

```
#showtooltip Crusader Aura
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
