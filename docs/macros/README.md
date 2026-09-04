# Classic Era macro index

Parked notes plus class Macro Library groups. Live Keybind overlays live in AceDB SavedVariables, not in sidecar JSON.

The sidecar **WoW Macro Cursor** (sibling repo `../MacroCursor`) reads and writes [catalog.json](catalog.json). That file is the Macro Library. The header **Version** chip selects Era or TBC. TBC reads `_anniversary_` WTF and, when present, [spells-tbc.json](spells-tbc.json). Load a group without wiping groups already on that tab. Replace is an explicit action. On startup the sidecar diffs live `macros-cache.txt` into the library. Catalog bodies win on a name match. Delete in Macro Cursor removes the record from the live cache. A macro removed in the game is unloaded and stays in the library.

Scope: **Classic Era** macros (client 1.13+ conditionals) are the catalog default. Groups tagged `gameVersion: TBC` show only on Version TBC. TBC / Wrath / Retail syntax beyond those tagged groups stays out of the catalog. Version TBC also reads `_anniversary_` WTF and [spells-tbc.json](spells-tbc.json).

Key ranks and class/Variant binds: [classic-keymaps.md](../classic-keymaps.md).

## Map

| File | Who it is for |
| --- | --- |
| [inventory.md](inventory.md) | Dump of every Classic Era `macros-cache.txt` and the triage |
| [catalog.md](catalog.md) | Full text database (see counts in that file) |
| [catalog.json](catalog.json) | Macro Library. The sidecar reads and writes this file |
| [actions.json](actions.json) | Leftover Action Slot overlay. First GET with the client closed migrates it into Account SavedVariables, then clears the file |
| [keybinds.json](keybinds.json) | Leftover Keybind overlay. Same migrate-then-clear path |
| [loaded.json](loaded.json) | Last loaded tab ids plus last-seen live names for delete sync |
| [pruned.json](pruned.json) | Names waiting to leave the live cache while WoW is open. The sidecar deletes this file after it writes WTF |
| [spells.json](spells.json) | Classic Era class, general, racial, and profession abilities for the sidecar Spellbook, including max-rank descriptions for Action Bar tooltips |
| [spells-tbc.json](spells-tbc.json) | TBC Spellbook from Wowhead `/tbc`, including Jewelcrafting and Blood Elf / Draenei racials |
| [rules.md](rules.md) | Engine limits, modifiers, condensed ranks, stopcasting |
| [shared.md](shared.md) | General-tab extras that need a macro: assist, focus, trinket slots, cursor items. No potion, hearth, or racial wrappers |
| [warrior.md](warrior.md) | Warrior macros plus optional Tazzy gear macros |
| [mage.md](mage.md) | Currentz fillers, burst, ports |
| [paladin.md](paladin.md) | Seals, blessings, bubble, Alt-self heals |
| [hunter.md](hunter.md) | Aspects, pet, Feign Death, traps, shots |
| [rogue.md](rogue.md) | Openers, Kick, vanish, Cold Blood finishers |
| [priest.md](priest.md) | Alt-self heals, condensed downranks, Shadowform |
| [shaman.md](shaman.md) | Shock interrupt, totems, imbues |
| [warlock.md](warlock.md) | Life Tap, curses, pets, Spell Lock, summon |
| [druid.md](druid.md) | Form cancel, feral interrupt, Innervate, rez |

Rebuild class files and `defaults/catalog.lua` from the Macro Library: `python3 docs/macros/build_catalog.py`. That command reads [catalog.json](catalog.json). Use `--from-source` only to rebuild the library from `build_catalog.py` plus leftover overlay files. Rebuild the sidecar spellbook (class, general, racial, profession tabs) from Wowhead: `python3 docs/macros/build_spells.py`. Add `--version TBC` to write `spells-tbc.json`. Add `--shared-only` to refresh general, racial, and profession tabs without refetching class abilities. Add `--general-only` to refresh the General tab only. Add `--descriptions` to fill max-rank ability text on the current `spells.json` without rebuilding the list.

## Reconcile rule

Existing bodies remain as catalog records. Catalog names are
unique across the library. Social / RXP / Decursive stubs stay out of the authored class files. They may sit in Other when they exist in the live cache.

Scope, class, spec, and character live on the catalog record. Do not put
`# class-specific`, `# global`, or `# character-specific` comments in the body.
Keybinds live in AceDB overlays, not in macro text.

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
9. **Stance / form / aura** — change stance when an action requires another stance.
10. **Downrank** — `[nomod]` max rank, `[mod:shift]` cheap rank, `[mod:ctrl]` Rank 1 when needed.
11. **Pet** — attack (`shared-pa`), follow (`shared-pf`), Spell Lock, Sacrifice.
12. **Travel** — teleport vs portal (Shift = portal), Ghost Wolf, Travel Form, mount.

## Faction locks

Era:

- Paladin is Alliance only. Shaman is Horde only.
- Mage ports: Alliance Stormwind, Ironforge, Darnassus. Horde Orgrimmar, Undercity, Thunder Bluff.
- Priest racials differ. See [priest.md](priest.md).

TBC:

- Paladin and Shaman are both factions. Blood Elf Paladin. Draenei Shaman.
- Mage ports add Exodar, Silvermoon, Shattrath, Theramore, and Stonard.
- Blood Elf Arcane Torrent and Draenei Gift of the Naaru sit in Shared TBC. Priest Consume Magic and Chastise sit in Priest TBC.
