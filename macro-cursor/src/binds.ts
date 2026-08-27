import { applySlotBind, stackBinds, type BindValue } from "./keybind-edit.ts";
import { mergeActionTables, type ActionValue } from "./deck-edit.ts";
import {
  firstActionSlot,
  hotkeysBySlot,
  mergeActions,
  mergeClassLayout,
  type BarCfg,
  type ClassSpec,
  type DeckAction,
  type VariantSpec,
} from "./parse-defaults.ts";

export type StanceName = string;

export const STANCES: StanceName[] = ["Battle", "Defensive", "Berserker"];

/** Bonus-bar first slots: 73 Cat/Stealth/Battle, 85 Prowl/Defensive, 97 Bear/Berserker. */
export function pageLabel(firstSlot: number, classId = "WARRIOR"): string {
  if (classId === "DRUID") {
    if (firstSlot === 1) return "Caster";
    if (firstSlot === 73) return "Cat";
    if (firstSlot === 85) return "Prowl";
    if (firstSlot === 97) return "Bear";
  }
  if (classId === "ROGUE") {
    if (firstSlot === 1) return "Open";
    if (firstSlot === 73) return "Stealth";
  }
  if (firstSlot === 73) return "Battle";
  if (firstSlot === 85) return "Defensive";
  if (firstSlot === 97) return "Berserker";
  if (firstSlot === 1) return "Main";
  return `Slot ${firstSlot}`;
}

export function pageLabels(pages: number[], classId = "WARRIOR"): string[] {
  return pages.map((first) => pageLabel(first, classId));
}

export type HudButton = {
  barId: string;
  index: number;
  bindSlot: number;
  actionSlot: number;
  key: string;
  action?: DeckAction;
};

export type MacroBind = {
  key: string;
  bindSlot: number;
  actionSlot: number;
  barId: string;
  stance?: StanceName;
};

export type KeyCollision = {
  key: string;
  buttons: { barId: string; index: number; bindSlot: number; macroId?: string }[];
};

const KEY_RE = /\|\s*key\s*\(([^)]*)\)\s*$/i;

export function commentKey(body: string): string {
  for (const line of body.split("\n")) {
    const t = line.trim();
    if (!t.startsWith("#")) continue;
    const m = t.match(KEY_RE);
    if (m) return m[1]!.trim();
  }
  return "";
}

export function setCommentKey(body: string, key: string): string {
  const lines = body.replace(/\r\n/g, "\n").split("\n");
  const label = key ? ` | key (${key})` : "";
  const scope = /#\s*(global|class-specific|character-specific)\b/i;
  for (let i = 0; i < lines.length; i++) {
    const t = lines[i]!.trim();
    if (!scope.test(t)) continue;
    const stripped = t.replace(/\s*\|\s*key\s*\([^)]*\)\s*$/i, "");
    const nextLine = stripped + label;
    const next = [...lines];
    next[i] = nextLine;
    const out = next.join("\n");
    return out.length > 255 ? body : out;
  }
  const insert = `# class-specific unknown all${label}`;
  if (lines[0]?.startsWith("#showtooltip")) {
    return [lines[0], insert, ...lines.slice(1)].join("\n");
  }
  return [insert, ...lines].join("\n");
}

export function canonicalKey(raw: string): string {
  let s = raw.trim().toUpperCase();
  s = s.replace(/\s+/g, " ");
  s = s.replace(/MOUSE\s*BUTTON\s*/g, "BUTTON");
  s = s.replace(/MOUST\s*BUTTON\s*/g, "BUTTON");
  s = s.replace(/\bSHIFT\s*-?\s*/g, "SHIFT-");
  s = s.replace(/\bCTRL\s*-?\s*/g, "CTRL-");
  s = s.replace(/\bALT\s*-?\s*/g, "ALT-");
  s = s.replace(/-+/g, "-");
  s = s.replace(/^-|-$/g, "");
  if (s === "M3") return "BUTTON3";
  if (s === "M4") return "BUTTON4";
  if (s === "M5") return "BUTTON5";
  return s;
}

function stanceOfPage(pages: number[] | undefined, first: number): StanceName | undefined {
  if (!pages || pages.length < 2) return undefined;
  if (!pages.includes(first)) return undefined;
  return pageLabel(first);
}

export function hudButtons(
  layout: Record<string, BarCfg>,
  actions: Record<number, DeckAction>,
  keybinds: Record<string, string>,
  stanceIndex: number,
): HudButton[] {
  const keys = hotkeysBySlot(keybinds);
  const out: HudButton[] = [];
  for (const [barId, cfg] of Object.entries(layout)) {
    if (!cfg.enabled) continue;
    const bindFirst = firstActionSlot(barId, cfg);
    if (bindFirst === undefined) continue;
    const pages = cfg.stancePages;
    const pageFirst =
      pages && pages.length ? pages[Math.max(0, Math.min(stanceIndex, pages.length - 1))]! : bindFirst;
    for (let i = 0; i < cfg.buttons; i++) {
      const bindSlot = bindFirst + i;
      const actionSlot = pageFirst + i;
      out.push({
        barId,
        index: i,
        bindSlot,
        actionSlot,
        key: keys[bindSlot] ?? "",
        action: actions[actionSlot],
      });
    }
  }
  return out;
}

export function bindsForMacro(
  layout: Record<string, BarCfg>,
  actions: Record<number, DeckAction>,
  keybinds: Record<string, string>,
  macroId: string,
): MacroBind[] {
  return bindsForActions(layout, actions, keybinds, [macroId]);
}

export function bindsForActions(
  layout: Record<string, BarCfg>,
  actions: Record<number, DeckAction>,
  keybinds: Record<string, string>,
  actionIds: string[],
): MacroBind[] {
  const want = new Set(actionIds);
  const keys = hotkeysBySlot(keybinds);
  const found: MacroBind[] = [];
  for (const [barId, cfg] of Object.entries(layout)) {
    if (!cfg.enabled) continue;
    const bindFirst = firstActionSlot(barId, cfg);
    if (bindFirst === undefined) continue;
    const pages = cfg.stancePages?.length ? cfg.stancePages : [bindFirst];
    for (const pageFirst of pages) {
      for (let i = 0; i < cfg.buttons; i++) {
        const actionSlot = pageFirst + i;
        const id = actions[actionSlot]?.id;
        if (!id || !want.has(id)) continue;
        const bindSlot = bindFirst + i;
        found.push({
          key: keys[bindSlot] ?? "",
          bindSlot,
          actionSlot,
          barId,
          stance: stanceOfPage(cfg.stancePages, pageFirst),
        });
      }
    }
  }
  return found;
}

export function actionIdsOnBars(actions: Record<number, DeckAction>): Set<string> {
  return new Set(Object.values(actions).map((a) => a.id));
}

export function applyActionKey(
  overlay: Record<string, BindValue>,
  shipped: Record<string, string>,
  layout: Record<string, BarCfg>,
  actions: Record<number, DeckAction>,
  actionIds: string[],
  key: string,
): Record<string, BindValue> {
  const slot = bindsForActions(layout, actions, shipped, actionIds)[0]?.bindSlot;
  if (slot === undefined) return overlay;
  return applySlotBind(overlay, shipped, slot, key === "ESCAPE" || key === "" ? false : key);
}

export function assignedKeyLabel(binds: MacroBind[], fallback: string): string {
  if (!binds.length) return fallback;
  const keys = [...new Set(binds.map((b) => b.key).filter(Boolean))];
  return keys.length ? keys.join(" / ") : "";
}

export function classKeyCollisions(buttons: HudButton[]): KeyCollision[] {
  const byKey = new Map<string, HudButton[]>();
  for (const b of buttons) {
    if (!b.key) continue;
    const k = canonicalKey(b.key);
    const list = byKey.get(k) ?? [];
    list.push(b);
    byKey.set(k, list);
  }
  const collisions: KeyCollision[] = [];
  for (const [key, list] of byKey) {
    const unique = new Map<string, HudButton>();
    for (const b of list) unique.set(`${b.barId}:${b.index}`, b);
    if (unique.size < 2) continue;
    collisions.push({
      key,
      buttons: [...unique.values()].map((b) => ({
        barId: b.barId,
        index: b.index,
        bindSlot: b.bindSlot,
        macroId: b.action?.id,
      })),
    });
  }
  return collisions.sort((a, b) => a.key.localeCompare(b.key));
}

export function resolveHud(
  base: Record<string, BarCfg>,
  cls: ClassSpec,
  variant: VariantSpec | undefined,
  stanceIndex: number,
  overlay: Record<string, BindValue> = {},
  actionOverlay: Record<number, ActionValue> = {},
  baseKeybinds: Record<string, string> = {},
  baseBindOverlay: Record<string, BindValue> = {},
) {
  const layout = mergeClassLayout(base, cls, variant);
  const actions = mergeActionTables(mergeActions(cls, variant), actionOverlay);
  const keybinds = stackBinds(
    baseKeybinds,
    cls.keybinds,
    variant?.keybinds ?? {},
    baseBindOverlay,
    overlay,
  );
  const buttons = hudButtons(layout, actions, keybinds, stanceIndex);
  return { layout, actions, keybinds, buttons };
}
