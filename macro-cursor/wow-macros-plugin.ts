import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";
import type { IncomingMessage, ServerResponse } from "node:http";
import type { Plugin, PreviewServer, ViteDevServer } from "vite";
import { cacheLooksCorrupt, parseCache, serializeCache, type CacheMacro } from "./src/cache.ts";
import { CORE_GROUP, HORDE_REALMS, type LiveAccount, type LiveCharacter, type SyncResponse } from "./src/merge.ts";
import {
  attuneLookupKey,
  mergeCharMeta,
  nitLookupKey,
  parseAttuneToons,
  parseNitMyChars,
  type RosterCharacter,
  type RosterResponse,
} from "./src/roster.ts";
import type { Catalog, Macro, WowClass } from "./src/types.ts";
import { parseClassDefaults } from "./src/parse-defaults.ts";
import { overlayForWrite } from "./src/deck-edit.ts";
import { consumeSelfWrite, markSelfWrite, writeWatchedFile } from "./src/self-write.ts";
import {
  applyLoadoutToClassLua,
  fallbackMatchesFromBodies,
  overlayFromUnknown,
} from "./src/write-defaults.ts";

const CLASSES: WowClass[] = [
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

const NAME_CLASS: Record<string, WowClass> = {
  Tazzy: "WARRIOR",
  Tazman: "WARRIOR",
  Tazz: "WARRIOR",
  Currentz: "MAGE",
  Currents: "MAGE",
  Virene: "PALADIN",
  Auden: "HUNTER",
  Xavvian: "WARLOCK",
  Jahsham: "SHAMAN",
  Ellina: "ROGUE",
  Niela: "ROGUE",
  Legolaz: "PRIEST",
  Delthas: "HUNTER",
};

function wowPath(): string {
  return (
    process.env.WOW_CLASSIC_ERA ||
    "/Applications/World of Warcraft/_classic_era_"
  );
}

function wowRunning(): boolean {
  try {
    execSync('pgrep -fi "World of Warcraft Classic"', { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function isCharacterDir(charDir: string): boolean {
  return (
    fs.existsSync(path.join(charDir, "config-cache.wtf")) ||
    fs.existsSync(path.join(charDir, "macros-cache.txt")) ||
    fs.existsSync(path.join(charDir, "SavedVariables"))
  );
}

function walkCharacters(): { account: string; realm: string; name: string; charDir: string }[] {
  const root = wowPath();
  const wtf = path.join(root, "WTF", "Account");
  const out: { account: string; realm: string; name: string; charDir: string }[] = [];
  if (!fs.existsSync(wtf)) return out;
  for (const account of fs.readdirSync(wtf)) {
    if (account.startsWith(".") || account === "SavedVariables") continue;
    const accDir = path.join(wtf, account);
    if (!fs.statSync(accDir).isDirectory()) continue;
    for (const realm of fs.readdirSync(accDir)) {
      if (realm.startsWith(".") || realm === "SavedVariables") continue;
      const realmDir = path.join(accDir, realm);
      if (!fs.statSync(realmDir).isDirectory()) continue;
      for (const name of fs.readdirSync(realmDir)) {
        if (name.startsWith(".")) continue;
        const charDir = path.join(realmDir, name);
        if (!fs.statSync(charDir).isDirectory()) continue;
        if (!isCharacterDir(charDir)) continue;
        out.push({ account, realm, name, charDir });
      }
    }
  }
  return out;
}

function readAddonLua(
  accDir: string,
  file: string,
  parse: (src: string) => Map<string, { class: WowClass | null; level: number | null }>,
): Map<string, { class: WowClass | null; level: number | null }> {
  const lua = path.join(accDir, "SavedVariables", file);
  if (!fs.existsSync(lua)) return new Map();
  try {
    return parse(fs.readFileSync(lua, "utf8"));
  } catch {
    return new Map();
  }
}

function scanRoster(): RosterResponse {
  const root = wowPath();
  const characters: RosterCharacter[] = [];
  const nitByAccount = new Map<string, Map<string, { class: WowClass | null; level: number | null }>>();
  const attuneByAccount = new Map<string, Map<string, { class: WowClass | null; level: number | null }>>();
  for (const row of walkCharacters()) {
    const accDir = path.join(root, "WTF", "Account", row.account);
    if (!nitByAccount.has(row.account)) {
      nitByAccount.set(row.account, readAddonLua(accDir, "NovaInstanceTracker.lua", parseNitMyChars));
    }
    if (!attuneByAccount.has(row.account)) {
      attuneByAccount.set(row.account, readAddonLua(accDir, "Attune.lua", parseAttuneToons));
    }
    const nit = nitByAccount.get(row.account)?.get(nitLookupKey(row.realm, row.name));
    const attune = attuneByAccount.get(row.account)?.get(attuneLookupKey(row.realm, row.name));
    const meta = mergeCharMeta(nit, attune);
    characters.push({
      account: row.account,
      realm: row.realm,
      name: row.name,
      class: meta.class ?? inferClass(row.charDir, row.name),
      level: meta.level,
    });
  }
  return { wowPath: root, characters };
}

function inferClass(charDir: string, name: string): WowClass | null {
  const counts = new Map<WowClass, number>();
  const sv = path.join(charDir, "SavedVariables");
  if (fs.existsSync(sv)) {
    for (const file of fs.readdirSync(sv).filter((f) => f.endsWith(".lua")).slice(0, 12)) {
      let text = "";
      try {
        text = fs.readFileSync(path.join(sv, file), "utf8").slice(0, 12000);
      } catch {
        continue;
      }
      for (const cls of CLASSES) {
        const n = text.split(cls).length - 1;
        if (n) counts.set(cls, (counts.get(cls) ?? 0) + n);
      }
    }
  }
  if (counts.size === 1) return [...counts.keys()][0];
  if (counts.size > 1) {
    const ranked = [...counts.entries()].sort((a, b) => b[1] - a[1]);
    if (ranked[0][1] >= ranked[1][1] * 2) return ranked[0][0];
  }
  return NAME_CLASS[name] ?? null;
}

function readCache(file: string): { text: string; macros: CacheMacro[]; corrupt: boolean } {
  if (!fs.existsSync(file)) return { text: "", macros: [], corrupt: false };
  const text = fs.readFileSync(file, "utf8");
  const macros = parseCache(text);
  return { text, macros, corrupt: cacheLooksCorrupt(text, macros.length) };
}

function toCache(m: Macro, i: number, character: boolean): CacheMacro {
  return {
    cacheId: character
      ? `01000000${(i + 1).toString(16).toUpperCase().padStart(8, "0")}`
      : `00000000${(i + 1).toString(16).toUpperCase().padStart(8, "0")}`,
    name: m.name,
    icon: m.icon.toUpperCase().replace(/-/g, "_"),
    body: m.body,
  };
}

function healFile(
  file: string,
  character: boolean,
  catalogMacros: Macro[] | undefined,
  running: boolean,
  notes: string[],
  label: string,
): { macros: CacheMacro[]; healed?: string; wrote: boolean } {
  const live = readCache(file);
  const oldPath = file.replace(/\.txt$/, ".old");
  const old = readCache(oldPath);
  let macros = live.macros;
  let healed: string | undefined;
  let wrote = false;

  const empty = macros.length === 0;
  const broken = live.corrupt;
  if (!empty && !broken) return { macros, wrote: false };

  if (old.macros.length) {
    macros = old.macros;
    healed = `${label}: restored ${old.macros.length} from macros-cache.old`;
    if (!running) {
      fs.copyFileSync(oldPath, file);
      wrote = true;
      healed += " (wrote).";
    } else {
      healed += " (WoW is open; in memory only).";
    }
    notes.push(healed);
    return { macros, healed, wrote };
  }

  if (catalogMacros && catalogMacros.length) {
    macros = catalogMacros.map((m, i) => toCache(m, i, character));
    healed = `${label}: restored ${macros.length} from catalog`;
    if (!running) {
      fs.writeFileSync(file, serializeCache(macros, character), "utf8");
      wrote = true;
      healed += " (wrote).";
    } else {
      healed += " (WoW is open; in memory only).";
    }
    notes.push(healed);
    return { macros, healed, wrote };
  }

  if (broken) notes.push(`${label}: cache looks damaged and has no .old backup.`);
  return { macros, wrote: false };
}

function catalogForClass(catalog: Catalog, cls: WowClass | null, realm: string): Macro[] | undefined {
  if (!cls || cls === "ALL") return undefined;
  let groupId = CORE_GROUP[cls];
  if (cls === "MAGE" && HORDE_REALMS.has(realm)) groupId = "mage-ports-horde";
  const g = catalog.groups.find((x) => x.id === groupId);
  if (!g) return undefined;
  const byId = new Map(catalog.macros.map((m) => [m.id, m]));
  return g.macroIds.map((id) => byId.get(id)).filter((m): m is Macro => Boolean(m));
}

function scan(catalog: Catalog): SyncResponse {
  const root = wowPath();
  const running = wowRunning();
  const notes: string[] = [];
  const accounts: LiveAccount[] = [];
  const characters: LiveCharacter[] = [];
  let wrote = false;
  const wtf = path.join(root, "WTF", "Account");
  if (!fs.existsSync(wtf)) {
    notes.push(`No WTF folder at ${root}.`);
    return { wowPath: root, wowRunning: running, wrote: false, accounts, characters, notes };
  }

  const allChars = walkCharacters();
  for (const account of fs.readdirSync(wtf)) {
    if (account.startsWith(".") || account === "SavedVariables") continue;
    const accDir = path.join(wtf, account);
    if (!fs.statSync(accDir).isDirectory()) continue;
    const accFile = path.join(accDir, "macros-cache.txt");
    const accHeal = healFile(accFile, false, undefined, running, notes, `${account} account`);
    wrote = wrote || accHeal.wrote;
    accounts.push({
      account,
      path: accFile,
      macros: accHeal.macros,
      healed: accHeal.healed,
    });

    for (const row of allChars) {
      if (row.account !== account) continue;
      const charFile = path.join(row.charDir, "macros-cache.txt");
      if (!fs.existsSync(charFile)) continue;
      const cls = inferClass(row.charDir, row.name);
      const fallback = catalogForClass(catalog, cls, row.realm);
      const heal = healFile(
        charFile,
        true,
        fallback,
        running,
        notes,
        `${row.realm}/${row.name}`,
      );
      wrote = wrote || heal.wrote;
      characters.push({
        account,
        realm: row.realm,
        name: row.name,
        class: cls,
        path: charFile,
        macros: heal.macros,
        healed: heal.healed,
      });
    }
  }

  if (running) notes.unshift("WoW Classic is open. Heal stays in memory. Close the client to write caches.");
  return { wowPath: root, wowRunning: running, wrote, accounts, characters, notes };
}

function readJson(file: string, fallback: unknown): unknown {
  if (!fs.existsSync(file)) return fallback;
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

const CLASS_MD = [
  "shared.md",
  "warrior.md",
  "paladin.md",
  "hunter.md",
  "rogue.md",
  "priest.md",
  "shaman.md",
  "mage.md",
  "warlock.md",
  "druid.md",
];

function markCatalogRebuild(catalogPath: string): void {
  const dir = path.dirname(catalogPath);
  const addonRoot = path.resolve(dir, "..", "..");
  for (const file of [
    catalogPath,
    path.join(dir, "catalog.md"),
    path.join(addonRoot, "defaults", "catalog.lua"),
    ...CLASS_MD.map((name) => path.join(dir, name)),
  ]) {
    markSelfWrite(file);
  }
}

function rebuildCatalog(catalogPath: string): void {
  markCatalogRebuild(catalogPath);
  execSync("python3 build_catalog.py", { cwd: path.dirname(catalogPath), stdio: "pipe" });
}

function handlePrune(req: IncomingMessage, res: ServerResponse, catalogPath: string): void {
  const chunks: Buffer[] = [];
  req.on("data", (chunk) => chunks.push(chunk as Buffer));
  req.on("end", () => {
    try {
      const parsed = JSON.parse(Buffer.concat(chunks).toString("utf8")) as { id?: unknown };
      const id = parsed.id;
      if (typeof id !== "string" || !id.trim()) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "id required" }));
        return;
      }
      const prunePath = path.join(path.dirname(catalogPath), "pruned.json");
      const current = readJson(prunePath, { ids: [] }) as { ids?: string[] };
      const ids = [...new Set([...(current.ids ?? []), id])].sort();
      writeWatchedFile(prunePath, JSON.stringify({ ids }, null, 2) + "\n");
      rebuildCatalog(catalogPath);
      const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ ok: true, id, catalog }));
    } catch (err) {
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
    }
  });
}

function handleRename(req: IncomingMessage, res: ServerResponse, catalogPath: string): void {
  const chunks: Buffer[] = [];
  req.on("data", (chunk) => chunks.push(chunk as Buffer));
  req.on("end", () => {
    try {
      const parsed = JSON.parse(Buffer.concat(chunks).toString("utf8")) as {
        id?: unknown;
        name?: unknown;
      };
      const id = parsed.id;
      const name = typeof parsed.name === "string" ? parsed.name.trim() : "";
      if (typeof id !== "string" || !id.trim()) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "id required" }));
        return;
      }
      if (!name) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "name required" }));
        return;
      }
      if (name.length > 16) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "name is longer than 16 characters" }));
        return;
      }
      const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8")) as Catalog;
      const rec = catalog.macros.find((m) => m.id === id);
      if (!rec) {
        res.statusCode = 404;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "unknown id" }));
        return;
      }
      const owner = catalog.macros.find((m) => m.name === name && m.id !== id);
      if (owner) {
        res.statusCode = 409;
        res.setHeader("Content-Type", "application/json");
        res.end(
          JSON.stringify({
            error: "name in use",
            owner: {
              id: owner.id,
              name: owner.name,
              group: owner.group,
              class: owner.class,
              scope: owner.scope,
            },
          }),
        );
        return;
      }
      const renamePath = path.join(path.dirname(catalogPath), "renames.json");
      const current = readJson(renamePath, { byId: {} }) as { byId?: Record<string, string> };
      const byId = { ...(current.byId ?? {}), [id]: name };
      writeWatchedFile(renamePath, JSON.stringify({ byId }, null, 2) + "\n");
      rebuildCatalog(catalogPath);
      const next = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ ok: true, id, name, catalog: next }));
    } catch (err) {
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
    }
  });
}

function handleBody(req: IncomingMessage, res: ServerResponse, catalogPath: string): void {
  const chunks: Buffer[] = [];
  req.on("data", (chunk) => chunks.push(chunk as Buffer));
  req.on("end", () => {
    try {
      const parsed = JSON.parse(Buffer.concat(chunks).toString("utf8")) as {
        id?: unknown;
        body?: unknown;
      };
      const id = parsed.id;
      const body = typeof parsed.body === "string" ? parsed.body.replace(/\r\n/g, "\n") : null;
      if (typeof id !== "string" || !id.trim()) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "id required" }));
        return;
      }
      if (body === null) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "body required" }));
        return;
      }
      if (body.length > 255) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "body is longer than 255 characters" }));
        return;
      }
      const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8")) as Catalog;
      const rec = catalog.macros.find((m) => m.id === id);
      if (!rec) {
        res.statusCode = 404;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "unknown id" }));
        return;
      }
      const bodiesPath = path.join(path.dirname(catalogPath), "bodies.json");
      const current = readJson(bodiesPath, { byId: {} }) as { byId?: Record<string, string> };
      const byId = { ...(current.byId ?? {}), [id]: body };
      writeWatchedFile(bodiesPath, JSON.stringify({ byId }, null, 2) + "\n");
      rebuildCatalog(catalogPath);
      const next = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ ok: true, id, catalog: next }));
    } catch (err) {
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
    }
  });
}

function keybindsPath(catalogPath: string): string {
  return path.join(path.dirname(catalogPath), "keybinds.json");
}

function isBindValue(v: unknown): v is string | false {
  return v === false || (typeof v === "string" && v.length > 0 && v.length < 64);
}

function handleKeybindsGet(_req: IncomingMessage, res: ServerResponse, catalogPath: string): void {
  try {
    const current = readJson(keybindsPath(catalogPath), { base: {}, classes: {} }) as {
      base?: Record<string, unknown>;
      classes?: Record<string, Record<string, unknown>>;
    };
    const base: Record<string, string | false> = {};
    for (const [name, key] of Object.entries(current.base ?? {})) {
      if (isBindValue(key)) base[name] = key;
    }
    const classes: Record<string, Record<string, string | false>> = {};
    for (const [cls, binds] of Object.entries(current.classes ?? {})) {
      const clean: Record<string, string | false> = {};
      for (const [name, key] of Object.entries(binds ?? {})) {
        if (isBindValue(key)) clean[name] = key;
      }
      classes[cls] = clean;
    }
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify({ base, classes }));
  } catch (err) {
    res.statusCode = 500;
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
  }
}

function handleKeybindsPost(req: IncomingMessage, res: ServerResponse, catalogPath: string): void {
  const chunks: Buffer[] = [];
  req.on("data", (chunk) => chunks.push(chunk as Buffer));
  req.on("end", () => {
    try {
      const parsed = JSON.parse(Buffer.concat(chunks).toString("utf8")) as {
        classId?: unknown;
        overlay?: unknown;
      };
      const classId = typeof parsed.classId === "string" ? parsed.classId.toUpperCase() : "";
      if (!/^[A-Z]+$/.test(classId)) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "classId required" }));
        return;
      }
      if (!parsed.overlay || typeof parsed.overlay !== "object" || Array.isArray(parsed.overlay)) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "overlay required" }));
        return;
      }
      const overlay: Record<string, string | false> = {};
      for (const [name, key] of Object.entries(parsed.overlay as Record<string, unknown>)) {
        if (typeof name === "string" && isBindValue(key)) overlay[name] = key;
      }
      const file = keybindsPath(catalogPath);
      const current = readJson(file, { base: {}, classes: {} }) as {
        base?: Record<string, string | false>;
        classes?: Record<string, Record<string, string | false>>;
      };
      const base = { ...(current.base ?? {}) };
      const classes = { ...(current.classes ?? {}) };
      if (classId === "BASE") {
        Object.keys(base).forEach((k) => delete base[k]);
        Object.assign(base, overlay);
      } else {
        classes[classId] = overlay;
      }
      fs.writeFileSync(file, JSON.stringify({ base, classes }, null, 2) + "\n");
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ ok: true, base, classes }));
    } catch (err) {
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
    }
  });
}

function actionsPath(catalogPath: string): string {
  return path.join(path.dirname(catalogPath), "actions.json");
}

function classLuaPath(catalogPath: string, classId: string): string {
  return path.resolve(path.dirname(catalogPath), "..", "..", "defaults", "classes", `${classId}.lua`);
}

function catalogMatches(catalogPath: string): Record<string, string> {
  try {
    const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8")) as Catalog;
    return fallbackMatchesFromBodies(catalog.macros);
  } catch {
    return {};
  }
}

function bakeClassLua(
  catalogPath: string,
  classId: string,
  variant: string,
  overlay: Record<string, unknown>,
): { overlay: Record<string, unknown>; classSpec?: ReturnType<typeof parseClassDefaults>; wrote: boolean } {
  const luaFile = classLuaPath(catalogPath, classId);
  if (!fs.existsSync(luaFile) || Object.keys(overlay).length === 0) {
    return { overlay, wrote: false };
  }
  const baked = applyLoadoutToClassLua(
    fs.readFileSync(luaFile, "utf8"),
    classId,
    variant,
    overlayFromUnknown(overlay),
    catalogMatches(catalogPath),
  );
  if (!baked) return { overlay, wrote: false };
  const wrote = writeWatchedFile(luaFile, baked.src);
  return {
    overlay: overlayForWrite(baked.remainingOverlay),
    classSpec: parseClassDefaults(classId, baked.src),
    wrote,
  };
}

export function syncActionOverlaysToDecks(catalogPath: string): void {
  const file = actionsPath(catalogPath);
  const current = readJson(file, { classes: {} }) as {
    classes?: Record<string, Record<string, Record<string, unknown>>>;
  };
  const classes = { ...(current.classes ?? {}) };
  let changed = false;
  for (const [classId, variants] of Object.entries(classes)) {
    const next: Record<string, Record<string, unknown>> = { ...variants };
    for (const [variant, overlay] of Object.entries(variants ?? {})) {
      const baked = bakeClassLua(catalogPath, classId, variant, overlay ?? {});
      next[variant] = baked.overlay;
      if (baked.wrote) changed = true;
    }
    classes[classId] = next;
  }
  if (changed) writeWatchedFile(file, JSON.stringify({ classes }, null, 2) + "\n");
}

function isSlotAction(v: unknown): boolean {
  if (v === false) return true;
  if (!v || typeof v !== "object" || Array.isArray(v)) return false;
  const rec = v as Record<string, unknown>;
  return typeof rec.id === "string" && rec.id.length > 0 && rec.id.length < 80 && typeof rec.name === "string";
}

function handleActionsGet(_req: IncomingMessage, res: ServerResponse, catalogPath: string): void {
  try {
    const current = readJson(actionsPath(catalogPath), { classes: {} }) as {
      classes?: Record<string, Record<string, Record<string, unknown>>>;
    };
    const classes: Record<string, Record<string, Record<string, unknown>>> = {};
    for (const [cls, variants] of Object.entries(current.classes ?? {})) {
      const clean: Record<string, Record<string, unknown>> = {};
      for (const [variant, slots] of Object.entries(variants ?? {})) {
        const overlay: Record<string, unknown> = {};
        for (const [slot, action] of Object.entries(slots ?? {})) {
          if (isSlotAction(action)) overlay[slot] = action;
        }
        clean[variant] = overlay;
      }
      classes[cls] = clean;
    }
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify({ classes }));
  } catch (err) {
    res.statusCode = 500;
    res.setHeader("Content-Type", "application/json");
    res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
  }
}

function handleActionsPost(req: IncomingMessage, res: ServerResponse, catalogPath: string): void {
  const chunks: Buffer[] = [];
  req.on("data", (chunk) => chunks.push(chunk as Buffer));
  req.on("end", () => {
    try {
      const parsed = JSON.parse(Buffer.concat(chunks).toString("utf8")) as {
        classId?: unknown;
        variant?: unknown;
        overlay?: unknown;
      };
      const classId = typeof parsed.classId === "string" ? parsed.classId.toUpperCase() : "";
      if (!/^[A-Z]+$/.test(classId)) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "classId required" }));
        return;
      }
      const variant = typeof parsed.variant === "string" ? parsed.variant : "";
      if (!parsed.overlay || typeof parsed.overlay !== "object" || Array.isArray(parsed.overlay)) {
        res.statusCode = 400;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: "overlay required" }));
        return;
      }
      const overlay: Record<string, unknown> = {};
      for (const [slot, action] of Object.entries(parsed.overlay as Record<string, unknown>)) {
        if (/^\d+$/.test(slot) && isSlotAction(action)) overlay[slot] = action;
      }
      const baked = bakeClassLua(catalogPath, classId, variant, overlay);
      const writtenOverlay = baked.overlay;
      const classSpec = baked.classSpec;
      const file = actionsPath(catalogPath);
      const current = readJson(file, { classes: {} }) as {
        classes?: Record<string, Record<string, Record<string, unknown>>>;
      };
      const classTable = { ...(current.classes?.[classId] ?? {}), [variant]: writtenOverlay };
      const classes = { ...(current.classes ?? {}), [classId]: classTable };
      writeWatchedFile(file, JSON.stringify({ classes }, null, 2) + "\n");
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ ok: true, classes, classSpec }));
    } catch (err) {
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
    }
  });
}

function attach(server: ViteDevServer | PreviewServer, catalogPath: string): void {
  server.middlewares.use((req, res, next) => {
    const url = req.url?.split("?")[0];
    if (url === "/api/prune" && req.method === "POST") {
      handlePrune(req, res, catalogPath);
      return;
    }
    if (url === "/api/rename" && req.method === "POST") {
      handleRename(req, res, catalogPath);
      return;
    }
    if (url === "/api/body" && req.method === "POST") {
      handleBody(req, res, catalogPath);
      return;
    }
    if (url === "/api/keybinds" && req.method === "GET") {
      handleKeybindsGet(req, res, catalogPath);
      return;
    }
    if (url === "/api/keybinds" && req.method === "POST") {
      handleKeybindsPost(req, res, catalogPath);
      return;
    }
    if (url === "/api/actions" && req.method === "GET") {
      handleActionsGet(req, res, catalogPath);
      return;
    }
    if (url === "/api/actions" && req.method === "POST") {
      handleActionsPost(req, res, catalogPath);
      return;
    }
    if (url === "/api/roster" && req.method === "GET") {
      try {
        const body = JSON.stringify(scanRoster());
        res.setHeader("Content-Type", "application/json");
        res.end(body);
      } catch (err) {
        res.statusCode = 500;
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
      }
      return;
    }
    if (url !== "/api/sync") return next();
    try {
      const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8")) as Catalog;
      const body = JSON.stringify(scan(catalog));
      res.setHeader("Content-Type", "application/json");
      res.end(body);
    } catch (err) {
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify({ error: err instanceof Error ? err.message : String(err) }));
    }
  });
}

export function wowMacrosPlugin(catalogPath: string): Plugin {
  return {
    name: "wow-macro-sync",
    handleHotUpdate(ctx) {
      if (consumeSelfWrite(ctx.file)) return [];
    },
    configureServer(server) {
      syncActionOverlaysToDecks(catalogPath);
      attach(server, catalogPath);
    },
    configurePreviewServer(server) {
      attach(server, catalogPath);
    },
  };
}
