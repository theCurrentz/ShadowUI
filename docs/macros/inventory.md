# Classic Era macro inventory

Dump of every `macros-cache.txt` under `/Applications/World of Warcraft/_classic_era_/WTF` (21 Aug 2026). `.old` copies match the live files unless a note says otherwise.

ShadowUI does not load these files. This list is the source for the triage in [README.md](README.md).

**Live cap (Classic Era `/macro`):** 120 account + 18 character. Body 255 characters. Name 16 characters.

Nightslayer **Tazzy** has **28** character-cache entries. The extra ten sit in the file; the UI still only shows 18. That is why the sidecar rolodex exists.

## Who owns which file

| Account | Realm / character | Class (from SavedVariables) | File | Count |
| --- | --- | --- | --- | --- |
| WARKEYS | *(account)* | mixed Mage + Warrior | `macros-cache.txt` | 42 |
| WARKEYS | Nightslayer / Tazzy | Warrior | character | 28 |
| WARKEYS | Whitemane / Tazzy | Warrior | character | 18 |
| WARKEYS | Whitemane / Tazman | Warrior | character | 18 |
| WARKEYS | Living Flame / Tazman | Warrior | character | 18 |
| WARKEYS | Nightfall / Tazz | Warrior | character | 18 |
| WARKEYS | Nightslayer / Currentz | Mage | character | 4 |
| WARKEYS | Whitemane / Currentz | Mage | character | 0 |
| WARKEYS | Living Flame / Currentz | Mage | character | 9 |
| WARKEYS | Defias Pillager / Curents | — | character | 2 |
| WARKEYS | Defias Pillager / Xavvian | Warlock | character | 1 |
| 2219647#1 | *(account)* | Paladin tools | account | 3 |
| 2219647#1 | Nightslayer / Virene | Paladin | character | 1 |
| 372399535#1 | *(account)* | Hunter / Paladin mix | account | 10 |

Other characters have no `macros-cache.txt`.

## WARKEYS account (42) — mixed Mage + Warrior

These sit on the General tab and follow every character.

| Name | Role | Keep? |
| --- | --- | --- |
| `'` | Fire Blast, Shift Rank 1 | **keep** — Mage filler |
| `ae` | Arcane Explosion, Shift Rank 1 | **keep** |
| `am` | Arcane Missiles, skip if channeling | **keep** |
| `Blizz` | Blizzard, Shift Rank 1 | **keep** |
| `c` | Cone of Cold, Shift Rank 1 | **keep** as catalog `cone`; Warrior Cleave keeps `c` |
| `c` (racial) | Cannibalize + conjured food/water | **drop** — Cannibalize is a racial on the bar, not a macro. Conjure food is Mage. Do not keep an account `c` for the racial. |
| `CS` | Counterspell + `/stopcasting` | **keep** (mouseover line stays commented) |
| `decurse` | Remove Lesser Curse, mouseover then target | **keep** — existing uses mouseover |
| `f` | Frostbolt + `/cqs`, Shift Rank 1 | **keep** |
| `fb` | Fireball; Shift Combustion + trinkets | **keep** |
| `fs` | Flamestrike `@cursor`; Alt burst mods | **keep** |
| `ib` | Ice Block toggle (`cast` then `cancelaura`) | **keep** |
| `MS` | Mana Shield + `/stopcasting` | **keep** |
| `mqg` | SpellQueueWindow + Mind Quickening Gem + Frostbolt | **keep** |
| `PoM + fb` | Presence of Mind + trinkets + Frostbolt | **keep** |
| `ap + PoM` | PoM + Arcane Power + Frostbolt | **keep** |
| `toep +fb` | Talisman of Ephemeral Power + Frostbolt | **keep** |
| `zhc` | ZHC item:19950 + Frostbolt | **keep** |
| `sh` | Sheep announce + Polymorph Rank 1 | **keep** |
| `org` / `uc` / `tb` | Horde teleport / Shift portal | **keep** as Horde port group |
| `shadow` | Equip Touch of Chaos + Shoot | **keep** as wand kit |
| `c` (racial) | Cannibalize + conjured food/water | **drop** — Cannibalize is a racial on the bar, not a macro. Conjure food is Mage. Do not keep an account `c` for the racial. |
| `cc` | Crystal Charge `@cursor` | **keep** |
| `nef` | Stratholme Holy Water `@cursor` + Blast Wave | **keep** as fight kit |
| `prot` | Burrower's Shell + Loatheb's Reflection | **keep** on Mage Currentz (`m-prot`). Not shared. |
| `Decursive` | addon stub (`Println`) | **drop** from the plan — addon owns it |
| `pi` | whisper Stinkytoez for PI + Fireball | **drop** from the shared plan — character social |
| `sum` | Ritual of Summoning announce | **keep** on Warlock, not Mage |
| `pa` / `pf` | pet attack / follow | **keep** on Hunter/Warlock |
| `a` | Taunt | **keep** Warrior |
| `br` | Berserker Rage | **keep** Warrior |
| `bs` | Battle Shout | **keep** Warrior |
| `bt` | Bloodthirst | **keep** Warrior |
| `ds` | Demoralizing Shout | **keep** Warrior |
| `ex` | Execute | **keep** Warrior |
| `hm` | Hamstring | **keep** Warrior |
| `pum` | Pummel | **keep** Warrior |
| `ada` / `dual` / `tankdw` | named weapon swaps | **keep** in Tazzy gear kit, not generic |

## Warrior character sets (Tazzy / Tazman / Tazz)

Canonical combat set is **Nightslayer Tazzy**. Other warriors are the same core with different weapons.

| Name | Body (short) | Keep? |
| --- | --- | --- |
| `charge` | Charge + Intercept + `/startattack` (some also Rend) | **keep** Charge+Intercept. Drop Rend-on-charge. |
| `a` | Bloodrage + Berserker Rage + `/startattack` | **keep** active Berserker Rage (Tazman). Tazzy comments it out. |
| `a` | `/startattack` only | **drop** — duplicate name, no value. Not a shared macro. |
| `b` / `bs` / `d` | Battle / Berserker / Defensive + `/startattack` | **keep** |
| `h` / `c` / `ww` | Heroic Strike / Cleave / Whirlwind | **keep** |
| `ms` / `bt` / `ex` / `o` | Mortal Strike / Bloodthirst / Execute / Overpower | **keep** |
| `rend` / `s` | Rend / Sunder | **keep** |
| `pum` | Berserker Stance + Pummel | **keep** |
| `sb` | equip shield + Defensive + Shield Bash | **keep** generic bash; named-item copy in gear kit |
| `sw` / `sd` | Shield Wall, sometimes with a named shield | **keep** both patterns |
| `d` | Disarm | **keep** as catalog `disarm`; Defensive Stance keeps `d` |
| `dfdw` | Diamond Flask + Death Wish + `/cqs` | **keep** |
| `dual` / `dw` / `sh` / `shh` / `th` | Quel'Serrar, dual wield, 1H+shield, Archeus | **keep** in Tazzy gear kit |
| `jed` / `prin` / `lfg` | `/tar j`, `/tar prince`, UBRS LFG | **drop** from the plan — one-shot social / target |

## Mage character sets

| Toon | Keep? |
| --- | --- |
| Nightslayer Currentz `if` / `sw` | **keep** Alliance Ironforge + Stormwind ports |
| Nightslayer Currentz `WTS` / `DROP` | **drop** — vendor / raid call |
| Living Flame Currentz `com` / `heal` / `wof` | **drop** — out of Classic Era scope (Combustion monocle, Regeneration, WotF) |
| Living Flame Currentz LFG / assigns / recruit | **drop** |

## Other accounts (do not drive the plan)

| File | Macros | Note |
| --- | --- | --- |
| 2219647#1 account | Decursive Purify, RXP targeting, empty `ad` | Leveling / addon |
| Virene | `/equip Thief's Blade` (typo `equiip`) | Paladin gear swap |
| 372399535#1 | Call Pet + Worg Carrier, Holy Light on named friends, summon, RXP, `/tar sayge` | Hunter/Paladin leveling |
| Defias Curents | Light of Elune + Hearth, `/tar p` | one-shot |
| Xavvian | `/4 LF tank scholo` | social |

## Plan macros that you do not have yet

Keep your existing bodies when they overlap. Add these from the plan as **new** groups so a class is complete:

- Warrior: Revenge, Shield Block, Last Stand, Sweeping Strikes, Slam, Thunder Clap, Mocking Blow, Recklessness, Retaliation, Intimidating Shout, Challenging Shout (you do not have these as macros; spells may sit on bars).
- Mage: Blink, Evocation, Cold Snap, Ice Barrier, wards, Slow Fall, Dampen/Amplify, Alliance Darnassus port, Conjure food/water/gem.
- Every other class: a full play group (you have almost none on disk).
