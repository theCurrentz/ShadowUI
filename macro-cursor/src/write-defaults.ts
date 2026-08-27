import type { DeckAction } from "./parse-defaults.ts";
import { parseClassDefaults, sliceBalanced } from "./parse-defaults.ts";
import {
  bakeLoadoutToDeck,
  type ActionValue,
} from "./deck-edit.ts";

type Field = { open: number; end: number };

function skipNoise(inner: string, i: number): number {
  const n = inner.length;
  while (i < n) {
    while (i < n && /[\s,]/.test(inner[i]!)) i++;
    if (inner.startsWith("--", i)) {
      const nl = inner.indexOf("\n", i);
      i = nl === -1 ? n : nl + 1;
      continue;
    }
    break;
  }
  return i;
}

function walkTable(src: string, open: number): Map<string, Field> {
  const block = sliceBalanced(src, open);
  const base = open + 1;
  const inner = block.inner;
  const fields = new Map<string, Field>();
  let i = 0;
  const n = inner.length;
  while (i < n) {
    i = skipNoise(inner, i);
    if (i >= n) break;
    let key: string;
    if (inner[i] === "[") {
      const close = inner.indexOf("]", i);
      if (close < 0) break;
      key = inner.slice(i + 1, close).trim().replace(/^["']|["']$/g, "");
      i = close + 1;
    } else {
      const m = inner.slice(i).match(/^([A-Za-z_][\w]*)/);
      if (!m) break;
      key = m[1]!;
      i += m[0].length;
    }
    i = skipNoise(inner, i);
    if (inner[i] !== "=") break;
    i++;
    i = skipNoise(inner, i);
    if (inner[i] === "{") {
      const nested = sliceBalanced(inner, i);
      fields.set(key, { open: base + i, end: base + nested.end });
      i = nested.end;
    } else if (inner.startsWith("act(", i)) {
      while (i < n && inner[i] !== ")") {
        if (inner[i] === "{") {
          const extra = sliceBalanced(inner, i);
          i = extra.end;
          continue;
        }
        i++;
      }
      if (i < n) i++;
    } else {
      const m = inner.slice(i).match(/^[^,\n}]+/);
      i += m ? m[0].length : 1;
    }
  }
  return fields;
}

function classTableOpen(src: string, classId: string): number {
  const assign = src.indexOf(`Addon.Defaults.classes.${classId}`);
  if (assign < 0) return -1;
  return src.indexOf("{", assign);
}

function emitLuaString(value: string): string {
  if (/^[A-Z][A-Z0-9_]*$/.test(value)) return value;
  return `"${value.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n")}"`;
}

export function formatActionsTable(
  actions: Record<number, ActionValue | DeckAction>,
  indent: string,
): string {
  const slots = Object.keys(actions)
    .map(Number)
    .filter((n) => Number.isInteger(n))
    .sort((a, b) => a - b);
  if (!slots.length) return "";
  const lines: string[] = [];
  for (const slot of slots) {
    const value = actions[slot];
    if (value === false) {
      lines.push(`${indent}[${slot}] = false,`);
      continue;
    }
    if (!value) continue;
    const extra: string[] = [];
    if (value.match) extra.push(`match = ${emitLuaString(value.match)}`);
    if (value.notMatch) extra.push(`notMatch = ${emitLuaString(value.notMatch)}`);
    if (value.createName) extra.push(`createName = ${emitLuaString(value.createName)}`);
    if (!extra.length) extra.push(`match = ${emitLuaString(value.name)}`);
    const oneLine = extra.length === 1 && extra[0]!.startsWith("match = ");
    if (oneLine && !value.createName && !value.notMatch) {
      lines.push(`${indent}[${slot}] = act("${value.id}", "${value.name}", { ${extra[0]} }),`);
    } else {
      const inner = extra.map((e) => `${indent}  ${e},`).join("\n");
      lines.push(`${indent}[${slot}] = act("${value.id}", "${value.name}", {\n${inner}\n${indent}}),`);
    }
  }
  return lines.join("\n");
}

function replaceFieldTable(src: string, field: Field, inner: string, indent: string): string {
  const table = inner ? `{\n${inner}\n${indent}}` : `{\n${indent}}`;
  return src.slice(0, field.open) + table + src.slice(field.end);
}

function insertActionsField(src: string, tableEnd: number, inner: string, indent: string): string {
  const block = inner
    ? `${indent}actions = {\n${inner}\n${indent}},\n`
    : `${indent}actions = {},\n`;
  return src.slice(0, tableEnd - 1) + block + src.slice(tableEnd - 1);
}

export function replaceActionsTable(
  src: string,
  classId: string,
  variantName: string,
  actions: Record<number, ActionValue | DeckAction>,
): string {
  const open = classTableOpen(src, classId);
  if (open < 0) return src;
  const classFields = walkTable(src, open);
  if (variantName) {
    const variantsField = classFields.get("variants");
    if (!variantsField) return src;
    const variants = walkTable(src, variantsField.open);
    const variant = variants.get(variantName);
    if (!variant) return src;
    const fields = walkTable(src, variant.open);
    const indent = "        ";
    const inner = formatActionsTable(actions, indent);
    const existing = fields.get("actions");
    if (existing) return replaceFieldTable(src, existing, inner, "      ");
    return insertActionsField(src, variant.end, inner, "      ");
  }
  const indent = "    ";
  const inner = formatActionsTable(actions, indent);
  const existing = classFields.get("actions");
  if (existing) return replaceFieldTable(src, existing, inner, "  ");
  return insertActionsField(src, sliceBalanced(src, open).end, inner, "  ");
}

export function applyLoadoutToClassLua(
  src: string,
  classId: string,
  variantName: string,
  overlay: Record<number, ActionValue>,
  fallbackMatches: Record<string, string> = {},
): { src: string; remainingOverlay: Record<number, ActionValue> } | null {
  const spec = parseClassDefaults(classId, src);
  if (!spec.deckSlots.length) return null;
  const variant = spec.variants.find((v) => v.name === variantName);
  const baked = bakeLoadoutToDeck(
    spec.actions,
    variant?.actions ?? {},
    overlay,
    spec.deckSlots,
    spec.variants.map((v) => v.actions),
    fallbackMatches,
  );
  const nextSrc =
    variantName && variant
      ? replaceActionsTable(src, classId, variantName, baked.variantActions)
      : replaceActionsTable(src, classId, "", baked.classActions);
  return { src: nextSrc, remainingOverlay: baked.remainingOverlay };
}

export function fallbackMatchesFromBodies(
  macros: Array<{ id: string; body: string }>,
): Record<string, string> {
  const out: Record<string, string> = {};
  for (const rec of macros) {
    const tip = /^#showtooltip ([^\n]+)/m.exec(rec.body);
    if (tip) out[rec.id] = tip[1]!;
  }
  return out;
}

export function overlayFromUnknown(raw: Record<string, unknown>): Record<number, ActionValue> {
  const overlay: Record<number, ActionValue> = {};
  for (const [slot, action] of Object.entries(raw)) {
    const n = Number(slot);
    if (!Number.isInteger(n)) continue;
    if (action === false) overlay[n] = false;
    else if (action && typeof action === "object" && !Array.isArray(action)) {
      const rec = action as { id?: unknown; name?: unknown };
      if (typeof rec.id === "string" && typeof rec.name === "string") {
        overlay[n] = action as ActionValue;
      }
    }
  }
  return overlay;
}
