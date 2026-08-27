import type { DeckAction, DeckSlotRange } from "./parse-defaults.ts";
import { slotInDeck } from "./parse-defaults.ts";
import type { Pickup } from "./spellbook.ts";

export type SlotAction = DeckAction & {
  kind?: "macro" | "spell";
  icon?: string;
  rank?: string;
  spellId?: number;
};

export type ActionValue = SlotAction | false;

export type ActionStore = {
  classes: Record<string, Record<string, Record<string, ActionValue>>>;
};

export function emptyActionStore(): ActionStore {
  return { classes: {} };
}

export function classActionOverlay(
  store: ActionStore,
  classId: string,
  variant: string,
): Record<number, ActionValue> {
  const table = store.classes[classId]?.[variant] ?? {};
  const out: Record<number, ActionValue> = {};
  for (const [slot, value] of Object.entries(table)) {
    const n = Number(slot);
    if (!Number.isInteger(n) || n < 1) continue;
    out[n] = value;
  }
  return out;
}

export function mergeActionTables(
  shipped: Record<number, DeckAction>,
  overlay: Record<number, ActionValue> = {},
): Record<number, SlotAction> {
  const out: Record<number, SlotAction> = {};
  for (const [slot, action] of Object.entries(shipped)) {
    out[Number(slot)] = { kind: "macro", ...action };
  }
  for (const [slot, value] of Object.entries(overlay)) {
    const n = Number(slot);
    if (value === false) {
      delete out[n];
      continue;
    }
    out[n] = value;
  }
  return out;
}

export function pickupToAction(p: Pickup): SlotAction {
  if (p.kind === "macro") {
    return { kind: "macro", id: p.id, name: p.name, icon: p.icon };
  }
  return {
    kind: "spell",
    id: p.id,
    name: p.name,
    icon: p.icon,
    rank: p.rank,
    spellId: p.spellId,
  };
}

export function actionToPickup(action: SlotAction, fromSlot?: number): Pickup {
  const pickup: Pickup =
    action.kind === "spell" && action.spellId
      ? {
          kind: "spell",
          id: action.id,
          name: action.name,
          icon: action.icon ?? "",
          spellId: action.spellId,
          rank: action.rank ?? "",
        }
      : { kind: "macro", id: action.id, name: action.name, icon: action.icon ?? "" };
  return fromSlot ? { ...pickup, fromSlot } : pickup;
}

export function dropOnSlot(
  shipped: Record<number, DeckAction>,
  overlay: Record<number, ActionValue>,
  slot: number,
  incoming: Pickup,
): { overlay: Record<number, ActionValue>; held?: Pickup } {
  const fromSlot = incoming.fromSlot;
  if (fromSlot === slot) return { overlay };
  const merged = mergeActionTables(shipped, overlay);
  const current = merged[slot];
  const placed: Pickup = { ...incoming };
  delete placed.fromSlot;
  const next: Record<number, ActionValue> = {
    ...overlay,
    [slot]: pickupToAction(placed),
  };
  if (fromSlot !== undefined) next[fromSlot] = false;
  const same =
    current &&
    current.id === incoming.id &&
    (incoming.kind !== "spell" || (current.rank ?? "") === incoming.rank);
  const held = current && !same ? actionToPickup(current) : undefined;
  return { overlay: next, held };
}

export function dropOffBar(
  overlay: Record<number, ActionValue>,
  fromSlot: number,
): Record<number, ActionValue> {
  return { ...overlay, [fromSlot]: false };
}

export function applySlotAction(
  overlay: Record<number, ActionValue>,
  slot: number,
  action: ActionValue,
): Record<number, ActionValue> {
  return { ...overlay, [slot]: action };
}

function sameAction(a: SlotAction | undefined, b: DeckAction | SlotAction | undefined): boolean {
  if (!a && !b) return true;
  if (!a || !b) return false;
  const bk = b as SlotAction;
  return (
    a.id === b.id &&
    a.name === b.name &&
    (a.kind ?? "macro") === (bk.kind ?? "macro") &&
    (a.rank ?? "") === (bk.rank ?? "") &&
    (a.spellId ?? 0) === (bk.spellId ?? 0)
  );
}

/** Overlay that copies one stance/form page onto the other pages of the same Bar. */
export function copyBarPages(
  shipped: Record<number, DeckAction>,
  overlay: Record<number, ActionValue>,
  pages: number[],
  sourceIndex: number,
  buttonCount: number,
): Record<number, ActionValue> {
  const srcFirst = pages[sourceIndex];
  if (!srcFirst || pages.length < 2 || buttonCount < 1) return overlay;
  const merged = mergeActionTables(shipped, overlay);
  const next: Record<number, ActionValue> = { ...overlay };
  for (let i = 0; i < buttonCount; i++) {
    const src = merged[srcFirst + i];
    for (let p = 0; p < pages.length; p++) {
      if (p === sourceIndex) continue;
      const destSlot = pages[p]! + i;
      const destShipped = shipped[destSlot];
      if (!src) {
        if (destShipped) next[destSlot] = false;
        else delete next[destSlot];
        continue;
      }
      if (sameAction(src, destShipped)) delete next[destSlot];
      else next[destSlot] = { ...src };
    }
  }
  return next;
}

/** Overlay that makes destShipped match sourceMerged on every Action Slot. */
export function copyVariantActions(
  sourceMerged: Record<number, SlotAction>,
  destShipped: Record<number, DeckAction>,
): Record<number, ActionValue> {
  const overlay: Record<number, ActionValue> = {};
  const slots = new Set<number>([
    ...Object.keys(sourceMerged).map(Number),
    ...Object.keys(destShipped).map(Number),
  ]);
  for (const slot of slots) {
    const src = sourceMerged[slot];
    const dst = destShipped[slot];
    if (!src) {
      if (dst) overlay[slot] = false;
      continue;
    }
    if (!sameAction(src, dst)) overlay[slot] = src;
  }
  return overlay;
}

export function overlayForWrite(overlay: Record<number, ActionValue>): Record<string, ActionValue> {
  const out: Record<string, ActionValue> = {};
  for (const [slot, value] of Object.entries(overlay)) out[String(slot)] = value;
  return out;
}

export function isSpellAction(action: SlotAction | DeckAction): boolean {
  return (action.kind ?? "macro") === "spell" || action.id.startsWith("spell:");
}

function extraStrength(action: DeckAction): number {
  let n = 0;
  if (action.match && action.match !== action.name) n += 2;
  if (action.createName) n += 1;
  if (action.notMatch) n += 1;
  if (action.match && /^[A-Z][A-Z0-9_]*$/.test(action.match)) n += 2;
  return n;
}

function extrasById(
  ...tables: Array<Record<number, DeckAction | false | SlotAction | undefined>>
): Map<string, DeckAction> {
  const extras = new Map<string, DeckAction>();
  for (const table of tables) {
    for (const value of Object.values(table)) {
      if (!value) continue;
      if (!value.match && !value.notMatch && !value.createName) continue;
      const prev = extras.get(value.id);
      if (!prev || extraStrength(value) > extraStrength(prev)) extras.set(value.id, value);
    }
  }
  return extras;
}

function decorateMacro(
  action: SlotAction,
  extras: Map<string, DeckAction>,
  fallbackMatches: Record<string, string> = {},
): DeckAction {
  const extra = extras.get(action.id);
  const out: DeckAction = { id: action.id, name: action.name };
  const strong =
    extra?.match && extra.match !== extra.name ? extra.match : undefined;
  const match = strong ?? action.match ?? fallbackMatches[action.id] ?? extra?.match ?? action.name;
  if (match) out.match = match;
  if (extra?.notMatch) out.notMatch = extra.notMatch;
  if (extra?.createName) out.createName = extra.createName;
  return out;
}

function sameMacroId(a: SlotAction | DeckAction | undefined, b: DeckAction | false | undefined): boolean {
  if (!a || !b) return false;
  return a.id === b.id && !isSpellAction(a);
}

/** Bake a sidecar loadout overlay into Class / Variant Action Deck tables. */
export function bakeLoadoutToDeck(
  classActions: Record<number, DeckAction>,
  variantActions: Record<number, DeckAction | false>,
  overlay: Record<number, ActionValue>,
  deckSlots: DeckSlotRange[],
  extraTables: Array<Record<number, DeckAction | false>> = [],
  fallbackMatches: Record<string, string> = {},
): {
  classActions: Record<number, DeckAction>;
  variantActions: Record<number, ActionValue>;
  remainingOverlay: Record<number, ActionValue>;
} {
  const extras = extrasById(classActions, variantActions, ...extraTables);
  const shipped: Record<number, DeckAction> = { ...classActions };
  for (const [slot, value] of Object.entries(variantActions)) {
    const n = Number(slot);
    if (value === false) delete shipped[n];
    else shipped[n] = value;
  }
  const merged = mergeActionTables(shipped, overlay);
  const nextClass: Record<number, DeckAction> = {};
  const nextVariant: Record<number, ActionValue> = {};
  const slots = new Set<number>([
    ...Object.keys(classActions).map(Number),
    ...Object.keys(variantActions).map(Number),
    ...Object.keys(overlay).map(Number),
    ...Object.keys(merged).map(Number),
  ]);
  for (const slot of slots) {
    if (!slotInDeck(deckSlots, slot)) continue;
    const action = merged[slot];
    if (action && isSpellAction(action)) continue;
    if (action) nextClass[slot] = decorateMacro(action, extras, fallbackMatches);
    if (!action) {
      if (classActions[slot]) nextVariant[slot] = false;
      continue;
    }
    if (sameMacroId(action, classActions[slot])) continue;
    nextVariant[slot] = decorateMacro(action, extras, fallbackMatches);
  }
  const written = { ...classActions };
  for (const [slot, value] of Object.entries(nextVariant)) {
    const n = Number(slot);
    if (value === false) delete written[n];
    else written[n] = value;
  }
  return {
    classActions: nextClass,
    variantActions: nextVariant,
    remainingOverlay: copyVariantActions(merged, written),
  };
}
