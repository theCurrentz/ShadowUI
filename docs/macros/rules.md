# Macro engine rules (Classic Era)

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
| `target=mouseover` | Cast on unit under the cursor |
| `target=player` | Cast on you |
| `target=focus` | Cast on focus (Classic Era has `/focus`) |
| `target=pet` | Cast on your pet |
| `target=targettarget` | Cast on their target |

Classic-safe unit syntax is `target=mouseover`. Some later Classic builds also accept `@mouseover`. These notes use `target=`.

Stance numbers are class-specific. See each class file.

## Ranks (downrank)

Append the rank in parentheses. No space before `(`:

```
/cast Frostbolt(Rank 1)
/cast Flash Heal(Rank 4)
/cast Heroic Strike(Rank 3)
```

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

`/stopattack` stops auto-shot or melee swing (Hunter Feign Death, Rogue vanish setup).

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

## What not to do

- Do not put a long `/script` in the body. Classic blocks most of it in combat.
- Do not rely on `[btn:2]` for a keybind. Right-click tests are for mouse clicks on the button.
- Do not stack five spells with no conditions. The client casts the first one that is usable, which is easy to misread.
- Do not ship these as ShadowUI defaults. They stay in `docs/macros/`.
