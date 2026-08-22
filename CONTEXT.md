# ShadowUI

Opinionated Classic Era and Season of Discovery UI. It replaces default action bars, applies one chrome treatment, and shows fixed combat meters. Layout and keybinds belong to the account and inherit Base → Class → Variant.

## Inheritance

**Layer**:
One of Base, Class, or Variant. Later layers win field by field. Edit mode writes to exactly one selected layer.
_Avoid_: profile, AceDB profile

**Base**:
The shared layer for every class.

**Class**:
A World of Warcraft class (`WARRIOR`, `MAGE`, and so on). The Class layer holds sparse deltas for that class only.
_Avoid_: Lua class, character, spec

**Variant**:
A named overlay on a Class (for example Arms). It may bind to a Talent Tree. It is not owned by one Character.
_Avoid_: profile, spec, spec profile, dual spec

**Account**:
The Battle.net account. Layout and Keybinds live here so same-class characters share them.

**Character**:
One toon. It stores the active Variant, whether that choice is a Manual Override, which Layer edit mode writes, and Action Slot hard lock.
_Avoid_: character layout, per-character profile

**Manual Override**:
A Character lock on the active Variant. Talent Tree auto-bind does not change the Variant until the override is cleared.

**Talent Tree**:
One of the three class talent tabs. A Variant may bind to the tab with the most points spent.
_Avoid_: spec, specialization, dual spec

**Effective Config**:
The merged Layout and Keybinds after all Layers apply.

## Layout and bars

**Layout**:
Positions, scale, grid, and enabled state of Bars, plus Player Frame and Target Frame positions, Cast Bar place and size, and Range Display place. Chrome, combat meters other than the Cast Bar and Range Display, Chat, and Details Windows are not Layout.

**Layout Harness**:
The HTML preview in `sim/`. It draws shipped Layout plus geometric Chrome. Widgets snap to a 12px grid that tiles 1920×1080. Action buttons are 32.4px (90% of 36). Dragging or resizing a Bar exports a patch for `defaults/`. Action Bars snap resize to 12-slot grids (columns 12, 6, 4, 3, 2, or 1). Dragging or resizing Chrome or combat meters, including Tracking, exports a patch for `sim/chrome.lua` only. The Cast Bar, GCD Sweep, and Swing Timer lock as one group: the spell icon overlays the left of the Cast Bar at the same height so the meter fill shows through, they sit flush with no gap, the GCD Sweep stays under the Cast Bar, and the Swing Timer stays under the GCD Sweep. GCD Sweep and Swing Timer share the Cast Bar width. The Shield Row stays on the Player Frame. Named saves stay in the browser. It is not the game client. Layout Edit Mode in the game moves Bars, the Player Frame, the Target Frame, the Cast Bar, and the Range Display. It does not move other Chrome, combat meters, Chat, Details Windows, or the Shield Row.

**Keybind**:
A keyboard or mouse key mapped to a ShadowUI action button. It uses the same Layer stack as Layout. The action fires on key down and on click down.
_Avoid_: binding set, SavedBindings (ShadowUI does not write the default bind file)

**Bar**:
A ShadowUI grid of action buttons. Standard bars bind to Action Slots. The first slot defaults to (bar index − 1) × 12 + 1. A Class layer may set `firstSlot` to show a different range. Special Bars bind to stance, aura, form, pet, or possess actions. Edit mode moves whole bars, not single buttons.
_Avoid_: calling the Cast Bar, GCD Sweep, Mana Ticker, Swing Timer, Range Display, Shield Row, or Tracking a Bar

**Action Slot**:
A numbered slot on the default 1–120 action grid. A standard Bar maps each button to a fixed slot. Stance paging does not swap those slots.

**Action Slot Lock**:
Buttons stay locked. A click uses the action. Shift-drag (the default pickup modifier) moves a spell or item to another Action Slot and does not use the action. Hard lock in `/shadowui` blocks that move too.

**Special Bar**:
A Bar gated by class or possess: stance, aura, form, pet, or possess.

## Combat meters

**Cast Bar**:
The player cast and channel meter. It is not a Bar. Layout Edit Mode can drag it and resize it. A spell icon overlays the left of the meter at the same height so the fill shows through. Channel spells such as Blizzard show interior ticks. The meter uses Outer Edge. It sits at the top of the combat meter group with the GCD Sweep and the Swing Timer. GCD Sweep and Swing Timer stay stacked under it and share the Cast Bar width.

**GCD Sweep**:
The skinny glossy global-cooldown countdown under the Cast Bar. It sits flush under the Cast Bar with no gap and spans the Cast Bar. It shows while a GCD is active, including on every player cast and channel. Layout Edit Mode previews it. Fill stays more transparent than the Cast Bar.

**Mana Ticker**:
The fixed five-second-rule and regen-tick meters under the player mana bar. Warriors do not have one.

**Swing Timer**:
The fixed player melee and ranged swing meters under the GCD Sweep. They sit flush with no gap. Main-hand is for melee classes. Off-hand is for dual-wield classes. Ranged is for Hunter Auto Shot and wand classes. A lane stays hidden until that swing is active. Layout Edit Mode previews all three lanes for every class. Fill stays more transparent than the Cast Bar. Each lane uses Outer Edge.

**Range Display**:
The target range meter. It sits near the unit-frame cluster. It is not a Bar. Layout Edit Mode can drag it.

**Shield Row**:
The colour-coded absorb icons locked 4px above the left of the player name. Each icon is an oval portrait crop of the spell art that fills with remaining absorb. It is not a Bar, not in Layout, and not draggable in Edit Mode.
_Avoid_: absorb bar, shield bar, WeakAura

## Chrome

**Chrome**:
The visual treatment of the UI: matte fill on ShadowUI Bars, Darken of Blizzard art, action-icon chrome, buffs, Chat, minimap, World Layer, Time, Stopwatch, Minimap Icons, Micro Cluster, Tracking, Details Windows, the Player Frame, and the Target Frame. Icon chrome is a 0.05 fill, a 2px inset, a 0.07 icon crop, and an Outer Edge. Spell and item buttons darken slightly on hover, darken more when pressed, and keep the GCD clock swipe. Cooldown Count shows remaining seconds on those buttons. ItemRack worn-item and menu buttons use the same icon chrome. Target auras show remaining time. The Target Frame shows Status Text on health and mana. A rare-elite target uses the Rare-Elite dragon. The Threat Bar sits flush on the Target Frame nameplate.
_Avoid_: theme, skin pack, user-selectable skin

**Darken**:
A 0.05 chrome lock on Blizzard unit-frame and window art, plus a 0.05 fill around action icons, buffs, and debuffs. The square minimap buffer uses the same 0.05 colour at 0.6 alpha. Portraits stay native. Debuff type colours stay native.
_Avoid_: Outer Edge, overlay filter

**Outer Edge**:
The Lorti black drop around a chrome host. It sits outside the fill. Action icons, buffs, debuffs, the square minimap, the Cast Bar, and Swing Timer lanes all use it.
_Avoid_: drop shadow, box-shadow, glow, Darken

**Zone Text**:
The location name on the square minimap. It sits on top of the map, in the Darken buffer, with a 4px gap from the top of the screen and a 3px gap above the map.
_Avoid_: compass, north tag, zone button art

**World Layer**:
The Classic realm shard shown by Nova World Buffs. ShadowUI parks NWB's `MinimapLayerFrame` on the bottom of the square minimap holder so the map mask does not clip it. It does not compute shards itself.
_Avoid_: Layer (that is Base / Class / Variant)

**Time**:
The clock square on the square minimap (`ShadowUIMinimapClock`). It shows realm time. Hover shows realm time and local time. A click opens the Stopwatch. GameTimeFrame (day/night) stays hidden.
_Avoid_: GameTimeFrame, TimeManagerClockButton

**Stopwatch**:
The timer that Time opens (`ShadowUIStopwatch`). Left click starts or pauses. Right click resets. A second click on Time hides it.

**Minimap Icon**:
A button on the square minimap edge. The player can drag it. Buttons that parent to `Minimap`, `MinimapCluster`, or `MinimapBackdrop` park here, including dungeon finder, ItemRack, and LibDBIcon. The ItemRack minimap button does not get a second Outer Edge.

**Micro Cluster**:
The micro-menu buttons plus the backpack in one row, flush to the bottom-right of the screen. Buttons keep native Blizzard size and art. Adjacent buttons have no gap. The row has no gap above the bottom of the screen. `/shadowui` can turn this off and keep the default Blizzard menu.

**Tracking**:
The Blizzard XP and reputation meters, parked at the top of the screen. Not a Bar.

**Chat**:
The General chat window. ShadowUI parks it and fills it black. It is not a Bar and is not in Layout.

**Details Window**:
A Details! damage chart or threat chart. ShadowUI parks those two charts when Details! is loaded. They are not Bars and are not in Layout.

**Player Frame**:
The Blizzard player unit frame. ShadowUI parks it and applies Darken. Layout Edit Mode can drag it. ParkFrame snaps Blizzard Edit Mode back to the Layout place. On 1.15.9 it uses SetPointBase because Edit Mode replaces SetPoint. ShadowUI does not replace it.

**Target Frame**:
The Blizzard target unit frame. ShadowUI parks it and applies Darken. Layout Edit Mode can drag it. ParkFrame snaps Blizzard Edit Mode back to the Layout place. On 1.15.9 it uses SetPointBase because Edit Mode replaces SetPoint. ShadowUI does not replace it. Status Text on health and mana follows the Blizzard Status Text option. A rare-elite target uses the Blizzard Rare-Elite dragon. The Threat Bar sits flush on the nameplate. Target auras show remaining time from UnitAura.

**Status Text**:
Health and mana numbers on a unit frame. Format comes from Blizzard Status Text (numeric, percent, both, or none). ShadowUI paints one centre caption on the Target Frame. Native LeftText, RightText, and TextString stay hidden.

**Threat Bar**:
The full-width threat meter flush on the Target Frame nameplate, with zero gap. Fill is the player threat percent from UnitDetailedThreatSituation (scaled percent, or raw if scaled is missing). Colour goes from desaturated grey at low threat, to orange at mid-high threat, to blood red at full threat. It shows in solo, party, and raid. 0% stays hidden. Native NumericalThreat stays hidden. Details! still parks the threat chart.
_Avoid_: threat pip, LibThreatClassic2, full-frame threat flash

**Threat Number**:
Remaining threat percent on the Threat Bar. Same hide rules as the Threat Bar.

**Aura Duration**:
Remaining time on a Target Frame or Focus Frame buff or debuff. ShadowUI paints a cooldown swipe and remaining seconds from UnitAura. Player BuffFrame keeps Blizzard duration text.
_Avoid_: LibClassicDurations

**Cooldown Count**:
Remaining cooldown seconds on a ShadowUI action button. Counts hide for cooldowns shorter than 2s so the GCD swipe has no number. Bags and other Blizzard cooldowns stay default.
_Avoid_: OmniCC as a second addon name in-game

## Edit

**Layout Edit Mode**:
The session where the player drags Bars, the Player Frame, the Target Frame, the Cast Bar, and the Range Display on a snap grid from screen bottom-left. Hold Shift while dragging to skip the snap grid. The Cast Bar also resizes. A HUD overlay paints each host in blue. The Cast overlay matches the Cast Bar. Layout Edit Mode previews the Cast Bar, the GCD Sweep, and all Swing Timer lanes. Magenta guides mark screen centre. Writes go only to the selected Layer. GCD Sweep, Mana Ticker, Swing Timer, Shield Row, Micro Cluster, Tracking, Chat, and Details Windows do not move on their own.
_Avoid_: Blizzard Edit Mode as the way to place ShadowUI hosts, moving other Chrome

**Keybind Edit Mode**:
The session where the player hovers a button and presses a key. Writes go only to the selected Layer. It does not write SavedBindings. Layout Edit Mode and Keybind Edit Mode cannot run at the same time.
_Avoid_: LibKeyBound SaveBindings, /kb as the primary command, binding set

**Edit Mode**:
Either Layout Edit Mode or Keybind Edit Mode. `/shadowui` and `/sui` open options. `/shadowui edit` toggles Layout Edit Mode. `/shadowui binds` toggles Keybind Edit Mode. `/sui` takes the same subcommands.
