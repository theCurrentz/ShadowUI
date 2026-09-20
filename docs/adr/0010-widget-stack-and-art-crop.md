# Widget stack and Frame Art crop

Widgets on one Unit Frame must overlap. Frame Art is a targeting-frame atlas, not a stretchable box.

Each Widget has a **stack** integer (1–16). Higher stack paints in front. Stack is not a Profile Layer. The Designer Front/Back controls write `stack` on the active Profile.

Resizing or moving Frame Art **crops** `UI-TargetingFrame` UVs against the Baseline 232×100 box. It does not squash the whole silhouette. Host park size stays on the Unit Frame key. Layout Edit Mode still parks the host.

Studio drag uses host-local cursor space. Frame Art cannot persist a box larger than the host. Insane Profile numbers (from a bad drag) fall back to Baseline on apply.

## Considered Options

- Stretch Frame Art to the new box — rejected; that distorts the chrome.
- Call z-order a Layer — rejected; Layer was the old Profile inheritance word.
