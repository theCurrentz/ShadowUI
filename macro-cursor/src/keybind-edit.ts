import { hotkeysBySlot, slotFromBindingName } from "./parse-defaults.ts";

export type BindValue = string | false;

export type KeybindStore = {
  base: Record<string, BindValue>;
  classes: Record<string, Record<string, BindValue>>;
};

const IGNORE_KEYS = new Set([
  "Shift",
  "Control",
  "Alt",
  "Meta",
  "Dead",
  "Unidentified",
]);

const IGNORE_CODES = new Set([
  "ShiftLeft",
  "ShiftRight",
  "ControlLeft",
  "ControlRight",
  "AltLeft",
  "AltRight",
  "MetaLeft",
  "MetaRight",
]);

const CODE_KEYS: Record<string, string> = {
  Backquote: "`",
  Minus: "-",
  Equal: "=",
  BracketLeft: "[",
  BracketRight: "]",
  Backslash: "\\",
  Semicolon: ";",
  Quote: "'",
  Comma: ",",
  Period: ".",
  Slash: "/",
  Space: "SPACE",
  Escape: "ESCAPE",
  Backspace: "BACKSPACE",
  Enter: "ENTER",
  Tab: "TAB",
  Delete: "DELETE",
  Insert: "INSERT",
  Home: "HOME",
  End: "END",
  PageUp: "PAGEUP",
  PageDown: "PAGEDOWN",
  ArrowUp: "UP",
  ArrowDown: "DOWN",
  ArrowLeft: "LEFT",
  ArrowRight: "RIGHT",
  CapsLock: "CAPSLOCK",
  NumpadAdd: "NUMPADPLUS",
  NumpadSubtract: "NUMPADMINUS",
  NumpadMultiply: "NUMPADMULTIPLY",
  NumpadDivide: "NUMPADDIVIDE",
  NumpadDecimal: "NUMPADDECIMAL",
  NumpadEnter: "ENTER",
};

export function emptyKeybindStore(): KeybindStore {
  return { base: {}, classes: {} };
}

export function baseOverlay(store: KeybindStore): Record<string, BindValue> {
  return { ...(store.base ?? {}) };
}

export function stackBinds(
  shipped: Record<string, string> = {},
  ...overlays: Record<string, BindValue>[]
): Record<string, string> {
  let out = shipped;
  for (const overlay of overlays) out = mergeBindingTables(out, overlay);
  return out;
}

export function canonicalSlotName(slot: number): string {
  return "CLICK ShadowUIActionButton" + slot + ":Keybind";
}

export function classOverlay(store: KeybindStore, classId: string): Record<string, BindValue> {
  return { ...(store.classes[classId] ?? {}) };
}

export function mergeBindingTables(
  shipped: Record<string, string>,
  overlay: Record<string, BindValue> = {},
): Record<string, string> {
  const bySlot = new Map<number, string>();
  const byKey = new Map<string, number>();

  function dropSlot(slot: number): void {
    const key = bySlot.get(slot);
    if (key === undefined) return;
    bySlot.delete(slot);
    if (byKey.get(key) === slot) byKey.delete(key);
  }

  function set(name: string, key: string): void {
    const slot = slotFromBindingName(name);
    if (slot === undefined || !key) return;
    const prior = byKey.get(key);
    if (prior !== undefined && prior !== slot) dropSlot(prior);
    dropSlot(slot);
    bySlot.set(slot, key);
    byKey.set(key, slot);
  }

  for (const [name, key] of Object.entries(shipped)) set(name, key);
  for (const [name, key] of Object.entries(overlay)) {
    const slot = slotFromBindingName(name);
    if (key === false || key === "") {
      if (slot !== undefined) dropSlot(slot);
      continue;
    }
    set(name, key);
  }

  const out: Record<string, string> = {};
  for (const [slot, key] of bySlot) out[canonicalSlotName(slot)] = key;
  return out;
}

export function applySlotBind(
  overlay: Record<string, BindValue>,
  shipped: Record<string, string>,
  slot: number,
  key: string | false,
): Record<string, BindValue> {
  const next = { ...overlay };
  const name = canonicalSlotName(slot);
  if (key === false) {
    next[name] = false;
    return next;
  }
  const current = hotkeysBySlot(mergeBindingTables(shipped, overlay));
  for (const [other, bound] of Object.entries(current)) {
    if (bound === key && Number(other) !== slot) {
      next[canonicalSlotName(Number(other))] = false;
    }
  }
  next[name] = key;
  return next;
}

export function normalizeBindingKey(
  key: string,
  mods: { shift?: boolean; ctrl?: boolean; alt?: boolean; meta?: boolean },
): string | null {
  if (!key || IGNORE_KEYS.has(key)) return null;
  if (key === "ESCAPE") return "ESCAPE";
  if (key === "BUTTON1" || key === "BUTTON2") {
    if (!(mods.shift || mods.ctrl || mods.alt || mods.meta)) return null;
  }
  let out = key;
  if (mods.shift) out = "SHIFT-" + out;
  if (mods.ctrl) out = "CTRL-" + out;
  if (mods.alt) out = "ALT-" + out;
  if (mods.meta) out = "META-" + out;
  return out;
}

function keyFromCode(code: string): string | null {
  if (CODE_KEYS[code]) return CODE_KEYS[code]!;
  if (/^Key[A-Z]$/.test(code)) return code.slice(3);
  if (/^Digit[0-9]$/.test(code)) return code.slice(5);
  if (/^F([1-9]|1[0-2])$/.test(code)) return code;
  if (/^Numpad[0-9]$/.test(code)) return "NUMPAD" + code.slice(6);
  return null;
}

export function bindKeydownAction(
  ev: KeyboardEvent,
  bindMode: boolean,
  hoverSlot: number | null,
): { preventDefault: boolean; key: string | null } {
  if (!bindMode) return { preventDefault: false, key: null };
  const chord = Boolean(ev.ctrlKey || ev.metaKey || ev.altKey);
  if (hoverSlot === null) return { preventDefault: chord, key: null };
  return { preventDefault: true, key: wowKeyFromKeyboardEvent(ev) };
}

export function wowKeyFromKeyboardEvent(ev: KeyboardEvent): string | null {
  if (IGNORE_CODES.has(ev.code)) return null;
  if (ev.key === "Escape") return "ESCAPE";
  const key = keyFromCode(ev.code);
  if (!key) return null;
  return normalizeBindingKey(key, {
    shift: ev.shiftKey,
    ctrl: ev.ctrlKey,
    alt: ev.altKey,
    meta: ev.metaKey,
  });
}

export function wowKeyFromMouseEvent(ev: MouseEvent): string | null {
  const map: Record<number, string> = {
    0: "BUTTON1",
    1: "BUTTON3",
    2: "BUTTON2",
    3: "BUTTON4",
    4: "BUTTON5",
  };
  const key = map[ev.button];
  if (!key) return null;
  return normalizeBindingKey(key, {
    shift: ev.shiftKey,
    ctrl: ev.ctrlKey,
    alt: ev.altKey,
    meta: ev.metaKey,
  });
}

export function wowKeyFromWheelEvent(ev: WheelEvent): string | null {
  if (!ev.deltaY) return null;
  const key = ev.deltaY < 0 ? "MOUSEWHEELUP" : "MOUSEWHEELDOWN";
  return normalizeBindingKey(key, {
    shift: ev.shiftKey,
    ctrl: ev.ctrlKey,
    alt: ev.altKey,
    meta: ev.metaKey,
  });
}
