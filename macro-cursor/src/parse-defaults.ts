/** Parse shipped Base and Class Layout, Keybinds, and Action Deck from Lua. */

export type BarCfg = {
  point: string;
  x: number;
  y: number;
  buttons: number;
  columns: number;
  scale: number;
  enabled: boolean;
  buttonSize: number;
  firstSlot?: number;
  stancePages?: number[];
};

export type DeckAction = {
  id: string;
  name: string;
  kind?: "macro" | "spell";
  icon?: string;
  rank?: string;
  spellId?: number;
  match?: string;
  notMatch?: string;
  createName?: string;
};

export type DeckSlotRange = number | [number, number];

export type VariantSpec = {
  name: string;
  talentTree?: number;
  layout: Record<string, Partial<BarCfg>>;
  keybinds: Record<string, string>;
  actions: Record<number, DeckAction | false>;
};

export type ClassSpec = {
  classId: string;
  layout: Record<string, Partial<BarCfg>>;
  keybinds: Record<string, string>;
  actions: Record<number, DeckAction>;
  deckSlots: DeckSlotRange[];
  variants: VariantSpec[];
};

export const BUTTON_SIZE = 36 * 0.9;
const BOTTOM = 0;
const SIDE_X = (12 * BUTTON_SIZE) / 2 + (3 * BUTTON_SIZE) / 2;

const BAR_IDS = [
  "bar1",
  "bar2",
  "bar3",
  "bar4",
  "bar5",
  "bar6",
  "bar7",
  "bar8",
  "bar9",
  "bar10",
] as const;

function defaultBar(): BarCfg {
  return {
    point: "BOTTOM",
    x: 0,
    y: 0,
    buttons: 12,
    columns: 12,
    scale: 1,
    enabled: true,
    buttonSize: BUTTON_SIZE,
  };
}

function evalArg(raw: string): number | string | boolean {
  const s = raw.trim();
  if (s === "true") return true;
  if (s === "false") return false;
  if (s.startsWith('"') && s.endsWith('"')) return s.slice(1, -1);
  const ids: Record<string, number> = {
    SIZE: BUTTON_SIZE,
    BOTTOM,
    SIDE_X,
    ROW_WIDTH: 12 * BUTTON_SIZE,
    SIDE_WIDTH: 3 * BUTTON_SIZE,
  };
  const expr = s.replace(/\b[A-Z_]+\b/g, (name) =>
    name in ids ? String(ids[name]) : name,
  );
  if (/^[-+/*().\d\s]+$/.test(expr)) {
    // Defaults files only use SIZE / BOTTOM / SIDE_X arithmetic.
    return Function(`"use strict"; return (${expr});`)() as number;
  }
  return s;
}

export function sliceBalanced(src: string, open: number): { inner: string; end: number } {
  if (src[open] !== "{") throw new Error("expected {");
  let depth = 0;
  for (let i = open; i < src.length; i++) {
    const ch = src[i];
    if (ch === "{") depth++;
    else if (ch === "}") {
      depth--;
      if (depth === 0) return { inner: src.slice(open + 1, i), end: i + 1 };
    }
  }
  throw new Error("unbalanced {");
}

function parseLuaTable(inner: string): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  let i = 0;
  const n = inner.length;
  while (i < n) {
    while (i < n && /[\s,]/.test(inner[i]!)) i++;
    if (i >= n) break;
    if (inner.startsWith("--", i)) {
      const nl = inner.indexOf("\n", i);
      i = nl === -1 ? n : nl + 1;
      continue;
    }
    let key: string;
    if (inner[i] === "[") {
      const close = inner.indexOf("]", i);
      const raw = inner.slice(i + 1, close).trim();
      const slot = raw.match(/^slot\((\d+)\)$/);
      key = slot ? `CLICK ShadowUIActionButton${slot[1]}:Keybind` : raw.replace(/^["']|["']$/g, "");
      i = close + 1;
    } else {
      const m = inner.slice(i).match(/^([A-Za-z_][\w]*)/);
      if (!m) break;
      key = m[1]!;
      i += m[0].length;
    }
    while (i < n && /\s/.test(inner[i]!)) i++;
    if (inner[i] !== "=") break;
    i++;
    while (i < n && /\s/.test(inner[i]!)) i++;
    if (inner[i] === "{") {
      const block = sliceBalanced(inner, i);
      out[key] = parseLuaValue(block.inner);
      i = block.end;
    } else if (inner.startsWith("act(", i)) {
      const act = inner.slice(i).match(/^act\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,?\s*/);
      const rec: Record<string, unknown> = act
        ? { id: act[1], name: act[2] }
        : {};
      i += act ? act[0].length : 4;
      if (inner[i] === "{") {
        const extra = sliceBalanced(inner, i);
        Object.assign(rec, parseLuaTable(extra.inner));
        i = extra.end;
      }
      while (i < n && inner[i] !== ")") i++;
      if (i < n) i++;
      out[key] = rec;
    } else if (inner[i] === '"' || inner[i] === "'") {
      const q = inner[i]!;
      let j = i + 1;
      while (j < n && inner[j] !== q) j++;
      out[key] = inner.slice(i + 1, j);
      i = j + 1;
    } else {
      const m = inner.slice(i).match(/^[^,\n}]+/);
      if (!m) break;
      out[key] = evalArg(m[0]!);
      i += m[0].length;
    }
  }
  return out;
}

function parseLuaValue(inner: string): unknown {
  const trimmed = inner.trim();
  if (!trimmed) return {};
  if (/^\d[\d\s,]*$/.test(trimmed)) {
    return trimmed
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean)
      .map(Number);
  }
  if (trimmed.startsWith("{")) {
    const list: unknown[] = [];
    let i = 0;
    while (i < trimmed.length) {
      while (i < trimmed.length && /[\s,]/.test(trimmed[i]!)) i++;
      if (i >= trimmed.length) break;
      if (trimmed[i] !== "{") return parseLuaTable(inner);
      const block = sliceBalanced(trimmed, i);
      list.push(parseLuaValue(block.inner));
      i = block.end;
    }
    return list;
  }
  return parseLuaTable(inner);
}

function asBarPatch(raw: Record<string, unknown>): Partial<BarCfg> {
  const patch: Partial<BarCfg> = {};
  if (typeof raw.point === "string") patch.point = raw.point;
  if (typeof raw.x === "number") patch.x = raw.x;
  if (typeof raw.y === "number") patch.y = raw.y;
  if (typeof raw.buttons === "number") patch.buttons = raw.buttons;
  if (typeof raw.columns === "number") patch.columns = raw.columns;
  if (typeof raw.scale === "number") patch.scale = raw.scale;
  if (typeof raw.enabled === "boolean") patch.enabled = raw.enabled;
  if (typeof raw.buttonSize === "number") patch.buttonSize = raw.buttonSize;
  if (typeof raw.firstSlot === "number") patch.firstSlot = raw.firstSlot;
  if (Array.isArray(raw.stancePages)) {
    patch.stancePages = raw.stancePages.filter((n): n is number => typeof n === "number");
  }
  return patch;
}

function asKeybinds(raw: Record<string, unknown>): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [k, v] of Object.entries(raw)) {
    if (typeof v === "string") out[k] = v;
  }
  return out;
}

function asDeckAction(v: unknown): DeckAction | undefined {
  if (!v || typeof v !== "object" || Array.isArray(v)) return undefined;
  const rec = v as Record<string, unknown>;
  if (typeof rec.id !== "string" || typeof rec.name !== "string") return undefined;
  const action: DeckAction = { id: rec.id, name: rec.name };
  if (typeof rec.match === "string") action.match = rec.match;
  if (typeof rec.notMatch === "string") action.notMatch = rec.notMatch;
  if (typeof rec.createName === "string") action.createName = rec.createName;
  if (rec.kind === "macro" || rec.kind === "spell") action.kind = rec.kind;
  return action;
}

function asActions(raw: Record<string, unknown>): Record<number, DeckAction | false> {
  const out: Record<number, DeckAction | false> = {};
  for (const [k, v] of Object.entries(raw)) {
    const slot = Number(k);
    if (!Number.isFinite(slot)) continue;
    if (v === false) {
      out[slot] = false;
      continue;
    }
    const action = asDeckAction(v);
    if (action) out[slot] = action;
  }
  return out;
}

function asClassActions(raw: Record<string, unknown>): Record<number, DeckAction> {
  const out: Record<number, DeckAction> = {};
  for (const [slot, value] of Object.entries(asActions(raw))) {
    if (value !== false) out[Number(slot)] = value;
  }
  return out;
}

function asDeckSlots(raw: unknown): DeckSlotRange[] {
  if (!Array.isArray(raw)) return [];
  const out: DeckSlotRange[] = [];
  for (const item of raw) {
    if (typeof item === "number") out.push(item);
    else if (Array.isArray(item) && typeof item[0] === "number" && typeof item[1] === "number") {
      out.push([item[0], item[1]]);
    }
  }
  return out;
}

export function slotInDeck(ranges: DeckSlotRange[] | undefined, slot: number): boolean {
  if (!ranges?.length) return false;
  for (const range of ranges) {
    if (typeof range === "number") {
      if (range === slot) return true;
    } else if (slot >= range[0] && slot <= range[1]) {
      return true;
    }
  }
  return false;
}

function parseBarCall(args: string): BarCfg {
  const parts = args.split(",").map((s) => s.trim());
  const cfg = defaultBar();
  if (parts[0]) cfg.point = String(evalArg(parts[0]!));
  if (parts[1]) cfg.x = Number(evalArg(parts[1]!));
  if (parts[2]) cfg.y = Number(evalArg(parts[2]!));
  if (parts[3]) cfg.buttons = Number(evalArg(parts[3]!));
  if (parts[4]) cfg.columns = Number(evalArg(parts[4]!));
  if (parts[5] !== undefined && parts[5] !== "") cfg.enabled = Boolean(evalArg(parts[5]!));
  return cfg;
}

export function parseBaseKeybinds(src: string): Record<string, string> {
  const assign = src.indexOf("Addon.Defaults.base");
  if (assign < 0) return {};
  const key = src.indexOf("keybinds", assign);
  if (key < 0) return {};
  const open = src.indexOf("{", key);
  if (open < 0) return {};
  const block = sliceBalanced(src, open);
  return asKeybinds(parseLuaTable(block.inner));
}

export function parseBaseLayout(src: string): Record<string, BarCfg> {
  const layout: Record<string, BarCfg> = {};
  for (const m of src.matchAll(/^\s*(bar\d+|pet|possess)\s*=\s*row\((\d+)\)/gm)) {
    const fromTop = Number(m[2]);
    layout[m[1]!] = {
      ...defaultBar(),
      y: BOTTOM + (5 - fromTop) * BUTTON_SIZE,
    };
  }
  for (const m of src.matchAll(/^\s*(bar\d+|pet|possess)\s*=\s*bar\(([^)]*)\)/gm)) {
    layout[m[1]!] = parseBarCall(m[2]!);
  }
  return layout;
}

export function parseClassDefaults(classId: string, src: string): ClassSpec {
  const assign = src.indexOf(`Addon.Defaults.classes.${classId}`);
  if (assign < 0) {
    return { classId, layout: {}, keybinds: {}, actions: {}, deckSlots: [], variants: [] };
  }
  const open = src.indexOf("{", assign);
  const block = sliceBalanced(src, open);
  const root = parseLuaTable(block.inner);
  const layoutRaw = (root.layout ?? {}) as Record<string, unknown>;
  const layout: Record<string, Partial<BarCfg>> = {};
  for (const [id, val] of Object.entries(layoutRaw)) {
    if (val && typeof val === "object" && !Array.isArray(val)) {
      layout[id] = asBarPatch(val as Record<string, unknown>);
    }
  }
  const variantsRaw = (root.variants ?? {}) as Record<string, unknown>;
  const variants: VariantSpec[] = [];
  for (const [name, val] of Object.entries(variantsRaw)) {
    if (!val || typeof val !== "object") continue;
    const rec = val as Record<string, unknown>;
    const vLayout: Record<string, Partial<BarCfg>> = {};
    const rawLayout = (rec.layout ?? {}) as Record<string, unknown>;
    for (const [id, patch] of Object.entries(rawLayout)) {
      if (patch && typeof patch === "object" && !Array.isArray(patch)) {
        vLayout[id] = asBarPatch(patch as Record<string, unknown>);
      }
    }
    variants.push({
      name,
      talentTree: typeof rec.talentTree === "number" ? rec.talentTree : undefined,
      layout: vLayout,
      keybinds: asKeybinds((rec.keybinds ?? {}) as Record<string, unknown>),
      actions: asActions((rec.actions ?? {}) as Record<string, unknown>),
    });
  }
  return {
    classId,
    layout,
    keybinds: asKeybinds((root.keybinds ?? {}) as Record<string, unknown>),
    actions: asClassActions((root.actions ?? {}) as Record<string, unknown>),
    deckSlots: asDeckSlots(root.deckSlots),
    variants,
  };
}

export function mergeBarCfg(base: BarCfg, ...patches: Partial<BarCfg>[]): BarCfg {
  return Object.assign(defaultBar(), base, ...patches);
}

export function mergeClassLayout(
  base: Record<string, BarCfg>,
  cls: ClassSpec,
  variant?: VariantSpec,
): Record<string, BarCfg> {
  const out: Record<string, BarCfg> = {};
  for (const id of BAR_IDS) {
    const founded = base[id] ?? defaultBar();
    out[id] = mergeBarCfg(founded, cls.layout[id] ?? {}, variant?.layout[id] ?? {});
  }
  return out;
}

export function mergeActions(cls: ClassSpec, variant?: VariantSpec): Record<number, DeckAction> {
  const out: Record<number, DeckAction> = { ...cls.actions };
  for (const [slot, value] of Object.entries(variant?.actions ?? {})) {
    const n = Number(slot);
    if (value === false) delete out[n];
    else out[n] = value;
  }
  return out;
}

export function firstActionSlot(barId: string, cfg: BarCfg): number | undefined {
  if (cfg.stancePages && cfg.stancePages.length) return cfg.stancePages[0];
  if (typeof cfg.firstSlot === "number") return cfg.firstSlot;
  const page = Number(/^bar(\d+)$/.exec(barId)?.[1]);
  if (!page) return undefined;
  return (page - 1) * 12 + 1;
}

const MULTI_BAR_FIRST_SLOT = [61, 49, 25, 37];

export function slotFromBindingName(name: string): number | undefined {
  const click =
    name.match(/^CLICK BT4Button(\d+):/) ||
    name.match(/^CLICK ShadowUIActionButton(\d+):/) ||
    name.match(/^ACTIONBUTTON(\d+)$/);
  if (click) return Number(click[1]);
  const multi = name.match(/^MULTIACTIONBAR(\d+)BUTTON(\d+)$/);
  if (!multi) return undefined;
  const first = MULTI_BAR_FIRST_SLOT[Number(multi[1]) - 1];
  if (first === undefined) return undefined;
  return first + Number(multi[2]) - 1;
}

export function hotkeysBySlot(keybinds: Record<string, string>): Record<number, string> {
  const out: Record<number, string> = {};
  for (const [name, key] of Object.entries(keybinds)) {
    const slot = slotFromBindingName(name);
    if (slot !== undefined && key) out[slot] = key;
  }
  return out;
}

export function shortHotkey(key: string): string {
  return key
    .replace(/SHIFT-/g, "S-")
    .replace(/CTRL-/g, "C-")
    .replace(/ALT-/g, "A-")
    .replace(/BUTTON3/g, "M3")
    .replace(/BUTTON4/g, "M4")
    .replace(/BUTTON5/g, "M5");
}
