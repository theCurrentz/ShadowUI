import type { MountOpts } from "../src/app";
import type { Catalog, Macro } from "../src/types";

const charge: Macro = {
  id: "warrior-charge",
  name: "Charge",
  scope: "class",
  class: "WARRIOR",
  spec: "all",
  tab: "character",
  icon: "ability_warrior_charge",
  group: "warrior-core",
  source: "plan",
  body: "#showtooltip\n/cast Charge",
  chars: 25,
  notes: "Charge into combat.",
};

const execute: Macro = {
  id: "warrior-execute",
  name: "Execute",
  scope: "class",
  class: "WARRIOR",
  spec: "all",
  tab: "character",
  icon: "inv_sword_48",
  group: "warrior-core",
  source: "plan",
  body: "#showtooltip\n/cast Execute",
  chars: 26,
};

export function fixtureCatalog(macros: Macro[] = [charge, execute]): Catalog {
  return {
    version: 1,
    limits: { account: 120, character: 18, bodyChars: 255, nameChars: 16 },
    iconCdn: "",
    iconNote: "",
    groups: [
      {
        id: "warrior-core",
        title: "Warrior Core",
        class: "WARRIOR",
        spec: "all",
        tab: "character",
        scope: "class",
        description: "Core Warrior combat macros.",
        macroIds: macros.map((macro) => macro.id),
        count: macros.length,
      },
    ],
    macros,
  };
}

export function fixtureMountOpts(): MountOpts {
  const catalog = fixtureCatalog();
  return {
    base: catalog,
    catalog,
    live: null,
    accountName: "",
    toon: undefined,
    accountIds: [],
    characterIds: [],
    notes: [],
    baseLayout: {
      bar1: {
        point: "BOTTOM",
        x: 0,
        y: 0,
        buttons: 3,
        columns: 3,
        scale: 1,
        enabled: true,
        buttonSize: 36,
        firstSlot: 1,
        stancePages: [1, 13],
      },
    },
    baseKeybinds: {
      "CLICK ShadowUIActionButton1:Keybind": "1",
      "CLICK ShadowUIActionButton2:Keybind": "2",
      "CLICK ShadowUIActionButton3:Keybind": "3",
    },
    classSpecs: {
      WARRIOR: {
        classId: "WARRIOR",
        layout: {},
        keybinds: {},
        actions: {
          1: { id: charge.id, name: charge.name, icon: charge.icon },
        },
        deckSlots: [1, 2, 3],
        variants: [
          { name: "Arms", layout: {}, keybinds: {}, actions: {} },
          { name: "Fury", layout: {}, keybinds: {}, actions: {} },
        ],
      },
    },
    spellbook: {
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
                maxSpellId: 100,
                description: "Charge an enemy, generate 15 rage, and stun it for 1 sec.",
                ranks: [
                  {
                    spellId: 100,
                    name: "Charge",
                    rank: "Rank 3",
                    level: 20,
                    icon: "ability_warrior_charge",
                  },
                ],
              },
            ],
          },
        ],
      },
      shared: [
        {
          skillId: -4,
          title: "Racial",
          families: [
            {
              name: "Stoneform",
              icon: "spell_shadow_unholystrength",
              maxSpellId: 20594,
              ranks: [
                {
                  spellId: 20594,
                  name: "Stoneform",
                  rank: "Racial",
                  level: 1,
                  icon: "spell_shadow_unholystrength",
                },
              ],
            },
          ],
        },
        {
          skillId: 182,
          title: "Herbalism",
          families: [
            {
              name: "Find Herbs",
              icon: "inv_misc_flower_02",
              maxSpellId: 2383,
              ranks: [
                {
                  spellId: 2383,
                  name: "Find Herbs",
                  rank: "",
                  level: 1,
                  icon: "inv_misc_flower_02",
                },
              ],
            },
          ],
        },
      ],
    },
    bindStore: { base: {}, classes: {} },
    actionStore: { classes: {} },
    roster: [
      {
        account: "WARKEYS",
        realm: "Nightslayer",
        name: "Tazzy",
        class: "WARRIOR",
        level: 60,
      },
      {
        account: "WARKEYS",
        realm: "Nightslayer",
        name: "Currentz",
        class: "MAGE",
        level: 58,
      },
    ],
  };
}

export function withMacro(
  catalog: Catalog,
  id: string,
  patch: Partial<Macro>,
): Catalog {
  return {
    ...catalog,
    macros: catalog.macros.map((macro) => (macro.id === id ? { ...macro, ...patch } : macro)),
  };
}
