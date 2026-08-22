# Paladin (Alliance in Classic Era)

## Start attack + Judgement

```
#showtooltip Judgement
/startattack
/cast Judgement
```

## Seal swap (hold shift for the other seal)

Righteousness vs Command (ret):

```
#showtooltip
/cast [mod:shift] Seal of Command; Seal of Righteousness
```

Wisdom vs Light (holy):

```
#showtooltip
/cast [mod:shift] Seal of Light; Seal of Wisdom
```

The Justice (stun on judge, pvp):

```
#showtooltip Seal of Justice
/cast Seal of Justice
```

Crusader (mana, older content):

```
#showtooltip Seal of the Crusader
/cast Seal of the Crusader
```

## Auto seal then judge (one key)

```
#showtooltip Judgement
/cast Seal of Command
/startattack
/cast Judgement
```

This recasts the seal every press if you are not careful. Prefer separate keys in raids.

## Hammer of Justice

```
#showtooltip Hammer of Justice
/stopcasting
/cast Hammer of Justice
```

## Consecration

Shift Rank 1 (grind / low threat):

```
#showtooltip
/cast [mod:shift] Consecration(Rank 1); Consecration
```

## Holy Shield (prot)

```
#showtooltip Holy Shield
/cast Holy Shield
```

## Righteous Fury

```
#showtooltip Righteous Fury
/cast Righteous Fury
```

Cancel when you must drop threat:

```
/cancelaura Righteous Fury
```

## Hammer of Wrath (execute window)

```
#showtooltip Hammer of Wrath
/cast Hammer of Wrath
```

## Exorcism / Holy Wrath (undead / demon)

```
#showtooltip Exorcism
/cast Exorcism
```

```
#showtooltip Holy Wrath
/cast Holy Wrath
```

## Repentance (ret talent)

```
#showtooltip Repentance
/stopcasting
/cast Repentance
```

## Flash of Light / Holy Light

Alt self. Shift Flash Rank 4. Ctrl Flash Rank 1.

```
#showtooltip
/cast [mod:alt,target=player] Flash of Light; [mod:shift] Flash of Light(Rank 4); [mod:ctrl] Flash of Light(Rank 1); Flash of Light
```

Holy Light. Shift Rank 1 (cheap top / 5SR):

```
#showtooltip
/cast [mod:alt,target=player] Holy Light; [mod:shift] Holy Light(Rank 1); Holy Light
```

## Divine Favor (holy)

```
#showtooltip Flash of Light
/cast Divine Favor
/cast Flash of Light
```

## Holy Shock (holy talent)

```
#showtooltip Holy Shock
/cast Holy Shock
```

## Lay on Hands

```
#showtooltip Lay on Hands
/cast Lay on Hands
```

```
/raid Lay on Hands on %t
/cast Lay on Hands
```

## Blessing of Protection

```
#showtooltip Blessing of Protection
/cast Blessing of Protection
```

Cancel BoP (so the tank can hit again, or you can swing):

```
/cancelaura Blessing of Protection
```

## Divine Shield

```
#showtooltip Divine Shield
/cast Divine Shield
```

Cancel bubble:

```
/cancelaura Divine Shield
```

Bubble-hearth:

```
#showtooltip Hearthstone
/cast Divine Shield
/use Hearthstone
```

## Divine Intervention

```
#showtooltip Divine Intervention
/cast Divine Intervention
```

```
/raid DI on %t
/cast Divine Intervention
```

## Cleanse

```
#showtooltip Cleanse
/cast [mod:alt,target=player] Cleanse; Cleanse
```

Purify (lower ranks / no magic dispel):

```
#showtooltip Purify
/cast [mod:alt,target=player] Purify; Purify
```

## Blessings (single)

```
#showtooltip
/cast [mod:shift] Blessing of Salvation; [mod:ctrl] Blessing of Wisdom; Blessing of Might
```

Kings / Light / Sanctuary as their own keys if you have the talent or raid role.

```
#showtooltip Blessing of Might
/cast Blessing of Might
```

Greater Blessing of Might (class click):

```
#showtooltip Greater Blessing of Might
/cast Greater Blessing of Might
```

Target a class member, then press Greater Blessing. One macro per greater blessing.

## Auras

```
#showtooltip
/cast [mod:shift] Devotion Aura; [mod:ctrl] Retribution Aura; Concentration Aura
```

```
#showtooltip Shadow Resistance Aura
/cast Shadow Resistance Aura
```

```
#showtooltip Frost Resistance Aura
/cast Frost Resistance Aura
```

```
#showtooltip Fire Resistance Aura
/cast Fire Resistance Aura
```

```
#showtooltip Sanctity Aura
/cast Sanctity Aura
```

## Mount

```
#showtooltip
/cast [mod:shift] Summon Warhorse; Summon Charger
```

Use the spell you actually trained. Epic is Summon Charger.

## SoD note

SoD Paladin exists on Horde. Same spell names. Extra runes (for example Crusader Strike, Divine Storm) use `/startattack` + `/cast`.
