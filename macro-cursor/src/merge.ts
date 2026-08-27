import type { Catalog, Macro, Source, Tab, WowClass } from "./types.ts";
import type { CacheMacro } from "./cache.ts";
import { normalizeBody } from "./cache.ts";

export type LiveAccount = {
  account: string;
  path: string;
  macros: CacheMacro[];
  healed?: string;
};

export type LiveCharacter = {
  account: string;
  realm: string;
  name: string;
  class: WowClass | null;
  path: string;
  macros: CacheMacro[];
  healed?: string;
};

export type SyncResponse = {
  wowPath: string;
  wowRunning: boolean;
  wrote: boolean;
  accounts: LiveAccount[];
  characters: LiveCharacter[];
  notes: string[];
};

export type MergedLive = {
  catalog: Catalog;
  accountIds: string[];
  characterIds: string[];
  notes: string[];
};

let ingameSeq = 0;

function iconSlug(icon: string): string {
  const s = icon.trim();
  if (!s) return "inv_misc_questionmark";
  if (/^\d+$/.test(s)) return s;
  return s.toLowerCase();
}

function matchCatalog(catalog: Catalog, live: CacheMacro, tab: Tab): Macro | undefined {
  const liveNorm = normalizeBody(live.body);
  const sameName = catalog.macros.filter((m) => m.name === live.name && m.tab === tab);
  const named = sameName.find((m) => normalizeBody(m.body) === liveNorm) ?? sameName[0];
  if (named) return named;
  return catalog.macros.find((m) => m.tab === tab && normalizeBody(m.body) === liveNorm);
}

function fromLive(
  live: CacheMacro,
  tab: Tab,
  cls: WowClass,
  toon: string | undefined,
): Macro {
  ingameSeq += 1;
  return {
    id: `ingame-${tab}-${ingameSeq}`,
    name: live.name.slice(0, 16),
    scope: tab === "account" ? "global" : "character",
    class: cls,
    spec: "all",
    character: toon,
    tab,
    icon: iconSlug(live.icon),
    group: toon ? `ingame-${toon}` : "ingame-account",
    source: "ingame" as Source,
    body: live.body,
    chars: live.body.length,
    notes: "Imported from in-game macros-cache.txt on startup.",
  };
}

function adoptLiveBody(base: Macro, live: CacheMacro): Macro {
  const same = normalizeBody(base.body) === normalizeBody(live.body);
  if (same) return { ...base, icon: base.icon || iconSlug(live.icon) };
  return {
    ...base,
    body: live.body,
    chars: live.body.length,
    icon: iconSlug(live.icon) || base.icon,
    source: "ingame",
    notes: [base.notes, "In-game body replaced the catalog body."]
      .filter(Boolean)
      .join(" "),
  };
}

function upsertGroup(catalog: Catalog, id: string, title: string, cls: WowClass, tab: Tab, toon: string | undefined, macroId: string): void {
  let g = catalog.groups.find((x) => x.id === id);
  if (!g) {
    g = {
      id,
      title,
      class: cls,
      spec: "all",
      tab,
      scope: toon ? "character" : "global",
      character: toon,
      description: "Macros read from the live Classic Era cache on startup.",
      macroIds: [],
      count: 0,
    };
    catalog.groups.push(g);
  }
  if (!g.macroIds.includes(macroId)) g.macroIds.push(macroId);
  g.count = g.macroIds.length;
}

export function mergeLive(
  catalog: Catalog,
  live: SyncResponse,
  accountName: string,
  toon: LiveCharacter | undefined,
): MergedLive {
  ingameSeq = 0;
  const session: Catalog = structuredClone(catalog);
  const notes = [...live.notes];
  const acc = live.accounts.find((a) => a.account === accountName) ?? live.accounts[0];
  const accountIds: string[] = [];
  const characterIds: string[] = [];
  let imported = 0;
  let replaced = 0;

  function ingest(list: CacheMacro[], tab: Tab, cls: WowClass, name: string | undefined, ids: string[]): void {
    for (const liveMacro of list) {
      const hit = matchCatalog(session, liveMacro, tab);
      let rec: Macro;
      if (hit) {
        rec = adoptLiveBody(hit, liveMacro);
        if (rec.source === "ingame" && rec.body !== hit.body) replaced += 1;
        const i = session.macros.findIndex((m) => m.id === hit.id);
        if (i >= 0) session.macros[i] = rec;
      } else {
        rec = fromLive(liveMacro, tab, cls, name);
        session.macros.push(rec);
        const gid = name ? `ingame-${name}` : "ingame-account";
        const title = name ? `In-game ${name}` : "In-game account";
        upsertGroup(session, gid, title, cls, tab, name, rec.id);
        imported += 1;
      }
      ids.push(rec.id);
    }
  }

  if (acc) ingest(acc.macros, "account", "ALL", undefined, accountIds);
  if (toon) ingest(toon.macros, "character", toon.class ?? "ALL", toon.name, characterIds);
  if (imported) notes.push(`Imported ${imported} in-game macros.`);
  if (replaced) notes.push(`Kept ${replaced} in-game bodies over the catalog.`);
  if (acc) notes.unshift(`${acc.account}: ${accountIds.length} account macros.`);
  if (toon) notes.unshift(`${toon.realm}/${toon.name}: ${characterIds.length} character macros.`);

  return { catalog: session, accountIds, characterIds, notes };
}

export const CORE_GROUP: Record<Exclude<WowClass, "ALL">, string> = {
  WARRIOR: "warrior-core",
  PALADIN: "paladin-ret",
  HUNTER: "hunter-core",
  ROGUE: "rogue-combat",
  PRIEST: "priest-holy",
  SHAMAN: "shaman-enhance",
  MAGE: "mage-ports-alliance",
  WARLOCK: "warlock-core",
  DRUID: "druid-feral",
};

export const HORDE_REALMS = new Set(["Nightfall", "Living Flame"]);
