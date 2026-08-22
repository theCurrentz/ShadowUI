# Hunter

## Hunter's Mark

```
#showtooltip Hunter's Mark
/cast Hunter's Mark
```

## Aspects

Hawk vs Monkey (melee pressure):

```
#showtooltip
/cast [mod:shift] Aspect of the Monkey; Aspect of the Hawk
```

Cheetah (out of combat run). Pack is the group version.

```
#showtooltip Aspect of the Cheetah
/cast Aspect of the Cheetah
```

```
#showtooltip Aspect of the Pack
/cast Aspect of the Pack
```

```
#showtooltip Aspect of the Wild
/cast Aspect of the Wild
```

```
#showtooltip Aspect of the Beast
/cast Aspect of the Beast
```

Viper is TBC. Era mana regen is drinks, trinkets, and viper... wait, Aspect of the Viper is TBC. Classic Era has no Viper.

## Auto Shot / stop

```
/startattack
```

```
/stopattack
```

## Aimed Shot (marksmanship)

```
#showtooltip Aimed Shot
/cast Aimed Shot
```

## Multi-Shot

```
#showtooltip Multi-Shot
/cast Multi-Shot
```

## Arcane Shot

Shift Rank 1 (mana / tag):

```
#showtooltip
/cast [mod:shift] Arcane Shot(Rank 1); Arcane Shot
```

## Serpent Sting / Scorpid / Viper

```
#showtooltip Serpent Sting
/cast Serpent Sting
```

```
#showtooltip Scorpid Sting
/cast Scorpid Sting
```

```
#showtooltip Viper Sting
/cast Viper Sting
```

## Concussive Shot / Wing Clip

```
#showtooltip Concussive Shot
/cast Concussive Shot
```

Shift Rank 1 still snares with less damage:

```
#showtooltip
/cast [mod:shift] Wing Clip(Rank 1); Wing Clip
```

## Scatter Shot (surv talent)

```
#showtooltip Scatter Shot
/stopattack
/cast Scatter Shot
```

## Wyvern Sting (surv talent)

```
#showtooltip Wyvern Sting
/cast Wyvern Sting
```

## Tranquilizing Shot

```
#showtooltip Tranquilizing Shot
/cast Tranquilizing Shot
```

## Rapid Fire / Bestial Wrath / Intimidation

```
#showtooltip Rapid Fire
/cast Rapid Fire
```

```
#showtooltip Bestial Wrath
/cast Bestial Wrath
```

```
#showtooltip Intimidation
/cast Intimidation
```

Trinket + Rapid Fire:

```
#showtooltip Rapid Fire
/use 13
/cast Rapid Fire
```

## Feign Death

```
#showtooltip Feign Death
/stopattack
/stopcasting
/cast Feign Death
```

## Freezing Trap (after FD — two presses is more reliable)

Trap only:

```
#showtooltip Freezing Trap
/cast Freezing Trap
```

Frost Trap / Explosive Trap / Immolation Trap as their own keys.

FD then trap on one key is racey. Prefer:

1. Feign Death macro
2. Trap key after the feign applies

## Flare / Volley

```
#showtooltip Flare
/cast Flare
```

```
#showtooltip Volley
/cast Volley
```

## Disengage

Not in Classic Era. Do not add it.

## Pet: attack, follow, passive, wait

```
/petattack
```

```
/petfollow
```

```
/petpassive
```

```
/petwait
```

Attack pet's target or yours:

```
/petattack [@target,harm,exists]
/startattack
```

## Mend Pet / Feed Pet / Dismiss / Call

```
#showtooltip Mend Pet
/cast Mend Pet
```

```
#showtooltip Feed Pet
/cast Feed Pet
```

```
#showtooltip Dismiss Pet
/cast Dismiss Pet
```

```
#showtooltip Call Pet
/cast Call Pet
```

Revive:

```
#showtooltip Revive Pet
/cast Revive Pet
```

## Eyes of the Beast / Eagle Eye

```
#showtooltip Eyes of the Beast
/cast Eyes of the Beast
```

## Track

```
#showtooltip Track Humanoids
/cast Track Humanoids
```

```
#showtooltip Track Hidden
/cast Track Hidden
```

```
#showtooltip Track Beasts
/cast Track Beasts
```

Shift humanoids / else hidden (stealth detect):

```
#showtooltip
/cast [mod:shift] Track Humanoids; Track Hidden
```

## SoD note

SoD adds melee hunter runes and new shots. Keep Feign Death on `/stopattack` + `/stopcasting`. Pet slash commands do not change.
