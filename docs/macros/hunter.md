# Hunter

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Hunter core — class-specific

Mark, shots, Feign Death, pet. 18 or fewer.

### hmark — `h-mark`

```
#showtooltip Hunter's Mark
/cast Hunter's Mark
```

### asp — `h-aspect`

```
#showtooltip
/cast [mod:shift] Aspect of the Monkey; Aspect of the Hawk
```

### as — `h-aimed`

```
#showtooltip Aimed Shot
/cast Aimed Shot
```

### multi — `h-multi`

```
#showtooltip Multi-Shot
/cast Multi-Shot
```

### arc — `h-arcane`

```
#showtooltip
/cast [mod:shift] Arcane Shot(Rank 1); Arcane Shot
```

### sting — `h-sting`

```
#showtooltip Serpent Sting
/cast Serpent Sting
```

### conc — `h-conc`

```
#showtooltip Concussive Shot
/cast Concussive Shot
```

### wc — `h-clip`

```
#showtooltip
/cast [mod:shift] Wing Clip(Rank 1); Wing Clip
```

### fd — `h-fd`

```
#showtooltip Feign Death
/stopattack
/stopcasting
/cast Feign Death
```

### ft — `h-trap`

```
#showtooltip Freezing Trap
/cast Freezing Trap
```

### rapid — `h-rapid`

```
#showtooltip Rapid Fire
/use 13
/cast Rapid Fire
```

### tq — `h-tranq`

```
#showtooltip Tranquilizing Shot
/cast Tranquilizing Shot
```

### mp — `h-mend`

```
#showtooltip Mend Pet
/cast Mend Pet
```

### pet — `h-call`

```
#showtooltip Call Pet
/cast Call Pet
```

### bw — `h-bw`

```
#showtooltip Bestial Wrath
/cast Bestial Wrath
```

### cheetah — `h-cheetah`

```
#showtooltip Aspect of the Cheetah
/cast Aspect of the Cheetah
```

## Hunter ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### wild — `h-wild`

```
#showtooltip
/cast [nomod]Aspect of the Wild;[mod:shift]Aspect of the Wild(Rank 1)
```

### scare — `h-scare`

```
#showtooltip
/cast [nomod]Scare Beast;[mod:shift]Scare Beast(Rank 1)
```

### dshot — `h-dshot`

```
#showtooltip
/cast [nomod]Distracting Shot;[mod:shift]Distracting Shot(Rank 1)
```

### scorpid — `h-scorpid`

```
#showtooltip
/cast [nomod]Scorpid Sting;[mod:shift]Scorpid Sting(Rank 1)
```

### viper — `h-viper`

```
#showtooltip
/cast [nomod]Viper Sting;[mod:shift]Viper Sting(Rank 1)
```

### volley — `h-volley`

```
#showtooltip
/cast [nomod]Volley;[mod:shift]Volley(Rank 1)
```

### diseng — `h-diseng`

```
#showtooltip
/cast [nomod]Disengage;[mod:shift]Disengage(Rank 1)
```

### etrap — `h-etrap`

```
#showtooltip
/cast [nomod]Explosive Trap;[mod:shift]Explosive Trap(Rank 1)
```

### itrap — `h-itrap`

```
#showtooltip
/cast [nomod]Immolation Trap;[mod:shift]Immolation Trap(Rank 1)
```

### mongo — `h-mongo`

```
#showtooltip
/startattack
/cast [nomod]Mongoose Bite;[mod:shift]Mongoose Bite(Rank 1)
```

### raptor — `h-raptor`

```
#showtooltip
/startattack
/cast [nomod]Raptor Strike;[mod:shift]Raptor Strike(Rank 1)
```

## Hunter TBC — class-specific — TBC

TBC shots, Kill Command, Misdirection, and Viper. Readiness is gone. Bestial Wrath stays in Hunter core.

### steady — `h-steady`

```
#showtooltip Steady Shot
/cast Steady Shot
```

### kc — `h-kc`

```
#showtooltip Kill Command
/petattack
/cast Kill Command
```

### md — `h-md`

Friendly mouseover, then pet, then current target.

```
#showtooltip Misdirection
/cast [target=mouseover,help,nodead] Misdirection; [target=pet,exists] Misdirection; Misdirection
```

### snake — `h-snake`

```
#showtooltip Snake Trap
/cast Snake Trap
```

### aspv — `h-aspv`

Hawk normally. Shift is Viper. Ctrl is Monkey. Era `asp` has no Viper line.

```
#showtooltip
/cast [mod:shift] Aspect of the Viper; [mod:ctrl] Aspect of the Monkey; Aspect of the Hawk
```

## Auden pet kit — character-specific Auden

Character-specific Auden. Worg Carrier from the 372399535 account.

### worg — `h-worg`

```
#showtooltip
/cast Call Pet
/use Worg Carrier
```
