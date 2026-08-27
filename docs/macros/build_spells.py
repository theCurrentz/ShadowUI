#!/usr/bin/env python3
"""Build Classic Era class, racial, and profession spellbook JSON from Wowhead."""

from __future__ import annotations

import html
import json
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from collections.abc import Callable
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "spells.json"

CLASS_PAGES = [
    ("WARRIOR", "warrior"),
    ("PALADIN", "paladin"),
    ("HUNTER", "hunter"),
    ("ROGUE", "rogue"),
    ("PRIEST", "priest"),
    ("SHAMAN", "shaman"),
    ("MAGE", "mage"),
    ("WARLOCK", "warlock"),
    ("DRUID", "druid"),
]

SKILL_TITLES = {
    26: "Arms",
    256: "Fury",
    257: "Protection",
    184: "Holy",
    267: "Protection",
    594: "Retribution",
    50: "Beast Mastery",
    163: "Marksmanship",
    51: "Survival",
    253: "Assassination",
    38: "Combat",
    39: "Subtlety",
    613: "Discipline",
    56: "Holy",
    78: "Shadow",
    375: "Elemental Combat",
    373: "Enhancement",
    374: "Restoration",
    237: "Arcane",
    8: "Fire",
    6: "Frost",
    355: "Affliction",
    354: "Demonology",
    593: "Destruction",
    574: "Balance",
    134: "Feral Combat",
    573: "Restoration",
    171: "Alchemy",
    164: "Blacksmithing",
    333: "Enchanting",
    202: "Engineering",
    182: "Herbalism",
    165: "Leatherworking",
    186: "Mining",
    393: "Skinning",
    197: "Tailoring",
    185: "Cooking",
    129: "First Aid",
    356: "Fishing",
}

LINE_ORDER = {
    "WARRIOR": [26, 256, 257],
    "PALADIN": [184, 267, 594],
    "HUNTER": [50, 163, 51],
    "ROGUE": [253, 38, 39],
    "PRIEST": [613, 56, 78],
    "SHAMAN": [375, 373, 374],
    "MAGE": [237, 8, 6],
    "WARLOCK": [355, 354, 593],
    "DRUID": [574, 134, 573],
}

RACIAL_SKILL_ID = -4
RACIAL_URL = "https://www.wowhead.com/classic/spells/racial-traits"
PROFESSION_URLS = [
    "https://www.wowhead.com/classic/spells/professions/alchemy",
    "https://www.wowhead.com/classic/spells/professions/blacksmithing",
    "https://www.wowhead.com/classic/spells/professions/enchanting",
    "https://www.wowhead.com/classic/spells/professions/engineering",
    "https://www.wowhead.com/classic/spells/professions/herbalism",
    "https://www.wowhead.com/classic/spells/professions/leatherworking",
    "https://www.wowhead.com/classic/spells/professions/mining",
    "https://www.wowhead.com/classic/spells/professions/skinning",
    "https://www.wowhead.com/classic/spells/professions/tailoring",
    "https://www.wowhead.com/classic/spells/secondary-skills/cooking",
    "https://www.wowhead.com/classic/spells/secondary-skills/first-aid",
    "https://www.wowhead.com/classic/spells/secondary-skills/fishing",
]
PROFESSION_ORDER = [171, 164, 333, 202, 182, 165, 186, 393, 197, 185, 129, 356]

UA = {"User-Agent": "ShadowUI-MacroCursor/1.0 (Classic Era spellbook)"}


def js_array_to_json(src: str) -> str:
    return re.sub(r"([{\[,]\s*)([A-Za-z_][\w]*)\s*:", r'\1"\2":', src)


def rank_number(rank: str) -> int:
    m = re.search(r"(\d+)", rank or "")
    return int(m.group(1)) if m else 0


def is_era(row: dict) -> bool:
    if "seasonId" in row:
        return False
    if int(row.get("id") or 0) >= 400000:
        return False
    name = str(row.get("name") or "")
    if name.startswith("Engrave "):
        return False
    return True


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=30) as res:
        return res.read().decode("utf-8", "replace")


def fetch_list(url: str) -> list[dict]:
    html = fetch(url)
    match = re.search(r"var listviewspells = (\[.*?\]);", html, re.S)
    if not match:
        raise RuntimeError(f"no listview for {url}")
    return json.loads(js_array_to_json(match.group(1)))


def fetch_class(slug: str) -> list[dict]:
    return fetch_list(f"https://www.wowhead.com/classic/spells/abilities/{slug}")


def is_profession_ability(row: dict) -> bool:
    """Keep skill ranks and bar spells. Drop recipes."""
    return not row.get("reagents") and not row.get("creates")


def strip_tooltip_html(raw: str) -> str:
    """Keep the Wowhead effect text. Drop range, cooldown, and requirement chrome."""
    if not raw:
        return ""
    match = re.search(r'<div class="q">(.*?)</div>', raw, re.S | re.I)
    text = match.group(1) if match else raw
    text = re.sub(r"<br\s*/?>", "\n", text, flags=re.I)
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text).replace("\xa0", " ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\s*\n\s*", " ", text)
    return text.strip()


def fetch_tip(spell_id: int) -> tuple[str, str]:
    try:
        body = fetch(f"https://nether.wowhead.com/classic/tooltip/spell/{spell_id}")
        data = json.loads(body)
        icon = str(data.get("icon") or "").strip().lower()
        desc = strip_tooltip_html(str(data.get("tooltip") or ""))
        return icon, desc
    except Exception:
        return "", ""


def fetch_icon(spell_id: int) -> str:
    icon, _desc = fetch_tip(spell_id)
    return icon


def skill_id(row: dict) -> int:
    skills = row.get("skill") or []
    if isinstance(skills, list) and skills:
        return int(skills[0])
    return 0


def pack_families(
    by_name: dict[str, list[dict]],
    icons: dict[int, str],
    descriptions: dict[int, str] | None = None,
) -> list[dict]:
    families = []
    descriptions = descriptions or {}
    for name, ranks in sorted(by_name.items(), key=lambda kv: kv[0].lower()):
        ranks.sort(key=lambda r: (rank_number(str(r.get("rank") or "")), int(r.get("level") or 0), int(r["id"])))
        packed = []
        for r in ranks:
            spell_id = int(r["id"])
            packed.append(
                {
                    "spellId": spell_id,
                    "name": name,
                    "rank": str(r.get("rank") or "").strip(),
                    "level": int(r.get("level") or 0),
                    "icon": icons.get(spell_id, ""),
                }
            )
        max_rank = packed[-1]
        icon = max_rank["icon"] or next((p["icon"] for p in packed if p["icon"]), "")
        if icon:
            for p in packed:
                if not p["icon"]:
                    p["icon"] = icon
        family = {"name": name, "icon": icon, "maxSpellId": max_rank["spellId"], "ranks": packed}
        desc = descriptions.get(max_rank["spellId"], "")
        if desc:
            family["description"] = desc
        families.append(family)
    return families


def nest_lines(
    rows: list[dict],
    icons: dict[int, str],
    order: list[int],
    line_of: Callable[[dict], int],
    titles: dict[int, str],
    descriptions: dict[int, str] | None = None,
) -> list[dict]:
    by_line: dict[int, dict[str, list[dict]]] = {}
    for row in rows:
        if not is_era(row):
            continue
        line = line_of(row)
        by_line.setdefault(line, {}).setdefault(str(row["name"]), []).append(row)

    line_ids = [sid for sid in order if sid in by_line]
    for sid in sorted(by_line):
        if sid not in line_ids:
            line_ids.append(sid)

    lines = []
    for sid in line_ids:
        title = titles.get(sid, "Other" if sid == 0 else f"Skill {sid}")
        lines.append(
            {
                "skillId": sid,
                "title": title,
                "families": pack_families(by_line[sid], icons, descriptions),
            }
        )
    return lines


def nest_class(
    class_id: str,
    rows: list[dict],
    icons: dict[int, str],
    descriptions: dict[int, str] | None = None,
) -> list[dict]:
    return nest_lines(rows, icons, LINE_ORDER.get(class_id, []), skill_id, SKILL_TITLES, descriptions)


def max_ids(rows: list[dict], line_of: Callable[[dict], int]) -> set[int]:
    by_name: dict[tuple[int, str], list[dict]] = {}
    for row in rows:
        if not is_era(row):
            continue
        by_name.setdefault((line_of(row), str(row["name"])), []).append(row)
    needed: set[int] = set()
    for group in by_name.values():
        group.sort(
            key=lambda r: (rank_number(str(r.get("rank") or "")), int(r.get("level") or 0), int(r["id"]))
        )
        needed.add(int(group[-1]["id"]))
    return needed


def fetch_shared() -> tuple[list[dict], list[dict], set[int]]:
    racial_rows = fetch_list(RACIAL_URL)
    racial_era = [r for r in racial_rows if is_era(r)]
    print(f"Racial: {len(racial_era)} era / {len(racial_rows)}")

    profession_rows: list[dict] = []
    seen_ids: set[int] = set()
    for url in PROFESSION_URLS:
        rows = fetch_list(url)
        kept = [r for r in rows if is_era(r) and is_profession_ability(r)]
        for row in kept:
            sid = int(row["id"])
            if sid in seen_ids:
                continue
            seen_ids.add(sid)
            profession_rows.append(row)
        print(f"{url.rsplit('/', 1)[-1]}: {len(kept)} abilities / {len(rows)}")

    needed = max_ids(racial_era, lambda _r: RACIAL_SKILL_ID)
    needed |= max_ids(profession_rows, skill_id)
    return racial_era, profession_rows, needed


def fetch_tips(needed: set[int]) -> tuple[dict[int, str], dict[int, str]]:
    icons: dict[int, str] = {}
    descriptions: dict[int, str] = {}
    with ThreadPoolExecutor(max_workers=12) as pool:
        futs = {pool.submit(fetch_tip, sid): sid for sid in needed}
        for i, fut in enumerate(as_completed(futs), 1):
            sid = futs[fut]
            icon, desc = fut.result()
            icons[sid] = icon
            if desc:
                descriptions[sid] = desc
            if i % 100 == 0:
                print(f"tips {i}/{len(needed)}")
    return icons, descriptions


def fetch_icons(needed: set[int]) -> dict[int, str]:
    icons, _descriptions = fetch_tips(needed)
    return icons


def apply_descriptions(lines: list[dict], descriptions: dict[int, str]) -> None:
    for line in lines:
        for family in line.get("families") or []:
            desc = descriptions.get(int(family.get("maxSpellId") or 0), "")
            if desc:
                family["description"] = desc
            else:
                family.pop("description", None)


def walk_max_ids(lines: list[dict]) -> set[int]:
    needed: set[int] = set()
    for line in lines:
        for family in line.get("families") or []:
            sid = int(family.get("maxSpellId") or 0)
            if sid:
                needed.add(sid)
    return needed


def shared_lines(
    racial_era: list[dict],
    profession_rows: list[dict],
    icons: dict[int, str],
    descriptions: dict[int, str] | None = None,
) -> list[dict]:
    racial = nest_lines(
        racial_era,
        icons,
        [RACIAL_SKILL_ID],
        lambda _r: RACIAL_SKILL_ID,
        {RACIAL_SKILL_ID: "Racial"},
        descriptions,
    )
    professions = nest_lines(
        profession_rows, icons, PROFESSION_ORDER, skill_id, SKILL_TITLES, descriptions
    )
    return racial + professions


def backfill_descriptions() -> None:
    payload = json.loads(OUT.read_text())
    needed: set[int] = set()
    for lines in payload.get("classes", {}).values():
        needed |= walk_max_ids(lines)
    needed |= walk_max_ids(payload.get("shared") or [])
    print(f"descriptions {len(needed)}")
    _icons, descriptions = fetch_tips(needed)
    for lines in payload.get("classes", {}).values():
        apply_descriptions(lines, descriptions)
    apply_descriptions(payload.get("shared") or [], descriptions)
    OUT.write_text(json.dumps(payload, indent=2) + "\n")
    print(f"wrote descriptions {OUT}")


def main() -> None:
    if "--descriptions" in sys.argv:
        backfill_descriptions()
        return

    racial_era, profession_rows, shared_needed = fetch_shared()
    shared_only = "--shared-only" in sys.argv

    if shared_only and OUT.exists():
        icons, descriptions = fetch_tips(shared_needed)
        payload = json.loads(OUT.read_text())
        payload["source"] = "wowhead classic abilities, racial traits, professions"
        payload["shared"] = shared_lines(racial_era, profession_rows, icons, descriptions)
        OUT.write_text(json.dumps(payload, indent=2) + "\n")
        print(f"wrote shared tabs {OUT}")
        return

    class_rows: dict[str, list[dict]] = {}
    needed: set[int] = set(shared_needed)
    for class_id, slug in CLASS_PAGES:
        rows = fetch_class(slug)
        class_rows[class_id] = rows
        era = [r for r in rows if is_era(r)]
        needed |= max_ids(era, skill_id)
        print(f"{class_id}: {len(era)} era / {len(rows)}")

    icons, descriptions = fetch_tips(needed)
    classes = {
        cid: nest_class(cid, class_rows[cid], icons, descriptions) for cid, _ in CLASS_PAGES
    }
    payload = {
        "version": 1,
        "source": "wowhead classic abilities, racial traits, professions",
        "classes": classes,
        "shared": shared_lines(racial_era, profession_rows, icons, descriptions),
    }
    OUT.write_text(json.dumps(payload, indent=2) + "\n")
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
