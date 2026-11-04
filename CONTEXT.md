# ShadowUI

Opinionated WoW Forever UI. It skins Blizzard action bars and applies one chrome treatment. Layout, Keybinds, and the Action Deck live on one Account Profile.

## Inheritance

**Version**:
Forever. Catalog, Spellbook, live WTF, and the in-game TOC follow this client.
_Avoid_: Era, TBC, expansion, flavor, interface, mode, game version, patch, BCC

**Forever**:
WoW Forever (Camelot). Game 1.60.1. Interface 16001. Client folder `_forever_`. It loads `ShadowUI.toc`, `ShadowUI_Forever.toc`, and `ShadowUI_Camelot.toc`. Live action buttons are Blizzard ActionButtons with ShadowUI Chrome (a Darken rim and an Outer Edge). Button place stays with the Blizzard bar. ShadowUI does not create LibActionButton Bars.

**Profile**:
The Account store of Layout, Keybinds, and the Action Deck. Every Character uses this one store. Edit Mode writes to it.
_Avoid_: AceDB profile, Layer, Variant, Bartender profile, named Profile, Default Profile

**Class**:
A World of Warcraft class (`WARRIOR`, `MAGE`, and so on).
_Avoid_: Lua class, spec, Layer named Class

**Account**:
The Battle.net account. The Profile lives here so every Character uses the same store.

**Character**:
One toon. It stores Action Slot hard lock and chrome prefs. It does not store Layout overlays.
_Avoid_: Bartender character profile, AceDB character profile as the only store

**Effective Config**:
The merged Layout, Keybinds, and Action Deck after shipped Class defaults and the Profile apply.

## Layout and bars

**Layout**:
Positions, scale, grid, and enabled state of Bars, plus Stance Bar place. Chrome, Chat, Details Windows, and Blizzard Player Frame and Target Frame are not Layout.

**Keybind**:
A keyboard or mouse key mapped to a ShadowUI action button. It lives on the same Profile as Layout and the Action Deck. The action fires on key down and on click down. Shipped Class defaults include the physical keys (the current Warrior Action Bar map). The Profile may overlay those keys.
_Avoid_: binding set, SavedBindings (ShadowUI does not write the default bind file)

**Bar**:
A Blizzard action-button row that ShadowUI skins in place. Chrome is a Darken rim and an Outer Edge. The icon and every Blizzard effect stay native. Button place stays with the Blizzard bar. ShadowUI does not create LibActionButton hosts.
_Avoid_: calling Tracking a Bar

**Action Slot**:
A numbered slot on the default 1–120 action grid. A standard Bar normally maps each button to one fixed slot. The Warrior main Bar selects Battle slots 73–84, Defensive slots 85–96, or Berserker slots 97–108. The Druid main Bar selects Caster 1–12, Cat 73–84, Prowl 85–96, or Bear 97–108. The Rogue main Bar selects Open 1–12 or Stealth 73–84.

**Action Deck**:
Macros and spells on Action Slots. It lives on the same Profile as Layout and Keybinds. Macro Cursor writes that overlay. ShadowUI does not place Action Slots in-game. Profile `false` tombstones a slot. Warrior ships an Action Deck. Other classes may overlay one.
_Avoid_: Bartender profile import, injecting macros on login, Decks as a Keybind Layer, `/shadowui deck`

**Action Slot Lock**:
Buttons stay locked. A click uses the action. Shift-drag (the default pickup modifier) moves a spell or item to another Action Slot and does not use the action. Shift+Alt (Option on Mac) drag inserts the action and Keybind; the drop row shifts right; overflow from the end of that row stays on the cursor. Hard lock in `/shadowui` blocks those moves too.

**Shift and Prune**:
An edit that packs Keybinds left and drops gaps with no Keybind. It does not read Action Slots. The pack wraps to the next row of a Bar and continues onto the next Bar. Writes go to the Profile. `/shadowui prune` runs it. Out of combat only.

**Macro Library**:
The shared catalog of macros. Applying an Action Deck loads only its referenced catalog records into the General tab and leaves the character tab empty. Delete in Macro Cursor removes the catalog record and its live cache copy. A macro removed in the game is unloaded only; the catalog record stays.
_Avoid_: overlay store, browser persist, IndexedDB

**Special Bar**:
A Bar gated by class or possess in play: pet or possess. Layout Edit Mode previews every Special Bar for every class.

**Stance Bar**:
The Blizzard shapeshift bar (`StanceBarFrame` / `ShapeshiftBarFrame`). It shows Warrior stances, Paladin auras, Druid forms, Rogue Stealth, Priest Shadowform, and Shaman Ghost Wolf. ShadowUI does not replace it. ParkBlizzardStanceBar does not reparent it. Layout Edit Mode can drag it. Shown buttons use the same icon chrome and Outer Edge as Action Slots. Unused slots stay empty. It is not a Bar and not a Special Bar.
_Avoid_: aura bar, form bar as separate ShadowUI Bars

## Combat meters

Forever shares the Midnight secret-value API. ShadowUI does not scan auras, the combat log, threat percent, or target range. ShadowUI does not replace `ActionButton_UpdateCooldown`. Blizzard's own cooldown update runs untainted, so `SetCooldown` accepts the secret start and duration.

## Chrome

**Chrome**:
The visual treatment of the UI: Darken of Blizzard art, action-icon chrome, Stance Bar buttons, buffs, Chat, minimap, World Layer, Time, Stopwatch, Minimap Icons, the Micro Bar, the Bag Bar, Tracking, the Experience bar, Details Windows, and the `/shadowui` options pane. Action-icon chrome blackens the Blizzard slot rim with Darken and adds an Outer Edge. The icon, its Blizzard mask, and every Blizzard effect stay native, with no zoom. Player buff and debuff icons use a 0.07 zoom. They do not show a border, a Darken ring, or an Outer Edge. `/shadowui` can turn the square minimap off and keep the default Blizzard map. An Action Slot with no spell, macro, or item stays hidden, including its Keybind label and Outer Edge. Forever does not call HasAction on a Blizzard ActionButton; it follows that host's show state, so Edit Mode "not always visible" drops Outer Edge on empty slots. Chrome does not write keys on a Blizzard ActionButton. That taint would stop a pickup from showing empty slots, and a drop would click through to the world. Keybind Edit Mode still shows empty Action Slots. The hover binder shows the Keybind. Slot Keybind labels stay hidden in that session unless an Action Slot pickup is active. A Shift-drag pickup (ACTIONBAR_SHOWGRID) or a spell, item, or macro on the cursor shows every standard Bar, including a Bar that is off, paints every empty Action Slot with Darken and Outer Edge so it is a drop target, and shows every Keybind. Merchant and money on the cursor do not. Special Bars that are off stay hidden. After the pickup ends, empty Action Slots and disabled Bars hide again. Player BuffFrame and DebuffFrame keep Blizzard Edit Mode place. ShadowUI skins their icons and does not park or snap them. Target Frame, Target of Target, Focus, and party auras stay Blizzard. Action Slots keep the Blizzard hover, pressed, checked, proc, cast, and cooldown feedback. ItemRack worn-item and menu buttons use a 0.05 fill, a 2px inset, a 0.07 icon crop, and an Outer Edge. The Target Frame keeps Blizzard Status Text. Target Frame Art uses a 0.14 Darken so original chrome and elite, rare, rare-elite, and worldboss dragons still show.
_Avoid_: theme, skin pack, user-selectable skin

**Darken**:
A chrome lock on Blizzard unit-frame and window art and on the Blizzard action-slot rim. Character `darkness` (default 1) scales the lock. At darkness 1 the rim is 0.05, empty Action Slot art is 0.2 so a drop target still shows, Target Frame Art is 0.14 so original chrome and dragon art still show, and window art is 0.35. The square minimap fade uses the same rim colour at 0.6 alpha in place of the compass ring. The `/shadowui` options pane uses that fill instead of DialogBox parchment. Unit-frame borders keep their outer shadow. Bar wells do not. Portraits stay native. Debuff type colours stay native.
_Avoid_: Outer Edge, overlay filter

**Outer Edge**:
The Lorti black drop around a chrome host. It sits outside the rim or fill. Action icons, Stance Bar buttons, the square minimap, and the Experience bar use it. Backdrop repeat math skips a secret width, which loot can report on that frame.
_Avoid_: drop shadow, box-shadow, glow, Darken

**Zone Text**:
The location name on the Forever minimap cluster header. ShadowUI does not move it.
_Avoid_: compass, north tag, relocating Zone Text onto a custom holder

**World Layer**:
The Classic realm shard shown by Nova World Buffs. ShadowUI parks NWB's `MinimapLayerFrame` on the bottom of the square minimap holder so the map mask does not clip it. It does not compute shards itself.
_Avoid_: Layer (that is a Profile)

**Time**:
The Blizzard clock on the Forever minimap cluster header (`TimeManagerClockButton`). It stays where Blizzard put it. Hover shows realm time and local time. A click opens the Stopwatch. GameTimeFrame is the calendar and stays on the header.
_Avoid_: ShadowUIMinimapClock, clock square, parking Time under the map, hiding GameTimeFrame

**Stopwatch**:
The Blizzard timer that Time opens (`StopwatchFrame`). ShadowUI Darkens it. It does not replace StopwatchFrame.
_Avoid_: ShadowUIStopwatch

**Minimap Zoom**:
The mouse wheel zooms the square minimap. After 5 seconds the map zooms out. Forever hover zoom buttons stay. Left-click pings the full square face. Forever `DielFrame` (day/night dial) stays hidden on the square map so it does not block pings.

**Minimap Icon**:
A button on the square minimap edge. The player can drag it. Buttons sit on SexyMap's square path, 10px outside the map so the mask does not clip them. Map-edge buttons that parent to `Minimap`, `MinimapContainer`, or `MinimapBackdrop` park here, including dungeon finder, ItemRack, and LibDBIcon. Cluster header widgets stay: Zone Text, Time, calendar, mail, and tracking. The ItemRack minimap button does not get a second Outer Edge. ItemRack's set menu stays on UIParent so the square map does not clip it.

**Micro Bar**:
The Blizzard micro menu. Place, buttons, tray art, and Flash stay with Blizzard. Shop, Customer Support, Achievement, Professions, and Legacy stay where Blizzard put them. ShadowUI adds an Outer Edge on the bar border. `/shadowui` can turn that shadow off.
_Avoid_: Micro Cluster, docking the menu, icons-only tray

**Bag Bar**:
The Blizzard bag bar, including the backpack and extra bag slots. Place and art stay with Blizzard. ShadowUI adds an Outer Edge on the bar border. `/shadowui` can turn that shadow off.
_Avoid_: parking extra bag slots, hiding BagsBar, one backpack button

**Tracking**:
The Blizzard reputation meter, parked at the top of the screen. The Experience bar stays with Blizzard in place. The fill, notches, Status Text, and rested XP stay Blizzard. ShadowUI gives that bar an Outer Edge. Not a Bar.

**Chat**:
The General chat window. ShadowUI parks its place and fills it black. Size stays with Blizzard Chat and Blizzard Edit Mode. ShadowUI does not set or snap Chat size. It is not a Bar and is not in Layout.

**Details Window**:
A Details! damage chart or threat chart. ShadowUI parks those two charts when Details! is loaded. They are not Bars and are not in Layout.

**Nameplate**:
A Blizzard world unit nameplate. Layout, name text, health, and nameplate cast bars stay default.
_Avoid_: Plater, nameplate replacement

**Bags**:
Parked combined inventory and bank (`skin/bags.lua`, `skin/rainbow.lua`). The files stay in the tree. The TOC does not load them. Blizzard bag and bank windows stay. Darken still tints those Blizzard windows.
_Avoid_: Bagnon, Combuctor, AdiBags, replacing the Bag Bar, shipping ShadowUIInventory in play

**Rainbow Organizer**:
Parked category groups for Bags: hearthstone, mounts, profession fixtures, gear, consumables, profession materials, quest, other, junk, then empty slots. Each filled group would get a coloured glow in addition to item quality chrome. Groups sit on new rows with extra padding. Groups are not bags. Not in play until Bags load again.
_Avoid_: bag break, replacing quality glow

## Edit

**Layout Edit Mode**:
The session where the player drags Bars and the Stance Bar on a snap grid from screen bottom-left. Hold Shift while dragging to skip the snap grid. Persist writes the nearest UIParent point (`BOTTOM`, `BOTTOMRIGHT`, `CENTER`, and the rest) so the host keeps that screen edge when the resolution changes. Magenta guides mark the snap-grid line nearest true screen centre. A host snaps to that midline when it is within one 16.2 cell. While a host is selected, dragged, or resized, a HUD chip follows the pointer and shows the Layout point, x/y, and frame size. The chip sits above the Edit Mode HUD. Every Bar has a resize grip. Resize changes columns and rows so the slot count still fills the grid. Scale does not change. Action Bars snap to 12, 6, 4, 3, 2, or 1 columns. Other Bars snap to grids that fill their slot count. A HUD overlay paints each host in blue. Layout Edit Mode previews every Special Bar for every class. Magenta guides mark screen centre. Writes go only to the Profile. The Micro Bar, the Bag Bar, Tracking, Chat, and Details Windows do not move on their own.
_Avoid_: Blizzard Edit Mode as the way to place ShadowUI hosts, moving other Chrome

**Keybind Edit Mode**:
The session where the player hovers a button and presses a key. Writes go only to the Profile. It does not write SavedBindings. Layout Edit Mode and Keybind Edit Mode cannot run at the same time.
_Avoid_: LibKeyBound SaveBindings, /kb as the primary command, binding set

**Edit Mode**:
Layout Edit Mode or Keybind Edit Mode. `/shadowui` and `/sui` open options. `/shadowui edit` toggles Layout Edit Mode. `/shadowui binds` toggles Keybind Edit Mode. `/shadowui prune` packs Keybinds left. `/sui` takes the same subcommands.
