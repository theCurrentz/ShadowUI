# Rogue

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Rogue Combat — class-specific

Openers, Kick, finishers. /startattack on builders.

### st — `r-stealth`

```
#showtooltip Stealth
/cast Stealth
```

### sinister — `r-ss`

```
#showtooltip Sinister Strike
/startattack
/cast Sinister Strike
```

### kick — `r-kick`

```
#showtooltip Kick
/stopcasting
/cast Kick
```

### ev — `r-evis`

```
#showtooltip Eviscerate
/cast Eviscerate
```

### snd — `r-snd`

```
#showtooltip Slice and Dice
/cast Slice and Dice
```

### rup — `r-rup`

```
#showtooltip Rupture
/cast Rupture
```

### ks — `r-ks`

```
#showtooltip Kidney Shot
/cast Kidney Shot
```

### g — `r-gouge`

```
#showtooltip Gouge
/stopattack
/cast Gouge
```

### cheap — `r-cheap`

```
#showtooltip Cheap Shot
/cast [nostealth] Stealth
/cast Cheap Shot
```

### ambush — `r-ambush`

```
#showtooltip Ambush
/cast [nostealth] Stealth
/cast Ambush
```

### bf — `r-bf`

```
#showtooltip Blade Flurry
/use 13
/cast Blade Flurry
```

### ar — `r-ar`

```
#showtooltip Adrenaline Rush
/cast Adrenaline Rush
```

### eva — `r-eva`

```
#showtooltip Evasion
/cast Evasion
```

### van — `r-vanish`

```
#showtooltip Vanish
/stopattack
/cast Vanish
```

### sp — `r-sprint`

```
#showtooltip Sprint
/cast Sprint
```

### blind — `r-blind`

```
#showtooltip Blind
/cast Blind
```

### sap — `r-sap`

```
#showtooltip
/cast [nostealth] Stealth
/cast [mod:shift] Sap; Pick Pocket
```

### coldb — `r-cb`

```
#showtooltip Eviscerate
/cast Cold Blood
/cast Eviscerate
```

## Rogue ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### expose — `r-expose`

```
#showtooltip
/cast [nomod]Expose Armor;[mod:shift]Expose Armor(Rank 1)
```

### garrote — `r-garrote`

```
#showtooltip
/cast [nomod]Garrote;[mod:shift]Garrote(Rank 1)
```

### bstab — `r-bstab`

```
#showtooltip
/startattack
/cast [nomod]Backstab;[mod:shift]Backstab(Rank 1)
```

### feint — `r-feint`

```
#showtooltip
/cast [nomod]Feint;[mod:shift]Feint(Rank 1)
```

## Rogue TBC — class-specific — TBC

TBC Cloak, finishers, Shiv, and talent openers. Anesthetic Poison is an item; drag it to the bar.

### cloak — `r-cloak`

```
#showtooltip Cloak of Shadows
/stopcasting
/cast Cloak of Shadows
```

### dthrow — `r-dthrow`

```
#showtooltip Deadly Throw
/cast Deadly Throw
```

### shiv — `r-shiv`

```
#showtooltip Shiv
/startattack
/cast Shiv
```

### env — `r-env`

```
#showtooltip Envenom
/cast Envenom
```

### step — `r-step`

```
#showtooltip Shadowstep
/cast Shadowstep
```

### mut — `r-mut`

```
#showtooltip Mutilate
/startattack
/cast Mutilate
```
