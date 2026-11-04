# ShadowUI Architecture

WoW Forever addon. Skins Blizzard action bars and applies selective chrome. **Version** is Forever ([ADR 0002](adr/0002-version-outside-layers.md)). Live ActionButtons stay Blizzard hosts ([ADR 0011](adr/0011-forever-skins-blizzard-bars.md)). Layout, Keybinds, and the Action Deck live on one Account **Profile** ([ADR 0014](adr/0014-one-account-profile.md)). Domain terms live in [CONTEXT.md](../CONTEXT.md). Macro Cursor is a local sidecar that writes the Macro Library ([ADR 0003](adr/0003-local-macro-library.md)). Live Layout, Keybind, and Action Deck overlays live in WTF SavedVariables ([ADR 0004](adr/0004-wtf-live-overlays.md)). Player Frame and Target Frame stay Blizzard. Chrome Darkens their art. ShadowUI does not add a Threat Bar, Crowd Control Portrait, Range Display, or Shield Row ([ADR 0012](adr/0012-blizzard-unit-frames-and-no-cast-stack.md)).

## Module layout

```text
ShadowUI/
  ShadowUI.toc                Forever (game 1.60.1, interface 16001)
  ShadowUI_Forever.toc        Forever flavor TOC (same files)
  ShadowUI_Camelot.toc        Camelot flavor TOC (same files)
  libs/                         Ace3, LibStub, CallbackHandler, LibActionButton (not loaded)
  core/
    init.lua                    AceAddon bootstrap, lifecycle, slash commands
    db.lua                      AceDB account + character schema
    resolve.lua                 sparse merge and effective config resolution
    keybinds.lua                paint hotkey labels from client and Profile binds; does not override-click LAB hosts
  defaults/
    base.lua                    shared centered bar layout; Addon.Defaults.act for Action Deck entries
    catalog.lua                 generated Warrior deck macro bodies
    classes/*.lua               sparse class deltas (mage firstSlot, Warrior stance layout, keys, and deck)
  bars/
    button.lua                  Blizzard ActionButton chrome (Darken rim, Outer Edge, native icon and effects); empty Action Slots stay hidden except during Keybind Edit Mode or an Action Slot pickup; a pickup shows every Keybind
    grid.lua                    snap a Bar size to columns and rows that fill the slot count
    bar.lua                     unused LAB bar frames (CreateBarButton returns nil)
    slotshift.lua               Shift and Prune packs Keybinds left; does not read Action Slots
    overlay.lua                 HUD overlay drag and column/row resize for Bars
    pet.lua                     pet action binding and token texture resolve
    special.lua                 pet and possess bars
    manager.lua                 ApplyBars skins Blizzard ActionButtons in place; does not hide default action hosts
  skin/
    chrome.lua                  Lorti outer edge; ParkFrame; ApplySkins; status-bar gradient helper
    darken.lua                  Lorti SetVertexColor lock helper
    frames.lua                  unit, raid, party, pet, tooltip Darken; Stance Bar repark; Focus/ToT edit guard
    windows.lua                 bags, character, vendor, XP art
    auras.lua                   player buff and debuff 0.07 zoom, no border (BuffButton and BuffFrame.auraFrames)
    chat.lua                    parked General chat with Currentz fill
    micro.lua                   Blizzard micro menu and bag bar stay in place; Outer Edge on those borders
    tracking.lua                reputation bar at screen top; Experience bar stays with Blizzard and gets a Lorti Outer Edge
    minimap.lua                 Forever cluster in place: SexyMap square mask, Darken fade instead of the compass, square icon path, mouse-wheel zoom, auto zoom-out; header widgets stay; World Layer; draggable map-edge icons; `/shadowui` can restore the Blizzard map
    time.lua                    keep TimeManagerClockButton on the cluster header; hover Time Info; Blizzard Stopwatch; calendar stays
    details.lua                 parked Details! damage and threat charts
    itemrack.lua                ItemRack worn-item and menu button icon chrome; set menu stays on UIParent
    rainbow.lua                 Rainbow Organizer (parked; TOC does not load)
    bags.lua                    combined inventory and bank (parked; TOC does not load)
    stance.lua                  Blizzard Stance Bar buttons through the action-button chrome; strips Stance Bar art
  edit/
    mode.lua                    layout edit toggle, snap grid, magenta centre guides, persist drags
    frames.lua                  HUD drag hosts for the Stance Bar
    keybinds.lua                hover-and-press Keybind Edit Mode
    layer.lua                   HUD names the session and closes Edit Mode
  options/
    config.lua                  AceConfig panel; Character chrome, edit sessions, and resets. Bar place stays with Blizzard.
    chrome.lua                  Darken AceConfigDialog host and AceGUI controls; drop DialogBox parchment
  docs/macros/                  Macro Library (catalog.json is source; the addon does not load the sidecar). Version TBC spellbook is spells-tbc.json
```

WoW Macro Cursor lives in a sibling repo (`../MacroCursor`). It is local-only (pnpm, Vite). Version Era | TBC. It reads and writes `docs/macros/catalog.json`, live WTF caches, AceDB SavedVariables, and shipped Layout / Keybinds / Action Deck. Close the client before SavedVariables writes.

## Layout Edit Mode

Layout Edit Mode snaps Bars and the Stance Bar to 16.2px from screen bottom-left. Hold Shift while dragging to skip snap. Persist stores the nearest UIParent point so a host stays on that screen edge when the resolution changes. Magenta guides mark the snap-grid line nearest true screen centre; a host snaps to that midline when it is within one grid cell. A HUD chip follows the pointer and shows Layout point, x/y, and frame size while a host is selected, dragged, or resized. The chip sits above the Edit Mode HUD. Bars resize by columns and rows; scale does not change. A DIALOG-strata HUD overlay sits on each host so drag is not eaten by action buttons. Layout Edit Mode does not move other Chrome, Chat, or Details Windows. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place.

## Load order

Defined in `ShadowUI.toc`, `ShadowUI_Forever.toc`, and `ShadowUI_Camelot.toc`. File order is the same:

1. `libs/embeds.xml` — vendored libraries
2. `core/` — init, db, resolve, keybinds
3. `defaults/base.lua`, catalog, then class files (WARRIOR … DRUID)
4. `bars/` — button, grid, bar, slotshift, overlay, pet, special, manager
5. `skin/` — chrome, darken, frames, windows, auras, chat, micro, tracking, minimap, time, details, itemrack, stance (`rainbow` and `bags` stay in the tree, TOC does not load them)
6. `edit/` — mode, frames, keybinds, layer
7. `options/` — config, nav, scroll, Darken chrome

Later files replace stub methods on the `ShadowUI` addon table defined in `core/init.lua`.

## SavedVariables schema

### Account (`ShadowUIDB`)

Shared across characters on the account.

```lua
{
  layout = { [barId] = { point, relativeTo, relativePoint, x, y, columns, buttons, scale, enabled, buttonSize, ... } },
  keybinds = { [bindingName] = key },
  actions = { [slot] = { id, name, kind? } or false },
}
```

### Character (`ShadowUICharDB`)

Per-character state. Layout overlays live on the Account Profile.

```lua
{
  hardLockActionSlots = false, -- true blocks Shift-drag between Action Slots
  useShadowUIMenu = true,      -- false leaves the micro menu and bag bar borders stock
  useShadowUIMinimap = true,   -- false restores the default Blizzard map
}
```

Shipped defaults live in `ShadowUI.Defaults` (populated by `defaults/*.lua`), not in SavedVariables.

## Resolve rules

`ResolveEffective(classFile?)` returns `{ layout, keybinds }`. Apply uses the full merge.

Merge order (each step sparse-merges into the result; later wins per field):

1. Shipped `Defaults.base`
2. Shipped `Defaults.classes[classFile]` `layout` and `keybinds` only (not a `variants` table)
3. Account Profile (`db.layout` and `db.keybinds`)

**Layout Edit Mode writes** (`WriteProfileDelta(section, key, patch)`):

- Store is `db[section][key]` on the Account Profile
- Layout patches are tables (sparse-merged). Keybind patches are strings, or `false` to unbind a name. Action Deck patches are slot tables, or `false` to tombstone.

`/shadowui edit` toggles Layout Edit Mode (grid + HUD overlay drag on Bars and the Stance Bar). Hold Shift while dragging to skip snap. A Bar resize grip writes `columns` and does not write `scale`. `/shadowui binds` toggles Keybind Edit Mode (hover a button, press a key). The two sessions cannot run together. Keybind Edit Mode does not call `SaveBindings`. Combat closes either edit session.

`ApplyAll()` resolves config then calls `ApplyBars`, `ApplyKeybinds`, `ApplyAutoLoot`, and `ApplySkins`. `ApplyAutoLoot` sets the client CVar `autoLootDefault` on.

## Lifecycle

| Event | Action |
|-------|--------|
| `OnInitialize` | `SetupDB`, register `/shadowui` and `/sui` |
| `OnEnable` | register `PLAYER_ENTERING_WORLD`, `PLAYER_REGEN_ENABLED`, `PLAYER_REGEN_DISABLED`, `PLAYER_TALENT_UPDATE` |
| First `PLAYER_ENTERING_WORLD` | `ApplyAll` once per session |
| `PLAYER_TALENT_UPDATE` | no Profile switch |
| `PLAYER_REGEN_ENABLED` | flush deferred `ApplyAll`, keybinds, special-bar refresh |
| `PLAYER_REGEN_DISABLED` | close Layout Edit Mode or Keybind Edit Mode |

Event names vary by client flavour, so each registration is wrapped in `pcall`; an
unknown event is skipped instead of aborting `OnEnable`.

### Combat safety

`ApplyAll` creates frames, sets secure attributes, and hides protected Blizzard
frames, so it is deferred wholesale when `InCombatLockdown()` returns true. It sets
`pendingApplyAll` and `OnRegenEnabled` replays it. `ApplyBars` and `ApplySkins`
repeat the same guard so a direct call cannot mutate protected state
mid-combat. Keybinds queue in `_pendingKeybinds`; special-bar refreshes queue in
`pendingSpecialBarRefresh`. Both flush from `OnRegenEnabled`.

## Bar IDs

Forever skins Blizzard ActionButtons in place ([ADR 0011](adr/0011-forever-skins-blizzard-bars.md)). `ApplyBars` does not create LibActionButton hosts or `RegisterStateDriver`. Blizzard ActionBars keep their own paging. Shipped `bar1`–`bar10` rects still live on Profiles for leftover Layout data.

Standard: `bar1` … `bar10` (action slots 1–120). A Class layout may set
`firstSlot` so a bar shows a different 12-slot range. Mage rotates bars 2–6:
bar2 shows slots 61–72 (old bar6), then 13–24, 25–36, 37–48, 49–60. Base ships
`bar1`–`bar6` as six horizontal rows stacked on the bottom edge with **bar1 on
top** and **bar6 on the bottom**. `bar7` and `bar8` are 3×4 blocks on the left
and right of that stack.
`bar9`–`bar10` ship enabled above pet and possess. Pet and possess sit in a gap above the six-row stack.
Warrior `bar1` slot map is Battle 73–84, Defensive 85–96, and Berserker 97–108.
Warrior bars 2–8 expose slots 1–72 and 109–120; bars 9–10 stay off so no stance page appears twice.
Druid `bar1` pages Caster 1–12, Cat 73–84, Prowl 85–96, and Bear 97–108.
Rogue `bar1` pages Open 1–12 and Stealth 73–84.
Every shipped rect stays within ±360 of screen centre (asserted by
`tests/layout_spec.lua`).

Special (class-gated in play in `bars/manager.lua`): `pet` (Hunter, Warlock), `possess` (all).
Layout Edit Mode previews pet and possess for every class, using shipped Base defaults when
the effective Layout has no entry.
The Blizzard Stance Bar (`StanceBarFrame` / `ShapeshiftBarFrame`) shows Warrior stances,
Paladin auras, Druid forms, Rogue Stealth, Priest Shadowform, and Shaman Ghost Wolf.
ShadowUI does not replace it. Shown buttons use the same icon chrome and Outer Edge as
Action Slots. `ParkBlizzardStanceBar` does not reparent or Hide the Blizzard Stance Bar. A Layout `stance` place is leftover Profile data. Leftover `aura` and `form`
layout keys are ignored.

Layout also stores `stance` place. It is not a Bar. `ApplyBars` skips that key.

## Known limitations

- **Possess needs in-game validation.** Possess buttons stay on the Blizzard possess bar. ShadowUI does not Hide or SetAlpha those hosts.
- **Profile keybinds stay on the client.** `ApplyKeybinds` is a no-op. Forever skins Blizzard ActionButtons and keeps the client binds. It does not call `SetOverrideBindingClick` or `SaveBindings`. Mage defaults still ship Currentz's Bartender hotkeys as Profile data. Warrior ships one Class physical grid: `Q` starts the fixed utility row at slot 1, `1` starts the paged main Bar at button 73, and mouse keys stay on slots 109–111. Merge prefers the profile bind when two names share a key, so a leftover client `Q` on slot 61 does not win. Other classes import live client BT4/Blizzard binds.
  `/shadowui binds` (or **Edit keybinds** in `/shadowui`) starts the Bartender-style hover-and-press session. `/shadowui edit` stays Layout-only.
- **Micro menu and bag bar stay with Blizzard.** `SkinMicroAndBags` does not
  dock, reparent, or hide those bars ([ADR 0017](adr/0017-micro-and-bag-borders.md)).
  The Micro Bar is `MicroMenuContainer` (or `MicroMenu` when that container is
  absent). The Bag Bar is `BagsBar`. When neither exists, the combined
  `MicroButtonAndBagsBar` gets the same treatment. Each bar gets a Lorti Outer
  Edge on its border. Buttons, tray art, Flash, Shop, Customer Support,
  Achievement, and extra bag slots stay where Blizzard put them. Hide, SetPoint,
  and SetAlpha on those protected buttons stay off. `/shadowui` can turn the
  border shadow off. Forever does not Hide or SetAlpha
  `MainMenuBar` art or the default action buttons. `pcall` of those calls still
  pops ADDON_ACTION_FORBIDDEN. `ShapeshiftBarFrame`/`StanceBarFrame` stay shown.
- **Reputation sits at screen top.** `SkinTrackingBars` parents `ReputationWatchBar`
  (or `SecondaryStatusTrackingBarContainer`) to `UIParent` at `TOP` with offset 0.
  The Experience bar stays with Blizzard. The fill, notches, Status Text, and rested XP stay.
  ShadowUI gives that bar a Lorti Outer Edge. `MainMenuTrackingBar_Configure` would
  otherwise pin reputation to `MainMenuBar`.
- **Chat and Details charts are parked.** `SkinChat` docks `ChatFrame1`
  at `BOTTOMLEFT` (36, 32) with fill `0,0,0,202/255` and font size 16.
  `ParkFrame` snaps only the place. Size stays with Blizzard Chat and Blizzard
  Edit Mode, including after reload.
  Player Frame and Target Frame stay Blizzard. `SkinUnitFrames` Darkens their art
  and hides `TargetFrameBackground` / `FocusFrameBackground`. Classic `CheckClassification`
  sizes that well to 25px from y=-26, which covers only the top half of the 12px
  health slot at y=-45. `SkinDetails` docks
  the Details! damage chart flush `RIGHT` (0, -194) at 153×164 and the Tiny
  Threat chart at `BOTTOMRIGHT` (0, 150) at 153×106. Numbers come from Whitemane
  Currentz. `ParkFrame` uses `SetPointBase` when 1.15.9 Edit Mode has replaced
  `SetPoint`, then hooks `ApplySystemAnchor` so Blizzard Edit Mode, Leatrix Plus, and
  Details cannot keep a different place. `SetSmallSize` on the Focus Frame SetPoint
  `FocusFrameToT`. If the Focus Frame is already in that ToT family, Edit Mode
  `UpdateSystems` errors.   `WatchBlizzardUnitEdit` wraps `FocusFrame.SetSmallSize`
  (the XML mixin copy) so the Focus Frame cannot stay snapped to its ToT.
  Target of Target stays on the Blizzard default `BOTTOMRIGHT` (−35, −10) on the
  Target Frame. Target Frame, Target of Target, Focus, and party auras stay Blizzard.
  Layout Edit Mode drags Bars
  and the Stance Bar. If Details! is not loaded, `SkinDetails` does
  nothing.
- **Blizzard chrome uses Lorti vertex colors.** Character `darkness` (default 1) scales the live
  `DARKEN_*` palette via `RefreshDarkenPalette`. At darkness 1, `SkinDarken` sets 0.05 on unit-frame
  art, 0.14 on Target and Focus Frame Art, 0.35 on window art, and 0.2 on leftover bar/XP art, then hooks
  `SetVertexColor`, `SetTexture`, and `SetAtlas` so Blizzard cannot reset the player or target chrome. Portraits
  stay native. Target and Focus Frame Art use soft Darken (0.14) so original chrome still shows.
  Player, Target, and Focus Frame Art use a border-shadow atlas (`media/frameart`). The border
  keeps its outer shadow. The inner shadow on the health and mana wells is gone, including
  elite, rare, rare-elite, minus, and no-level art.
  Blizzard action buttons (including pet, stance, and override) keep the native icon,
  IconMask, cooldowns, hover and checked glows, Flash, equipped Border, and spell alerts.
  `LockVertex` tints only the slot and pressed rim (0.05) and the empty-slot art (0.2).
  Action buttons that have a spell or item get a 4px black Outer Edge (`media/outer_shadow.tga`).
  Player buff and debuff icons use a 0.07 zoom and hide their border. They do not get a
  Darken ring or an Outer Edge. Target Frame, Target of Target, Focus, and party auras stay Blizzard.
  An Action Slot with no spell, macro, or item stays hidden, including its Keybind label.
  Forever Blizzard ActionButtons do not call HasAction; chrome follows the host show state so
  Edit Mode "not always visible" drops Outer Edge on empty slots. Chrome does not write keys
  (`icon`, `HotKey`, `Count`) on those hosts and does not replace `ActionButton_UpdateCooldown`.
  Blizzard `Update` reads both. That taint stops ACTIONBAR_SHOWGRID from showing empty slots,
  so a drop on an empty slot clicks through to the world.
  A Shift-drag pickup or a spell, item, or macro on the cursor shows every standard Bar
  (including a Bar that is off), paints empty Action Slots as drop targets, and shows
  every Keybind. Merchant and money on the cursor do not. Keybind Edit Mode hides slot
  Keybind labels unless a pickup is active; the hover binder shows the key. Special Bars that are off stay hidden.
  ItemRack worn-item buttons (`ItemRackButton0`–`20`) and menu buttons (`ItemRackMenuN`)
  get a 0.05 fill, a 2px inset, a 0.07 icon crop, and an Outer Edge when ItemRack is loaded. The ItemRack minimap icon stays a
  Minimap Icon on the square path and does not get a second Outer Edge. ItemRack docks
  `ItemRackMenuFrame` to that icon; ShadowUI reparents the set menu to `UIParent` so the
  square map mask does not clip it and ItemRack's mouseover timer can keep it open.
  If ItemRack is not loaded, `SkinItemRack` does nothing.
  Bags (`skin/bags.lua`, `skin/rainbow.lua`) stay in the tree and are not loaded.
  `ApplySkins` does not call `SkinBags`. Blizzard bag and bank windows stay. Darken
  still tints those Blizzard windows. The Bag Bar stays the Blizzard bag bar.
  Action buttons keep the Blizzard cooldown swipe. Unused buff and debuff slots stay empty. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place. ShadowUI zooms their icons, hides their border, and does not park or snap them.
  Target Frame, Target of Target, Focus, and party auras stay Blizzard.
  The Target Frame keeps native Blizzard Status Text on health and mana.
  The minimap stays on the Forever cluster when `useShadowUIMinimap` is on (the default) ([ADR 0015](adr/0015-forever-square-minimap.md)). It uses SexyMap's square mask (`WHITE8X8`) and square icon path. A 16px 0.05 Darken fade at 0.6 alpha plus an Outer Edge replaces the compass ring. Forever `DielFrame` (day/night dial) hides so it does not block pings on the map face. Left-click `OnClick` pings the full square, not only Blizzard's inscribed circle. The map keeps its Blizzard size and place. Cluster header widgets stay: Zone Text, Time (`TimeManagerClockButton`), calendar (`GameTimeFrame`), mail, and tracking. Hover Time Info and a click on Time still open the Blizzard Stopwatch. Forever hover zoom buttons stay. The mouse wheel zooms. After 5 seconds the map zooms out. Nova World Buffs `MinimapLayerFrame` (World Layer) sits on the bottom of the holder so the map mask does not clip it. Hide and EnableMouse on `MinimapCluster` stay off. Map-edge icons, including late `LFGMinimapFrame`, ItemRack, and LibDBIcon buttons, sit on the square path 10px outside the map. The player can drag those icons. Buttons that parent to `Minimap`, `MinimapContainer`, or `MinimapBackdrop` park on the square path. `/shadowui` can turn this off so the default Blizzard compass map stays.
- **LibActionButton stays in the tree and is not loaded.** `CreateBarButton` returns nil. Bar frames are plain Frames. `ApplyBars` skins Blizzard ActionButtons in place and does not Hide or SetAlpha default action hosts. `ApplyAll` pcalls each step and prints the label if one fails, so skins can still run.
- **Hotkeys are painted from binds.** `FlushPendingKeybinds` merges the live client ACTIONBUTTON / MULTIACTIONBAR / BT4 names with the profile (profile wins by name, by key, and by Action Slot), then writes `shadowUIHotkey` onto each known button. An empty Action Slot hides that Keybind label. A pickup or ACTIONBAR_SHOWGRID shows every Keybind. Keybind Edit Mode hides slot Keybind labels unless a pickup is active; the hover binder shows the key. Priest/class files with empty `keybinds` still pick up Bartender keys from the client. Warrior shipped Keybinds win when they share a key or an Action Slot with a leftover client name.
- **Options are Character chrome and edit-session entry.** `/shadowui` has no Action bars group and no Profiles group. Bar place stays with Blizzard. General can turn the micro and bag border shadow and the square minimap off. Action Slot icons keep the Blizzard shape. The AceConfigDialog host uses Darken fill and tooltip edge instead of DialogBox parchment. AceGUI controls created in that window use the same Darken. `/shadowui prune` packs Keybinds left. **Edit layout** and **Edit keybinds** stay in General.

## Out of scope

Nameplate replacement, objective tracker, combined inventory and bank (Bags files stay parked), and Focus / Pet / Party / raid Unit Frames are not in scope. Player Frame and Target Frame stay Blizzard (ADR 0012). Nameplates stay Blizzard frames. Target of Target stays on the Blizzard default `BOTTOMRIGHT` (−35, −10) on the Target Frame. Player, target, and focus cast bars stay Blizzard. Target Frame, Target of Target, Focus, and party auras stay Blizzard. Details! still parks the threat chart.

The Action Deck lives on the Profile. Macro Cursor writes that overlay. ShadowUI does not PlaceAction in-game. Live Keybind and Action Deck overlays live in AceDB SavedVariables. Macro Cursor writes those files only when the client is closed. First GET migrates leftover `docs/macros/keybinds.json` and `actions.json` into Account SavedVariables, then stops serving them as live stores. Save as default still writes shipped `defaults/*.lua` for git. [docs/macros/](macros/) is the catalog. **WoW Macro Cursor** (`macro-cursor/`) is a Vite sidecar that loads that catalog by class group. The Characters view lists every Classic Era WTF toon folder with class and level. On startup the sidecar diffs live `macros-cache.txt` into the library. It writes cache heals and SavedVariables only when the client is closed. Copy a body into `/macro`, or export `macros-cache.txt` while the game is closed. Default path: `/Applications/World of Warcraft/_classic_era_`. Override with `WOW_CLASSIC_ERA`.
