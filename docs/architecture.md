# ShadowUI Architecture

Classic Era / Season of Discovery addon. Replaces Blizzard action bars with custom LibActionButton bars, applies selective chrome skinning, and provides a fixed cast/GCD bar. Layout and keybinds inherit through **Base → Class → Variant**.

## Module layout

```text
ShadowUI/
  ShadowUI.toc
  libs/                         Ace3, LibStub, CallbackHandler, LibActionButton
  core/
    init.lua                    AceAddon bootstrap, lifecycle, slash commands
    db.lua                      AceDB account + character schema
    resolve.lua                 sparse merge and effective config resolution
    keybinds.lua                combat-safe keybind apply
  defaults/
    base.lua                    shared centered bar layout
    classes/*.lua               sparse class deltas (stance/aura/form/pet)
  bars/
    button.lua                  flush square LAB buttons
    bar.lua                     standard bar frames, drag in edit mode
    pet.lua                     pet action binding and token texture resolve
    special.lua                 stance, aura, form, possess, pet bars
    manager.lua                 apply resolved layout; hide Blizzard bars
  cast/
    castbar.lua                 fixed player cast/channel bar
    gcd.lua                     GCD sweep under cast bar
  skin/
    chrome.lua                  black bar backdrops + soft shadow
    chat.lua                    semi-transparent chat
    micro.lua                   dark micro menu + bag bar, bottom-right
    minimap.lua                 large square blackened minimap
  edit/
    mode.lua                    edit toggle, snap grid, persist drags
    layer.lua                   Base | Class | Variant save-target picker
  profile/
    variants.lua                named variants, talent bind, manual override
  options/
    config.lua                  AceConfig panel
```

## Load order

Defined in `ShadowUI.toc`:

1. `libs/embeds.xml` — vendored libraries
2. `core/` — init, db, resolve, keybinds
3. `defaults/` — base, then class files (WARRIOR … DRUID)
4. `bars/` — button, bar, pet, special, manager
5. `cast/` — castbar, gcd
6. `skin/` — chrome, chat, micro, minimap
7. `edit/` — mode, layer
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

**Edit-mode writes** (`WriteLayerDelta(layer, section, key, patch)`):

- `layer` defaults to `editLayer` on the character DB
- `base` → `db.base[section][key]`
- `class` → `db.classes[class].layout|keybinds[key]`
- `variant` → active variant (or `"Default"`) under `db.classes[class].variants`

`ApplyAll()` resolves config then calls `ApplyBars`, `ApplyKeybinds`, `ApplySkins`, and `ApplyCastBar`.

## Lifecycle

| Event | Action |
|-------|--------|
| `OnInitialize` | `SetupDB`, register `/shadowui` |
| `OnEnable` | register `PLAYER_ENTERING_WORLD`, `PLAYER_REGEN_ENABLED`, `PLAYER_TALENT_UPDATE`, `CHARACTER_POINTS_CHANGED` |
| First `PLAYER_ENTERING_WORLD` | `ApplyAll` once per session |
| `PLAYER_TALENT_UPDATE` / `CHARACTER_POINTS_CHANGED` | re-apply unless `variantManual` |
| `PLAYER_REGEN_ENABLED` | flush deferred `ApplyAll`, keybinds, special-bar refresh |

Event names vary by client flavour, so each registration is wrapped in `pcall`; an
unknown event is skipped instead of aborting `OnEnable`.

### Combat safety

`ApplyAll` creates frames, sets secure attributes, and hides protected Blizzard
frames, so it is deferred wholesale when `InCombatLockdown()` returns true. It sets
`pendingApplyAll` and `OnRegenEnabled` replays it. `ApplyBars`, `ApplySkins`, and
`ApplyCastBar` repeat the same guard so a direct call cannot mutate protected state
mid-combat. Keybinds queue in `_pendingKeybinds`; special-bar refreshes queue in
`pendingSpecialBarRefresh`. Both flush from `OnRegenEnabled`.

## Bar IDs

Standard: `bar1` … `bar10` (action slots 1–120). Base ships `bar1`, `bar2`, `bar3`, and
`bar6` as bottom rows plus `bar4` and `bar5` as vertical side columns; `bar7`–`bar10`
ship with `enabled = false` and parked positions so enabling one does not collide.
Every shipped rect stays within ±360 of screen centre (asserted by
`tests/layout_spec.lua`).

Special (class-gated in `bars/manager.lua`): `stance` (Warrior), `aura` (Paladin),
`form` (Druid, Rogue, Priest, Shaman), `pet` (Hunter, Warlock), `possess` (all).
The three shapeshift ids share one class gate because they all read
`GetShapeshiftFormInfo`; a bar with no available forms hides itself. Shipped positions
for special bars are sparse class deltas at `y = -84`, above the cast bar at `y = -120`.

## Known limitations

- **Action page paging is not implemented.** Bars are bound to fixed action slots via
  `SetState(0, "action", slot)`. There is no `RegisterStateDriver` on `actionpage`, so
  Blizzard bonus-bar and stance paging does not swap `bar1` contents. The
  `SecureHandlerStateTemplate` on bar frames is in place for this follow-up.
- **Possess needs in-game validation.** Possess buttons are driven by
  `/click PossessButtonN`. `PossessBarFrame` is therefore parked off-screen at alpha 0
  rather than hidden, because clicks against a hidden secure button do not fire.
  LibActionButton-1.0 has no possess (or pet) action type, so no library path exists.
- **Profile keybinds are account bindings only.** `ApplyKeybinds` calls `SetBinding`
  with the stored binding name. It does not call `SetOverrideBindingClick` against
  ShadowUI buttons, and LAB hotkey text is not populated from the profile.
- **Micro button anchors are not re-hooked.** Blizzard code that repositions micro or
  bag buttons after `ApplySkins` will win until the next apply.
- **Vendored libraries are not SHA-pinned.** `libs/` is copied in-tree with no upstream
  revision recorded, so library updates are manual and unverifiable.
- **Talent tab shape is inferred.** `TalentPointsFromTabInfo` takes the larger numeric
  value of the third and fifth returns of `GetTalentTabInfo` to read both the Classic
  Era and modernized signatures without branching on client build.

## Out of scope

Unit frames, nameplates, tooltips, bag interiors, objective tracker, and cast-bar configuration are not modified by ShadowUI.
