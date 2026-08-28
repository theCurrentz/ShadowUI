# ShadowUI

ShadowUI is an opinionated World of Warcraft UI addon for action bars, interface chrome, and cast bars. It supports Classic Era (Version Era) and The Burning Crusade Classic Anniversary (Version TBC).

## Installation

Copy the addon directory to `Interface/AddOns/ShadowUI`, then enable ShadowUI from the character selection screen. Era loads `ShadowUI.toc` (interface 11509). TBC loads `ShadowUI_TBC.toc` (interface 20506). On first apply each session, ShadowUI turns Auto Loot on for that Character.

## Configuration

- `/shadowui` or `/sui` opens the options.
- `/shadowui edit` toggles Layout Edit Mode (HUD overlay, snap grid, drag Bars, Player Frame, Target Frame, Cast Bar, Range Display, and Stance Bar). Hold Shift while dragging to skip snap. Drag a Bar resize grip to change columns and rows. Scale does not change.
- `/shadowui binds` toggles Keybind Edit Mode (hover a button, press a key).
- `/shadowui deck` places the merged Action Deck (macros and spells) onto Action Slots (out of combat).
- `/shadowui prune` packs Keybinds left and drops gaps with no Keybind. Actions on those Keybinds move with them (out of combat).
- `/shadowui layer base|class|variant|character` sets the layer changed by either edit session.
- `/shadowui variant <name>` manually activates a variant.
- `/shadowui variant clear` clears the manual variant override.

## Layout inheritance

Every layout resolves through Base → Class → Variant → Character. Base provides shared defaults. Class and Variant apply class overlays. Character applies a sparse last overlay for that toon.

Terms: [CONTEXT.md](CONTEXT.md). Module layout and resolve rules: [docs/architecture.md](docs/architecture.md). Macros: [docs/macros/](docs/macros/). Sidecar rolodex: [MacroCursor](../MacroCursor) (`pnpm dev`). Version chips: Era or TBC.

## Options

Open with `/shadowui` or `/sui`. The panel covers variants, talent-tree binding, Action Slot hard lock, an on/off toggle for every Bar including pet and possess, edit-layer selection, Layout Edit Mode, Keybind Edit Mode, Shift and Prune, Action Deck loadout (Class, Variant, or Character), Place Action Deck, and resets. It does not contain bar-layout sliders. A Bar toggle writes `enabled` to the selected Layer. Toggles stay shown when the current class Layout has no entry.

Action buttons stay locked: a click uses the action. Shift-drag moves a spell or item to another Action Slot and does not use the action. Shift+Alt drag inserts the action and Keybind and shifts that row right. While that pickup is on the cursor, every standard Bar and every empty Action Slot is shown as a drop target, including each Keybind label. Enable **Hard lock action slots** to block those moves too. **Shift and Prune** packs Keybinds left and drops gaps with no Keybind. Actions on those Keybinds move with them. Writes go to the selected Layer.

## Testing

Automated checks (plain Lua, no client needed):

```bash
lua tests/resolve_spec.lua
lua tests/layout_spec.lua
lua tests/api_shapes_spec.lua
lua tests/slash_spec.lua
lua tests/version_spec.lua
lua tests/auto_loot_spec.lua
lua tests/keybinds_spec.lua
lua tests/deck_spec.lua
lua tests/deck_overlay_spec.lua
lua tests/deck_replace_spec.lua
lua tests/deck_tombstone_spec.lua
lua tests/layer_spec.lua
lua tests/edit_session_spec.lua
lua tests/edit_hud_spec.lua
lua tests/edit_bars_spec.lua
lua tests/edit_unit_spec.lua
lua tests/edit_meters_spec.lua
lua tests/apply_bars_spec.lua
lua tests/special_preview_spec.lua
lua tests/button_create_spec.lua
lua tests/button_lock_spec.lua
lua tests/slotshift_spec.lua
lua tests/options_bars_spec.lua
lua tests/button_skin_spec.lua
lua tests/micro_bags_spec.lua
lua tests/micro_menu_spec.lua
lua tests/park_main_menu_spec.lua
lua tests/tracking_spec.lua
lua tests/darken_spec.lua
lua tests/minimap_spec.lua
lua tests/time_spec.lua
lua tests/auras_spec.lua
lua tests/aura_duration_spec.lua
lua tests/status_text_spec.lua
lua tests/threat_spec.lua
lua tests/portrait_spec.lua
lua tests/statusbars_spec.lua
lua tests/rare_elite_spec.lua
lua tests/cooldown_count_spec.lua
lua tests/chat_spec.lua
lua tests/unit_park_spec.lua
lua tests/focus_tot_spec.lua
lua tests/target_spellbar_spec.lua
lua tests/details_spec.lua
lua tests/itemrack_spec.lua
lua tests/rainbow_spec.lua
lua tests/bags_spec.lua
lua tests/stance_spec.lua
lua tests/mana_ticker_spec.lua
lua tests/swing_spec.lua
lua tests/range_spec.lua
lua tests/shields_spec.lua
lua tests/cast_spec.lua
```

`slash_spec` asserts `/sui` uses the same handler as `/shadowui`.
`resolve_spec` covers layer merging, layer writes, and talent-tab parsing for both the
Classic Era and modernized `GetTalentTabInfo` signatures. `layout_spec` asserts every
shipped bar stays within ±360 of screen centre and never overlaps another bar or the
cast bar. `api_shapes_spec` covers the `SetGradient` path with its solid-colour
fallback and pet action returns with and without token textures. `keybinds_spec`
maps Bartender and Blizzard binding names onto ShadowUI action slots.
`deck_spec` covers the Warrior Action Deck: stance-page maps, exact macro-tab rebuild, managed-slot clearing, duplicate names, catalog validation, and placement.
`deck_replace_spec` reproduces stale macro-index shifts and asserts that a Warrior Class apply places the Macro Cursor HUD (not the Variant-less skeleton), cannot place Power Infusion, and drops unrelated General or character macros.
`deck_overlay_spec` covers Account and Character Action Deck merge, `false` tombstones, PlaceDeck spell pickup, and `through` Class / Variant / Character.
`layer_spec` covers the in-game Layer picker: Base, Class, Variant, and Character.
`edit_session_spec` covers Layout Edit Mode vs Keybind Edit Mode, Layer writes, and key tombstones.
`edit_hud_spec` covers the DIALOG HUD overlay, magenta centre guides, Bar resize grip, and combat close.
`edit_bars_spec` covers secure Warrior stance paging and Bar resize by columns and rows: 12-slot grids, Special Bar slot-count grids, and persist without writing scale.
`edit_unit_spec` covers Player Frame, Target Frame, and Stance Bar HUD hosts and the snap-back from Blizzard Edit Mode.
`edit_meters_spec` covers Cast Bar drag and resize and Range Display drag in Layout Edit Mode.
`apply_bars_spec` asserts ShadowUI bars are created before Blizzard bars are hidden, that a disabled standard Bar is still created, and that a pickup shows that Bar.
`special_preview_spec` asserts Layout Edit Mode previews pet and possess for every class and does not create stance, aura, or form bars.
`button_create_spec` asserts Classic LAB create sets `MasqueSkinned` and pcalls click registration.
`button_lock_spec` asserts Action Slot Lock: click uses the action, Shift-drag moves, hard lock blocks the move.
`slotshift_spec` asserts Shift and Prune packs Keybinds left across gaps, rows, and Bars, and that Shift+Alt insert shifts a row right.
`options_bars_spec` asserts `/shadowui` has an on/off toggle for every Bar, including Special Bars missing from Layout. The toggle reads `enabled` through the selected Layer and writes to that Layer.
`micro_bags_spec` asserts the micro row and backpack leave the hidden art frame, keep native Blizzard size and art, keep no gap between items, and dock with no gap from the bottom of the screen. It also hides Dungeon Journal and Collections when those windows do not exist.
`micro_menu_spec` asserts `MicroMenu` parents to the Micro Cluster, hosts stay on `MicroMenu`, and Blizzard Edit Mode `Layout` can compare button centres. It also hides Dungeon Journal when `ToggleEncounterJournal` is missing.
`park_main_menu_spec` asserts MainMenuBar parks off-screen and the Blizzard Stance Bar stays shown on UIParent.
`tracking_spec` asserts XP and reputation dock to the top of the screen.
`darken_spec` asserts Lorti vertex colors on unit-frame and window chrome, and that Blizzard cannot reset them with SetVertexColor, SetTexture, SetAtlas, or TargetFrameMixin.CheckClassification.
`button_skin_spec` asserts a 0.05 chrome fill, a 2px icon inset, and a 4px outer edge on bound action buttons, that an empty Action Slot stays hidden with no Darken fill and no Keybind label, and that a pickup or ACTIONBAR_SHOWGRID shows empty Action Slots as drop targets with their Keybind labels.
`minimap_spec` asserts the square map uses the SexyMap mask, sits in a 16px Darken buffer with Zone Text on top and an Outer Edge, shows World Layer on the bottom of the holder and Blizzard Time under the map, zooms with the mouse wheel and auto zoom-out, and keeps cluster icons (including late LFG, ItemRack, and LibDBIcon buttons) on the square path so the player can drag them.
`time_spec` asserts Time is Blizzard `TimeManagerClockButton` under the map, hover Time Info shows realm time and local time, a click keeps the Blizzard Stopwatch, and GameTimeFrame stays hidden.
`auras_spec` asserts buff chrome is darkest, unused slots stay empty, player BuffFrame and DebuffFrame keep Blizzard Edit Mode place, debuff type colour stays native, Target of Target auras sit 2px to the right in a horizontal row, and Target auras sit 2px to the right of the Target Frame at 32px, including after TargetFrame:UpdateAuras and on 1.15.9 auraPools buttons.
`aura_duration_spec` asserts Target Frame auras show remaining time from UnitAura, hide native Duration text, and use NumberFontNormal.
`status_text_spec` asserts ShadowUI does not paint Target Frame health text and hides a leftover caption.
`threat_spec` asserts the Threat Bar is a round bubble tab on the 45-degree portrait edge, including solo.
`target_spellbar_spec` asserts Target of Target stays on the Blizzard default offset and the Target Frame spell bar sits 2px above Name Background at mana width, with the spell name on the left and remaining / duration on the right.
`cooldown_count_spec` asserts action-button cooldown seconds hide for the GCD.
`chat_spec`, `unit_park_spec`, and `details_spec` assert Chat, Player/Target, and Details charts stay on the Currentz chrome lock. `chat_spec` also asserts Blizzard Edit Mode can keep a new Chat size. `unit_park_spec` also asserts Blizzard Edit Mode cannot keep a different Player Frame or Target Frame place, including the 1.15.9 `SetPoint` override and `ApplySystemAnchor`.
`focus_tot_spec` asserts Edit Mode `SetSmallSize` can SetPoint `FocusFrameToT` when the Focus Frame was snapped to that ToT.
`portrait_spec` asserts the Portrait Ring is class-coloured for player targets and that a non-player portrait stays full original.
`statusbars_spec` asserts Meter Fill is a horizontal lighting overlay on health, mana, rage, Name Background, and nameplate health, that a player Name Background uses class colour, and that StatusBar vertex colour cannot flatten it.
`itemrack_spec` asserts ItemRack worn-item and menu buttons get icon chrome and Outer Edge, and the minimap ItemRack icon does not get a second edge.
`rainbow_spec` and `bags_spec` cover parked Bags and Rainbow Organizer modules. Those files stay in the tree. The TOC does not load them.
`stance_spec` asserts Blizzard Stance Bar buttons get icon chrome and Outer Edge, unused shapeshift slots stay empty, and ShadowUI does not draw a second Stance Bar.
`mana_ticker_spec` and `swing_spec` cover those meters. Swing lanes are class-gated, hidden until active, and sit flush in the combat meter group. Layout Edit Mode previews every swing lane.
`range_spec` covers the target Range Display lock and colour bands.
`shields_spec` covers Shield Row absorb math, fill percent, Player Frame lock, oval portrait crop, and icon spring.
`cast_spec` covers Cast Bar fill, latency window, and GCD Sweep timing.

Manual in-game verification (Classic Era):

- [ ] **Fresh character** — centered bars, skins applied, cast bar visible, no setup prompts
- [ ] **On-screen layout** — six reversed rows on the bottom; bar7 left and bar8 right as 3x4; bar9 and bar10 above pet and possess; nothing clipped
- [ ] **Bar toggles** — `/shadowui` shows an on/off toggle for every Bar, including pet and possess; off hides that Bar; on shows it; writes go to the selected Layer
- [ ] **Keybind Edit Mode** — `/shadowui binds`, hover a button, press a key; hotkey paints; `/shadowui layer` still selects the write target; combat closes the session
- [ ] **Edit layer Base** — drag a bar; all classes inherit the change
- [ ] **Layer picker** — Layout Edit Mode panel shows BASE / CLASS / VARIANT / CHARACTER; Done closes the session; magenta centre guides show
- [ ] **Bar resize** — drag the Bar grip; a 12-slot row becomes 6x2 / 4x3 / 3x4; scale does not change; Special Bars snap to grids that fill their slot count
- [ ] **Talent auto-bind** — talent change selects the bound variant unless manually overridden (`/shadowui variant clear` restores auto)
- [ ] **Stance Bar** — Blizzard `StanceBarFrame` / `ShapeshiftBarFrame` stays shown for Warrior stances, Paladin auras, Druid forms, Rogue Stealth, Priest Shadowform, and Shaman Ghost Wolf; ShadowUI does not draw a second copy; shown buttons use icon chrome and Outer Edge; Layout Edit Mode can drag it
- [ ] **Warrior stance pages** — `bar1` shows Battle 73–84, Defensive 85–96, and Berserker 97–108; `1`–`7`, `Z`, and `X` stay on the same physical buttons in combat
- [ ] **Pet bar** — token actions (Attack, Follow, stances) show icons rather than blanks
- [ ] **Combat deferral** — enter combat, run `/shadowui variant <name>`; no taint error, layout applies when combat drops
- [ ] **Chrome** — 0.05 icon chrome and Outer Edge on bound action buttons and Stance Bar buttons; empty Action Slots stay hidden, including Keybind labels, except during Keybind Edit Mode or a Shift-drag pickup (every standard Bar and empty Action Slot is then a drop target, including each Keybind label); square minimap flush to top-right in a 16px Darken buffer at 0.6 alpha with Zone Text on top, World Layer on the bottom, Blizzard Time under the map, mouse-wheel zoom, and an Outer Edge; parked Currentz chat; micro menu + one bag button, bottom-right, one row
- [ ] **Cooldown Count** — a 30s cooldown shows remaining seconds; a GCD swipe has no number
- [ ] **Lorti darken** — player and target sit in the centre cluster and are near-black; party and pet frames are near-black; buffs and debuffs have the same chrome; character/bag windows are grey; portraits stay native colour; target health numbers stay Blizzard Status Text; a rare-elite uses the winged silver dragon; the Threat Bar sits as a bubble tab on the 45-degree edge of the Target Frame portrait; target debuffs show remaining seconds
- [ ] **Meter Fill** — player and target health and power bars, Name Background, and nameplate health bars use a horizontal lighting overlay of the live colour; a player Name Background uses class colour
- [ ] **Details** — with Details! loaded, the damage chart is flush right and the threat chart sits above the micro row
- [ ] **ItemRack** — with ItemRack loaded, worn-item and menu buttons have 0.05 icon chrome and Outer Edge; the minimap ItemRack icon stays on the square path with no second edge
- [ ] **Bags** — backpack and bank stay Blizzard; ShadowUI does not replace them
- [ ] **Cast + GCD** — Quartz-like Cast Bar with overlay spell icon, channel ticks, spark, and latency window; skinny glossy GCD Sweep flush under it while a GCD is active; Blizzard player cast bar hidden; target cast bar stays Blizzard; Layout Edit Mode can drag and resize the Cast Bar and previews Cast + GCD + all Swing Timer lanes
- [ ] **Mana ticker** — after a mana spend, remaining seconds (`5.0s`) show under the portrait mana bar; after 5s the 2s tick countdown shows
- [ ] **Swing timer** — centred melee bars tick down after auto-attacks; dual-wield shows a second bar; Slam resets main-hand; Auto Shot / wand Shoot / guns / bows show the green ranged bar
- [ ] **Range Display** — with a target, min–max yards show on the top of the Cast Bar stack; colour changes through close / short / medium / default / out of range; Layout Edit Mode can drag it
- [ ] **Shield Row** — Fire Ward, Ice Barrier, Power Word: Shield, or Mana Shield show a colour-coded icon above the player frame; fill and percent match remaining absorb
- [ ] **Possess** — mind-control a target and confirm the possess bar drives the vehicle actions
- [ ] **Warrior Action Deck** — out of combat, `/shadowui` Loadout Character then Place Action Deck (or `/shadowui deck`) on Fury puts Heroic Strike on 1, Disarm on 13, Perception on 22, Charge/Intercept on 77, Cleave (not Cannibalize or Cone of Cold) on 76, the smart interrupt on 78, Bloodthirst on 74/86/98, and leaves 109–111 empty; empty managed positions are clear; the General tab contains only unique resolved deck macros; the character tab is empty; Power Infusion and other stale macros are absent
- [ ] **Unchanged UI** — nameplate layout and the objective tracker stay default

## Known limitations

- Possess relies on `/click PossessButtonN` and needs in-game validation; LibActionButton has no possess action type.
- Profile keybinds use `SetOverrideBindingClick` on ShadowUI buttons and paint hotkey labels from those binds.
- `/shadowui deck` places macros and abilities from the selected loadout (Class, Variant, or Character). It validates the catalog, replaces both macro tabs with only the unique resolved deck macros on the General tab, and then clears owned Warrior slots 1–12 and 73–111 plus every loadout slot. Fury, Arms, and Protection leave 109–111 empty unless the loadout writes them. Apply keeps tombstoned slots empty after reload. Every macro entry must match its required body marker. Classic Era picks up abilities by spell name. Clients with `C_Spell.PickupSpell` use the spell id.
- Micro and bag buttons are docked flush to the screen bottom-right in one row (single backpack button, native Blizzard art, no Shop).
- Vendored libraries in `libs/` are not pinned to upstream revisions.

See [Known limitations](docs/architecture.md#known-limitations) for detail.
