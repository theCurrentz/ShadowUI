# ShadowUI

ShadowUI is an opinionated World of Warcraft UI addon for action bars, interface chrome, and cast bars. It supports Classic Era and Season of Discovery only.

## Installation

Copy the addon directory to `Interface/AddOns/ShadowUI`, then enable ShadowUI from the character selection screen.

## Configuration

- `/shadowui` opens the options.
- `/shadowui edit` toggles edit mode.
- `/shadowui layer base|class|variant` sets the layer changed by edit mode.
- `/shadowui variant <name>` manually activates a variant.
- `/shadowui variant clear` clears the manual variant override.

## Layout inheritance

Every layout resolves through Base → Class → Variant. Base provides shared defaults, Class applies class-specific settings, and the active Variant applies the final situational overrides.

See [docs/architecture.md](docs/architecture.md) for module layout, SavedVariables schema, and resolve rules.

## Options

Open with `/shadowui`. The panel supports variant create/rename/delete, talent-tree binding, edit-layer selection, reset of the selected layer, and full account profile reset.

## Testing

Automated checks (plain Lua, no client needed):

```bash
lua tests/resolve_spec.lua
lua tests/layout_spec.lua
lua tests/api_shapes_spec.lua
```

`resolve_spec` covers layer merging, layer writes, and talent-tab parsing for both the
Classic Era and modernized `GetTalentTabInfo` signatures. `layout_spec` asserts every
shipped bar stays within ±360 of screen centre and never overlaps another bar or the
cast bar. `api_shapes_spec` covers the `SetGradient` path with its solid-colour
fallback and pet action returns with and without token textures.

Manual in-game verification (Classic Era or SoD):

- [ ] **Fresh character** — centered bars, skins applied, cast bar visible, no setup prompts
- [ ] **On-screen layout** — six bars visible (four bottom rows, two side columns); nothing clipped off screen
- [ ] **Edit layer Variant** — drag a bar; only that class variant changes; same-class alt sees it
- [ ] **Edit layer Base** — drag a bar; all classes inherit the change
- [ ] **Layer picker** — BASE / CLASS / VARIANT buttons render their labels and highlight the active layer
- [ ] **Talent auto-bind** — talent change selects the bound variant unless manually overridden (`/shadowui variant clear` restores auto)
- [ ] **Stance / form bar** — active stance, form, aura, or Stealth shows a lit checked overlay (Warrior, Druid, Paladin, Rogue, Priest, Shaman)
- [ ] **Pet bar** — token actions (Attack, Follow, stances) show icons rather than blanks
- [ ] **Combat deferral** — enter combat, run `/shadowui variant <name>`; no taint error, layout applies when combat drops
- [ ] **Chrome** — flush square buttons; large square minimap; semi-transparent chat; micro menu + bags bottom-right
- [ ] **Cast + GCD** — custom cast bar and GCD underlay visible with gradient fill; Blizzard cast bar hidden
- [ ] **Possess** — mind-control a target and confirm the possess bar drives the vehicle actions
- [ ] **Unchanged UI** — unit frames and other unrelated Blizzard UI untouched

## Known limitations

- Action page paging is not implemented; bars hold fixed action slots and do not swap on bonus bars or stances.
- Possess relies on `/click PossessButtonN` and needs in-game validation; LibActionButton has no possess action type.
- Profile keybinds use `SetBinding` only. ShadowUI does not yet call `SetOverrideBindingClick` against its own buttons, and LAB hotkey text is not driven from the profile.
- Micro and bag button anchors are set once per apply and are not re-hooked if Blizzard moves them.
- Vendored libraries in `libs/` are not pinned to upstream revisions.

See [Known limitations](docs/architecture.md#known-limitations) for detail.
