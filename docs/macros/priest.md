# Priest

## Mouseover Flash Heal

```
#showtooltip Flash Heal
/cast [mod:alt,target=player] Flash Heal; [target=mouseover,help,nodead] Flash Heal; Flash Heal
```

Downrank Flash (common tank spam ranks — pick the rank you actually use):

```
#showtooltip Flash Heal(Rank 4)
/cast [target=mouseover,help,nodead] Flash Heal(Rank 4); Flash Heal(Rank 4)
```

```
#showtooltip Flash Heal(Rank 1)
/cast [target=mouseover,help,nodead] Flash Heal(Rank 1); Flash Heal(Rank 1)
```

## Greater Heal

```
#showtooltip Greater Heal
/stopcasting
/cast [mod:alt,target=player] Greater Heal; [target=mouseover,help,nodead] Greater Heal; Greater Heal
```

Drop `/stopcasting` if you do not want this key to clip a heal that is about to land.

Downrank Greater Heal (mana / overheal control):

```
#showtooltip Greater Heal(Rank 1)
/cast [target=mouseover,help,nodead] Greater Heal(Rank 1); Greater Heal(Rank 1)
```

## Heal / Lesser Heal (early ranks)

```
#showtooltip Heal
/cast [target=mouseover,help,nodead] Heal; Heal
```

## Renew

```
#showtooltip Renew
/cast [mod:alt,target=player] Renew; [target=mouseover,help,nodead] Renew; Renew
```

Downrank Renew (5SR / small HoT):

```
#showtooltip Renew(Rank 3)
/cast [target=mouseover,help,nodead] Renew(Rank 3); Renew(Rank 3)
```

## Power Word: Shield

```
#showtooltip Power Word: Shield
/cast [mod:alt,target=player] Power Word: Shield; [target=mouseover,help,nodead] Power Word: Shield; Power Word: Shield
```

Downrank shield (less absorbed, less threat, weaker Weakened Soul still applies):

```
#showtooltip Power Word: Shield(Rank 1)
/cast [target=mouseover,help,nodead] Power Word: Shield(Rank 1); Power Word: Shield(Rank 1)
```

## Inner Focus + big heal

```
#showtooltip Greater Heal
/cast Inner Focus
/cast [target=mouseover,help,nodead] Greater Heal; Greater Heal
```

Inner Focus + Prayer of Healing:

```
#showtooltip Prayer of Healing
/cast Inner Focus
/cast Prayer of Healing
```

## Prayer of Healing / Holy Nova

```
#showtooltip Prayer of Healing
/cast Prayer of Healing
```

Rank 1 Holy Nova (low threat AoE / tag):

```
#showtooltip Holy Nova(Rank 1)
/cast Holy Nova(Rank 1)
```

```
#showtooltip Holy Nova
/cast Holy Nova
```

## Circle of Healing

Not in Classic Era. Skip it.

## Dispel Magic / Abolish Disease

```
#showtooltip Dispel Magic
/cast [mod:alt,target=player] Dispel Magic; [target=mouseover,exists,nodead] Dispel Magic; Dispel Magic
```

Offensive dispel wants `harm`. Split if you mis-dispel:

```
#showtooltip Dispel Magic
/cast [target=mouseover,harm,nodead] Dispel Magic; [target=mouseover,help,nodead] Dispel Magic; Dispel Magic
```

```
#showtooltip Abolish Disease
/cast [target=mouseover,help,nodead] Abolish Disease; Abolish Disease
```

```
#showtooltip Cure Disease
/cast [target=mouseover,help,nodead] Cure Disease; Cure Disease
```

## Fade / Psychic Scream

```
#showtooltip Fade
/cast Fade
```

```
#showtooltip Psychic Scream
/cast Psychic Scream
```

## Shackle Undead

```
#showtooltip Shackle Undead
/stopcasting
/cast [target=mouseover,harm,nodead] Shackle Undead; Shackle Undead
```

## Silence (shadow talent)

```
#showtooltip Silence
/stopcasting
/cast Silence
```

## Mana Burn

```
#showtooltip Mana Burn
/cast Mana Burn
```

## Shadow Word: Pain / Mind Flay / Mind Blast

```
#showtooltip Shadow Word: Pain
/cast Shadow Word: Pain
```

Rank 1 SW:P (tag / contest):

```
#showtooltip Shadow Word: Pain(Rank 1)
/cast Shadow Word: Pain(Rank 1)
```

```
#showtooltip Mind Flay
/cast Mind Flay
```

```
#showtooltip Mind Blast
/cast Mind Blast
```

## Vampiric Embrace / Shadowform

```
#showtooltip Vampiric Embrace
/cast Vampiric Embrace
```

```
#showtooltip Shadowform
/cast Shadowform
```

Cancel Shadowform to use Holy (Era cannot heal in Shadowform):

```
/cancelaura Shadowform
```

Heal that cancels form first:

```
#showtooltip Flash Heal
/cancelaura Shadowform
/cast [target=mouseover,help,nodead] Flash Heal; Flash Heal
```

## Power Infusion (disc talent)

```
#showtooltip Power Infusion
/cast [target=mouseover,help,nodead] Power Infusion; Power Infusion
```

```
/raid PI on %t
/cast Power Infusion
```

## Inner Fire

```
#showtooltip Inner Fire
/cast Inner Fire
```

## Fear Ward

```
#showtooltip Fear Ward
/cast [target=mouseover,help,nodead] Fear Ward; Fear Ward
```

```
/raid Fear Ward on %t
/cast Fear Ward
```

## Resurrection / Prayer of Spirit / Fort / Shadow Protection

```
#showtooltip Resurrection
/cast [target=mouseover,help,dead] Resurrection; Resurrection
```

```
#showtooltip Power Word: Fortitude
/cast [target=mouseover,help,nodead] Power Word: Fortitude; Power Word: Fortitude
```

```
#showtooltip Prayer of Fortitude
/cast Prayer of Fortitude
```

```
#showtooltip Divine Spirit
/cast [target=mouseover,help,nodead] Divine Spirit; Divine Spirit
```

```
#showtooltip Prayer of Spirit
/cast Prayer of Spirit
```

```
#showtooltip Shadow Protection
/cast [target=mouseover,help,nodead] Shadow Protection; Shadow Protection
```

```
#showtooltip Prayer of Shadow Protection
/cast Prayer of Shadow Protection
```

## Wand

```
#showtooltip Shoot
/cast Shoot
```

## Racial / undead / night elf / dwarf extras

```
#showtooltip Desperate Prayer
/cast Desperate Prayer
```

```
#showtooltip Feedback
/cast Feedback
```

```
#showtooltip Starshards
/cast Starshards
```

```
#showtooltip Elune's Grace
/cast Elune's Grace
```

```
#showtooltip Hex of Weakness
/cast Hex of Weakness
```

```
#showtooltip Shadowguard
/cast Shadowguard
```

```
#showtooltip Touch of Weakness
/cast Touch of Weakness
```

```
#showtooltip Devouring Plague
/cast Devouring Plague
```

Troll mana hymn is not Classic Era. Troll racial:

```
#showtooltip Berserking
/cast Berserking
```

## Mind Control / Mind Soothe / Mind Vision

```
#showtooltip Mind Control
/cast Mind Control
```

```
#showtooltip Mind Soothe
/cast Mind Soothe
```

```
#showtooltip Mind Vision
/cast Mind Vision
```

## SoD note

SoD Shadow and Holy runes add spells. Mouseover + Alt-self pattern stays the same. Downrank still uses `Spell(Rank N)`.
