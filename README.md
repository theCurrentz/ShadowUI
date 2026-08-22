# ShadowUI

ShadowUI is an opinionated World of Warcraft UI addon for action bars, interface chrome, and cast bars. It supports Classic Era and Season of Discovery only.

## Installation

Copy the addon directory to `Interface/AddOns/ShadowUI`, then enable ShadowUI from the character selection screen. On first apply each session, ShadowUI turns Auto Loot on for that Character.

## Configuration

- `/shadowui` or `/sui` opens the options.
- `/shadowui edit` toggles Layout Edit Mode (HUD overlay, snap grid, drag Bars, Player Frame, Target Frame, Cast Bar, and Range Display). Hold Shift while dragging to skip snap.
- `/shadowui binds` toggles Keybind Edit Mode (hover a button, press a key).
- `/shadowui layer base|class|variant` sets the layer changed by either edit session.
- `/shadowui variant <name>` manually activates a variant.
- `/shadowui variant clear` clears the manual variant override.

## Layout inheritance

Every layout resolves through Base → Class → Variant. Base provides shared defaults, Class applies class-specific settings, and the active Variant applies the final situational overrides.

Terms: [CONTEXT.md](CONTEXT.md). Module layout and resolve rules: [docs/architecture.md](docs/architecture.md).

## Options

Open with `/shadowui` or `/sui`. The panel covers variants, talent-tree binding, Action Slot hard lock, edit-layer selection, Layout Edit Mode, Keybind Edit Mode, and resets. It does not contain bar-layout sliders.

Action buttons stay locked: a click uses the action. Shift-drag moves a spell or item to another Action Slot and does not use the action. Enable **Hard lock action slots** to block Shift-drag too.

## Testing

Automated checks (plain Lua, no client needed):

```bash
lua tests/resolve_spec.lua
lua tests/layout_spec.lua
lua tests/api_shapes_spec.lua
lua tests/slash_spec.lua
lua tests/auto_loot_spec.lua
lua tests/keybinds_spec.lua
lua tests/edit_session_spec.lua
lua tests/edit_hud_spec.lua
lua tests/edit_unit_spec.lua
lua tests/edit_meters_spec.lua
lua tests/apply_bars_spec.lua
lua tests/button_create_spec.lua
lua tests/button_lock_spec.lua
lua tests/button_skin_spec.lua
lua tests/micro_bags_spec.lua
lua tests/micro_menu_spec.lua
lua tests/park_main_menu_spec.lua
lua tests/tracking_spec.lua
lua tests/darken_spec.lua
lua tests/minimap_spec.lua
lua tests/auras_spec.lua
lua tests/aura_duration_spec.lua
lua tests/status_text_spec.lua
lua tests/threat_spec.lua
lua tests/rare_elite_spec.lua
lua tests/cooldown_count_spec.lua
lua tests/chat_spec.lua
lua tests/unit_park_spec.lua
lua tests/details_spec.lua
lua tests/itemrack_spec.lua
lua tests/mana_ticker_spec.lua
lua tests/swing_spec.lua
lua tests/range_spec.lua
lua tests/shields_spec.lua
lua tests/cast_spec.lua
lua tests/sim_layout_spec.lua
```

`slash_spec` asserts `/sui` uses the same handler as `/shadowui`.
`resolve_spec` covers layer merging, layer writes, and talent-tab parsing for both the
Classic Era and modernized `GetTalentTabInfo` signatures. `layout_spec` asserts every
shipped bar stays within ±360 of screen centre and never overlaps another bar or the
cast bar. `api_shapes_spec` covers the `SetGradient` path with its solid-colour
fallback and pet action returns with and without token textures. `keybinds_spec`
maps Bartender and Blizzard binding names onto ShadowUI action slots.
`edit_session_spec` covers Layout Edit Mode vs Keybind Edit Mode, Layer writes, and key tombstones.
`edit_hud_spec` covers the DIALOG HUD overlay, magenta centre guides, and combat close.
`edit_unit_spec` covers Player Frame and Target Frame HUD hosts and the snap-back from Blizzard Edit Mode.
`edit_meters_spec` covers Cast Bar drag and resize and Range Display drag in Layout Edit Mode.
`apply_bars_spec` asserts ShadowUI bars are created before Blizzard bars are hidden.
`button_create_spec` asserts Classic LAB create sets `MasqueSkinned` and pcalls click registration.
`button_lock_spec` asserts Action Slot Lock: click uses the action, Shift-drag moves, hard lock blocks the move.
`micro_bags_spec` asserts the micro row and backpack leave the hidden art frame, keep native Blizzard size and art, keep no gap between items, and dock with no gap from the bottom of the screen.
`micro_menu_spec` asserts `MicroMenu` parents to the Micro Cluster, hosts stay on `MicroMenu`, and Blizzard Edit Mode `Layout` can compare button centres.
`tracking_spec` asserts XP and reputation dock to the top of the screen.
`darken_spec` asserts Lorti vertex colors on unit-frame and window chrome, and that Blizzard cannot reset them with SetVertexColor, SetTexture, SetAtlas, or TargetFrameMixin.CheckClassification.
`button_skin_spec` asserts a 0.05 chrome fill, a 2px icon inset, and a 4px outer edge on action buttons.
`minimap_spec` asserts the square map uses the SexyMap mask, sits in a 16px Darken buffer with Zone Text on top and an Outer Edge, shows World Layer on the bottom of the holder and Blizzard Time on the map, and keeps cluster icons (including late LFG, ItemRack, and LibDBIcon buttons) on the square path so the player can drag them.
`auras_spec` asserts buff chrome is darkest, unused slots stay empty, player buffs sit 2px left of the square minimap, and debuff type colour stays native.
`aura_duration_spec` asserts Target Frame auras show remaining time from UnitAura.
`status_text_spec` asserts Target Frame health text follows Blizzard Status Text and does not stack native LeftText and RightText.
`threat_spec` asserts the Threat Bar is full width and flush on the nameplate, including solo.
`cooldown_count_spec` asserts action-button cooldown seconds hide for the GCD.
`chat_spec`, `unit_park_spec`, and `details_spec` assert Chat, Player/Target, and Details charts stay on the Currentz chrome lock. `unit_park_spec` also asserts Blizzard Edit Mode cannot keep a different Player Frame or Target Frame place, including the 1.15.9 `SetPoint` override and `ApplySystemAnchor`.
`itemrack_spec` asserts ItemRack worn-item and menu buttons get icon chrome and Outer Edge, and the minimap ItemRack icon does not get a second edge.
`mana_ticker_spec` and `swing_spec` cover those meters. Swing lanes are class-gated, hidden until active, and sit flush in the combat meter group. Layout Edit Mode previews every swing lane.
`range_spec` covers the target Range Display lock and colour bands.
`shields_spec` covers Shield Row absorb math, fill percent, Player Frame lock, oval portrait crop, and icon spring.
`cast_spec` covers Cast Bar fill, latency window, and GCD Sweep timing.
`sim_layout_spec` asserts the HTML harness dump uses the same bar and cast rects as `layout_spec`.

Layout preview (no client):

```bash
pnpm --dir sim install
pnpm --dir sim dev
```

Vite dumps `sim/layout.json` and serves the Layout Harness at `http://localhost:5173`. The preview reloads when TypeScript, CSS, or Layout Lua change. Drag to move. Drag an edge or corner to resize. Action Bars snap to 12-slot grids. Use **Save** to copy Lua or store a named browser save. Paste bar deltas into `defaults/`. Paste Chrome deltas into `sim/chrome.lua`. See [sim/README.md](sim/README.md).

Manual in-game verification (Classic Era or SoD):

- [ ] **Fresh character** — centered bars, skins applied, cast bar visible, no setup prompts
- [ ] **On-screen layout** — six reversed rows on the bottom; bar7 left and bar8 right as 3x4; nothing clipped
- [ ] **Edit layer Variant** — `/shadowui edit`, drag the blue HUD overlay on a bar; only that class variant changes; same-class alt sees it
- [ ] **Keybind Edit Mode** — `/shadowui binds`, hover a button, press a key; hotkey paints; `/shadowui layer` still selects the write target; combat closes the session
- [ ] **Edit layer Base** — drag a bar; all classes inherit the change
- [ ] **Layer picker** — Layout Edit Mode panel shows BASE / CLASS / VARIANT; Done closes the session; magenta centre guides show
- [ ] **Talent auto-bind** — talent change selects the bound variant unless manually overridden (`/shadowui variant clear` restores auto)
- [ ] **Stance / form bar** — active stance, form, aura, or Stealth shows a lit checked overlay (Warrior, Druid, Paladin, Rogue, Priest, Shaman)
- [ ] **Pet bar** — token actions (Attack, Follow, stances) show icons rather than blanks
- [ ] **Combat deferral** — enter combat, run `/shadowui variant <name>`; no taint error, layout applies when combat drops
- [ ] **Chrome** — 0.05 icon chrome and Outer Edge on action buttons; square minimap flush to top-right in a 16px Darken buffer at 0.6 alpha with Zone Text on top, World Layer on the bottom, Blizzard Time on the map, and an Outer Edge; parked Currentz chat; micro menu + one bag button, bottom-right, one row
- [ ] **Cooldown Count** — a 30s cooldown shows remaining seconds; a GCD swipe has no number
- [ ] **Lorti darken** — player and target sit in the centre cluster and are near-black; party and pet frames are near-black; buffs and debuffs have the same chrome; character/bag windows are grey; portraits stay native colour; target health numbers follow Status Text; a rare-elite uses the winged silver dragon; the Threat Bar sits flush on the Target Frame nameplate; target debuffs show remaining seconds
- [ ] **Details** — with Details! loaded, the damage chart is flush right and the threat chart sits above the micro row
- [ ] **ItemRack** — with ItemRack loaded, worn-item and menu buttons have 0.05 icon chrome and Outer Edge; the minimap ItemRack icon stays on the square path with no second edge
- [ ] **Cast + GCD** — Quartz-like Cast Bar with overlay spell icon, channel ticks, spark, and latency window; skinny glossy GCD Sweep flush under it while a GCD is active; Blizzard player cast bar hidden; target cast bar stays Blizzard; Layout Edit Mode can drag and resize the Cast Bar and previews Cast + GCD + all Swing Timer lanes
- [ ] **Mana ticker** — after a mana spend, remaining seconds (`5.0s`) show under the portrait mana bar; after 5s the 2s tick countdown shows
- [ ] **Swing timer** — centred melee bars tick down after auto-attacks; dual-wield shows a second bar; Slam resets main-hand; Auto Shot / wand Shoot / guns / bows show the green ranged bar
- [ ] **Range Display** — with a target, min–max yards show near the unit-frame cluster; colour changes through close / short / medium / default / out of range; Layout Edit Mode can drag it
- [ ] **Shield Row** — Fire Ward, Ice Barrier, Power Word: Shield, or Mana Shield show a colour-coded icon above the player frame; fill and percent match remaining absorb
- [ ] **Possess** — mind-control a target and confirm the possess bar drives the vehicle actions
- [ ] **Mage Currentz hotkeys** — with Bartender off, Q/E/R/F/G/C/V/T fire slots 61–72 on bar2; mouse4/5 fire the same slots as before
- [ ] **Unchanged UI** — nameplates and the objective tracker stay default

## Known limitations

- Action page paging is not implemented; bars hold fixed action slots and do not swap on bonus bars or stances.
- Possess relies on `/click PossessButtonN` and needs in-game validation; LibActionButton has no possess action type.
- Profile keybinds use `SetOverrideBindingClick` on ShadowUI buttons and paint hotkey labels from those binds.
- Micro and bag buttons are docked flush to the screen bottom-right in one row (single backpack button, native Blizzard art, no Shop).
- Vendored libraries in `libs/` are not pinned to upstream revisions.

See [Known limitations](docs/architecture.md#known-limitations) for detail.
