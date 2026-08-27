import assert from "node:assert/strict";
import test from "node:test";
import {
  attuneLookupKey,
  mergeCharMeta,
  nitLookupKey,
  parseAttuneToons,
  parseNitMyChars,
  sortRoster,
  type RosterCharacter,
} from "../src/roster.ts";

const nit = `
NITdatabase = {
["global"] = {
["Nightslayer"] = {
["myChars"] = {
["Odrade"] = {
["realm"] = "Nightslayer",
["playerName"] = "Odrade",
["classEnglish"] = "PRIEST",
["level"] = 1,
["levelLog"] = {
{
["level"] = 1,
},
},
},
["Tazzy"] = {
["realm"] = "Nightslayer",
["playerName"] = "Tazzy",
["classEnglish"] = "WARRIOR",
["level"] = 60,
},
},
},
},
}
`;

const attune = `
Attune_DB = {
["toons"] = {
["Lipe-Nightslayer"] = {
["class"] = "WARLOCK",
["level"] = "7",
},
["Currentz-Nightslayer"] = {
["class"] = "MAGE",
["level"] = "58",
["name"] = "Currentz",
},
["Broken-Nightslayer"] = {
["class"] = "UNKNOWN",
},
},
}
`;

test("parseNitMyChars reads class and level from myChars", () => {
  const map = parseNitMyChars(nit);
  assert.deepEqual(map.get(nitLookupKey("Nightslayer", "Tazzy")), {
    class: "WARRIOR",
    level: 60,
  });
  assert.deepEqual(map.get(nitLookupKey("Nightslayer", "Odrade")), {
    class: "PRIEST",
    level: 1,
  });
});

test("parseAttuneToons skips UNKNOWN class", () => {
  const map = parseAttuneToons(attune);
  assert.equal(map.has(attuneLookupKey("Nightslayer", "Broken")), false);
  assert.deepEqual(map.get(attuneLookupKey("Nightslayer", "Currentz")), {
    class: "MAGE",
    level: 58,
  });
});

test("mergeCharMeta prefers Nova Instance Tracker", () => {
  assert.deepEqual(
    mergeCharMeta({ class: "WARRIOR", level: 60 }, { class: "MAGE", level: 1 }),
    { class: "WARRIOR", level: 60 },
  );
  assert.deepEqual(
    mergeCharMeta({ class: null, level: null }, { class: "MAGE", level: 58 }),
    { class: "MAGE", level: 58 },
  );
});

test("sortRoster orders by class then level", () => {
  const rows: RosterCharacter[] = [
    { account: "A", realm: "R", name: "Low", class: "WARRIOR", level: 10 },
    { account: "A", realm: "R", name: "Currentz", class: "MAGE", level: 58 },
    { account: "A", realm: "R", name: "Tazzy", class: "WARRIOR", level: 60 },
    { account: "A", realm: "R", name: "Mystery", class: null, level: null },
  ];
  assert.deepEqual(
    sortRoster(rows).map((row) => row.name),
    ["Tazzy", "Low", "Currentz", "Mystery"],
  );
});
