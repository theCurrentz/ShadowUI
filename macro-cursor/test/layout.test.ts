import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";
import {
  actionIdsOnBars,
  applyActionKey,
  assignedKeyLabel,
  bindsForActions,
  bindsForMacro,
  canonicalKey,
  classKeyCollisions,
  commentKey,
  hudButtons,
  setCommentKey,
} from "../src/binds.ts";
import {
  applySlotBind,
  bindKeydownAction,
  mergeBindingTables,
  stackBinds,
  wowKeyFromKeyboardEvent,
  wowKeyFromMouseEvent,
} from "../src/keybind-edit.ts";
import {
  firstActionSlot,
  hotkeysBySlot,
  mergeActions,
  mergeClassLayout,
  parseBaseKeybinds,
  parseBaseLayout,
  parseClassDefaults,
  shortHotkey,
  slotFromBindingName,
} from "../src/parse-defaults.ts";
import { applyLoadoutToClassLua } from "../src/write-defaults.ts";
import type { Macro } from "../src/types.ts";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

function read(rel: string): string {
  return fs.readFileSync(path.join(root, rel), "utf8");
}

const base = parseBaseLayout(read("defaults/base.lua"));
const baseKeybinds = parseBaseKeybinds(read("defaults/base.lua"));
const warrior = parseClassDefaults("WARRIOR", read("defaults/classes/WARRIOR.lua"));
const druid = parseClassDefaults("DRUID", read("defaults/classes/DRUID.lua"));
const rogue = parseClassDefaults("ROGUE", read("defaults/classes/ROGUE.lua"));
const mage = parseClassDefaults("MAGE", read("defaults/classes/MAGE.lua"));
const paladin = parseClassDefaults("PALADIN", read("defaults/classes/PALADIN.lua"));

const furyKeybindDeck = {
  1: { id: "w-hm", name: "hm" },
  2: { id: "w-charge", name: "charge" },
  4: { id: "w-interrupt", name: "wkick" },
  73: { id: "w-bt", name: "bt" },
  85: { id: "w-bt", name: "bt" },
  97: { id: "w-bt", name: "bt" },
};

function classKeys(cls: typeof warrior, variantName?: string) {
  const variant = variantName ? cls.variants.find((v) => v.name === variantName) : undefined;
  return stackBinds(baseKeybinds, cls.keybinds, variant?.keybinds ?? {});
}

test("base layout matches ShadowUI six-row stack", () => {
  assert.equal(base.bar1.y, 5 * 32.4);
  assert.equal(base.bar6.y, 0);
  assert.equal(base.bar7.columns, 3);
  assert.equal(base.bar8.columns, 3);
  assert.equal(base.bar1.buttonSize, 32.4);
});

test("Warrior Action Deck parse and Base Keybinds apply to every class", () => {
  assert.deepEqual(warrior.layout.bar1.stancePages, [73, 85, 97]);
  assert.deepEqual(druid.layout.bar1.stancePages, [1, 73, 85, 97]);
  assert.deepEqual(rogue.layout.bar1.stancePages, [1, 73]);
  assert.equal(druid.layout.bar7.enabled, false);
  assert.equal(rogue.layout.bar7.enabled, false);
  assert.equal(warrior.layout.bar2.firstSlot, 1);
  assert.equal(warrior.layout.bar9.enabled, false);
  assert.equal(warrior.keybinds["CLICK ShadowUIActionButton1:Keybind"], undefined);
  assert.equal(baseKeybinds["CLICK ShadowUIActionButton1:Keybind"], "1");
  assert.equal(baseKeybinds["CLICK ShadowUIActionButton73:Keybind"], "Q");
  assert.equal(baseKeybinds["CLICK ShadowUIActionButton109:Keybind"], "BUTTON5");
  const paladinKeys = hotkeysBySlot(classKeys(paladin));
  assert.equal(paladinKeys[1], "1");
  assert.equal(paladinKeys[73], "Q");
  assert.equal(warrior.actions[1]?.id, "w-hm");
  assert.equal(warrior.actions[4]?.id, "w-interrupt");
  const fury = warrior.variants.find((v) => v.name === "Fury");
  assert.ok(fury);
  assert.equal(fury.talentTree, 2);
  assert.ok(fury.actions[73]);
  assert.deepEqual(warrior.deckSlots, [
    [1, 12],
    [73, 111],
  ]);
  assert.equal(warrior.actions[1]?.match, "HAMSTRING_MATCH");
  assert.equal(warrior.actions[1]?.createName, "suiHamstring");
});

test("Mage layout maps bars; Base Keybinds fill the slots", () => {
  assert.equal(slotFromBindingName("MULTIACTIONBAR1BUTTON1"), 61);
  assert.equal(slotFromBindingName("ACTIONBUTTON1"), 1);
  assert.equal(slotFromBindingName("CLICK BT4Button17:Keybind"), 17);
  assert.equal(mage.layout.bar2.firstSlot, 61);
  assert.equal(mage.keybinds.MULTIACTIONBAR1BUTTON1, undefined);
  const keys = hotkeysBySlot(classKeys(mage));
  assert.equal(keys[61], "ALT-SHIFT-1");
  assert.equal(keys[17], "SHIFT-X");
  assert.equal(shortHotkey("BUTTON3"), "M3");
  assert.equal(shortHotkey("CTRL-SHIFT-1"), "C-S-1");
});

test("assigned keybind uses the Action Bar when the action is placed", () => {
  assert.equal(
    assignedKeyLabel([{ key: "", bindSlot: 1, actionSlot: 1, barId: "bar2" }], "T"),
    "",
  );
  assert.equal(assignedKeyLabel([], "T"), "T");
  assert.equal(
    assignedKeyLabel([{ key: "E", bindSlot: 2, actionSlot: 2, barId: "bar2" }], "T"),
    "E",
  );
});

test("Action Bars mark placed macros and spells", () => {
  const ids = actionIdsOnBars({
    1: { id: "w-hm", name: "hm" },
    73: { id: "spell:78", name: "Heroic Strike", kind: "spell", spellId: 78 },
  });
  assert.equal(ids.has("w-hm"), true);
  assert.equal(ids.has("spell:78"), true);
  assert.equal(ids.has("w-charge"), false);
});

test("family ability keybind follows any placed rank", () => {
  const fury = warrior.variants.find((v) => v.name === "Fury");
  const layout = mergeClassLayout(base, warrior, fury);
  const actions = {
    ...furyKeybindDeck,
    80: { id: "spell:78", name: "Heroic Strike", kind: "spell" as const, spellId: 78 },
  };
  const keybinds = classKeys(warrior, "Fury");
  const binds = bindsForActions(layout, actions, keybinds, ["spell:78", "spell:284", "spell:1608"]);
  assert.equal(assignedKeyLabel(binds, ""), "V");
});

test("inspector keybind writes the Action Bar slot", () => {
  const fury = warrior.variants.find((v) => v.name === "Fury");
  const layout = mergeClassLayout(base, warrior, fury);
  const actions = furyKeybindDeck;
  const shipped = classKeys(warrior, "Fury");
  const overlay = applyActionKey({}, shipped, layout, actions, ["w-charge"], "F");
  assert.equal(overlay["CLICK ShadowUIActionButton2:Keybind"], "F");
  const merged = mergeBindingTables(shipped, overlay);
  assert.equal(assignedKeyLabel(bindsForMacro(layout, actions, merged, "w-charge"), ""), "F");
});

test("assigned keybind follows stance pages", () => {
  const fury = warrior.variants.find((v) => v.name === "Fury");
  const layout = mergeClassLayout(base, warrior, fury);
  const actions = furyKeybindDeck;
  const keybinds = classKeys(warrior, "Fury");
  assert.equal(firstActionSlot("bar1", layout.bar1), 73);
  const charge = bindsForMacro(layout, actions, keybinds, "w-charge");
  assert.equal(assignedKeyLabel(charge, ""), "2");
  const bt = bindsForMacro(layout, actions, keybinds, "w-bt");
  assert.equal(assignedKeyLabel(bt, ""), "Q");
  assert.equal(bt.length, 3);
  const buttons = hudButtons(layout, actions, keybinds, 0);
  const main = buttons.find((b) => b.barId === "bar1" && b.index === 0);
  assert.equal(main?.action?.id, "w-bt");
  assert.equal(main?.key, "Q");
  const def = hudButtons(layout, actions, keybinds, 1);
  const defMain = def.find((b) => b.barId === "bar1" && b.index === 0);
  assert.equal(defMain?.action?.id, "w-bt");
  assert.equal(defMain?.bindSlot, 73);
  assert.equal(defMain?.actionSlot, 85);
});

test("Warrior Class Keybinds do not collide across stance pages", () => {
  const fury = warrior.variants.find((v) => v.name === "Fury");
  const layout = mergeClassLayout(base, warrior, fury);
  const actions = mergeActions(warrior, fury);
  const keybinds = classKeys(warrior, "Fury");
  const collisions = classKeyCollisions(hudButtons(layout, actions, keybinds, 0));
  assert.deepEqual(collisions, []);
});

test("duplicate visible keys are a Class Keybind collision", () => {
  const collisions = classKeyCollisions([
    { barId: "bar1", index: 0, bindSlot: 73, actionSlot: 73, key: "Q", action: { id: "a", name: "a" } },
    { barId: "bar2", index: 0, bindSlot: 1, actionSlot: 1, key: "Q", action: { id: "b", name: "b" } },
  ]);
  assert.equal(collisions.length, 1);
  assert.equal(collisions[0]?.key, "Q");
  assert.equal(collisions[0]?.buttons.length, 2);
});

test("comment key rewrites the label in real time", () => {
  const body = "#showtooltip Charge\n# class-specific WARRIOR all | key (T)\n/cast Charge";
  assert.equal(commentKey(body), "T");
  const next = setCommentKey(body, "E");
  assert.match(next, /\| key \(E\)/);
  assert.equal(commentKey(next), "E");
  assert.equal(canonicalKey("shift-c"), "SHIFT-C");
  assert.equal(canonicalKey("ctrl g"), "CTRL-G");
  assert.equal(canonicalKey("ctrl-g"), "CTRL-G");
  assert.equal(canonicalKey("mouse button 3"), "BUTTON3");
});

test("overlay bind moves a Class Keybind and tombstones the old slot", () => {
  const shipped = classKeys(warrior);
  const overlay = applySlotBind({}, shipped, 80, "E");
  assert.equal(overlay["CLICK ShadowUIActionButton80:Keybind"], "E");
  assert.equal(overlay["CLICK ShadowUIActionButton74:Keybind"], false);
  const merged = mergeBindingTables(shipped, overlay);
  assert.equal(merged["CLICK ShadowUIActionButton80:Keybind"], "E");
  assert.equal(merged["CLICK ShadowUIActionButton74:Keybind"], undefined);
  const cleared = applySlotBind(overlay, shipped, 80, false);
  assert.equal(cleared["CLICK ShadowUIActionButton80:Keybind"], false);
});

test("keyboard events map to WoW binding names", () => {
  const q = wowKeyFromKeyboardEvent({
    key: "q",
    code: "KeyQ",
    shiftKey: false,
    ctrlKey: false,
    altKey: false,
    metaKey: false,
  } as KeyboardEvent);
  assert.equal(q, "Q");
  const shifted = wowKeyFromKeyboardEvent({
    key: "!",
    code: "Digit1",
    shiftKey: true,
    ctrlKey: false,
    altKey: false,
    metaKey: false,
  } as KeyboardEvent);
  assert.equal(shifted, "SHIFT-1");
  const chord = wowKeyFromKeyboardEvent({
    key: "e",
    code: "KeyE",
    shiftKey: true,
    ctrlKey: true,
    altKey: false,
    metaKey: false,
  } as KeyboardEvent);
  assert.equal(chord, "CTRL-SHIFT-E");
  const altE = wowKeyFromKeyboardEvent({
    key: "e",
    code: "KeyE",
    shiftKey: false,
    ctrlKey: false,
    altKey: true,
    metaKey: false,
  } as KeyboardEvent);
  assert.equal(altE, "ALT-E");
  const altEDead = wowKeyFromKeyboardEvent({
    key: "Dead",
    code: "KeyE",
    shiftKey: false,
    ctrlKey: false,
    altKey: true,
    metaKey: false,
  } as KeyboardEvent);
  assert.equal(altEDead, "ALT-E");
  const esc = wowKeyFromKeyboardEvent({
    key: "Escape",
    code: "Escape",
    shiftKey: false,
    ctrlKey: false,
    altKey: false,
    metaKey: false,
  } as KeyboardEvent);
  assert.equal(esc, "ESCAPE");
  const bareClick = wowKeyFromMouseEvent({
    button: 0,
    shiftKey: false,
    ctrlKey: false,
    altKey: false,
    metaKey: false,
  } as MouseEvent);
  assert.equal(bareClick, null);
  const mid = wowKeyFromMouseEvent({
    button: 1,
    shiftKey: false,
    ctrlKey: false,
    altKey: false,
    metaKey: false,
  } as MouseEvent);
  assert.equal(mid, "BUTTON3");
});

test("bind mode blocks browser chords and still maps them", () => {
  const ctrlR = {
    key: "r",
    code: "KeyR",
    shiftKey: false,
    ctrlKey: true,
    altKey: false,
    metaKey: false,
  } as KeyboardEvent;
  const hovered = bindKeydownAction(ctrlR, true, 38);
  assert.equal(hovered.preventDefault, true);
  assert.equal(hovered.key, "CTRL-R");
  const ctrlF = bindKeydownAction(
    {
      key: "f",
      code: "KeyF",
      shiftKey: false,
      ctrlKey: true,
      altKey: false,
      metaKey: false,
    } as KeyboardEvent,
    true,
    38,
  );
  assert.equal(ctrlF.preventDefault, true);
  assert.equal(ctrlF.key, "CTRL-F");
  const noHover = bindKeydownAction(ctrlR, true, null);
  assert.equal(noHover.preventDefault, true);
  assert.equal(noHover.key, null);
});

test("a Variant Action Deck false entry clears the Class slot", () => {
  const fury = warrior.variants.find((v) => v.name === "Fury");
  assert.ok(fury);
  const seventyThree = fury.actions[73];
  assert.ok(seventyThree && seventyThree !== false);
  const merged = mergeActions(warrior, {
    ...fury,
    actions: { ...fury.actions, 1: false },
  });
  assert.equal(merged[1], undefined);
  assert.equal(merged[73]?.id, seventyThree.id);
});

test("applyLoadoutToClassLua bakes a Fury sidecar overlay onto slot 1", () => {
  const overlay = {
    1: { kind: "macro" as const, id: "w-h", name: "h", icon: "" },
  };
  const baked = applyLoadoutToClassLua(
    read("defaults/classes/WARRIOR.lua"),
    "WARRIOR",
    "Fury",
    overlay,
    { "w-h": "Heroic Strike" },
  );
  assert.ok(baked);
  const spec = parseClassDefaults("WARRIOR", baked.src);
  const fury = spec.variants.find((v) => v.name === "Fury");
  assert.equal(fury?.actions[1] !== false && fury?.actions[1]?.id, "w-h");
  const merged = mergeActions(spec, fury);
  assert.equal(merged[1]?.id, "w-h");
});

test("applyLoadoutToClassLua bakes a managed loadout into the Variant Action Deck", () => {
  const src = `Addon.Defaults.classes.WARRIOR = {
  deckSlots = {
    { 1, 12 },
    { 73, 111 },
  },
  actions = {
    [1] = act("w-hm", "hm", { match = HAMSTRING_MATCH, createName = "suiHamstring" }),
    [2] = act("w-charge", "charge", { match = CHARGE_MATCH }),
  },
  variants = {
    Fury = {
      talentTree = 2,
      actions = {
        [8] = act("w-deathwish", "dwish", { match = "Death Wish" }),
        [73] = act("w-bt", "bt", { match = "Bloodthirst" }),
      },
    },
  },
}
`;
  const baked = applyLoadoutToClassLua(src, "WARRIOR", "Fury", {
    1: false,
    5: { kind: "macro", id: "w-hm", name: "hm", icon: "" },
    13: { kind: "macro", id: "w-disarm", name: "disarm", icon: "" },
  });
  assert.ok(baked);
  const spec = parseClassDefaults("WARRIOR", baked.src);
  const fury = spec.variants.find((v) => v.name === "Fury");
  assert.equal(fury?.actions[1], false);
  assert.equal(fury?.actions[5] !== false && fury?.actions[5]?.id, "w-hm");
  assert.equal(fury?.actions[5] !== false && fury?.actions[5]?.match, "HAMSTRING_MATCH");
  assert.equal(fury?.actions[73] !== false && fury?.actions[73]?.id, "w-bt");
  assert.equal(spec.actions[1]?.id, "w-hm");
  assert.equal(baked.remainingOverlay[13]?.id, "w-disarm");
  const merged = mergeActions(spec, fury);
  assert.equal(merged[1], undefined);
  assert.equal(merged[5]?.id, "w-hm");
});
