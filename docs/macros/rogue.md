# Rogue

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Rogue Combat — class-specific

Openers, Kick, finishers. /startattack on builders.

### st — `r-stealth`

```
#showtooltip Stealth
# class-specific ROGUE all
/cast Stealth
```

### sinister — `r-ss`

```
#showtooltip Sinister Strike
# class-specific ROGUE combat
/startattack
/cast Sinister Strike
```

### kick — `r-kick`

```
#showtooltip Kick
# class-specific ROGUE all
/stopcasting
/cast Kick
```

### ev — `r-evis`

```
#showtooltip Eviscerate
# class-specific ROGUE all
/cast Eviscerate
```

### snd — `r-snd`

```
#showtooltip Slice and Dice
# class-specific ROGUE combat
/cast Slice and Dice
```

### rup — `r-rup`

```
#showtooltip Rupture
# class-specific ROGUE assassination
/cast Rupture
```

### ks — `r-ks`

```
#showtooltip Kidney Shot
# class-specific ROGUE assassination
/cast Kidney Shot
```

### g — `r-gouge`

```
#showtooltip Gouge
# class-specific ROGUE combat
/stopattack
/cast Gouge
```

### cheap — `r-cheap`

```
#showtooltip Cheap Shot
# class-specific ROGUE all
/cast [nostealth] Stealth
/cast Cheap Shot
```

### ambush — `r-ambush`

```
#showtooltip Ambush
# class-specific ROGUE assassination
/cast [nostealth] Stealth
/cast Ambush
```

### bf — `r-bf`

```
#showtooltip Blade Flurry
# class-specific ROGUE combat
/use 13
/cast Blade Flurry
```

### ar — `r-ar`

```
#showtooltip Adrenaline Rush
# class-specific ROGUE combat
/cast Adrenaline Rush
```

### eva — `r-eva`

```
#showtooltip Evasion
# class-specific ROGUE combat
/cast Evasion
```

### van — `r-vanish`

```
#showtooltip Vanish
# class-specific ROGUE subtlety
/stopattack
/cast Vanish
```

### sp — `r-sprint`

```
#showtooltip Sprint
# class-specific ROGUE all
/cast Sprint
```

### blind — `r-blind`

```
#showtooltip Blind
# class-specific ROGUE all
/cast Blind
```

### sap — `r-sap`

```
#showtooltip
# class-specific ROGUE all
/cast [nostealth] Stealth
/cast [mod:shift] Sap; Pick Pocket
```

### coldb — `r-cb`

```
#showtooltip Eviscerate
# class-specific ROGUE assassination
/cast Cold Blood
/cast Eviscerate
```

## Rogue ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### expose — `r-expose`

```
#showtooltip
# class-specific ROGUE all
/cast [nomod]Expose Armor;[mod:shift]Expose Armor(Rank 1)
```

### garrote — `r-garrote`

```
#showtooltip
# class-specific ROGUE all
/cast [nomod]Garrote;[mod:shift]Garrote(Rank 1)
```

### bstab — `r-bstab`

```
#showtooltip
# class-specific ROGUE all
/startattack
/cast [nomod]Backstab;[mod:shift]Backstab(Rank 1)
```

### feint — `r-feint`

```
#showtooltip
# class-specific ROGUE all
/cast [nomod]Feint;[mod:shift]Feint(Rank 1)
```

## Rogue TBC — class-specific — TBC

TBC Cloak, finishers, Shiv, and talent openers. Anesthetic Poison is an item; drag it to the bar.

### cloak — `r-cloak`

```
#showtooltip Cloak of Shadows
# class-specific ROGUE all
/stopcasting
/cast Cloak of Shadows
```

### dthrow — `r-dthrow`

```
#showtooltip Deadly Throw
# class-specific ROGUE all
/cast Deadly Throw
```

### shiv — `r-shiv`

```
#showtooltip Shiv
# class-specific ROGUE all
/startattack
/cast Shiv
```

### env — `r-env`

```
#showtooltip Envenom
# class-specific ROGUE assassination
/cast Envenom
```

### step — `r-step`

```
#showtooltip Shadowstep
# class-specific ROGUE subtlety
/cast Shadowstep
```

### mut — `r-mut`

```
#showtooltip Mutilate
# class-specific ROGUE assassination
/startattack
/cast Mutilate
```
