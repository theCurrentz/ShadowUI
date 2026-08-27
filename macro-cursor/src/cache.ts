export type CacheMacro = {
  cacheId: string;
  name: string;
  icon: string;
  body: string;
};

const BLOCK = /^VER\s+\d+\s+(\S+)\s+"([^"]*)"\s+"([^"]*)"\s*\n(.*?)(?=^END\s*$)/gms;

export function parseCache(text: string): CacheMacro[] {
  const macros: CacheMacro[] = [];
  const src = text.replace(/\r\n/g, "\n");
  for (const m of src.matchAll(BLOCK)) {
    macros.push({
      cacheId: m[1],
      name: m[2],
      icon: m[3],
      body: m[4].replace(/\n$/, ""),
    });
  }
  return macros;
}

export function serializeCache(macros: CacheMacro[], character: boolean): string {
  return macros
    .map((m, i) => {
      const id = m.cacheId || padCacheId(i + 1, character);
      return `VER 3 ${id} "${m.name}" "${m.icon}"\n${m.body}\nEND`;
    })
    .join("\n") + (macros.length ? "\n" : "");
}

export function padCacheId(n: number, character: boolean): string {
  const hex = n.toString(16).toUpperCase().padStart(8, "0");
  return character ? `01000000${hex}` : `00000000${hex}`;
}

export function normalizeBody(body: string): string {
  return body
    .split("\n")
    .filter((line) => !/^# (global|class-specific|character-specific) /.test(line))
    .join("\n")
    .trim()
    .replace(/\s+/g, " ");
}

export function cacheLooksCorrupt(text: string, parsedCount: number): boolean {
  const trimmed = text.trim();
  if (!trimmed) return false;
  if (parsedCount > 0) return false;
  return trimmed.length > 20 && !/^END\s*$/m.test(trimmed);
}
