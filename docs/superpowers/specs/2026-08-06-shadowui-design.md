# ShadowUI Design Spec

**Date:** 2026-08-06  
**Status:** Approved for implementation planning  
**Target client:** World of Warcraft Classic Era / Season of Discovery (Interface `115xx`)  
**Addon name:** ShadowUI  

## Goal

ShadowUI is a Classic Era/SoD addon that replaces Bartender-style action bar management and selective Lorti-style chrome with one opinionated, auto-configuring system. Layouts and keybinds are profiled by **class** (not character), with an inheritance stack of **Base → Class → Variant**. New characters apply a complete layout with no setup wizard.

## Non-goals (v1)

- Unit-frame replacement, nameplates, objective tracker, or restyle beyond Lorti vertex-color chrome
- Configurable cast bar (position, size, colors are fixed by design)
- Full Bartender feature parity (fades, complex state conditions beyond stance/aura/form/paging, per-button drag)
- Multi-flavor support (Cata/MoP) in v1

## Approach

**Custom bars bound to action slots** (Bartender-style), using LibActionButton for button behavior. Blizzard main-menu art and default bar frames are hidden/disabled where they conflict. Chrome skinning covers: our bars, minimap, chat, micro menu, bag bar, a custom cast/GCD bar, and Lorti vertex-color darkening of Blizzard unit-frame and window art.

## Architecture

```text
ShadowUI/
  ShadowUI.toc
  libs/                         -- Ace3, LibStub, CallbackHandler, LibActionButton
  core/
    init.lua                    -- AceAddon bootstrap, lifecycle
    db.lua                      -- AceDB schema, defaults registration
    resolve.lua                 -- merge Base → Class → Variant into effective config
  bars/
    bar.lua                     -- bar frame: grid, drag, scale, columns
    button.lua                  -- LAB buttons with 2px Lorti-dark icon chrome
    cooldown.lua                -- remaining cooldown seconds on ShadowUI action buttons
    manager.lua                 -- create/enable all bars; apply resolved layout
    special.lua                 -- stance / aura / form / possess / pet bars
  cast/
    castbar.lua                 -- Quartz-like cast/channel bar (fixed layout)
    gcd.lua                     -- GCD underlay bar
    manaregen.lua               -- regen tick vs FSR spend
    manaticker.lua              -- 5SR + mana ticks with remaining seconds under PlayerFrameManaBar
    swing.lua                   -- player melee and ranged swing timers under the GCD Sweep
    range.lua                   -- target Range Display from Whitemane Currentz
    shields.lua                 -- Classic Era absorb catalogue and remaining absorb
    shieldrow.lua               -- colour-coded Shield Row locked to the Player Frame
  skin/
    chrome.lua                  -- matte fill on ShadowUI bar backdrops
    darken.lua                  -- Lorti SetVertexColor lock helper
    frames.lua                  -- unit, raid, party, pet, tooltip chrome; Rare-Elite dragon
    statustext.lua              -- Target Frame health and mana Status Text
    threat.lua                  -- Target Frame Threat Bar flush on the nameplate
    windows.lua                 -- bags, character, vendor, XP art
    auras.lua                   -- buff and debuff icon chrome
    auratime.lua                -- Target Frame Aura Duration swipe and seconds
    chat.lua                    -- semi-transparent black chat
    micro.lua                   -- micro + backpack on ShadowUIMicroCluster, native art, flush bottom-right
    minimap.lua                 -- large square blackened minimap
  edit/
    mode.lua                    -- Layout Edit Mode, grid snap, bar and unit-frame drag
    frames.lua                  -- Player Frame and Target Frame HUD hosts
    keybinds.lua                -- Keybind Edit Mode (hover and press)
    layer.lua                   -- Base | Class | Variant save-target picker
  profile/
    variants.lua                -- named variants, talent-tree bind, manual override
  options/
    config.lua                  -- AceConfig panel + slash commands
  defaults/
    base.lua                    -- shared centered layout; all bars enabled
    classes/                    -- sparse class deltas (stance/aura/form placement)
      WARRIOR.lua
      PALADIN.lua
      ...
```

### Module rules

- One responsibility per file; prefer ≤120 lines, hard cap ~200 for complex modules
- No undeclared globals; public API is the `ShadowUI` addon table
- Modern Lua style: locals, early returns, explicit module returns via AceAddon embeds
- File headers document purpose, dependencies, and public functions

## Data model

### Account DB (`ShadowUIDB`)

Stores layout and keybinds shared across characters.

```lua
{
  base = {
    layout = { -- [barId] = { point, x, y, columns, buttons, scale, enabled, ... } },
    keybinds = { -- [bindingName] = key },
  },
  classes = {
    WARRIOR = {
      layout = {},      -- sparse deltas
      keybinds = {},
      variants = {
        Arms = {
          talentTree = 1,  -- optional; nil = manual-only variant
          layout = {},
          keybinds = {},
        },
      },
    },
  },
}
```

### Character DB (`ShadowUICharDB`)

Minimal per-character state only:

```lua
{
  activeVariant = "Arms",   -- nil → talent auto-bind or shipped "Default"
  editLayer = "variant",    -- "base" | "class" | "variant"
  variantManual = true,     -- true after manual `/shadowui variant`; cleared by `variant clear`
  hardLockActionSlots = false, -- true blocks Shift-drag between Action Slots
  useShadowUIMenu = true,      -- false restores the default Blizzard micro menu and bags
}
```

### Resolve rules

1. Start from shipped defaults (Base + class file).
2. Overlay account `base`, then `classes[class].layout/keybinds`, then active variant deltas.
3. Later layers win field-by-field (sparse merge).
4. Edits in edit mode write **only** to the selected layer; default layer is **active variant**.
5. Changing Base or Class updates every character that inherits those layers.

### Variants

- Named per class.
- Optional `talentTree` index for auto-selection on talent changes.
- Manual switch via slash/options sets `activeVariant` and `variantManual = true`.
- `variant clear` clears manual override so talent binding resumes.
- If no variant matches and none selected, use an empty variant layer (effective = Base+Class).

## Bars & layout

### Visual button rules

- Action Slot Lock: click uses the action. Shift-drag moves a spell or item and does not use the action. `/shadowui` hard lock blocks that move.
- Square ability icons with a 2px Lorti-dark inset (chrome 0.05, 0.05, 0.05) and a 4px black outer edge
- No margin between buttons (button frames abut; icons do not)
- Bar backdrop: matte black fill

### Defaults

- **Base:** six reversed rows on the bottom edge; bar7 left and bar8 right as 3×4 grids
- **Class defaults:** only account for special bars (warrior stances, paladin auras, druid forms, pet, etc.) as sparse position/paging deltas — not a second full layout
- Auto-enable the centered rows on apply; hide conflicting Blizzard and Bartender bar art

### Edit mode

- Two sessions; they cannot run together
- Layout Edit Mode: `/shadowui edit` — snap grid (hold Shift to skip); HUD overlay on whole bars, the Player Frame, and the Target Frame (v1: no per-button repositioning). Blizzard Edit Mode cannot keep a different Player Frame or Target Frame place.
- Keybind Edit Mode: `/shadowui binds` — hover a button, press a key; Escape clears; no SavedBindings write
- Layer picker always visible in either session: Base / Class / Variant
- On exit: persist active layer deltas and re-apply resolved layout / keybinds

## Chrome (in scope)

| Element | Treatment |
|---------|-----------|
| Action bars (ours) | Matte black bar fill; 0.05 chrome around each icon; 4px black outer edge; Cooldown Count for cooldowns of 2s or more |
| Unit frames, raid, party, pet | Vertex color 0.05, 0.05, 0.05; color stays after Blizzard resets; Target Frame Status Text follows Blizzard Status Text; rare-elite uses the Rare-Elite dragon; Threat Bar flush on the nameplate |
| Window chrome (bags, character, vendor, bank, spellbook) | Vertex color 0.35, 0.35, 0.35; portraits stay native |
| XP / reputation art | Vertex color 0.2, 0.2, 0.2 |
| Buffs / debuffs | 0.05 chrome, 2px icon inset, 4px outer edge; unused slots stay empty; player buffs 2px left of the square minimap and 4px from the top of the screen; debuff type colour stays native; Target Frame auras show remaining time |
| Tooltips | Dark backdrop border |
| Minimap | Compact square flush to top-right, 16px 0.05 Darken buffer at 0.6 alpha, Zone Text on top, World Layer on the bottom from Nova World Buffs, Blizzard Time on the map, Outer Edge; cluster icons on the square path and draggable |
| Chat | Black, semi-transparent |
| Micro menu + bag bar | Native Blizzard size and art (no Shop); one row, flush bottom-right, 0px gap between items, 0px gap from screen bottom |
| Cast bar | Custom player Cast Bar (see below); Blizzard player cast bar hidden; target/focus spell bars stay Blizzard |

Everything else is left alone.

## Cast bar

- Custom Quartz-like cast/channel bar
- Centered at Currentz Quartz (`CENTER` `-6`, `-132`), 288 wide (narrower than a 12-slot Action Bar). A spell icon overlays the left at the same height so the fill shows through. Channel spells show interior ticks. GCD Sweep and Swing Timer lock under the Cast Bar as one group with no gap and share that width. The GCD Sweep starts on any player cast or channel. Layout Edit Mode can drag and resize the Cast Bar; the stack shares width. Layout Edit Mode previews the Cast Bar, GCD Sweep, and all Swing Timer lanes.
- Lorti-dark chrome, Outer Edge on the meter, gold cast fill, green channel fill, spark, and a latency window
- Interrupt and failed casts flash red, then hide
- Skinny glossy GCD Sweep directly underneath, only while a GCD is active; more transparent than the Cast Bar

## Swing timer

- Player main-hand, off-hand, and ranged swing bars under the GCD Sweep — **not configurable**
- Main-hand for melee classes; off-hand for dual-wield classes; ranged for Hunter and wand classes
- Hidden until that swing is active; Layout Edit Mode previews all three lanes; Outer Edge on each lane; more transparent than the Cast Bar
- Combat-log swings, Slam reset, extra-attack skip, and incoming parry haste
- Ranged bar tracks Auto Shot, wand Shoot, Shoot Bow/Gun/Crossbow, and Throw
- No target timer

## Range Display

- Target min–max yards
- Ships `CENTER` offset `(-6, -170)` from Whitemane Currentz RangeDisplay; Layout Edit Mode can drag it
- Colour bands: close 5, short 20, medium 30, default, out of range 40
- No mouseover, pet, focus, arena, or warning sounds

## Shield Row

- Colour-coded circular absorb icons, left-aligned 4px above the player name — **not configurable**
- Oval portrait crop via `SetPortraitToTexture` so Classic does not stripe the spell art
- Fire Ward, Frost Ward, Shadow Ward, Ice Barrier, Power Word: Shield, Mana Shield
- Fill is remaining absorb; percent text sits under the icon
- Classic Era coefficients: 10% school bonus (5% Mana Shield), then listed talents
- Not a Bar and not in Layout

## First-run / new character

On login (`PLAYER_LOGIN` / safe `PLAYER_ENTERING_WORLD`):

1. Detect class
2. Resolve effective config
3. Apply bars, keybinds (deferred if combat), skin, micro/bags, minimap, cast bar, Shield Row
4. No wizard, dialogs, or required user input

## Player-facing interface

### Slash commands

- `/shadowui` or `/sui` — open options
- `/shadowui edit` — toggle Layout Edit Mode
- `/shadowui binds` — toggle Keybind Edit Mode
- `/shadowui layer base|class|variant` — set edit save target
- `/shadowui variant <name>` — manual variant switch
- `/shadowui variant clear` — clear manual override

### Options panel (AceConfig)

- Active variant list/create/rename/delete
- Talent-tree binding per variant
- Current edit layer indicator
- Edit layout / Edit keybinds
- Reset selected layer / reset to shipped defaults
- No cast-bar settings
- Prefer “all bars on”; avoid exposing a large toggle matrix unless needed for support

## Libraries

Vendored (or packager-managed) under `libs/`:

- AceAddon-3.0, AceEvent-3.0, AceDB-3.0, AceDBOptions-3.0
- AceConfig-3.0, AceConfigDialog-3.0, AceGUI-3.0, AceConsole-3.0
- LibStub, CallbackHandler-1.0
- LibActionButton-1.0

## TOC / packaging

- `ShadowUI.toc` with Classic Era/SoD interface version(s) appropriate for 1.15.x
- `## SavedVariables: ShadowUIDB`
- `## SavedVariablesPerCharacter: ShadowUICharDB`
- Load order: libs → core → defaults → bars/cast/skin/edit/profile → options

## Documentation standards

- Root `README.md`: install path (`Interface/AddOns/ShadowUI`), slash commands, inheritance model
- `docs/` architecture notes kept in sync with this spec
- Every Lua module starts with a short header (purpose, deps, public API)
- Prefer clarity over cleverness in merge/resolve code — this is the correctness core

## Success criteria

1. Fresh character of any class logs in with centered bars, all bars on, skins applied, no prompts
2. Dragging a bar while edit layer = Variant updates only that variant; other classes unchanged; same-class alts see it
3. Editing Base updates all classes/characters that inherit it
4. Talent-tree change auto-selects bound variant when not manually overridden
5. Buttons use 0.05 icon chrome; minimap is square in a 0.05 frame; chat is semi-transparent black; micro+bags sit bottom-right
6. Cast bar shows thick gradient cast + GCD underlay above bars; Blizzard cast bar does not appear
7. Blizzard unit frames, window chrome, buffs, and debuffs use Lorti dark chrome; nameplates stay default

## Open implementation notes (non-blocking)

- Exact Interface version number(s) to set in TOC against current Era/SoD build at implement time
- Grid cell size chosen to match full icon size (e.g. 36px) with zero gap
- Keybind apply must respect combat lockdown; queue and flush on `PLAYER_REGEN_ENABLED`
- LibActionButton Classic Era compatibility verified when vendoring the library version
