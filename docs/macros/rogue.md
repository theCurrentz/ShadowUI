# Rogue

## Stealth

```
#showtooltip Stealth
/cast Stealth
```

Cancel stealth:

```
/cancelaura Stealth
```

## Cheap Shot opener

```
#showtooltip Cheap Shot
/cast [nostealth] Stealth
/cast Cheap Shot
```

## Ambush / Garrote / Premeditation

```
#showtooltip Ambush
/cast [nostealth] Stealth
/cast Ambush
```

```
#showtooltip Garrote
/cast [nostealth] Stealth
/cast Garrote
```

```
#showtooltip Premeditation
/cast [nostealth] Stealth
/cast Premeditation
```

## Pick Pocket then Sap

```
#showtooltip Pick Pocket
/cast [nostealth] Stealth
/cast Pick Pocket
```

```
#showtooltip Sap
/cast [nostealth] Stealth
/cast Sap
```

Modifier: shift sap, else pick pocket:

```
#showtooltip
/cast [nostealth] Stealth
/cast [mod:shift] Sap; Pick Pocket
```

## Kick (interrupt)

```
#showtooltip Kick
/stopcasting
/cast Kick
```

Mouseover kick:

```
#showtooltip Kick
/stopcasting
/cast [target=mouseover,harm,nodead] Kick; Kick
```

## Gouge

```
#showtooltip Gouge
/stopattack
/cast Gouge
```

`/stopattack` helps the Gouge land if a swing would break it.

## Kidney Shot

```
#showtooltip Kidney Shot
/cast Kidney Shot
```

## Eviscerate / Rupture / Slice and Dice

```
#showtooltip Eviscerate
/cast Eviscerate
```

```
#showtooltip Rupture
/cast Rupture
```

```
#showtooltip Slice and Dice
/cast Slice and Dice
```

Cold Blood + Eviscerate (assa talent):

```
#showtooltip Eviscerate
/cast Cold Blood
/cast Eviscerate
```

## Backstab / Hemorrhage / Ghostly Strike / Sinister Strike

```
#showtooltip Backstab
/startattack
/cast Backstab
```

```
#showtooltip Sinister Strike
/startattack
/cast Sinister Strike
```

```
#showtooltip Hemorrhage
/startattack
/cast Hemorrhage
```

```
#showtooltip Ghostly Strike
/startattack
/cast Ghostly Strike
```

## Expose Armor

```
#showtooltip Expose Armor
/cast Expose Armor
```

## Feint

```
#showtooltip Feint
/cast Feint
```

## Blade Flurry / Adrenaline Rush / Evasion

```
#showtooltip Blade Flurry
/cast Blade Flurry
```

```
#showtooltip Adrenaline Rush
/cast Adrenaline Rush
```

```
#showtooltip Evasion
/cast Evasion
```

Trinket + Blade Flurry:

```
#showtooltip Blade Flurry
/use 13
/cast Blade Flurry
```

## Vanish / Preparation / Sprint

```
#showtooltip Vanish
/stopattack
/cast Vanish
```

```
#showtooltip Preparation
/cast Preparation
```

```
#showtooltip Sprint
/cast Sprint
```

## Blind / Distract / Cheap Shot from vanish

```
#showtooltip Blind
/cast Blind
```

```
#showtooltip Distract
/cast Distract
```

## Throw / Shoot (pull)

```
#showtooltip Throw
/cast Throw
```

```
#showtooltip Shoot
/cast Shoot
```

## Cannibalize

Troll racial, not a rogue spell. If you are a Troll rogue:

```
#showtooltip Cannibalize
/cast Cannibalize
```

## SoD note

SoD runes (for example Saber Slash, Between the Eyes) follow `/startattack` + `/cast`. Kick still wants `/stopcasting`.
