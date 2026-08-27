import type { Catalog, Macro } from "./types";

export type NameOwner = {
  id: string;
  name: string;
  group: string;
  class: Macro["class"];
  scope: Macro["scope"];
};

export function findNameOwner(catalog: Catalog, name: string, exceptId?: string): Macro | undefined {
  return catalog.macros.find((m) => m.name === name && m.id !== exceptId);
}

export function describeOwner(m: Macro): string {
  return `${m.id} (${m.group}, ${m.class}, ${m.scope})`;
}

export function renameMacro(catalog: Catalog, id: string, name: string): Catalog {
  return {
    ...catalog,
    macros: catalog.macros.map((m) => (m.id === id ? { ...m, name } : m)),
  };
}

export function setMacroBody(catalog: Catalog, id: string, body: string): Catalog {
  return {
    ...catalog,
    macros: catalog.macros.map((m) => (m.id === id ? { ...m, body, chars: body.length } : m)),
  };
}

export function catalogNamesUnique(catalog: Catalog): boolean {
  const seen = new Set<string>();
  for (const m of catalog.macros) {
    if (seen.has(m.name)) return false;
    seen.add(m.name);
  }
  return true;
}

export type LoadIdsResult = { ids: string[]; error?: string };

/** Merge group ids onto a tab. Skip duplicate ids and names. Respect the slot cap. */
export function loadGroupIds(
  current: string[],
  incoming: string[],
  catalog: Catalog,
  cap: number,
  replace: boolean,
): LoadIdsResult {
  const byId = new Map(catalog.macros.map((m) => [m.id, m]));
  const start = replace ? [] : [...current];
  const ids = [...start];
  const used = new Set(start);
  const names = new Set(
    start.map((id) => byId.get(id)?.name).filter((n): n is string => Boolean(n)),
  );
  for (const id of incoming) {
    if (used.has(id)) continue;
    const rec = byId.get(id);
    if (rec && names.has(rec.name)) continue;
    ids.push(id);
    used.add(id);
    if (rec) names.add(rec.name);
  }
  if (ids.length > cap) {
    return { ids: current, error: `needs ${ids.length} slots. Cap is ${cap}.` };
  }
  return { ids };
}

export function dropMacro(catalog: Catalog, id: string): Catalog {
  const macros = catalog.macros.filter((m) => m.id !== id);
  const groups = catalog.groups
    .map((g) => {
      const macroIds = g.macroIds.filter((mid) => mid !== id);
      return { ...g, macroIds, count: macroIds.length };
    })
    .filter((g) => g.count > 0);
  return { ...catalog, macros, groups };
}

export function mergePruned(existing: string[], id: string): string[] {
  return [...new Set([...existing, id])].sort();
}
