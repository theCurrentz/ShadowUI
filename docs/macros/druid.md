# Druid

**Forms (typical Era index):** `1` Bear (or Dire Bear), `2` Aquatic, `3` Cat, `4` Travel. Moonkin is a talent form and can shift the index. Test `form:N` on your character if a macro misses.

`/cancelform` leaves any shapeshift so you can heal or innervate.

## Cancel form + heal

```
#showtooltip Healing Touch
/cancelform
/cast [mod:alt,target=player] Healing Touch; [target=mouseover,help,nodead] Healing Touch; Healing Touch
```

## Healing Touch ranks

```
#showtooltip Healing Touch(Rank 4)
/cancelform
/cast [target=mouseover,help,nodead] Healing Touch(Rank 4); Healing Touch(Rank 4)
```

```
#showtooltip Healing Touch(Rank 1)
/cancelform
/cast [target=mouseover,help,nodead] Healing Touch(Rank 1); Healing Touch(Rank 1)
```

## Regrowth / Rejuvenation

```
#showtooltip Regrowth
/cancelform
/cast [mod:alt,target=player] Regrowth; [target=mouseover,help,nodead] Regrowth; Regrowth
```

```
#showtooltip Rejuvenation
/cancelform
/cast [mod:alt,target=player] Rejuvenation; [target=mouseover,help,nodead] Rejuvenation; Rejuvenation
```

Downrank Rejuvenation:

```
#showtooltip Rejuvenation(Rank 3)
/cancelform
/cast [target=mouseover,help,nodead] Rejuvenation(Rank 3); Rejuvenation(Rank 3)
```

## Swiftmend (resto talent)

```
#showtooltip Swiftmend
/cancelform
/cast [target=mouseover,help,nodead] Swiftmend; Swiftmend
```

## Nature's Swiftness + Healing Touch

```
#showtooltip Healing Touch
/cancelform
/cast Nature's Swiftness
/cast [target=mouseover,help,nodead] Healing Touch; Healing Touch
```

## Tranquility

```
#showtooltip Tranquility
/cancelform
/cast Tranquility
```

## Innervate

```
#showtooltip Innervate
/cancelform
/cast [mod:alt,target=player] Innervate; [target=mouseover,help,nodead] Innervate; Innervate
```

```
/raid Innervate on %t
```

## Rebirth

```
#showtooltip Rebirth
/cancelform
/cast [target=mouseover,help,dead] Rebirth; Rebirth
```

```
/raid {rt8} Rebirth on %t {rt8}
/cast Rebirth
```

## Remove Curse / Abolish Poison

```
#showtooltip Remove Curse
/cancelform
/cast [mod:alt,target=player] Remove Curse; [target=mouseover,help,nodead] Remove Curse; Remove Curse
```

```
#showtooltip Abolish Poison
/cancelform
/cast [mod:alt,target=player] Abolish Poison; [target=mouseover,help,nodead] Abolish Poison; Abolish Poison
```

```
#showtooltip Cure Poison
/cancelform
/cast [target=mouseover,help,nodead] Cure Poison; Cure Poison
```

## Mark of the Wild / Thorns / Gift

```
#showtooltip Mark of the Wild
/cancelform
/cast [target=mouseover,help,nodead] Mark of the Wild; Mark of the Wild
```

```
#showtooltip Gift of the Wild
/cancelform
/cast Gift of the Wild
```

```
#showtooltip Thorns
/cancelform
/cast [target=mouseover,help,nodead] Thorns; Thorns
```

## Hibernate / Entangling Roots / Nature's Grasp / Cyclone

Cyclone is TBC. Era:

```
#showtooltip Hibernate
/cancelform
/cast [target=mouseover,harm,nodead] Hibernate; Hibernate
```

```
#showtooltip Entangling Roots
/cancelform
/cast Entangling Roots
```

Rank 1 roots (pvp / kite):

```
#showtooltip Entangling Roots(Rank 1)
/cancelform
/cast Entangling Roots(Rank 1)
```

```
#showtooltip Nature's Grasp
/cast Nature's Grasp
```

## Moonfire / Wrath / Starfire / Insect Swarm / Hurricane

```
#showtooltip Moonfire
/cast Moonfire
```

Rank 1 Moonfire (tag):

```
#showtooltip Moonfire(Rank 1)
/cast Moonfire(Rank 1)
```

```
#showtooltip Wrath
/cast Wrath
```

```
#showtooltip Starfire
/cast Starfire
```

```
#showtooltip Insect Swarm
/cast Insect Swarm
```

```
#showtooltip Hurricane
/cast Hurricane
```

## Faerie Fire (caster vs feral)

```
#showtooltip Faerie Fire
/cast Faerie Fire
```

```
#showtooltip Faerie Fire (Feral)
/cast Faerie Fire (Feral)
```

One key that prefers feral in cat/bear:

```
#showtooltip
/cast [form:1/3] Faerie Fire (Feral); Faerie Fire
```

Form numbers must match your character. If Moonkin is form 5, add it.

## Barkskin / Omen of Clarity / Nature's Grace

```
#showtooltip Barkskin
/cast Barkskin
```

Omen is a talent proc, not a spam button.

## Bear: Growl / Maul / Swipe / Demoralizing Roar / Enrage / Frenzied Regeneration

```
#showtooltip Growl
/cast [noform:1] Dire Bear Form
/cast Growl
```

Use `Bear Form` until you train Dire Bear.

Mouseover Growl:

```
#showtooltip Growl
/cast [target=mouseover,harm,nodead] Growl; Growl
```

```
#showtooltip Maul
/startattack
/cast Maul
```

```
#showtooltip Swipe
/startattack
/cast Swipe
```

```
#showtooltip Demoralizing Roar
/cast Demoralizing Roar
```

```
#showtooltip Enrage
/cast Enrage
```

```
#showtooltip Frenzied Regeneration
/cast Frenzied Regeneration
```

```
#showtooltip Challenging Roar
/cast Challenging Roar
```

```
#showtooltip Bash
/stopcasting
/cast Bash
```

Bash is the bear interrupt/stun.

```
#showtooltip Feral Charge
/cast Feral Charge
```

## Cat: Prowl / Claw / Rake / Rip / Ferocious Bite / Shred / Ravage / Pounce

```
#showtooltip Prowl
/cast [noform:3] Cat Form
/cast Prowl
```

```
#showtooltip Claw
/startattack
/cast Claw
```

```
#showtooltip Shred
/startattack
/cast Shred
```

```
#showtooltip Rake
/startattack
/cast Rake
```

```
#showtooltip Rip
/cast Rip
```

```
#showtooltip Ferocious Bite
/cast Ferocious Bite
```

```
#showtooltip Ferocious Bite(Rank 1)
/cast Ferocious Bite(Rank 1)
```

```
#showtooltip Ravage
/cast [nostealth] Prowl
/cast Ravage
```

```
#showtooltip Pounce
/cast [nostealth] Prowl
/cast Pounce
```

```
#showtooltip Tiger's Fury
/cast Tiger's Fury
```

```
#showtooltip Dash
/cast Dash
```

```
#showtooltip Cower
/cast Cower
```

```
#showtooltip Track Humanoids
/cast Track Humanoids
```

## Travel / Aquatic / caster form

```
#showtooltip Travel Form
/cast Travel Form
```

```
#showtooltip Aquatic Form
/cast Aquatic Form
```

```
#showtooltip Dire Bear Form
/cast Dire Bear Form
```

```
#showtooltip Cat Form
/cast Cat Form
```

```
#showtooltip Moonkin Form
/cast Moonkin Form
```

Shift travel, else cat (example):

```
#showtooltip
/cast [mod:shift] Travel Form; Cat Form
```

## SoD note

SoD feral and balance runes add strikes and starsurge-like spells. `/cancelform` before a heal still matters. Maul still needs `/startattack`.
