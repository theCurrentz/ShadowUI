# Classic Era Warrior macro audit

Date: 2026-08-22  
Status: Research rationale plus the pre-change audit. The catalog was revised
from these findings on the same date.

## Conclusion

Use current **Classic Era 1.15.9** as the macro target. ShadowUI supports
Classic Era only. The addon TOC uses interface
`11509`, and Wago Tools reports current `wow_classic_era` build
`1.15.9.69109`. [Repository: `CONTEXT.md:3`;
`README.md:3`; `ShadowUI.toc:1-3`; `docs/macros/README.md:1-7`;
`docs/classic-keymaps.md:1-5`.] [Primary game-data mirror:
[current builds](https://wago.tools/), accessed 2026-08-22.]

The main audit result is a classification error. The current catalog `spec`
field mixes two different facts:

1. the talent tree that unlocks an ability; and
2. the play role that commonly uses an ability.

Pummel, Shield Bash, Shield Wall, Slam, Recklessness, Retaliation, Revenge,
Shield Block, Sunder Armor, and the other ordinary Warrior abilities are
**class-core**, not talent unlocks. Their location in an Arms, Fury, or
Protection spellbook category does not make them talent abilities. The only
active talent-granted abilities relevant to this inventory are:

- Arms: Sweeping Strikes and Mortal Strike;
- Fury: Piercing Howl, Death Wish, and Bloodthirst;
- Protection: Last Stand, Concussion Blow, and Shield Slam.

This list comes from the Warrior rows in the current client `Talent` table.
The table maps Arms to talent tab `161`, Fury to `164`, and Protection to
`163`. The listed spell IDs are the rank spells in those talent rows.
[Primary game data:
[TalentTab](https://wago.tools/db2/TalentTab?build=1.15.9.69109),
[Arms Talent rows](https://wago.tools/db2/Talent?build=1.15.9.69109&filter%5BTabID%5D=exact%3A161),
[Fury Talent rows](https://wago.tools/db2/Talent?build=1.15.9.69109&filter%5BTabID%5D=exact%3A164),
and
[Protection Talent rows](https://wago.tools/db2/Talent?build=1.15.9.69109&filter%5BTabID%5D=exact%3A163),
accessed 2026-08-22.]

## Implemented result

The revised catalog now has one `warrior-core` group and no Warrior “extras”
group. Core uses the General tab because the complete set is larger than the
18-macro character limit. The talent taxonomy recognizes these verified
active unlocks:

- Arms: Sweeping Strikes and Mortal Strike;
- Fury: Piercing Howl, Death Wish, and Bloodthirst;
- Protection: Last Stand, Concussion Blow, and Shield Slam.

The catalog keeps wrappers only when they add behavior or supply the Action
Deck. `warrior-fury` therefore contains Death Wish and Bloodthirst; Piercing
Howl stays a direct spell on an unmanaged slot. Heroic Strike now uses maximum
rank because Rank 3 has the same listed rage cost.

The revision removed the redundant combined Bloodrage body, lower-rank Heroic
Strike body, standalone interrupt copies, duplicate account copies, duplicate
Sunder Armor copy, duplicate `w-ada` gear body, and plain Piercing Howl
wrapper. Every retained macro now adds useful behavior beyond a plain
`/cast Spell`: targeting, stance handling, attack control, modifiers,
stopcasting, or equipment control. The remaining Tazzy weapon sets use
explicit equipment slots and role-neutral classification. Dedicated
Demoralizing Shout and Shield Wall stay because they are distinct controls,
not tab-only duplicates. [Repository:
`docs/macros/build_catalog.py`; `docs/macros/catalog.json`;
`macro-cursor/test/sync.test.ts`.]

For Fury/Protection, load `warrior-core` and `warrior-fury`, then copy Last
Stand separately when the actual build has it. Do not load Concussion Blow or
Shield Slam for a build that does not unlock them.

For Fury/Protection hybrid tanking, keep the Fury Action Deck because
Bloodthirst is the primary attack. Add Last Stand separately when the chosen
talents unlock it. Do not use Shield Slam or Concussion Blow unless the actual
talent build unlocks them. For the practical `31 Fury / 20 Protection`
allocation assumed in this note, Last Stand is available but the deeper
Concussion Blow and Shield Slam rows are not. [Primary game data: Fury and
Protection `Talent` rows above.] The allocation is a recommendation target,
not a ShadowUI requirement.

## Method and source hierarchy

I used these sources in this order:

1. **Primary Blizzard sources:** Blizzard's macro overview confirms the
   General and character macro scopes, action-bar placement, key activation,
   automatic icons, and that one press runs the actions assigned to the
   macro. [Blizzard,
   [New Player Tips: Dial M for Macro](https://worldofwarcraft.blizzard.com/en-us/news/2356433),
   accessed 2026-08-22.] Blizzard's Classic primer separately confirms that
   Classic has three talent trees and lets the player spread points between
   them. Fury/Protection is therefore a hybrid allocation, not a fourth
   specialization. [Blizzard,
   [WoW Classic Primer for New Players](https://worldofwarcraft.blizzard.com/en-us/news/23090134/wow-classic-primer-for-new-players),
   accessed 2026-08-22.]
2. **Primary game data:** client tables for build `1.15.9.69109`, exposed by
   Wago Tools. These tables decide talent membership. Wago Tools is not a
   Blizzard site. The cited rows are extracted Blizzard client data.
   [Primary game-data mirror: Wago links above.]
3. **Primary-equivalent UI source:** the extracted Blizzard FrameXML mirror,
   pinned to Classic Era commit `7285bab` (`version.txt`:
   `1.15.9.69109`). It shows modifier-aware secure attributes and
   separate secure handlers for actions, spells, items, and macros.
   [Blizzard UI source mirror:
   [`version.txt`](https://github.com/Gethe/wow-ui-source/blob/7285babcfa6931f7c4265ce8672fa6d99c7bcaf1/version.txt),
   [`SecureButton_GetModifiedAttribute`, lines 113-132](https://github.com/Gethe/wow-ui-source/blob/7285babcfa6931f7c4265ce8672fa6d99c7bcaf1/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua#L113-L132)
   and
   [secure action handlers, lines 334-455](https://github.com/Gethe/wow-ui-source/blob/7285babcfa6931f7c4265ce8672fa6d99c7bcaf1/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua#L334-L455),
   accessed 2026-08-22.]
4. **Repository evidence:** the shipped catalog, generated notes, Action
   Deck, and local `macros-cache.txt` inventory. These are primary evidence
   for what ShadowUI contains and what its owner has used. They are not
   independent proof of game behavior.
5. **Secondary support only:** Warcraft Wiki and player posts in Blizzard's
   UI and Macro forum. I use these only for macro-language details that the
   public Blizzard overview and extracted Lua do not fully document.
   [Secondary:
   [Secure command options](https://warcraft.wiki.gg/wiki/Secure_command_options),
   [Making a macro](https://warcraft.wiki.gg/wiki/Making_a_macro), and
   [Useful Macro Templates](https://us.forums.blizzard.com/en/wow/t/useful-macro-templates/42937),
   accessed 2026-08-22.]

I classified an ability as talent-only only when its spell ID appears as a
rank spell in one of the three current Warrior `Talent` tables. I did not use
spellbook tabs as talent evidence.

The repository has no separate research-note directory or naming convention.
It keeps the macro notes in `docs/macros/`, and its index identifies each
file's purpose. The generated class file also says that it comes from
`build_catalog.py`. I therefore put this non-generated audit beside those
notes as `docs/macros/warrior-research.md`.
[Repository: `docs/macros/README.md:1-32`;
`docs/macros/warrior.md:1-4`.]

## Version assumption

### Verified

- ShadowUI supports Classic Era only. [Repository:
  `CONTEXT.md:1-3`; `README.md:1-3`.]
- The addon currently declares interface `11509`. [Repository:
  `ShadowUI.toc:1-3`.]
- Wago Tools reports current Classic Era build `1.15.9.69109`.
  [Primary game-data mirror:
  [current builds](https://wago.tools/), accessed 2026-08-22.]
- The macro notes declare Classic Era scope and reject TBC, Wrath, and Retail
  syntax. [Repository: `docs/macros/README.md:1-7`.]

### Assumption for this audit

The recommended inventory targets Era rules on the current 1.15.9 client.

## Talent unlocks versus class core

### Verified talent unlocks

| Unlock tree | Active ability | Client evidence |
| --- | --- | --- |
| Arms | Sweeping Strikes (`12292`) | Arms `Talent` row `133`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A12292) |
| Arms | Mortal Strike (`12294`) | Arms `Talent` row `135`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A12294) |
| Fury | Piercing Howl (`12323`) | Fury `Talent` row `160`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A12323) |
| Fury | Death Wish (`12328`) | Fury `Talent` row `165`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A12328) |
| Fury | Bloodthirst (`23881`) | Fury `Talent` row `167`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A23881) |
| Protection | Last Stand (`12975`) | Protection `Talent` row `153`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A12975) |
| Protection | Concussion Blow (`12809`) | Protection `Talent` row `152`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A12809) |
| Protection | Shield Slam (`23922`) | Protection `Talent` row `148`; [SpellName](https://wago.tools/db2/SpellName?build=1.15.9.69109&filter%5BID%5D=exact%3A23922) |

The row and tab links are the current-build `Talent` links in the methodology
section. [Primary game data, accessed 2026-08-22.]

### Verified class-core set in this repository

The remaining cataloged Warrior abilities are not rank spells in the three
Warrior `Talent` tables. They are therefore class-core for this audit. “Core”
means “not talent-gated.” It does not mean “known at level 1.” A core ability
can still require a level, class quest, stance, weapon, shield, rage, target,
or other game condition. [Primary game data: all three Warrior `Talent`
tables above.]

The repository core set includes Battle Stance, Defensive Stance, Berserker
Stance, Charge, Intercept, Bloodrage, Berserker Rage, Battle Shout,
Demoralizing Shout, Heroic Strike, Cleave, Whirlwind, Execute, Overpower,
Rend, Sunder Armor, Slam, Hamstring, Pummel, Shield Bash, Shield Wall,
Retaliation, Recklessness, Intimidating Shout, Disarm, Taunt, Revenge,
Shield Block, Mocking Blow, Challenging Shout, and Thunder Clap.
[Repository inventory and bodies:
`docs/macros/warrior.md:12-471`;
`docs/macros/build_catalog.py:135-292`.]

### Baseline misclassifications fixed by the revision

These records use a talent-like `spec` label for a core ability:

- `w-pum` and `w-pum-acc`: Pummel is labeled Fury.
- `w-sb` and `w-sw`: Shield Bash and Shield Wall are labeled Protection.
- `w-slam`: Slam is labeled Arms.
- `w-reck`: Recklessness is labeled Fury.
- `w-retal` and `w-sunder5`: Retaliation and Sunder Armor are labeled
  Protection.
- Character gear records such as `w-shh` and `w-sd-item` also use
  `protection` as a role label, not an unlock fact.

[Repository: `docs/macros/build_catalog.py:170-195`, `224-231`,
`248-267`, `281-291`, and `307-328`.] [Primary game data: the three
Warrior `Talent` tables above.]

The `warrior-arms` group is especially mixed. It contains one Arms talent
(Sweeping Strikes), one core attack (Slam), one core fear (Intimidating
Shout), one core major cooldown (Recklessness), and one Fury talent (Death
Wish). [Repository: `docs/macros/build_catalog.py:271-292`.] This is a
catalog taxonomy issue. It is not evidence that the game puts those abilities
behind Arms talents.

## Baseline repository inventory

### Verified

Before the revision, the generated JSON had **51 Warrior records**:

- `warrior-core`: 20;
- `warrior-account`: 10;
- `warrior-prot`: 10;
- `warrior-arms`: 5;
- `warrior-gear`: 6.

[Repository: `docs/macros/catalog.json:27-136`.] The inventory comes from
local Classic Era `macros-cache.txt` files dated 2026-08-21, plus planned
records. [Repository: `docs/macros/inventory.md:1-9`,
`docs/macros/build_catalog.py:135-332`.]

The Warrior Action Deck uses body markers, not names alone. It owns action
slots `1-12` and `73-111`, creates missing General-tab macros, and changes
slots only out of combat. [Repository:
`defaults/classes/WARRIOR.lua:49-52,77-219`;
`core/deck.lua:61-115,131-162`;
`docs/architecture.md:360`.]

The Action Deck already gives the Fury Variant Bloodthirst and Death Wish.
The Protection Variant gives Last Stand, Shield Slam, and Concussion Blow.
It cannot combine a dominant Fury tree with a secondary Protection unlock,
because one active Variant supplies one set of action overrides.
[Repository: `defaults/classes/WARRIOR.lua:170-217`;
`CONTEXT.md:18-20,32-34`.]

### Duplicate and overlap audit

**Remove or archive when the catalog is next revised:**

- `w-bt-acc` duplicates the job of `w-bt`. The different macro tab does not
  justify two catalog bodies when the deck creates its required copy.
  [Repository: `docs/macros/build_catalog.py:170-173,224-225`;
  `core/deck.lua:88-109`.]
- `w-ex-acc` is the legacy, less capable Execute body. `w-ex` also leaves
  Defensive Stance. [Repository: `docs/macros/build_catalog.py:174-176,
  226-228`.]
- `w-pum-acc` duplicates `w-pum` and is superseded for the deck by
  `w-interrupt`. [Repository: `docs/macros/build_catalog.py:183-193,
  229-231`.]
- `w-sunder5` is a second Sunder Armor plus `/startattack` body. It differs
  from `w-s` only by line order and labels. [Repository:
  `docs/macros/build_catalog.py:181-182,264-265`.]
- `w-dual` and `w-ada` have the same named weapon body. [Repository:
  `docs/macros/build_catalog.py:309-310,327-328`.]
- `w-a` combines Bloodrage and Berserker Rage, but the deck intentionally
  uses `w-bloodrage` and `w-br` separately. [Repository:
  `docs/macros/build_catalog.py:152-157,212-213`;
  `defaults/classes/WARRIOR.lua:91-99`.]
- `w-hs-r3` does not reduce Heroic Strike's listed rage cost. The current
  client `SpellPower` rows for Rank 3 and Rank 8 have the same cost value
  (`150`). Keep the maximum-rank `w-h` unless the player intentionally wants
  lower bonus damage and threat. [Primary game data:
  [Rank 3](https://wago.tools/db2/SpellPower?build=1.15.9.69109&filter%5BSpellID%5D=exact%3A285)
  and
  [Rank 8](https://wago.tools/db2/SpellPower?build=1.15.9.69109&filter%5BSpellID%5D=exact%3A11567),
  accessed 2026-08-22.] [Repository:
  `docs/macros/build_catalog.py:164-165,232-234`.]

**Keep as useful variants:**

- `w-shout` and `w-ds`: one modifier-combined button and one dedicated
  Demoralizing Shout button. [Repository:
  `docs/macros/build_catalog.py:214-218`.]
- `w-interrupt` keeps the combined Shield Bash/Pummel job. A separate Shield
  Bash spell or named equipment macro gives clearer manual control without a
  second generic catalog body.
- `w-sw` and `w-major-cd`: dedicated Shield Wall versus one
  stance-selected major cooldown key. [Repository:
  `docs/macros/build_catalog.py:188-196`.]
- Generic combat bodies and named equipment bodies: named equipment is
  character data and becomes stale when gear changes. It must stay outside
  the generic class core. [Repository:
  `docs/macros/build_catalog.py:295-330`;
  `docs/macros/warrior.md:473-527`.]

## Recommended taxonomy

Use three independent labels. Do not use one `spec` field for all three:

| Axis | Values | Meaning |
| --- | --- | --- |
| Unlock | `core`, `arms-talent`, `fury-talent`, `protection-talent` | How the player learns the ability |
| Role | `shared`, `fury-dps`, `fury-prot-tank`, `arms`, `deep-protection` | Why the player keeps the action |
| Delivery | `direct`, `stance-dance`, `modifier`, `equipment` | What the macro adds |

This taxonomy is a recommendation. It does not require a schema change now.
A short note or corrected group name is enough until production code needs
these fields.

Suggested catalog groups:

1. `warrior-core`: only non-talent Warrior actions.
2. `warrior-arms-talents`: Sweeping Strikes and Mortal Strike.
3. `warrior-fury-talents`: Piercing Howl, Death Wish, and Bloodthirst.
4. `warrior-protection-talents`: Last Stand, Concussion Blow, and Shield
   Slam.
5. `warrior-gear`: character-specific equipment only.

## Recommended practical inventory

### Fury

Keep this concise baseline:

| Job | Recommended action |
| --- | --- |
| Main attack | `w-bt` Bloodthirst |
| Rotation partners | `w-ww`, `w-h`, `w-c`, `w-ex` |
| Start and close distance | `w-charge` |
| Interrupt | `w-interrupt` |
| Rage and fear break | `w-bloodrage`, `w-br` |
| Damage cooldown | `w-deathwish`; keep core Recklessness through `w-major-cd` |
| Shouts | `w-shout`; keep `w-ds` only if a dedicated tank button is useful |
| Control | `w-hm`, `w-disarm`, `w-intimid` |
| Stances | `w-b`, `w-d-def`, `w-bs` |
| Optional Fury talent | Piercing Howl as the spell itself |

The first ten rows already exist in the Action Deck or catalog.
[Repository: `defaults/classes/WARRIOR.lua:77-196`;
`docs/macros/catalog.json:27-117`.] Piercing Howl is the one active Fury
talent missing from the catalog. [Primary game data: Fury `Talent` row `160`
above.] A plain Piercing Howl wrapper adds no value, so YAGNI says to drag the
spell unless a tested modifier or stance need appears.

### Fury/Protection hybrid tank

Use the Fury baseline, then keep these tank actions:

| Job | Recommended action |
| --- | --- |
| Primary threat | `w-bt` |
| Armor reduction | `w-s` |
| Reactive attack | `w-revenge` |
| Block | `w-sblock` |
| Single-target taunt | `w-taunt` |
| Interrupt | `w-interrupt`; use the Shield Bash spell or a current named equipment macro for dedicated control |
| Emergency mitigation | `w-major-cd` or dedicated `w-sw` |
| Protection talent defensive | `w-ls`, only if learned |
| Multi-target control | `w-chall`, `w-tc`, `w-ds` |
| Forced attack backup | `w-mock` |
| Weapon sets | one current dual-wield set plus clearly distinct current shield sets |

These tank actions, except Last Stand, are class-core even when they are
mostly used for tanking. [Primary game data: Warrior `Talent` tables above.]
The current class deck already places Revenge, Shield Block, Taunt, Sunder
Armor, Shield Wall, Challenging Shout, Thunder Clap, Mocking Blow, and
Demoralizing Shout on stance pages or the utility row.
[Repository: `defaults/classes/WARRIOR.lua:101-168`.]

For a Fury/Protection hybrid, place Last Stand and Piercing Howl in an
unmanaged slot such as `13-72` or `112-120`. Re-running the deck clears and
replaces its owned slots, so a manual action inside `1-12` or `73-111` will
not survive. [Repository: `defaults/classes/WARRIOR.lua:49-52`;
`docs/classic-keymaps.md:219-223`.]

Do not add Shield Slam or Concussion Blow to this hybrid inventory unless the
character has those Protection talents. Do not infer access from a shield,
Defensive Stance, the Protection spellbook category, or the word “tank.”
[Primary game data: Protection `Talent` rows `148` and `152` above.]

### Macro bodies worth keeping

Keep the current combined Charge/Intercept, smart interrupt, stance-aware
Execute, stance-aware Hamstring, stance-aware Taunt, and stance-selected
major cooldown bodies. They each combine one stable player decision with a
secure game condition. [Repository:
`docs/macros/warrior.md:16-24,56-76,177-187,284-294,357-378`.]

Keep direct spell buttons when a macro adds no decision. Do not add wrappers
only to duplicate a spell icon. This applies to Piercing Howl and to most
single-action cooldowns.

Keep equipment macros character-specific and limited to current item names.
Use one dual-wield body and only current, clearly distinct shield bodies per
gear kit. Remove old named-item copies instead of growing permanent variants.
[Repository: `docs/macros/warrior.md:473-527`.]

## Valid useful variants

These variants solve different practical needs:

- **Smart interrupt or dedicated interrupts:** `w-interrupt` saves a key.
  The direct Pummel or Shield Bash spell gives clearer control without a
  duplicate generic macro.
- **Stance-aware or stance-local:** a stance-aware macro works from another
  page. A direct spell is shorter when the stance page already guarantees the
  correct stance.
- **Combined or dedicated major cooldown:** `w-major-cd` follows the current
  stance. A dedicated Shield Wall button is safer when the player needs one
  named emergency action.
- **Combined or dedicated shout:** `w-shout` saves a slot. `w-ds` gives a
  stable tank key.
- **Maximum-rank or lower-damage Heroic Strike:** use maximum rank by default.
  Rank 3 has the same listed rage cost, so it is not a rage-saving variant.
  Keep it only for a deliberate lower-damage or lower-threat policy.
- **Generic or equipment-assisted:** generic ability bodies do not become
  stale. Named shield and weapon bodies are valid only for one current
  character gear kit.

Do not treat a different line order, macro tab, icon, or short name as a
useful gameplay variant.

## Macro and API constraints

### Verified

- A macro is activated through an action-bar click or key press. General
  macros are account-wide, while character macros are character-specific.
  [Blizzard macro overview, accessed 2026-08-22.]
- Secure buttons resolve modifier-aware attributes and dispatch protected
  action, spell, item, or macro handlers. The macro handler calls
  `RunMacro` or restricted `C_Macro.RunMacroText`; spell and item handlers
  use separate protected paths. [Extracted Blizzard
  `SecureTemplates.lua:113-132,334-455`; generated
  [`UIMacrosDocumentation.lua`](https://raw.githubusercontent.com/Gethe/wow-ui-source/7285babcfa6931f7c4265ce8672fa6d99c7bcaf1/Interface/AddOns/Blizzard_APIDocumentationGenerated/UIMacrosDocumentation.lua),
  accessed 2026-08-22.]
- ShadowUI refuses to create or place the Action Deck during combat. It
  creates every required macro before it clears any managed action slot.
  [Repository: `core/deck.lua:112-147`.]
- The project records the Classic limits as 120 General macros, 18 character
  macros, 255 body characters, and 16 name characters.
  [Repository: `docs/macros/catalog.json:1-8`;
  `docs/macros/README.md:54-58`.] These numbers are verified repository and
  local-client evidence in this audit, not independently documented by the
  cited Blizzard overview.

### Practical rules

- One press must represent one player decision. Do not build a rotation that
  selects from cooldown, rage, proc, target health, or aura state. This audit
  found no primary Classic source that supports those conditions.
- A stance change can consume the press before the requested stance-bound
  ability succeeds. The current project therefore tells the player that a
  second press can be necessary. [Repository:
  `docs/macros/warrior.md:8-10`;
  `docs/classic-keymaps.md:182-190`.]
- The same caution applies to equipment-assisted shield actions. Do not
  promise that equipping a shield and using Shield Wall or Shield Bash will
  complete on one press. Keep the generic action and the gear swap visible as
  separate decisions when reliability matters.
- Secure option clauses are evaluated in order and stop at the first
  satisfied clause. Only commands that accept secure options can use these
  conditionals. [Secondary: Warcraft Wiki
  [Secure command options](https://warcraft.wiki.gg/wiki/Secure_command_options)
  and
  [Making a macro](https://warcraft.wiki.gg/wiki/Making_a_macro),
  accessed 2026-08-22.]
- `/castsequence` advances through a fixed list; it does not make combat
  decisions for the player. It does not advance when the current action does
  not execute successfully. [Secondary: Warcraft Wiki
  [`/castsequence`](https://warcraft.wiki.gg/wiki/MACRO_castsequence),
  accessed 2026-08-22.] Do not use it for the Fury or tank rotation.
- Do not add Lua or addon API calls to combat bodies. The repository already
  forbids new `/run` bodies and stacked, unconditioned spell lists.
  [Repository: `docs/macros/rules.md:3-8,148-156`.]
- Keep existing `target=` syntax. The repository notes that some later
  clients accept `@unit`, but it does not establish one fully verified syntax
  set for all 1.15.9 commands. [Repository:
  `docs/macros/rules.md:10-35`.]
- Do not add native focus-target variants yet. The repository says Classic
  Era has `/focus`, but Classic removed the native focus unit, and recent
  Classic Era focus addons still describe their feature as a replacement.
  Use current-target or mouseover variants until an in-client 1.15.9 test
  proves native focus support. [Repository: `docs/macros/rules.md:27-33`.]
  [Secondary:
  [Blizzard forum focus API report](https://us.forums.blizzard.com/en/wow/t/focus-was-in-vanilla-please-fix-the-api/188182)
  and
  [FocusClassic](https://www.curseforge.com/wow/addons/focusclassic),
  accessed 2026-08-22.]

## Unresolved uncertainty

1. The current client data proves talent membership, but it does not by
   itself prove every stance, shield, rage, or target rule in each macro
   body. Test the stance-dance and equipment-assisted bodies in Classic Era
   1.15.9 before changing shipped defaults.
2. The public Blizzard overview does not document the full Classic
   conditional grammar. `stance`, `combat`, `mod`, `equipped`, tooltip
   selection, and unit-target forms used by the existing catalog should stay
   unchanged unless an in-client test or a more direct Blizzard source
   verifies a replacement.
3. The 120/18/255/16 limits are strongly supported by the repository's live
   cache inventory and generated validation, but this audit did not locate a
   current first-party Blizzard page that states all four numbers.
4. Native focus support remains unverified on 1.15.9. The repository's
   `/focus` claim conflicts with Classic reports and recent replacement-addon
   documentation. Test `/focus` and a focus-target cast in the client before
   changing the macro rules.
5. Fury/Protection is a talent-build description, not a fourth Blizzard
   talent tree and not a ShadowUI Talent Tree value. ShadowUI currently
   selects one Variant from the tree with the most points unless Manual
   Override is active. [Repository: `CONTEXT.md:18-20,29-34`;
   `docs/classic-keymaps.md:225-228`.]
