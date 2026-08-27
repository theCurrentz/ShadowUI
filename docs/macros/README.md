# Classic Era macro index

Parked notes plus the Warrior Action Deck. `/shadowui deck` clears and replaces the managed Warrior Action Slots. Other classes stay notes only.

The sidecar **WoW Macro Cursor** (`macro-cursor/`) reads [catalog.json](catalog.json) and shows the same groups as a rolodex. Load a group without wiping groups already on that tab. Replace is an explicit action. Live WTF sync is **off** (the code stays). Turn `LIVE_SYNC` on in `macro-cursor/src/main.ts` to merge in-game caches.

Scope: **Classic Era** (client 1.13+ conditionals). TBC / Wrath / Retail syntax is out of scope.

Key ranks and class/Variant binds: [classic-keymaps.md](../classic-keymaps.md).

## Map

| File | Who it is for |
| --- | --- |
| [inventory.md](inventory.md) | Dump of every Classic Era `macros-cache.txt` and the triage |
| [catalog.md](catalog.md) | Full text database (see counts in that file) |
| [catalog.json](catalog.json) | Machine source. The sidecar loads this file |
| [pruned.json](pruned.json) | Ids removed by Macro Cursor **Delete**. Rebuild skips them |
| [renames.json](renames.json) | Names changed by Macro Cursor inspector edits. Rebuild applies them |
| [bodies.json](bodies.json) | Bodies changed by Macro Cursor inspector edits. Rebuild applies them |
| [keybinds.json](keybinds.json) | Overlay Keybinds from Macro Cursor **Keybind edit**. `base` applies to every class. `classes` overlays one class |
| [actions.json](actions.json) | Action Slot overlays from Macro Cursor drag-and-drop. Per Class and Variant. Managed Action Deck macros also write the Class Lua Action Deck |
| [spells.json](spells.json) | Classic Era class, racial, and profession abilities for the sidecar Spellbook, including max-rank descriptions for Action Bar tooltips |
| [rules.md](rules.md) | Engine limits, modifiers, condensed ranks, stopcasting |
| [shared.md](shared.md) | General-tab extras that need a macro: assist, focus, trinket slots, cursor items. No potion, hearth, or racial wrappers |
| [warrior.md](warrior.md) | Warrior Action Deck macros plus optional Tazzy gear macros |
| [mage.md](mage.md) | Currentz fillers, burst, ports |
| [paladin.md](paladin.md) | Seals, blessings, bubble, Alt-self heals |
| [hunter.md](hunter.md) | Aspects, pet, Feign Death, traps, shots |
| [rogue.md](rogue.md) | Openers, Kick, vanish, Cold Blood finishers |
| [priest.md](priest.md) | Alt-self heals, condensed downranks, Shadowform |
| [shaman.md](shaman.md) | Shock interrupt, totems, imbues |
| [warlock.md](warlock.md) | Life Tap, curses, pets, Spell Lock, summon |
| [druid.md](druid.md) | Form cancel, feral interrupt, Innervate, rez |

Rebuild class files and `defaults/catalog.lua` from the Python list: `python3 docs/macros/build_catalog.py`. Rebuild the sidecar spellbook (class, racial, profession tabs) from Wowhead: `python3 docs/macros/build_spells.py`. Add `--shared-only` to refresh racial and profession tabs without refetching class abilities. Add `--descriptions` to fill max-rank ability text on the current `spells.json` without rebuilding the list.

## Reconcile rule

Existing bodies remain as catalog records. Every Warrior Action Deck entry
requires its Warrior body marker, not only a matching name. Catalog names are
unique across the library. The deck uses collision-safe
create names when needed. In particular, macro name `c` must match Cleave;
Cannibalize and Cone of Cold cannot satisfy that deck entry.
Social / RXP / Decursive stubs stay out of the catalog.

Label in every body (after `#showtooltip` when that line exists):

```
# <global|class-specific|character-specific> <CLASS> <spec> [Toon] [| key (<hotkey>)]
```

`global` = General-tab scope, not permission for every character. A racial body
still applies only to its race. `class-specific` = that class, any toon.
`character-specific` = one toon (name is the last token). Spec is `all`, `arms`,
`fury`, `protection`, and so on. Warrior labels also show the recommended
Action Deck hotkey. `key (unbound)` means the named gear macro has no shared key.

## Slot cap (the rolodex)

Classic Era `/macro`: **120 account** + **18 character**. One body: **255** characters. One name: **16** characters.

Tazzy’s historical character cache holds 28 entries. The UI still shows 18.
Load **warrior-core** on the General tab. Load **warrior-arms**,
**warrior-fury**, and **warrior-prot** on the character tab only when the
character has those active talent abilities. Fury/Protection normally loads
**warrior-fury** and copies only Last Stand from **warrior-prot** when learned.
Piercing Howl needs no wrapper; drag the spell itself to an unmanaged slot.
Named weapon and shield swaps stay in **warrior-gear**.

## Playstyle groups

1. **Start combat** — Charge+Intercept, opener, Hunter's Mark.
2. **Main damage** — the button you press every GCD, with `/startattack` on melee.
3. **Rage / energy / mana dump** — Heroic Strike, Cleave, Life Tap, downrank filler.
4. **Interrupt** — `/stopcasting` then Kick / Pummel / Shield Bash / Counterspell / Earth Shock / Spell Lock / Bash.
5. **Crowd control** — Polymorph, Sap, Hibernate, Shackle, Banish, Fear.
6. **Defensive** — Shield Wall, Evasion, Ice Block, Fade, Feign Death, bubble.
7. **Help on target** — heal, dispel, Blessing, Innervate, BoP.
8. **Self modifier** — Alt-self heal or buff without losing target.
9. **Stance / form / aura** — change stance when one physical key must work from another stance page.
10. **Downrank** — `[nomod]` max rank, `[mod:shift]` cheap rank, `[mod:ctrl]` Rank 1 when needed.
11. **Pet** — attack, follow, Spell Lock, Sacrifice.
12. **Travel** — teleport vs portal (Shift = portal), Ghost Wolf, Travel Form, mount.

## Faction locks (Classic Era)

- Paladin is Alliance only. Shaman is Horde only.
- Mage ports: Alliance Stormwind, Ironforge, Darnassus. Horde Orgrimmar, Undercity, Thunder Bluff.
- Priest racials differ. See [priest.md](priest.md).
