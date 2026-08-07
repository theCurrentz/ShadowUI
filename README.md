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

## Testing checklist

Manual in-game verification (Classic Era or SoD):

- [ ] **Fresh character** — centered bars, skins applied, cast bar visible, no setup prompts
- [ ] **Edit layer Variant** — drag a bar; only that class variant changes; same-class alt sees it
- [ ] **Edit layer Base** — drag a bar; all classes inherit the change
- [ ] **Talent auto-bind** — talent change selects the bound variant unless manually overridden (`/shadowui variant clear` restores auto)
- [ ] **Chrome** — flush square buttons; large square minimap; semi-transparent chat; micro menu + bags bottom-right
- [ ] **Cast + GCD** — custom cast bar and GCD underlay visible; Blizzard cast bar hidden
- [ ] **Unchanged UI** — unit frames and other unrelated Blizzard UI untouched
