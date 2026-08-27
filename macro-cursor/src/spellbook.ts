import type { WowClass } from "./types";

export type SpellRank = {
  spellId: number;
  name: string;
  rank: string;
  level: number;
  icon: string;
};

export type SpellFamily = {
  name: string;
  icon: string;
  maxSpellId: number;
  /** Max-rank effect text from Wowhead. Used to explain nested macro abilities. */
  description?: string;
  ranks: SpellRank[];
};

export type SpellLine = {
  skillId: number;
  title: string;
  families: SpellFamily[];
};

export type Spellbook = {
  version: number;
  source?: string;
  classes: Partial<Record<WowClass, SpellLine[]>>;
  /** Racial traits and profession skill lines. Shown after class tabs. */
  shared?: SpellLine[];
};

export type Pickup =
  | { kind: "macro"; id: string; name: string; icon: string; fromSlot?: number }
  | {
      kind: "spell";
      id: string;
      name: string;
      icon: string;
      spellId: number;
      rank: string;
      fromSlot?: number;
    };

export const PICKUP_MIME = "application/x-shadowui-pickup";

export function spellActionId(spellId: number): string {
  return `spell:${spellId}`;
}

export function rankNumber(rank: string): number {
  const m = /(\d+)/.exec(rank || "");
  return m ? Number(m[1]) : 0;
}

export function isEraSpell(row: { id?: number; seasonId?: unknown; name?: string }): boolean {
  if (row.seasonId !== undefined) return false;
  if ((row.id ?? 0) >= 400000) return false;
  if ((row.name ?? "").startsWith("Engrave ")) return false;
  return true;
}

export function nestFamilies(
  rows: { id: number; name: string; rank?: string; level?: number; icon?: string }[],
): SpellFamily[] {
  const byName = new Map<string, typeof rows>();
  for (const row of rows) {
    const list = byName.get(row.name) ?? [];
    list.push(row);
    byName.set(row.name, list);
  }
  return [...byName.entries()]
    .sort((a, b) => a[0].localeCompare(b[0]))
    .map(([name, list]) => {
      const ranks = [...list]
        .sort(
          (a, b) =>
            rankNumber(a.rank ?? "") - rankNumber(b.rank ?? "") ||
            (a.level ?? 0) - (b.level ?? 0) ||
            a.id - b.id,
        )
        .map((r) => ({
          spellId: r.id,
          name,
          rank: r.rank ?? "",
          level: r.level ?? 0,
          icon: r.icon ?? "",
        }));
      const last = ranks[ranks.length - 1]!;
      return {
        name,
        icon: last.icon || ranks.find((r) => r.icon)?.icon || "",
        maxSpellId: last.spellId,
        ranks,
      };
    });
}

export function linesForClass(book: Spellbook, classId: WowClass): SpellLine[] {
  return [...(book.classes[classId] ?? []), ...(book.shared ?? [])];
}

export function findFamily(book: Spellbook, classId: WowClass, spellId: number): SpellFamily | undefined {
  for (const line of linesForClass(book, classId)) {
    const family = line.families.find((f) => f.ranks.some((r) => r.spellId === spellId));
    if (family) return family;
  }
  return undefined;
}

export function findSpell(book: Spellbook, classId: WowClass, spellId: number): SpellRank | undefined {
  const family = findFamily(book, classId, spellId);
  return family?.ranks.find((r) => r.spellId === spellId);
}

export function familyPlaced(family: SpellFamily, placed: Set<string>): boolean {
  return family.ranks.some((r) => placed.has(spellActionId(r.spellId)));
}

export function normalizeAbilityName(name: string): string {
  return name.trim().toLowerCase().replace(/\s+/g, " ");
}

function addSpellToken(names: Set<string>, raw: string): void {
  let token = raw.replace(/\[[^\]]*\]/g, " ").trim();
  token = token.replace(/^!+/, "").trim();
  token = token.replace(/\s*\(Rank\s+\d+\)\s*$/i, "").trim();
  if (!token || /^\d+$/.test(token) || /^item:/i.test(token)) return;
  names.add(token);
}

export function spellNamesFromBody(body: string): string[] {
  const names = new Set<string>();
  for (const raw of body.replace(/\r\n/g, "\n").split("\n")) {
    const line = raw.trim();
    if (!line) continue;
    const tip = /^#showtooltip(?:\s+(.+))?$/i.exec(line);
    if (tip) {
      if (tip[1]) {
        const rest = tip[1].replace(/\[[^\]]*\]/g, " ");
        for (const part of rest.split(/[;,]/)) addSpellToken(names, part);
      }
      continue;
    }
    if (line.startsWith("#")) continue;
    const cmd = /^\/(castsequence|castrandom|cast|use)\b(.*)$/i.exec(line);
    if (!cmd) continue;
    let rest = cmd[2].trim();
    rest = rest.replace(/^reset=\S+\s+/i, "");
    rest = rest.replace(/\[[^\]]*\]/g, " ");
    for (const part of rest.split(/[;,]/)) addSpellToken(names, part);
  }
  return [...names];
}

export type AbilityRef = { id: string; body: string };

export type AbilityTip = { name: string; description: string };

export type SlotTip = {
  kind: "macro" | "spell" | "empty";
  keybind: string;
  name: string;
  notes?: string;
  body?: string;
  rank?: string;
  abilities: AbilityTip[];
};

export function familyIndex(book: Spellbook, classId: WowClass): Map<string, SpellFamily> {
  const index = new Map<string, SpellFamily>();
  for (const line of linesForClass(book, classId)) {
    for (const family of line.families) {
      const key = normalizeAbilityName(family.name);
      if (!index.has(key)) index.set(key, family);
    }
  }
  return index;
}

export function abilitiesFromBody(body: string, families: Map<string, SpellFamily>): AbilityTip[] {
  return spellNamesFromBody(body).map((name) => {
    const family = families.get(normalizeAbilityName(name));
    return { name: family?.name ?? name, description: family?.description ?? "" };
  });
}

export function slotTip(input: {
  key: string;
  action?: { id: string; name: string; rank?: string };
  macro?: { name: string; body: string; notes?: string };
  families: Map<string, SpellFamily>;
}): SlotTip {
  const keybind = input.key || "unbound";
  if (!input.action) {
    return { kind: "empty", keybind, name: "", abilities: [] };
  }
  const isSpell = input.action.id.startsWith("spell:");
  if (input.macro || !isSpell) {
    const body = input.macro?.body ?? "";
    return {
      kind: "macro",
      keybind,
      name: input.macro?.name ?? input.action.name,
      notes: input.macro?.notes || undefined,
      body: body || undefined,
      abilities: body ? abilitiesFromBody(body, input.families) : [],
    };
  }
  const family = input.families.get(normalizeAbilityName(input.action.name));
  return {
    kind: "spell",
    keybind,
    name: input.action.name,
    rank: input.action.rank || undefined,
    abilities: [
      {
        name: family?.name ?? input.action.name,
        description: family?.description ?? "",
      },
    ],
  };
}

export function abilityRefIndex(macros: AbilityRef[]): Map<string, string[]> {
  const index = new Map<string, string[]>();
  for (const rec of macros) {
    for (const name of spellNamesFromBody(rec.body)) {
      const key = normalizeAbilityName(name);
      const list = index.get(key) ?? [];
      if (!list.includes(rec.id)) list.push(rec.id);
      index.set(key, list);
    }
  }
  return index;
}

export function refsForFamily(family: SpellFamily, index: Map<string, string[]>): string[] {
  return index.get(normalizeAbilityName(family.name)) ?? [];
}

export function familyReferenced(family: SpellFamily, index: Map<string, string[]>): boolean {
  return refsForFamily(family, index).length > 0;
}

export function familyActionIds(family: SpellFamily): string[] {
  return family.ranks.map((r) => spellActionId(r.spellId));
}

export function pickupFromFamily(family: SpellFamily): Pickup {
  const max = family.ranks[family.ranks.length - 1]!;
  return {
    kind: "spell",
    id: spellActionId(family.maxSpellId),
    name: family.name,
    icon: family.icon || max.icon,
    spellId: family.maxSpellId,
    rank: max.rank,
  };
}

export function pickupFromRank(rank: SpellRank): Pickup {
  return {
    kind: "spell",
    id: spellActionId(rank.spellId),
    name: rank.name,
    icon: rank.icon,
    spellId: rank.spellId,
    rank: rank.rank,
  };
}

function withFromSlot<T extends Pickup>(pickup: T, fromSlot: unknown): T {
  if (typeof fromSlot === "number" && Number.isInteger(fromSlot) && fromSlot > 0) {
    return { ...pickup, fromSlot };
  }
  return pickup;
}

export function parsePickup(raw: string): Pickup | undefined {
  try {
    const v = JSON.parse(raw) as Partial<Pickup>;
    if (v.kind === "macro" && typeof v.id === "string" && typeof v.name === "string") {
      return withFromSlot(
        { kind: "macro", id: v.id, name: v.name, icon: typeof v.icon === "string" ? v.icon : "" },
        v.fromSlot,
      );
    }
    if (
      v.kind === "spell" &&
      typeof v.id === "string" &&
      typeof v.name === "string" &&
      typeof v.spellId === "number"
    ) {
      return withFromSlot(
        {
          kind: "spell",
          id: v.id,
          name: v.name,
          icon: typeof v.icon === "string" ? v.icon : "",
          spellId: v.spellId,
          rank: typeof v.rank === "string" ? v.rank : "",
        },
        v.fromSlot,
      );
    }
  } catch {
    return undefined;
  }
  return undefined;
}

export function encodePickup(p: Pickup): string {
  return JSON.stringify(p);
}

export function pickupFromDataTransfer(getData: (type: string) => string): Pickup | undefined {
  return parsePickup(getData(PICKUP_MIME)) ?? parsePickup(getData("text/plain"));
}

export function writePickup(
  dt: { setData: (type: string, value: string) => void; effectAllowed: string },
  pickup: Pickup,
  effect: "copy" | "move",
): void {
  const encoded = encodePickup(pickup);
  dt.effectAllowed = effect;
  dt.setData(PICKUP_MIME, encoded);
  dt.setData("text/plain", encoded);
}
