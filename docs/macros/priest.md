# Priest

## Flash Heal

Alt self. Shift Rank 4 (tank spam). Ctrl Rank 1.

```
#showtooltip
/cast [mod:alt,target=player] Flash Heal; [mod:shift] Flash Heal(Rank 4); [mod:ctrl] Flash Heal(Rank 1); Flash Heal
```

## Greater Heal

```
#showtooltip
/stopcasting
/cast [mod:alt,target=player] Greater Heal; [mod:shift] Greater Heal(Rank 1); Greater Heal
```

Drop `/stopcasting` if you do not want this key to clip a heal that is about to land.

## Heal / Lesser Heal (early ranks)

```
#showtooltip Heal
/cast [mod:alt,target=player] Heal; Heal
```

## Renew

Shift Rank 3 (5SR / small HoT).

```
#showtooltip
/cast [mod:alt,target=player] Renew; [mod:shift] Renew(Rank 3); Renew
```

## Power Word: Shield

Shift Rank 1 (less absorb, less threat; Weakened Soul still applies).

```
#showtooltip
/cast [mod:alt,target=player] Power Word: Shield; [mod:shift] Power Word: Shield(Rank 1); Power Word: Shield
```

## Inner Focus + big heal

```
#showtooltip Greater Heal
/cast Inner Focus
/cast Greater Heal
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

Shift Rank 1 (low threat AoE / tag):

```
#showtooltip
/cast [mod:shift] Holy Nova(Rank 1); Holy Nova
```

## Circle of Healing

Not in Classic Era. Skip it.

## Dispel Magic / Abolish Disease

```
#showtooltip Dispel Magic
/cast [mod:alt,target=player] Dispel Magic; Dispel Magic
```

Offensive dispel wants `harm`. Split if you mis-dispel:

```
#showtooltip Dispel Magic
/cast [harm] Dispel Magic; [help] Dispel Magic
```

```
#showtooltip Abolish Disease
/cast [mod:alt,target=player] Abolish Disease; Abolish Disease
```

```
#showtooltip Cure Disease
/cast [mod:alt,target=player] Cure Disease; Cure Disease
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
/cast Shackle Undead
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

Shift Rank 1 (tag / contest):

```
#showtooltip
/cast [mod:shift] Shadow Word: Pain(Rank 1); Shadow Word: Pain
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
/cast [mod:alt,target=player] Flash Heal; Flash Heal
```

## Power Infusion (disc talent)

```
#showtooltip Power Infusion
/cast [mod:alt,target=player] Power Infusion; Power Infusion
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
/cast [mod:alt,target=player] Fear Ward; Fear Ward
```

```
/raid Fear Ward on %t
/cast Fear Ward
```

## Resurrection / Prayer of Spirit / Fort / Shadow Protection

```
#showtooltip Resurrection
/cast Resurrection
```

```
#showtooltip Power Word: Fortitude
/cast [mod:alt,target=player] Power Word: Fortitude; Power Word: Fortitude
```

```
#showtooltip Prayer of Fortitude
/cast Prayer of Fortitude
```

```
#showtooltip Divine Spirit
/cast [mod:alt,target=player] Divine Spirit; Divine Spirit
```

```
#showtooltip Prayer of Spirit
/cast Prayer of Spirit
```

```
#showtooltip Shadow Protection
/cast [mod:alt,target=player] Shadow Protection; Shadow Protection
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

SoD Shadow and Holy runes add spells. Alt-self and Shift/Ctrl downrank stay the same. Downrank still uses `Spell(Rank N)`.
