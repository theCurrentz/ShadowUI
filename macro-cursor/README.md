# WoW Macro Cursor

Sidecar for Classic Era macros. It is not the game client and ShadowUI does not load it.

The interface uses React 19, Lucide glyphs, and Vite. The React layer does not own persistent
data. The existing Vite API writes the JSON, Lua, and optional WoW cache files described below.
The development server keeps React Fast Refresh and CSS HMR enabled.

The app reads [docs/macros/catalog.json](../docs/macros/catalog.json) and shipped ShadowUI defaults.

**Library** lists every group and macro for the selected class. A green edge and a key pill mark macros already on an Action Bar. A second pill marks macros already on the General or character tab.

**Assigned keybind** on the inspector follows the Action Bar key for that macro or spell. The Action Bars are the source of truth. Edit the field (it saves on type, Enter, or blur) or use Keybind edit on a slot; both write the same Class Keybind. It rewrites the `| key (...)` comment in a macro body. Stance pages that share one physical button show one key. An action on the bars with no key shows empty, not the comment fallback. Macros that are not on a bar keep a comment-only key.

**Spellbook** lists Classic Era class abilities, racial traits, and profession skill lines in nested groups. Class talent tabs come first. Racial and profession tabs follow for every class. Profession tabs hold the skill ranks and bar spells (Find Herbs, Find Minerals, Disenchant, Smelting). They do not list recipes. Open a family to see every rank. A green edge marks an ability that is on an Action Bar (any rank for the family header). A blue edge and a Macro pill mark an ability that a catalog macro for this class casts (`/cast`, `/use`, `/castsequence`, `/castrandom`, or `#showtooltip Spell`). The inspector lists those macros. Open one to jump to Library. Drag a family (max rank) or a rank onto an Action Bar slot. Drag a Library macro the same way. Drop an action where there is no Action Slot to remove it. Cancel the drag to keep it. A drop onto an occupied slot places the new action and keeps the old one on the cursor so you can drop it on another slot. Click a slot to place a held action. Escape or a click outside the Action Bars clears the held action and keeps your placement. Library, Spellbook, and Loaded keep their scroll position after a drop. Drops write [docs/macros/actions.json](../docs/macros/actions.json) for the current Class and Variant. Managed Action Deck slots also write the Class Lua Action Deck so `/shadowui deck` matches the loadout. Spells and unmanaged slots stay in `actions.json` only. They do not write in-game Action Slots.

**Action Bars** paint the ShadowUI Base + Class + Variant layout. Click a slot to select its macro. Hover a slot to see its Keybind, the macro body, and every nested ability with its spellbook description. Stance and form chips page the main Bar for Warrior, Druid, and Rogue. A **Copy to other pages** button on a paged Bar copies that page onto the other stance or form pages. A collision banner lists duplicate Class Keybinds. **Save keybinds as default** writes the current keys to the Base layer so every class and Variant inherits them. **Copy bars** copies every Action Slot (macros and spells) from one Variant onto the Variant you are viewing. Managed Action Deck macros write the Class Lua file for that Variant.

**Library**, **Spellbook**, **Loaded**, and **Characters** sit as folder tabs on the catalog pane, not in the header.

**Keybind edit** lets you click a slot and press a key (with Shift / Ctrl / Alt). Escape clears. The mapper uses the physical key, so Chrome dead keys such as Option+E still bind. While a slot is selected, the page blocks in-page browser chords (reload, find). Chrome Gemini on Mac uses Ctrl+G as a global shortcut, so the page never sees that chord. Turn the shortcut off in Chrome Settings → AI innovations → Gemini in Chrome, or type `CTRL-G` in the bind field and press Enter. Writes go to [docs/macros/keybinds.json](../docs/macros/keybinds.json) (`base` or the current class) and survive a sidecar restart. They do not write in-game SavedBindings.

**Loaded** lists only what is on those two tabs, grouped by source group.

**Characters** lists every toon folder under the Classic Era WTF path. Each row shows name, class, level, realm, and account. Class and level come from Nova Instance Tracker `myChars`, then Attune, then a folder heuristic. Live WTF sync is not required. Add `view=characters` to open this list.

Load a group into the 18 character slots or the 120 account slots, edit a name or body, copy a body, or export `macros-cache.txt`. Name and body edits save as you type (and on blur). They write [docs/macros/renames.json](../docs/macros/renames.json) and [docs/macros/bodies.json](../docs/macros/bodies.json) and rebuild the catalog (255 character cap). **Delete** removes the selected macro from the catalog (confirm first). Each card also has Delete. The sidecar writes the id to [docs/macros/pruned.json](../docs/macros/pruned.json) and rebuilds the catalog, so the record stays gone after reload. The Delete key does the same. **Delete tab** only clears the loaded General or character tab. Export after you change a loaded tab.

Live WTF sync is **off**. The app does not merge `macros-cache.txt` on startup. The scan, heal, and merge code stays. Set `LIVE_SYNC` to `true` in `src/main.ts` to turn it on. When on: in-game extras stay, in-game body wins on a name match, empty character caches restore from `.old` then the class core group. Writes happen only when WoW is closed.

Default client path: `/Applications/World of Warcraft/_classic_era_`. Override with `WOW_CLASSIC_ERA`.

To restore a pruned macro, remove its id from `pruned.json` and run `python3 docs/macros/build_catalog.py`. To restore a shipped body, remove its id from `bodies.json` and rebuild.

## Open

From the addon root:

```bash
pnpm --dir macro-cursor install
pnpm --dir macro-cursor test
pnpm --dir macro-cursor dev
```

Vite opens `http://localhost:5174/?class=WARRIOR`. Add `view=loaded` to open the loaded tabs. Add `view=spellbook` to open the class spellbook (racial and profession tabs sit after the class talent tabs). Add `view=characters` to open the toon list.
`pnpm test` runs the data/logic unit tests and the user-facing DOM regression suite.

## Icons

Spell art uses Wowhead's public CDN, same texture names as `Interface/ICONS`:

```
https://wow.zamimg.com/images/wow/icons/large/ability_warrior_charge.jpg
```

Sizes: `small` 18px, `medium` 36px, `large` 56px. Numeric FileDataIDs and `INV_MISC_QUESTIONMARK` fall back to `inv_misc_questionmark`. The in-game picker is `GetMacroIcons()`. This app does not ship Blizzard BLP files.

## Swap a group in game

1. Pick a class, then a scope (global / class / character), then a toon if needed.
2. In **Library**, pick a group.
3. **Load** fills the General or character tab (cap 120 / 18).
4. Open **Loaded** to see both tabs by group. Edit the name or body in the inspector; edits save as you type. **Delete** on a card or in the inspector removes that macro from the catalog. **Delete tab** clears that tab. Confirm each time.
5. **Copy body** into `/macro`, or **Export cache** and replace `WTF/Account/<id>/macros-cache.txt` (account) or `.../<realm>/<char>/macros-cache.txt` (character) **while WoW is closed**.

The General and character tabs start empty until you **Load**. Live WTF sync is off.

Do not write the cache while the client is open. The live UI still caps character macros at 18 even if a cache file holds more.

The catalog does not wrap a single potion, hearthstone, healthstone, or racial. Put those on the bar.

## Rebuild the catalog

```bash
python3 docs/macros/build_catalog.py
python3 docs/macros/build_spells.py
```
