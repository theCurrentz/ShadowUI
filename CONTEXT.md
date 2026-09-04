# ShadowUI

Opinionated Classic Era and TBC UI. It replaces default action bars, applies one chrome treatment, and shows fixed combat meters. Layout, Keybinds, and the Action Deck inherit Base → Class → Variant → Character. Version selects Era or TBC.

## Inheritance

**Version**:
The client flavor: Era or TBC. Catalog, Spellbook, live WTF, and the in-game TOC follow Version. It sits outside the Layer stack.
_Avoid_: expansion, flavor, interface, mode, game version, patch, BCC

**Era**:
Classic Era (Vanilla 1.15). Interface 11509. Client folder `_classic_era_`.

**TBC**:
The Burning Crusade Classic Anniversary. Interface 20506. Client folder `_anniversary_`.
_Avoid_: BCC, Burning Crusade Classic as the short UI label

**Layer**:
One of Base, Class, Variant, or Character. Later layers win field by field. Edit mode writes to exactly one selected layer.
_Avoid_: profile, AceDB profile, Default as a Layer name

**Base**:
The shared layer for every class.

**Class**:
A World of Warcraft class (`WARRIOR`, `MAGE`, and so on). The Class layer holds sparse deltas for that class only.
_Avoid_: Lua class, character, spec

**Variant**:
A named overlay on a Class (for example Arms). It may bind to a Talent Tree. It is not owned by one Character.
_Avoid_: profile, spec, spec profile, dual spec

**Account**:
The Battle.net account. Base, Class, and Variant Layout, Keybinds, and Action Deck overlays live here so same-class characters share them.

**Character**:
One toon. It stores the active Variant, whether that choice is a Manual Override, which Layer edit mode writes, Action Slot hard lock, and sparse Character Layer deltas for Layout, Keybinds, and Action Deck.
_Avoid_: Bartender character profile, AceDB character profile as the only store

**Manual Override**:
A Character lock on the active Variant. Talent Tree auto-bind does not change the Variant until the override is cleared.

**Talent Tree**:
One of the three class talent tabs. A Variant may bind to the tab with the most points spent.
_Avoid_: spec, specialization, dual spec

**Effective Config**:
The merged Layout, Keybinds, and Action Deck after all Layers apply.

## Layout and bars

**Layout**:
Positions, scale, grid, and enabled state of Bars, plus Player Frame and Target Frame positions, Cast Bar place and size, Range Display place, and Stance Bar place. Chrome, combat meters other than the Cast Bar and Range Display, Chat, and Details Windows are not Layout.

**Keybind**:
A keyboard or mouse key mapped to a ShadowUI action button. It uses the same Layer stack as Layout and the Action Deck. The action fires on key down and on click down. Base ships the default physical keys (the current Warrior Action Bar map). Class, Variant, and Character layers may overlay those keys. Warrior Variants change the Action Deck but keep the Base physical keys.
_Avoid_: binding set, SavedBindings (ShadowUI does not write the default bind file)

**Bar**:
A ShadowUI grid of action buttons. Standard bars bind to Action Slots. The first slot defaults to (bar index − 1) × 12 + 1. A Class layer may show a different range. The Warrior main Bar follows Battle, Defensive, and Berserker stance pages while its physical keys stay fixed. The Druid main Bar follows Caster, Cat, Prowl, and Bear pages. The Rogue main Bar follows Open and Stealth pages. Special Bars bind to pet or possess actions. Edit mode moves whole bars, not single buttons. A resize grip changes columns and rows and does not change scale.
_Avoid_: calling the Cast Bar, GCD Sweep, Mana Ticker, Swing Timer, Range Display, Shield Row, or Tracking a Bar

**Action Slot**:
A numbered slot on the default 1–120 action grid. A standard Bar normally maps each button to one fixed slot. The Warrior main Bar selects Battle slots 73–84, Defensive slots 85–96, or Berserker slots 97–108. The Druid main Bar selects Caster 1–12, Cat 73–84, Prowl 85–96, or Bear 97–108. The Rogue main Bar selects Open 1–12 or Stealth 73–84.

**Action Deck**:
Macros and spells on Action Slots. It uses the same Layer stack as Layout and Keybinds. A macro must match its catalog name and body, not only its account-wide name. `/shadowui deck` validates the resolved loadout, deletes every General and character macro, recreates only the unique loadout macros on the General tab, then clears and replaces the Action Slots that the deck owns plus every slot in the selected loadout. Loadout Class still includes the active Variant, matching the Macro Cursor Action Bars. A missing Variant uses the first shipped Variant so apply cannot write the class skeleton (Bloodrage on 5, extra Taunts). Later-layer `false` tombstones a slot. Apply honors those tombstones so empty slots stay empty after reload. It does not change Keybinds or Layout. `/shadowui` Loadout chooses Class, Variant, or Character. Classic Era picks up abilities by spell name. Warrior ships an Action Deck. Other classes may overlay one. Macro Cursor and ShadowUI share the live overlay.
_Avoid_: Bartender profile import, injecting macros on login, Decks as a Keybind Layer

**Action Slot Lock**:
Buttons stay locked. A click uses the action. Shift-drag (the default pickup modifier) moves a spell or item to another Action Slot and does not use the action. Shift+Alt (Option on Mac) drag inserts the action and Keybind; the drop row shifts right; overflow from the end of that row stays on the cursor. Hard lock in `/shadowui` blocks those moves too.

**Shift and Prune**:
An edit that packs Keybinds left and drops gaps with no Keybind. Actions on those Keybinds move with them. The pack wraps to the next row of a Bar and continues onto the next Bar. Writes go to the selected Layer. `/shadowui prune` and the options button run it. Out of combat only.

**Macro Library**:
The shared catalog of macros. Applying an Action Deck loads only its referenced catalog records into the General tab and leaves the character tab empty. Delete in Macro Cursor removes the catalog record and its live cache copy. A macro removed in the game is unloaded only; the catalog record stays.
_Avoid_: overlay store, browser persist, IndexedDB

**Special Bar**:
A Bar gated by class or possess in play: pet or possess. Layout Edit Mode previews every Special Bar for every class.

**Stance Bar**:
The Blizzard shapeshift bar (`StanceBarFrame` / `ShapeshiftBarFrame`). It shows Warrior stances, Paladin auras, Druid forms, Rogue Stealth, Priest Shadowform, and Shaman Ghost Wolf. ShadowUI does not replace it. HideBlizzardBars reparents it to UIParent and ParkFrame parks it from Layout so parked MainMenuBar cannot drag it off-screen. Layout Edit Mode can drag it. Shown buttons use the same icon chrome and Outer Edge as Action Slots. Unused slots stay empty. It is not a Bar and not a Special Bar.
_Avoid_: aura bar, form bar as separate ShadowUI Bars

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
The target range meter. It sits flush on the top of the combat meter group and shares the Cast Bar centre. It is not a Bar. Layout Edit Mode can drag it.

**Shield Row**:
The colour-coded absorb icons locked 4px above the left of the player name. Each icon is an oval portrait crop of the spell art that fills with remaining absorb. It is not a Bar, not in Layout, and not draggable in Edit Mode.
_Avoid_: absorb bar, shield bar, WeakAura

## Chrome

**Chrome**:
The visual treatment of the UI: Darken of Blizzard art, Meter Fill, action-icon chrome, Stance Bar buttons, buffs, Chat, minimap, World Layer, Time, Stopwatch, Minimap Icons, Micro Cluster, Tracking, Details Windows, the Player Frame, and the Target Frame. Icon chrome is a 0.05 fill, a 2px inset, a 0.07 icon crop, and an Outer Edge. An Action Slot with no spell, macro, or item stays hidden, including its Keybind label: no Darken fill and no Outer Edge. Keybind Edit Mode still shows empty Action Slots. A Shift-drag pickup (ACTIONBAR_SHOWGRID) shows every standard Bar, including a Bar that is off, and paints every empty Action Slot with Darken and Outer Edge so it is a drop target. The Keybind label on those empty slots is shown too. Special Bars that are off stay hidden. After the pickup ends, empty Action Slots and disabled Bars hide again. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place. ShadowUI skins their icons and does not park or snap them. Spell and item buttons darken slightly on hover, darken more when pressed, and keep the GCD clock swipe. Cooldown Count shows remaining seconds on those buttons. ItemRack worn-item and menu buttons use the same icon chrome. Target auras sit 2px to the right of the Target Frame in horizontal rows at 32px so Aura Duration numbers fit, and show remaining time. Target of Target auras sit 2px to the right of Target of Target in a horizontal row. The Target Frame keeps Blizzard Status Text. A rare-elite target uses the Rare-Elite dragon. The Threat Bar is a bubble tab on the 45-degree edge of the Target Frame portrait. A Portrait Ring outlines that portrait in the target's class colour. Aggro Glow sits around the Target Frame: orange at high threat, blood red while the target attacks the player.
_Avoid_: theme, skin pack, user-selectable skin

**Darken**:
A 0.05 chrome lock on Blizzard unit-frame and window art, plus a 0.05 fill around action icons that have a spell or item, buffs, and debuffs. The square minimap buffer uses the same 0.05 colour at 0.6 alpha. Portraits stay native. Debuff type colours stay native.
_Avoid_: Outer Edge, overlay filter

**Meter Fill**:
A horizontal lighting overlay of the live bar colour on Blizzard health and power bars (mana, rage, energy, and the rest) and on Name Background. The overlay sits on the native fill so StatusBar vertex colour cannot flatten it. Unit frames and nameplates keep Blizzard layout. Cast Bar, GCD Sweep, Swing Timer, and Threat Bar keep their own palettes.
_Avoid_: class-coloured health, replacing unit frames or nameplates

**Name Background**:
The strip behind the Target Frame and Focus Frame name (`TargetFrameNameBackground`). A player unit uses that unit's class colour (same source as Portrait Ring). A non-player unit keeps reaction colour: hostile red, friendly blue, neutral yellow. Meter Fill paints it. It is not a nameplate.
_Avoid_: nameplate name-bar, nameplate tab

**Outer Edge**:
The Lorti black drop around a chrome host. It sits outside the fill. Action icons, Stance Bar buttons, buffs, debuffs, the square minimap, the Cast Bar, and Swing Timer lanes all use it. The Threat Bar does not: Outer Edge is square.
_Avoid_: drop shadow, box-shadow, glow, Darken

**Zone Text**:
The location name on the square minimap. It sits on top of the map, in the Darken buffer, with a 4px gap from the top of the screen and a 3px gap above the map.
_Avoid_: compass, north tag, zone button art

**World Layer**:
The Classic realm shard shown by Nova World Buffs. ShadowUI parks NWB's `MinimapLayerFrame` on the bottom of the square minimap holder so the map mask does not clip it. It does not compute shards itself.
_Avoid_: Layer (that is Base / Class / Variant)

**Time**:
The Blizzard clock on the square minimap (`TimeManagerClockButton`). ShadowUI restyles it the SexyMap way: hide the clock border, size the chip to the ticker, and park it under the map. It shows realm time. Hover shows realm time and local time. A click opens the Stopwatch. GameTimeFrame (day/night) stays hidden.
_Avoid_: ShadowUIMinimapClock, clock square, GameTimeFrame

**Stopwatch**:
The Blizzard timer that Time opens (`StopwatchFrame`). ShadowUI Darkens it. It does not replace StopwatchFrame.
_Avoid_: ShadowUIStopwatch

**Minimap Zoom**:
The mouse wheel zooms the square minimap. After 5 seconds the map zooms out. Zoom buttons stay hidden.

**Minimap Icon**:
A button on the square minimap edge. The player can drag it. Buttons sit on SexyMap's square path, 10px outside the map so the mask does not clip them. Buttons that parent to `Minimap`, `MinimapCluster`, or `MinimapBackdrop` park here, including dungeon finder, ItemRack, and LibDBIcon. The ItemRack minimap button does not get a second Outer Edge.

**Micro Cluster**:
The micro-menu buttons plus the backpack in one row, flush to the bottom-right of the screen. Buttons keep native Blizzard size and art. Adjacent buttons have no gap. The row has no gap above the bottom of the screen. Classic Era hides Dungeon Journal and Collections when those windows do not exist. `/shadowui` can turn this off and keep the default Blizzard menu.

**Tracking**:
The Blizzard XP and reputation meters, parked at the top of the screen. Not a Bar.

**Chat**:
The General chat window. ShadowUI parks its place and fills it black. Size stays with Blizzard Chat and Blizzard Edit Mode. ShadowUI does not set or snap Chat size. It is not a Bar and is not in Layout.

**Details Window**:
A Details! damage chart or threat chart. ShadowUI parks those two charts when Details! is loaded. They are not Bars and are not in Layout.

**Player Frame**:
The Blizzard player unit frame. ShadowUI parks it and applies Darken and Meter Fill. Layout Edit Mode can drag it. ParkFrame snaps Blizzard Edit Mode back to the Layout place. On 1.15.9 it uses SetPointBase because Edit Mode replaces SetPoint. ShadowUI does not replace it.

**Target Frame**:
The Blizzard target unit frame. ShadowUI parks it and applies Darken and Meter Fill. Layout Edit Mode can drag it. ParkFrame snaps Blizzard Edit Mode back to the Layout place. On 1.15.9 it uses SetPointBase because Edit Mode replaces SetPoint. ShadowUI does not replace it. Status Text on health and mana stays native Blizzard. A rare-elite target uses the Blizzard Rare-Elite dragon. Target of Target stays on the Blizzard default (`BOTTOMRIGHT`, −35, −10). The Blizzard target spell bar sits 2px above Name Background at mana width. Spell name sits on the left. Remaining / duration sits on the right. The Threat Bar is a bubble tab on the 45-degree edge of the circular portrait. A Portrait Ring outlines that portrait in the target's class colour. A non-player portrait stays full original. Aggro Glow sits around the frame: orange at high threat, blood red while the target attacks the player. Target auras sit 2px to the right of the Target Frame in horizontal rows at 32px so Aura Duration numbers fit, and show remaining time from UnitAura. Target of Target auras sit 2px to the right of Target of Target in a horizontal row. The Blizzard bar well (`TargetFrameBackground`) stays hidden so it cannot cover the top half of an empty health slot. Name Background uses Meter Fill. A player target uses class colour.

**Status Text**:
Health and mana numbers on a unit frame. Format comes from Blizzard Status Text (numeric, percent, both, or none). ShadowUI does not paint a caption on the Target Frame. Native LeftText, RightText, and TextString stay.

**Threat Bar**:
A round bubble tab on the 45-degree (top-right) edge of the Target Frame circular portrait. It sits over that portrait rim. Fill is one circle with a vertical lighting gradient of the player threat percent from UnitDetailedThreatSituation (scaled percent, or raw if scaled is missing). Fill sits at 50% opacity so the portrait shows through. The Darken stroke stays opaque. Percent can exceed 100. Below 70% the bubble is dark glass. 70–88% is yellow to orange. 88–99% is orange to deep orange. 100% and above is red to deep red. A thick circular Darken stroke matches Target Frame chrome. Nested discs, offset drops, and Outer Edge stay hidden. Threat Number stays centred, one outlined line at size 9. It shows in solo, party, and raid. 0% stays hidden. Native NumericalThreat stays hidden. Details! still parks the threat chart.
_Avoid_: threat pip, LibThreatClassic2, full-frame threat flash, status bar, nameplate tab

**Threat Number**:
Remaining threat percent on the Threat Bar. Same hide rules as the Threat Bar. Size 9, outlined.

**Aggro Glow**:
A subtle halo around the Target Frame chrome silhouette (name, meters, and circular portrait), not the rectangular bounding box. It uses the Blizzard targeting-frame flash art as a static ADD overlay, recoloured, and matches the native flash place when that texture exists. Blood red while the target attacks the player (`UnitDetailedThreatSituation` isTanking). Orange at mid-high threat without aggro (70% and above, same step as the Threat Bar). Elite / rare / rare-elite / worldboss use the elite flash slice. It hides below mid-high threat when the player does not have aggro. Focus Frame does not get it. Native TargetFrameFlash stays hidden.
_Avoid_: rectangular bounding-box glow, pulsing Blizzard TargetFrameFlash

**Portrait Ring**:
A subtle class-coloured outline on the circular portrait of the Target Frame and the Focus Frame. Colour comes from RAID_CLASS_COLORS when present, else the Classic class colours (Warrior brown, Mage blue, Rogue yellow, and the rest of the roster). The ring sits behind the portrait, 2px larger, so only a thin rim shows inside the circular chrome. Fill is one vertical lighting gradient from a darker, more transparent hue to a brighter inner rim. The ring is only for player units. A non-player portrait stays full original: no ring, no gradient, and no wash. The Player Frame portrait stays native.
_Avoid_: portrait tint, nameplate class color, Player Frame ring

**Nameplate**:
A Blizzard world unit nameplate. ShadowUI paints Meter Fill on its health and power bars. Layout, name text, and nameplate cast bars stay default.
_Avoid_: Plater, nameplate replacement, Name Background

**Aura Duration**:
Remaining time on a Target Frame or Focus Frame buff or debuff. ShadowUI paints a cooldown swipe and remaining seconds from UnitAura. Native Duration text stays hidden. Player BuffFrame keeps Blizzard duration text.
_Avoid_: LibClassicDurations

**Cooldown Count**:
Remaining cooldown seconds on a ShadowUI action button. Counts hide for cooldowns shorter than 2s so the GCD swipe has no number. Bags and other Blizzard cooldowns stay default.
_Avoid_: OmniCC as a second addon name in-game

**Bags**:
Parked combined inventory and bank (`skin/bags.lua`, `skin/rainbow.lua`). The files stay in the tree. The TOC does not load them. Blizzard bag and bank windows stay. Darken still tints those Blizzard windows.
_Avoid_: Bagnon, Combuctor, AdiBags, bag-slot icons on the Micro Cluster, shipping ShadowUIInventory in play

**Rainbow Organizer**:
Parked category groups for Bags: hearthstone, mounts, profession fixtures, gear, consumables, profession materials, quest, other, junk, then empty slots. Each filled group would get a coloured glow in addition to item quality chrome. Groups sit on new rows with extra padding. Groups are not bags. Not in play until Bags load again.
_Avoid_: bag break, replacing quality glow

## Edit

**Layout Edit Mode**:
The session where the player drags Bars, the Player Frame, the Target Frame, the Cast Bar, the Range Display, and the Stance Bar on a snap grid from screen bottom-left. Hold Shift while dragging to skip the snap grid. Persist writes the nearest UIParent point (`BOTTOM`, `BOTTOMRIGHT`, `CENTER`, and the rest) so the host keeps that screen edge when the resolution changes. Magenta guides mark true screen centre. A host snaps to that centre when it is within one 32.4 cell. Player Frame, Target Frame, and Range Display snap and paint the HUD overlay on the visible chrome, not the empty hit-box pad. Range numbers stay geometrically centred in the host so the midline is exact. While a host is dragged or resized, a HUD chip shows the Layout point, x/y, and frame size. Every Bar has a resize grip. Resize changes columns and rows so the slot count still fills the grid. Scale does not change. Action Bars snap to 12, 6, 4, 3, 2, or 1 columns. Other Bars snap to grids that fill their slot count. The Cast Bar also resizes. A HUD overlay paints each host in blue. The Cast overlay matches the Cast Bar. Layout Edit Mode previews the Cast Bar, the GCD Sweep, all Swing Timer lanes, and every Special Bar for every class. Magenta guides mark screen centre. Writes go only to the selected Layer. GCD Sweep, Mana Ticker, Swing Timer, Shield Row, Micro Cluster, Tracking, Chat, and Details Windows do not move on their own.
_Avoid_: Blizzard Edit Mode as the way to place ShadowUI hosts, moving other Chrome

**Keybind Edit Mode**:
The session where the player hovers a button and presses a key. Writes go only to the selected Layer. It does not write SavedBindings. Layout Edit Mode and Keybind Edit Mode cannot run at the same time.
_Avoid_: LibKeyBound SaveBindings, /kb as the primary command, binding set

**Edit Mode**:
Either Layout Edit Mode or Keybind Edit Mode. `/shadowui` and `/sui` open options. `/shadowui edit` toggles Layout Edit Mode. `/shadowui binds` toggles Keybind Edit Mode. `/shadowui deck` places the Action Deck. `/shadowui prune` packs Keybinds left. `/sui` takes the same subcommands.
