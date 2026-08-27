import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { pickupClickAction, pickupDropOffBarAction } from "../src/pickup-gesture.ts";
import { consumeSelfWrite, markSelfWrite, writeWatchedFile } from "../src/self-write.ts";

test("a click after drop does not clear or re-place the held action", () => {
  assert.equal(
    pickupClickAction({
      holding: true,
      keybindMode: false,
      insideHudSlot: false,
      suppressAfterDrop: true,
    }),
    "ignore",
  );
  assert.equal(
    pickupClickAction({
      holding: true,
      keybindMode: false,
      insideHudSlot: true,
      suppressAfterDrop: true,
    }),
    "ignore",
  );
  assert.equal(
    pickupClickAction({
      holding: true,
      keybindMode: false,
      insideHudSlot: true,
      suppressAfterDrop: false,
    }),
    "place-on-slot",
  );
  assert.equal(
    pickupClickAction({
      holding: true,
      keybindMode: false,
      insideHudSlot: false,
      suppressAfterDrop: false,
    }),
    "clear-held",
  );
});

test("a drop off the Action Bars clears the source; a drop on a slot does not", () => {
  assert.equal(
    pickupDropOffBarAction({ fromSlot: 73, droppedOnSlot: false }),
    "clear-source",
  );
  assert.equal(
    pickupDropOffBarAction({ fromSlot: 73, droppedOnSlot: true }),
    "ignore",
  );
  assert.equal(
    pickupDropOffBarAction({ fromSlot: undefined, droppedOnSlot: false }),
    "ignore",
  );
});

test("self-written files are consumed once so Vite can skip HMR", () => {
  const file = path.join(os.tmpdir(), "shadowui-self-write.lua");
  markSelfWrite(file);
  assert.equal(consumeSelfWrite(file), true);
  assert.equal(consumeSelfWrite(file), false);
});

test("writeWatchedFile skips a no-op write", () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "shadowui-watch-"));
  const file = path.join(dir, "WARRIOR.lua");
  fs.writeFileSync(file, "keep\n");
  assert.equal(writeWatchedFile(file, "keep\n"), false);
  assert.equal(consumeSelfWrite(file), false);
  assert.equal(writeWatchedFile(file, "next\n"), true);
  assert.equal(consumeSelfWrite(file), true);
  assert.equal(fs.readFileSync(file, "utf8"), "next\n");
});
