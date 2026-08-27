import assert from "node:assert/strict";
import test from "node:test";
import {
  cacheLooksCorrupt,
  normalizeBody,
  parseCache,
  serializeCache,
} from "../src/cache.ts";
import {
  catalogNamesUnique,
  describeOwner,
  dropMacro,
  findNameOwner,
  loadGroupIds,
  mergePruned,
  renameMacro,
  setMacroBody,
} from "../src/catalog.ts";
import catalogJson from "../../docs/macros/catalog.json" with { type: "json" };
import { mergeLive, type SyncResponse } from "../src/merge.ts";
import type { Catalog, Macro } from "../src/types.ts";

const sample = `VER 3 0100000000000001 "Charge" "ABILITY_WARRIOR_CHARGE"
#showtooltip
# class-specific WARRIOR all
/cast Charge
/cast Intercept
END
VER 3 0100000000000002 "Homebrew" "INV_MISC_QUESTIONMARK"
/say hi
END
`;

function macro(partial: Partial<Macro> & Pick<Macro, "id" | "name" | "tab" | "body">): Macro {
  return {
    scope: "class",
    class: "WARRIOR",
    spec: "all",
    icon: "ability_warrior_charge",
    group: "warrior-core",
    source: "existing",
    chars: partial.body.length,
    ...partial,
  };
}

function catalog(): Catalog {
  const charge = macro({
    id: "w-charge",
    name: "Charge",
    tab: "character",
    body: "#showtooltip\n# class-specific WARRIOR all\n/cast Charge\n/cast Intercept",
  });
  return {
    version: 1,
    limits: { account: 120, character: 18, bodyChars: 255, nameChars: 16 },
    iconCdn: "",
    iconNote: "",
    groups: [
      {
        id: "warrior-core",
        title: "Core",
        class: "WARRIOR",
        spec: "all",
        tab: "character",
        scope: "class",
        description: "test",
        macroIds: [charge.id],
        count: 1,
      },
    ],
    macros: [charge],
  };
}

test("parseCache reads VER 3 blocks", () => {
  const macros = parseCache(sample);
  assert.equal(macros.length, 2);
  assert.equal(macros[0].name, "Charge");
  assert.match(macros[0].body, /\/cast Charge/);
  assert.equal(macros[1].name, "Homebrew");
});

test("serializeCache round-trips", () => {
  const macros = parseCache(sample);
  const again = parseCache(serializeCache(macros, true));
  assert.deepEqual(again.map((m) => m.name), ["Charge", "Homebrew"]);
});

test("normalizeBody drops scope labels", () => {
  const live = "/cast Charge\n/cast Intercept";
  const labeled = "# class-specific WARRIOR all\n/cast Charge\n/cast Intercept";
  assert.equal(normalizeBody(live), normalizeBody(labeled));
});

test("cacheLooksCorrupt flags junk without END", () => {
  assert.equal(cacheLooksCorrupt("", 0), false);
  assert.equal(cacheLooksCorrupt(sample, 2), false);
  assert.equal(cacheLooksCorrupt("this is not a macro cache file!!", 0), true);
});

test("mergeLive keeps in-game extras and in-game bodies", () => {
  const live: SyncResponse = {
    wowPath: "/tmp",
    wowRunning: false,
    wrote: false,
    accounts: [{ account: "WARKEYS", path: "", macros: [] }],
    characters: [
      {
        account: "WARKEYS",
        realm: "Nightslayer",
        name: "Tazzy",
        class: "WARRIOR",
        path: "",
        macros: parseCache(`VER 3 0100000000000001 "Charge" "ABILITY_WARRIOR_CHARGE"
/cast Charge
END
VER 3 0100000000000002 "Homebrew" "INV_MISC_QUESTIONMARK"
/say hi
END
`),
      },
    ],
    notes: [],
  };
  const next = mergeLive(catalog(), live, "WARKEYS", live.characters[0]);
  assert.equal(next.characterIds.length, 2);
  const charge = next.catalog.macros.find((m) => m.id === "w-charge");
  assert.equal(charge?.body, "/cast Charge");
  assert.equal(charge?.source, "ingame");
  const homebrew = next.catalog.macros.find((m) => m.name === "Homebrew");
  assert.ok(homebrew);
  assert.equal(homebrew.source, "ingame");
  assert.ok(next.catalog.groups.some((g) => g.id === "ingame-Tazzy"));
  assert.ok(next.notes.some((n) => n.includes("Imported 1")));
  assert.ok(next.notes.some((n) => n.includes("Kept 1")));
});

test("dropMacro removes a record and empty groups", () => {
  const start = catalog();
  const extra = macro({
    id: "w-extra",
    name: "Extra",
    tab: "character",
    group: "warrior-extra",
    body: "/cast Extra",
  });
  start.macros.push(extra);
  start.groups.push({
    id: "warrior-extra",
    title: "Extra",
    class: "WARRIOR",
    spec: "all",
    tab: "character",
    scope: "class",
    description: "test",
    macroIds: ["w-extra"],
    count: 1,
  });
  const next = dropMacro(start, "w-extra");
  assert.equal(next.macros.some((m) => m.id === "w-extra"), false);
  assert.equal(next.macros.some((m) => m.id === "w-charge"), true);
  assert.equal(next.groups.some((g) => g.id === "warrior-extra"), false);
  assert.deepEqual(mergePruned(["b"], "a"), ["a", "b"]);
});

test("loadGroupIds adds a second group without wiping the first", () => {
  const start = catalog();
  const extra = macro({
    id: "shared-assist",
    name: "assist",
    tab: "account",
    group: "shared-core",
    class: "ALL",
    scope: "global",
    body: "/assist",
  });
  start.macros.push(extra);
  start.groups.push({
    id: "shared-core",
    title: "Shared core",
    class: "ALL",
    spec: "all",
    tab: "account",
    scope: "global",
    description: "test",
    macroIds: ["shared-assist"],
    count: 1,
  });
  const first = loadGroupIds([], ["w-charge"], start, 18, false);
  const second = loadGroupIds(first.ids, ["shared-assist"], start, 18, false);
  assert.deepEqual(second.ids, ["w-charge", "shared-assist"]);
  const replaced = loadGroupIds(second.ids, ["shared-assist"], start, 18, true);
  assert.deepEqual(replaced.ids, ["shared-assist"]);
});

test("loadGroupIds skips duplicate ids and names and respects the cap", () => {
  const start = catalog();
  const twin = macro({
    id: "w-charge-copy",
    name: "Charge",
    tab: "character",
    group: "other",
    body: "/cast Charge",
  });
  start.macros.push(twin);
  const added = loadGroupIds(["w-charge"], ["w-charge", "w-charge-copy"], start, 18, false);
  assert.deepEqual(added.ids, ["w-charge"]);
  const over = loadGroupIds([], ["w-charge"], start, 0, false);
  assert.match(over.error ?? "", /Cap is 0/);
  assert.deepEqual(over.ids, []);
});

test("renameMacro blocks a name that another macro already uses", () => {
  const start = catalog();
  const extra = macro({
    id: "w-extra",
    name: "Extra",
    tab: "character",
    group: "warrior-extra",
    body: "/cast Extra",
  });
  start.macros.push(extra);
  const hit = findNameOwner(start, "Charge", "w-extra");
  assert.equal(hit?.id, "w-charge");
  assert.match(describeOwner(hit!), /w-charge \(warrior-core, WARRIOR, class\)/);
  const next = renameMacro(start, "w-extra", "Cleave");
  assert.equal(next.macros.find((m) => m.id === "w-extra")?.name, "Cleave");
  assert.equal(start.macros.find((m) => m.id === "w-extra")?.name, "Extra");
});

test("setMacroBody replaces the body and character count", () => {
  const start = catalog();
  const next = setMacroBody(start, "w-charge", "/cast Charge");
  const rec = next.macros.find((m) => m.id === "w-charge");
  assert.equal(rec?.body, "/cast Charge");
  assert.equal(rec?.chars, "/cast Charge".length);
  assert.match(start.macros.find((m) => m.id === "w-charge")?.body ?? "", /#showtooltip/);
});

test("shipped catalog names are unique", () => {
  assert.equal(catalogNamesUnique(catalogJson as Catalog), true);
});

test("warrior catalog uses core plus talent-only groups", () => {
  const shipped = catalogJson as Catalog;
  const groups = new Map(shipped.groups.map((g) => [g.id, g]));
  const macros = new Map(shipped.macros.map((m) => [m.id, m]));

  assert.equal(groups.has("warrior-account"), false);
  const core = groups.get("warrior-core");
  assert.ok(core);
  assert.equal(core.tab, "account");
  assert.ok(core.macroIds.every((id) => {
    const m = macros.get(id);
    return m?.group === "warrior-core" && m.spec === "all" && m.tab === "account";
  }));

  const talentGroups: Record<string, { spec: string; ids: string[] }> = {
    "warrior-arms": { spec: "arms", ids: ["w-sweep", "w-ms"] },
    "warrior-fury": { spec: "fury", ids: ["w-deathwish", "w-bt"] },
    "warrior-prot": { spec: "protection", ids: ["w-ls", "w-concussion", "w-sslam"] },
  };
  for (const [groupId, expected] of Object.entries(talentGroups)) {
    const group = groups.get(groupId);
    assert.ok(group);
    assert.deepEqual(group.macroIds, expected.ids);
    assert.ok(group.macroIds.every((id) => {
      const m = macros.get(id);
      return m?.group === groupId && m.spec === expected.spec && m.tab === "character";
    }));
  }

  const removedDuplicates = [
    "w-a", "w-hs-r3", "w-hs-cancel", "w-piercing", "w-pum",
    "w-sb", "w-bt-acc", "w-ex-acc", "w-pum-acc", "w-sunder5", "w-ada",
  ];
  assert.ok(removedDuplicates.every((id) => !macros.has(id)));

  const heroic = macros.get("w-h");
  assert.ok(heroic);
  assert.equal(heroic.name, "h");
  assert.match(heroic.body, /\/cast Heroic Strike/);
  assert.doesNotMatch(heroic.body, /Rank 3|mod:shift|\/cqs/);

  assert.equal(macros.get("w-shh")?.spec, "all");
  assert.equal(macros.get("w-sd-item")?.spec, "all");
  assert.doesNotMatch(macros.get("w-dfdw")?.body ?? "", /\/cqs/);
  assert.ok(["w-dual", "w-sh-qs", "w-shh", "w-sd-item"].every(
    (id) => macros.get(id)?.body.includes("/stopcasting"),
  ));
  assert.match(
    macros.get("w-sh-qs")?.body ?? "",
    /\/equipslot 16 Quel'Serrar\n\/equipslot 17 Buru's Skull Fragment/,
  );
  assert.match(macros.get("w-hm")?.body ?? "", /\| key \(/);
  assert.match(macros.get("w-bt")?.body ?? "", /\| key \(/);
  assert.match(macros.get("w-dual")?.body ?? "", /\| key \(unbound\)/);
  assert.ok(
    shipped.macros
      .filter((m) => m.class === "WARRIOR")
      .every((m) => m.body.includes("| key (")),
  );

  const bodyOwners = new Map<string, string>();
  for (const macro of shipped.macros.filter((m) => m.class === "WARRIOR")) {
    const body = normalizeBody(macro.body);
    assert.equal(bodyOwners.get(body), undefined, `${macro.id} duplicates ${bodyOwners.get(body)}`);
    bodyOwners.set(body, macro.id);
  }

  const plainCastOnly = shipped.macros
    .filter((m) => m.class === "WARRIOR")
    .filter((m) => {
      const commands = m.body.split("\n").filter((line) => line.startsWith("/"));
      return commands.length === 1
        && commands[0].startsWith("/cast ")
        && !/[\[;]/.test(commands[0]);
    })
    .map((m) => m.id);
  assert.deepEqual(plainCastOnly, []);
});
