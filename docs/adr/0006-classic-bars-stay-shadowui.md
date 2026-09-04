# Classic and TBC use ShadowUI action bars, not Blizzard hosts

Classic Era (interface 11509) and TBC Anniversary (interface 20506) ship `EditModeManagerFrame` extra bars. Sharing those `ActionButton*` / `MultiBar*` hosts with Layout and Blizzard Edit Mode caused SetPoint fights, slot-range mismatch with Class `firstSlot`, and duplicate chrome. That host experiment is reversed.

## Decision

Visible action bars are ShadowUI LibActionButton Bars. Hide Blizzard `ActionButton*` and `MultiBar*` frames. Park `MainMenuBar` on a hidden off-screen parent so `ActionBarController_UpdateAll` cannot `Show()` it back into the HUD. `/shadowui edit` moves only ShadowUI Bars.

Each standard Bar keeps one fixed Action Slot range. Do not page bar1 for Warrior stances, Druid forms, Rogue Stealth, or another class state.

Do not skin Blizzard action buttons as the live HUD. Do not write Blizzard Edit Mode `GetPoint` into Layer Layout.

Pet and possess stay LibActionButton Special Bars. `PetActionBarFrame` stays hidden. `PossessBarFrame` stays parked so `/click PossessButtonN` still resolves. The Stance Bar and Extra Action Button keep their own chrome rules. They are not Bars.

## Consequences

The shipped centre stack is ShadowUI Layout after `/reload`. Bar 1–10 expose their fixed slot ranges at the same time. A stance, form, or Stealth change does not replace bar1. Class `firstSlot` applies to every standard Bar. Blizzard Edit Mode may still move extra bars in the default UI; those frames stay hidden. Profile keys click `ShadowUIActionButtonN`. Gryphon art stays hidden.
