#!/usr/bin/env python3
"""Build the macro catalog, class references, and Warrior deck catalog."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
LIMIT = 255
SCOPE_LINE = re.compile(r"^\s*#\s*(global|class-specific|character-specific)\b", re.I)
RECOMMENDED_KEYS = {
    "w-hm": "Q",
    "w-charge": "E",
    "w-c": "R",
    "w-interrupt": "F",
    "w-bloodrage": "G",
    "w-intimid": "C",
    "w-disarm": "V",
    "w-br": "B / 6",
    "w-shout": "Y",
    "w-o": "2",
    "w-h": "3",
    "w-ex": "4",
    "w-rend": "5",
    "w-s": "5",
    "w-tc": "6",
    "w-sblock": "6",
    "w-ds": "7",
    "w-major-cd": "Z",
    "w-retal": "Z",
    "w-reck": "Z",
    "w-sw": "Z",
    "w-mock": "X",
    "w-taunt": "X",
    "w-chall": "X",
    "w-revenge": "2",
    "w-ww": "2",
    "w-b": "BUTTON3",
    "w-d-def": "BUTTON4",
    "w-bs": "BUTTON5",
    "w-slam": "7",
    "w-sweep": "T",
    "w-ms": "1",
    "w-deathwish": "T",
    "w-bt": "1",
    "w-ls": "T",
    "w-concussion": "7",
    "w-sslam": "1",
    "w-dfdw": "T",
    "w-dual": "unbound",
    "w-sh-qs": "unbound",
    "w-shh": "unbound",
    "w-sd-item": "unbound",
    "shared-pa": "`",
    "shared-pf": "SHIFT-`",
}


def strip_scope_comments(body: str) -> str:
    return "\n".join(
        line for line in body.replace("\r\n", "\n").split("\n") if not SCOPE_LINE.match(line)
    )


def labeled(
    scope: str,
    cls: str,
    spec: str,
    raw: str,
    toon: str = "",
    key: str = "",
) -> tuple[str, bool]:
    """Keep the authored body. Scope lives on the catalog record, not in the macro text."""
    _ = (scope, cls, spec, toon, key)
    return strip_scope_comments(raw.strip("\n")), False


def M(
    id: str,
    name: str,
    scope: str,
    cls: str,
    spec: str,
    tab: str,
    icon: str,
    group: str,
    source: str,
    raw: str,
    notes: str = "",
    toon: str = "",
    gameVersion: str = "",
) -> dict:
    body, dropped = labeled(scope, cls, spec, raw, toon, RECOMMENDED_KEYS.get(id, ""))
    rec = {
        "id": id,
        "name": name,
        "scope": scope,
        "class": cls,
        "spec": spec,
        "tab": tab,
        "icon": icon,
        "group": group,
        "source": source,
        "body": body,
        "chars": len(body),
    }
    if toon:
        rec["character"] = toon
    if notes:
        rec["notes"] = notes
    if gameVersion:
        if gameVersion not in {"ERA", "TBC"}:
            raise SystemExit(f"bad gameVersion for {id}")
        rec["gameVersion"] = gameVersion
    if dropped:
        rec["labelDropped"] = True
        rec["notes"] = (notes + " " if notes else "") + "Label omitted: body at 255."
    if len(name) > 16:
        raise SystemExit(f"name too long: {name}")
    if rec["chars"] > LIMIT:
        raise SystemExit(f"{id} is {rec['chars']} chars")
    return rec


macros: list[dict] = []
groups: list[dict] = []


def add(group: dict, items: list[dict]) -> None:
    gv = group.get("gameVersion")
    if gv in {"ERA", "TBC"}:
        for m in items:
            m.setdefault("gameVersion", gv)
    scopes = [m["scope"] for m in items]
    toons = [m["character"] for m in items if m.get("character")]
    if "scope" not in group:
        if scopes and all(s == "character" for s in scopes):
            group["scope"] = "character"
        elif scopes and all(s == "global" for s in scopes):
            group["scope"] = "global"
        else:
            group["scope"] = "class"
    if "character" not in group and len(set(toons)) == 1:
        group["character"] = toons[0]
    groups.append({**group, "macroIds": [m["id"] for m in items], "count": len(items)})
    macros.extend(items)


# ---------------------------------------------------------------------------
# Shared
# ---------------------------------------------------------------------------
add(
    {
        "id": "shared-core",
        "title": "Shared core",
        "class": "ALL",
        "spec": "all",
        "tab": "account",
        "description": "General-tab utilities that need a macro: assist, focus, trinket slots, pet attack / follow, and cursor items. Put potions, the hearthstone, and racials on the bar. Class spells stay in class groups.",
    },
    [
        M("shared-assist", "assist", "global", "ALL", "all", "account", "ability_hunter_snipershot", "shared-core", "plan",
          "#showtooltip\n/assist"),
        M("shared-focus", "focus", "global", "ALL", "all", "account", "ability_hunter_mastermarksman", "shared-core", "plan",
          "/focus", "Shift is a bind. Clear focus is shared-clear."),
        M("shared-clear", "clear", "global", "ALL", "all", "account", "spell_shadow_teleport", "shared-core", "plan",
          "/clearfocus"),
        M("shared-last", "last", "global", "ALL", "all", "account", "ability_hunter_markedfordeath", "shared-core", "plan",
          "/targetlasttarget"),
        M("shared-stop", "stop", "global", "ALL", "all", "account", "spell_misc_emotionafraid", "shared-core", "plan",
          "/stopattack"),
        M("shared-t13", "t13", "global", "ALL", "all", "account", "inv_misc_orb_02", "shared-core", "plan",
          "#showtooltip\n/use 13"),
        M("shared-t14", "t14", "global", "ALL", "all", "account", "inv_misc_orb_03", "shared-core", "plan",
          "#showtooltip\n/use 14"),
        M("shared-eng", "eng", "global", "ALL", "all", "account", "inv_gizmo_02", "shared-core", "plan",
          "#showtooltip\n/use 10"),
        M("shared-band", "band", "global", "ALL", "all", "account", "inv_misc_bandage_12", "shared-core", "plan",
          "#showtooltip Heavy Runecloth Bandage\n/use [@player] Heavy Runecloth Bandage",
          "Self-cast bandage. A plain bandage on the bar still targets the current unit."),
        M("shared-cc", "cc", "global", "ALL", "all", "account", "inv_misc_gem_diamond_02", "shared-core", "existing",
          "/use [@cursor] Crystal Charge"),
        M("shared-pa", "pa", "global", "ALL", "all", "account", "ability_druid_bash", "shared-core", "existing",
          "/petattack", "Hunter, Warlock, and any other pet class. One General-tab body."),
        M("shared-pf", "pf", "global", "ALL", "all", "account", "ability_tracking", "shared-core", "existing",
          "/petfollow", "Shift-backtick. Split from pet attack so Shift is a bind, not a modifier."),
    ],
)

# ---------------------------------------------------------------------------
# Warrior
# ---------------------------------------------------------------------------
add(
    {
        "id": "warrior-core",
        "title": "Warrior core",
        "class": "WARRIOR",
        "spec": "all",
        "tab": "account",
        "scope": "class",
        "description": "Useful macros for non-talent Warrior abilities. Load this complete set on the General tab; named gear swaps stay character-specific.",
    },
    [
        M("w-charge", "charge", "class", "WARRIOR", "all", "account", "ability_warrior_charge", "warrior-core", "hybrid",
          "#showtooltip [combat] Intercept; Charge\n/cast [nocombat,nostance:1] Battle Stance; [combat,nostance:3] Berserker Stance\n/cast [nocombat] Charge; Intercept\n/startattack",
          "Enters Battle for Charge or Berserker for Intercept. Do not add Rend."),
        M("w-bloodrage", "brage", "class", "WARRIOR", "all", "account", "ability_racial_bloodrage", "warrior-core", "plan",
          "#showtooltip Bloodrage\n/cast Bloodrage\n/startattack",
          "Bloodrage stays separate from Berserker Rage."),
        M("w-br", "br", "class", "WARRIOR", "all", "account", "spell_nature_ancestralguardian", "warrior-core", "hybrid",
          "#showtooltip Berserker Rage\n/cast [nostance:3] Berserker Stance\n/cast Berserker Rage"),
        M("w-b", "b", "class", "WARRIOR", "all", "account", "ability_warrior_offensivestance", "warrior-core", "existing",
          "#showtooltip Battle Stance\n/cast Battle Stance\n/startattack"),
        M("w-bs", "bs", "class", "WARRIOR", "all", "account", "ability_racial_avatar", "warrior-core", "existing",
          "#showtooltip Berserker Stance\n/cast Berserker Stance\n/startattack"),
        M("w-d-def", "d", "class", "WARRIOR", "all", "account", "ability_warrior_defensivestance", "warrior-core", "existing",
          "#showtooltip Defensive Stance\n/cast Defensive Stance\n/startattack"),
        M("w-h", "h", "class", "WARRIOR", "all", "account", "ability_rogue_ambush", "warrior-core", "existing",
          "#showtooltip Heroic Strike\n/cast Heroic Strike\n/startattack",
          "Uses maximum rank. Rank 3 has the same listed rage cost and is not a rage-saving option."),
        M("w-c", "c", "class", "WARRIOR", "all", "account", "ability_warrior_cleave", "warrior-core", "existing",
          "#showtooltip Cleave\n/cast Cleave\n/startattack"),
        M("w-ww", "ww", "class", "WARRIOR", "all", "account", "ability_whirlwind", "warrior-core", "hybrid",
          "#showtooltip Whirlwind\n/cast [nostance:3] Berserker Stance\n/cast Whirlwind\n/startattack",
          "Enters Berserker Stance. A stance change can require a second press."),
        M("w-ex", "ex", "class", "WARRIOR", "all", "account", "inv_sword_48", "warrior-core", "hybrid",
          "#showtooltip Execute\n/cast [stance:2] Battle Stance\n/cast Execute\n/startattack",
          "Leaves Defensive Stance because Execute requires Battle or Berserker Stance."),
        M("w-o", "o", "class", "WARRIOR", "all", "account", "ability_meleedamage", "warrior-core", "hybrid",
          "#showtooltip Overpower\n/cast [nostance:1] Battle Stance\n/cast Overpower\n/startattack",
          "Enters Battle Stance. A stance change can require a second press."),
        M("w-rend", "rend", "class", "WARRIOR", "all", "account", "ability_gouge", "warrior-core", "hybrid",
          "#showtooltip Rend\n/cast [stance:3] Battle Stance\n/cast Rend\n/startattack",
          "Leaves Berserker Stance because Rend requires Battle or Defensive Stance."),
        M("w-s", "s", "class", "WARRIOR", "all", "account", "ability_warrior_sunder", "warrior-core", "hybrid",
          "#showtooltip Sunder Armor\n/startattack\n/cast [target=mouseover,harm,nodead][] Sunder Armor",
          "Uses a hostile living mouseover, then the current target. Useful for multi-target tanking."),
        M("w-slam", "sl", "class", "WARRIOR", "all", "account", "ability_warrior_decisivestrike", "warrior-core", "plan",
          "#showtooltip Slam\n/cast [stance:2] Battle Stance\n/startattack\n/cast Slam",
          "Trainer-taught filler. TBC uses it on the baseline bar. Leaves Defensive Stance.", gameVersion="TBC"),
        M("w-interrupt", "wkick", "class", "WARRIOR", "all", "account", "inv_gauntlets_04", "warrior-core", "plan",
          "#showtooltip [stance:3] Pummel; [equipped:Shields] Shield Bash; Pummel\n/stopcasting\n/startattack\n/cast [noequipped:Shields,nostance:3] Berserker Stance\n/cast [stance:3] Pummel; [equipped:Shields] Shield Bash",
          "One interrupt replaces separate Pummel and Shield Bash copies. It uses Shield Bash with a shield; otherwise it enters Berserker and uses Pummel."),
        M("w-major-cd", "major", "class", "WARRIOR", "all", "account", "ability_warrior_challange", "warrior-core", "plan",
          "#showtooltip\n/cast [stance:1] Retaliation; [stance:2] Shield Wall; Recklessness",
          "One major cooldown key. The current stance selects the spell."),
        M("w-taunt", "a", "class", "WARRIOR", "all", "account", "spell_nature_reincarnation", "warrior-core", "hybrid",
          "#showtooltip Taunt\n/cast [nostance:2] Defensive Stance\n/cast [target=mouseover,harm,nodead][] Taunt",
          "Uses a hostile living mouseover, then the current target."),
        M("w-shout", "bshout", "class", "WARRIOR", "all", "account", "ability_warrior_battleshout", "warrior-core", "hybrid",
          "#showtooltip [mod:shift] Demoralizing Shout; Battle Shout\n/cast [mod:shift] Demoralizing Shout; Battle Shout",
          "Battle Shout normally. Shift uses Demoralizing Shout."),
        M("w-ds", "ds", "class", "WARRIOR", "all", "account", "ability_warrior_warcry", "warrior-core", "existing",
          "#showtooltip Demoralizing Shout\n/cast Demoralizing Shout\n/startattack",
          "Dedicated Demoralizing Shout copy; `w-shout` also provides Demoralizing Shout on Shift."),
        M("w-hm", "hm", "class", "WARRIOR", "all", "account", "ability_shockwave", "warrior-core", "hybrid",
          "#showtooltip Hamstring\n/cast [stance:2] Battle Stance\n/cast Hamstring\n/startattack",
          "Leaves Defensive Stance because Hamstring requires Battle or Berserker Stance."),
        M("w-disarm", "disarm", "class", "WARRIOR", "all", "account", "ability_warrior_disarm", "warrior-core", "hybrid",
          "#showtooltip Disarm\n/startattack\n/cast [nostance:2] Defensive Stance\n/cast Disarm"),
        M("w-intimid", "is", "class", "WARRIOR", "all", "account", "ability_golemthunderclap", "warrior-core", "plan",
          "#showtooltip Intimidating Shout\n/cast Intimidating Shout\n/stopattack",
          "Stops auto-attack so the primary target is not hit immediately after the fear."),
        M("w-revenge", "rev", "class", "WARRIOR", "all", "account", "ability_warrior_revenge", "warrior-core", "plan",
          "#showtooltip Revenge\n/cast [nostance:2] Defensive Stance\n/cast Revenge\n/startattack"),
        M("w-sblock", "sbk", "class", "WARRIOR", "all", "account", "ability_defend", "warrior-core", "plan",
          "#showtooltip Shield Block\n/cast [nostance:2] Defensive Stance\n/cast Shield Block"),
        M("w-mock", "mb", "class", "WARRIOR", "all", "account", "ability_warrior_punishingblow", "warrior-core", "plan",
          "#showtooltip Mocking Blow\n/cast [nostance:1] Battle Stance\n/cast [target=mouseover,harm,nodead][] Mocking Blow",
          "Uses a hostile living mouseover, then the current target."),
        M("w-chall", "ch", "class", "WARRIOR", "all", "account", "ability_bullrush", "warrior-core", "plan",
          "#showtooltip Challenging Shout\n/cast Challenging Shout\n/startattack"),
        M("w-tc", "tc", "class", "WARRIOR", "all", "account", "spell_nature_thunderclap", "warrior-core", "plan",
          "#showtooltip Thunder Clap\n/cast [nostance:1] Battle Stance\n/cast Thunder Clap"),
        M("w-retal", "ret", "class", "WARRIOR", "all", "account", "ability_warrior_challange", "warrior-core", "plan",
          "#showtooltip Retaliation\n/cast [nostance:1] Battle Stance\n/cast Retaliation"),
        M("w-reck", "rk", "class", "WARRIOR", "all", "account", "ability_criticalstrike", "warrior-core", "plan",
          "#showtooltip Recklessness\n/cast [nostance:3] Berserker Stance\n/cast Recklessness"),
        M("w-sw", "sw", "class", "WARRIOR", "all", "account", "ability_warrior_shieldwall", "warrior-core", "hybrid",
          "#showtooltip Shield Wall\n/cast [nostance:2] Defensive Stance\n/cast Shield Wall",
          "Requires an equipped shield. Named equip copies stay in the gear kit."),
    ],
)

add(
    {
        "id": "warrior-arms",
        "title": "Warrior Arms",
        "class": "WARRIOR",
        "spec": "arms",
        "tab": "character",
        "description": "Only active abilities unlocked by Arms talents.",
    },
    [
        M("w-sweep", "ss", "class", "WARRIOR", "arms", "character", "ability_rogue_slicedice", "warrior-arms", "plan",
          "#showtooltip Sweeping Strikes\n/cast [nostance:1] Battle Stance\n/cast Sweeping Strikes"),
        M("w-ms", "ms", "class", "WARRIOR", "arms", "character", "ability_warrior_savageblow", "warrior-arms", "existing",
          "#showtooltip Mortal Strike\n/cast Mortal Strike\n/startattack"),
    ],
)

add(
    {
        "id": "warrior-fury",
        "title": "Warrior Fury",
        "class": "WARRIOR",
        "spec": "fury",
        "tab": "character",
        "description": "Useful macros for Fury talent abilities. Piercing Howl needs no wrapper; drag the spell itself to an unmanaged slot.",
    },
    [
        M("w-deathwish", "dwish", "class", "WARRIOR", "fury", "character", "spell_shadow_deathpact", "warrior-fury", "plan",
          "#showtooltip Death Wish\n/cast Death Wish\n/startattack"),
        M("w-bt", "bt", "class", "WARRIOR", "fury", "character", "spell_nature_bloodlust", "warrior-fury", "existing",
          "#showtooltip Bloodthirst\n/cast Bloodthirst\n/startattack"),
    ],
)

add(
    {
        "id": "warrior-prot",
        "title": "Warrior Protection",
        "class": "WARRIOR",
        "spec": "protection",
        "tab": "character",
        "description": "Only active abilities unlocked by Protection talents. A Fury/Protection build usually adds only Last Stand; Concussion Blow and Shield Slam require deeper Protection talents.",
    },
    [
        M("w-ls", "ls", "class", "WARRIOR", "protection", "character", "spell_holy_ashestoashes", "warrior-prot", "plan",
          "#showtooltip Last Stand\n/stopcasting\n/cast Last Stand",
          "Stops a cast or queued spell so the emergency defensive can fire immediately."),
        M("w-concussion", "cb", "class", "WARRIOR", "protection", "character", "ability_thunderbolt", "warrior-prot", "plan",
          "#showtooltip Concussion Blow\n/startattack\n/cast Concussion Blow"),
        M("w-sslam", "ssl", "class", "WARRIOR", "protection", "character", "inv_shield_05", "warrior-prot", "plan",
          "#showtooltip Shield Slam\n/startattack\n/cast Shield Slam"),
    ],
)

add(
    {
        "id": "warrior-gear",
        "title": "Tazzy gear kit",
        "class": "WARRIOR",
        "spec": "all",
        "tab": "character",
        "scope": "character",
        "character": "Tazzy",
        "description": "Character-specific Nightslayer Tazzy cooldown and equipment macros. Swap this group when the gear kit changes.",
    },
    [
        M("w-dfdw", "dfdw", "character", "WARRIOR", "fury", "character", "inv_potion_69", "warrior-gear", "existing",
          "/use Diamond Flask\n/cast Death Wish",
          "Uses Diamond Flask, then Death Wish. The flask can consume the first press; press again after the global cooldown.", toon="Tazzy"),
        M("w-dual", "dual", "character", "WARRIOR", "all", "character", "inv_sword_39", "warrior-gear", "existing",
          "/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 Mirah's Song",
          "Cancels a queued attack, then equips the dual-wield threat set.", toon="Tazzy"),
        M("w-dw", "dw", "character", "WARRIOR", "fury", "character", "inv_axe_10", "warrior-gear", "existing",
          "/equipslot 16 Guillotine Axe\n/equipslot 17 Butcher's Cleaver", toon="Tazzy"),
        M("w-sh-qs", "shqs", "character", "WARRIOR", "all", "character", "inv_shield_04", "warrior-gear", "existing",
          "/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 Buru's Skull Fragment",
          "Cancels a queued attack, then equips the alternate shield set. The one-handed weapon goes on before the shield.", toon="Tazzy"),
        M("w-shh", "shh", "character", "WARRIOR", "all", "character", "inv_shield_06", "warrior-gear", "existing",
          "/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 The Immovable Object",
          "Cancels a queued attack, then equips the mitigation shield set.", toon="Tazzy"),
        M("w-th", "th", "character", "WARRIOR", "all", "character", "inv_sword_20", "warrior-gear", "existing",
          "/equip Archeus", toon="Tazzy"),
        M("w-sb-item", "sbitm", "character", "WARRIOR", "protection", "character", "ability_warrior_shieldbash", "warrior-gear", "existing",
          "#showtooltip Shield Bash\n/equip Commander's Crest\n/equip Hillborne Axe of Agility\n/cast Defensive Stance\n/cast Shield Bash\n/startattack", toon="Tazzy"),
        M("w-sd-item", "sd", "character", "WARRIOR", "all", "character", "ability_warrior_shieldwall", "warrior-gear", "existing",
          "#showtooltip Shield Wall\n/stopcasting\n/equipslot 16 Quel'Serrar\n/equipslot 17 The Immovable Object\n/cast [nostance:2] Defensive Stance\n/cast Shield Wall",
          "Cancels a queued attack, equips the mitigation set, enters Defensive Stance, then uses Shield Wall. Combat swaps can require repeated presses.", toon="Tazzy"),
        M("w-sw-item", "switm", "character", "WARRIOR", "protection", "character", "ability_warrior_shieldwall", "warrior-gear", "existing",
          "#showtooltip Shield Wall\n/equip Black Metal Shortsword\n/equip Gold-plated Buckler\n/cast Defensive Stance\n/cast Shield Wall\n/startattack", toon="Tazzy"),
        M("w-tankdw", "tankdw", "character", "WARRIOR", "protection", "account", "inv_mace_15", "warrior-gear", "existing",
          "/equipslot 16 Hammer of Righteous Judgement\n/equipslot 17 Vampiric Boot Knife", toon="Tazzy"),
        M("w-dual-acc", "dualacc", "character", "WARRIOR", "all", "account", "inv_sword_36", "warrior-gear", "existing",
          "/equipslot 16 Outlaw Sabre\n/equipslot 17 Vampiric Boot Knife", toon="Tazzy"),
    ],
)

# ---------------------------------------------------------------------------
# Mage
# ---------------------------------------------------------------------------
add(
    {
        "id": "mage-filler",
        "title": "Mage filler",
        "class": "MAGE",
        "spec": "all",
        "tab": "account",
        "description": "Existing Currentz fillers. /cqs and [nomod]/[mod:shift] downranks stay.",
    },
    [
        M("m-fb", "f", "class", "MAGE", "frost", "account", "spell_frost_frostbolt02", "mage-filler", "existing",
          "#showtooltip [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)\n/cqs\n/cast [nomod]Frostbolt;[mod:shift]Frostbolt(rank 1)"),
        M("m-fireball", "fb", "class", "MAGE", "fire", "account", "spell_fire_flamebolt", "mage-filler", "existing",
          "#showtooltip [mod:shift] Combustion; Fireball\n/cqs\n/cast [mod:shift] Combustion\n/use [mod:shift] Mind Quickening Gem\n/use [mod:shift] Talisman of Ephemeral Power\n/use [mod:shift] Zandalarian Hero Charm\n/cast Fireball;"),
        M("m-blast", "'", "class", "MAGE", "fire", "account", "spell_fire_fireball", "mage-filler", "existing",
          "#showtooltip [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)\n/cast [nomod]Fire Blast;[mod:shift]Fire Blast(rank 1)"),
        M("m-ae", "ae", "class", "MAGE", "arcane", "account", "spell_nature_wispsplode", "mage-filler", "existing",
          "#showtooltip [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)\n/cast [nomod]Arcane Explosion;[mod:shift]Arcane Explosion(rank 1)"),
        M("m-am", "am", "class", "MAGE", "arcane", "account", "spell_nature_starfall", "mage-filler", "existing",
          "#showtooltip Arcane Missiles\n/cast [nochanneling:Arcane Missiles] Arcane Missiles"),
        M("m-blizz", "Blizz", "class", "MAGE", "frost", "account", "spell_frost_icestorm", "mage-filler", "existing",
          "#showtooltip [nomod]Blizzard;[mod:shift]Blizzard(rank 1)\n/cast [nomod]Blizzard;[mod:shift]Blizzard(rank 1)"),
        M("m-cone", "cone", "class", "MAGE", "frost", "account", "spell_frost_glacier", "mage-filler", "existing",
          "#showtooltip [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)\n/cast [nomod]Cone of Cold;[mod:shift]Cone of Cold(rank 1)"),
        M("m-fs", "fs", "class", "MAGE", "fire", "account", "spell_fire_selfdestruct", "mage-filler", "existing",
          "#showtooltip [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike\n/use [mod:alt] Talisman of Ephemeral Power\n/use [mod:alt] Zandalarian Hero Charm\n/cast [mod:alt] Arcane Power\n/cast [mod:shift,@cursor] Flamestrike(Rank 5); [@cursor] Flamestrike"),
        M("m-scorch", "sc", "class", "MAGE", "fire", "account", "spell_fire_soulburn", "mage-filler", "plan",
          "#showtooltip Scorch\n/cqs\n/cast Scorch"),
        M("m-pyro", "py", "class", "MAGE", "fire", "account", "spell_fire_fireball02", "mage-filler", "plan",
          "#showtooltip Pyroblast\n/cast Presence of Mind\n/cast Pyroblast"),
        M("m-shoot", "shoot", "class", "MAGE", "all", "account", "ability_shootwand", "mage-filler", "plan",
          "#showtooltip Shoot\n/cast Shoot"),
    ],
)

add(
    {
        "id": "mage-currentz",
        "title": "Currentz kit",
        "class": "MAGE",
        "spec": "all",
        "tab": "account",
        "scope": "character",
        "character": "Currentz",
        "description": "Character-specific Currentz. Touch of Chaos wand and named Naxx shells. Generic Shoot stays in mage-filler.",
    },
    [
        M("m-wand", "shadow", "character", "MAGE", "all", "account", "spell_shadow_shadowbolt", "mage-currentz", "existing",
          "#showtooltip\n/equip Touch of Chaos\n/cast shoot", toon="Currentz"),
        M("m-prot", "prot", "character", "MAGE", "all", "account", "inv_misc_ahnqirajtrinket_06", "mage-currentz", "existing",
          "#showtooltip\n/use The Burrower's Shell\n/use Loatheb's Reflection",
          "Named items. Edit names if another toon uses different shells.", toon="Currentz"),
    ],
)

add(
    {
        "id": "mage-control",
        "title": "Mage control",
        "class": "MAGE",
        "spec": "all",
        "tab": "account",
        "description": "Kicks, sheep, block, decurse. Existing bodies win.",
    },
    [
        M("m-cs", "CS", "class", "MAGE", "all", "account", "spell_frost_iceshock", "mage-control", "existing",
          "#showtooltip\n/stopcasting\n#/cast [target=mouseover,exists] Counterspell\n/cast Counterspell",
          "Mouseover stays commented, as on disk."),
        M("m-cs-focus", "CSf", "class", "MAGE", "all", "account", "spell_frost_iceshock", "mage-control", "plan",
          "#showtooltip Counterspell\n/stopcasting\n/cast [target=focus,harm,nodead] Counterspell; Counterspell"),
        M("m-sheep", "sheep", "class", "MAGE", "all", "account", "spell_nature_polymorph", "mage-control", "existing",
          "#showtooltip [nomod]Polymorph;[mod:shift]Polymorph(rank 1)\n/cast [nomod]Polymorph;[mod:shift]Polymorph(rank 1)"),
        M("m-decurse", "decurse", "class", "MAGE", "all", "account", "spell_nature_removecurse", "mage-control", "existing",
          "#showtooltip Remove Lesser Curse\n/cast [target=mouseover,exists] Remove Lesser Curse\n/cast Remove Lesser Curse"),
        M("m-ib", "ib", "class", "MAGE", "frost", "account", "spell_frost_frost", "mage-control", "existing",
          "#showtooltip Ice block\n/stopcasting\n/cast Ice block\n/cancelaura Ice block"),
        M("m-ms", "MS", "class", "MAGE", "all", "account", "spell_shadow_detectlesserinvisibility", "mage-control", "existing",
          "#showtooltip\n/stopcasting\n/cast mana shield"),
        M("m-nova", "fn", "class", "MAGE", "frost", "account", "spell_frost_frostnova", "mage-control", "plan",
          "#showtooltip [mod:shift] Frost Nova; Frost Nova(rank 1)\n/cast [mod:shift] Frost Nova; Frost Nova(rank 1)"),
        M("m-blink", "blink", "class", "MAGE", "all", "account", "spell_arcane_blink", "mage-control", "plan",
          "#showtooltip Blink\n/cast Blink"),
        M("m-evo", "evo", "class", "MAGE", "all", "account", "spell_nature_purge", "mage-control", "plan",
          "#showtooltip Evocation\n/cast Evocation"),
        M("m-barrier", "iba", "class", "MAGE", "frost", "account", "spell_ice_lament", "mage-control", "plan",
          "#showtooltip Ice Barrier\n/cast Ice Barrier"),
        M("m-ward", "ward", "class", "MAGE", "all", "account", "spell_frost_frostward", "mage-control", "plan",
          "#showtooltip [mod:shift] Fire Ward; Frost Ward\n/cast [mod:shift] Fire Ward; Frost Ward"),
        M("m-slowfall", "slowfall", "class", "MAGE", "all", "account", "spell_magic_featherfall", "mage-control", "plan",
          "#showtooltip Slow Fall\n/cast [mod:alt,target=player] Slow Fall; Slow Fall"),
        M("m-dampen", "dm", "class", "MAGE", "all", "account", "spell_nature_abolishmagic", "mage-control", "plan",
          "#showtooltip [mod:shift] Amplify Magic; Dampen Magic\n/cast [mod:shift] Amplify Magic; Dampen Magic"),
        M("m-csnap", "snap", "class", "MAGE", "frost", "account", "spell_frost_wizardmark", "mage-control", "plan",
          "#showtooltip Cold Snap\n/cast Cold Snap"),
        M("m-nef", "nef", "class", "MAGE", "fire", "account", "spell_holy_excorcism_02", "mage-control", "existing",
          "/use [@cursor] Stratholme Holy Water\n/cast Blast Wave"),
    ],
)

add(
    {
        "id": "mage-burst",
        "title": "Mage burst",
        "class": "MAGE",
        "spec": "frost",
        "tab": "account",
        "description": "Existing SpellQueueWindow + trinket + PoM set. Do not shorten.",
    },
    [
        M("m-appom", "ap + PoM", "class", "MAGE", "arcane", "account", "spell_nature_enchantarmor", "mage-burst", "existing",
          "/run local _,_,lagHome = GetNetStats() s = lagHome * 2\n/console SpellQueueWindow s\n/cast !Presence of Mind\n/use [mod:shift]Zandalarian Hero Charm\n/use [mod:shift]Talisman of Ephemeral Power\n/cast !Arcane Power\n/cast Frostbolt"),
        M("m-pomfb", "PoM + fb", "class", "MAGE", "frost", "account", "spell_nature_enchantarmor", "mage-burst", "existing",
          "/run local _,_,lagHome = GetNetStats() s = lagHome * 2\n/console SpellQueueWindow s\n/cast !Presence of Mind\n/use [mod:shift]Zandalarian Hero Charm\n/use [mod:shift]Talisman of Ephemeral Power\n/cast Frostbolt"),
        M("m-mqg", "mqg", "class", "MAGE", "frost", "account", "inv_misc_gem_stone_01", "mage-burst", "existing",
          "/run local _,_,lagHome = GetNetStats() s = lagHome * 2\n/console SpellQueueWindow s\n/use Mind Quickening Gem\n/cast Frostbolt"),
        M("m-toep", "toep +fb", "class", "MAGE", "frost", "account", "inv_misc_stonetablet_11", "mage-burst", "existing",
          "/run local _,_,lagHome = GetNetStats() s = lagHome * 2\n/console SpellQueueWindow s\n/use Talisman of Ephemeral Power\n/cast Frostbolt;[mod:shift]"),
        M("m-zhc", "zhc", "class", "MAGE", "frost", "account", "inv_jewelry_necklace_13", "mage-burst", "existing",
          "/run local _,_,lagHome = GetNetStats() s = lagHome * 2\n/console SpellQueueWindow s\n/use item:19950\n/cast Frostbolt;[mod:shift]"),
        M("m-ap", "ap", "class", "MAGE", "arcane", "account", "spell_nature_enchantarmor", "mage-burst", "plan",
          "#showtooltip Arcane Power\n/cast Arcane Power"),
        M("m-comb", "comb", "class", "MAGE", "fire", "account", "spell_fire_sealoffire", "mage-burst", "plan",
          "#showtooltip Combustion\n/cast Combustion"),
    ],
)

add(
    {
        "id": "mage-ports-alliance",
        "title": "Mage ports Alliance",
        "class": "MAGE",
        "spec": "all",
        "tab": "character",
        "description": "Existing Currentz IF/SW plus Darnassus from the plan. Shift = portal.",
    },
    [
        M("m-sw", "portsw", "class", "MAGE", "all", "character", "spell_arcane_teleportstormwind", "mage-ports-alliance", "existing",
          "#showtooltip [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind\n/cast [nomod] Teleport: Stormwind; [mod:shift] Portal: Stormwind"),
        M("m-if", "if", "class", "MAGE", "all", "character", "spell_arcane_teleportironforge", "mage-ports-alliance", "existing",
          "#showtooltip [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge\n/cast [nomod] Teleport: Ironforge; [mod:shift] Portal: Ironforge"),
        M("m-dar", "dar", "class", "MAGE", "all", "character", "spell_arcane_teleportdarnassus", "mage-ports-alliance", "plan",
          "#showtooltip [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus\n/cast [nomod] Teleport: Darnassus; [mod:shift] Portal: Darnassus"),
        M("m-water", "water", "class", "MAGE", "all", "character", "inv_drink_18", "mage-ports-alliance", "plan",
          "#showtooltip Conjure Water\n/cast Conjure Water"),
        M("m-food", "food", "class", "MAGE", "all", "character", "inv_misc_food_73cinnamonroll", "mage-ports-alliance", "plan",
          "#showtooltip Conjure Food\n/cast Conjure Food"),
        M("m-gem", "gem", "class", "MAGE", "all", "character", "inv_misc_gem_ruby_01", "mage-ports-alliance", "plan",
          "#showtooltip Mana Ruby\n/use Mana Ruby"),
        M("m-armor", "arm", "class", "MAGE", "all", "character", "spell_frost_frostarmor02", "mage-ports-alliance", "plan",
          "#showtooltip\n/cast [mod:shift] Mage Armor; Ice Armor"),
    ],
)

add(
    {
        "id": "mage-ports-horde",
        "title": "Mage ports Horde",
        "class": "MAGE",
        "spec": "all",
        "tab": "account",
        "description": "Existing WARKEYS Orgrimmar / Undercity / Thunder Bluff.",
    },
    [
        M("m-org", "org", "class", "MAGE", "all", "account", "spell_arcane_teleportorgrimmar", "mage-ports-horde", "existing",
          "#showtooltip [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar\n/cast [nomod] Teleport: Orgrimmar; [mod:shift] Portal: Orgrimmar"),
        M("m-uc", "uc", "class", "MAGE", "all", "account", "spell_arcane_teleportundercity", "mage-ports-horde", "existing",
          "#showtooltip [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity\n/cast [nomod] Teleport: Undercity; [mod:shift] Portal: Undercity"),
        M("m-tb", "tb", "class", "MAGE", "all", "account", "spell_arcane_teleportthunderbluff", "mage-ports-horde", "existing",
          "#showtooltip [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff\n/cast [nomod] Teleport: Thunder bluff; [mod:shift] Portal: Thunder bluff"),
    ],
)

# ---------------------------------------------------------------------------
# Paladin
# ---------------------------------------------------------------------------
add(
    {
        "id": "paladin-ret",
        "title": "Paladin Retribution",
        "class": "PALADIN",
        "spec": "retribution",
        "tab": "character",
        "description": "Alliance Era ret. Seal + judge + stun + consecrate.",
    },
    [
        M("p-judge", "judge", "class", "PALADIN", "retribution", "character", "spell_holy_righteousfury", "paladin-ret", "plan",
          "#showtooltip Judgement\n/startattack\n/cast Judgement"),
        M("p-seal", "seal", "class", "PALADIN", "retribution", "character", "ability_thunderbolt", "paladin-ret", "plan",
          "#showtooltip\n/cast [mod:shift] Seal of Command; Seal of Righteousness"),
        M("p-hoj", "hoj", "class", "PALADIN", "all", "character", "spell_holy_sealofmight", "paladin-ret", "plan",
          "#showtooltip Hammer of Justice\n/stopcasting\n/cast Hammer of Justice"),
        M("p-cons", "cons", "class", "PALADIN", "all", "character", "spell_holy_innerfire", "paladin-ret", "plan",
          "#showtooltip\n/cast [mod:shift] Consecration(Rank 1); Consecration"),
        M("p-how", "how", "class", "PALADIN", "all", "character", "ability_thunderclap", "paladin-ret", "plan",
          "#showtooltip Hammer of Wrath\n/cast Hammer of Wrath"),
        M("p-exo", "exo", "class", "PALADIN", "retribution", "character", "spell_holy_excorcism_02", "paladin-ret", "plan",
          "#showtooltip Exorcism\n/cast Exorcism"),
        M("p-rep", "rep", "class", "PALADIN", "retribution", "character", "spell_holy_prayerofhealing", "paladin-ret", "plan",
          "#showtooltip Repentance\n/stopcasting\n/cast Repentance"),
        M("p-bubble", "bubble", "class", "PALADIN", "all", "character", "spell_holy_divineintervention", "paladin-ret", "plan",
          "#showtooltip Divine Shield\n/cast Divine Shield"),
        M("p-cancel-ds", "cds", "class", "PALADIN", "all", "character", "spell_holy_divineintervention", "paladin-ret", "plan",
          "/cancelaura Divine Shield"),
        M("p-bop", "bop", "class", "PALADIN", "all", "character", "spell_holy_sealofprotection", "paladin-ret", "plan",
          "#showtooltip Blessing of Protection\n/cast Blessing of Protection"),
        M("p-cleanse", "cl", "class", "PALADIN", "all", "character", "spell_holy_purify", "paladin-ret", "hybrid",
          "#showtooltip Cleanse\n/cast [mod:alt,target=player] Cleanse; [target=mouseover,exists] Cleanse; Cleanse"),
        M("p-fol", "fol", "class", "PALADIN", "holy", "character", "spell_holy_flashheal", "paladin-ret", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Flash of Light; [mod:shift] Flash of Light(Rank 4); [mod:ctrl] Flash of Light(Rank 1); Flash of Light"),
        M("p-might", "bom", "class", "PALADIN", "all", "character", "spell_holy_fistofjustice", "paladin-ret", "plan",
          "#showtooltip\n/cast [mod:shift] Blessing of Salvation; [mod:ctrl] Blessing of Wisdom; Blessing of Might"),
        M("p-aura", "aura", "class", "PALADIN", "all", "character", "spell_holy_devotionaura", "paladin-ret", "plan",
          "#showtooltip\n/cast [mod:shift] Devotion Aura; [mod:ctrl] Retribution Aura; Concentration Aura"),
        M("p-rf", "rf", "class", "PALADIN", "protection", "character", "spell_holy_sealoffury", "paladin-ret", "plan",
          "#showtooltip Righteous Fury\n/cast Righteous Fury"),
        M("p-hs", "hsh", "class", "PALADIN", "protection", "character", "spell_holy_blessingofprotection", "paladin-ret", "plan",
          "#showtooltip Holy Shield\n/cast Holy Shield"),
        M("p-loh", "loh", "class", "PALADIN", "holy", "character", "spell_holy_layonhands", "paladin-ret", "plan",
          "#showtooltip Lay on Hands\n/raid Lay on Hands on %t\n/cast Lay on Hands"),
        M("p-di", "di", "class", "PALADIN", "all", "character", "spell_nature_timestop", "paladin-ret", "plan",
          "#showtooltip Divine Intervention\n/raid DI on %t\n/cast Divine Intervention"),
    ],
)

add(
    {
        "id": "paladin-holy",
        "title": "Paladin Holy",
        "class": "PALADIN",
        "spec": "holy",
        "tab": "character",
        "description": "Heals. Alt self. Shift cheap rank.",
    },
    [
        M("p-hl", "hl", "class", "PALADIN", "holy", "character", "spell_holy_holybolt", "paladin-holy", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Holy Light; [mod:shift] Holy Light(Rank 1); Holy Light"),
        M("p-df", "df", "class", "PALADIN", "holy", "character", "spell_holy_flashheal", "paladin-holy", "plan",
          "#showtooltip Flash of Light\n/cast Divine Favor\n/cast Flash of Light"),
        M("p-shock", "hsk", "class", "PALADIN", "holy", "character", "spell_holy_searinglight", "paladin-holy", "plan",
          "#showtooltip Holy Shock\n/cast Holy Shock"),
        M("p-seal-h", "sealh", "class", "PALADIN", "holy", "character", "spell_holy_righteousnessaura", "paladin-holy", "plan",
          "#showtooltip\n/cast [mod:shift] Seal of Light; Seal of Wisdom"),
        M("p-mount", "chg", "class", "PALADIN", "all", "character", "spell_nature_swiftness", "paladin-holy", "plan",
          "#showtooltip\n/cast [mod:shift] Summon Warhorse; Summon Charger"),
    ],
)

# ---------------------------------------------------------------------------
# Hunter
# ---------------------------------------------------------------------------
add(
    {
        "id": "hunter-core",
        "title": "Hunter core",
        "class": "HUNTER",
        "spec": "all",
        "tab": "character",
        "description": "Mark, shots, Feign Death, pet. 18 or fewer.",
    },
    [
        M("h-mark", "hmark", "class", "HUNTER", "all", "character", "ability_hunter_snipershot", "hunter-core", "plan",
          "#showtooltip Hunter's Mark\n/cast Hunter's Mark"),
        M("h-aspect", "asp", "class", "HUNTER", "all", "character", "spell_nature_ravenform", "hunter-core", "plan",
          "#showtooltip\n/cast [mod:shift] Aspect of the Monkey; Aspect of the Hawk"),
        M("h-aimed", "as", "class", "HUNTER", "marksmanship", "character", "inv_spear_07", "hunter-core", "plan",
          "#showtooltip Aimed Shot\n/cast Aimed Shot"),
        M("h-multi", "multi", "class", "HUNTER", "marksmanship", "character", "ability_upgrademoonglaive", "hunter-core", "plan",
          "#showtooltip Multi-Shot\n/cast Multi-Shot"),
        M("h-arcane", "arc", "class", "HUNTER", "all", "character", "ability_impalingbolt", "hunter-core", "plan",
          "#showtooltip\n/cast [mod:shift] Arcane Shot(Rank 1); Arcane Shot"),
        M("h-sting", "sting", "class", "HUNTER", "all", "character", "ability_hunter_quickshot", "hunter-core", "plan",
          "#showtooltip Serpent Sting\n/cast Serpent Sting"),
        M("h-conc", "conc", "class", "HUNTER", "all", "character", "spell_frost_stun", "hunter-core", "plan",
          "#showtooltip Concussive Shot\n/cast Concussive Shot"),
        M("h-clip", "wc", "class", "HUNTER", "all", "character", "ability_rogue_trip", "hunter-core", "plan",
          "#showtooltip\n/cast [mod:shift] Wing Clip(Rank 1); Wing Clip"),
        M("h-fd", "fd", "class", "HUNTER", "all", "character", "ability_rogue_feigndeath", "hunter-core", "plan",
          "#showtooltip Feign Death\n/stopattack\n/stopcasting\n/cast Feign Death"),
        M("h-trap", "ft", "class", "HUNTER", "all", "character", "spell_frost_chainsofice", "hunter-core", "plan",
          "#showtooltip Freezing Trap\n/cast Freezing Trap"),
        M("h-rapid", "rapid", "class", "HUNTER", "marksmanship", "character", "ability_hunter_runningshot", "hunter-core", "plan",
          "#showtooltip Rapid Fire\n/use 13\n/cast Rapid Fire"),
        M("h-tranq", "tq", "class", "HUNTER", "all", "character", "spell_nature_drowsy", "hunter-core", "plan",
          "#showtooltip Tranquilizing Shot\n/cast Tranquilizing Shot"),
        M("h-mend", "mp", "class", "HUNTER", "beast-mastery", "character", "ability_hunter_mendpet", "hunter-core", "plan",
          "#showtooltip Mend Pet\n/cast Mend Pet"),
        M("h-call", "pet", "class", "HUNTER", "beast-mastery", "character", "ability_hunter_beastcall", "hunter-core", "plan",
          "#showtooltip Call Pet\n/cast Call Pet"),
        M("h-bw", "bw", "class", "HUNTER", "beast-mastery", "character", "ability_druid_ferociousbite", "hunter-core", "plan",
          "#showtooltip Bestial Wrath\n/cast Bestial Wrath"),
        M("h-cheetah", "cheetah", "class", "HUNTER", "all", "character", "ability_mount_jungletiger", "hunter-core", "plan",
          "#showtooltip Aspect of the Cheetah\n/cast Aspect of the Cheetah"),
    ],
)

add(
    {
        "id": "hunter-auden",
        "title": "Auden pet kit",
        "class": "HUNTER",
        "spec": "beast-mastery",
        "tab": "account",
        "scope": "character",
        "character": "Auden",
        "description": "Character-specific Auden. Worg Carrier from the 372399535 account.",
    },
    [
        M("h-worg", "worg", "character", "HUNTER", "beast-mastery", "account", "ability_hunter_beastcall", "hunter-auden", "existing",
          "#showtooltip\n/cast Call Pet\n/use Worg Carrier", toon="Auden"),
    ],
)

# ---------------------------------------------------------------------------
# Rogue
# ---------------------------------------------------------------------------
add(
    {
        "id": "rogue-combat",
        "title": "Rogue Combat",
        "class": "ROGUE",
        "spec": "combat",
        "tab": "character",
        "description": "Openers, Kick, finishers. /startattack on builders.",
    },
    [
        M("r-stealth", "st", "class", "ROGUE", "all", "character", "ability_stealth", "rogue-combat", "plan",
          "#showtooltip Stealth\n/cast Stealth"),
        M("r-ss", "sinister", "class", "ROGUE", "combat", "character", "spell_shadow_ritualofsacrifice", "rogue-combat", "plan",
          "#showtooltip Sinister Strike\n/startattack\n/cast Sinister Strike"),
        M("r-kick", "kick", "class", "ROGUE", "all", "character", "ability_kick", "rogue-combat", "plan",
          "#showtooltip Kick\n/stopcasting\n/cast Kick"),
        M("r-evis", "ev", "class", "ROGUE", "all", "character", "ability_rogue_eviscerate", "rogue-combat", "plan",
          "#showtooltip Eviscerate\n/cast Eviscerate"),
        M("r-snd", "snd", "class", "ROGUE", "combat", "character", "ability_rogue_slicedice", "rogue-combat", "plan",
          "#showtooltip Slice and Dice\n/cast Slice and Dice"),
        M("r-rup", "rup", "class", "ROGUE", "assassination", "character", "ability_rogue_rupture", "rogue-combat", "plan",
          "#showtooltip Rupture\n/cast Rupture"),
        M("r-ks", "ks", "class", "ROGUE", "assassination", "character", "ability_rogue_kidneyshot", "rogue-combat", "plan",
          "#showtooltip Kidney Shot\n/cast Kidney Shot"),
        M("r-gouge", "g", "class", "ROGUE", "combat", "character", "ability_gouge", "rogue-combat", "plan",
          "#showtooltip Gouge\n/stopattack\n/cast Gouge"),
        M("r-cheap", "cheap", "class", "ROGUE", "all", "character", "ability_cheapshot", "rogue-combat", "plan",
          "#showtooltip Cheap Shot\n/cast [nostealth] Stealth\n/cast Cheap Shot"),
        M("r-ambush", "ambush", "class", "ROGUE", "assassination", "character", "ability_rogue_ambush", "rogue-combat", "plan",
          "#showtooltip Ambush\n/cast [nostealth] Stealth\n/cast Ambush"),
        M("r-bf", "bf", "class", "ROGUE", "combat", "character", "ability_warrior_punishingblow", "rogue-combat", "plan",
          "#showtooltip Blade Flurry\n/use 13\n/cast Blade Flurry"),
        M("r-ar", "ar", "class", "ROGUE", "combat", "character", "spell_shadow_shadowworddominate", "rogue-combat", "plan",
          "#showtooltip Adrenaline Rush\n/cast Adrenaline Rush"),
        M("r-eva", "eva", "class", "ROGUE", "combat", "character", "spell_shadow_shadowward", "rogue-combat", "plan",
          "#showtooltip Evasion\n/cast Evasion"),
        M("r-vanish", "van", "class", "ROGUE", "subtlety", "character", "ability_vanish", "rogue-combat", "plan",
          "#showtooltip Vanish\n/stopattack\n/cast Vanish"),
        M("r-sprint", "sp", "class", "ROGUE", "all", "character", "ability_rogue_sprint", "rogue-combat", "plan",
          "#showtooltip Sprint\n/cast Sprint"),
        M("r-blind", "blind", "class", "ROGUE", "all", "character", "spell_shadow_mindsteal", "rogue-combat", "plan",
          "#showtooltip Blind\n/cast Blind"),
        M("r-sap", "sap", "class", "ROGUE", "all", "character", "ability_sap", "rogue-combat", "plan",
          "#showtooltip\n/cast [nostealth] Stealth\n/cast [mod:shift] Sap; Pick Pocket"),
        M("r-cb", "coldb", "class", "ROGUE", "assassination", "character", "spell_ice_lament", "rogue-combat", "plan",
          "#showtooltip Eviscerate\n/cast Cold Blood\n/cast Eviscerate"),
    ],
)

# ---------------------------------------------------------------------------
# Priest
# ---------------------------------------------------------------------------
add(
    {
        "id": "priest-holy",
        "title": "Priest Holy / Disc",
        "class": "PRIEST",
        "spec": "holy",
        "tab": "character",
        "description": "Alt self. Shift cheap rank. Ctrl Rank 1. Mouseover on dispel.",
    },
    [
        M("pr-fh", "fh", "class", "PRIEST", "holy", "character", "spell_holy_flashheal", "priest-holy", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Flash Heal; [mod:shift] Flash Heal(Rank 4); [mod:ctrl] Flash Heal(Rank 1); Flash Heal"),
        M("pr-gh", "gh", "class", "PRIEST", "holy", "character", "spell_holy_greaterheal", "priest-holy", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Greater Heal; [mod:shift] Greater Heal(Rank 1); Greater Heal"),
        M("pr-renew", "rn", "class", "PRIEST", "holy", "character", "spell_holy_renew", "priest-holy", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Renew; [mod:shift] Renew(Rank 3); Renew"),
        M("pr-pws", "pws", "class", "PRIEST", "discipline", "character", "spell_holy_powerwordshield", "priest-holy", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Power Word: Shield; [mod:shift] Power Word: Shield(Rank 1); Power Word: Shield"),
        M("pr-poh", "poh", "class", "PRIEST", "holy", "character", "spell_holy_prayerofhealing02", "priest-holy", "plan",
          "#showtooltip Prayer of Healing\n/cast Inner Focus\n/cast Prayer of Healing"),
        M("pr-dispel", "disp", "class", "PRIEST", "discipline", "character", "spell_holy_dispelmagic", "priest-holy", "hybrid",
          "#showtooltip Dispel Magic\n/cast [mod:alt,target=player] Dispel Magic; [target=mouseover,exists] Dispel Magic; Dispel Magic"),
        M("pr-fade", "fade", "class", "PRIEST", "all", "character", "spell_magic_lesserinvisibilty", "priest-holy", "plan",
          "#showtooltip Fade\n/cast Fade"),
        M("pr-scream", "ps", "class", "PRIEST", "shadow", "character", "spell_shadow_psychicscream", "priest-holy", "plan",
          "#showtooltip Psychic Scream\n/cast Psychic Scream"),
        M("pr-fw", "fw", "class", "PRIEST", "discipline", "character", "spell_holy_excorcism", "priest-holy", "plan",
          "#showtooltip Fear Ward\n/raid Fear Ward on %t\n/cast [mod:alt,target=player] Fear Ward; Fear Ward"),
        M("pr-pi", "pi", "class", "PRIEST", "discipline", "character", "spell_holy_powerinfusion", "priest-holy", "plan",
          "#showtooltip Power Infusion\n/raid PI on %t\n/cast [mod:alt,target=player] Power Infusion; Power Infusion"),
        M("pr-fort", "fort", "class", "PRIEST", "discipline", "character", "spell_holy_wordfortitude", "priest-holy", "plan",
          "#showtooltip Power Word: Fortitude\n/cast [mod:alt,target=player] Power Word: Fortitude; Power Word: Fortitude"),
        M("pr-rez", "rez", "class", "PRIEST", "holy", "character", "spell_holy_resurrection", "priest-holy", "plan",
          "#showtooltip Resurrection\n/cast Resurrection"),
        M("pr-if", "ifr", "class", "PRIEST", "discipline", "character", "spell_holy_innerfire", "priest-holy", "plan",
          "#showtooltip Inner Fire\n/cast Inner Fire"),
        M("pr-nova", "hn", "class", "PRIEST", "holy", "character", "spell_holy_holynova", "priest-holy", "plan",
          "#showtooltip\n/cast [mod:shift] Holy Nova(Rank 1); Holy Nova"),
        M("pr-wand", "wand", "class", "PRIEST", "all", "character", "ability_shootwand", "priest-holy", "plan",
          "#showtooltip Shoot\n/cast Shoot"),
        M("pr-abolish", "ad", "class", "PRIEST", "holy", "character", "spell_nature_nullifydisease", "priest-holy", "hybrid",
          "#showtooltip Abolish Disease\n/cast [mod:alt,target=player] Abolish Disease; [target=mouseover,exists] Abolish Disease; Abolish Disease"),
        M("pr-pof", "pof", "class", "PRIEST", "discipline", "character", "spell_holy_prayeroffortitude", "priest-holy", "plan",
          "#showtooltip Prayer of Fortitude\n/cast Prayer of Fortitude"),
        M("pr-spirit", "pos", "class", "PRIEST", "discipline", "character", "spell_holy_prayerofspirit", "priest-holy", "plan",
          "#showtooltip Prayer of Spirit\n/cast Prayer of Spirit"),
    ],
)

add(
    {
        "id": "priest-shadow",
        "title": "Priest Shadow",
        "class": "PRIEST",
        "spec": "shadow",
        "tab": "character",
        "description": "Dots and form. Cancel form to heal.",
    },
    [
        M("pr-swp", "swp", "class", "PRIEST", "shadow", "character", "spell_shadow_shadowwordpain", "priest-shadow", "plan",
          "#showtooltip\n/cast [mod:shift] Shadow Word: Pain(Rank 1); Shadow Word: Pain"),
        M("pr-mf", "mf", "class", "PRIEST", "shadow", "character", "spell_shadow_siphonmana", "priest-shadow", "plan",
          "#showtooltip Mind Flay\n/cast Mind Flay"),
        M("pr-mb", "mblast", "class", "PRIEST", "shadow", "character", "spell_shadow_unholyfrenzy", "priest-shadow", "plan",
          "#showtooltip Mind Blast\n/cast Mind Blast"),
        M("pr-ve", "ve", "class", "PRIEST", "shadow", "character", "spell_shadow_unsummonbuilding", "priest-shadow", "plan",
          "#showtooltip Vampiric Embrace\n/cast Vampiric Embrace"),
        M("pr-sf", "sf", "class", "PRIEST", "shadow", "character", "spell_shadow_shadowform", "priest-shadow", "plan",
          "#showtooltip Shadowform\n/cast Shadowform"),
        M("pr-silence", "sil", "class", "PRIEST", "shadow", "character", "spell_shadow_impphaseshift", "priest-shadow", "plan",
          "#showtooltip Silence\n/stopcasting\n/cast Silence"),
        M("pr-shackle", "shk", "class", "PRIEST", "shadow", "character", "spell_nature_slow", "priest-shadow", "plan",
          "#showtooltip Shackle Undead\n/stopcasting\n/cast Shackle Undead"),
        M("pr-healform", "hf", "class", "PRIEST", "shadow", "character", "spell_holy_flashheal", "priest-shadow", "plan",
          "#showtooltip Flash Heal\n/cancelaura Shadowform\n/cast [mod:alt,target=player] Flash Heal; Flash Heal"),
    ],
)

# ---------------------------------------------------------------------------
# Shaman
# ---------------------------------------------------------------------------
add(
    {
        "id": "shaman-enhance",
        "title": "Shaman Enhancement",
        "class": "SHAMAN",
        "spec": "enhancement",
        "tab": "character",
        "description": "Horde Era. Shock interrupt uses /stopcasting and Rank 1 on Shift.",
    },
    [
        M("s-es", "es", "class", "SHAMAN", "all", "character", "spell_nature_earthshock", "shaman-enhance", "plan",
          "#showtooltip Earth Shock\n/stopcasting\n/cast [mod:shift] Earth Shock(Rank 1); Earth Shock"),
        M("s-shock", "fl", "class", "SHAMAN", "enhancement", "character", "spell_fire_flameshock", "shaman-enhance", "plan",
          "#showtooltip\n/cast [mod:shift] Frost Shock; Flame Shock"),
        M("s-ss", "storm", "class", "SHAMAN", "enhancement", "character", "ability_shaman_stormstrike", "shaman-enhance", "plan",
          "#showtooltip Stormstrike\n/startattack\n/cast Stormstrike"),
        M("s-lb", "lb", "class", "SHAMAN", "elemental", "character", "spell_nature_lightning", "shaman-enhance", "plan",
          "#showtooltip\n/cast [mod:shift] Lightning Bolt(Rank 1); Lightning Bolt"),
        M("s-cl", "chain", "class", "SHAMAN", "elemental", "character", "spell_nature_chainlightning", "shaman-enhance", "plan",
          "#showtooltip Chain Lightning\n/cast Chain Lightning"),
        M("s-ls", "lshield", "class", "SHAMAN", "all", "character", "spell_nature_lightningshield", "shaman-enhance", "plan",
          "#showtooltip Lightning Shield\n/cast Lightning Shield"),
        M("s-wf", "wf", "class", "SHAMAN", "enhancement", "character", "spell_nature_cyclone", "shaman-enhance", "plan",
          "#showtooltip\n/cast [mod:shift] Flametongue Weapon; Windfury Weapon"),
        M("s-lhw", "lhw", "class", "SHAMAN", "restoration", "character", "spell_nature_healingway", "shaman-enhance", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Lesser Healing Wave; [mod:shift] Lesser Healing Wave(Rank 4); [mod:ctrl] Lesser Healing Wave(Rank 1); Lesser Healing Wave"),
        M("s-hw", "hw", "class", "SHAMAN", "restoration", "character", "spell_nature_magicimmunity", "shaman-enhance", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Healing Wave; [mod:shift] Healing Wave(Rank 1); Healing Wave"),
        M("s-ns", "ns", "class", "SHAMAN", "restoration", "character", "spell_nature_ravenform", "shaman-enhance", "plan",
          "#showtooltip Healing Wave\n/cast Nature's Swiftness\n/cast Healing Wave"),
        M("s-purge", "pg", "class", "SHAMAN", "elemental", "character", "spell_nature_purge", "shaman-enhance", "hybrid",
          "#showtooltip Purge\n/cast [target=mouseover,exists] Purge; Purge"),
        M("s-wolf", "gw", "class", "SHAMAN", "all", "character", "spell_nature_spiritwolf", "shaman-enhance", "plan",
          "#showtooltip Ghost Wolf\n/cast Ghost Wolf"),
        M("s-ground", "gt", "class", "SHAMAN", "all", "character", "spell_nature_groundingtotem", "shaman-enhance", "plan",
          "#showtooltip\n/cast [mod:shift] Grounding Totem; Windfury Totem"),
        M("s-tremor", "tt", "class", "SHAMAN", "all", "character", "spell_nature_tremortotem", "shaman-enhance", "plan",
          "#showtooltip Tremor Totem\n/cast Tremor Totem"),
        M("s-mana", "mst", "class", "SHAMAN", "all", "character", "spell_nature_manaregentotem", "shaman-enhance", "plan",
          "#showtooltip Mana Spring Totem\n/cast Mana Spring Totem"),
        M("s-str", "str", "class", "SHAMAN", "enhancement", "character", "spell_nature_earthbindtotem", "shaman-enhance", "plan",
          "#showtooltip Strength of Earth Totem\n/cast Strength of Earth Totem"),
        M("s-tide", "mt", "class", "SHAMAN", "restoration", "character", "spell_frost_summonwaterelemental", "shaman-enhance", "plan",
          "#showtooltip Mana Tide Totem\n/cast Mana Tide Totem"),
        M("s-cure", "cure", "class", "SHAMAN", "restoration", "character", "spell_nature_nullifypoison", "shaman-enhance", "hybrid",
          "#showtooltip Cure Poison\n/cast [mod:alt,target=player] Cure Poison; [target=mouseover,exists] Cure Poison; Cure Poison"),
    ],
)

# ---------------------------------------------------------------------------
# Warlock
# ---------------------------------------------------------------------------
add(
    {
        "id": "warlock-core",
        "title": "Warlock core",
        "class": "WARLOCK",
        "spec": "all",
        "tab": "character",
        "description": "Life Tap, bolts, curses, Spell Lock, summon announce (existing `sum`).",
    },
    [
        M("l-tap", "lt", "class", "WARLOCK", "all", "character", "spell_shadow_burningspirit", "warlock-core", "plan",
          "#showtooltip\n/cast [mod:shift] Life Tap(Rank 1); Life Tap"),
        M("l-sb", "sbolt", "class", "WARLOCK", "destruction", "character", "spell_shadow_shadowbolt", "warlock-core", "plan",
          "#showtooltip\n/cast [mod:shift] Shadow Bolt(Rank 1); Shadow Bolt"),
        M("l-imm", "imm", "class", "WARLOCK", "destruction", "character", "spell_fire_immolation", "warlock-core", "plan",
          "#showtooltip Immolate\n/cast Immolate"),
        M("l-corr", "corr", "class", "WARLOCK", "affliction", "character", "spell_shadow_abominationexplosion", "warlock-core", "plan",
          "#showtooltip\n/cast [mod:shift] Corruption(Rank 1); Corruption"),
        M("l-coa", "coa", "class", "WARLOCK", "affliction", "character", "spell_shadow_curseofsargeras", "warlock-core", "plan",
          "#showtooltip\n/cast [mod:shift] Curse of Agony; Curse of the Elements"),
        M("l-fear", "fear", "class", "WARLOCK", "affliction", "character", "spell_shadow_possession", "warlock-core", "plan",
          "#showtooltip\n/stopcasting\n/cast [mod:shift] Fear(Rank 1); Fear"),
        M("l-lock", "lock", "class", "WARLOCK", "demonology", "character", "spell_shadow_mindrot", "warlock-core", "plan",
          "#showtooltip Spell Lock\n/stopcasting\n/cast Spell Lock"),
        M("l-sum", "sum", "class", "WARLOCK", "all", "account", "spell_shadow_twilight", "warlock-core", "existing",
          "/ra Summoning %t\n/rw Summoning %t, click!\n/cast Ritual of Summoning"),
        M("l-ss", "soulstone", "class", "WARLOCK", "all", "character", "inv_misc_orb_04", "warlock-core", "plan",
          "#showtooltip Major Soulstone\n/raid Soulstone on %t\n/use Major Soulstone"),
        M("l-sac", "sac", "class", "WARLOCK", "demonology", "character", "spell_shadow_sacrificialshield", "warlock-core", "plan",
          "#showtooltip Sacrifice\n/cast Sacrifice"),
        M("l-banish", "ban", "class", "WARLOCK", "demonology", "character", "spell_shadow_cripple", "warlock-core", "plan",
          "#showtooltip Banish\n/stopcasting\n/cast Banish"),
        M("l-coil", "dc", "class", "WARLOCK", "affliction", "character", "spell_shadow_deathcoil", "warlock-core", "plan",
          "#showtooltip Death Coil\n/cast Death Coil"),
        M("l-fel", "fel", "class", "WARLOCK", "demonology", "character", "spell_shadow_summonfelhunter", "warlock-core", "plan",
          "#showtooltip\n/cast [mod:shift] Summon Succubus; Summon Felhunter"),
        M("l-armor", "da", "class", "WARLOCK", "all", "character", "spell_shadow_ragingscream", "warlock-core", "plan",
          "#showtooltip Demon Armor\n/cast Demon Armor"),
        M("l-drain", "drain", "class", "WARLOCK", "affliction", "character", "spell_shadow_haunting", "warlock-core", "plan",
          "#showtooltip\n/cast [mod:shift] Drain Soul(Rank 1); Drain Soul"),
        M("l-shadowburn", "sbn", "class", "WARLOCK", "destruction", "character", "spell_shadow_scourgebuild", "warlock-core", "plan",
          "#showtooltip Shadowburn\n/cast Shadowburn"),
        M("l-wand", "lwand", "class", "WARLOCK", "all", "character", "ability_shootwand", "warlock-core", "plan",
          "#showtooltip Shoot\n/cast Shoot"),
    ],
)

# ---------------------------------------------------------------------------
# Druid
# ---------------------------------------------------------------------------
add(
    {
        "id": "druid-feral",
        "title": "Druid Feral",
        "class": "DRUID",
        "spec": "feral",
        "tab": "character",
        "description": "Cat/bear. /cancelform before heals. Form numbers: 1 bear, 3 cat.",
    },
    [
        M("d-shred", "shred", "class", "DRUID", "feral", "character", "spell_shadow_vampiricaura", "druid-feral", "plan",
          "#showtooltip Shred\n/startattack\n/cast Shred"),
        M("d-fb", "fbite", "class", "DRUID", "feral", "character", "ability_druid_ferociousbite", "druid-feral", "plan",
          "#showtooltip\n/cast [mod:shift] Ferocious Bite(Rank 1); Ferocious Bite"),
        M("d-rip", "rip", "class", "DRUID", "feral", "character", "ability_ghoulfrenzy", "druid-feral", "plan",
          "#showtooltip Rip\n/cast Rip"),
        M("d-rake", "rake", "class", "DRUID", "feral", "character", "ability_druid_disembowel", "druid-feral", "plan",
          "#showtooltip Rake\n/startattack\n/cast Rake"),
        M("d-prowl", "pr", "class", "DRUID", "feral", "character", "ability_druid_prowl", "druid-feral", "plan",
          "#showtooltip Prowl\n/cast [noform:3] Cat Form\n/cast Prowl"),
        M("d-maul", "ml", "class", "DRUID", "feral", "character", "ability_druid_maul", "druid-feral", "plan",
          "#showtooltip Maul\n/startattack\n/cast Maul"),
        M("d-growl", "gr", "class", "DRUID", "feral", "character", "ability_physical_taunt", "druid-feral", "plan",
          "#showtooltip Growl\n/cast [noform:1] Dire Bear Form\n/cast Growl"),
        M("d-bash", "bash", "class", "DRUID", "feral", "character", "ability_druid_bash", "druid-feral", "plan",
          "#showtooltip Bash\n/stopcasting\n/cast Bash"),
        M("d-ff", "ff", "class", "DRUID", "all", "character", "spell_nature_faeriefire", "druid-feral", "plan",
          "#showtooltip\n/cast [form:1/3] Faerie Fire (Feral); Faerie Fire"),
        M("d-charge", "fc", "class", "DRUID", "feral", "character", "ability_hunter_pet_bear", "druid-feral", "plan",
          "#showtooltip Feral Charge\n/cast Feral Charge"),
        M("d-fr", "fr", "class", "DRUID", "feral", "character", "ability_bullrush", "druid-feral", "plan",
          "#showtooltip Frenzied Regeneration\n/cast Frenzied Regeneration"),
        M("d-dash", "dash", "class", "DRUID", "feral", "character", "ability_druid_dash", "druid-feral", "plan",
          "#showtooltip Dash\n/cast Dash"),
        M("d-cat", "cat", "class", "DRUID", "feral", "character", "ability_druid_catform", "druid-feral", "plan",
          "#showtooltip\n/cast [mod:shift] Travel Form; Cat Form"),
        M("d-bear", "bear", "class", "DRUID", "feral", "character", "ability_racial_bearform", "druid-feral", "plan",
          "#showtooltip Dire Bear Form\n/cast Dire Bear Form"),
        M("d-ht", "ht", "class", "DRUID", "restoration", "character", "spell_nature_healingtouch", "druid-feral", "plan",
          "#showtooltip\n/cancelform\n/cast [mod:alt,target=player] Healing Touch; [mod:shift] Healing Touch(Rank 4); [mod:ctrl] Healing Touch(Rank 1); Healing Touch"),
        M("d-inn", "inn", "class", "DRUID", "restoration", "character", "spell_nature_lightning", "druid-feral", "plan",
          "#showtooltip Innervate\n/cancelform\n/raid Innervate on %t\n/cast [mod:alt,target=player] Innervate; Innervate"),
        M("d-reb", "reb", "class", "DRUID", "restoration", "character", "spell_nature_reincarnation", "druid-feral", "plan",
          "#showtooltip Rebirth\n/cancelform\n/raid {rt8} Rebirth on %t {rt8}\n/cast Rebirth"),
        M("d-motw", "motw", "class", "DRUID", "restoration", "character", "spell_nature_regeneration", "druid-feral", "plan",
          "#showtooltip Mark of the Wild\n/cancelform\n/cast [mod:alt,target=player] Mark of the Wild; Mark of the Wild"),
    ],
)

add(
    {
        "id": "druid-balance",
        "title": "Druid Balance / Resto extras",
        "class": "DRUID",
        "spec": "balance",
        "tab": "character",
        "description": "Moonkin and healer extras.",
    },
    [
        M("d-mf", "mfire", "class", "DRUID", "balance", "character", "spell_nature_starfall", "druid-balance", "plan",
          "#showtooltip\n/cast [mod:shift] Moonfire(Rank 1); Moonfire"),
        M("d-wrath", "wr", "class", "DRUID", "balance", "character", "spell_nature_abolishmagic", "druid-balance", "plan",
          "#showtooltip Wrath\n/cast Wrath"),
        M("d-star", "stf", "class", "DRUID", "balance", "character", "spell_arcane_starfire", "druid-balance", "plan",
          "#showtooltip Starfire\n/cast Starfire"),
        M("d-moonkin", "mk", "class", "DRUID", "balance", "character", "spell_nature_forceofnature", "druid-balance", "plan",
          "#showtooltip Moonkin Form\n/cast Moonkin Form"),
        M("d-roots", "er", "class", "DRUID", "balance", "character", "spell_nature_stranglevines", "druid-balance", "plan",
          "#showtooltip\n/cancelform\n/cast [mod:shift] Entangling Roots(Rank 1); Entangling Roots"),
        M("d-rejuv", "rej", "class", "DRUID", "restoration", "character", "spell_nature_rejuvenation", "druid-balance", "plan",
          "#showtooltip\n/cancelform\n/cast [mod:alt,target=player] Rejuvenation; [mod:shift] Rejuvenation(Rank 3); Rejuvenation"),
        M("d-swift", "sm", "class", "DRUID", "restoration", "character", "inv_relics_idolofrejuvenation", "druid-balance", "plan",
          "#showtooltip Swiftmend\n/cancelform\n/cast Swiftmend"),
        M("d-ns", "dnsw", "class", "DRUID", "restoration", "character", "spell_nature_ravenform", "druid-balance", "plan",
          "#showtooltip Healing Touch\n/cancelform\n/cast Nature's Swiftness\n/cast Healing Touch"),
    ],
)

# ---------------------------------------------------------------------------
# TBC
# ---------------------------------------------------------------------------
add(
    {
        "id": "shared-tbc",
        "title": "Shared TBC",
        "class": "ALL",
        "spec": "all",
        "tab": "account",
        "gameVersion": "TBC",
        "description": "TBC racial wrappers that need a modifier or stopcasting. Blood Elf and Draenei passives stay on the bar. Mana Tap is a plain racial.",
    },
    [
        M("shared-gotn", "gotn", "global", "ALL", "all", "account", "spell_holy_holyprotection", "shared-tbc", "plan",
          "#showtooltip Gift of the Naaru\n/cast [mod:alt,target=player] Gift of the Naaru; Gift of the Naaru",
          "Draenei heal. Alt self."),
        M("shared-at", "atorrent", "global", "ALL", "all", "account", "spell_shadow_teleport", "shared-tbc", "plan",
          "#showtooltip Arcane Torrent\n/stopcasting\n/cast Arcane Torrent",
          "Blood Elf interrupt. Stops a queued spell first."),
    ],
)

add(
    {
        "id": "warrior-tbc",
        "title": "Warrior TBC",
        "class": "WARRIOR",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC trainer abilities. Slam sits in Warrior core on TBC. Stance Mastery is passive.",
    },
    [
        M("w-cshout", "cshout", "class", "WARRIOR", "all", "character", "ability_warrior_rallyingcry", "warrior-tbc", "plan",
          "#showtooltip Commanding Shout\n/cast Commanding Shout\n/startattack",
          "Health shout. Battle Shout stays on `w-shout`."),
        M("w-intervene", "interv", "class", "WARRIOR", "all", "character", "ability_warrior_victoryrush", "warrior-tbc", "plan",
          "#showtooltip Intervene\n/cast [nostance:2] Defensive Stance\n/cast [target=mouseover,help,nodead][] Intervene",
          "Enters Defensive Stance. Uses a friendly living mouseover, then the current target."),
        M("w-reflect", "reflect", "class", "WARRIOR", "all", "character", "ability_warrior_shieldreflection", "warrior-tbc", "plan",
          "#showtooltip Spell Reflection\n/stopcasting\n/cast [nostance:2] Defensive Stance\n/cast Spell Reflection",
          "Requires an equipped shield. Enters Defensive Stance."),
        M("w-vrush", "vrush", "class", "WARRIOR", "all", "character", "ability_warrior_devastate", "warrior-tbc", "plan",
          "#showtooltip Victory Rush\n/cast [stance:2] Battle Stance\n/cast Victory Rush\n/startattack",
          "Leaves Defensive Stance. Usable after a killing blow."),
    ],
)

add(
    {
        "id": "paladin-tbc",
        "title": "Paladin TBC",
        "class": "PALADIN",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC baseline and talent buttons. Paladin is both factions. Seal of Command stays on `p-seal`.",
    },
    [
        M("p-cstrike", "cstrike", "class", "PALADIN", "retribution", "character", "spell_holy_crusaderstrike", "paladin-tbc", "plan",
          "#showtooltip Crusader Strike\n/startattack\n/cast Crusader Strike"),
        M("p-aw", "aw", "class", "PALADIN", "all", "character", "spell_holy_avenginewrath", "paladin-tbc", "plan",
          "#showtooltip Avenging Wrath\n/use 13\n/cast Avenging Wrath"),
        M("p-rdef", "rdef", "class", "PALADIN", "all", "character", "inv_shoulder_37", "paladin-tbc", "plan",
          "#showtooltip Righteous Defense\n/cast [target=mouseover,help,nodead][] Righteous Defense",
          "Taunt the mobs on a friendly mouseover, then the current target."),
        M("p-ashield", "ashield", "class", "PALADIN", "protection", "character", "spell_holy_avengersshield", "paladin-tbc", "plan",
          "#showtooltip Avenger's Shield\n/startattack\n/cast Avenger's Shield"),
        M("p-sealtbc", "sealtbc", "class", "PALADIN", "retribution", "character", "spell_holy_sealofblood", "paladin-tbc", "plan",
          "#showtooltip\n/cast Seal of Blood\n/cast Seal of Vengeance\n/cast Seal of the Martyr\n/cast Seal of Corruption",
          "Horde Blood / Martyr. Alliance Vengeance / Corruption. First learned seal wins."),
        M("p-turne", "turne", "class", "PALADIN", "all", "character", "spell_holy_turnundead", "paladin-tbc", "plan",
          "#showtooltip Turn Evil\n/stopcasting\n/cast Turn Evil"),
        M("p-caura", "caura", "class", "PALADIN", "all", "character", "spell_holy_crusaderaura", "paladin-tbc", "plan",
          "#showtooltip Crusader Aura\n/cast Crusader Aura"),
    ],
)

add(
    {
        "id": "hunter-tbc",
        "title": "Hunter TBC",
        "class": "HUNTER",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC shots, Kill Command, Misdirection, and Viper. Readiness is gone. Bestial Wrath stays in Hunter core.",
    },
    [
        M("h-steady", "steady", "class", "HUNTER", "all", "character", "ability_hunter_steadyshot", "hunter-tbc", "plan",
          "#showtooltip Steady Shot\n/cast Steady Shot"),
        M("h-kc", "kc", "class", "HUNTER", "beast-mastery", "character", "ability_hunter_killcommand", "hunter-tbc", "plan",
          "#showtooltip Kill Command\n/petattack\n/cast Kill Command"),
        M("h-md", "md", "class", "HUNTER", "all", "character", "ability_hunter_misdirection", "hunter-tbc", "plan",
          "#showtooltip Misdirection\n/cast [target=mouseover,help,nodead] Misdirection; [target=pet,exists] Misdirection; Misdirection",
          "Friendly mouseover, then pet, then current target."),
        M("h-snake", "snake", "class", "HUNTER", "all", "character", "ability_hunter_snaketrap", "hunter-tbc", "plan",
          "#showtooltip Snake Trap\n/cast Snake Trap"),
        M("h-aspv", "aspv", "class", "HUNTER", "all", "character", "ability_hunter_aspectoftheviper", "hunter-tbc", "plan",
          "#showtooltip\n/cast [mod:shift] Aspect of the Viper; [mod:ctrl] Aspect of the Monkey; Aspect of the Hawk",
          "Hawk normally. Shift is Viper. Ctrl is Monkey. Era `asp` has no Viper line."),
    ],
)

add(
    {
        "id": "rogue-tbc",
        "title": "Rogue TBC",
        "class": "ROGUE",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC Cloak, finishers, Shiv, and talent openers. Anesthetic Poison is an item; drag it to the bar.",
    },
    [
        M("r-cloak", "cloak", "class", "ROGUE", "all", "character", "spell_shadow_nethercloak", "rogue-tbc", "plan",
          "#showtooltip Cloak of Shadows\n/stopcasting\n/cast Cloak of Shadows"),
        M("r-dthrow", "dthrow", "class", "ROGUE", "all", "character", "inv_throwingknife_06", "rogue-tbc", "plan",
          "#showtooltip Deadly Throw\n/cast Deadly Throw"),
        M("r-shiv", "shiv", "class", "ROGUE", "all", "character", "inv_throwingknife_04", "rogue-tbc", "plan",
          "#showtooltip Shiv\n/startattack\n/cast Shiv"),
        M("r-env", "env", "class", "ROGUE", "assassination", "character", "ability_rogue_disembowel", "rogue-tbc", "plan",
          "#showtooltip Envenom\n/cast Envenom"),
        M("r-step", "step", "class", "ROGUE", "subtlety", "character", "ability_rogue_shadowstep", "rogue-tbc", "plan",
          "#showtooltip Shadowstep\n/cast Shadowstep"),
        M("r-mut", "mut", "class", "ROGUE", "assassination", "character", "ability_rogue_shadowstrikes", "rogue-tbc", "plan",
          "#showtooltip Mutilate\n/startattack\n/cast Mutilate"),
    ],
)

add(
    {
        "id": "priest-tbc",
        "title": "Priest TBC",
        "class": "PRIEST",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC trainer and talent heals. Fear Ward is baseline. Blood Elf Consume Magic and Draenei/Dwarf Chastise stay here because they need stopcasting.",
    },
    [
        M("pr-swd", "swd", "class", "PRIEST", "all", "character", "spell_shadow_demonicfortitude", "priest-tbc", "plan",
          "#showtooltip Shadow Word: Death\n/cast Shadow Word: Death"),
        M("pr-pom", "pom", "class", "PRIEST", "holy", "character", "spell_holy_prayerofmendingtga", "priest-tbc", "plan",
          "#showtooltip Prayer of Mending\n/cast [mod:alt,target=player] Prayer of Mending; Prayer of Mending"),
        M("pr-coh", "coh", "class", "PRIEST", "holy", "character", "spell_holy_circleofrenewal", "priest-tbc", "plan",
          "#showtooltip Circle of Healing\n/cast [mod:alt,target=player] Circle of Healing; Circle of Healing"),
        M("pr-psup", "psup", "class", "PRIEST", "discipline", "character", "spell_holy_painsupression", "priest-tbc", "plan",
          "#showtooltip Pain Suppression\n/raid Pain Suppression on %t\n/cast [mod:alt,target=player] Pain Suppression; Pain Suppression"),
        M("pr-mdisp", "mdisp", "class", "PRIEST", "all", "character", "spell_arcane_massdispel", "priest-tbc", "plan",
          "#showtooltip Mass Dispel\n/stopcasting\n/cast Mass Dispel"),
        M("pr-sfiend", "sfiend", "class", "PRIEST", "all", "character", "spell_shadow_shadowfiend", "priest-tbc", "plan",
          "#showtooltip Shadowfiend\n/cast Shadowfiend"),
        M("pr-bheal", "bheal", "class", "PRIEST", "holy", "character", "spell_holy_blindingheal", "priest-tbc", "plan",
          "#showtooltip Binding Heal\n/cast Binding Heal"),
        M("pr-vt", "vt", "class", "PRIEST", "shadow", "character", "spell_holy_stoicism", "priest-tbc", "plan",
          "#showtooltip Vampiric Touch\n/cast Vampiric Touch"),
        M("pr-cmagic", "cmagic", "class", "PRIEST", "all", "character", "spell_arcane_studentofmagic", "priest-tbc", "plan",
          "#showtooltip Consume Magic\n/stopcasting\n/cast Consume Magic",
          "Blood Elf priest racial."),
        M("pr-chast", "chast", "class", "PRIEST", "all", "character", "spell_holy_chastise", "priest-tbc", "plan",
          "#showtooltip Chastise\n/stopcasting\n/cast Chastise",
          "Dwarf and Draenei priest racial."),
    ],
)

add(
    {
        "id": "shaman-tbc",
        "title": "Shaman TBC",
        "class": "SHAMAN",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC both factions. Bloodlust and Heroism share one body. Stormstrike stays in Shaman Enhancement.",
    },
    [
        M("s-bl", "bl", "class", "SHAMAN", "enhancement", "character", "spell_nature_bloodlust", "shaman-tbc", "plan",
          "#showtooltip\n/cast Bloodlust\n/cast Heroism",
          "Horde Bloodlust. Alliance Heroism. First learned spell wins."),
        M("s-wshield", "wshield", "class", "SHAMAN", "all", "character", "ability_shaman_watershield", "shaman-tbc", "plan",
          "#showtooltip\n/cast [mod:shift] Lightning Shield; Water Shield"),
        M("s-eshield", "eshield", "class", "SHAMAN", "restoration", "character", "spell_nature_skinofearth", "shaman-tbc", "plan",
          "#showtooltip Earth Shield\n/cast [mod:alt,target=player] Earth Shield; Earth Shield"),
        M("s-srage", "srage", "class", "SHAMAN", "enhancement", "character", "spell_nature_shamanrage", "shaman-tbc", "plan",
          "#showtooltip Shamanistic Rage\n/cast Shamanistic Rage"),
        M("s-woa", "woa", "class", "SHAMAN", "all", "character", "spell_nature_slowingtotem", "shaman-tbc", "plan",
          "#showtooltip Wrath of Air Totem\n/cast Wrath of Air Totem"),
        M("s-towrath", "towrath", "class", "SHAMAN", "elemental", "character", "spell_fire_totemofwrath", "shaman-tbc", "plan",
          "#showtooltip Totem of Wrath\n/cast Totem of Wrath"),
        M("s-eet", "eet", "class", "SHAMAN", "all", "character", "spell_nature_earthelemental_totem", "shaman-tbc", "plan",
          "#showtooltip Earth Elemental Totem\n/cast Earth Elemental Totem"),
        M("s-fet", "fet", "class", "SHAMAN", "all", "character", "spell_fire_elemental_totem", "shaman-tbc", "plan",
          "#showtooltip Fire Elemental Totem\n/cast Fire Elemental Totem"),
        M("s-tcall", "tcall", "class", "SHAMAN", "all", "character", "spell_unused", "shaman-tbc", "plan",
          "#showtooltip Totemic Call\n/cast Totemic Call"),
    ],
)

add(
    {
        "id": "mage-tbc",
        "title": "Mage TBC",
        "class": "MAGE",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC trainer and talent buttons plus Outland ports. Shift still opens a portal on the city macros. Ice Block stays in Mage control.",
    },
    [
        M("m-ilance", "ilance", "class", "MAGE", "frost", "character", "spell_frost_frostblast", "mage-tbc", "plan",
          "#showtooltip Ice Lance\n/cast Ice Lance"),
        M("m-steal", "steal", "class", "MAGE", "all", "character", "spell_arcane_arcane02", "mage-tbc", "plan",
          "#showtooltip Spellsteal\n/stopcasting\n/cast Spellsteal"),
        M("m-invis", "invis", "class", "MAGE", "all", "character", "ability_mage_invisibility", "mage-tbc", "plan",
          "#showtooltip Invisibility\n/stopcasting\n/cast Invisibility"),
        M("m-molten", "molten", "class", "MAGE", "all", "character", "ability_mage_moltenarmor", "mage-tbc", "plan",
          "#showtooltip Molten Armor\n/cast Molten Armor"),
        M("m-ablast", "ablast", "class", "MAGE", "arcane", "character", "spell_arcane_blast", "mage-tbc", "plan",
          "#showtooltip Arcane Blast\n/cqs\n/cast Arcane Blast"),
        M("m-slow", "mslow", "class", "MAGE", "arcane", "character", "spell_nature_slow", "mage-tbc", "plan",
          "#showtooltip Slow\n/cast Slow"),
        M("m-dbreath", "dbreath", "class", "MAGE", "fire", "character", "inv_misc_head_dragon_01", "mage-tbc", "plan",
          "#showtooltip Dragon's Breath\n/cast Dragon's Breath"),
        M("m-welem", "welem", "class", "MAGE", "frost", "character", "spell_frost_summonwaterelemental_2", "mage-tbc", "plan",
          "#showtooltip Summon Water Elemental\n/cast Summon Water Elemental"),
        M("m-table", "mtable", "class", "MAGE", "all", "character", "spell_arcane_massdispel", "mage-tbc", "plan",
          "#showtooltip Ritual of Refreshment\n/cast Ritual of Refreshment"),
        M("m-gemtbc", "gemtbc", "class", "MAGE", "all", "character", "inv_misc_gem_stone_01", "mage-tbc", "plan",
          "#showtooltip Conjure Mana Emerald\n/cast Conjure Mana Emerald"),
        M("m-exodar", "exodar", "class", "MAGE", "all", "character", "spell_arcane_portalexodar", "mage-tbc", "plan",
          "#showtooltip [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar\n/cast [nomod] Teleport: Exodar; [mod:shift] Portal: Exodar"),
        M("m-slvr", "slvr", "class", "MAGE", "all", "character", "spell_arcane_portalsilvermoon", "mage-tbc", "plan",
          "#showtooltip [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon\n/cast [nomod] Teleport: Silvermoon; [mod:shift] Portal: Silvermoon"),
        M("m-shat", "shat", "class", "MAGE", "all", "character", "spell_arcane_portalshattrath", "mage-tbc", "plan",
          "#showtooltip [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath\n/cast [nomod] Teleport: Shattrath; [mod:shift] Portal: Shattrath"),
        M("m-thera", "thera", "class", "MAGE", "all", "character", "spell_arcane_portaltheramore", "mage-tbc", "plan",
          "#showtooltip [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore\n/cast [nomod] Teleport: Theramore; [mod:shift] Portal: Theramore"),
        M("m-stonard", "stonard", "class", "MAGE", "all", "character", "spell_arcane_portalstonard", "mage-tbc", "plan",
          "#showtooltip [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard\n/cast [nomod] Teleport: Stonard; [mod:shift] Portal: Stonard"),
    ],
)

add(
    {
        "id": "warlock-tbc",
        "title": "Warlock TBC",
        "class": "WARLOCK",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC armor, filler, soulwell, and talent CCs. Create Soulstone ranks collapsed on the TBC trainer list; the soulstone macro still uses the item.",
    },
    [
        M("l-incin", "incin", "class", "WARLOCK", "destruction", "character", "spell_fire_burnout", "warlock-tbc", "plan",
          "#showtooltip Incinerate\n/cast Incinerate"),
        M("l-felarm", "felarm", "class", "WARLOCK", "all", "character", "spell_shadow_felarmour", "warlock-tbc", "plan",
          "#showtooltip\n/cast [mod:shift] Demon Armor; Fel Armor"),
        M("l-shatter", "shatter", "class", "WARLOCK", "all", "character", "spell_arcane_arcane01", "warlock-tbc", "plan",
          "#showtooltip Soulshatter\n/cast Soulshatter"),
        M("l-souls", "souls", "class", "WARLOCK", "all", "character", "spell_shadow_shadesofdarkness", "warlock-tbc", "plan",
          "#showtooltip Ritual of Souls\n/cast Ritual of Souls"),
        M("l-seed", "seed", "class", "WARLOCK", "affliction", "character", "spell_shadow_seedofdestruction", "warlock-tbc", "plan",
          "#showtooltip Seed of Corruption\n/cast Seed of Corruption"),
        M("l-ua", "ua", "class", "WARLOCK", "affliction", "character", "spell_shadow_unstableaffliction_3", "warlock-tbc", "plan",
          "#showtooltip Unstable Affliction\n/cast Unstable Affliction"),
        M("l-sfury", "sfury", "class", "WARLOCK", "destruction", "character", "spell_shadow_shadowfury", "warlock-tbc", "plan",
          "#showtooltip Shadowfury\n/stopcasting\n/cast Shadowfury"),
        M("l-fguard", "fguard", "class", "WARLOCK", "demonology", "character", "spell_shadow_summonfelguard", "warlock-tbc", "plan",
          "#showtooltip Summon Felguard\n/cast Summon Felguard"),
    ],
)

add(
    {
        "id": "druid-tbc",
        "title": "Druid TBC",
        "class": "DRUID",
        "spec": "all",
        "tab": "character",
        "gameVersion": "TBC",
        "description": "TBC forms and feral/resto buttons. Flight Form is trainer-taught. Swift Flight Form is Restoration.",
    },
    [
        M("d-mangle", "mangle", "class", "DRUID", "feral", "character", "ability_druid_mangle2", "druid-tbc", "plan",
          "#showtooltip\n/startattack\n/cast [form:3] Mangle (Cat); Mangle (Bear)"),
        M("d-lbloom", "lbloom", "class", "DRUID", "restoration", "character", "inv_misc_herb_felblossom", "druid-tbc", "plan",
          "#showtooltip Lifebloom\n/cancelform\n/cast [mod:alt,target=player] Lifebloom; Lifebloom"),
        M("d-cyc", "cyc", "class", "DRUID", "balance", "character", "spell_nature_earthbind", "druid-tbc", "plan",
          "#showtooltip Cyclone\n/stopcasting\n/cast Cyclone"),
        M("d-flight", "flight", "class", "DRUID", "all", "character", "ability_druid_flightform", "druid-tbc", "plan",
          "#showtooltip\n/cast [mod:shift] Swift Flight Form; Flight Form"),
        M("d-lac", "lac", "class", "DRUID", "feral", "character", "ability_druid_lacerate", "druid-tbc", "plan",
          "#showtooltip Lacerate\n/startattack\n/cast Lacerate"),
        M("d-maim", "maim", "class", "DRUID", "feral", "character", "ability_druid_mangle-tga", "druid-tbc", "plan",
          "#showtooltip Maim\n/cast Maim"),
        M("d-tree", "tree", "class", "DRUID", "restoration", "character", "ability_druid_treeoflife", "druid-tbc", "plan",
          "#showtooltip Tree of Life\n/cast Tree of Life"),
    ],
)

# ---------------------------------------------------------------------------
# Paladin ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "paladin-ranks",
        "title": "Paladin ranks",
        "class": "PALADIN",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("p-gbom", "gbom", "class", "PALADIN", "all", "account", "spell_holy_greaterblessingofkings", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Greater Blessing of Might;[mod:shift]Greater Blessing of Might(Rank 1)"),
        M("p-crus", "crus", "class", "PALADIN", "all", "account", "spell_holy_holysmite", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Seal of the Crusader;[mod:shift]Seal of the Crusader(Rank 1)"),
        M("p-bosac", "bosac", "class", "PALADIN", "all", "account", "spell_holy_sealofsacrifice", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Blessing of Sacrifice;[mod:shift]Blessing of Sacrifice(Rank 1)"),
        M("p-dprot", "dprot", "class", "PALADIN", "all", "account", "spell_holy_restoration", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Divine Protection;[mod:shift]Divine Protection(Rank 1)"),
        M("p-fraura", "fraura", "class", "PALADIN", "all", "account", "spell_fire_sealoffire", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Fire Resistance Aura;[mod:shift]Fire Resistance Aura(Rank 1)"),
        M("p-rfaura", "rfaura", "class", "PALADIN", "all", "account", "spell_frost_wizardmark", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Frost Resistance Aura;[mod:shift]Frost Resistance Aura(Rank 1)"),
        M("p-sraura", "sraura", "class", "PALADIN", "all", "account", "spell_shadow_sealofkings", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Shadow Resistance Aura;[mod:shift]Shadow Resistance Aura(Rank 1)"),
        M("p-bolight", "bolight", "class", "PALADIN", "all", "account", "spell_holy_prayerofhealing02", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Blessing of Light;[mod:shift]Blessing of Light(Rank 1)"),
        M("p-gbow", "gbow", "class", "PALADIN", "all", "account", "spell_holy_greaterblessingofwisdom", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Greater Blessing of Wisdom;[mod:shift]Greater Blessing of Wisdom(Rank 1)"),
        M("p-hwath", "hwath", "class", "PALADIN", "all", "account", "spell_holy_excorcism", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Holy Wrath;[mod:shift]Holy Wrath(Rank 1)"),
        M("p-redeem", "redeem", "class", "PALADIN", "all", "account", "spell_holy_resurrection", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Redemption;[mod:shift]Redemption(Rank 1)"),
        M("p-turnu", "turnu", "class", "PALADIN", "all", "account", "spell_holy_turnundead", "paladin-ranks", "plan",
          "#showtooltip\n/cast [nomod]Turn Undead;[mod:shift]Turn Undead(Rank 1)"),
    ],
)

# ---------------------------------------------------------------------------
# Hunter ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "hunter-ranks",
        "title": "Hunter ranks",
        "class": "HUNTER",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("h-wild", "wild", "class", "HUNTER", "all", "account", "spell_nature_protectionformnature", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Aspect of the Wild;[mod:shift]Aspect of the Wild(Rank 1)"),
        M("h-scare", "scare", "class", "HUNTER", "all", "account", "ability_druid_cower", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Scare Beast;[mod:shift]Scare Beast(Rank 1)"),
        M("h-dshot", "dshot", "class", "HUNTER", "all", "account", "spell_arcane_blink", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Distracting Shot;[mod:shift]Distracting Shot(Rank 1)"),
        M("h-scorpid", "scorpid", "class", "HUNTER", "all", "account", "ability_hunter_criticalshot", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Scorpid Sting;[mod:shift]Scorpid Sting(Rank 1)"),
        M("h-viper", "viper", "class", "HUNTER", "all", "account", "ability_hunter_aimedshot", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Viper Sting;[mod:shift]Viper Sting(Rank 1)"),
        M("h-volley", "volley", "class", "HUNTER", "all", "account", "ability_marksmanship", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Volley;[mod:shift]Volley(Rank 1)"),
        M("h-diseng", "diseng", "class", "HUNTER", "all", "account", "ability_rogue_feint", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Disengage;[mod:shift]Disengage(Rank 1)"),
        M("h-etrap", "etrap", "class", "HUNTER", "all", "account", "spell_fire_selfdestruct", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Explosive Trap;[mod:shift]Explosive Trap(Rank 1)"),
        M("h-itrap", "itrap", "class", "HUNTER", "all", "account", "spell_fire_flameshock", "hunter-ranks", "plan",
          "#showtooltip\n/cast [nomod]Immolation Trap;[mod:shift]Immolation Trap(Rank 1)"),
        M("h-mongo", "mongo", "class", "HUNTER", "all", "account", "ability_hunter_swiftstrike", "hunter-ranks", "plan",
          "#showtooltip\n/startattack\n/cast [nomod]Mongoose Bite;[mod:shift]Mongoose Bite(Rank 1)"),
        M("h-raptor", "raptor", "class", "HUNTER", "all", "account", "ability_meleedamage", "hunter-ranks", "plan",
          "#showtooltip\n/startattack\n/cast [nomod]Raptor Strike;[mod:shift]Raptor Strike(Rank 1)"),
    ],
)

# ---------------------------------------------------------------------------
# Rogue ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "rogue-ranks",
        "title": "Rogue ranks",
        "class": "ROGUE",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("r-expose", "expose", "class", "ROGUE", "all", "account", "ability_warrior_riposte", "rogue-ranks", "plan",
          "#showtooltip\n/cast [nomod]Expose Armor;[mod:shift]Expose Armor(Rank 1)"),
        M("r-garrote", "garrote", "class", "ROGUE", "all", "account", "ability_rogue_garrote", "rogue-ranks", "plan",
          "#showtooltip\n/cast [nomod]Garrote;[mod:shift]Garrote(Rank 1)"),
        M("r-bstab", "bstab", "class", "ROGUE", "all", "account", "ability_backstab", "rogue-ranks", "plan",
          "#showtooltip\n/startattack\n/cast [nomod]Backstab;[mod:shift]Backstab(Rank 1)"),
        M("r-feint", "feint", "class", "ROGUE", "all", "account", "ability_rogue_feint", "rogue-ranks", "plan",
          "#showtooltip\n/cast [nomod]Feint;[mod:shift]Feint(Rank 1)"),
    ],
)

# ---------------------------------------------------------------------------
# Priest ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "priest-ranks",
        "title": "Priest ranks",
        "class": "PRIEST",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("pr-egrace", "egrace", "class", "PRIEST", "all", "account", "spell_holy_elunesgrace", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Elune's Grace;[mod:shift]Elune's Grace(Rank 1)"),
        M("pr-fback", "fback", "class", "PRIEST", "all", "account", "spell_shadow_ritualofsacrifice", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Feedback;[mod:shift]Feedback(Rank 1)"),
        M("pr-mburn", "mburn", "class", "PRIEST", "all", "account", "spell_shadow_manaburn", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Mana Burn;[mod:shift]Mana Burn(Rank 1)"),
        M("pr-shards", "shards", "class", "PRIEST", "all", "account", "spell_arcane_starfire", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Starshards;[mod:shift]Starshards(Rank 1)"),
        M("pr-dpray", "dpray", "class", "PRIEST", "all", "account", "spell_holy_restoration", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Desperate Prayer;[mod:shift]Desperate Prayer(Rank 1)"),
        M("pr-heal", "heal", "class", "PRIEST", "all", "account", "spell_holy_heal02", "priest-ranks", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Heal; [mod:shift] Heal(Rank 1); Heal"),
        M("pr-hfire", "hfire", "class", "PRIEST", "all", "account", "spell_holy_searinglight", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Holy Fire;[mod:shift]Holy Fire(Rank 1)"),
        M("pr-lheal", "lheal", "class", "PRIEST", "all", "account", "spell_holy_lesserheal", "priest-ranks", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Lesser Heal; [mod:shift] Lesser Heal(Rank 1); Lesser Heal"),
        M("pr-smite", "smite", "class", "PRIEST", "all", "account", "spell_holy_holysmite", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Smite;[mod:shift]Smite(Rank 1)"),
        M("pr-dplague", "dplague", "class", "PRIEST", "all", "account", "spell_shadow_blackplague", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Devouring Plague;[mod:shift]Devouring Plague(Rank 1)"),
        M("pr-hexw", "hexw", "class", "PRIEST", "all", "account", "spell_shadow_fingerofdeath", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Hex of Weakness;[mod:shift]Hex of Weakness(Rank 1)"),
        M("pr-mc", "mc", "class", "PRIEST", "all", "account", "spell_shadow_shadowworddominate", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Mind Control;[mod:shift]Mind Control(Rank 1)"),
        M("pr-msoothe", "msoothe", "class", "PRIEST", "all", "account", "spell_holy_mindsooth", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Mind Soothe;[mod:shift]Mind Soothe(Rank 1)"),
        M("pr-mvis", "mvis", "class", "PRIEST", "all", "account", "spell_holy_mindvision", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Mind Vision;[mod:shift]Mind Vision(Rank 1)"),
        M("pr-sprot", "sprot", "class", "PRIEST", "all", "account", "spell_shadow_antishadow", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Shadow Protection;[mod:shift]Shadow Protection(Rank 1)"),
        M("pr-sguard", "sguard", "class", "PRIEST", "all", "account", "spell_nature_lightningshield", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Shadowguard;[mod:shift]Shadowguard(Rank 1)"),
        M("pr-tow", "tow", "class", "PRIEST", "all", "account", "spell_shadow_deadofnight", "priest-ranks", "plan",
          "#showtooltip\n/cast [nomod]Touch of Weakness;[mod:shift]Touch of Weakness(Rank 1)"),
    ],
)

# ---------------------------------------------------------------------------
# Shaman ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "shaman-ranks",
        "title": "Shaman ranks",
        "class": "SHAMAN",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("s-fnt", "fnt", "class", "SHAMAN", "all", "account", "spell_fire_sealoffire", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Fire Nova Totem;[mod:shift]Fire Nova Totem(Rank 1)"),
        M("s-magma", "magma", "class", "SHAMAN", "all", "account", "spell_fire_selfdestruct", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Magma Totem;[mod:shift]Magma Totem(Rank 1)"),
        M("s-sear", "sear", "class", "SHAMAN", "all", "account", "spell_fire_searingtotem", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Searing Totem;[mod:shift]Searing Totem(Rank 1)"),
        M("s-sclaw", "sclaw", "class", "SHAMAN", "all", "account", "spell_nature_stoneclawtotem", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Stoneclaw Totem;[mod:shift]Stoneclaw Totem(Rank 1)"),
        M("s-frtot", "frtot", "class", "SHAMAN", "all", "account", "spell_fireresistancetotem_01", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Fire Resistance Totem;[mod:shift]Fire Resistance Totem(Rank 1)"),
        M("s-fttot", "fttot", "class", "SHAMAN", "all", "account", "spell_nature_guardianward", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Flametongue Totem;[mod:shift]Flametongue Totem(Rank 1)"),
        M("s-rftot", "rftot", "class", "SHAMAN", "all", "account", "spell_frostresistancetotem_01", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Frost Resistance Totem;[mod:shift]Frost Resistance Totem(Rank 1)"),
        M("s-fbrand", "fbrand", "class", "SHAMAN", "all", "account", "spell_frost_frostbrand", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Frostbrand Weapon;[mod:shift]Frostbrand Weapon(Rank 1)"),
        M("s-goa", "goa", "class", "SHAMAN", "all", "account", "spell_nature_invisibilitytotem", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Grace of Air Totem;[mod:shift]Grace of Air Totem(Rank 1)"),
        M("s-nrtot", "nrtot", "class", "SHAMAN", "all", "account", "spell_nature_natureresistancetotem", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Nature Resistance Totem;[mod:shift]Nature Resistance Totem(Rank 1)"),
        M("s-rbit", "rbit", "class", "SHAMAN", "all", "account", "spell_nature_rockbiter", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Rockbiter Weapon;[mod:shift]Rockbiter Weapon(Rank 1)"),
        M("s-sskin", "sskin", "class", "SHAMAN", "all", "account", "spell_nature_stoneskintotem", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Stoneskin Totem;[mod:shift]Stoneskin Totem(Rank 1)"),
        M("s-wwall", "wwall", "class", "SHAMAN", "all", "account", "spell_nature_earthbind", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Windwall Totem;[mod:shift]Windwall Totem(Rank 1)"),
        M("s-aspirit", "aspirit", "class", "SHAMAN", "all", "account", "spell_nature_regenerate", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Ancestral Spirit;[mod:shift]Ancestral Spirit(Rank 1)"),
        M("s-cheal", "cheal", "class", "SHAMAN", "all", "account", "spell_nature_healingwavegreater", "shaman-ranks", "plan",
          "#showtooltip\n/cast [mod:alt,target=player] Chain Heal; [mod:shift] Chain Heal(Rank 1); Chain Heal"),
        M("s-hstot", "hstot", "class", "SHAMAN", "all", "account", "inv_spear_04", "shaman-ranks", "plan",
          "#showtooltip\n/cast [nomod]Healing Stream Totem;[mod:shift]Healing Stream Totem(Rank 1)"),
    ],
)

# ---------------------------------------------------------------------------
# Mage ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "mage-ranks",
        "title": "Mage ranks",
        "class": "MAGE",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("m-ai", "ai", "class", "MAGE", "all", "account", "spell_holy_magicalsentry", "mage-ranks", "plan",
          "#showtooltip\n/cast [nomod]Arcane Intellect;[mod:shift]Arcane Intellect(Rank 1)"),
        M("m-cf", "cf", "class", "MAGE", "all", "account", "inv_misc_food_73cinnamonroll", "mage-ranks", "plan",
          "#showtooltip\n/cast [nomod]Conjure Food;[mod:shift]Conjure Food(Rank 1)"),
        M("m-cw", "cw", "class", "MAGE", "all", "account", "inv_drink_18", "mage-ranks", "plan",
          "#showtooltip\n/cast [nomod]Conjure Water;[mod:shift]Conjure Water(Rank 1)"),
        M("m-ma", "ma", "class", "MAGE", "all", "account", "spell_magearmor", "mage-ranks", "plan",
          "#showtooltip\n/cast [nomod]Mage Armor;[mod:shift]Mage Armor(Rank 1)"),
        M("m-farmor", "farmor", "class", "MAGE", "all", "account", "spell_frost_frostarmor02", "mage-ranks", "plan",
          "#showtooltip\n/cast [nomod]Frost Armor;[mod:shift]Frost Armor(Rank 1)"),
        M("m-ia", "ia", "class", "MAGE", "all", "account", "spell_frost_frostarmor02", "mage-ranks", "plan",
          "#showtooltip\n/cast [nomod]Ice Armor;[mod:shift]Ice Armor(Rank 1)"),
    ],
)

# ---------------------------------------------------------------------------
# Warlock ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "warlock-ranks",
        "title": "Warlock ranks",
        "class": "WARLOCK",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("l-cor", "cor", "class", "WARLOCK", "all", "account", "spell_shadow_unholystrength", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Curse of Recklessness;[mod:shift]Curse of Recklessness(Rank 1)"),
        M("l-cosh", "cosh", "class", "WARLOCK", "all", "account", "spell_shadow_curseofachimonde", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Curse of Shadow;[mod:shift]Curse of Shadow(Rank 1)"),
        M("l-cot", "cot", "class", "WARLOCK", "all", "account", "spell_shadow_curseoftounges", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Curse of Tongues;[mod:shift]Curse of Tongues(Rank 1)"),
        M("l-cowk", "cowk", "class", "WARLOCK", "all", "account", "spell_shadow_curseofmannoroth", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Curse of Weakness;[mod:shift]Curse of Weakness(Rank 1)"),
        M("l-dlife", "dlife", "class", "WARLOCK", "all", "account", "spell_shadow_lifedrain02", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Drain Life;[mod:shift]Drain Life(Rank 1)"),
        M("l-dmana", "dmana", "class", "WARLOCK", "all", "account", "spell_shadow_siphonmana", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Drain Mana;[mod:shift]Drain Mana(Rank 1)"),
        M("l-howl", "howl", "class", "WARLOCK", "all", "account", "spell_shadow_deathscream", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Howl of Terror;[mod:shift]Howl of Terror(Rank 1)"),
        M("l-dskin", "dskin", "class", "WARLOCK", "all", "account", "spell_shadow_ragingscream", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Demon Skin;[mod:shift]Demon Skin(Rank 1)"),
        M("l-hfunnel", "hfunnel", "class", "WARLOCK", "all", "account", "spell_shadow_lifedrain", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Health Funnel;[mod:shift]Health Funnel(Rank 1)"),
        M("l-sward", "sward", "class", "WARLOCK", "all", "account", "spell_shadow_antishadow", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Shadow Ward;[mod:shift]Shadow Ward(Rank 1)"),
        M("l-subj", "subj", "class", "WARLOCK", "all", "account", "spell_shadow_enslavedemon", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Subjugate Demon;[mod:shift]Subjugate Demon(Rank 1)"),
        M("l-hell", "hell", "class", "WARLOCK", "all", "account", "spell_fire_incinerate", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Hellfire;[mod:shift]Hellfire(Rank 1)"),
        M("l-rof", "rof", "class", "WARLOCK", "all", "account", "spell_shadow_rainoffire", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Rain of Fire;[mod:shift]Rain of Fire(Rank 1)"),
        M("l-spain", "spain", "class", "WARLOCK", "all", "account", "spell_fire_soulburn", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Searing Pain;[mod:shift]Searing Pain(Rank 1)"),
        M("l-sfire", "sfire", "class", "WARLOCK", "all", "account", "spell_fire_fireball02", "warlock-ranks", "plan",
          "#showtooltip\n/cast [nomod]Soul Fire;[mod:shift]Soul Fire(Rank 1)"),
    ],
)

# ---------------------------------------------------------------------------
# Druid ranks
# ---------------------------------------------------------------------------
add(
    {
        "id": "druid-ranks",
        "title": "Druid ranks",
        "class": "DRUID",
        "spec": "all",
        "tab": "account",
        "description": "Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.",
    },
    [
        M("d-hib", "hib", "class", "DRUID", "all", "account", "spell_nature_sleep", "druid-ranks", "plan",
          "#showtooltip\n/cancelform\n/cast [nomod]Hibernate;[mod:shift]Hibernate(Rank 1)"),
        M("d-cane", "cane", "class", "DRUID", "all", "account", "spell_nature_cyclone", "druid-ranks", "plan",
          "#showtooltip\n/cast [nomod]Hurricane;[mod:shift]Hurricane(Rank 1)"),
        M("d-soothe", "soothe", "class", "DRUID", "all", "account", "ability_hunter_beastsoothe", "druid-ranks", "plan",
          "#showtooltip\n/cancelform\n/cast [nomod]Soothe Animal;[mod:shift]Soothe Animal(Rank 1)"),
        M("d-thorns", "thorns", "class", "DRUID", "all", "account", "spell_nature_thorns", "druid-ranks", "plan",
          "#showtooltip\n/cancelform\n/cast [nomod]Thorns;[mod:shift]Thorns(Rank 1)"),
        M("d-claw", "claw", "class", "DRUID", "all", "account", "ability_druid_rake", "druid-ranks", "plan",
          "#showtooltip\n/startattack\n/cast [nomod]Claw;[mod:shift]Claw(Rank 1)"),
        M("d-cower", "cower", "class", "DRUID", "all", "account", "ability_druid_cower", "druid-ranks", "plan",
          "#showtooltip\n/cast [nomod]Cower;[mod:shift]Cower(Rank 1)"),
        M("d-dmr", "dmr", "class", "DRUID", "all", "account", "classic_ability_druid_demoralizingroar", "druid-ranks", "plan",
          "#showtooltip\n/cast [nomod]Demoralizing Roar;[mod:shift]Demoralizing Roar(Rank 1)"),
        M("d-pounce", "pounce", "class", "DRUID", "all", "account", "ability_druid_supriseattack", "druid-ranks", "plan",
          "#showtooltip\n/cast [nomod]Pounce;[mod:shift]Pounce(Rank 1)"),
        M("d-ravage", "ravage", "class", "DRUID", "all", "account", "ability_druid_ravage", "druid-ranks", "plan",
          "#showtooltip\n/cast [nomod]Ravage;[mod:shift]Ravage(Rank 1)"),
        M("d-swipe", "swipe", "class", "DRUID", "all", "account", "inv_misc_monsterclaw_03", "druid-ranks", "plan",
          "#showtooltip\n/startattack\n/cast [nomod]Swipe;[mod:shift]Swipe(Rank 1)"),
        M("d-tfury", "tfury", "class", "DRUID", "all", "account", "ability_mount_jungletiger", "druid-ranks", "plan",
          "#showtooltip\n/cast [nomod]Tiger's Fury;[mod:shift]Tiger's Fury(Rank 1)"),
        M("d-gotw", "gotw", "class", "DRUID", "all", "account", "spell_nature_regeneration", "druid-ranks", "plan",
          "#showtooltip\n/cancelform\n/cast [nomod]Gift of the Wild;[mod:shift]Gift of the Wild(Rank 1)"),
        M("d-rgw", "rgw", "class", "DRUID", "all", "account", "spell_nature_resistnature", "druid-ranks", "plan",
          "#showtooltip\n/cancelform\n/cast [mod:alt,target=player] Regrowth; [mod:shift] Regrowth(Rank 1); Regrowth"),
        M("d-tranq", "tranq", "class", "DRUID", "all", "account", "spell_nature_tranquility", "druid-ranks", "plan",
          "#showtooltip\n/cancelform\n/cast [nomod]Tranquility;[mod:shift]Tranquility(Rank 1)"),
    ],
)

def emit_md(catalog: dict) -> str:
    lines = [
        "# Macro catalog",
        "",
        "Source of truth: [catalog.json](catalog.json). WoW Macro Cursor loads that file. Groups with `gameVersion` TBC show only on Version TBC.",
        "",
        "Scope, class, and spec live on the catalog record. Do not put `# class-specific` comments in the body.",
        "",
        f"- Macros: **{len(catalog['macros'])}**",
        f"- Groups: **{len(catalog['groups'])}**",
        "- Cap: 120 account + 18 character. Body 255. Name 16.",
        "",
        "## Groups",
        "",
        "| Group | Version | Scope | Character | Class | Spec | Tab | Count |",
        "| --- | --- | --- | --- | --- | --- | --- | --- |",
    ]
    for g in catalog["groups"]:
        lines.append(
            f"| [{g['id']}](#{g['id']}) | {g.get('gameVersion', 'both')} | {g.get('scope', '')} | {g.get('character', '') or '—'} | {g['class']} | {g['spec']} | {g['tab']} | {g['count']} |"
        )
    lines += ["", "## Records", ""]
    by_id = {m["id"]: m for m in catalog["macros"]}
    for g in catalog["groups"]:
        lines += [
            f"### {g['id']}",
            "",
            f"{g['description']}",
            "",
        ]
        for mid in g["macroIds"]:
            m = by_id[mid]
            lines += [
                f"#### {m['id']}",
                "",
                f"- name: `{m['name']}`",
                f"- scope: {m['scope']}",
                f"- class: {m['class']}",
                f"- spec: {m['spec']}",
                f"- character: {m.get('character', '—')}",
                f"- tab: {m['tab']}",
                f"- icon: `{m['icon']}`",
                f"- source: {m['source']}",
                f"- chars: {m['chars']}",
            ]
            if m.get("gameVersion"):
                lines.append(f"- version: {m['gameVersion']}")
            if m.get("notes"):
                lines.append(f"- notes: {m['notes']}")
            lines += ["", "```", m["body"], "```", ""]
    return "\n".join(lines) + "\n"


def emit_class_md(cls: str, catalog: dict) -> str:
    gset = sorted(
        [g for g in catalog["groups"] if g["class"] == cls],
        key=lambda g: ({"global": 0, "class": 1, "character": 2}.get(g.get("scope", "class"), 1), g["id"]),
    )
    if cls == "WARRIOR":
        order = {
            "warrior-core": 0,
            "warrior-arms": 1,
            "warrior-fury": 2,
            "warrior-prot": 3,
            "warrior-tbc": 4,
            "warrior-gear": 5,
        }
        gset.sort(key=lambda g: order.get(g["id"], 99))
    by_id = {m["id"]: m for m in catalog["macros"]}
    title = {
        "ALL": "Shared macros (General tab)",
        "WARRIOR": "Warrior",
        "PALADIN": "Paladin",
        "HUNTER": "Hunter",
        "ROGUE": "Rogue",
        "PRIEST": "Priest",
        "SHAMAN": "Shaman",
        "MAGE": "Mage",
        "WARLOCK": "Warlock",
        "DRUID": "Druid",
    }[cls]
    lines = [
        f"# {title}",
        "",
        "Generated from `build_catalog.py`.",
        "Full records: [catalog.md](catalog.md).",
        "",
    ]
    if cls == "WARRIOR":
        lines += [
            "**Stances:** `1` Battle, `2` Defensive, `3` Berserker.",
            "",
            "Warrior core contains useful macros for non-talent abilities. Arms, Fury, and Protection contain only useful wrappers for abilities unlocked by that talent tree.",
            "Piercing Howl needs no macro logic, so drag the spell itself to an unmanaged slot.",
            "For Fury, load Warrior core + Warrior Fury. For Fury/Protection, add Last Stand separately if learned; do not add Concussion Blow or Shield Slam unless the build unlocks them.",
            "",
            "Catalog bodies stay stance-aware. On a matching stance page, the stance line is a no-op.",
            "Charge / Intercept share `E`; Shield Bash / Pummel share `F`; the three major stance cooldowns share `Z`.",
            "A stance change can require a second key press after the stance cooldown. Shield Slam and Shield Wall require an equipped shield.",
            "On TBC, load Warrior TBC for Commanding Shout, Intervene, Spell Reflection, and Victory Rush. Slam is in Warrior core on that Version.",
            "",
        ]
    if cls == "PALADIN":
        lines += [
            "Era Paladin is Alliance only. TBC Paladin is both factions. Load Paladin TBC for Crusader Strike, Avenging Wrath, and Blood / Vengeance seals.",
            "",
        ]
    if cls == "SHAMAN":
        lines += [
            "Era Shaman is Horde only. TBC Shaman is both factions. Load Shaman TBC for Bloodlust / Heroism and Water Shield.",
            "",
        ]
    if cls == "MAGE":
        lines += [
            "Existing Currentz style: `/cqs`, `[nomod]` max rank, `[mod:shift]` Rank 1, `#showtooltip` copies those conditions, `(rank 1)` has no space, `@cursor` ground spells, Ice Block toggle.",
            "TBC adds Outland city ports plus Theramore and Stonard. Shift still opens a portal.",
            "",
        ]
    if cls == "DRUID":
        lines += [
            "**Forms (typical Era index):** `1` Bear, `2` Aquatic, `3` Cat, `4` Travel. Test `form:N` if a macro misses.",
            "TBC adds Flight Form. Swift Flight Form is a Restoration talent. Tree of Life is Restoration.",
            "",
        ]
    for g in gset:
        scope = g.get("scope", "class")
        toon = g.get("character", "")
        heading = g["title"]
        if scope == "character" and toon:
            heading = f"{g['title']} — character-specific {toon}"
        elif scope == "global":
            heading = f"{g['title']} — global"
        else:
            heading = f"{g['title']} — class-specific"
        if g.get("gameVersion") == "TBC":
            heading = f"{heading} — TBC"
        lines += [f"## {heading}", "", f"{g['description']}", ""]
        for mid in g["macroIds"]:
            m = by_id[mid]
            lines += [f"### {m['name']} — `{m['id']}`", ""]
            if m.get("notes"):
                lines += [m["notes"], ""]
            lines += ["```", m["body"], "```", ""]
    return "\n".join(lines)


catalog = {
    "version": 1,
    "limits": {"account": 120, "character": 18, "bodyChars": 255, "nameChars": 16},
    "iconCdn": "https://wow.zamimg.com/images/wow/icons/large/{icon}.jpg",
    "iconNote": (
        "Texture names (ability_warrior_charge) from Interface/ICONS. "
        "Serve large 56px JPEGs from the Wowhead CDN (wow.zamimg.com). "
        "INV_MISC_QUESTIONMARK and numeric FileDataIDs fall back to inv_misc_questionmark. "
        "In-game, GetMacroIcons() lists the same set. Do not ship Blizzard BLP files."
    ),
    "groups": groups,
    "macros": macros,
}


def merge_custom() -> None:
    path = ROOT / "custom.json"
    if not path.exists():
        return
    data = json.loads(path.read_text())
    if not isinstance(data, dict):
        raise SystemExit("bad custom.json")
    groups_by_id = {g["id"]: g for g in groups}
    for raw in data.get("groups") or []:
        if not isinstance(raw, dict):
            continue
        gid = raw.get("id")
        if not isinstance(gid, str) or not gid.strip() or gid in groups_by_id:
            continue
        rec = {
            "id": gid,
            "title": raw.get("title") or gid,
            "class": raw.get("class") or "ALL",
            "spec": raw.get("spec") or "all",
            "tab": raw.get("tab") or "account",
            "scope": raw.get("scope") or "class",
            "description": raw.get("description") or "",
            "macroIds": [],
            "count": 0,
        }
        if raw.get("character"):
            rec["character"] = raw["character"]
        if raw.get("gameVersion") in {"ERA", "TBC"}:
            rec["gameVersion"] = raw["gameVersion"]
        groups.append(rec)
        groups_by_id[gid] = rec
    seen = {m["id"] for m in macros}
    for raw in data.get("macros") or []:
        if not isinstance(raw, dict):
            continue
        mid = raw.get("id")
        gid = raw.get("group")
        if not isinstance(mid, str) or not mid.strip() or mid in seen:
            continue
        if not isinstance(gid, str) or gid not in groups_by_id:
            continue
        group = groups_by_id[gid]
        name = raw.get("name") or "New"
        if not isinstance(name, str) or not name.strip() or len(name) > 16:
            raise SystemExit(f"bad custom name for {mid}")
        body = raw.get("body") if isinstance(raw.get("body"), str) else "#showtooltip"
        body = body.replace("\r\n", "\n")
        if len(body) > LIMIT:
            raise SystemExit(f"body too long: {mid}")
        rec = {
            "id": mid,
            "name": name,
            "scope": raw.get("scope") or group["scope"],
            "class": raw.get("class") or group["class"],
            "spec": raw.get("spec") or group["spec"],
            "tab": raw.get("tab") or group["tab"],
            "icon": raw.get("icon") or "inv_misc_questionmark",
            "group": gid,
            "source": "plan",
            "body": body,
            "chars": len(body),
        }
        character = raw.get("character") or group.get("character")
        if character:
            rec["character"] = character
        if raw.get("notes"):
            rec["notes"] = raw["notes"]
        if raw.get("gameVersion") in {"ERA", "TBC"}:
            rec["gameVersion"] = raw["gameVersion"]
        elif group.get("gameVersion"):
            rec["gameVersion"] = group["gameVersion"]
        macros.append(rec)
        seen.add(mid)
        group["macroIds"].append(mid)
        group["count"] = len(group["macroIds"])


def apply_overlays() -> None:
    merge_custom()
    ids = [m["id"] for m in macros]
    if len(ids) != len(set(ids)):
        raise SystemExit("duplicate macro id")

    prune_path = ROOT / "pruned.json"
    if prune_path.exists():
        drop = set(json.loads(prune_path.read_text()).get("ids", []))
        if drop:
            macros[:] = [m for m in macros if m["id"] not in drop]
            kept = []
            for g in groups:
                gids = [i for i in g["macroIds"] if i not in drop]
                if gids:
                    kept.append({**g, "macroIds": gids, "count": len(gids)})
            groups[:] = kept

    rename_path = ROOT / "renames.json"
    if rename_path.exists():
        by_id = json.loads(rename_path.read_text()).get("byId", {})
        if isinstance(by_id, dict):
            for m in macros:
                nxt = by_id.get(m["id"])
                if not nxt:
                    continue
                if not isinstance(nxt, str) or not nxt.strip():
                    raise SystemExit(f"bad rename for {m['id']}")
                if len(nxt) > 16:
                    raise SystemExit(f"name too long: {nxt}")
                m["name"] = nxt

    bodies_path = ROOT / "bodies.json"
    if bodies_path.exists():
        by_id = json.loads(bodies_path.read_text()).get("byId", {})
        if isinstance(by_id, dict):
            for m in macros:
                nxt = by_id.get(m["id"])
                if nxt is None:
                    continue
                if not isinstance(nxt, str):
                    raise SystemExit(f"bad body for {m['id']}")
                nxt = nxt.replace("\r\n", "\n")
                if len(nxt) > LIMIT:
                    raise SystemExit(f"body too long: {m['id']}")
                m["body"] = nxt
                m["chars"] = len(nxt)

    assert_unique_names(macros)


def assert_unique_names(items: list[dict]) -> None:
    seen_names: dict[str, str] = {}
    for m in items:
        n = m["name"]
        if n in seen_names:
            raise SystemExit(f"duplicate name {n!r}: {seen_names[n]} and {m['id']}")
        seen_names[n] = m["id"]


def emit_artifacts(catalog_obj: dict, *, write_json: bool) -> None:
    for m in catalog_obj["macros"]:
        body = strip_scope_comments(m["body"])
        m["body"] = body
        m["chars"] = len(body)
        m.pop("labelDropped", None)
    assert_unique_names(catalog_obj["macros"])
    if write_json:
        (ROOT / "catalog.json").write_text(json.dumps(catalog_obj, indent=2) + "\n")
    (ROOT / "catalog.md").write_text(emit_md(catalog_obj))
    (ROOT.parents[1] / "defaults" / "catalog.lua").write_text(emit_deck_catalog(catalog_obj))
    class_files = {
        "ALL": "shared.md",
        "WARRIOR": "warrior.md",
        "PALADIN": "paladin.md",
        "HUNTER": "hunter.md",
        "ROGUE": "rogue.md",
        "PRIEST": "priest.md",
        "SHAMAN": "shaman.md",
        "MAGE": "mage.md",
        "WARLOCK": "warlock.md",
        "DRUID": "druid.md",
    }
    for cls, fname in class_files.items():
        (ROOT / fname).write_text(emit_class_md(cls, catalog_obj))
    records = catalog_obj["macros"]
    over = [m for m in records if m["chars"] > LIMIT]
    print(f"wrote {len(records)} macros in {len(catalog_obj['groups'])} groups")
    print("label dropped:", sum(1 for m in records if m.get("labelDropped")))
    if over:
        raise SystemExit(over)


DECK_IDS = [
    "w-hm", "w-charge", "w-c", "w-interrupt", "w-bloodrage", "w-intimid", "w-disarm",
    "w-br", "w-shout", "w-o", "w-h", "w-ex", "w-rend", "w-tc", "w-ds",
    "w-major-cd", "w-mock", "w-revenge", "w-s", "w-sblock", "w-taunt", "w-ww",
    "w-chall", "w-b", "w-d-def", "w-bs", "w-sweep", "w-ms", "w-slam",
    "w-deathwish", "w-bt", "w-ls", "w-sslam", "w-concussion", "w-retal", "w-reck",
]


def lua_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'


def emit_deck_catalog(catalog_obj: dict) -> str:
    lines = [
        "--[[",
        "  Purpose: Catalog macros for the Macro Library.",
        "  Deps: ShadowUI addon table",
        "  Public: populates ShadowUI.Defaults.catalog",
        "  Notes: Bodies copy docs/macros/catalog.json. Rebuild with build_catalog.py.",
        "]]",
        "",
        'local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")',
        "Addon.Defaults.catalog = Addon.Defaults.catalog or {}",
        "local C = Addon.Defaults.catalog",
        "",
    ]
    for m in catalog_obj.get("macros") or []:
        mid = m.get("id") if isinstance(m, dict) else None
        if not isinstance(mid, str) or not m.get("name") or not m.get("body"):
            continue
        icon = m.get("icon") if isinstance(m.get("icon"), str) and m.get("icon") else "inv_misc_questionmark"
        lines += [
            f"C[{lua_str(mid)}] = {{",
            f"  name = {lua_str(m['name'])},",
            f"  icon = {lua_str(icon)},",
            f"  body = {lua_str(m['body'])},",
            "}",
            "",
        ]
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    if "--from-source" in sys.argv:
        apply_overlays()
        emit_artifacts(catalog, write_json=True)
    else:
        catalog_obj = json.loads((ROOT / "catalog.json").read_text())
        emit_artifacts(catalog_obj, write_json=True)
