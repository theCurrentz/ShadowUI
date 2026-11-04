# ShadowUI Unit Frames replace Blizzard Player and Target hosts

Superseded by [ADR 0012](0012-blizzard-unit-frames-and-no-cast-stack.md). Player Frame and Target Frame stay Blizzard.

# Original

Sharing Blizzard `PlayerFrame` and `TargetFrame` with Layout already causes SetPoint fights, 1.15.9 `SetPointBase` resets, CheckClassification texture fights, and Focus/ToT family errors. A Unit Frame Designer that moves Widgets inside those hosts would multiply that fight.

ShadowUI owns the Player Frame and Target Frame, the same way it owns Bars (ADR 0006). Shipped Layout is a Baseline that matches the Classic targeting frame. Unit Frame Designer writes Widget deltas on the active Profile. Blizzard Player and Target hosts hide after the ShadowUI hosts are live. Focus, Pet, Party, and Nameplates stay Blizzard.

Until that cutover, ShadowUI builds the hosts hidden and Chrome still paints the Blizzard frames.

## Considered Options

- Mutate Blizzard regions in place — rejected; ParkFrame history already shows the host fight.
- Ship a different default look — rejected; Baseline lets Unit Frame Designer start from Blizzard.
