# Unit Frame Designer keeps SetPoint relativeTo

A drag that calls `GetPoint` after `StartMoving` re-parents the Widget to the host or UIParent. Status Text would store host offsets and drop `relativeTo = "health"`.

Designer persist converts the new canvas rect into offsets for the existing `point`, `relativePoint`, and `relativeTo`, then writes that patch on the active Profile. The studio lives on the `/shadowui` Unit Frames page. It does not overlay HUD chips on the live Player Frame. Layout Edit Mode still parks the host on the screen. Frame Art crop and Widget stack are [ADR 0010](0010-widget-stack-and-art-crop.md).

## Considered Options

- Persist `GetPoint(1)` after overlay `StartMoving` — rejected; it flattens Widget anchors.
- HUD chips on the live Player Frame and Target Frame — rejected; the builder is a preview inside `/shadowui`.
- Browser geometry sidecar — rejected; Designer is in-game only.
