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
