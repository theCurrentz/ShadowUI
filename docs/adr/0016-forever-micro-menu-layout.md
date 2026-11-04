# Forever Micro Cluster uses MicroMenu layout

Status: superseded by ADR 0017.

The Micro Cluster docks Blizzard `MicroMenu` with `OverrideMicroMenuPosition` and lets `GridLayoutFrame` place buttons. Buttons stay children of `MicroMenu` and keep `layoutIndex`. ShadowUI does not wrap MicroButtons in hosts and does not `SetPoint` each button.

Shop, Customer Support, Achievement, extra bag slots, and the keyring park off `MicroMenu` and drop `layoutIndex`. Hide on those buttons and Hide/SetPoint/SetClipsChildren on `MicroMenuContainer` stay off. A child `Show` would reveal the park and leave extras at their old MicroMenu points, so Skin drops those points, keeps the park hidden, and re-parks when Blizzard Shows or reparents an extra. Every `BagsBar` child except the backpack parks too, then `BagsBar` Hides so leftover slot chrome cannot sit left of the backpack. Tray art and `Flash` highlights strip from textures. Edit Mode `Selection` stays shown. `UpdateClampOffsets` subtracts `Selection:GetLeft()` from the system frame, and a hidden Selection makes that rect nil. `ResetMicroMenuPosition` restores the default Blizzard menu.

The Era model (per-button `SetParent` onto `MainMenuBarArtFrame`, native-size hosts, `MoveMicroButtons` undo) is retired.
