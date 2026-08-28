# Hunter

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Hunter core — class-specific

Mark, shots, Feign Death, pet. 18 or fewer.

### hmark — `h-mark`

```
#showtooltip Hunter's Mark
# class-specific HUNTER all
/cast Hunter's Mark
```

### asp — `h-aspect`

```
#showtooltip
# class-specific HUNTER all
/cast [mod:shift] Aspect of the Monkey; Aspect of the Hawk
```

### as — `h-aimed`

```
#showtooltip Aimed Shot
# class-specific HUNTER marksmanship
/cast Aimed Shot
```

### multi — `h-multi`

```
#showtooltip Multi-Shot
# class-specific HUNTER marksmanship
/cast Multi-Shot
```

### arc — `h-arcane`

```
#showtooltip
# class-specific HUNTER all
/cast [mod:shift] Arcane Shot(Rank 1); Arcane Shot
```

### sting — `h-sting`

```
#showtooltip Serpent Sting
# class-specific HUNTER all
/cast Serpent Sting
```

### conc — `h-conc`

```
#showtooltip Concussive Shot
# class-specific HUNTER all
/cast Concussive Shot
```

### wc — `h-clip`

```
#showtooltip
# class-specific HUNTER all
/cast [mod:shift] Wing Clip(Rank 1); Wing Clip
```

### fd — `h-fd`

```
#showtooltip Feign Death
# class-specific HUNTER all
/stopattack
/stopcasting
/cast Feign Death
```

### ft — `h-trap`

```
#showtooltip Freezing Trap
# class-specific HUNTER all
/cast Freezing Trap
```

### rapid — `h-rapid`

```
#showtooltip Rapid Fire
# class-specific HUNTER marksmanship
/use 13
/cast Rapid Fire
```

### tq — `h-tranq`

```
#showtooltip Tranquilizing Shot
# class-specific HUNTER all
/cast Tranquilizing Shot
```

### mp — `h-mend`

```
#showtooltip Mend Pet
# class-specific HUNTER beast-mastery
/cast Mend Pet
```

### pet — `h-call`

```
#showtooltip Call Pet
# class-specific HUNTER beast-mastery
/cast Call Pet
```

### bw — `h-bw`

```
#showtooltip Bestial Wrath
# class-specific HUNTER beast-mastery
/cast Bestial Wrath
```

### cheetah — `h-cheetah`

```
#showtooltip Aspect of the Cheetah
# class-specific HUNTER all
/cast Aspect of the Cheetah
```

## Hunter ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### wild — `h-wild`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Aspect of the Wild;[mod:shift]Aspect of the Wild(Rank 1)
```

### scare — `h-scare`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Scare Beast;[mod:shift]Scare Beast(Rank 1)
```

### dshot — `h-dshot`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Distracting Shot;[mod:shift]Distracting Shot(Rank 1)
```

### scorpid — `h-scorpid`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Scorpid Sting;[mod:shift]Scorpid Sting(Rank 1)
```

### viper — `h-viper`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Viper Sting;[mod:shift]Viper Sting(Rank 1)
```

### volley — `h-volley`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Volley;[mod:shift]Volley(Rank 1)
```

### diseng — `h-diseng`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Disengage;[mod:shift]Disengage(Rank 1)
```

### etrap — `h-etrap`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Explosive Trap;[mod:shift]Explosive Trap(Rank 1)
```

### itrap — `h-itrap`

```
#showtooltip
# class-specific HUNTER all
/cast [nomod]Immolation Trap;[mod:shift]Immolation Trap(Rank 1)
```

### mongo — `h-mongo`

```
#showtooltip
# class-specific HUNTER all
/startattack
/cast [nomod]Mongoose Bite;[mod:shift]Mongoose Bite(Rank 1)
```

### raptor — `h-raptor`

```
#showtooltip
# class-specific HUNTER all
/startattack
/cast [nomod]Raptor Strike;[mod:shift]Raptor Strike(Rank 1)
```

## Hunter TBC — class-specific — TBC

TBC shots, Kill Command, Misdirection, and Viper. Readiness is gone. Bestial Wrath stays in Hunter core.

### steady — `h-steady`

```
#showtooltip Steady Shot
# class-specific HUNTER all
/cast Steady Shot
```

### kc — `h-kc`

```
#showtooltip Kill Command
# class-specific HUNTER beast-mastery
/petattack
/cast Kill Command
```

### md — `h-md`

Friendly mouseover, then pet, then current target.

```
#showtooltip Misdirection
# class-specific HUNTER all
/cast [target=mouseover,help,nodead] Misdirection; [target=pet,exists] Misdirection; Misdirection
```

### snake — `h-snake`

```
#showtooltip Snake Trap
# class-specific HUNTER all
/cast Snake Trap
```

### aspv — `h-aspv`

Hawk normally. Shift is Viper. Ctrl is Monkey. Era `asp` has no Viper line.

```
#showtooltip
# class-specific HUNTER all
/cast [mod:shift] Aspect of the Viper; [mod:ctrl] Aspect of the Monkey; Aspect of the Hawk
```

## Auden pet kit — character-specific Auden

Character-specific Auden. Worg Carrier from the 372399535 account.

### worg — `h-worg`

```
#showtooltip
# character-specific HUNTER beast-mastery Auden
/cast Call Pet
/use Worg Carrier
```
