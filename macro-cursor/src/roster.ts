import type { WowClass } from "./types.ts";

export type RosterCharacter = {
  account: string;
  realm: string;
  name: string;
  class: WowClass | null;
  level: number | null;
};

export type RosterResponse = {
  wowPath: string;
  characters: RosterCharacter[];
};

const CLASS_IDS: WowClass[] = [
  "WARRIOR",
  "PALADIN",
  "HUNTER",
  "ROGUE",
  "PRIEST",
  "SHAMAN",
  "MAGE",
  "WARLOCK",
  "DRUID",
];

export function rosterKey(character: {
  account: string;
  realm: string;
  name: string;
}): string {
  return `${character.account}/${character.realm}/${character.name}`;
}

export function asWowClass(value: string | null | undefined): WowClass | null {
  if (!value) return null;
  const id = value.toUpperCase() as WowClass;
  return CLASS_IDS.includes(id) ? id : null;
}

export function nitLookupKey(realm: string, name: string): string {
  return `${realm}/${name}`;
}

export function attuneLookupKey(realm: string, name: string): string {
  return `${name}-${realm}`;
}

export type AddonCharMeta = {
  class: WowClass | null;
  level: number | null;
};

function sliceBalanced(src: string, open: number): { inner: string; end: number } | null {
  if (src[open] !== "{") return null;
  let depth = 0;
  let inStr = false;
  for (let i = open; i < src.length; i += 1) {
    const ch = src[i];
    if (inStr) {
      if (ch === "\\") {
        i += 1;
        continue;
      }
      if (ch === '"') inStr = false;
      continue;
    }
    if (ch === '"') {
      inStr = true;
      continue;
    }
    if (ch === "{") depth += 1;
    else if (ch === "}") {
      depth -= 1;
      if (depth === 0) return { inner: src.slice(open + 1, i), end: i + 1 };
    }
  }
  return null;
}

function skipSpace(src: string, i: number): number {
  while (i < src.length && /\s/.test(src[i]!)) i += 1;
  return i;
}

function readQuoted(src: string, i: number): { value: string; end: number } | null {
  if (src[i] !== '"') return null;
  let out = "";
  for (let n = i + 1; n < src.length; n += 1) {
    const ch = src[n];
    if (ch === "\\") {
      out += src[n + 1] ?? "";
      n += 1;
      continue;
    }
    if (ch === '"') return { value: out, end: n + 1 };
    out += ch;
  }
  return null;
}

function readScalar(src: string, i: number): { value: string; end: number } | null {
  i = skipSpace(src, i);
  const quoted = readQuoted(src, i);
  if (quoted) return quoted;
  const m = /^-?\d+(?:\.\d+)?/.exec(src.slice(i));
  if (m) return { value: m[0], end: i + m[0].length };
  return null;
}

function walkTable(
  inner: string,
  onTable: (key: string, tableInner: string) => void,
  onScalar: (key: string, value: string) => void,
): void {
  let i = 0;
  while (i < inner.length) {
    i = skipSpace(inner, i);
    if (i >= inner.length) break;
    if (inner.startsWith('["', i)) {
      const close = inner.indexOf('"]', i + 2);
      if (close < 0) break;
      const key = inner.slice(i + 2, close);
      i = skipSpace(inner, close + 2);
      if (inner[i] !== "=") {
        i += 1;
        continue;
      }
      i = skipSpace(inner, i + 1);
      if (inner[i] === "{") {
        const table = sliceBalanced(inner, i);
        if (!table) break;
        onTable(key, table.inner);
        i = table.end;
        continue;
      }
      const scalar = readScalar(inner, i);
      if (!scalar) {
        i += 1;
        continue;
      }
      onScalar(key, scalar.value);
      i = scalar.end;
      continue;
    }
    if (inner[i] === "{") {
      const table = sliceBalanced(inner, i);
      if (!table) break;
      i = table.end;
      continue;
    }
    i += 1;
  }
}

function tableScalars(inner: string): Record<string, string> {
  const fields: Record<string, string> = {};
  walkTable(
    inner,
    () => undefined,
    (key, value) => {
      fields[key] = value;
    },
  );
  return fields;
}

function parseLevel(value: string | undefined): number | null {
  if (!value) return null;
  const n = Number(value);
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.floor(n);
}

export function parseNitMyChars(src: string): Map<string, AddonCharMeta> {
  const out = new Map<string, AddonCharMeta>();
  let from = 0;
  while (from < src.length) {
    const hit = src.indexOf('["myChars"]', from);
    if (hit < 0) break;
    const brace = src.indexOf("{", hit);
    if (brace < 0) break;
    const table = sliceBalanced(src, brace);
    if (!table) break;
    from = table.end;
    walkTable(
      table.inner,
      (name, inner) => {
        const fields = tableScalars(inner);
        const realm = fields.realm;
        const player = fields.playerName || name;
        if (!realm) return;
        out.set(nitLookupKey(realm, player), {
          class: asWowClass(fields.classEnglish),
          level: parseLevel(fields.level),
        });
      },
      () => undefined,
    );
  }
  return out;
}

export function parseAttuneToons(src: string): Map<string, AddonCharMeta> {
  const out = new Map<string, AddonCharMeta>();
  const hit = src.indexOf('["toons"]');
  if (hit < 0) return out;
  const brace = src.indexOf("{", hit);
  if (brace < 0) return out;
  const table = sliceBalanced(src, brace);
  if (!table) return out;
  walkTable(
    table.inner,
    (key, inner) => {
      const fields = tableScalars(inner);
      const cls = asWowClass(fields.class);
      const level = parseLevel(fields.level);
      if (!cls && level == null) return;
      out.set(key, { class: cls, level });
    },
    () => undefined,
  );
  return out;
}

export function mergeCharMeta(
  primary: AddonCharMeta | undefined,
  fallback: AddonCharMeta | undefined,
): AddonCharMeta {
  return {
    class: primary?.class ?? fallback?.class ?? null,
    level: primary?.level ?? fallback?.level ?? null,
  };
}

const CLASS_ORDER = new Map(CLASS_IDS.map((id, i) => [id, i]));

export function sortRoster(characters: RosterCharacter[]): RosterCharacter[] {
  return [...characters].sort((a, b) => {
    const classA = a.class ? (CLASS_ORDER.get(a.class) ?? 99) : 99;
    const classB = b.class ? (CLASS_ORDER.get(b.class) ?? 99) : 99;
    if (classA !== classB) return classA - classB;
    const levelA = a.level ?? -1;
    const levelB = b.level ?? -1;
    if (levelA !== levelB) return levelB - levelA;
    const name = a.name.localeCompare(b.name);
    if (name) return name;
    const realm = a.realm.localeCompare(b.realm);
    if (realm) return realm;
    return a.account.localeCompare(b.account);
  });
}
