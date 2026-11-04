# ShadowUI

ShadowUI is an opinionated WoW Forever UI addon. It skins Blizzard action bars and applies one chrome treatment.

## Installation

Copy the addon directory to `_forever_/Interface/AddOns/ShadowUI`, then enable ShadowUI from the character selection screen. The client loads `ShadowUI_Forever.toc` or `ShadowUI_Camelot.toc` (game 1.60.1, interface 16001). `ShadowUI.toc` matches those files. On first apply each session, ShadowUI turns Auto Loot on for that Character.

## Configuration

- `/shadowui` or `/sui` opens the options. The pane uses Darken chrome, not DialogBox parchment.
- `/shadowui edit` toggles Layout Edit Mode (HUD overlay, snap grid, drag Bars and Stance Bar). Hosts follow the pointer while the mouse is down. The Layout readout follows the pointer. Hold Shift while dragging to skip snap. Drag a Bar resize grip to change columns and rows. Scale does not change.
- `/shadowui binds` toggles Keybind Edit Mode (hover a button, press a key).
- `/shadowui prune` packs Keybinds left and drops gaps with no Keybind (out of combat).

Layout, Keybinds, and the Action Deck live on one Account Profile. Every Character uses that store. Shipped Class defaults still merge first.

Terms: [CONTEXT.md](CONTEXT.md). Module layout and resolve rules: [docs/architecture.md](docs/architecture.md). Macros: [docs/macros/](docs/macros/). Sidecar rolodex: [MacroCursor](../MacroCursor) (`pnpm dev`). Version: Forever.

## Options

Open with `/shadowui` or `/sui`. The pane uses Darken fill (0.05) and grey edge instead of the stock WoW DialogBox look. The panel covers Action Slot hard lock, Darkness, Layout Edit Mode, Keybind Edit Mode, micro and bag border shadow, minimap chrome, and resets. Bar place stays with Blizzard. `/shadowui prune` packs Keybinds left.

Action buttons stay locked: a click uses the action. Shift-drag moves a spell or item to another Action Slot and does not use the action. Shift+Alt drag inserts the action and Keybind and shifts that row right. While that pickup is on the cursor, every standard Bar and every empty Action Slot is shown as a drop target, and every Keybind is shown. Enable **Hard lock action slots** to block those moves too. **Shift and Prune** (`/shadowui prune`) packs Keybinds left and drops gaps with no Keybind. Writes go to the Profile.

## Testing

Automated checks (plain Lua, no client needed):

```bash
lua tests/api_shapes_spec.lua
lua tests/apply_bars_spec.lua
lua tests/auras_spec.lua
lua tests/auto_loot_spec.lua
lua tests/bags_spec.lua
lua tests/blizzardbars_spec.lua
lua tests/button_create_spec.lua
lua tests/button_lock_spec.lua
lua tests/button_skin_spec.lua
lua tests/chat_spec.lua
lua tests/darken_spec.lua
lua tests/db_spec.lua
lua tests/details_spec.lua
lua tests/easing_spec.lua
lua tests/edit_bars_spec.lua
lua tests/edit_hud_spec.lua
lua tests/edit_session_spec.lua
lua tests/edit_unit_spec.lua
lua tests/extra_spec.lua
lua tests/fade_spec.lua
lua tests/focus_tot_spec.lua
lua tests/forever_spec.lua
lua tests/itemrack_spec.lua
lua tests/keybinds_spec.lua
lua tests/layer_spec.lua
lua tests/layout_spec.lua
lua tests/micro_bags_spec.lua
lua tests/micro_menu_spec.lua
lua tests/minimap_spec.lua
lua tests/options_bars_spec.lua
lua tests/options_chrome_spec.lua
lua tests/options_nav_spec.lua
lua tests/options_scroll_spec.lua
lua tests/park_main_menu_spec.lua
lua tests/profile_spec.lua
lua tests/rainbow_spec.lua
lua tests/resolve_spec.lua
lua tests/shape_spec.lua
lua tests/slash_spec.lua
lua tests/slotshift_spec.lua
lua tests/special_preview_spec.lua
lua tests/stance_spec.lua
lua tests/time_spec.lua
lua tests/tracking_spec.lua
lua tests/taint_spec.lua
lua tests/version_spec.lua
```

`slash_spec` asserts `/sui` uses the same handler as `/shadowui`.
`resolve_spec` covers Profile merge and Profile writes. `layout_spec` asserts every
shipped bar stays within ±360 of screen centre and never overlaps another bar. `api_shapes_spec` covers the `SetGradient` path with its solid-colour
fallback and pet action returns with and without token textures. `keybinds_spec`
maps Bartender and Blizzard binding names onto ShadowUI action slots.
`layer_spec` covers `/shadowui profile` as gone.
`profile_spec` covers flattening named stores into one Account Profile.
`edit_session_spec` covers Layout Edit Mode vs Keybind Edit Mode, Profile writes, key tombstones, and persist of the nearest UIParent point.
`edit_hud_spec` covers the DIALOG HUD overlay, magenta snap-grid centre guides, centre snap within one grid cell, Bar resize grip, and combat close.
`edit_bars_spec` covers Bar resize by columns and rows: 12-slot grids, Special Bar slot-count grids, and persist without writing scale.
`edit_unit_spec` covers Stance Bar HUD hosts.
`apply_bars_spec` asserts ShadowUI bars are created before Blizzard bars are hidden, that a disabled standard Bar is still created, and that a pickup shows that Bar.
`special_preview_spec` asserts Layout Edit Mode previews pet and possess for every class and does not create stance, aura, or form bars.
`button_create_spec` asserts Classic LAB create sets `MasqueSkinned` and pcalls click registration.
`button_lock_spec` asserts Action Slot Lock: click uses the action, Shift-drag moves, hard lock blocks the move.
`slotshift_spec` asserts Shift and Prune packs Keybinds left across gaps, rows, and Bars, and that Shift+Alt insert shifts a row right.
`options_bars_spec` asserts `/shadowui` has no Action bars group and no Profiles group. Action Slot icons stay square. General can turn the square minimap off. Loadouts are gone.
`options_scroll_spec` asserts AceGUI options wheel steps 18px of content.
`options_chrome_spec` asserts the `/shadowui` AceConfigDialog host uses ChatFrame fill and Darken colours, not DialogBox parchment.
`micro_bags_spec` asserts the backpack, extra bag slots, and the keyring stay on `BagsBar`, the bag bar keeps its place and art, and only the bag bar border gets an Outer Edge.
`micro_menu_spec` asserts `MicroMenu` stays on `MicroMenuContainer`, Shop, Help, and Achievement stay on the menu, tray art and Flash stay, and only the micro bar border gets an Outer Edge.
`park_main_menu_spec` asserts MainMenuBar parks off-screen and the Blizzard Stance Bar stays shown on UIParent.
`tracking_spec` asserts reputation docks to the top of the screen and XP stays with Blizzard.
`darken_spec` asserts Lorti vertex colors on unit-frame and window chrome, and that Blizzard cannot reset them with SetVertexColor, SetTexture, SetAtlas, or TargetFrameMixin.CheckClassification. It also asserts Frame Art swaps to the border-shadow atlas so bar wells lose the inner shadow.
`button_skin_spec` asserts that a Blizzard ActionButton keeps its native icon, IconMask, hover, checked, Flash, and equipped Border, gets a blackened rim and a 4px outer edge, and gets no fill or icon zoom; that LAB buttons keep a 0.05 chrome fill, a 2px icon inset, and a 0.07 crop; that an empty Action Slot stays hidden with no Outer Edge and no Keybind label, that chrome does not write `icon`, `HotKey`, or `Count` on a Blizzard ActionButton, that a pickup or ACTIONBAR_SHOWGRID shows empty Action Slots as drop targets with Keybind labels, that Keybind Edit Mode hides slot Keybind labels unless a pickup is active, and that an empty Blizzard Action Slot does not keep Outer Edge.
`minimap_spec` asserts the square map skins the Forever cluster in place: SexyMap mask, a 16px Darken fade plus Outer Edge instead of the compass, header widgets stay, World Layer on the bottom of the holder, mouse-wheel zoom and auto zoom-out, and map-edge icons (including late LFG, ItemRack, and LibDBIcon buttons) on the square path so the player can drag them. Off in `/shadowui` restores the default Blizzard compass map.
`time_spec` asserts Time is Blizzard `TimeManagerClockButton` on the cluster header, hover Time Info shows realm time and local time, a click keeps the Blizzard Stopwatch, and GameTimeFrame (calendar) stays.
`auras_spec` asserts player buff and debuff icons use a 0.07 zoom and hide their border, with no Darken ring and no Outer Edge. Unused slots stay empty. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place. Target Frame, Target of Target, and 1.15.9 auraPools buttons stay on the Blizzard place and size.
`chat_spec` and `details_spec` assert Chat and Details charts stay on the Currentz chrome lock. `chat_spec` also asserts Blizzard Edit Mode can keep a new Chat size.
`focus_tot_spec` asserts Edit Mode `SetSmallSize` can SetPoint `FocusFrameToT` when the Focus Frame was snapped to that ToT.
`itemrack_spec` asserts ItemRack worn-item and menu buttons get icon chrome and Outer Edge, the minimap ItemRack icon does not get a second edge, and the set menu stays on UIParent after ItemRack docks it to that icon.
`rainbow_spec` and `bags_spec` cover parked Bags and Rainbow Organizer modules. Those files stay in the tree. The TOC does not load them.
`stance_spec` asserts Blizzard Stance Bar buttons keep the native icon and IconMask and get a blackened rim and Outer Edge, unused shapeshift slots stay empty, and ShadowUI does not draw a second Stance Bar.

Manual in-game verification (Forever):

- [ ] **Fresh character** — centered bars, skins applied, no setup prompts
- [ ] **On-screen layout** — six reversed rows on the bottom; bar7 left and bar8 right as 3x4; bar9 and bar10 above pet and possess; nothing clipped
- [ ] **Bar place** — live ActionButtons stay Blizzard hosts; `/shadowui` has no Action bars group; Layout Edit Mode still parks chrome hosts that ShadowUI owns
- [ ] **Keybind Edit Mode** — `/shadowui binds`, hover a button, press a key; hotkey paints; `/shadowui layer` still selects the write target; combat closes the session
- [ ] **Edit layer Base** — drag a bar; all classes inherit the change
- [ ] **Layer picker** — Layout Edit Mode panel shows BASE / CLASS / VARIANT / CHARACTER; Done closes the session; magenta centre guides show
- [ ] **Bar resize** — drag the Bar grip; a 12-slot row becomes 6x2 / 4x3 / 3x4; scale does not change; Special Bars snap to grids that fill their slot count
- [ ] **Stance Bar** — Blizzard `StanceBarFrame` / `ShapeshiftBarFrame` stays shown for Warrior stances, Paladin auras, Druid forms, Rogue Stealth, Priest Shadowform, and Shaman Ghost Wolf; ShadowUI does not draw a second copy; shown buttons use icon chrome and Outer Edge; Layout Edit Mode can drag it
- [ ] **Warrior stance pages** — `bar1` shows Battle 73–84, Defensive 85–96, and Berserker 97–108; `1`–`7`, `Z`, and `X` stay on the same physical buttons in combat
- [ ] **Pet bar** — token actions (Attack, Follow, stances) show icons rather than blanks
- [ ] **Combat deferral** — enter combat, run `/shadowui variant <name>`; no taint error, layout applies when combat drops
- [ ] **Chrome** — Darken rim and Outer Edge on bound action buttons and Stance Bar buttons, with the native icon and every Blizzard effect (proc, cast, cooldown, attack Flash, equipped border) fully visible; a 0.07 zoom and no border on player buffs and debuffs; Target Frame auras stay Blizzard; empty Action Slots stay hidden, including Keybind labels, except during Keybind Edit Mode or a Shift-drag pickup (every standard Bar and empty Action Slot is then a drop target; a pickup shows every Keybind; Keybind Edit Mode hides slot Keybind labels unless a pickup is active); square Forever minimap with a 16px Darken fade at 0.6 alpha instead of the compass, header widgets stay, World Layer on the bottom, mouse-wheel zoom, and an Outer Edge; parked Currentz chat; Blizzard micro menu and bag bar, with a border shadow only
- [ ] **Lorti darken** — player and target chrome are near-black; party and pet frames are near-black; player buffs and debuffs zoom with no border; character/bag windows are grey; portraits stay native colour; target health numbers stay Blizzard Status Text
- [ ] **Details** — with Details! loaded, the damage chart is flush right and the threat chart sits above the micro row
- [ ] **ItemRack** — with ItemRack loaded, worn-item and menu buttons have 0.05 icon chrome and Outer Edge; the minimap ItemRack icon stays on the square path with no second edge; left-click set menu stays on screen while the mouse is over the sets
- [ ] **Bags** — backpack and bank stay Blizzard; ShadowUI does not replace them
- [ ] **Possess** — mind-control a target and confirm the possess bar drives the vehicle actions
- [ ] **Unchanged UI** — nameplate layout and the objective tracker stay default

## Known limitations

- Possess stays on the Blizzard possess bar. ShadowUI does not Hide or SetAlpha those hosts.
- Profile keybinds stay on the client. `ApplyKeybinds` does not call `SetOverrideBindingClick`.
- Macro Cursor writes the Action Deck overlay. ShadowUI does not PlaceAction in-game.
- Micro and bag buttons are docked flush to the screen bottom-right in one row (single backpack button, native Blizzard art, no Shop, no Customer Support).
- Vendored libraries in `libs/` are not pinned to upstream revisions.

See [Known limitations](docs/architecture.md#known-limitations) for detail.
