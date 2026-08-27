import { fireEvent, getAllByText, getByRole, getByText, queryByText } from "@testing-library/dom";
import userEvent from "@testing-library/user-event";
import { describe, expect, it } from "vitest";
import { mount } from "../src/app";
import { fixtureMountOpts, withMacro } from "./app-fixture";

describe("Macro Cursor navigation", () => {
  it("lets a user browse, load, and inspect macros and spells", async () => {
    document.body.innerHTML = '<div id="app"></div>';
    const root = document.querySelector<HTMLElement>("#app")!;
    const user = userEvent.setup();

    mount(root, fixtureMountOpts());

    expect(getByRole(root, "heading", { name: "Macro Cursor" })).toBeVisible();
    expect(getByRole(root, "heading", { name: "Warrior Core" })).toBeVisible();
    expect(getByRole(root, "textbox", { name: "Name" })).toHaveValue("Charge");

    await user.click(getByRole(root, "button", { name: "Load character" }));
    expect(getByText(root, /Loaded Warrior Core → character \(2\/18\)/)).toBeVisible();

    await user.click(getByRole(root, "button", { name: /Loaded 2/ }));
    expect(getByRole(root, "heading", { name: "Warrior Core (2)" })).toBeVisible();
    expect(getByText(root, "Execute").closest("button")).toBeVisible();

    await user.click(getByRole(root, "button", { name: "Spellbook" }));
    expect(getByRole(root, "heading", { name: "Arms" })).toBeVisible();
    expect(getByRole(root, "button", { name: /Rank 3/ })).toBeVisible();
    expect(getByRole(root, "textbox", { name: "Name" })).toHaveValue("Charge");
    expect(location.search).toContain("view=spellbook");

    await user.click(getByRole(root, "button", { name: /Racial/ }));
    expect(getByRole(root, "heading", { name: "Racial" })).toBeVisible();
    expect(getByRole(root, "button", { name: /Stoneform/ })).toBeVisible();

    await user.click(getByRole(root, "button", { name: /Herbalism/ }));
    expect(getByRole(root, "heading", { name: "Herbalism" })).toBeVisible();
    expect(getByRole(root, "button", { name: /Find Herbs/ })).toBeVisible();

    await user.click(getByRole(root, "button", { name: "Library" }));
    fireEvent.click(getByRole(root, "button", { name: "Unload" }));
    expect(getByText(root, "Unloaded Warrior Core.")).toBeVisible();

    await user.click(getByRole(root, "button", { name: /Loaded 0/ }));
    expect(queryByText(root, "Warrior Core (2)")).not.toBeInTheDocument();
    expect(getAllByText(root, /Nothing loaded/)).toHaveLength(2);
  });

  it("lists every toon with class and level", async () => {
    document.body.innerHTML = '<div id="app"></div>';
    const root = document.querySelector<HTMLElement>("#app")!;
    const user = userEvent.setup();

    mount(root, fixtureMountOpts());

    await user.click(getByRole(root, "button", { name: /Characters 2/ }));
    expect(location.search).toContain("view=characters");
    const tazzy = getByRole(root, "button", { name: /Tazzy/ });
    expect(tazzy).toHaveTextContent("Warrior");
    expect(tazzy).toHaveTextContent("Lv 60");
    const currentz = getByRole(root, "button", { name: /Currentz/ });
    expect(currentz).toHaveTextContent("Mage");
    expect(currentz).toHaveTextContent("Lv 58");
  });

  it("links a Spellbook ability to catalog macros that cast it", async () => {
    document.body.innerHTML = '<div id="app"></div>';
    const root = document.querySelector<HTMLElement>("#app")!;
    const user = userEvent.setup();
    const opts = fixtureMountOpts();
    opts.spellbook.classes.WARRIOR![0]!.families.push({
      name: "Heroic Strike",
      icon: "ability_rogue_ambush",
      maxSpellId: 78,
      ranks: [
        {
          spellId: 78,
          name: "Heroic Strike",
          rank: "Rank 1",
          level: 1,
          icon: "ability_rogue_ambush",
        },
      ],
    });

    mount(root, opts);

    await user.click(getByRole(root, "button", { name: "Spellbook" }));
    expect(root.querySelector('[data-spell="100"]')).toHaveTextContent("Macro");
    expect(root.querySelector('[data-spell="78"]')).not.toHaveTextContent("Macro");
    expect(getByRole(root, "button", { name: "Open Charge" })).toBeVisible();

    await user.click(getByRole(root, "button", { name: "Open Charge" }));
    expect(getByRole(root, "heading", { name: "Warrior Core" })).toBeVisible();
    expect(getByRole(root, "textbox", { name: "Name" })).toHaveValue("Charge");
  });

  it("shows a slot tooltip with keybind, macro, and nested abilities", async () => {
    document.body.innerHTML = '<div id="app"></div>';
    const root = document.querySelector<HTMLElement>("#app")!;
    const user = userEvent.setup();
    const opts = fixtureMountOpts();
    opts.catalog = withMacro(opts.catalog, "warrior-charge", {
      body: "#showtooltip [combat] Intercept; Charge\n/cast [nocombat] Charge; Intercept",
      notes: "Enters Battle for Charge or Berserker for Intercept.",
    });
    opts.spellbook.classes.WARRIOR![0]!.families.push({
      name: "Intercept",
      icon: "ability_rogue_sprint",
      maxSpellId: 20252,
      description: "Charge an enemy in combat, generating 10 rage.",
      ranks: [
        {
          spellId: 20252,
          name: "Intercept",
          rank: "Rank 1",
          level: 30,
          icon: "ability_rogue_sprint",
        },
      ],
    });

    mount(root, opts);

    await user.hover(getByRole(root, "button", { name: /Charge · 1 · slot 1/ }));
    const tip = getByRole(root, "tooltip");
    expect(tip).toHaveTextContent(/Keybind/);
    expect(tip).toHaveTextContent("1");
    expect(tip).toHaveTextContent(/Macro/);
    expect(tip).toHaveTextContent("Charge");
    expect(tip).toHaveTextContent("Enters Battle for Charge or Berserker for Intercept.");
    expect(tip).toHaveTextContent("/cast [nocombat] Charge; Intercept");
    expect(tip).toHaveTextContent("Charge an enemy, generate 15 rage, and stun it for 1 sec.");
    expect(tip).toHaveTextContent("Charge an enemy in combat, generating 10 rage.");
  });
});
