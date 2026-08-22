# Warrior

**Stances:** `1` Battle, `2` Defensive, `3` Berserker.

## Charge (swap to Battle)

```
#showtooltip Charge
/cast [nostance:1] Battle Stance
/cast Charge
```

## Intercept (swap to Berserker)

```
#showtooltip Intercept
/cast [nostance:3] Berserker Stance
/cast Intercept
```

Charge or Intercept by combat state:

```
#showtooltip
/cast [nostance:1,nocombat] Battle Stance
/cast [nocombat] Charge
/cast [nostance:3,combat] Berserker Stance
/cast [combat] Intercept
```

That block is near the character cap. Drop `#showtooltip` if it will not save.

## Heroic Strike queue

```
#showtooltip Heroic Strike
/startattack
/cast Heroic Strike
```

Downrank rage control:

```
#showtooltip Heroic Strike(Rank 3)
/startattack
/cast Heroic Strike(Rank 3)
```

## Cleave queue

```
#showtooltip Cleave
/startattack
/cast Cleave
```

## Bloodrage then dump

```
#showtooltip Heroic Strike
/cast Bloodrage
/startattack
/cast Heroic Strike
```

## Overpower (Battle Stance)

```
#showtooltip Overpower
/cast [nostance:1] Battle Stance
/cast Overpower
```

## Revenge (Defensive)

```
#showtooltip Revenge
/cast [nostance:2] Defensive Stance
/cast Revenge
```

## Execute

```
#showtooltip Execute
/startattack
/cast Execute
```

Berserker Execute (Arms/Fury often sit in Berserker):

```
#showtooltip Execute
/cast [nostance:3] Berserker Stance
/startattack
/cast Execute
```

## Mortal Strike / Bloodthirst / Shield Slam

```
#showtooltip Mortal Strike
/startattack
/cast Mortal Strike
```

```
#showtooltip Bloodthirst
/startattack
/cast Bloodthirst
```

```
#showtooltip Shield Slam
/startattack
/cast Shield Slam
```

## Whirlwind (Berserker)

```
#showtooltip Whirlwind
/cast [nostance:3] Berserker Stance
/cast Whirlwind
```

## Slam (Arms — stop the swing timer reset by accident)

```
#showtooltip Slam
/startattack
/cast Slam
```

## Hamstring (Battle or Berserker)

```
#showtooltip Hamstring
/cast [stance:2] Battle Stance
/cast Hamstring
```

## Pummel (Berserker interrupt)

```
#showtooltip Pummel
/stopcasting
/cast [nostance:3] Berserker Stance
/cast Pummel
```

Stance swap costs a GCD. Many players keep Pummel on a Berserker bar and Shield Bash on a Defensive bar instead.

## Shield Bash (Defensive, shield equipped)

```
#showtooltip Shield Bash
/stopcasting
/cast [nostance:2] Defensive Stance
/cast Shield Bash
```

## Taunt / Mocking Blow / Challenging Shout

```
#showtooltip Taunt
/cast [nostance:2] Defensive Stance
/cast Taunt
```

Mouseover taunt:

```
#showtooltip Taunt
/cast [nostance:2] Defensive Stance
/cast [target=mouseover,harm,nodead] Taunt; Taunt
```

```
#showtooltip Mocking Blow
/cast [nostance:1] Battle Stance
/cast Mocking Blow
```

```
#showtooltip Challenging Shout
/cast Challenging Shout
```

## Disarm (Defensive)

```
#showtooltip Disarm
/cast [nostance:2] Defensive Stance
/cast Disarm
```

## Shield Block / Shield Wall / Last Stand

```
#showtooltip Shield Block
/cast [nostance:2] Defensive Stance
/cast Shield Block
```

```
#showtooltip Shield Wall
/cast [nostance:2] Defensive Stance
/cast Shield Wall
```

```
#showtooltip Last Stand
/cast Last Stand
```

## Recklessness / Retaliation / Sweeping Strikes

```
#showtooltip Recklessness
/cast [nostance:3] Berserker Stance
/cast Recklessness
```

```
#showtooltip Retaliation
/cast [nostance:1] Battle Stance
/cast Retaliation
```

```
#showtooltip Sweeping Strikes
/cast [nostance:1] Battle Stance
/cast Sweeping Strikes
```

## Berserker Rage (Fear / sap break)

```
#showtooltip Berserker Rage
/cast [nostance:3] Berserker Stance
/cast Berserker Rage
```

## Intimidating Shout

```
#showtooltip Intimidating Shout
/cast Intimidating Shout
```

## Shouts

```
#showtooltip Battle Shout
/cast Battle Shout
```

```
#showtooltip Demoralizing Shout
/cast Demoralizing Shout
```

Shift for Demo, else Battle:

```
#showtooltip
/cast [mod:shift] Demoralizing Shout; Battle Shout
```

## Rend / Thunder Clap / Sunder

```
#showtooltip Rend
/startattack
/cast Rend
```

```
#showtooltip Thunder Clap
/cast [nostance:1] Battle Stance
/cast Thunder Clap
```

```
#showtooltip Sunder Armor
/startattack
/cast Sunder Armor
```

## Stance only (no spell)

```
/cast Battle Stance
```

```
/cast Defensive Stance
```

```
/cast Berserker Stance
```

## SoD note

SoD runes add buttons (for example Quick Strike, Raging Blow, Devastate). Use the same `/startattack` + `/cast` pattern. Stance numbers stay 1/2/3.
