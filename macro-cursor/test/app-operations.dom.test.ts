import {
  getAllByRole,
  getByRole,
  getByText,
  queryByRole,
  waitFor,
} from "@testing-library/dom";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { mount } from "../src/app";
import { fixtureMountOpts } from "./app-fixture";

describe("Macro Cursor operations", () => {
  it("copies, exports, validates, and deletes through visible controls", async () => {
    document.body.innerHTML = '<div id="app"></div>';
    const root = document.querySelector<HTMLElement>("#app")!;
    const user = userEvent.setup();
    vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(() => undefined);
    vi.mocked(fetch).mockResolvedValue({ ok: true } as Response);

    mount(root, fixtureMountOpts());

    await user.click(getByRole(root, "button", { name: "Copy body" }));
    expect(getByText(root, "Copied Charge.")).toBeVisible();

    await user.click(getByRole(root, "button", { name: "Load character" }));
    await user.click(getByRole(root, "button", { name: /Loaded 2/ }));
    await user.click(getAllByRole(root, "button", { name: "Export cache" })[1]!);
    expect(URL.createObjectURL).toHaveBeenCalledOnce();
    expect(getByText(root, /Exported 2 character macros/)).toBeVisible();

    await user.click(getByRole(root, "button", { name: "Library" }));
    await user.click(getByRole(root, "button", { name: /^Execute/ }));
    const name = getByRole(root, "textbox", { name: "Name" });
    await user.clear(name);
    await user.type(name, "Charge{Enter}");
    expect(getByText(root, /Name "Charge" is already used/)).toBeVisible();

    await user.click(getByRole(root, "button", { name: "Delete Execute" }));
    await waitFor(() =>
      expect(getByText(root, "Removed Execute from the catalog.")).toBeVisible(),
    );
    expect(queryByRole(root, "button", { name: /^Execute/ })).not.toBeInTheDocument();
    expect(fetch).toHaveBeenCalledWith(
      "/api/prune",
      expect.objectContaining({ method: "POST" }),
    );
  });
});
