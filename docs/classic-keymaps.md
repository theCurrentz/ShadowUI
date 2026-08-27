# Classic Era keybind maps

Parked notes for class maps. Spell names are Classic Era. Base Keybinds live in `defaults/base.lua`. Warrior Variant Action Deck entries in `defaults/classes/WARRIOR.lua` follow the Warrior section. Other classes stay docs only; ShadowUI does not load those maps.

Layer the same way as Layout: **Base** (physical keys + interface) → **Class** (shared jobs + class core) → **Variant** (talent-tree swaps). Macro ids match [docs/macros/](macros/README.md). A name with no id has no catalog body yet.

## Scope

- Movement: WASD, **A/D strafe**, mouse look. **S** stays backpedal.
- **Shift may be a keybind.** Potion (`SHIFT-G`) and pet follow (`SHIFT-`` ` ``) are split. Cheap ranks and travel swaps still use `[mod:shift]` on the unshifted key.
- One job stays on one key across classes. Rotation fillers may change by Variant.

## How to read a map

- Rank lists are most important first.
- Maps are `key` → ability (catalog id). Warrior also lists Action Slot.
- `SHIFT-` plus a key is its own bind when the map lists it.
- Alt and Ctrl on a key still change the spell on that key (self-cast / Rank 1).
- Class jobs repeat on every Variant on purpose.

## Key ranks

Score = press while holding **W**, while strafing **A** or **D**, and in a **W+A** / **W+D** chord. Mouse side buttons score high. They cost no left-hand movement.

**Misclick cost** is a second score. `1` `2` `3` `4` sit in one mash span. A rare cooldown on `4` is a fat-finger from `1`–`3`. Do not put a long cooldown, a long channel, a form swap, or a panic spell on `1`–`4`. `E` is the same: high access, high miss risk.

Safe on `4`: high-frequency rotation, or a spell that **fails cheap** (Execute, Hammer of Wrath, Shoot, Stealth in combat).

Rare / catastrophic spells go to `6` `7` `B` `Y` or `SHIFT-` plus a related key (Cold Snap on `SHIFT-Z` next to Ice Block).

**S — every GCD / must not miss**

1. `E` — best letter while holding W. Slight penalty while holding D.
2. `R` — index, while moving.
3. `F` — index home. **Interrupt job.**
4. `Q` — strong. Worse while holding A.
5. `1` `2` `3` — number row from Q/W.
6. `BUTTON4` `BUTTON5` — no left-hand cost. Warrior uses these for stances.

**A — high use, still easy**

7. `C` `V` `5` `T` `G`
8. `4` — easy, but **fat-finger from `1`–`3`**. High-frequency or fail-cheap only.
9. `BUTTON3` — middle click. Warrior stance. Other classes: avoid during look.

**B — cooldowns, not panic**

10. `6` `X` `Z` `7` `` ` ``
11. `B` `Y`

**C — reachable, not rotation**

12. `H` `N` `M` `F1`–`F4` `8`

**Shift chord — extra binds**

Same physical key, pinky down. Slightly worse than the unshifted key. Valid combat binds.

- S-chord: `SHIFT-E` `SHIFT-R` `SHIFT-F` `SHIFT-Q` `SHIFT-1` `SHIFT-2` `SHIFT-3`
- A-chord: `SHIFT-4` `SHIFT-C` `SHIFT-V` `SHIFT-5` `SHIFT-T` `SHIFT-G`
- B-chord: `SHIFT-6` `SHIFT-X` `SHIFT-Z` `SHIFT-7` `SHIFT-B` `SHIFT-Y`

Alt and Ctrl do not add keys. They change the spell on the key already bound.

## Reserved keys

Do not bind combat here.

- Movement: `W` `A` `S` `D`
- Look / click: Mouse1, Mouse2
- Target / jump: `Tab`, Space
- Mac Escape: Caps Lock
- Weak combat: `9` `0` `-` `=` `I` `J` `K` `O` `P` `L` and far F-keys

Do not reserve Shift. `SHIFT-1`–`6` and `SHIFT`+letter are legal binds.

## Shared job keys

Place these before spec fillers.

- **Interrupt** → `F` — `/stopcasting`, then the kick.
- **Stun / hard CC** → `C`
- **Soft CC** → `X`
- **Panic defensive** → `Z`
- **Dispel / purge / cleanse** → `V` — healers. DPS with no dispel: Blink or short AoE.
- **Healer spam** → `1` fastest heal, `2` HoT or shield, `3` big heal. Alt = self (`target=player`).
- **HP potion** → `G` (drag the potion, not a macro). Mana classes: `SHIFT-G` (mana potion item).
- **Trinket / burst** → `T` (`shared-t13` or a class burst macro). `SHIFT-T` may be a second bind.
- **Mount** → `F1`. Paladin: `p-mount`.
- **Auto Run** → `F2`
- **Pet attack** → backtick (`h-pa` / `l-pa`). Follow is `SHIFT-`` ` `` (`h-pf` / `l-pf`).
- **Warrior stances** → `BUTTON3` Battle (`w-b`), `BUTTON4` Defensive (`w-d-def`), `BUTTON5` Berserker (`w-bs`).

If a class has no kick, `F` holds the highest-priority **instant** that must fire while moving.

## Modifier rules

From [macros/rules.md](macros/rules.md). These are catalog habits, not bind bans.

- **Shift** — may be a **keybind** (`SHIFT-E`, `SHIFT-1`, …). Potion items and pet follow are split onto Shift binds. Cheap ranks, seal/aspect/imbue swaps, and portals still use `[mod:shift]` on the unshifted key. If a map binds `SHIFT-F` and a kick macro also tests `[mod:shift]`, both claims exist.
- **Alt** — max rank on you. Do not mix Alt with Shift/Ctrl on healer keys.
- **Ctrl** — Rank 1 when Shift already holds a mid rank.

## Interface binds (Base)

Live WARKEYS habits. Not combat.

- `,` — map
- `F1` — extra action (mount slot)
- `F2` — Auto Run
- `Tab` — target
- Space — jump
- `;` — Questie (live)
- `/` — sheath (live)
- `ALT-Z` — sit (live)
- `SHIFT-\` — run/walk (live)
- `SHIFT-F1`–`F9` — raid marks (live; these Shift binds stay)
- Caps Lock — Escape (Mac remap, not WTF)
- `CTRL-SHIFT-1`–`4` — rare extra clicks. Not rotation.

## Map rule

1. Bind reserved keys and shared jobs.
2. Put spec identity (every GCD) on leftover S: `1` then `2` then `E` then `R` then `Q`.
3. Put rotation partners on adjacent keys.
4. Put movement instants on `Q` or `BUTTON4`.
5. `4` is only high-frequency or fail-cheap. Not Cold Snap, Combustion, Arcane Power, Lay on Hands, Tranquility, Evocation, Elemental Mastery, Adrenaline Rush, Rapid Fire, Moonkin, Divine Favor.
6. Put 1–2 min and longer CDs on `T` `6` `7` `B` `Y` or a Shift chord. Channels go there too.
7. Extra actions may use `SHIFT-` plus a combat key. Pair a reset with its panic key (`SHIFT-Z` = Cold Snap).
8. Class layer = jobs + class core. Variant layer = keys that swap.

---

## Warrior

Shipped preset: [defaults/classes/WARRIOR.lua](../defaults/classes/WARRIOR.lua).
This map is for Warrior only. It does not include racial abilities. The Class
layer defines each physical key once. Arms, Fury, and Protection change Action
Deck entries, but they do not move the keys.

`bar1` follows the active Warrior stance:

| Stance | Action Slots |
| --- | --- |
| Battle | 73–84 |
| Defensive | 85–96 |
| Berserker | 97–108 |

The fixed utility row stays available in every stance:

| Key | Slot | Macro | Job |
| --- | ---: | --- | --- |
| `Q` | 1 | `w-hm` | Hamstring |
| `E` | 2 | `w-charge` | Charge / Intercept |
| `R` | 3 | `w-c` | Cleave |
| `F` | 4 | `w-interrupt` | Shield Bash / Pummel |
| `G` | 5 | `w-bloodrage` | Bloodrage |
| `C` | 6 | `w-intimid` | Intimidating Shout |
| `V` | 7 | `w-disarm` | Disarm |
| `T` | 8 | Variant | Sweeping Strikes / Death Wish / Last Stand |
| `B` | 9 | `w-br` | Berserker Rage |
| `Y` | 10 | `w-shout` | Battle Shout; Shift = Demoralizing Shout |

Slots 11 and 12 are clear by design.
The unbound page positions are also clear: 80, 81, 84, 92, 93, 96, 104, 105,
and 108.

The main Bar keeps one physical job map across all three stance pages:

| Key | Battle | Defensive | Berserker |
| --- | --- | --- | --- |
| `1` | Variant attack | Variant attack | Variant attack |
| `2` | Overpower | Revenge | Whirlwind |
| `3` | Heroic Strike | Heroic Strike | Heroic Strike |
| `4` | Execute | Execute | Execute |
| `5` | Rend | Sunder Armor | Sunder Armor |
| `6` | Thunder Clap | Shield Block | Berserker Rage |
| `7` | Variant secondary | Variant secondary | Variant secondary |
| `Z` | Retaliation | Shield Wall | Recklessness |
| `X` | Mocking Blow | Taunt | Challenging Shout |

The Variant attack on `1` is Mortal Strike for Arms, Bloodthirst for Fury, and
Shield Slam for Protection. Shield Slam is the 31-point Protection talent in
Classic Era. The Variant secondary on `7` is Slam for Arms, Demoralizing Shout
for Fury, and Concussion Blow for Protection. Hamstring, Charge / Intercept,
Execute, Disarm, Berserker Rage, and the smart interrupt perform the required
stance dance.
A stance change can require a second key press after the stance cooldown.
Shield Slam and Shield Wall also require an equipped shield; the generic deck
does not select character-specific gear.

Heroic Strike uses maximum rank. Rank 3 has the same listed rage cost, so this
button has no lower-rank modifier.

Mouse side buttons always keep the stance jobs:

| Key | Slot | Action |
| --- | ---: | --- |
| `BUTTON3` | 109 | Battle Stance |
| `BUTTON4` | 110 | Defensive Stance |
| `BUTTON5` | 111 | Berserker Stance |

### Variant pages

Each row lists Battle / Defensive / Berserker Action Slots.

| Slots | Key | Arms | Fury | Protection |
| --- | --- | --- | --- | --- |
| 73 / 85 / 97 | `1` | Mortal Strike | Bloodthirst | Shield Slam |
| 74 / 86 / 98 | `2` | Overpower / Revenge / Whirlwind | same | same |
| 75 / 87 / 99 | `3` | Heroic Strike | same | same |
| 76 / 88 / 100 | `4` | Execute | same | same |
| 77 / 89 / 101 | `5` | Rend / Sunder Armor / Sunder Armor | same | same |
| 78 / 90 / 102 | `6` | Thunder Clap / Shield Block / Berserker Rage | same | same |
| 79 / 91 / 103 | `7` | Slam | Demoralizing Shout | Concussion Blow |
| 82 / 94 / 106 | `Z` | Retaliation / Shield Wall / Recklessness | same | same |
| 83 / 95 / 107 | `X` | Mocking Blow / Taunt / Challenging Shout | same | same |

The Action Deck owns slots 1–12 and 73–111. `/shadowui deck` clears and replaces
only those slots. Slots 13–72 and 112–120 stay unchanged. Missing macros are
created on the General tab before any slot changes. Every entry must match its
Warrior body marker. For example, account macros named `c` for Cannibalize or Cone of
Cold cannot fill the Cleave entry.

No talent points means Class jobs only. In that state, deck placement leaves
slots 8, 73, 85, and 97 clear because there is no Variant ability for `T` or
`1`. `/shadowui variant Fury` locks a Variant. The talent tab with the most
points selects Arms, Fury, or Protection unless Manual Override is on.

---

## Mage

Arcane in Era is AP / PoM, not a bolt spec. Filler stays Frostbolt or Fireball.

### Ability rank

All: filler bolt, Fire Blast, Counterspell, Frost Nova, Blink, Polymorph, Ice Block, wards, Evocation, Remove Lesser Curse, burst trinkets.

- Frost: Ice Barrier, Cone of Cold, Blizzard, Cold Snap.
- Fire: Fireball, Scorch, Combustion, Flamestrike, Blast Wave, PoM Pyroblast.
- Arcane: Presence of Mind, Arcane Power, Arcane Explosion, Arcane Missiles.

### Class jobs

- `F` Counterspell (`m-cs`)
- `X` Polymorph (`m-sheep`)
- `Z` Ice Block (`m-ib`)
- `V` Blink (`m-blink`) — Mage dispel is rare; Blink takes `V`
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)
- `H` Remove Lesser Curse (`m-decurse`)

### Frost

- `1` Frostbolt (`m-fb`)
- `2` Ice Barrier (`m-barrier`)
- `3` Arcane Explosion (`m-ae`)
- `4` Wards (`m-ward`) — refresh, low miss cost
- `E` Fire Blast (`m-blast`)
- `Q` Cone of Cold (`m-cone`)
- `R` Frost Nova (`m-nova`)
- `F` Counterspell (`m-cs`)
- `C` Blizzard (`m-blizz`)
- `X` Polymorph (`m-sheep`)
- `Z` Ice Block (`m-ib`)
- `SHIFT-Z` Cold Snap (`m-csnap`) — pairs with Ice Block; not on `4`
- `V` Blink (`m-blink`)
- `5` Mana Shield (`m-ms`)
- `6` Mana gem (`m-gem`)
- `7` Dampen / Amplify (`m-dampen`)
- `T` PoM + Frostbolt (`m-pomfb`)
- `B` Evocation (`m-evo`) — long channel; not on `4` or `6` next to mash keys
- `Y` Shoot (`m-shoot`)
- `N` Slow Fall (`m-slowfall`)
- `BUTTON4` Fire Blast (`m-blast`) — weave while WASD chord
- `BUTTON5` Frost Nova (`m-nova`)
- `G` healing potion (item)
- `H` `m-decurse`

### Fire

Same as Frost except:

- `1` Fireball (`m-fireball`)
- `2` Scorch (`m-scorch`)
- `4` Wards (`m-ward`)
- `6` Combustion (`m-comb`) — not on `4`
- `Q` Flamestrike (`m-fs`)
- `C` Arcane Explosion (`m-ae`)
- `T` PoM Pyroblast (`m-pyro`)
- `7` Blast Wave + holy water (`m-nef`)
- Ice Barrier / Cold Snap / Blizzard / Cone off the bar unless you keep Frost talent leftovers on `Y` / `N`

### Arcane

Same as Frost except:

- `1` Frostbolt (`m-fb`) — Era raid filler
- `2` Arcane Missiles (`m-am`)
- `4` Wards (`m-ward`)
- `6` Arcane Power (`m-ap`) — not on `4`
- `T` AP + PoM (`m-appom`)
- `C` Arcane Explosion (`m-ae`)
- Keep Ice Barrier / Nova / Cone / Ice Block / Blink / CS / sheep on the Frost job keys if talented
- `SHIFT-Z` still Cold Snap if you have it

Ports (`m-sw` `m-if` `m-dar` / Horde `m-org` `m-uc` `m-tb`) sit on `F3`+ or an unbound bag bar. Not combat. Shift = portal.

---

## Priest

### Ability rank

Holy / Disc: Flash Heal, Greater Heal, Renew, PW:Shield, Prayer of Healing, Dispel, Fade, Fear Ward, Inner Fire.

- Disc: Power Infusion, Inner Focus (already inside `pr-poh`).
- Shadow: Shadowform, SW:P, Mind Flay, Mind Blast, Vampiric Embrace, Silence, Psychic Scream, Shackle, Fade.

### Class jobs

- `C` Psychic Scream (`pr-scream`)
- `X` Shackle Undead (`pr-shackle`)
- `Z` Fade (`pr-fade`)
- `V` Dispel Magic (`pr-dispel`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)

### Holy

- `1` Flash Heal (`pr-fh`)
- `2` Renew (`pr-renew`)
- `3` Greater Heal (`pr-gh`)
- `E` Abolish Disease (`pr-abolish`)
- `Q` Inner Fire (`pr-if`)
- `R` Prayer of Healing (`pr-poh`)
- `F` PW:Shield (`pr-pws`) — no kick; shield is the moving instant
- `C` `pr-scream`
- `X` `pr-shackle`
- `Z` `pr-fade`
- `V` `pr-dispel`
- `4` Shoot (`pr-wand`) — fail-cheap
- `5` Fear Ward (`pr-fw`)
- `6` Holy Nova (`pr-nova`) — not on `E`
- `7` Resurrection (`pr-rez`)
- `T` `shared-t13`
- `B` Fort (`pr-fort`)
- `Y` Prayer of Fortitude (`pr-pof`)
- `N` Prayer of Spirit (`pr-spirit`)
- `G` healing potion (item)

### Discipline

Same as Holy except:

- `2` PW:Shield (`pr-pws`)
- `F` Power Infusion (`pr-pi`)
- `E` Renew (`pr-renew`)

### Shadow

- `1` Mind Flay (`pr-mf`)
- `2` Shadow Word: Pain (`pr-swp`)
- `3` Mind Blast (`pr-mb`)
- `E` Vampiric Embrace (`pr-ve`)
- `Q` Shadowform (`pr-sf`)
- `R` Drop form + Flash Heal (`pr-healform`)
- `F` Silence (`pr-silence`)
- `C` `pr-scream`
- `X` `pr-shackle`
- `Z` `pr-fade`
- `V` `pr-dispel`
- `4` Shoot (`pr-wand`)
- `5` PW:Shield (`pr-pws`)
- `T` `shared-t13`
- `G` healing potion (item)
- `BUTTON4` SW:P (`pr-swp`) — apply while moving

---

## Rogue

### Ability rank

All: Kick, Gouge, Kidney Shot, Stealth, Sprint, Evasion, Vanish, Blind, Sap.

- Combat: Sinister Strike, Slice and Dice, Eviscerate, Blade Flurry, Adrenaline Rush.
- Assassination: Rupture, Cold Blood, Cheap Shot / Ambush.
- Subtlety: Ambush, Vanish, Hemorrhage / Ghostly Strike (no catalog id).

### Class jobs

- `F` Kick (`r-kick`)
- `C` Kidney Shot (`r-ks`)
- `X` Gouge (`r-gouge`)
- `Z` Evasion (`r-eva`)
- `V` Blind (`r-blind`) — no dispel
- `G` healing potion (item)

### Combat

- `1` Sinister Strike (`r-ss`)
- `2` Slice and Dice (`r-snd`)
- `3` Eviscerate (`r-evis`)
- `4` Rupture (`r-rup`) — rotation, not a long CD
- `E` Stealth (`r-stealth`) — fails cheap in combat
- `Q` Sap / Pick Pocket (`r-sap`)
- `R` Cheap Shot (`r-cheap`) — opener; also on `BUTTON4`
- `F` Kick (`r-kick`)
- `C` Kidney Shot (`r-ks`)
- `X` Gouge (`r-gouge`)
- `Z` Evasion (`r-eva`)
- `V` Blind (`r-blind`)
- `5` Ambush (`r-ambush`)
- `6` Adrenaline Rush (`r-ar`) — not on `E`
- `7` Sprint (`r-sprint`)
- `T` Blade Flurry + trinket (`r-bf`)
- `B` Vanish (`r-vanish`)
- `BUTTON4` Cheap Shot (`r-cheap`)
- `BUTTON5` Vanish (`r-vanish`)
- `G` healing potion (item)

### Assassination

Same as Combat except:

- `1` Sinister Strike (`r-ss`) — Backstab if daggers (no catalog id); then SS on `4`
- `2` Rupture (`r-rup`)
- `3` Cold Blood + Eviscerate (`r-cb`)
- `E` Ambush (`r-ambush`) — fails cheap in combat
- `T` `shared-t13`
- `6` Slice and Dice (`r-snd`)
- `7` Adrenaline Rush (`r-ar`) if you take it; else Sprint (`r-sprint`)

### Subtlety

Same as Combat except:

- `1` Sinister Strike (`r-ss`) — Hemorrhage if talented (no catalog id)
- `E` Ambush (`r-ambush`) — fails cheap in combat
- Premeditation / Ghostly Strike (no catalog id) on `6` / `7`, not on `4`

---

## Hunter

No kick in Era. `F` = Tranquilizing Shot (must fire now).

### Ability rank

All: Hunter's Mark, Aimed Shot, Multi-Shot, Arcane Shot, Serpent Sting, Concussive Shot, Wing Clip, Feign Death, Freezing Trap, Rapid Fire, pet attack / follow / mend.

- BM: Bestial Wrath, Intimidation (no catalog id).
- Survival: traps, Counterattack, Deterrence (no catalog id).

### Class jobs

- `F` Tranquilizing Shot (`h-tranq`)
- `C` Intimidation (no catalog id); else Concussive (`h-conc`)
- `X` Freezing Trap (`h-trap`)
- `Z` Feign Death (`h-fd`)
- `V` Aspect (`h-aspect`) — Shift = Monkey
- `` ` `` pet attack (`h-pa`); `SHIFT-`` ` `` follow (`h-pf`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)

### Marksmanship

- `1` Aimed Shot (`h-aimed`)
- `2` Multi-Shot (`h-multi`)
- `3` Arcane Shot (`h-arcane`)
- `4` Serpent Sting (`h-sting`) — high frequency
- `E` Concussive Shot (`h-conc`)
- `Q` Wing Clip (`h-clip`)
- `R` Hunter's Mark (`h-mark`)
- `F` `h-tranq`
- `C` Intimidation (no catalog id)
- `X` `h-trap`
- `Z` `h-fd`
- `V` `h-aspect`
- `5` Mend Pet (`h-mend`)
- `6` Call Pet (`h-call`)
- `7` Cheetah (`h-cheetah`)
- `T` Rapid Fire (`h-rapid`) — includes `/use 13`; not on `4` or `5`
- `B` `shared-t14`
- `Y` unused / second aspect
- `` ` `` `h-pa`
- `BUTTON4` Wing Clip (`h-clip`)
- `BUTTON5` Feign Death (`h-fd`)
- `G` healing potion (item)

### Beast Mastery

Same as MM except:

- `1` Arcane Shot (`h-arcane`) if you skip Aimed
- `6` Bestial Wrath (`h-bw`) — not on `5`
- `T` Rapid Fire (`h-rapid`)
- `C` Intimidation (no catalog id)

### Survival

Same as MM except:

- `1` Arcane Shot (`h-arcane`)
- `2` Multi-Shot (`h-multi`)
- `E` Freezing Trap (`h-trap`) — traps more central; then `X` Frost Trap / Immolation Trap (no catalog id)
- `4` Counterattack (no catalog id)
- `B` Deterrence (no catalog id)
- Keep Feign Death on `Z`

---

## Paladin

Alliance only. No kick. `F` = Blessing of Protection (must fire now).

### Ability rank

All: Hammer of Justice, Divine Shield, Cleanse, Blessing, Flash of Light, Lay on Hands.

- Ret: Seal, Judgement, Consecration, Hammer of Wrath, Exorcism, Repentance.
- Holy: Flash of Light, Holy Light, Holy Shock, Divine Favor, Seal of Light / Wisdom.
- Prot: Consecration, Judgement, Righteous Fury, HoJ, bubble. Holy Shield is TBC — leave it off.

### Class jobs

- `F` Blessing of Protection (`p-bop`)
- `C` Hammer of Justice (`p-hoj`)
- `X` Repentance (`p-rep`) if talented; else unused
- `Z` Divine Shield (`p-bubble`)
- `V` Cleanse (`p-cleanse`)
- `F1` Charger / Warhorse (`p-mount`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)

Cancel bubble (`p-cancel-ds`) → `SHIFT-Z`.

### Retribution

- `1` Seal (`p-seal`)
- `2` Judgement (`p-judge`)
- `3` Consecration (`p-cons`)
- `4` Hammer of Wrath (`p-how`)
- `E` Exorcism (`p-exo`) — fails cheap on living targets
- `Q` Flash of Light (`p-fol`)
- `R` Blessing (`p-might`)
- `F` `p-bop`
- `C` `p-hoj`
- `X` `p-rep`
- `Z` `p-bubble`
- `V` `p-cleanse`
- `5` Aura (`p-aura`)
- `6` Lay on Hands (`p-loh`) — not on `4`
- `7` Divine Intervention (`p-di`)
- `T` `shared-t13`
- `B` Righteous Fury off (`p-rf` only if you tank)
- `SHIFT-Z` `p-cancel-ds`
- `BUTTON4` Judgement (`p-judge`)
- `G` healing potion (item)
- `F1` `p-mount`

### Holy

- `1` Flash of Light (`p-fol`)
- `2` Holy Light (`p-hl`)
- `3` Holy Shock (`p-shock`)
- `E` Seal Light / Wisdom (`p-seal-h`) — refresh, low miss cost
- `Q` Blessing (`p-might`)
- `R` Aura (`p-aura`)
- `F` `p-bop`
- `C` `p-hoj`
- `Z` `p-bubble`
- `V` `p-cleanse`
- `4` Judgement (`p-judge`) — high frequency
- `5` Consecration (`p-cons`)
- `6` Divine Favor + FoL (`p-df`) — not on `E`
- `7` Lay on Hands (`p-loh`) — not on `4`
- `T` `shared-t13`
- `SHIFT-Z` `p-cancel-ds`
- `G` healing potion (item)
- `F1` `p-mount`

### Protection

- `1` Consecration (`p-cons`)
- `2` Judgement (`p-judge`)
- `3` Seal (`p-seal`)
- `4` Hammer of Wrath (`p-how`) — fail-cheap if the target is above 20%
- `E` Blessing (`p-might`)
- `Q` Flash of Light (`p-fol`)
- `R` Aura (`p-aura`)
- `F` `p-bop`
- `C` `p-hoj`
- `Z` `p-bubble`
- `V` `p-cleanse`
- `5` unused / second blessing
- `6` Lay on Hands (`p-loh`)
- `7` Righteous Fury (`p-rf`) — not on `E`
- `T` `shared-t13`
- `SHIFT-Z` `p-cancel-ds`
- `G` healing potion (item)
- `F1` `p-mount`

`p-hs` (Holy Shield) stays unused in Era.

---

## Shaman

Horde only.

### Ability rank

All: Earth Shock, Lightning Shield, Ghost Wolf, Grounding / Windfury Totem, Tremor, Mana Spring, Purge.

- Enhancement: Stormstrike, Flame / Frost Shock, Windfury Weapon, Lesser Healing Wave.
- Elemental: Lightning Bolt, Chain Lightning, Elemental Mastery (no catalog id).
- Restoration: Lesser Healing Wave, Healing Wave, Chain Heal (no catalog id), Nature's Swiftness, Mana Tide, Cure Poison.

### Class jobs

- `F` Earth Shock (`s-es`)
- `C` Frost Shock via `s-shock` if Enh keeps Flame on `2`; else Frost Shock on `C` (no extra id)
- `X` unused / Hex is TBC. Rank 1 Earth Shock is already Shift on `F`
- `Z` Nature's Swiftness + Healing Wave (`s-ns`)
- `V` Purge (`s-purge`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)

### Enhancement

- `1` Stormstrike (`s-ss`)
- `2` Flame / Frost Shock (`s-shock`)
- `3` Lightning Bolt (`s-lb`)
- `4` Lightning Shield (`s-ls`) — high frequency
- `E` Lesser Healing Wave (`s-lhw`)
- `Q` Strength of Earth (`s-str`)
- `R` Mana Spring (`s-mana`)
- `F` Earth Shock (`s-es`)
- `C` Grounding / Windfury Totem (`s-ground`)
- `X` Cure Poison (`s-cure`)
- `Z` `s-ns`
- `V` `s-purge`
- `5` Tremor (`s-tremor`)
- `6` Healing Wave (`s-hw`)
- `7` Windfury Weapon (`s-wf`) — imbue; not on `E`
- `T` `shared-t13`
- `B` Mana Tide (`s-tide`) if you have the talent
- `Y` Ghost Wolf (`s-wolf`) — not next to mash keys
- `BUTTON4` Stormstrike (`s-ss`)
- `G` healing potion (item)

### Elemental

Same as Enhancement except:

- `1` Lightning Bolt (`s-lb`)
- `2` Chain Lightning (`s-cl`)
- `3` Flame / Frost Shock (`s-shock`)
- `4` Lightning Shield (`s-ls`) — not Elemental Mastery
- `E` Lesser Healing Wave (`s-lhw`)
- `R` Mana Spring (`s-mana`)
- `6` Elemental Mastery (no catalog id)
- `T` `shared-t13`

### Restoration

- `1` Lesser Healing Wave (`s-lhw`)
- `2` Healing Wave (`s-hw`)
- `3` Chain Heal (no catalog id)
- `E` Cure Poison (`s-cure`)
- `Q` Lightning Shield (`s-ls`)
- `R` Mana Spring (`s-mana`)
- `F` Earth Shock (`s-es`)
- `C` Tremor (`s-tremor`)
- `X` Ghost Wolf (`s-wolf`)
- `Z` `s-ns`
- `V` `s-purge`
- `4` Strength of Earth (`s-str`) — totem drop, low miss cost
- `5` Grounding (`s-ground`)
- `6` Mana Tide (`s-tide`) — not on `R`
- `7` Flame / Frost Shock (`s-shock`)
- `T` `shared-t13`
- `G` healing potion (item)

---

## Warlock

### Ability rank

All: Shadow Bolt, Life Tap, Spell Lock, Fear, Banish, Death Coil, Healthstone, pet, Demon Armor, wand.

- Affliction: Corruption, Curse of Agony / Elements, Drain Soul / Drain Life (Drain Life: no catalog id).
- Destruction: Immolate, Shadowburn, Conflagrate (no catalog id), Searing Pain (no catalog id).
- Demonology: Sacrifice, Felhunter / Succubus, Soulstone, Ritual of Summoning.

### Class jobs

- `F` Spell Lock (`l-lock`)
- `C` Fear (`l-fear`)
- `X` Banish (`l-banish`)
- `Z` Death Coil (`l-coil`) — Demo panic is Sacrifice instead
- `V` Drain Soul (`l-drain`) — no magic dispel
- `` ` `` pet attack (`l-pa`); `SHIFT-`` ` `` follow (`l-pf`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)

### Affliction

- `1` Shadow Bolt (`l-sb`)
- `2` Corruption (`l-corr`)
- `3` Curse of Agony / Elements (`l-coa`)
- `4` Life Tap (`l-tap`) — high frequency
- `E` Immolate (`l-imm`)
- `Q` Drain Life (no catalog id)
- `R` Demon Armor (`l-armor`)
- `F` Spell Lock (`l-lock`)
- `C` Fear (`l-fear`)
- `X` Banish (`l-banish`)
- `Z` Death Coil (`l-coil`)
- `V` Drain Soul (`l-drain`)
- `5` Shoot (`l-wand`)
- `6` Healthstone (item)
- `7` Soulstone (`l-ss`)
- `T` `shared-t13`
- `B` Howl of Terror (no catalog id)
- `Y` Ritual of Summoning (`l-sum`)
- `N` Pet swap (`l-fel`)
- `` ` `` pet attack
- `BUTTON4` Life Tap (`l-tap`)
- `G` healing potion (item)

### Destruction

Same as Affliction except:

- `1` Shadow Bolt (`l-sb`)
- `2` Immolate (`l-imm`)
- `3` Shadowburn (`l-shadowburn`)
- `4` Life Tap (`l-tap`) — keep the frequent tap on `4`
- `E` Conflagrate (no catalog id)
- `Q` Searing Pain (no catalog id)
- `5` Corruption (`l-corr`)

### Demonology

Same as Affliction except:

- `Z` Sacrifice (`l-sac`)
- `B` Death Coil (`l-coil`)
- `7` Pet swap (`l-fel`)
- `Y` `l-sum`
- `N` Soulstone (`l-ss`)

---

## Druid

Feral Cat and Feral Bear are two Variants. Form bars stay separate. Typical Era form index: 1 Bear, 3 Cat.

### Ability rank

- Cat: Shred, Rake, Rip, Ferocious Bite, Prowl, Dash, Faerie Fire (Feral).
- Bear: Maul, Swipe, Growl, Bash, Feral Charge, Frenzied Regeneration, Demo Roar, Enrage.
- Balance: Wrath, Starfire, Moonfire, Hurricane, Roots, Moonkin, Innervate, Faerie Fire.
- Restoration: Rejuvenation, Healing Touch, Regrowth, Swiftmend, NS+HT, Innervate, Rebirth, Mark of the Wild.

### Class jobs

- `F` Cat = Faerie Fire (`d-ff`); Bear = Bash (`d-bash`); caster = Faerie Fire (`d-ff`)
- `C` unused in caster (no scream). Bear Growl is not CC — Growl on `5`
- `X` Entangling Roots (`d-roots`) / Hibernate (no catalog id)
- `Z` Cat / Balance = Barkskin (no catalog id); Bear = Frenzied Regen (`d-fr`); Resto = NS+HT (`d-ns`)
- `V` caster / resto: Abolish Poison / Remove Curse (no catalog id). Cat / Bear: form swap
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)
- `T` Innervate (`d-inn`)

### Cat

- `1` Shred (`d-shred`)
- `2` Rake (`d-rake`)
- `3` Rip (`d-rip`)
- `4` Ferocious Bite (`d-fb`) — rotation dump, like Execute
- `E` Tiger's Fury (no catalog id)
- `Q` Dash (`d-dash`)
- `R` Prowl (`d-prowl`) — not on `E`
- `F` Faerie Fire (`d-ff`)
- `C` Pounce (no catalog id)
- `X` `d-roots` (cancelform)
- `Z` Barkskin (no catalog id)
- `V` Cat Form / Travel (`d-cat`)
- `5` Dire Bear (`d-bear`)
- `6` Rebirth (`d-reb`)
- `7` Healing Touch (`d-ht`)
- `T` Innervate (`d-inn`)
- `B` MotW (`d-motw`)
- `BUTTON4` Dash (`d-dash`)
- `G` healing potion (item)

Claw (no catalog id) replaces Shred if you have no positional opener.

### Bear

- `1` Maul (`d-maul`)
- `2` Swipe (no catalog id)
- `3` Demo Roar (no catalog id)
- `4` Enrage (no catalog id)
- `E` Feral Charge (`d-charge`)
- `Q` Dash does not work in bear — Faerie Fire (`d-ff`) if `F` is Bash
- `R` Dire Bear (`d-bear`)
- `F` Bash (`d-bash`)
- `C` Challenging Roar (no catalog id)
- `X` Hibernate (no catalog id)
- `Z` Frenzied Regeneration (`d-fr`)
- `V` Cat Form (`d-cat`)
- `5` Growl (`d-growl`)
- `6` Rebirth (`d-reb`)
- `7` Healing Touch (`d-ht`)
- `T` Innervate (`d-inn`)
- `BUTTON4` Growl (`d-growl`)
- `G` healing potion (item)

### Balance

- `1` Wrath (`d-wrath`)
- `2` Starfire (`d-star`)
- `3` Moonfire (`d-mf`)
- `4` Healing Touch (`d-ht`) — fail-cheap vs dropping form
- `E` Rejuvenation (`d-rejuv`)
- `Q` Faerie Fire (`d-ff`) if you want `F` free — else keep `F` = `d-ff`
- `R` MotW (`d-motw`)
- `F` Faerie Fire (`d-ff`)
- `C` Hibernate (no catalog id)
- `X` Roots (`d-roots`)
- `Z` Barkskin (no catalog id)
- `V` Abolish Poison / Remove Curse (no catalog id)
- `5` Swiftmend (`d-swift`)
- `6` Moonkin (`d-moonkin`) — not on `4`
- `7` Hurricane (no catalog id) — not on `E`
- `T` Innervate (`d-inn`)
- `B` Rebirth (`d-reb`)
- `G` healing potion (item)

### Restoration

- `1` Rejuvenation (`d-rejuv`)
- `2` Healing Touch (`d-ht`)
- `3` Regrowth (no catalog id)
- `E` Swiftmend (`d-swift`)
- `Q` Moonfire (`d-mf`) — filler while moving
- `R` unused / extra heal
- `F` Faerie Fire (`d-ff`)
- `C` Hibernate (no catalog id)
- `X` Roots (`d-roots`)
- `Z` NS + Healing Touch (`d-ns`)
- `V` Abolish Poison / Remove Curse (no catalog id)
- `4` Mark of the Wild (`d-motw`) — refresh, low miss cost
- `5` Cat Form (`d-cat`)
- `6` Rebirth (`d-reb`)
- `7` Dire Bear (`d-bear`)
- `T` Innervate (`d-inn`)
- `Y` Tranquility (no catalog id) — long channel; not on `4`
- `G` healing potion (item)

---

## Delta vs live

Action-slot spells are server-side. This compares **keys**, not icons.

### Mage (Currentz grid in `defaults/classes/MAGE.lua`)

Live physical grid to keep: `1`–`7`, `Q E R F G C V T B N M Y`, `Z` `X`, `F1`, `BUTTON4` `BUTTON5`.

Proposed job moves (adopt or reject each):

- **Do** put Counterspell on `F`, Ice Block on `Z`, Polymorph on `X`, Blink on `V`, Fire Blast on `E`, Frostbolt on `1`. If live already matches, keep it.
- **Do not** put Cold Snap, Evocation, or Combustion on `1`–`4`. Cold Snap is `SHIFT-Z`. Evocation is `B`.
- **Keep** live `SHIFT-F` as ACTIONBUTTON9. Shift is a legal bind. Counterspell (`m-cs`) does not test `[mod:shift]`.
- **Drop** `8` as a combat bind (C-tier). Move that slot to `H` / `N` / a bag bar.
- **Do not** use `BUTTON3` for a combat spell on Mage. Middle click fights mouse look. Warrior owns `BUTTON3` for Battle Stance.
- `CTRL-SHIFT-1`–`4` stay rare extras. Not rotation.
- `Y` live is an extra click. Maps use `Y` for wand / weak CD.

### Warrior mouse stances

Shipped on Warrior only. These fixed slots stay separate from the three main
stance pages:

- Slot 109 `BUTTON3` Battle (`w-b`)
- Slot 110 `BUTTON4` Defensive (`w-d-def`)
- Slot 111 `BUTTON5` Berserker (`w-bs`)

The smart interrupt (`w-interrupt`) uses Shield Bash with a shield. In the other
case, it enters Berserker Stance and uses Pummel on `F` (slot 4).

Do not also bind `w-b` / `w-d-def` / `w-bs` on letter keys.

### Other classes

Class default Lua files except Mage and Warrior have empty `keybinds`. These maps are greenfield on the shared grid.

## Catalog extras

Put on C-tier or leftover B keys when the class map leaves a hole:

- `shared-assist` — assist
- `shared-focus` — focus
- `shared-clear` — clear focus (`SHIFT` plus the focus key)
- `shared-last` — last target
- `shared-eng` — gloves (`/use 10`)
- `shared-band` — self-cast bandage
- Healing potion, mana potion, LIP, FAP, hearthstone, healthstone, and Cannibalize stay off the catalog. Bind the item or racial.
