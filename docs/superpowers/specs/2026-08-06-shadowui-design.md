# ShadowUI Design Spec

**Date:** 2026-08-06  
**Status:** Approved for implementation planning  
**Target client:** World of Warcraft Classic Era / Season of Discovery (Interface `115xx`)  
**Addon name:** ShadowUI  

## Goal

ShadowUI is a Classic Era/SoD addon that replaces Bartender-style action bar management and selective Lorti-style chrome with one opinionated, auto-configuring system. Layouts and keybinds are profiled by **class** (not character), with an inheritance stack of **Base → Class → Variant**. New characters apply a complete layout with no setup wizard.

## Non-goals (v1)

- Unit frames, nameplates, tooltips, bag interiors, objective tracker, or general frame restyling beyond the listed chrome
- Configurable cast bar (position, size, colors are fixed by design)
- Full Bartender feature parity (fades, complex state conditions beyond stance/aura/form/paging, per-button drag)
- Multi-flavor support (Cata/MoP) in v1

## Approach

**Custom bars bound to action slots** (Bartender-style), using LibActionButton for button behavior. Blizzard main-menu art and default bar frames are hidden/disabled where they conflict. Chrome skinning is limited to: our bars, minimap, chat, micro menu, bag bar, and a custom cast/GCD bar.

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
    button.lua                  -- flush square LAB buttons (no border/padding/margin)
    manager.lua                 -- create/enable all bars; apply resolved layout
    special.lua                 -- stance / aura / form / possess / pet bars
  cast/
    castbar.lua                 -- Quartz-like cast/channel bar (fixed layout)
    gcd.lua                     -- GCD underlay bar
  skin/
    chrome.lua                  -- black + soft shadow on ShadowUI bar backdrops
    chat.lua                    -- semi-transparent black chat
    micro.lua                   -- darken micro + bag bar; dock bottom-right
    minimap.lua                 -- large square blackened minimap
  edit/
    mode.lua                    -- edit mode, grid snap, bar drag
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

- Full-size square ability icons
- No borders, padding, or margin between buttons (icons abut)
- Bar backdrop: matte black with soft drop shadow for depth (shadow on bar chrome, not per-icon)

### Defaults

- **Base:** all standard bars enabled; evenly centered in the lower middle of the screen on a grid
- **Class defaults:** only account for special bars (warrior stances, paladin auras, druid forms, pet, etc.) as sparse position/paging deltas — not a second full layout
- Auto-enable all UI bars on apply; hide conflicting Blizzard bar art

### Edit mode

- Toggle via `/shadowui edit` and a bindable key
- Show snap grid; drag whole bars (v1: no per-button repositioning)
- Layer picker always visible: Base / Class / Variant
- On exit: persist active layer deltas and re-apply resolved layout

## Chrome (in scope)

| Element | Treatment |
|---------|-----------|
| Action bars (ours) | Black backdrop + soft shadow |
| Minimap | Large, square, blackened |
| Chat | Black, semi-transparent |
| Micro menu + bag bar | Darkened; moved snug to bottom-right |
| Cast bar | Custom (see below); Blizzard cast bar hidden |

Everything else is left alone.

## Cast bar

- Custom Quartz-like cast/channel bar — **not configurable**
- Centered horizontally, positioned above the action-bar cluster, sized proportionally to bar width
- Thicker main cast/channel fill with gradient coloring and depth
- GCD loop/sweep bar directly underneath
- No AceConfig options for cast/GCD appearance or position

## First-run / new character

On login (`PLAYER_LOGIN` / safe `PLAYER_ENTERING_WORLD`):

1. Detect class
2. Resolve effective config
3. Apply bars, keybinds (deferred if combat), skin, micro/bags, minimap, cast bar
4. No wizard, dialogs, or required user input

## Player-facing interface

### Slash commands

- `/shadowui` — open options
- `/shadowui edit` — toggle edit mode
- `/shadowui layer base|class|variant` — set edit save target
- `/shadowui variant <name>` — manual variant switch
- `/shadowui variant clear` — clear manual override

### Options panel (AceConfig)

- Active variant list/create/rename/delete
- Talent-tree binding per variant
- Current edit layer indicator
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
5. Buttons are flush full-size squares; minimap is large/square/black; chat is semi-transparent black; micro+bags sit bottom-right
6. Cast bar shows thick gradient cast + GCD underlay above bars; Blizzard cast bar does not appear
7. Unrelated Blizzard UI (unit frames, etc.) is unmodified

## Open implementation notes (non-blocking)

- Exact Interface version number(s) to set in TOC against current Era/SoD build at implement time
- Grid cell size chosen to match full icon size (e.g. 36px) with zero gap
- Keybind apply must respect combat lockdown; queue and flush on `PLAYER_REGEN_ENABLED`
- LibActionButton Classic Era compatibility verified when vendoring the library version
