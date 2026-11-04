# Blizzard Player and Target hosts; no combat HUD

ShadowUI Unit Frames fought Blizzard SetPoint, classification art, and Focus/ToT. The Cast Bar stack (Cast Bar, GCD Sweep, Swing Timer, Mana Ticker) was a second combat HUD the player no longer wants.

Player Frame and Target Frame stay Blizzard. Chrome still Darkens their art. ShadowUI does not add a Threat Bar, Crowd Control Portrait, Range Display, or Shield Row. Those features need secret or removed APIs (`UnitAura`, `CombatLogGetCurrentEventInfo`, `UnitDetailedThreatSituation` compares, LibRangeCheck). Layout Edit Mode does not park Player Frame, Target Frame, or a Cast Bar.

## Considered Options

- Keep ShadowUI hosts hidden until cutover — rejected; the hosts and Designer still cost Layout and tests.
- Keep Meter Fill, Portrait Ring, Combo Points, Aggro Glow, Aura Duration, Threat Bar, and Crowd Control Portrait on Blizzard frames — rejected; those are Unit Frame or combat-HUD features.
- Scan auras with `UnitAura` because `C_UnitAuras.GetAuraDataByIndex` is secret — rejected; Mainline removed `UnitAura` in 11.0.2.
