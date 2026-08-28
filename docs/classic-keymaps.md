# Classic Era keybind maps

Parked notes for class maps. Spell names on the Era maps are Classic Era. TBC catalog groups live in the class files under `docs/macros/` and show in Macro Cursor when Version is TBC. Base Keybinds live in `defaults/base.lua`. Warrior Variant Action Deck entries in `defaults/classes/WARRIOR.lua` follow the Warrior section. Other classes stay notes plus Macro Cursor loadouts; `/shadowui deck` does not place them.

Layer the same way as Layout: **Base** (physical keys + interface) → **Class** (shared jobs + class core) → **Variant** (talent-tree swaps) → **Character** (sparse toon overlay). Macro ids match [docs/macros/](macros/README.md). A name with no id has no catalog body yet. Live loadouts sit in AceDB SavedVariables. `/shadowui deck` places the merged Action Deck.

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
- **Pet attack** → backtick (`shared-pa`). Follow is `SHIFT-`` ` `` (`shared-pf`).
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
2. Put spec identity on bar1 from the left. Position 1 (`Q`) is the best Action Slot. Then `E` then `R`. Number-row `1` `2` `3` are high-use partners. Warrior keeps its shipped Action Deck.
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

The Action Deck owns slots 1–12 and 73–111 plus each slot in the selected
loadout. `/shadowui deck` validates every entry, replaces both macro tabs with
only the unique resolved deck macros on the General tab, and then clears and
replaces those slots. Other Action Slots stay unchanged. Every entry must match
its Warrior body marker. A stale Priest Power Infusion macro cannot shift onto
a Warrior slot.

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
- `V` Blink — Mage dispel is rare; Blink takes `V`
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)
- `H` Remove Lesser Curse (`m-decurse`)

### Frost

- `Q` Frostbolt (`m-fb`) — bar1 position 1
- `E` Fire Blast (`m-blast`)
- `R` Frost Nova (`m-nova`)
- `F` Counterspell (`m-cs`)
- `T` `shared-t13`
- `C` Blizzard (`m-blizz`)
- `X` Polymorph (`m-sheep`)
- `Z` Ice Block (`m-ib`)
- `SHIFT-Z` Cold Snap (`m-csnap`) — pairs with Ice Block; not on `4`
- `V` Blink
- `B` Evocation — long channel; not on `4` or next to mash keys
- `H` Remove Lesser Curse (`m-decurse`)
- `1` Ice Barrier (`m-barrier`)
- `2` Arcane Explosion (`m-ae`)
- `3` Cone of Cold (`m-cone`)
- `4` Wards (`m-ward`) — refresh, low miss cost
- `5` Mana Shield (`m-ms`)
- `6` Conjure Mana Ruby
- `7` Dampen / Amplify (`m-dampen`)
- `N` Shoot (`m-shoot`)
- `SHIFT-T` Pyroblast (`m-pyro`)
- `8` Slow Fall (`m-slowfall`)
- `BUTTON4` Fire Blast (`m-blast`) — weave while WASD chord
- `BUTTON5` Frost Nova (`m-nova`)
- `G` healing potion (item)

### Fire

Same as Frost except:

- `Q` Fireball (`m-fireball`)
- `1` Scorch (`m-scorch`)
- `2` Flamestrike (`m-fs`)
- `C` Arcane Explosion (`m-ae`)
- `T` PoM Pyroblast (`m-pyro`)
- `7` Blast Wave + holy water (`m-nef`)
- Ice Barrier / Cold Snap / Blizzard / Cone off the bar unless you keep Frost talent leftovers on `N`

### Arcane

Same as Frost except:

- `Q` Frostbolt (`m-fb`) — Era raid filler
- `1` Arcane Missiles (`m-am`)
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

- `Q` Flash Heal (`pr-fh`) — bar1 position 1
- `E` Renew (`pr-renew`)
- `R` Greater Heal (`pr-gh`)
- `F` PW:Shield (`pr-pws`) — no kick; shield is the moving instant
- `T` `shared-t13`
- `C` `pr-scream`
- `V` `pr-dispel`
- `B` Fort (`pr-fort`)
- `X` `pr-shackle`
- `Z` `pr-fade`
- `H` Abolish Disease (`pr-abolish`)
- `1` Mind Flay (`pr-mf`)
- `2` Shadow Word: Pain (`pr-swp`)
- `3` Mind Blast (`pr-mb`)
- `4` Shoot (`pr-wand`) — fail-cheap
- `5` Inner Fire (`pr-if`)
- `6` Holy Nova (`pr-nova`) — not on `E`
- `7` Resurrection (`pr-rez`)
- `N` Prayer of Fortitude (`pr-pof`)
- `SHIFT-T` Power Infusion (`pr-pi`)
- `SHIFT-Z` Shadowform (`pr-sf`)
- `8` Fear Ward (`pr-fw`)
- `9` Prayer of Spirit (`pr-spirit`)
- `BUTTON4` SW:P (`pr-swp`) — apply while moving
- `G` healing potion (item)

### Discipline

Same as Holy except:

- `E` PW:Shield (`pr-pws`)
- `F` Power Infusion (`pr-pi`)

### Shadow

Same as Holy except:

- `Q` Mind Flay (`pr-mf`)
- `E` Shadow Word: Pain (`pr-swp`)
- `R` Mind Blast (`pr-mb`)
- `F` Silence (`pr-silence`)
- `1` Flash Heal (`pr-fh`)
- `5` PW:Shield (`pr-pws`)

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

- `Q` Sinister Strike (`r-ss`) — bar1 position 1
- `E` Slice and Dice (`r-snd`)
- `R` Eviscerate (`r-evis`)
- `F` Kick (`r-kick`)
- `T` Blade Flurry + trinket (`r-bf`)
- `C` Kidney Shot (`r-ks`)
- `V` Blind (`r-blind`)
- `B` Vanish (`r-vanish`)
- `X` Gouge (`r-gouge`)
- `Z` Evasion (`r-eva`)
- `H` Sprint (`r-sprint`)
- `1` Rupture (`r-rup`) — rotation, not a long CD
- `2` Stealth (`r-stealth`) — fails cheap in combat
- `3` Cold Blood + Eviscerate (`r-cb`)
- `5` Ambush (`r-ambush`)
- `6` Adrenaline Rush (`r-ar`) — not on `E`
- `7` Sap / Pick Pocket (`r-sap`)
- `G` healing potion (item)

Stealth page (bar1, slots 73–84): `Q` Cheap Shot (`r-cheap`), `E` Ambush (`r-ambush`), `H` Sap (`r-sap`). Shared jobs stay on `F` `C` `X` `Z` `V`.

### Assassination

Same as Combat except:

- `Q` Sinister Strike (`r-ss`) — Backstab if daggers (no catalog id); then SS on `1`
- `E` Rupture (`r-rup`)
- `R` Cold Blood + Eviscerate (`r-cb`)
- `2` Ambush (`r-ambush`) — fails cheap in combat

### Subtlety

Same as Combat except:

- `Q` Sinister Strike (`r-ss`) — Hemorrhage if talented (no catalog id)
- `2` Ambush (`r-ambush`) — fails cheap in combat
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
- `C` Concussive (`h-conc`)
- `X` Freezing Trap (`h-trap`)
- `Z` Feign Death (`h-fd`)
- `V` Aspect (`h-aspect`) — Shift = Monkey
- `` ` `` pet attack (`shared-pa`); `SHIFT-`` ` `` follow (`shared-pf`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)

### Marksmanship

- `Q` Aimed Shot (`h-aimed`) — bar1 position 1
- `E` Arcane Shot (`h-arcane`)
- `R` Multi-Shot (`h-multi`)
- `F` `h-tranq`
- `T` Rapid Fire (`h-rapid`) — includes `/use 13`; not on `4` or `5`
- `C` Concussive (`h-conc`)
- `X` `h-trap`
- `Z` `h-fd`
- `V` `h-aspect`
- `B` `shared-t14`
- `H` Mend Pet (`h-mend`)
- `1` Hunter's Mark (`h-mark`)
- `2` Serpent Sting (`h-sting`)
- `3` Wing Clip (`h-clip`)
- `4` Auto Shot — fail-cheap
- `5` Cheetah (`h-cheetah`)
- `6` Call Pet (`h-call`)
- `7` Bestial Wrath (`h-bw`)
- `` ` `` `shared-pa`
- `BUTTON4` Wing Clip (`h-clip`)
- `BUTTON5` Feign Death (`h-fd`)
- `G` healing potion (item)

### Beast Mastery

Same as MM except:

- `Q` Arcane Shot (`h-arcane`) if you skip Aimed
- `7` Bestial Wrath (`h-bw`)
- `T` Rapid Fire (`h-rapid`)

### Survival

Same as MM except:

- `Q` Arcane Shot (`h-arcane`)
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

- `Q` Judgement (`p-judge`) — bar1 position 1
- `E` Seal (`p-seal`)
- `R` Consecration (`p-cons`)
- `F` `p-bop`
- `T` `shared-t13`
- `C` `p-hoj`
- `V` `p-cleanse`
- `B` Righteous Fury (`p-rf`)
- `X` `p-rep`
- `Z` `p-bubble`
- `H` Flash of Light (`p-fol`)
- `1` Hammer of Wrath (`p-how`)
- `2` Exorcism (`p-exo`) — fails cheap on living targets
- `3` Blessing (`p-might`)
- `4` Aura (`p-aura`)
- `5` Holy Light (`p-hl`)
- `6` Lay on Hands (`p-loh`) — not on `4`
- `7` Divine Intervention (`p-di`)
- `SHIFT-Z` `p-cancel-ds`
- `BUTTON4` Judgement (`p-judge`)
- `G` healing potion (item)
- `F1` `p-mount`

### Holy

Same as Retribution except:

- `Q` Flash of Light (`p-fol`)
- `E` Holy Light (`p-hl`)
- `R` Holy Shock (`p-shock`)
- `1` Judgement (`p-judge`) — high frequency
- `2` Seal Light / Wisdom (`p-seal-h`)
- `5` Consecration (`p-cons`)
- `6` Divine Favor + FoL (`p-df`) — not on `E`
- `7` Lay on Hands (`p-loh`) — not on `4`

### Protection

Same as Retribution except:

- `Q` Consecration (`p-cons`)
- `7` Righteous Fury (`p-rf`) — not on `E`

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

- `Q` Stormstrike (`s-ss`) — bar1 position 1
- `E` Flame / Frost Shock (`s-shock`)
- `R` Lightning Bolt (`s-lb`)
- `F` Earth Shock (`s-es`)
- `T` `shared-t13`
- `C` Grounding / Windfury Totem (`s-ground`)
- `V` `s-purge`
- `B` Mana Tide (`s-tide`) if you have the talent
- `X` Cure Poison (`s-cure`)
- `Z` `s-ns`
- `H` Lesser Healing Wave (`s-lhw`)
- `1` Lightning Shield (`s-ls`) — high frequency
- `2` Chain Lightning (`s-cl`)
- `3` Chain Heal
- `4` Strength of Earth (`s-str`)
- `5` Tremor (`s-tremor`)
- `6` Healing Wave (`s-hw`)
- `7` Windfury Weapon (`s-wf`) — imbue; not on `E`
- `N` Ghost Wolf (`s-wolf`) — not next to mash keys
- `SHIFT-R` Mana Spring (`s-mana`)
- `G` healing potion (item)

### Elemental

Same as Enhancement except:

- `Q` Lightning Bolt (`s-lb`)
- `E` Chain Lightning (`s-cl`)
- `R` Flame / Frost Shock (`s-shock`)
- `1` Lightning Shield (`s-ls`) — not Elemental Mastery
- `6` Elemental Mastery (no catalog id)

### Restoration

Same as Enhancement except:

- `Q` Lesser Healing Wave (`s-lhw`)
- `E` Healing Wave (`s-hw`)
- `R` Chain Heal
- `H` Cure Poison (`s-cure`)
- `1` Lightning Shield (`s-ls`)
- `C` Tremor (`s-tremor`)
- `X` Ghost Wolf (`s-wolf`)
- `6` Mana Tide (`s-tide`) — not on `R`
- `7` Flame / Frost Shock (`s-shock`)

---

## Warlock

### Ability rank

All: Shadow Bolt, Life Tap, Spell Lock, Fear, Banish, Death Coil, Healthstone, pet, Demon Armor, wand.

- Affliction: Corruption, Curse of Agony / Elements, Drain Soul / Drain Life.
- Destruction: Immolate, Shadowburn, Conflagrate (no catalog id), Searing Pain (no catalog id).
- Demonology: Sacrifice, Felhunter / Succubus, Soulstone, Ritual of Summoning.

### Class jobs

- `F` Spell Lock (`l-lock`)
- `C` Fear (`l-fear`)
- `X` Banish (`l-banish`)
- `Z` Death Coil (`l-coil`) — Demo panic is Sacrifice (`SHIFT-Z`, `l-sac`)
- `V` Drain Soul (`l-drain`) — no magic dispel
- `` ` `` pet attack (`shared-pa`); `SHIFT-`` ` `` follow (`shared-pf`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)

### Affliction

- `Q` Shadow Bolt (`l-sb`) — bar1 position 1
- `E` Corruption (`l-corr`)
- `R` Curse of Agony / Elements (`l-coa`)
- `F` Spell Lock (`l-lock`)
- `T` `shared-t13`
- `C` Fear (`l-fear`)
- `V` Drain Soul (`l-drain`)
- `B` Howl of Terror
- `X` Banish (`l-banish`)
- `Z` Death Coil (`l-coil`)
- `H` Demon Armor (`l-armor`)
- `1` Life Tap (`l-tap`) — high frequency
- `2` Immolate (`l-imm`)
- `3` Shadowburn (`l-shadowburn`)
- `4` Shoot (`l-wand`)
- `5` Drain Life
- `6` Soulstone (`l-ss`)
- `7` Pet swap (`l-fel`)
- `` ` `` `shared-pa`
- `N` Ritual of Summoning (`l-sum`)
- `SHIFT-Z` Sacrifice (`l-sac`)
- `BUTTON4` Life Tap (`l-tap`)
- `G` healing potion (item)

### Destruction

Same as Affliction except:

- `E` Immolate (`l-imm`)
- `R` Shadowburn (`l-shadowburn`)
- `2` Corruption (`l-corr`)

### Demonology

Same as Affliction except:

- `Z` Sacrifice (`l-sac`)
- `B` Death Coil (`l-coil`)

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
- `C` caster Hibernate; Cat Pounce; Bear Challenging Roar
- `X` Entangling Roots (`d-roots`) / Hibernate
- `Z` Cat / Balance = Barkskin; Bear = Frenzied Regen (`d-fr`); Resto = NS+HT (`d-ns`)
- `V` caster / resto: Abolish Poison. Cat / Bear: form swap (`d-cat`)
- `G` healing potion (item)
- `SHIFT-G` mana potion (item)
- `T` Innervate (`d-inn`)

bar1 pages Caster (slots 1–12), Cat (73–84), Prowl (85–96), and Bear (97–108). Number-row keys stay shared.

### Caster / Balance

- `Q` Wrath (`d-wrath`) — bar1 position 1
- `E` Starfire (`d-star`)
- `R` Moonfire (`d-mf`)
- `F` Faerie Fire (`d-ff`)
- `T` Innervate (`d-inn`)
- `C` Hibernate
- `V` Abolish Poison
- `B` MotW (`d-motw`)
- `X` Roots (`d-roots`)
- `Z` Barkskin
- `H` Rejuvenation (`d-rejuv`)
- `1` Healing Touch (`d-ht`)
- `2` Swiftmend (`d-swift`)
- `3` Rebirth (`d-reb`)
- `4` Moonkin (`d-moonkin`) — not on `Q`
- `5` Dire Bear (`d-bear`)
- `6` Cat Form (`d-cat`)
- `7` NS + Healing Touch (`d-ns`)
- `8` Remove Curse
- `9` Tranquility — long channel; not on `4`
- `G` healing potion (item)

### Cat

- `Q` Shred (`d-shred`) — bar1 position 1
- `E` Rake (`d-rake`)
- `R` Rip (`d-rip`)
- `F` Faerie Fire (`d-ff`)
- `T` Innervate (`d-inn`)
- `C` Pounce
- `V` Cat Form / Travel (`d-cat`)
- `B` MotW (`d-motw`)
- `X` Dash (`d-dash`)
- `Z` Barkskin
- `H` Ferocious Bite (`d-fb`) — rotation dump, like Execute

Prowl page: `Q` Pounce, `C` Prowl (`d-prowl`). Claw replaces Shred if you have no positional opener.

### Bear

- `Q` Maul (`d-maul`) — bar1 position 1
- `E` Swipe
- `R` Demo Roar
- `F` Bash (`d-bash`)
- `T` Feral Charge (`d-charge`)
- `C` Challenging Roar
- `V` Cat Form (`d-cat`)
- `B` Enrage
- `X` Hibernate
- `Z` Frenzied Regeneration (`d-fr`)
- `H` Growl (`d-growl`)

### Restoration

Same as Caster except:

- `Q` Rejuvenation (`d-rejuv`)
- `E` Healing Touch (`d-ht`)
- `Z` NS + Healing Touch (`d-ns`)
- `1` Moonfire (`d-mf`) — filler while moving

---

## Delta vs live

Action-slot spells are server-side. This compares **keys**, not icons.

### Mage (Currentz grid in `defaults/classes/MAGE.lua`)

Live physical grid to keep: `1`–`7`, `Q E R F G C V T B N M Y`, `Z` `X`, `F1`, `BUTTON4` `BUTTON5`.

Proposed job moves (adopt or reject each):

- **Do** put Counterspell on `F`, Ice Block on `Z`, Polymorph on `X`, Blink on `V`, Fire Blast on `E`, Frostbolt on `Q` (bar1 position 1). If live already matches, keep it.
- **Do not** put Cold Snap, Evocation, or Combustion on `1`–`4`. Cold Snap is `SHIFT-Z`. Evocation is `B`.
- **Keep** live `SHIFT-F` as ACTIONBUTTON9. Shift is a legal bind. Counterspell (`m-cs`) does not test `[mod:shift]`.
- **Drop** `8` as a combat bind (C-tier). Move that slot to `H` / `N` / a bag bar.
- **Do not** use `BUTTON3` for a combat spell on Mage. Middle click fights mouse look. Warrior owns `BUTTON3` for Battle Stance.
- `CTRL-SHIFT-1`–`4` stay rare extras. Not rotation.
- `Y` live is an extra click. Maps use `Y` for wand / weak CD.

### Warrior mouse stances

Mouse keys stay on slots 109–111. Arms, Fury, and Protection tombstone the
stance macros. The Blizzard Stance Bar is the stance selector. Apply keeps
those Action Slots empty after reload.

Do not also bind `w-b` / `w-d-def` / `w-bs` on letter keys.

### Other classes

Class default Lua files except Warrior hold Class Keybinds. Live loadouts sit in Account and Character SavedVariables. Warrior Action Slot assignment stays locked.

## Catalog extras

Put on C-tier or leftover B keys when the class map leaves a hole:

- `shared-assist` — assist
- `shared-focus` — focus
- `shared-clear` — clear focus (`SHIFT` plus the focus key)
- `shared-last` — last target
- `shared-eng` — gloves (`/use 10`)
- `shared-band` — self-cast bandage
- Healing potion, mana potion, LIP, FAP, hearthstone, healthstone, and Cannibalize stay off the catalog. Bind the item or racial.
