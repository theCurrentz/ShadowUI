import { fireEvent, getByRole, getByText, waitFor } from "@testing-library/dom";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { mount } from "../src/app";
import { PICKUP_MIME } from "../src/spellbook";
import { fixtureMountOpts, withMacro } from "./app-fixture";

function okJson(body: unknown): Response {
  return { ok: true, json: async () => body } as Response;
}

describe("Macro Cursor editing", () => {
  it("persists macro edits, action placement, and physical keybinds", async () => {
    document.body.innerHTML = '<div id="app"></div>';
    const root = document.querySelector<HTMLElement>("#app")!;
    const user = userEvent.setup();
    const opts = fixtureMountOpts();
    let serverCatalog = opts.catalog;

    const fetchMock = vi.mocked(fetch);
    fetchMock.mockImplementation(async (input, init) => {
      const url = String(input);
      const request = JSON.parse(String(init?.body ?? "{}")) as Record<string, unknown>;
      if (url === "/api/rename") {
        serverCatalog = withMacro(serverCatalog, String(request.id), { name: String(request.name) });
        return okJson({ ok: true, catalog: serverCatalog });
      }
      if (url === "/api/body") {
        serverCatalog = withMacro(serverCatalog, String(request.id), { body: String(request.body) });
        return okJson({ ok: true, catalog: serverCatalog });
      }
      if (url === "/api/keybinds") {
        return okJson({
          ok: true,
          base: {},
          classes: { WARRIOR: request.overlay },
        });
      }
      if (url === "/api/actions") {
        return okJson({
          ok: true,
          classes: { WARRIOR: { Arms: request.overlay } },
        });
      }
      throw new Error(`Unexpected request: ${url}`);
    });

    mount(root, opts);

    const name = getByRole(root, "textbox", { name: "Name" });
    await user.clear(name);
    await user.type(name, "Fast Charge{Enter}");
    await waitFor(() => expect(getByText(root, "Saved name Fast Charge.")).toBeVisible());
    expect(getByText(root, "Fast Charge").closest("button")).toBeVisible();

    const body = getByRole(root, "textbox", { name: "Body" });
    fireEvent.input(body, { target: { value: "#showtooltip\n/cast [combat] Charge" } });
    fireEvent.keyDown(body, { key: "Enter", code: "Enter", metaKey: true });
    await waitFor(() => expect(getByText(root, "Saved body for Fast Charge.")).toBeVisible());

    const execute = getByRole(root, "button", { name: /^Execute/ });
    const emptySlot = getByRole(root, "button", { name: /bar1 slot 2/ });
    const transfer = {
      data: new Map<string, string>(),
      effectAllowed: "none",
      dropEffect: "none",
      setData(type: string, value: string) {
        this.data.set(type, value);
      },
      getData(type: string) {
        return this.data.get(type) ?? "";
      },
    };
    fireEvent.dragStart(execute, { dataTransfer: transfer });
    expect(transfer.getData(PICKUP_MIME)).not.toBe("");
    transfer.data.delete(PICKUP_MIME);
    expect(JSON.parse(transfer.getData("text/plain"))).toEqual(
      expect.objectContaining({ kind: "macro", id: "warrior-execute" }),
    );
    fireEvent.drop(emptySlot, { dataTransfer: transfer });
    await waitFor(() => expect(getByText(root, "Placed Execute on slot 2.")).toBeVisible());
    expect(getByRole(root, "button", { name: /Execute · 2 · slot 2/ })).toBeVisible();

    await user.click(getByRole(root, "button", { name: "Keybind edit" }));
    const firstSlot = getByRole(root, "button", { name: /Fast Charge · 1 · slot 1/ });
    await user.click(firstSlot);
    fireEvent.keyDown(window, { key: "q", code: "KeyQ" });
    await waitFor(() => expect(getByText(root, "Bound Q to slot 1.")).toBeVisible());
    expect(getByRole(root, "button", { name: /Fast Charge · Q · slot 1/ })).toBeVisible();

    const requests = fetchMock.mock.calls.map(([url, init]) => ({
      url,
      body: JSON.parse(String(init?.body ?? "{}")) as Record<string, unknown>,
    }));
    expect(requests).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          url: "/api/rename",
          body: expect.objectContaining({ id: "warrior-charge", name: "Fast Charge" }),
        }),
        expect.objectContaining({
          url: "/api/body",
          body: expect.objectContaining({ id: "warrior-charge" }),
        }),
        expect.objectContaining({
          url: "/api/actions",
          body: expect.objectContaining({ classId: "WARRIOR", variant: "Arms" }),
        }),
        expect.objectContaining({
          url: "/api/keybinds",
          body: expect.objectContaining({ classId: "WARRIOR" }),
        }),
      ]),
    );
  });

  it("copies the visible stance page onto the other pages of that bar", async () => {
    document.body.innerHTML = '<div id="app"></div>';
    const root = document.querySelector<HTMLElement>("#app")!;
    const user = userEvent.setup();
    vi.spyOn(window, "confirm").mockReturnValue(true);
    vi.mocked(fetch).mockImplementation(async (input, init) => {
      const request = JSON.parse(String(init?.body ?? "{}")) as Record<string, unknown>;
      if (String(input) === "/api/actions") {
        return okJson({
          ok: true,
          classes: { WARRIOR: { Arms: request.overlay } },
        });
      }
      throw new Error(`Unexpected request: ${String(input)}`);
    });

    mount(root, fixtureMountOpts());

    expect(getByRole(root, "button", { name: "Main" })).toBeVisible();
    await user.click(getByRole(root, "button", { name: "Copy to other pages" }));
    await waitFor(() =>
      expect(getByText(root, "Copied bar1 Main onto Slot 13.")).toBeVisible(),
    );
    await user.click(getByRole(root, "button", { name: "Slot 13" }));
    expect(getByRole(root, "button", { name: /Charge · 1 · slot 13/ })).toBeVisible();
  });
});
