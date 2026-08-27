/** Clicks in the same gesture as an Action Bar drop must not place or clear held. */
export function pickupClickAction(input: {
  holding: boolean;
  keybindMode: boolean;
  insideHudSlot: boolean;
  suppressAfterDrop: boolean;
}): "place-on-slot" | "clear-held" | "ignore" {
  if (!input.holding || input.keybindMode || input.suppressAfterDrop) return "ignore";
  if (input.insideHudSlot) return "place-on-slot";
  return "clear-held";
}

/** Clear the source only after a drop that is not on an Action Slot. A cancelled drag keeps the action. */
export function pickupDropOffBarAction(input: {
  fromSlot: number | undefined;
  droppedOnSlot: boolean;
}): "clear-source" | "ignore" {
  if (input.fromSlot === undefined || input.droppedOnSlot) return "ignore";
  return "clear-source";
}
