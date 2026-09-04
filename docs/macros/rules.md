# Macro engine rules (Classic Era and TBC)

TBC uses the same 1.13+ conditionals as Era. Version TBC groups live in `build_catalog.py` with `gameVersion: TBC`. Do not mix Era-only racial wrappers onto those groups.

## Limits

- One macro body: **255 characters** including newlines.
- No Lua. No addon API. Only slash commands and conditional casts.
- `#showtooltip` must be line 1 if you use it. Empty `#showtooltip` shows the spell the macro will cast.
- `#showtooltip Spell Name` forces that icon even when a modifier picks another spell.

## Conditionals (1.13+ Classic)

Put tests in square brackets. Separate options with `;` (first match wins).

| Token | Meaning |
| --- | --- |
| `mod` / `mod:shift` / `mod:ctrl` / `mod:alt` | Hold that key |
| `nomod` | No modifier |
| `help` / `harm` | Friendly / enemy |
| `dead` / `nodead` | Dead / living |
| `exists` / `noexists` | Unit exists |
| `combat` / `nocombat` | You are in combat |
| `stance:N` / `nostance:N` / `form:N` | Stance or shapeshift index |
| `stealth` / `nostealth` | Stealthed |
| `mounted` / `indoors` / `swimming` | Position |
| `channeling` / `nochanneling` | You are channeling |
| `equipped:Shields` | Item type on |
| `target=player` | Cast on you |
| `target=focus` | Cast on focus (Classic Era has `/focus`) |
| `target=pet` | Cast on your pet |
| `target=targettarget` | Cast on their target |
| `target=mouseover` | Cast on the unit under the cursor. Existing decurse / dispel macros use it. |

Classic-safe unit syntax is `target=`. Some later Classic builds also accept `@unit`. These notes use `target=`.

Stance numbers are class-specific. See each class file.

## Ranks (downrank)

Append the rank in parentheses. No space before `(`:

```
/cast Frostbolt(Rank 1)
/cast Flash Heal(Rank 4)
```

Put every rank of one spell in **one** macro. First match wins:

```
#showtooltip
/cast [mod:shift] Frostbolt(Rank 1); Frostbolt
```

When a mid rank is the usual cheap cast (heal spam), Shift is that rank and Ctrl is Rank 1:

```
#showtooltip
/cast [mod:alt,target=player] Flash Heal; [mod:shift] Flash Heal(Rank 4); [mod:ctrl] Flash Heal(Rank 1); Flash Heal
```

- No modifier — max rank on the current target.
- **Shift** — cheap rank on the current target.
- **Ctrl** — Rank 1 when Shift already holds a mid rank.
- **Alt** — max rank on you (`target=player`). Do not mix Alt with Shift/Ctrl in these notes.

Use a downrank when you need:

- **Mana** — a cheaper heal or filler bolt.
- **Threat** — a smaller heal or Rank 1 nuke.
- **Kiting** — Rank 1 Frostbolt, Rank 1 Wing Clip already maxes the snare in Era for some spells; still use Rank 1 when the full rank is a waste.
- **AoE grinding** — Rank 1 Arcane Explosion, Rank 1 Consecration, Rank 1 Holy Nova.
- **Debuff apply** — Rank 1 Fireball or Rank 1 Frostbolt to tag, then wand.

## Stopcasting

Casters and healers interrupt their own cast before a kick, panic heal, or panic defensive:

```
/stopcasting
/cast Counterspell
```

Melee `/stopcasting` still helps if you queued a targeted spell (Bandage, Engineering, Slam).

`/stopattack` stops auto-shot or a melee swing (Hunter Feign Death, Rogue vanish setup, Warrior Intimidating Shout).

## Attack queue (melee)

Heroic Strike, Cleave, and Maul **replace** the next swing. Keep auto-attack on:

```
#showtooltip Heroic Strike
/startattack
/cast Heroic Strike
```

## Cast sequence

```
/castsequence reset=target/combat/5 Spell A, Spell B, Spell C
```

`reset=` can be seconds, `target`, `combat`, or `alt` (modifier). One sequence per macro. Do not hide a panic button behind a long sequence.

## Items and slots

```
/use 13
/use 14
/use Super Healing Potion
/use Heavy Runecloth Bandage
/equip [noequipped:Shields] item:12345
```

Slot 13 is the top trinket. Slot 14 is the bottom trinket. Gloves / boots / belt engineering are `/use 10`, `/use 8`, `/use 6`.

## Existing conventions (win over generic plan text)

These come from the WARKEYS cache. New macros follow them.

- **Melee:** `/cast` then `/startattack`. Do not require `[nostance]` if the existing set just `/cast`s the stance.
- **Downrank:** `[nomod]` max rank, then `[mod:shift]` Rank 1 (or a mid rank). That matches Currentz, not `[mod:shift]` alone. Potion and pet follow are separate Shift binds (`G` / `SHIFT-G`, backtick / Shift-backtick), not modifiers on the same key. Write `(rank 1)` with no space before the parenthesis. On Mage, copy those same conditions onto `#showtooltip` so the icon follows Shift.
- **`/cqs`:** Cancel queued spell. Keep it on Mage fillers.
- **Mouseover:** Keep it on decurse / dispel. `[target=mouseover,exists]` then the target.
- **Ground:** `[@cursor]` for Flamestrike, Crystal Charge, Holy Water.
- **Ice Block:** `/cast` then `/cancelaura` on the same key (toggle).
- **Charge:** Charge and Intercept on one key. Do not add Rend to that key.
- **`/run` SpellQueueWindow:** Keep the existing Mage burst macros. Do not add new `/run` bodies.

## Comments

A line that starts with `#` is a comment, except `#showtooltip`. Put `#showtooltip` on line 1 when you use it. Do not add `# class-specific`, `# global`, or `# character-specific` labels. Scope lives on the catalog record. Keybinds live in AceDB overlays.

## What not to do

- Do not wrap a single `/use` of a potion, hearthstone, or healthstone. Drag the item to the bar.
- Do not wrap a racial with no conditions (Cannibalize). Put the spell on the bar.
- Do not put a long `/script` in a **new** body. Classic blocks most of it in combat. Existing Mage SpellQueueWindow macros stay.
- Do not rely on `[btn:2]` for a keybind. Right-click tests are for mouse clicks on the button.
- Do not stack five spells with no conditions. The client casts the first one that is usable, which is easy to misread.
- Do not ship these as ShadowUI defaults. They stay in `docs/macros/` and in WoW Macro Cursor.
- Do not write `macros-cache.txt` while the client is open. Macro Cursor heals empty or damaged caches only when the client is closed. `scripts/apply-macro-cache.sh` copies an Export cache file onto WTF and exits without write if World of Warcraft Classic is open.
