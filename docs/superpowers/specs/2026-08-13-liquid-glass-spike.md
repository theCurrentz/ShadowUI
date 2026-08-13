# Liquid-glass chrome spike

**Date:** 2026-08-13
**Status:** Spike complete — inspired chrome is feasible; true Apple Liquid Glass is not
**Target client:** Classic Era / Season of Discovery (`Interface 11509`)

## Question

Can ShadowUI’s Lua chrome look like Apple Liquid Glass (iOS 26 / macOS): a refractive, specular, backdrop-blurred material?

## Verdict

**Inspired glass: yes. Real liquid glass: no.**

A convincing *inspired* treatment is possible with APIs this addon already uses (`CreateTexture`, `SetColorTexture`, `SetGradient` + `CreateColor`, `SetBlendMode("ADD")`, alpha, layered draw levels). True Liquid Glass is not: addons cannot sample the framebuffer, run custom shaders, or blur/refract whatever sits behind a frame.

Default chrome stays matte black. Glass is an opt-in character theme (`/shadowui theme glass`) so combat-readable bars remain the shipped look.

## What Apple’s material actually does

| Cue | Client capability |
| --- | --- |
| Backdrop blur of content behind the panel | None. No Gaussian / frost API. |
| Refraction / lensing of the 3D world | None. No framebuffer read. |
| Adaptive tint from surroundings | None (could fake a fixed cool tint). |
| Specular highlight from a light source | Fake: additive top sheen + brighter top/left 1px rims. |
| Cursor- or time-varying specular | Possible via `OnUpdate` + `GetCursorPosition`; not in this spike (cost on every bar). |
| Continuous rounded corners | `CreateMaskTexture` exists on Era, but only with a mask image. Shipped circle masks (`TempPortraitAlphaMask`) look wrong on wide bars. Rounded rect needs a custom BLP. |
| Translucency so the world shows through | Yes. `SetColorTexture` with alpha < 1. |

## Approaches considered

1. **Layered fake glass (chosen)** — translucent fill, vertical additive sheen, 1px lit/dim rims, keep the existing soft shadow. Square corners. No custom art. Works on 1.15 with the same fallbacks as the cast bar gradient.
2. **Custom BLP kit** — pre-rendered frosted panels and rounded-rect masks. Better corners and grain; heavier pack, still no real blur of the world.
3. **Per-frame lighting** — move a specular blob with the cursor. Closer to Apple’s “live” glass; extra `OnUpdate` on every skinned frame. Rejected for the spike.

## Spike implementation

- `skin/glass.lua` builds six textures per frame: fill, sheen, four rims.
- Fill is cool dark (`~0.42` alpha) so Azeroth shows through without washing out icons.
- Icons stay opaque flush squares. Glass is chrome only.
- `ClearGlassPanel` restores matte by hiding those textures.
- Character DB `theme = "matte" | "glass"` (default matte).
- Chat and minimap use the same compositor when glass is active.
- Cast/GCD stay opaque: a translucent cast track fails the “readable under fire” bar.

## What to verify in-game

1. `/shadowui theme glass` — bar backdrops go translucent; icons unchanged.
2. Chat and minimap pick up the same rim/sheen; world/chat text still readable.
3. `/shadowui theme matte` — original black chrome returns, no leftover rims.
4. Enter combat, then `/shadowui theme glass` — skins defer like other applies.

## Follow-ups (not this spike)

- Custom rounded-rect mask BLP if corners matter.
- Cursor sheen only on hovered chrome, not a global `OnUpdate`.
- Whether glass should ever become the default (it fights the current matte spec).
