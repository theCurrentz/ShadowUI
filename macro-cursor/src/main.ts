import catalogJson from "@catalog";
import spellbookJson from "@spells";
import baseLua from "../../defaults/base.lua?raw";
import { mount } from "./app";
import { mergeLive, type SyncResponse } from "./merge";
import { parseBaseKeybinds, parseBaseLayout, parseClassDefaults, type ClassSpec } from "./parse-defaults";
import { emptyKeybindStore, type KeybindStore } from "./keybind-edit";
import { emptyActionStore, type ActionStore } from "./deck-edit";
import type { Catalog } from "./types";
import type { Spellbook } from "./spellbook";
import type { RosterCharacter } from "./roster";
import "./styles.css";

const classLua = import.meta.glob("../../defaults/classes/*.lua", {
  query: "?raw",
  eager: true,
  import: "default",
}) as Record<string, string>;

const baseLayout = parseBaseLayout(baseLua);
const baseKeybinds = parseBaseKeybinds(baseLua);
const classSpecs: Record<string, ClassSpec> = {};
for (const [file, src] of Object.entries(classLua)) {
  const id = /([A-Z]+)\.lua$/.exec(file)?.[1];
  if (id) classSpecs[id] = parseClassDefaults(id, src);
}

const base = catalogJson as Catalog;
const root = document.getElementById("app");
if (!root) throw new Error("missing #app");

/** Merge live WTF macros-cache.txt on startup. Off: catalog only. Keep the sync code. */
const LIVE_SYNC = false;

async function fetchLive(): Promise<SyncResponse | null> {
  try {
    const res = await fetch("/api/sync");
    if (!res.ok) return null;
    return (await res.json()) as SyncResponse;
  } catch {
    return null;
  }
}

function pickStart(live: SyncResponse | null) {
  if (!live?.accounts.length) return { account: "", toon: undefined };
  const preferred = live.accounts.find((a) => a.account === "WARKEYS") ?? live.accounts[0];
  const toon =
    live.characters.find((c) => c.account === preferred.account && c.name === "Tazzy") ??
    live.characters.find((c) => c.account === preferred.account) ??
    live.characters[0];
  return { account: preferred.account, toon };
}

async function fetchKeybinds(): Promise<KeybindStore> {
  try {
    const res = await fetch("/api/keybinds");
    if (!res.ok) return emptyKeybindStore();
    const body = (await res.json()) as {
      base?: KeybindStore["base"];
      classes?: KeybindStore["classes"];
    };
    return { base: body.base ?? {}, classes: body.classes ?? {} };
  } catch {
    return emptyKeybindStore();
  }
}
async function fetchActions(): Promise<ActionStore> {
  try {
    const res = await fetch("/api/actions");
    if (!res.ok) return emptyActionStore();
    const body = (await res.json()) as { classes?: ActionStore["classes"] };
    return { classes: body.classes ?? {} };
  } catch {
    return emptyActionStore();
  }
}
async function fetchRoster(): Promise<RosterCharacter[]> {
  try {
    const res = await fetch("/api/roster");
    if (!res.ok) return [];
    const body = (await res.json()) as { characters?: RosterCharacter[] };
    return body.characters ?? [];
  } catch {
    return [];
  }
}

const [live, bindStore, actionStore, roster] = await Promise.all([
  LIVE_SYNC ? fetchLive() : Promise.resolve(null),
  fetchKeybinds(),
  fetchActions(),
  fetchRoster(),
]);
const start = pickStart(live);
const merged = live
  ? mergeLive(base, live, start.account, start.toon)
  : {
      catalog: base,
      accountIds: [],
      characterIds: [],
      notes: LIVE_SYNC ? ["Live WTF cache is not available."] : ["Live WTF sync is off. Catalog only."],
    };

mount(root, {
  base,
  catalog: merged.catalog,
  live,
  accountName: start.account,
  toon: start.toon,
  accountIds: merged.accountIds,
  characterIds: merged.characterIds,
  notes: merged.notes,
  baseLayout,
  baseKeybinds,
  classSpecs,
  bindStore,
  spellbook: spellbookJson as Spellbook,
  actionStore,
  roster,
});
