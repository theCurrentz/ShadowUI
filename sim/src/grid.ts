export type HtmlBox = {
  left: number;
  top: number;
  width: number;
  height: number;
};

export type BarLayout = {
  columns: number;
  rows: number;
  width: number;
  height: number;
};

export type Handle = "n" | "s" | "e" | "w" | "ne" | "nw" | "se" | "sw";

export const HANDLES: Handle[] = ["n", "s", "e", "w", "ne", "nw", "se", "sw"];

export function columnChoices(buttons: number): number[] {
  const count = Math.max(1, buttons);
  const cols: number[] = [];
  for (let c = count; c >= 1; c--) {
    if (count % c === 0) cols.push(c);
  }
  return cols;
}

export function layoutForColumns(buttons: number, columns: number, slotSize: number): BarLayout {
  const count = Math.max(1, buttons);
  const cols = Math.max(1, Math.min(columns, count));
  const rows = Math.ceil(count / cols);
  return {
    columns: cols,
    rows,
    width: cols * slotSize,
    height: rows * slotSize,
  };
}

export function nearestBarLayout(
  buttons: number,
  slotSize: number,
  width: number,
  height: number,
): BarLayout {
  const aspect = Math.max(width, 1) / Math.max(height, 1);
  const logAspect = Math.log(aspect);
  let best = layoutForColumns(buttons, columnChoices(buttons)[0], slotSize);
  let bestDist = Number.POSITIVE_INFINITY;
  columnChoices(buttons).forEach((cols) => {
    const layout = layoutForColumns(buttons, cols, slotSize);
    const layoutLog = Math.log(layout.width / layout.height);
    const dist = (layoutLog - logAspect) * (layoutLog - logAspect);
    if (dist < bestDist) {
      bestDist = dist;
      best = layout;
    }
  });
  return best;
}

export function snapValue(value: number, grid: number): number {
  return Math.round(value / grid) * grid;
}

export function snapBox(box: HtmlBox, grid: number): HtmlBox {
  return {
    left: snapValue(box.left, grid),
    top: snapValue(box.top, grid),
    width: Math.max(grid, snapValue(box.width, grid)),
    height: Math.max(grid, snapValue(box.height, grid)),
  };
}

export function snapChromeSize(width: number, height: number, grid: number): { width: number; height: number } {
  return {
    width: Math.max(grid, snapValue(width, grid)),
    height: Math.max(grid, snapValue(height, grid)),
  };
}

export function applyHandleSize(box: HtmlBox, handle: Handle, width: number, height: number): HtmlBox {
  let left = box.left;
  let top = box.top;
  if (handle.indexOf("w") !== -1) left = box.left + box.width - width;
  if (handle.indexOf("n") !== -1) top = box.top + box.height - height;
  return { left, top, width, height };
}

export function desiredSize(start: HtmlBox, handle: Handle, dx: number, dy: number): { width: number; height: number } {
  let width = start.width;
  let height = start.height;
  if (handle.indexOf("e") !== -1) width = start.width + dx;
  if (handle.indexOf("w") !== -1) width = start.width - dx;
  if (handle.indexOf("s") !== -1) height = start.height + dy;
  if (handle.indexOf("n") !== -1) height = start.height - dy;
  return { width, height };
}
