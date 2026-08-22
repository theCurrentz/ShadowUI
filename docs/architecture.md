# ShadowUI Architecture

Classic Era / Season of Discovery addon. Replaces Blizzard action bars with custom LibActionButton bars, applies selective chrome skinning, and provides a fixed cast/GCD bar. Layout and keybinds inherit through **Base → Class → Variant**. Domain terms live in [CONTEXT.md](../CONTEXT.md). The account-owned stack is [ADR 0001](adr/0001-account-class-inheritance.md).

## Module layout

```text
ShadowUI/
  ShadowUI.toc
  libs/                         Ace3, LibStub, CallbackHandler, LibActionButton, LibRangeCheck
  core/
    init.lua                    AceAddon bootstrap, lifecycle, slash commands
    db.lua                      AceDB account + character schema
    resolve.lua                 sparse merge and effective config resolution
    keybinds.lua                combat-safe keybind apply
  defaults/
    base.lua                    shared centered bar layout
    classes/*.lua               sparse class deltas (stance/aura/form/pet)
  bars/
    button.lua                  LAB buttons, Action Slot Lock, 2px Lorti-dark icon chrome and a 4px outer edge
    bar.lua                     standard bar frames, HUD overlay drag in Layout Edit Mode
    cooldown.lua                remaining cooldown seconds on ShadowUI action buttons
    pet.lua                     pet action binding and token texture resolve
    special.lua                 stance, aura, form, possess, pet bars
    manager.lua                 apply resolved layout; hide Blizzard bars
  cast/
    castbar.lua                 Quartz-like Cast Bar with Lorti chrome, overlay icon, channel ticks, spark, and latency
    gcd.lua                     skinny glossy GCD Sweep under the Cast Bar
    manaregen.lua               regen tick vs FSR spend classification
    manaticker.lua              5SR + tick bars with remaining seconds under PlayerFrameManaBar
    swing.lua                   player swing timers under the GCD Sweep; class-gated hands; Outer Edge
    range.lua                   target Range Display; Layout Edit Mode can drag it
    shields.lua                 Classic Era absorb catalogue, remaining absorb, combat log
    shieldrow.lua               colour-coded Shield Row locked to the Player Frame
  skin/
    chrome.lua                  matte fill on ShadowUI bars; Lorti outer edge; ParkFrame; ApplySkins
    darken.lua                  Lorti SetVertexColor lock helper
    frames.lua                  unit, raid, party, pet, tooltip chrome; parked player/target; Rare-Elite dragon
    statustext.lua              Target Frame health and mana Status Text
    threat.lua                  Target Frame Threat Bar flush on the nameplate
    windows.lua                 bags, character, vendor, XP art
    auras.lua                   buff and debuff icon chrome and Outer Edge (BuffButton and BuffFrame.auraFrames)
    auratime.lua                Target Frame and Focus Frame Aura Duration swipe and seconds
    chat.lua                    parked General chat with Currentz fill
    micro.lua                   micro + backpack on ShadowUIMicroCluster, native art, flush bottom-right
    tracking.lua                XP + reputation bars at screen top
    minimap.lua                 SexyMap-style square mask and icon path; 16px Darken buffer; Zone Text; Time; World Layer; draggable icons
    details.lua                 parked Details! damage and threat charts
    itemrack.lua                ItemRack worn-item and menu button icon chrome and Outer Edge
  edit/
    mode.lua                    layout edit toggle, snap grid, magenta centre guides, persist drags
    frames.lua                  HUD drag hosts for Player Frame, Target Frame, Cast Bar, and Range Display
    keybinds.lua                hover-and-press Keybind Edit Mode
    layer.lua                   HUD layer picker: Base | Class | Variant save target
  profile/
    variants.lua                named variants, talent bind, manual override
  options/
    config.lua                  AceConfig panel
  sim/
    dump_layout.lua             emit layout.json from shipped Base+Class
    chrome.lua                  geometric chrome placeholders
    rect.lua                    WoW point to HTML pixel mapping
    index.html                  Vite HUD preview
    src/                        TypeScript harness (pnpm, Vite, Node)
```

## Layout harness

`sim/` is not loaded by the addon. `lua sim/dump_layout.lua` writes `sim/layout.json` from shipped Base + Class (no SavedVariables). Run `pnpm --dir sim dev` to dump that JSON and serve a 1920×1080 geometric Classic HUD with Vite. The preview reloads when TypeScript, CSS, or Layout Lua change. Chrome, combat meters, and Tracking move and resize on a 12px grid. Action buttons are 32.4px (90% of 36). Action Bars snap resize to 12-slot grids (columns 12, 6, 4, 3, 2, or 1). Save copies Lua or stores a named browser save. Paste bar deltas into `defaults/base.lua` or `defaults/classes/*.lua`. Paste Chrome deltas into `sim/chrome.lua`. Layout Edit Mode snaps Bars, the Player Frame, the Target Frame, the Cast Bar, and the Range Display to 32.4px from screen bottom-left, matching the visible grid. Hold Shift while dragging to skip snap. The Cast Bar also resizes. A DIALOG-strata HUD overlay sits on each host so drag is not eaten by action buttons. Magenta guides mark screen centre. Layout Edit Mode does not move other Chrome, the GCD Sweep or Swing Timer on their own, Chat, Details Windows, or the Shield Row. If Blizzard Edit Mode moves the Player Frame or the Target Frame, ParkFrame snaps them back to Layout.

## Load order

Defined in `ShadowUI.toc`:

1. `libs/embeds.xml` — vendored libraries
2. `core/` — init, db, resolve, keybinds
3. `defaults/` — base, then class files (WARRIOR … DRUID)
4. `bars/` — button, cooldown, bar, pet, special, manager
5. `cast/` — castbar, gcd, manaticker, swing, range, shields, shieldrow
6. `skin/` — chrome, darken, frames, statustext, threat, windows, auras, auratime, chat, micro, tracking, minimap, details, itemrack
7. `edit/` — mode, frames, keybinds, layer
8. `profile/` — variants
9. `options/` — config

Later files replace stub methods on the `ShadowUI` addon table defined in `core/init.lua`.

## SavedVariables schema

### Account (`ShadowUIDB`)

Shared across characters on the account.

```lua
{
  base = {
    layout = { [barId] = { point, relativeTo, relativePoint, x, y, columns, buttons, scale, enabled, buttonSize, ... } },
    keybinds = { [bindingName] = key },
  },
  classes = {
    WARRIOR = {
      layout = {},
      keybinds = {},
      variants = {
        Arms = {
          talentTree = 1,   -- optional; nil = manual-only
          layout = {},
          keybinds = {},
        },
      },
    },
  },
}
```

### Character (`ShadowUICharDB`)

Per-character state only.

```lua
{
  activeVariant = "Arms",   -- nil until set or talent auto-bind
  editLayer = "variant",    -- "base" | "class" | "variant"
  variantManual = false,    -- true after manual /shadowui variant; cleared by variant clear
  hardLockActionSlots = false, -- true blocks Shift-drag between Action Slots
  useShadowUIMenu = true,      -- false restores the default Blizzard micro menu and bags
}
```

Shipped defaults live in `ShadowUI.Defaults` (populated by `defaults/*.lua`), not in SavedVariables.

## Resolve rules

`ResolveEffective(classFile?, variantName?)` returns `{ layout, keybinds }`.

Merge order (each step sparse-merges into the result; later wins per field):

1. Shipped `Defaults.base`
2. Shipped `Defaults.classes[classFile]`
3. Account `db.base`
4. Account `db.classes[classFile].layout` and `.keybinds`
5. Active variant deltas: `db.classes[classFile].variants[variantName]`

**Active variant selection** (`GetActiveVariantName`):

1. If `variantManual` and `activeVariant` set → use `activeVariant`
2. Else match variant with `talentTree` equal to the primary talent tab (most points spent)
3. Else fall back to `activeVariant` (may be nil → variant layer skipped)

**Layout Edit Mode writes** (`WriteLayerDelta(layer, section, key, patch)`):

- `layer` defaults to `editLayer` on the character DB
- `base` → `db.base[section][key]`
- `class` → `db.classes[class].layout|keybinds[key]`
- `variant` → active variant (or `"Default"`) under `db.classes[class].variants`
- Layout patches are tables (sparse-merged). Keybind patches are strings, or `false` to unbind a name on that Layer.

`/shadowui edit` toggles Layout Edit Mode (grid + HUD overlay drag on Bars, the Player Frame, the Target Frame, the Cast Bar, and the Range Display). Hold Shift while dragging to skip snap. `/shadowui binds` toggles Keybind Edit Mode (hover a button, press a key). The two sessions cannot run together. Keybind Edit Mode does not call `SaveBindings`. Combat closes either edit session.

`ApplyAll()` resolves config then calls `ApplyBars`, `ApplyKeybinds`, `ApplyAutoLoot`, `ApplySkins`, `ApplyCastBar`, `ApplyManaTicker`, `ApplySwingTimer`, `ApplyRangeDisplay`, and `ApplyShields`. `ApplyAutoLoot` sets the client CVar `autoLootDefault` on. `ApplySkins` also paints Target Frame Status Text and the Threat Bar.

## Lifecycle

| Event | Action |
|-------|--------|
| `OnInitialize` | `SetupDB`, register `/shadowui` and `/sui` |
| `OnEnable` | register `PLAYER_ENTERING_WORLD`, `PLAYER_REGEN_ENABLED`, `PLAYER_REGEN_DISABLED`, `PLAYER_TALENT_UPDATE`, `CHARACTER_POINTS_CHANGED` |
| First `PLAYER_ENTERING_WORLD` | `ApplyAll` once per session |
| `PLAYER_TALENT_UPDATE` / `CHARACTER_POINTS_CHANGED` | re-apply unless `variantManual` |
| `PLAYER_REGEN_ENABLED` | flush deferred `ApplyAll`, keybinds, special-bar refresh |
| `PLAYER_REGEN_DISABLED` | close Layout Edit Mode or Keybind Edit Mode |

Event names vary by client flavour, so each registration is wrapped in `pcall`; an
unknown event is skipped instead of aborting `OnEnable`.

### Combat safety

`ApplyAll` creates frames, sets secure attributes, and hides protected Blizzard
frames, so it is deferred wholesale when `InCombatLockdown()` returns true. It sets
`pendingApplyAll` and `OnRegenEnabled` replays it. `ApplyBars`, `ApplySkins`, and
`ApplyCastBar` repeat the same guard so a direct call cannot mutate protected state
mid-combat. `ApplyManaTicker`, `ApplySwingTimer`, `ApplyRangeDisplay`, and `ApplyShields` only create unprotected frames and may run in combat. Keybinds queue in `_pendingKeybinds`; special-bar refreshes queue in
`pendingSpecialBarRefresh`. Both flush from `OnRegenEnabled`.

## Bar IDs

Standard: `bar1` … `bar10` (action slots 1–120). A Class layout may set
`firstSlot` so a bar shows a different 12-slot range. Mage rotates bars 2–6:
bar2 shows slots 61–72 (old bar6), then 13–24, 25–36, 37–48, 49–60. Base ships
`bar1`–`bar6` as six horizontal rows stacked on the bottom edge with **bar1 on
top** and **bar6 on the bottom**. `bar7` and `bar8` are 3×4 blocks on the left
and right of that stack.
`bar9`–`bar10` ship disabled. Pet and possess sit in a gap above the six-row stack.
Every shipped rect stays within ±360 of screen centre (asserted by
`tests/layout_spec.lua`).

Special (class-gated in `bars/manager.lua`): `stance` (Warrior), `aura` (Paladin),
`form` (Druid, Rogue, Priest, Shaman), `pet` (Hunter, Warlock), `possess` (all).
The three shapeshift ids share one class gate because they all read
`GetShapeshiftFormInfo`; a bar with no available forms hides itself. Shipped positions
for special bars are sparse class deltas at `y = -84`, above the Cast Bar at `y = -132`.

Layout also stores `player` and `target` positions, `cast` place and size, and `range`
place. They are not Bars. `ApplyBars` skips those keys. Shipped parks are `CENTER`
(-200, -179) and (202, -179) for the unit frames, `CENTER` (-6, -132) 288×20 for the
Cast Bar, and `CENTER` (-6, -170) for the Range Display. A Layer delta overlays them.

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

The Range Display ships `CENTER` on `UIParent` at offset `(-6, -170)`, the
Whitemane Currentz RangeDisplay lock. Layout Edit Mode can drag it. It shows
min–max yards on the current target via LibRangeCheck-3.0. Close / short /
medium / default / out-of-range colours match RangeDisplay defaults. If only a
minimum is known, the meter shows `N +`. Mouseover, pet, focus, arena, and
warning sounds are not shipped.

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

- **Action page paging is not implemented.** Bars are bound to fixed action slots via
  `SetState(0, "action", slot)`. There is no `RegisterStateDriver` on `actionpage`, so
  Blizzard bonus-bar and stance paging does not swap `bar1` contents. The
  `SecureHandlerStateTemplate` on bar frames is in place for this follow-up.
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
  Bartender hotkeys; other classes import live client BT4/Blizzard binds.
  Keybind Edit Mode writes `CLICK ShadowUIActionButtonN:Keybind` onto the selected
  Layer. A later Layer can set `false` to drop a client or earlier-layer name.
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
  and keeps a positive size so Blizzard `Layout` cannot clip the row. Classic Era keeps `SocialsMicroButton` and hides
  `GuildMicroButton`, which does not open a frame. `AchievementMicroButton`
  and `StoreMicroButton` stay hidden. The backpack keeps its native size.
  Extra bag slots and the keyring stay hidden.
  `/shadowui` can turn this off so the default Blizzard menu and bags stay on
  `MainMenuBarArtFrame`. `HideBlizzardBars` then parents `MainMenuBar` to a hidden
  `ShadowUIBlizzardPark`
  frame off the screen, hides `MainMenuBarArtFrame`, the default action buttons,
  and `ShapeshiftBarFrame`/`StanceBarFrame`, and hooks `ActionBarController_UpdateAll`
  plus shapeshift updates so those frames cannot come back. Hiding
  `MainMenuBar` itself makes `ActionBarController` call `Show()` in a loop.
  If the default shapeshift bar stays shown, it follows the parked `MainMenuBar`
  to screen centre and sits on the ShadowUI stance bar.
- **XP and reputation sit at screen top.** `SkinTrackingBars` parents `MainMenuExpBar`
  to `UIParent` at `TOP` with offset 0, then stacks `ReputationWatchBar` under it.
  `MainMenuTrackingBar_Configure` would otherwise pin them to `MainMenuBar`.
- **Chat, unit frames, and Details charts are parked.** `SkinChat` docks `ChatFrame1`
  at `BOTTOMLEFT` (36, 32) at 608×294 with fill `0,0,0,202/255` and font size 16.
  `SkinUnitFrames` docks `PlayerFrame` at `CENTER` (-200, -179) and `TargetFrame`
  at `CENTER` (202, -179) until Layout supplies a new place. `SkinDetails` docks
  the Details! damage chart flush `RIGHT` (0, -194) at 153×164 and the Tiny
  Threat chart at `BOTTOMRIGHT` (0, 150) at 153×106. Numbers come from Whitemane
  Currentz. `ParkFrame` uses `SetPointBase` when 1.15.9 Edit Mode has replaced
  `SetPoint`, then hooks `ApplySystemAnchor` so Blizzard Edit Mode, Leatrix Plus, and
  Details cannot keep a different place. Layout Edit Mode drags Bars, the Player
  Frame, and the Target Frame. If Details! is not loaded, `SkinDetails` does
  nothing.
- **Blizzard chrome uses Lorti vertex colors.** `SkinDarken` sets 0.05 on unit-frame
  art, 0.35 on window art, and 0.2 on leftover bar/XP art, then hooks
  `SetVertexColor`, `SetTexture`, and `SetAtlas` so Blizzard cannot reset the player or target chrome. Portraits
  stay native. Elite and rare target borders darken in place; ShadowUI does not
  ship Lorti's replacement elite textures. A rare-elite target uses the Blizzard
  Rare-Elite dragon, then Darken. The Target Frame paints a full-width Threat Bar flush on the nameplate.
  Action buttons, buffs, and debuffs use
  a 0.05 fill with a 2px icon inset and a 4px black outer edge (`media/outer_shadow.tga`).
  ItemRack worn-item buttons (`ItemRackButton0`–`20`) and menu buttons (`ItemRackMenuN`)
  get the same icon chrome when ItemRack is loaded. The ItemRack minimap icon stays a
  Minimap Icon on the square path and does not get a second Outer Edge. If ItemRack is
  not loaded, `SkinItemRack` does nothing.
  ShadowUI action buttons show Cooldown Count for cooldowns of 2s or more. The GCD swipe
  has no number. Unused buff and debuff slots stay empty. Player buffs sit 2px left of the square minimap.
  Target Frame and Focus Frame auras show Aura Duration from UnitAura. Player BuffFrame keeps Blizzard duration text.
  The Target Frame paints one centre Status Text caption on health and mana using the Blizzard Status Text option. Native LeftText, RightText, and TextString stay hidden.
  The Threat Bar stays hidden at 0%. Solo still shows the percent. Native NumericalThreat is not the host. Fill follows UnitDetailedThreatSituation. Colour goes from desaturated grey, to orange, to blood red.
  The minimap parks flush at `TOPRIGHT` (0, 0). It uses SexyMap's square mask (`WHITE8X8`) and square icon path, inside a 16px 0.05 Darken buffer at 0.6 alpha. Zone Text sits 4px below the top of the screen and 3px above the map. Blizzard Time (`TimeManagerClockButton`) sits on the bottom-right of the map. A click opens the Stopwatch. Darken does not paint Time. Nova World Buffs `MinimapLayerFrame` (World Layer) sits on the bottom of the holder so the map mask does not clip it. An Outer Edge wraps the holder. The circular `MinimapCluster` does not stay behind it. Cluster icons, including late `LFGMinimapFrame`, ItemRack, and LibDBIcon buttons, sit on the square path. The player can drag those icons. Buttons that parent to `Minimap`, `MinimapCluster`, or `MinimapBackdrop` park on the square map.
- **Classic LAB create is patched in-tree.** Vendored LibActionButton-1.0 `CreateButton` pcalls `RegisterForClicks("AnyDown", "AnyUp")` (fallback `AnyUp`), sets `MasqueSkinned` from config **before** `UpdateConfig` (which runs `UpdateAction`), and nil-guards retail-only regions. Unknown events are `pcall`ed. Bar frames use `SecureHandlerStateTemplate` only; black chrome is a color texture. `ApplyBars` hides Blizzard bars only after ShadowUI bars exist. `ApplyAll` pcalls each step and prints the label if one fails, so skins can still run.
- **Hotkeys are painted from binds, not GetBindingKey.** Override clicks do not show in LAB's hotkey lookup. `FlushPendingKeybinds` merges the live client ACTIONBUTTON / MULTIACTIONBAR / BT4 names with the profile (profile wins), then writes `shadowUIHotkey` onto each LAB button. Priest/class files with empty `keybinds` still pick up Bartender keys from the client.
- **Options are variant/layer and edit-session entry.** `/shadowui` does not contain bar-layout sliders. It has **Edit layout** and **Edit keybinds**.
- **Talent tab shape is inferred.** `TalentPointsFromTabInfo` takes the larger numeric
  value of the third and fifth returns of `GetTalentTabInfo` to read both the Classic
  Era and modernized signatures without branching on client build.

## Out of scope

Nameplates, objective tracker, bag-slot icons, and unit-frame replacement are not in scope. ShadowUI parks and darkens Blizzard Player and Target frames. It does not replace them. The player Cast Bar stays the ShadowUI combat meter. Target and focus cast bars stay the Blizzard spell bars (Classic Era 1.15 Show Enemy Cast Bar). Party and nameplate cast bars are not shipped. The Target Frame does not add a full-frame threat flash; the Threat Bar is the full-width meter flush on the nameplate. Details! still parks the threat chart.
