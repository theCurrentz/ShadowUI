# ShadowUI Architecture

Classic Era and TBC addon. Replaces Blizzard action bars with custom LibActionButton bars, applies selective chrome skinning, and provides a fixed cast/GCD bar. **Version** selects Era or TBC. Layout, Keybinds, and the Action Deck live on named Account **Profiles**. Domain terms live in [CONTEXT.md](../CONTEXT.md). Named Profiles are [ADR 0008](adr/0008-named-profiles.md). Version sits outside Profiles ([ADR 0002](adr/0002-version-outside-layers.md)). Macro Cursor is a local sidecar that writes the Macro Library ([ADR 0003](adr/0003-local-macro-library.md)). Live Layout, Keybind, and Action Deck overlays live in WTF SavedVariables ([ADR 0004](adr/0004-wtf-live-overlays.md)). Player Frame and Target Frame become ShadowUI Unit Frames with a Classic targeting-frame Baseline ([ADR 0007](adr/0007-shadowui-unit-frames.md)). Unit Frame Designer writes Widget SetPoint deltas without flattening `relativeTo` ([ADR 0009](adr/0009-unit-designer-anchors.md)). Widget stack and Frame Art crop are [ADR 0010](adr/0010-widget-stack-and-art-crop.md).

## Module layout

```text
ShadowUI/
  ShadowUI.toc                Era (interface 11509)
  ShadowUI_TBC.toc            TBC Anniversary (interface 20506)
  libs/                         Ace3, LibStub, CallbackHandler, LibActionButton, LibRangeCheck
  core/
    init.lua                    AceAddon bootstrap, lifecycle, slash commands
    db.lua                      AceDB account + character schema
    resolve.lua                 sparse merge and effective config resolution
    keybinds.lua                combat-safe keybind apply
    deck.lua                    Action Deck placement; macros and spells; tombstoned slots stay empty on apply
  defaults/
    base.lua                    shared centered bar layout; Addon.Defaults.act for Action Deck entries
    units.lua                   Baseline Player Frame and Target Frame Layout
    catalog.lua                 generated Warrior deck macro bodies
    classes/*.lua               sparse class deltas (mage firstSlot, Warrior stance layout, keys, and deck)
  units/
    layout.lua                  Baseline targeting-frame Widgets, mirror, resolve, and place
    frame.lua                   CreateUnitFrame host and Widget regions
    apply.lua                   ApplyUnitFrames; HideBlizzardUnitFrames after cutover (ADR 0007)
  bars/
    button.lua                  LAB buttons, Action Slot Lock, 2px Lorti-dark icon chrome; empty Action Slots stay hidden except during Keybind Edit Mode or an Action Slot pickup (Keybind labels show too)
    cooldown.lua                remaining cooldown seconds on ShadowUI action buttons
    grid.lua                    snap a Bar size to columns and rows that fill the slot count
    bar.lua                     standard bar frames, button grid, and Warrior stance state driver
    slotshift.lua               Shift and Prune packs Keybinds left; Shift+Alt insert shifts a row right
    overlay.lua                 HUD overlay drag and column/row resize for Bars
    pet.lua                     pet action binding and token texture resolve
    special.lua                 pet and possess bars
    manager.lua                 apply resolved layout; hide Blizzard bars; park Stance Bar
  cast/
    castbar.lua                 Quartz-like Cast Bar with Lorti chrome, overlay icon, channel ticks, spark, and latency
    gcd.lua                     skinny glossy GCD Sweep under the Cast Bar
    manaregen.lua               regen tick vs FSR spend classification
    manaticker.lua              5SR + tick bars with remaining seconds under PlayerFrameManaBar
    swing.lua                   player swing timers under the GCD Sweep; class-gated hands; Outer Edge
    range.lua                   target Range Display on the top of the Cast Bar; Layout Edit Mode can drag it
    shields.lua                 Classic Era absorb catalogue, remaining absorb, combat log
    shieldrow.lua               colour-coded Shield Row locked to the Player Frame
  skin/
    chrome.lua                  Lorti outer edge; ParkFrame; ApplySkins (Bars have no matte fill)
    darken.lua                  Lorti SetVertexColor lock helper
    frames.lua                  unit, raid, party, pet, tooltip chrome; parked player/target; Stance Bar repark; Rare-Elite dragon
    statustext.lua              hide leftover ShadowUI Target Frame Status Text
    threat.lua                  Target Frame Threat Bar bubble tab; Aggro Glow on targeting-frame silhouette
    portrait.lua                Target Frame and Focus Frame circular portrait class-colour ring
    statusbars.lua              Meter Fill on unit-frame health/power, Name Background (player class colour), and nameplates
    windows.lua                 bags, character, vendor, XP art
    auras.lua                   buff and debuff icon chrome and Outer Edge (BuffButton and BuffFrame.auraFrames)
    auratime.lua                Target Frame and Focus Frame Aura Duration swipe and seconds
    chat.lua                    parked General chat with Currentz fill
    micro.lua                   micro + backpack on ShadowUIMicroCluster, native art, flush bottom-right
    tracking.lua                XP + reputation bars at screen top
    minimap.lua                 SexyMap square mask, square icon path, mouse-wheel zoom, auto zoom-out; 16px Darken buffer; Zone Text; World Layer; draggable icons
    time.lua                    restyle TimeManagerClockButton under the map; hover Time Info; Blizzard Stopwatch
    details.lua                 parked Details! damage and threat charts
    itemrack.lua                ItemRack worn-item and menu button icon chrome; set menu stays on UIParent
    rainbow.lua                 Rainbow Organizer (parked; TOC does not load)
    bags.lua                    combined inventory and bank (parked; TOC does not load)
    stance.lua                  Blizzard Stance Bar button icon chrome and Outer Edge
  edit/
    mode.lua                    layout edit toggle, snap grid, magenta centre guides, persist drags
    frames.lua                  HUD drag hosts for Player Frame, Target Frame, Cast Bar, Range Display, and Stance Bar
    units.lua                   Unit Frame Designer studio (tree, canvas, inspector) in /shadowui
    keybinds.lua                hover-and-press Keybind Edit Mode
    layer.lua                   HUD names the active Profile and closes Edit Mode
  profile/
    profiles.lua                named Profiles, Default Profile, Character selection
  options/
    config.lua                  AceConfig panel; Bar on/off toggles read and write Layout `enabled` on the active Profile
    chrome.lua                  Darken AceConfigDialog host and AceGUI controls; drop DialogBox parchment
  docs/macros/                  Macro Library (catalog.json is source; the addon does not load the sidecar). Version TBC spellbook is spells-tbc.json
```

WoW Macro Cursor lives in a sibling repo (`../MacroCursor`). It is local-only (pnpm, Vite). Version Era | TBC. It reads and writes `docs/macros/catalog.json`, live WTF caches, AceDB SavedVariables, and shipped Layout / Keybinds / Action Deck. Close the client before SavedVariables writes.

## Layout Edit Mode

Layout Edit Mode snaps Bars, the Player Frame, the Target Frame, the Cast Bar, the Range Display, and the Stance Bar to 16.2px from screen bottom-left. Hold Shift while dragging to skip snap. Persist stores the nearest UIParent point so a host stays on that screen edge when the resolution changes. Magenta guides mark the snap-grid line nearest true screen centre; a host snaps to that midline when it is within one grid cell. Player Frame, Target Frame, and Range Display use the visible chrome, not empty hit-box pad. A HUD chip follows the pointer and shows Layout point, x/y, and frame size while a host is selected, dragged, or resized. The chip sits above the Edit Mode HUD. Bars resize by columns and rows; scale does not change. The Cast Bar also resizes. A DIALOG-strata HUD overlay sits on each host so drag is not eaten by action buttons. Layout Edit Mode does not move other Chrome, the GCD Sweep or Swing Timer on their own, Chat, Details Windows, or the Shield Row. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place. If Blizzard Edit Mode moves the Player Frame, the Target Frame, or the Stance Bar, ParkFrame snaps them back to Layout.

## Unit Frame Designer

`/shadowui units` (or `/shadowui frames`) opens Unit Frame Designer on the `/shadowui` Unit Frames page. The studio is a tree, a canvas preview, and an inspector. The canvas paints Classic targeting-frame art with the same atlas crop as `PlayerFrameTexture` (`1, 0.09375, 0, 0.78125`; Target unflipped). Resize or move Frame Art to crop that atlas to the box; the host park size does not change. Portrait, meters, and Status Text use live or mock unit data. Click a Widget to select and drag it. Front and Back set Widget stack so a Widget can paint in front of or behind others. Anchor lines are not drawn; SetPoint lives in the inspector. A resize grip appears only on the selected Widget. The studio does not overlay HUD chips on the live Player Frame or Target Frame. Drag writes Widget SetPoint fields and keeps `relativeTo` (ADR 0009). Layout Edit Mode still parks the host on the screen. Writes go to the active Profile as sparse Widget patches on `layout.player` and `layout.target`.

Shipped Baseline is the Classic targeting frame (232×100, portrait 64×64, health and power 119×12). Target is that tree mirrored, plus Name Background, auras, and the spell bar. `ApplyUnitFrames` builds ShadowUI hosts from that Layout. Until `UnitFramesAreLive()` is true, those hosts stay hidden and Chrome still paints Blizzard PlayerFrame and TargetFrame. Unit Frame Designer previews geometry on its canvas, not on the live HUD.

## Load order

Defined in `ShadowUI.toc` (Era) and `ShadowUI_TBC.toc` (TBC). File order is the same:

1. `libs/embeds.xml` — vendored libraries
2. `core/` — init, db, resolve, keybinds, deck
3. `defaults/base.lua`, `units/layout.lua`, `defaults/units.lua`, catalog, then class files (WARRIOR … DRUID)
4. `bars/` — button, cooldown, grid, bar, slotshift, overlay, pet, special, manager
5. `units/` — frame, apply
6. `cast/` — castbar, gcd, manaticker, swing, range, shields, shieldrow
7. `skin/` — chrome, darken, frames, statustext, threat, windows, auras, auratime, chat, micro, tracking, minimap, time, details, itemrack, stance (`rainbow` and `bags` stay in the tree, TOC does not load them)
8. `edit/` — mode, frames, units, keybinds, layer
9. `profile/` — profiles, loadouts
10. `options/` — config, nav, scroll, Darken chrome

Later files replace stub methods on the `ShadowUI` addon table defined in `core/init.lua`.

## SavedVariables schema

### Account (`ShadowUIDB`)

Shared across characters on the account.

```lua
{
  defaultProfile = "Default",
  profiles = {
    Default = {
      layout = { [barId] = { point, relativeTo, relativePoint, x, y, columns, buttons, scale, enabled, buttonSize, ... } },
      keybinds = { [bindingName] = key },
      actions = { [slot] = { id, name, kind? } or false },
    },
  },
  loadouts = {},
}
```

### Character (`ShadowUICharDB`)

Per-character state. Layout overlays live on the Account Profile.

```lua
{
  activeProfile = nil,          -- nil follows defaultProfile
  hardLockActionSlots = false, -- true blocks Shift-drag between Action Slots
  useShadowUIMenu = true,      -- false restores the default Blizzard micro menu and bags
}
```

Shipped defaults live in `ShadowUI.Defaults` (populated by `defaults/*.lua`), not in SavedVariables.

## Resolve rules

`ResolveEffective(classFile?, profileName?)` returns `{ layout, keybinds }`. Omit `profileName` to use the active Profile. Apply and options Bar toggles use the full merge.

Merge order (each step sparse-merges into the result; later wins per field):

1. Shipped `Defaults.base`
2. Shipped `Defaults.classes[classFile]` `layout` and `keybinds` only (not a `variants` table)
3. Account `db.profiles[activeProfile]`

`GetActiveProfileName`: Character `activeProfile` when that name exists, else Account `defaultProfile`.

**Layout Edit Mode writes** (`WriteProfileDelta(section, key, patch)`):

- Store is `db.profiles[activeProfile][section][key]`
- Layout patches are tables (sparse-merged). Keybind patches are strings, or `false` to unbind a name. Action Deck patches are slot tables, or `false` to tombstone.

`/shadowui edit` toggles Layout Edit Mode (grid + HUD overlay drag on Bars, the Player Frame, the Target Frame, the Cast Bar, and the Range Display). Hold Shift while dragging to skip snap. A Bar resize grip writes `columns` and does not write `scale`. `/shadowui binds` toggles Keybind Edit Mode (hover a button, press a key). The two sessions cannot run together. Keybind Edit Mode does not call `SaveBindings`. Combat closes either edit session.

`ApplyAll()` resolves config then calls `ApplyBars`, `ApplyKeybinds`, `ApplyAutoLoot`, `ApplyUnitFrames`, `ApplySkins`, `ApplyCastBar`, `ApplyManaTicker`, `ApplySwingTimer`, `ApplyRangeDisplay`, and `ApplyShields`. `ApplyAutoLoot` sets the client CVar `autoLootDefault` on. `ApplySkins` also clears leftover Target Frame Status Text and paints the Threat Bar. `ApplyUnitFrames` creates ShadowUI Player and Target hosts from Baseline Layout. They stay hidden until `UnitFramesAreLive()`.

## Lifecycle

| Event | Action |
|-------|--------|
| `OnInitialize` | `SetupDB`, register `/shadowui` and `/sui` |
| `OnEnable` | register `PLAYER_ENTERING_WORLD`, `PLAYER_REGEN_ENABLED`, `PLAYER_REGEN_DISABLED`, `PLAYER_TALENT_UPDATE`, `CHARACTER_POINTS_CHANGED` |
| First `PLAYER_ENTERING_WORLD` | `ApplyAll` once per session |
| `PLAYER_TALENT_UPDATE` / `CHARACTER_POINTS_CHANGED` | no Profile switch |
| `PLAYER_REGEN_ENABLED` | flush deferred `ApplyAll`, keybinds, special-bar refresh |
| `PLAYER_REGEN_DISABLED` | close Layout Edit Mode or Keybind Edit Mode |

Event names vary by client flavour, so each registration is wrapped in `pcall`; an
unknown event is skipped instead of aborting `OnEnable`.

### Combat safety

`ApplyAll` creates frames, sets secure attributes, and hides protected Blizzard
frames, so it is deferred wholesale when `InCombatLockdown()` returns true. It sets
`pendingApplyAll` and `OnRegenEnabled` replays it. `ApplyBars`, `ApplySkins`, and
`ApplyCastBar` repeat the same guard so a direct call cannot mutate protected state
mid-combat. `ApplyManaTicker`, `ApplySwingTimer`, `ApplyRangeDisplay`, and `ApplyShields` only create unprotected frames and may run in combat. `ApplyUnitFrames` creates secure unit buttons, so it is deferred in combat with `ApplyBars`. Keybinds queue in `_pendingKeybinds`; special-bar refreshes queue in
`pendingSpecialBarRefresh`. Both flush from `OnRegenEnabled`.

## Bar IDs

Standard: `bar1` … `bar10` (action slots 1–120). A Class layout may set
`firstSlot` so a bar shows a different 12-slot range. Mage rotates bars 2–6:
bar2 shows slots 61–72 (old bar6), then 13–24, 25–36, 37–48, 49–60. Base ships
`bar1`–`bar6` as six horizontal rows stacked on the bottom edge with **bar1 on
top** and **bar6 on the bottom**. `bar7` and `bar8` are 3×4 blocks on the left
and right of that stack.
`bar9`–`bar10` ship enabled above pet and possess. Pet and possess sit in a gap above the six-row stack.
Warrior `bar1` uses a secure state driver: Battle shows slots 73–84, Defensive
shows 85–96, and Berserker shows 97–108. Its button names and physical keys stay
fixed at the Battle range. Warrior bars 2–8 expose slots 1–72 and 109–120;
bars 9–10 stay off so no stance page appears twice.
Druid `bar1` pages Caster 1–12, Cat 73–84, Prowl 85–96, and Bear 97–108.
Rogue `bar1` pages Open 1–12 and Stealth 73–84. Both hide bars that would show
those bonus slots twice. The driver uses `bonusbar` so Warrior stances, Druid
forms, and Rogue Stealth share one paging rule.
Every shipped rect stays within ±360 of screen centre (asserted by
`tests/layout_spec.lua`).

Special (class-gated in play in `bars/manager.lua`): `pet` (Hunter, Warlock), `possess` (all).
Layout Edit Mode previews pet and possess for every class, using shipped Base defaults when
the effective Layout has no entry.
The Blizzard Stance Bar (`StanceBarFrame` / `ShapeshiftBarFrame`) shows Warrior stances,
Paladin auras, Druid forms, Rogue Stealth, Priest Shadowform, and Shaman Ghost Wolf.
ShadowUI does not replace it. Shown buttons use the same icon chrome and Outer Edge as
Action Slots. `HideBlizzardBars` reparents it to `UIParent` and
`ParkBlizzardStanceBar` parks it at shipped `CENTER` (0, -84), above the Cast Bar at
`y = -132`. A Layout `stance` place overlays that park. Leftover `aura` and `form`
layout keys are ignored.

Layout also stores `player` and `target` positions, `cast` place and size, `range`
place, and `stance` place. They are not Bars. `ApplyBars` skips those keys. Shipped parks are `CENTER`
(-200, -179) and (202, -179) for the unit frames, `CENTER` (-6, -132) 288×20 for the
Cast Bar, and `BOTTOM`/`TOP` on the combat meter group for the Range Display. A Profile overlay parks them.

The mana ticker is always `TOPLEFT`/`TOPRIGHT` under `PlayerFrameManaBar`. It is not
edit-mode draggable. Warriors skip it. Regen ticks are unexplained mana gains after
combat-log `SPELL_ENERGIZE` is subtracted; a mana-costing cast that produces a deficit
starts a 5-second countdown, then the 2-second tick bar. Both bars show remaining
time in seconds (`3.5s`) on the left.

The swing timer sits in the combat meter group under the GCD Sweep, same width as
the Cast Bar, flush with no gap. The spell icon overlays the left of
the Cast Bar at the same height so the fill shows through. Channel spells
show interior ticks. The Cast Bar uses
Outer Edge. The GCD Sweep starts on any player
cast or channel, not only on a weapon swing. Layout Edit Mode moves the Cast Bar and the rest
of the stack follows. It previews the Cast Bar, the GCD Sweep, and all three swing
lanes. A lane stays hidden until that swing is active. Main-hand is for melee classes (Warrior, Paladin, Hunter, Rogue, Shaman,
Druid). Off-hand is for dual-wield classes (Warrior, Hunter, Rogue, Shaman). Ranged
is for Hunter Auto Shot and wand classes (Priest, Mage, Warlock). GCD Sweep and
Swing Timer fills stay more transparent than the Cast Bar. Each lane uses
Outer Edge. Slam resets the main-hand bar; an incoming parry applies Classic 40%
haste with a 20% remaining floor. Extra attacks skip the next main-hand reset.
Off-hand and ranged bars also hide when that weapon speed is missing.

The Range Display ships `BOTTOM`/`TOP` on the combat meter group with offset
`(0, 0)`, so it sits flush on the top of the Cast Bar and shares its centre.
Layout Edit Mode can drag it. It shows min–max yards on the current target via
LibRangeCheck-3.0. Close / short / medium / default / out-of-range colours match
RangeDisplay defaults. If only a minimum is known, the meter shows `N +`.
Mouseover, pet, focus, arena, and warning sounds are not shipped.

The Shield Row parents to `PlayerName` at `BOTTOM`/`TOP` with offset 4. It is not
edit-mode draggable. Icons stay square. `SetPortraitToTexture` crops each spell
icon to an oval, the same crop as a unit portrait. Classic `SetMask` plus
`SetTexCoord` samples mask UVs and paints stripes, so the row does not use that
path. Fill still uses a clip frame. The row locks `BOTTOMLEFT` / `TOPLEFT` on
`PlayerName`.
Mage Fire/Frost Ward, Warlock Shadow Ward, Mage Ice Barrier,
Priest Power Word: Shield, and Mage Mana Shield each get a school-coloured icon.
Classic Era max absorb is rank base plus 10% of the matching school bonus (5% for
Mana Shield). `GetSpellBonusDamage` already adds generic spell power to that
school. Improved Power Word: Shield, Frost Warding, and Improved Ice Barrier apply
after the bonus. Remaining absorb comes from combat-log absorb amounts. Classic
`SPELL_DAMAGE` has no overkill field; modern payloads do. A half-full
shield fills the lower half of the icon and reads `50%`.

## Known limitations

- **Possess needs in-game validation.** Possess buttons are driven by
  `/click PossessButtonN`. `PossessBarFrame` is therefore parked off-screen at alpha 0
  rather than hidden, because clicks against a hidden secure button do not fire.
  LibActionButton-1.0 has no possess (or pet) action type, so no library path exists.
- **Profile keybinds are override clicks.** `ApplyKeybinds` maps Blizzard and
  Bartender names (`ACTIONBUTTON*`, `MULTIACTIONBAR*BUTTON*`, `CLICK BT4ButtonN`)
  to `SetOverrideBindingClick` on `ShadowUIActionButtonN` with LAB's `Keybind`
  click type. Buttons set `useOnKeyDown` and `RegisterForClicks("AnyDown")` so
  the action fires on key down and on click down.
  It does not call `SaveBindings`. Mage defaults ship Currentz's
  Bartender hotkeys. Warrior ships one Class physical grid for every Variant:
  `Q` starts the fixed utility row at slot 1, `1` starts the paged main Bar at
  button 73, and mouse keys stay on slots 109–111. Arms, Fury, and
  Protection tombstone those stance macros (`false`) and use the Blizzard Stance Bar.
  Apply clears tombstoned Action Slots so a reload cannot put Battle, Defensive, or
  Berserker Stance back on `bar8`. Variants change Action Deck entries, not physical keys. Merge prefers the
  profile bind when two names share a key, so a
  leftover client `Q` on slot 61 does not win. Other classes import live
  client BT4/Blizzard binds.
  Keybind Edit Mode writes `CLICK ShadowUIActionButtonN:Keybind` onto the active Profile.
  `/shadowui binds` (or **Edit keybinds** in `/shadowui`) starts the Bartender-style
  hover-and-press session. `/shadowui edit` stays Layout-only.
- **Micro and bags sit bottom-right.** When `useShadowUIMenu` is on (the default),
  `SkinMicroAndBags` parents the backpack to `ShadowUIMicroCluster`. On Classic Era
  it also parents native-size hosts to that cluster. On clients with `MicroMenu`,
  the hosts stay children of `MicroMenu` and `MicroMenu` parents to the
  cluster so Blizzard Edit Mode `Layout` does not compare nil centres. Hidden extras
  drop `layoutIndex` and leave `MicroMenu`. Hooks on `SetPoint`/`SetParent` undo
  `MoveMicroButtons` anchors to `MainMenuBarArtFrame`. The cluster
  docks to `UIParent` `BOTTOMRIGHT` with no margin. Micro buttons keep native
  size, colour, and art. Hosts do not clip. Adjacent hosts have no gap.
  The row has no gap above the bottom of the screen. `MicroMenu` sits on the backpack's left
  and keeps a positive size so Blizzard `Layout` cannot clip the row.   Classic Era keeps `SocialsMicroButton` and hides
  `GuildMicroButton`, which does not open a frame. `AchievementMicroButton`
  and `StoreMicroButton` stay hidden. `EJMicroButton` stays hidden when
  `ToggleEncounterJournal` is missing. `CollectionsMicroButton` stays hidden
  when `ToggleCollectionsJournal` is missing. The backpack keeps its native size.
  Extra bag slots and the keyring stay hidden.
  `/shadowui` can turn this off so the default Blizzard menu and bags stay on
  `MainMenuBarArtFrame`. `HideBlizzardBars` then parents `MainMenuBar` to a hidden
  `ShadowUIBlizzardPark`
  frame off the screen, hides `MainMenuBarArtFrame` and the default action buttons,
  and hooks `ActionBarController_UpdateAll`
  plus extra-bar updates so those frames cannot come back. Hiding
  `MainMenuBar` itself makes `ActionBarController` call `Show()` in a loop.
  `ShapeshiftBarFrame`/`StanceBarFrame` stay shown. `ParkBlizzardStanceBar` parents
  them to `UIParent` at the Layout `stance` place so parked `MainMenuBar` cannot
  drag them off-screen.
- **XP and reputation sit at screen top.** `SkinTrackingBars` parents `MainMenuExpBar`
  to `UIParent` at `TOP` with offset 0, then stacks `ReputationWatchBar` under it.
  Character `showExperienceBar` can hide the Experience bar; reputation then docks
  to screen top. `MainMenuTrackingBar_Configure` would otherwise pin them to `MainMenuBar`.
- **Chat, unit frames, and Details charts are parked.** `SkinChat` docks `ChatFrame1`
  at `BOTTOMLEFT` (36, 32) with fill `0,0,0,202/255` and font size 16.
  `ParkFrame` snaps only the place. Size stays with Blizzard Chat and Blizzard
  Edit Mode, including after reload.
  `SkinUnitFrames` docks `PlayerFrame` at `CENTER` (-200, -179) and `TargetFrame`
  at `CENTER` (202, -179) until Layout supplies a new place. It also hides
  `TargetFrameBackground` / `FocusFrameBackground`. Classic `CheckClassification`
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
  Target Frame. The Target Frame spell bar sits 2px above Name Background at mana
  width. Spell name sits on the left. Remaining / duration sits on the right. Target auras sit 2px to the right of the
  Target Frame in horizontal rows at 32px so Aura Duration numbers fit. Target of Target auras sit 2px to the right of
  Target of Target in a horizontal row. Layout Edit Mode drags Bars, the Player
  Frame, and the Target Frame. If Details! is not loaded, `SkinDetails` does
  nothing.
- **Blizzard chrome uses Lorti vertex colors.** `SkinDarken` sets 0.05 on unit-frame
  art, 0.14 on Target and Focus Frame Art, 0.35 on window art, and 0.2 on leftover bar/XP art, then hooks
  `SetVertexColor`, `SetTexture`, and `SetAtlas` so Blizzard cannot reset the player or target chrome. Portraits
  stay native. A non-player Target Frame portrait keeps full original colour: no Portrait Ring, no gradient, and no wash. Target and Focus Frame Art use soft Darken (0.14) so original chrome still shows. ShadowUI does not
  ship Lorti's replacement elite textures. `SkinRareElite` swaps the native Frame Art atlas only. It does not crop a second overlay. A rare-elite target uses the Rare-Elite dragon. Soft Darken (0.14) keeps the dragon visible. The Target Frame paints a Threat Bar bubble tab on the 45-degree edge of the circular portrait.
  Action buttons that have a spell or item, plus buffs and debuffs, use
  a 0.05 fill with a 2px icon inset and a 4px black outer edge (`media/outer_shadow.tga`).
  An Action Slot with no spell, macro, or item stays hidden, including its Keybind label.
  A Shift-drag pickup shows every standard Bar (including a Bar that is off) and paints
  empty Action Slots as drop targets, including each Keybind label. Special Bars that are off stay hidden.
  ItemRack worn-item buttons (`ItemRackButton0`–`20`) and menu buttons (`ItemRackMenuN`)
  get the same icon chrome when ItemRack is loaded. The ItemRack minimap icon stays a
  Minimap Icon on the square path and does not get a second Outer Edge. ItemRack docks
  `ItemRackMenuFrame` to that icon; ShadowUI reparents the set menu to `UIParent` so the
  square map mask does not clip it and ItemRack's mouseover timer can keep it open.
  If ItemRack is not loaded, `SkinItemRack` does nothing.
  Bags (`skin/bags.lua`, `skin/rainbow.lua`) stay in the tree and are not loaded.
  `ApplySkins` does not call `SkinBags`. Blizzard bag and bank windows stay. Darken
  still tints those Blizzard windows. Extra bag-slot icons on the Micro Cluster stay hidden.
  ShadowUI action buttons show Cooldown Count for cooldowns of 2s or more. The GCD swipe
  has no number.   Unused buff and debuff slots stay empty. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place. ShadowUI skins their icons and does not park or snap them.
  Target auras sit 2px to the right of the Target Frame in horizontal rows at 32px so Aura Duration numbers fit. Target of Target auras sit 2px to the right of Target of Target in a horizontal row. Target Frame and Focus Frame auras show Aura Duration from UnitAura. Native Duration text stays hidden. Player BuffFrame keeps Blizzard duration text.
  The Target Frame keeps native Blizzard Status Text on health and mana. ShadowUI does not paint a caption.
  Health, mana, rage, energy, and other power bars use Meter Fill: a horizontal lighting overlay of the live Blizzard colour. Name Background on the Target Frame and Focus Frame uses the same lighting. A player unit uses class colour. A non-player unit keeps reaction colour. Nameplates keep Blizzard layout; Meter Fill paints their health and power bars.
  The Threat Bar is a round bubble tab on the 45-degree edge of the portrait. It sits over the portrait rim. It stays hidden at 0%. Solo still shows the percent. Native NumericalThreat is not the host. Fill is one circle with a vertical lighting gradient. The fill host sits at 50% opacity so Classic SetGradient cannot drop the glass. The Darken stroke stays opaque. Colour follows UnitDetailedThreatSituation: dark glass below 70%, yellow-to-orange at 70–88%, orange-to-deep-orange at 88–99%, red-to-deep-red at 100% and above. Percent can exceed 100. A thick circular Darken stroke matches Target Frame chrome. Nested discs, offset drops, and Outer Edge stay hidden. Threat Number is one outlined line at size 9. It is not a StatusBar.
  The minimap parks flush at `TOPRIGHT` (0, 0). It uses SexyMap's square mask (`WHITE8X8`) and square icon path, inside a 16px 0.05 Darken buffer at 0.6 alpha. Zone Text sits 4px below the top of the screen and 3px above the map. Time is Blizzard `TimeManagerClockButton`, restyled under the map: the clock border stays hidden, the chip sizes to the ticker, hover keeps Time Info, and a click opens the Blizzard Stopwatch. `GameTimeFrame` stays hidden. The mouse wheel zooms. After 5 seconds the map zooms out. Nova World Buffs `MinimapLayerFrame` (World Layer) sits on the bottom of the holder so the map mask does not clip it. An Outer Edge wraps the holder. The circular `MinimapCluster` does not stay behind it. Cluster icons, including late `LFGMinimapFrame`, ItemRack, and LibDBIcon buttons, sit on the square path 10px outside the map. The player can drag those icons. Buttons that parent to `Minimap`, `MinimapCluster`, or `MinimapBackdrop` park on the square map.
- **Classic LAB create is patched in-tree.** Vendored LibActionButton-1.0 `CreateButton` pcalls `RegisterForClicks("AnyDown", "AnyUp")` (fallback `AnyUp`), sets `MasqueSkinned` from config **before** `UpdateConfig` (which runs `UpdateAction`), and nil-guards retail-only regions. Unknown events are `pcall`ed. Bar frames use `SecureHandlerStateTemplate` only; black chrome is a color texture. `ApplyBars` hides Blizzard bars only after ShadowUI bars exist. `ApplyAll` pcalls each step and prints the label if one fails, so skins can still run.
- **Hotkeys are painted from binds, not GetBindingKey.** Override clicks do not show in LAB's hotkey lookup. `FlushPendingKeybinds` merges the live client ACTIONBUTTON / MULTIACTIONBAR / BT4 names with the profile (profile wins by name, by key, and by Action Slot), then writes `shadowUIHotkey` onto each LAB button. A paged Warrior button uses the stable Action Slot in its frame name, not LAB's active stance slot, so its label does not move with the stance. An empty Action Slot hides that Keybind label except during Keybind Edit Mode or a pickup. Priest/class files with empty `keybinds` still pick up Bartender keys from the client. Warrior shipped Keybinds win when they share a key or an Action Slot with a leftover client name.
- **Options are Profiles, Bar on/off, Unit Frames, and edit-session entry.** `/shadowui` has an on/off toggle for every Bar, including pet and possess when the current class Layout does not list them. Each toggle reads `enabled` on the active Profile and writes to that Profile. The AceConfigDialog host uses Darken fill and tooltip edge instead of DialogBox parchment. AceGUI controls created in that window use the same Darken. **Shift and Prune** packs Keybinds left. **Edit layout** and **Edit keybinds** stay in General. **Unit Frames** is the visual Widget builder. A Shift+Alt drag on a standard Bar inserts the action and Keybind and shifts that row right.
- **Talent tab shape is inferred.** `TalentPointsFromTabInfo` takes the larger numeric
  value of the third and fifth returns of `GetTalentTabInfo` to read both the Classic
  Era and modernized signatures without branching on client build.

## Out of scope

Nameplate replacement, objective tracker, bag-slot icons on the Micro Cluster, combined inventory and bank (Bags files stay parked), and Focus / Pet / Party / raid Unit Frames are not in scope. Player Frame and Target Frame are ShadowUI Unit Frames (ADR 0007). Until cutover, Chrome still paints Blizzard PlayerFrame and TargetFrame and the ShadowUI hosts stay hidden. Nameplates stay Blizzard frames; Meter Fill paints their health and power bars. Target of Target stays on the Blizzard default `BOTTOMRIGHT` (−35, −10) on the Target Frame. The player Cast Bar stays the ShadowUI combat meter. Target and focus cast bars stay the Blizzard spell bars (Classic Era 1.15 Show Enemy Cast Bar). The Target Frame spell bar sits 2px above Name Background at mana width. Spell name sits on the left. Remaining / duration sits on the right. Target auras sit 2px to the right of the Target Frame in horizontal rows at 32px so Aura Duration numbers fit. Target of Target auras sit 2px to the right of Target of Target in a horizontal row. Party and nameplate cast bars are not shipped. The Target Frame does not add a full-frame threat flash; the Threat Bar is a bubble tab on the circular portrait. Details! still parks the threat chart.

The Action Deck places catalog macros and spells onto Action Slots (`/shadowui deck`, out of combat). It validates catalog name and body before it changes live data. It then deletes both macro tabs, recreates only the unique resolved loadout macros on the General tab, and leaves the character tab empty. Rebuilding before index lookup prevents a deleted stale macro from shifting an unrelated macro, such as Power Infusion, onto a Warrior slot. It clears every slot the merged deck owns before placement, so stale actions cannot survive in an empty deck position. Warrior Variants tombstone the mouse stance slots (109–111). Apply, later `PLAYER_ENTERING_WORLD`, and `SPELLS_CHANGED` clear those tombstones so Battle, Defensive, and Berserker Stance cannot return on `bar8` after a reload. PlaceDeck applies that merged deck so in-game slots match the Macro Cursor HUD. Loadout Class still includes the active Variant; a missing Variant uses the first shipped Variant so apply cannot write the class skeleton. `/shadowui` Loadout chooses Class, Variant, or Character (`placeDeckFrom`). Classic Era picks up abilities by name; `C_Spell.PickupSpell` uses the spell id when present. Live Keybind and Action Deck overlays live in AceDB SavedVariables. Macro Cursor writes those files only when the client is closed. First GET migrates leftover `docs/macros/keybinds.json` and `actions.json` into Account SavedVariables, then stops serving them as live stores. Save as default and managed deck bake still write shipped `defaults/*.lua` for git. [docs/macros/](macros/) is the catalog. **WoW Macro Cursor** (`macro-cursor/`) is a Vite sidecar that loads that catalog by class group. The Characters view lists every Classic Era WTF toon folder with class and level. A loadout drop, Copy bars, or Copy to other pages on a managed Action Deck slot writes the selected Layer in SavedVariables. Managed Action Deck macros also bake into the Class Lua Action Deck for that Variant. On startup the sidecar diffs live `macros-cache.txt` into the library. It writes cache heals and SavedVariables only when the client is closed. Copy a body into `/macro`, or export `macros-cache.txt` while the game is closed. Default path: `/Applications/World of Warcraft/_classic_era_`. Override with `WOW_CLASSIC_ERA`.
