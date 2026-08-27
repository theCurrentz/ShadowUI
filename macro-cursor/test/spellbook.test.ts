import assert from "node:assert/strict";
import test from "node:test";
import {
  bakeLoadoutToDeck,
  copyBarPages,
  copyVariantActions,
  dropOffBar,
  dropOnSlot,
  mergeActionTables,
} from "../src/deck-edit.ts";
import {
  abilitiesFromBody,
  abilityRefIndex,
  familyIndex,
  familyPlaced,
  familyReferenced,
  isEraSpell,
  linesForClass,
  nestFamilies,
  parsePickup,
  pickupFromDataTransfer,
  pickupFromFamily,
  rankNumber,
  slotTip,
  spellActionId,
  spellNamesFromBody,
} from "../src/spellbook.ts";

test("class spellbook appends shared racial and profession tabs", () => {
  const lines = linesForClass(
    {
      version: 1,
      classes: {
        WARRIOR: [{ skillId: 26, title: "Arms", families: [] }],
      },
      shared: [
        { skillId: -4, title: "Racial", families: [] },
        { skillId: 171, title: "Alchemy", families: [] },
      ],
    },
    "WARRIOR",
  );
  assert.deepEqual(
    lines.map((line) => line.title),
    ["Arms", "Racial", "Alchemy"],
  );
});

test("era filter drops Season of Discovery rows", () => {
  assert.equal(isEraSpell({ id: 78, name: "Heroic Strike" }), true);
  assert.equal(isEraSpell({ id: 459313, name: "Engrave Ring - Defense Specialization" }), false);
  assert.equal(isEraSpell({ id: 100, name: "Charge", seasonId: 2 }), false);
});

test("nest families groups ranks under one ability", () => {
  const families = nestFamilies([
    { id: 78, name: "Heroic Strike", rank: "Rank 1", level: 1 },
    { id: 284, name: "Heroic Strike", rank: "Rank 2", level: 8 },
    { id: 1608, name: "Heroic Strike", rank: "Rank 10", level: 60 },
    { id: 100, name: "Charge", rank: "Rank 1", level: 4 },
  ]);
  assert.equal(families.length, 2);
  const hs = families.find((f) => f.name === "Heroic Strike");
  assert.equal(hs?.ranks.length, 3);
  assert.equal(hs?.maxSpellId, 1608);
  assert.equal(rankNumber("Rank 10"), 10);
  const pickup = pickupFromFamily(hs!);
  assert.equal(pickup.kind, "spell");
  assert.equal(pickup.id, spellActionId(1608));
});

test("spell names come from cast, use, sequence, and tooltip lines", () => {
  assert.deepEqual(spellNamesFromBody("#showtooltip\n/cast Charge"), ["Charge"]);
  assert.deepEqual(spellNamesFromBody("#showtooltip Heroic Strike\n/startattack\n/cast Heroic Strike"), [
    "Heroic Strike",
  ]);
  assert.deepEqual(
    spellNamesFromBody("/cast [mod:shift] Moonfire(Rank 1); Moonfire").sort(),
    ["Moonfire"],
  );
  assert.deepEqual(
    spellNamesFromBody("/cast [form:1/3] Faerie Fire (Feral); Faerie Fire").sort(),
    ["Faerie Fire", "Faerie Fire (Feral)"],
  );
  assert.deepEqual(
    spellNamesFromBody("/castsequence reset=target/combat/5 Sunder Armor, Shield Slam").sort(),
    ["Shield Slam", "Sunder Armor"],
  );
  assert.deepEqual(
    spellNamesFromBody("#showtooltip [combat] Intercept; Charge\n/cast [nocombat] Charge; Intercept").sort(),
    ["Charge", "Intercept"],
  );
  assert.deepEqual(
    spellNamesFromBody(
      "/cast [nocombat,nostance:1] Battle Stance; [combat,nostance:3] Berserker Stance",
    ).sort(),
    ["Battle Stance", "Berserker Stance"],
  );
  assert.deepEqual(spellNamesFromBody("# class-specific WARRIOR all\n/assist"), []);
});

test("slot tooltip lists the keybind, macro, and nested ability descriptions", () => {
  const book = {
    version: 1,
    classes: {
      WARRIOR: [
        {
          skillId: 26,
          title: "Arms",
          families: [
            {
              name: "Charge",
              icon: "ability_warrior_charge",
              maxSpellId: 11578,
              description: "Charge an enemy, generate 15 rage, and stun it for 1 sec.",
              ranks: [{ spellId: 11578, name: "Charge", rank: "Rank 3", level: 46, icon: "" }],
            },
            {
              name: "Intercept",
              icon: "ability_rogue_sprint",
              maxSpellId: 20617,
              description: "Charge an enemy in combat, generating 10 rage.",
              ranks: [{ spellId: 20617, name: "Intercept", rank: "Rank 3", level: 52, icon: "" }],
            },
          ],
        },
      ],
    },
  } as const;
  const families = familyIndex(book, "WARRIOR");
  assert.equal(families.get("charge")?.description?.includes("15 rage"), true);
  assert.deepEqual(abilitiesFromBody("/cast [nocombat] Charge; Intercept", families), [
    {
      name: "Charge",
      description: "Charge an enemy, generate 15 rage, and stun it for 1 sec.",
    },
    {
      name: "Intercept",
      description: "Charge an enemy in combat, generating 10 rage.",
    },
  ]);
  const macroTip = slotTip({
    key: "E",
    action: { id: "warrior-charge", name: "charge" },
    macro: {
      name: "charge",
      body: "#showtooltip [combat] Intercept; Charge\n/cast [nocombat] Charge; Intercept",
      notes: "Enters Battle for Charge or Berserker for Intercept.",
    },
    families,
  });
  assert.equal(macroTip.kind, "macro");
  assert.equal(macroTip.keybind, "E");
  assert.equal(macroTip.name, "charge");
  assert.equal(macroTip.notes, "Enters Battle for Charge or Berserker for Intercept.");
  assert.match(macroTip.body ?? "", /\/cast \[nocombat\] Charge; Intercept/);
  assert.equal(macroTip.abilities.length, 2);
  const spellTip = slotTip({
    key: "1",
    action: { id: "spell:11578", name: "Charge", rank: "Rank 3" },
    families,
  });
  assert.equal(spellTip.kind, "spell");
  assert.equal(spellTip.abilities[0]?.description.includes("15 rage"), true);
  const emptyTip = slotTip({ key: "2", families });
  assert.equal(emptyTip.kind, "empty");
  assert.equal(emptyTip.keybind, "2");
});

test("ability is referenced when a macro body casts that family name", () => {
  const families = nestFamilies([
    { id: 100, name: "Charge", rank: "Rank 3", level: 20 },
    { id: 1680, name: "Whirlwind", rank: "", level: 36 },
    { id: 16827, name: "Feral Charge", rank: "Rank 1", level: 20 },
  ]);
  const index = abilityRefIndex([
    { id: "warrior-charge", body: "#showtooltip\n/cast Charge" },
    { id: "druid-fc", body: "/cast Feral Charge" },
  ]);
  assert.equal(familyReferenced(families.find((f) => f.name === "Charge")!, index), true);
  assert.equal(familyReferenced(families.find((f) => f.name === "Feral Charge")!, index), true);
  assert.equal(familyReferenced(families.find((f) => f.name === "Whirlwind")!, index), false);
  assert.deepEqual(index.get("charge"), ["warrior-charge"]);
});

test("family is placed when any rank is on an Action Bar", () => {
  const families = nestFamilies([
    { id: 78, name: "Heroic Strike", rank: "Rank 1", level: 1 },
    { id: 1608, name: "Heroic Strike", rank: "Rank 10", level: 60 },
    { id: 100, name: "Charge", rank: "Rank 1", level: 4 },
  ]);
  const hs = families.find((f) => f.name === "Heroic Strike")!;
  const placed = new Set(["spell:78"]);
  assert.equal(familyPlaced(hs, placed), true);
  assert.equal(familyPlaced(families.find((f) => f.name === "Charge")!, placed), false);
  assert.equal(placed.has(spellActionId(1608)), false);
});

test("drop onto an occupied slot holds the previous action", () => {
  const shipped = { 73: { id: "w-bt", name: "bt" }, 74: { id: "w-charge", name: "Charge" } };
  const incoming = {
    kind: "spell" as const,
    id: "spell:78",
    name: "Heroic Strike",
    icon: "ability_rogue_ambush",
    spellId: 78,
    rank: "Rank 1",
  };
  const swapped = dropOnSlot(shipped, {}, 73, incoming);
  assert.equal(swapped.overlay[73]?.id, "spell:78");
  assert.equal(swapped.held?.kind, "macro");
  assert.equal(swapped.held?.id, "w-bt");
  const empty = dropOnSlot(shipped, swapped.overlay, 80, incoming);
  assert.equal(empty.held, undefined);
  assert.equal(empty.overlay[80]?.id, "spell:78");
});

test("move from one slot onto another clears the source and holds the target", () => {
  const shipped = { 73: { id: "a", name: "A" }, 74: { id: "b", name: "B" } };
  const moved = dropOnSlot(shipped, {}, 74, {
    kind: "macro",
    id: "a",
    name: "A",
    icon: "",
    fromSlot: 73,
  });
  const merged = mergeActionTables(shipped, moved.overlay);
  assert.equal(merged[74]?.id, "a");
  assert.equal(merged[73], undefined);
  assert.equal(moved.held?.id, "b");
  const back = dropOnSlot(shipped, {}, 73, {
    kind: "macro",
    id: "a",
    name: "A",
    icon: "",
    fromSlot: 73,
  });
  assert.equal(back.held, undefined);
});

test("dropOffBar removes the Action Slot even when the deck shipped it", () => {
  const shipped = { 73: { id: "w-bt", name: "bt" } };
  const overlay = dropOffBar({}, 73);
  assert.equal(overlay[73], false);
  assert.equal(mergeActionTables(shipped, overlay)[73], undefined);
});

test("copyBarPages copies the visible stance page onto the other pages", () => {
  const shipped = {
    73: { id: "w-bt", name: "bt" },
    74: { id: "w-hs", name: "hs" },
    85: { id: "w-sslam", name: "ssl" },
  };
  const overlay = copyBarPages(shipped, {}, [73, 85, 97], 0, 2);
  const merged = mergeActionTables(shipped, overlay);
  assert.equal(merged[73]?.id, "w-bt");
  assert.equal(merged[85]?.id, "w-bt");
  assert.equal(merged[86]?.id, "w-hs");
  assert.equal(merged[97]?.id, "w-bt");
  assert.equal(merged[98]?.id, "w-hs");
  assert.equal(overlay[85]?.id, "w-bt");
  const cleared = copyBarPages(shipped, { 74: false }, [73, 85, 97], 0, 2);
  const afterClear = mergeActionTables(shipped, cleared);
  assert.equal(afterClear[74], undefined);
  assert.equal(afterClear[86], undefined);
  assert.equal(afterClear[98], undefined);
});

test("copyVariantActions copies every bar slot onto another Variant", () => {
  const source = {
    8: { kind: "macro" as const, id: "w-deathwish", name: "dwish" },
    73: { kind: "macro" as const, id: "w-bt", name: "bt" },
    79: { kind: "macro" as const, id: "w-ds", name: "ds" },
  };
  const destShipped = {
    8: { id: "w-ls", name: "ls" },
    73: { id: "w-sslam", name: "ssl" },
    79: { id: "w-concussion", name: "cb" },
    91: { id: "w-concussion", name: "cb" },
  };
  const overlay = copyVariantActions(source, destShipped);
  const merged = mergeActionTables(destShipped, overlay);
  assert.equal(merged[8]?.id, "w-deathwish");
  assert.equal(merged[73]?.id, "w-bt");
  assert.equal(merged[79]?.id, "w-ds");
  assert.equal(merged[91], undefined);
  assert.equal(overlay[91], false);
});

test("bakeLoadoutToDeck writes Variant Action Deck deltas and keeps unmanaged overlay", () => {
  const classActions = {
    1: { id: "w-hm", name: "hm", match: "HAMSTRING_MATCH", createName: "suiHamstring" },
    2: { id: "w-charge", name: "charge", match: "CHARGE_MATCH" },
  };
  const variantActions = {
    8: { id: "w-deathwish", name: "dwish", match: "Death Wish" },
    73: { id: "w-bt", name: "bt", match: "Bloodthirst" },
  };
  const overlay = {
    1: false as const,
    5: { kind: "macro" as const, id: "w-hm", name: "hm", icon: "" },
    13: { kind: "macro" as const, id: "w-disarm", name: "disarm", icon: "" },
    73: {
      kind: "spell" as const,
      id: "spell:78",
      name: "Heroic Strike",
      icon: "",
      spellId: 78,
      rank: "Rank 1",
    },
  };
  const baked = bakeLoadoutToDeck(classActions, variantActions, overlay, [
    [1, 12],
    [73, 111],
  ]);
  assert.equal(baked.variantActions[1], false);
  assert.equal(baked.variantActions[5]?.id, "w-hm");
  assert.equal(baked.variantActions[5] !== false && baked.variantActions[5]?.match, "HAMSTRING_MATCH");
  assert.equal(baked.variantActions[8]?.id, "w-deathwish");
  assert.equal(baked.variantActions[73], undefined);
  assert.equal(baked.remainingOverlay[13]?.id, "w-disarm");
  assert.equal(baked.remainingOverlay[73]?.id, "spell:78");
  assert.equal(baked.remainingOverlay[1], undefined);
  assert.equal(baked.remainingOverlay[5], undefined);
});

test("pickupFromDataTransfer reads text/plain when the custom MIME type is empty", () => {
  const pickup = {
    kind: "macro" as const,
    id: "warrior-execute",
    name: "Execute",
    icon: "inv_sword_48",
  };
  const encoded = JSON.stringify(pickup);
  assert.deepEqual(
    pickupFromDataTransfer((type) => (type === "text/plain" ? encoded : "")),
    pickup,
  );
  assert.equal(
    pickupFromDataTransfer((type) => (type === "text/plain" ? "Execute" : "")),
    undefined,
  );
});
