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

Mouseover stun:

```
#showtooltip Hammer of Justice
/stopcasting
/cast [target=mouseover,harm,nodead] Hammer of Justice; Hammer of Justice
```

## Consecration downrank

```
#showtooltip Consecration(Rank 1)
/cast Consecration(Rank 1)
```

Full rank:

```
#showtooltip Consecration
/cast Consecration
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

## Flash of Light / Holy Light ranks

```
#showtooltip Flash of Light
/cast [mod:alt,target=player] Flash of Light; [target=mouseover,help,nodead] Flash of Light; Flash of Light
```

Downrank Flash (mana / tank spam):

```
#showtooltip Flash of Light(Rank 4)
/cast [target=mouseover,help,nodead] Flash of Light(Rank 4); Flash of Light(Rank 4)
```

Holy Light big heal:

```
#showtooltip Holy Light
/cast [mod:alt,target=player] Holy Light; [target=mouseover,help,nodead] Holy Light; Holy Light
```

Holy Light rank 1 (beacon-style cheap heal in Era — still useful for the 5-second rule and for topping):

```
#showtooltip Holy Light(Rank 1)
/cast [target=mouseover,help,nodead] Holy Light(Rank 1); Holy Light(Rank 1)
```

## Divine Favor (holy)

```
#showtooltip Flash of Light
/cast Divine Favor
/cast [target=mouseover,help,nodead] Flash of Light; Flash of Light
```

## Holy Shock (holy talent)

```
#showtooltip Holy Shock
/cast [target=mouseover,exists,nodead] Holy Shock; Holy Shock
```

## Lay on Hands

```
#showtooltip Lay on Hands
/cast [target=mouseover,help,nodead] Lay on Hands; Lay on Hands
```

```
/raid Lay on Hands on %t
/cast Lay on Hands
```

## Blessing of Protection (mouseover)

```
#showtooltip Blessing of Protection
/cast [target=mouseover,help,nodead] Blessing of Protection; Blessing of Protection
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
/cast [target=mouseover,help,nodead] Divine Intervention; Divine Intervention
```

```
/raid DI on %t
/cast Divine Intervention
```

## Cleanse (mouseover)

```
#showtooltip Cleanse
/cast [mod:alt,target=player] Cleanse; [target=mouseover,help,nodead] Cleanse; Cleanse
```

Purify (lower ranks / no magic dispel):

```
#showtooltip Purify
/cast [target=mouseover,help,nodead] Purify; Purify
```

## Blessings (single)

```
#showtooltip
/cast [mod:shift] Blessing of Salvation; [mod:ctrl] Blessing of Wisdom; Blessing of Might
```

Kings / Light / Sanctuary as their own keys if you have the talent or raid role.

Mouseover Might:

```
#showtooltip Blessing of Might
/cast [target=mouseover,help,nodead] Blessing of Might; Blessing of Might
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
