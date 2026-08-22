import layoutJson from "../layout.json";
import {
  applyHandleSize,
  desiredSize,
  HANDLES,
  nearestBarLayout,
  layoutForColumns,
  snapBox,
  snapChromeSize,
  snapValue,
  type Handle,
} from "./grid";
import type {
  HtmlBox,
  LayoutDump,
  NamedSave,
  Patch,
  WidgetCfg,
  WidgetSnapshot,
} from "./types";

const DATA = layoutJson as LayoutDump;
const SAVE_KEY = "shadowui-sim-saves";

function requireEl<T extends HTMLElement>(id: string): T {
  const el = document.getElementById(id);
  if (!el) throw new Error("missing #" + id);
  return el as T;
}

type Orig = {
  x: number;
  y: number;
  point: string;
  html: HtmlBox;
  target?: string;
  persist?: boolean;
  buttons?: number;
  columns?: number;
};

type Drag = {
  kind: "move";
  el: HTMLElement;
  dx: number;
  dy: number;
  scale: number;
  rect: DOMRect;
};

type Resize = {
  kind: "resize";
  el: HTMLElement;
  handle: Handle;
  scale: number;
  rect: DOMRect;
  start: HtmlBox;
  startX: number;
  startY: number;
};

export function startHud(): void {
  const sw = DATA.screen.width;
  const sh = DATA.screen.height;
  const grid = DATA.grid || 36;
  const stage = requireEl("stage");
  const wrap = requireEl("stageWrap");
  const select = requireEl<HTMLSelectElement>("classSelect");
  const layoutSelect = requireEl<HTMLSelectElement>("layoutSelect");
  const status = requireEl("status");
  const luaOut = requireEl("luaOut");
  const saveDialog = requireEl<HTMLDialogElement>("saveDialog");
  const saveHint = requireEl("saveHint");
  const saveAsRow = requireEl("saveAsRow");
  const saveAsName = requireEl<HTMLInputElement>("saveAsName");
  const deleteSaveBtn = requireEl<HTMLButtonElement>("deleteSaveBtn");
  const queryClass = (location.search.match(/[?&]class=([A-Z]+)/) || [])[1];
  let currentClass = queryClass && DATA.classes[queryClass] ? queryClass : "MAGE";
  let currentSave = "";
  const originals: Record<string, Record<string, Orig>> = {};
  let session: Drag | Resize | null = null;

  function snap(value: number): number {
    return snapValue(value, grid);
  }

  function fromHtml(point: string, box: HtmlBox): { x: number; y: number } {
    const w = box.width;
    const h = box.height;
    const left = box.left;
    const top = box.top;
    if (point === "BOTTOM") {
      return { x: left + w / 2 - sw / 2, y: sh - (top + h) };
    }
    if (point === "TOP") {
      return { x: left + w / 2 - sw / 2, y: -top };
    }
    if (point === "TOPRIGHT") {
      return { x: left + w - sw, y: -top };
    }
    if (point === "BOTTOMRIGHT") {
      return { x: left + w - sw, y: sh - (top + h) };
    }
    if (point === "TOPLEFT") {
      return { x: left, y: -top };
    }
    if (point === "BOTTOMLEFT") {
      return { x: left, y: sh - (top + h) };
    }
    if (point === "RIGHT") {
      return { x: left + w - sw, y: sh / 2 - (top + h / 2) };
    }
    return { x: left + w / 2 - sw / 2, y: sh / 2 - (top + h / 2) };
  }

  function applyHtml(el: HTMLElement, html: HtmlBox): void {
    el.style.left = html.left + "px";
    el.style.top = html.top + "px";
    el.style.width = html.width + "px";
    el.style.height = html.height + "px";
  }

  function scaleStage(): void {
    const view = requireEl("viewport");
    const pad = 24;
    const sx = (view.clientWidth - pad) / sw;
    const sy = (view.clientHeight - pad) / sh;
    let s = Math.min(sx, sy, 1);
    if (s <= 0) s = 1;
    stage.style.transform = "scale(" + s + ")";
    wrap.style.width = sw * s + "px";
    wrap.style.height = sh * s + "px";
  }

  function applyBarGrid(el: HTMLElement, columns: number, buttons: number): void {
    const cols = Math.max(1, Math.min(columns, buttons));
    const rows = Math.ceil(buttons / cols);
    el.style.gridTemplateColumns = "repeat(" + cols + ", 1fr)";
    el.style.gridTemplateRows = "repeat(" + rows + ", 1fr)";
    el.dataset.columns = String(cols);
  }

  function makeBar(cfg: WidgetCfg): HTMLElement {
    const el = document.createElement("div");
    el.className = "widget persist bar";
    const buttons = cfg.buttons || 12;
    const cols = Math.max(1, Math.min(cfg.columns || buttons, buttons));
    el.dataset.buttons = String(buttons);
    el.dataset.buttonSize = String(cfg.buttonSize || 36);
    applyBarGrid(el, cols, buttons);
    for (let i = 0; i < buttons; i++) {
      const slot = document.createElement("div");
      slot.className = "slot";
      el.appendChild(slot);
    }
    return el;
  }

  function addHandles(el: HTMLElement): void {
    HANDLES.forEach((dir) => {
      const handle = document.createElement("div");
      handle.className = "resize-handle " + dir;
      handle.dataset.handle = dir;
      handle.addEventListener("pointerdown", onResizeDown);
      el.appendChild(handle);
    });
  }

  function makeChrome(cfg: WidgetCfg): HTMLElement {
    const el = document.createElement("div");
    el.className = "widget " + (cfg.persist !== false ? "persist " : "") + (cfg.kind || "");
    if (cfg.kind === "chat") {
      el.textContent = "[Chat] Party: ready check.";
    }
    if (cfg.kind === "details") {
      el.textContent = cfg.label === "Threat" ? "Threat" : "Damage";
    }
    if (cfg.kind === "cast") {
      const icon = document.createElement("div");
      icon.className = "cast-icon";
      el.appendChild(icon);
      for (let i = 1; i <= 7; i++) {
        const tick = document.createElement("div");
        tick.className = "cast-tick";
        tick.style.left = (i / 8) * 100 + "%";
        el.appendChild(tick);
      }
    }
    if (cfg.kind === "minimap") {
      const map = document.createElement("div");
      map.className = "minimap-map";
      el.appendChild(map);
      const zone = document.createElement("div");
      zone.className = "minimap-zone";
      zone.textContent = "Elwynn Forest";
      el.appendChild(zone);
      const time = document.createElement("div");
      time.className = "minimap-time";
      el.appendChild(time);
      const layer = document.createElement("div");
      layer.className = "minimap-layer";
      layer.textContent = "Layer 1";
      el.appendChild(layer);
    }
    if (cfg.kind === "micro") {
      for (let i = 0; i < 8; i++) {
        const btn = document.createElement("div");
        btn.className = "micro-btn";
        el.appendChild(btn);
      }
      const bag = document.createElement("div");
      bag.className = "micro-bag";
      el.appendChild(bag);
    }
    if (cfg.kind === "swing") {
      const hands = cfg.hands || { main: true, off: true, range: true };
      (["main", "off", "range"] as const).forEach((hand) => {
        if (!hands[hand]) return;
        const lane = document.createElement("div");
        lane.className = "swing-lane swing-" + hand;
        el.appendChild(lane);
      });
    }
    if (cfg.kind === "shields") {
      (
        [
          ["fire", "100%"],
          ["holy", "50%"],
          ["frost", "100%"],
        ] as const
      ).forEach(([school, pct]) => {
        const icon = document.createElement("div");
        icon.className = "shield-icon shield-" + school;
        const fill = document.createElement("div");
        fill.className = "shield-fill";
        fill.style.height = pct;
        icon.appendChild(fill);
        const label = document.createElement("div");
        label.className = "shield-pct";
        label.textContent = pct;
        icon.appendChild(label);
        el.appendChild(icon);
      });
    }
    return el;
  }

  function addLabel(el: HTMLElement, text: string): void {
    const label = document.createElement("div");
    label.className = "label";
    label.textContent = text;
    el.appendChild(label);
  }

  function boxes() {
    return Array.from(stage.querySelectorAll<HTMLElement>(".widget")).map((el) => ({
      id: el.dataset.id,
      left: parseFloat(el.style.left),
      top: parseFloat(el.style.top),
      width: parseFloat(el.style.width),
      height: parseFloat(el.style.height),
      el,
    }));
  }

  function markOverlaps(): void {
    const all = boxes();
    all.forEach((a) => a.el.classList.remove("overlap"));
    for (let i = 0; i < all.length; i++) {
      for (let j = i + 1; j < all.length; j++) {
        const a = all[i];
        const b = all[j];
        const locked =
          (a.el.dataset.group && a.el.dataset.group === b.el.dataset.group) ||
          a.el.dataset.lock === b.id ||
          b.el.dataset.lock === a.id;
        const hit =
          !locked &&
          a.left < b.left + b.width &&
          b.left < a.left + a.width &&
          a.top < b.top + b.height &&
          b.top < a.top + a.height;
        if (hit) {
          a.el.classList.add("overlap");
          b.el.classList.add("overlap");
        }
      }
    }
  }

  function render(): void {
    const pack = DATA.classes[currentClass];
    stage.innerHTML = "";
    const gridEl = document.createElement("div");
    gridEl.className = "grid";
    gridEl.style.backgroundSize = grid + "px " + grid + "px";
    stage.appendChild(gridEl);
    originals[currentClass] = originals[currentClass] || {};
    function place(cfg: WidgetCfg, factory: (c: WidgetCfg) => HTMLElement): void {
      const el = factory(cfg);
      el.dataset.id = cfg.id;
      el.dataset.point = cfg.point || "CENTER";
      el.dataset.persist = cfg.persist ? "1" : "";
      el.dataset.target = cfg.target || "";
      el.dataset.lock = cfg.lock || "";
      if (cfg.id === "castbar" || cfg.id === "gcd" || cfg.id === "swing") {
        el.dataset.group = "cast";
      }
      if (cfg.id === "player" || cfg.id === "shields") {
        el.dataset.group = "player";
      }
      const html = el.classList.contains("bar") ? cfg.html : snapBox(cfg.html, grid);
      applyHtml(el, html);
      addLabel(el, cfg.label || cfg.id);
      if (cfg.persist) addHandles(el);
      if (!originals[currentClass][cfg.id]) {
        const pos = fromHtml(String(cfg.point || "CENTER"), html);
        originals[currentClass][cfg.id] = {
          x: pos.x,
          y: pos.y,
          point: String(cfg.point || "CENTER"),
          html: {
            left: html.left,
            top: html.top,
            width: html.width,
            height: html.height,
          },
          target: cfg.target,
          persist: cfg.persist,
          buttons: cfg.buttons,
          columns: cfg.columns,
        };
      }
      if (cfg.persist) {
        el.addEventListener("pointerdown", onDown);
      }
      stage.appendChild(el);
    }
    pack.chrome.forEach((cfg) => place(cfg, makeChrome));
    pack.bars.forEach((cfg) => place(cfg, makeBar));
    stackMeters();
    stackShields();
    markOverlaps();
    document.title = "ShadowUI " + currentClass + " layout";
    status.textContent = statusLine();
  }

  function statusLine(): string {
    const extra = currentSave ? " · " + currentSave : "";
    return currentClass + extra + " · snap " + grid + "px";
  }

  function readSaves(): Record<string, NamedSave> {
    try {
      return JSON.parse(localStorage.getItem(SAVE_KEY) || "{}") || {};
    } catch {
      return {};
    }
  }

  function writeSaves(map: Record<string, NamedSave>): void {
    localStorage.setItem(SAVE_KEY, JSON.stringify(map));
  }

  function saveId(name: string): string {
    return currentClass + ":" + name;
  }

  function namesForClass(): string[] {
    const map = readSaves();
    const names: string[] = [];
    Object.keys(map).forEach((key) => {
      const rec = map[key];
      if (rec && rec.classFile === currentClass) names.push(rec.name);
    });
    names.sort();
    return names;
  }

  function fillLayoutSelect(): void {
    const names = namesForClass();
    layoutSelect.innerHTML = "";
    const shipped = document.createElement("option");
    shipped.value = "";
    shipped.textContent = "Shipped default";
    layoutSelect.appendChild(shipped);
    names.forEach((name) => {
      const opt = document.createElement("option");
      opt.value = name;
      opt.textContent = name;
      layoutSelect.appendChild(opt);
    });
    if (currentSave && names.indexOf(currentSave) === -1) currentSave = "";
    layoutSelect.value = currentSave;
  }

  function snapshotWidgets(): Record<string, WidgetSnapshot> {
    const out: Record<string, WidgetSnapshot> = {};
    stage.querySelectorAll<HTMLElement>(".widget").forEach((el) => {
      const box = {
        left: parseFloat(el.style.left),
        top: parseFloat(el.style.top),
        width: parseFloat(el.style.width),
        height: parseFloat(el.style.height),
      };
      const pos = fromHtml(el.dataset.point || "CENTER", box);
      const shot: WidgetSnapshot = {
        point: el.dataset.point || "CENTER",
        x: pos.x,
        y: pos.y,
        width: box.width,
        height: box.height,
      };
      if (el.classList.contains("bar") && el.dataset.columns) {
        shot.columns = Number(el.dataset.columns);
      }
      out[el.dataset.id || ""] = shot;
    });
    return out;
  }

  function applySnapshot(widgets: Record<string, WidgetSnapshot> | undefined): void {
    if (!widgets) return;
    stage.querySelectorAll<HTMLElement>(".widget").forEach((el) => {
      const cfg = widgets[el.dataset.id || ""];
      if (!cfg) return;
      el.dataset.point = cfg.point || el.dataset.point;
      const width = cfg.width || parseFloat(el.style.width);
      const height = cfg.height || parseFloat(el.style.height);
      applyHtml(
        el,
        snapBox(
          htmlBox({
            point: el.dataset.point || "CENTER",
            x: cfg.x,
            y: cfg.y,
            width,
            height,
          }),
          grid,
        ),
      );
      if (el.classList.contains("bar")) {
        const buttons = Number(el.dataset.buttons || 12);
        const size = Number(el.dataset.buttonSize || 36);
        const layout = cfg.columns
          ? layoutForColumns(buttons, cfg.columns, size)
          : nearestBarLayout(buttons, size, width, height);
        applyBarGrid(el, layout.columns, buttons);
      }
    });
    stackMeters();
    stackShields();
    markOverlaps();
  }

  function loadNamedSave(name: string): void {
    currentSave = name || "";
    render();
    if (currentSave) {
      const rec = readSaves()[saveId(currentSave)];
      if (rec) applySnapshot(rec.widgets);
    }
    fillLayoutSelect();
    status.textContent = statusLine();
  }

  function stageScale(): { scale: number; rect: DOMRect } {
    const rect = stage.getBoundingClientRect();
    return { scale: rect.width / sw, rect };
  }

  function currentBox(el: HTMLElement): HtmlBox {
    return {
      left: parseFloat(el.style.left),
      top: parseFloat(el.style.top),
      width: parseFloat(el.style.width),
      height: parseFloat(el.style.height),
    };
  }

  function placeBox(el: HTMLElement, box: HtmlBox): void {
    applyHtml(el, {
      left: snap(box.left),
      top: snap(box.top),
      width: box.width,
      height: box.height,
    });
    markOverlaps();
  }

  function widgetById(id: string): HTMLElement | null {
    return stage.querySelector<HTMLElement>('.widget[data-id="' + id + '"]');
  }

  function lockedMate(el: HTMLElement): HTMLElement | null {
    const lock = el.dataset.lock;
    if (!lock) return null;
    return widgetById(lock);
  }

  const METER_IDS = ["castbar", "gcd", "swing"];

  function meterGroup(el: HTMLElement): HTMLElement[] {
    if (!METER_IDS.includes(el.dataset.id || "")) return [];
    return METER_IDS.map(widgetById).filter((node): node is HTMLElement => !!node);
  }

  function stackMeters(): void {
    const cast = widgetById("castbar");
    const gcd = widgetById("gcd");
    const swing = widgetById("swing");
    if (!cast || !gcd) return;
    const c = currentBox(cast);
    const left = c.left;
    const width = c.width;
    const iconEl = cast.querySelector(".cast-icon") as HTMLElement | null;
    if (iconEl) iconEl.style.width = c.height + "px";
    const g = currentBox(gcd);
    applyHtml(gcd, {
      left,
      top: c.top + c.height,
      width,
      height: g.height,
    });
    if (!swing) return;
    const s = currentBox(swing);
    const g2 = currentBox(gcd);
    applyHtml(swing, {
      left,
      top: g2.top + g2.height,
      width,
      height: s.height,
    });
  }

  function stackShields(): void {
    const player = widgetById("player");
    const shields = widgetById("shields");
    if (!player || !shields) return;
    const p = currentBox(player);
    const s = currentBox(shields);
    applyHtml(shields, {
      left: snap(p.left + (p.width - s.width) / 2),
      top: snap(p.top - s.height - grid),
      width: s.width,
      height: s.height,
    });
  }

  function moveLocked(el: HTMLElement, from: HtmlBox, placed: HtmlBox): void {
    const group = meterGroup(el);
    if (group.length) {
      const dx = placed.left - from.left;
      const dy = placed.top - from.top;
      group.forEach((other) => {
        if (other === el) return;
        const box = currentBox(other);
        applyHtml(other, {
          left: box.left + dx,
          top: box.top + dy,
          width: box.width,
          height: box.height,
        });
      });
      stackMeters();
      stackShields();
      markOverlaps();
      return;
    }
    const mate = lockedMate(el);
    if (!mate) return;
    const mateBox = currentBox(mate);
    applyHtml(mate, {
      left: mateBox.left + (placed.left - from.left),
      top: mateBox.top + (placed.top - from.top),
      width: mateBox.width,
      height: mateBox.height,
    });
    stackMeters();
    stackShields();
    markOverlaps();
  }

  function resizeLocked(el: HTMLElement): void {
    const group = meterGroup(el);
    if (group.length) {
      const box = currentBox(el);
      group.forEach((other) => {
        if (other === el) return;
        const o = currentBox(other);
        applyHtml(other, { left: box.left, top: o.top, width: box.width, height: o.height });
      });
      stackMeters();
      stackShields();
      markOverlaps();
      return;
    }
    const mate = lockedMate(el);
    if (!mate) return;
    if (el.dataset.id === "gcd") {
      const g = currentBox(el);
      const c = currentBox(mate);
      applyHtml(mate, { left: g.left, top: c.top, width: g.width, height: c.height });
    }
    stackMeters();
    stackShields();
    markOverlaps();
  }

  function onDown(ev: PointerEvent): void {
    const el = ev.currentTarget as HTMLElement;
    el.setPointerCapture(ev.pointerId);
    const { scale, rect } = stageScale();
    session = {
      kind: "move",
      el,
      dx: ev.clientX / scale - parseFloat(el.style.left) - rect.left / scale,
      dy: ev.clientY / scale - parseFloat(el.style.top) - rect.top / scale,
      scale,
      rect,
    };
    el.classList.add("dragging");
    meterGroup(el).forEach((node) => node.classList.add("dragging"));
    const mate = lockedMate(el);
    if (mate) mate.classList.add("dragging");
    ev.preventDefault();
  }

  function onResizeDown(ev: PointerEvent): void {
    ev.stopPropagation();
    const handleEl = ev.currentTarget as HTMLElement;
    const el = handleEl.parentElement;
    if (!el) return;
    el.setPointerCapture(ev.pointerId);
    const { scale, rect } = stageScale();
    session = {
      kind: "resize",
      el,
      handle: handleEl.dataset.handle as Handle,
      scale,
      rect,
      start: currentBox(el),
      startX: ev.clientX,
      startY: ev.clientY,
    };
    el.classList.add("dragging");
    meterGroup(el).forEach((node) => node.classList.add("dragging"));
    const mate = lockedMate(el);
    if (mate) mate.classList.add("dragging");
    ev.preventDefault();
  }

  function resizeBox(el: HTMLElement, handle: Handle, dx: number, dy: number): HtmlBox {
    const start = (session as Resize).start;
    const raw = desiredSize(start, handle, dx, dy);
    let width = raw.width;
    let height = raw.height;
    if (el.classList.contains("bar")) {
      const buttons = Number(el.dataset.buttons || 12);
      const size = Number(el.dataset.buttonSize || 36);
      const layout = nearestBarLayout(buttons, size, width, height);
      applyBarGrid(el, layout.columns, buttons);
      width = layout.width;
      height = layout.height;
    } else {
      const sized = snapChromeSize(width, height, grid);
      width = sized.width;
      height = sized.height;
    }
    return applyHandleSize(start, handle, width, height);
  }

  function onMove(ev: PointerEvent): void {
    if (!session) return;
    const scale = session.scale;
    if (session.kind === "move") {
      const left = ev.clientX / scale - session.rect.left / scale - session.dx;
      const top = ev.clientY / scale - session.rect.top / scale - session.dy;
      const w = parseFloat(session.el.style.width);
      const h = parseFloat(session.el.style.height);
      const from = currentBox(session.el);
      placeBox(session.el, { left, top, width: w, height: h });
      moveLocked(session.el, from, currentBox(session.el));
      return;
    }
    const dx = (ev.clientX - session.startX) / scale;
    const dy = (ev.clientY - session.startY) / scale;
    placeBox(session.el, resizeBox(session.el, session.handle, dx, dy));
    resizeLocked(session.el);
  }

  function htmlBox(cfg: { point: string; x: number; y: number; width: number; height: number }): HtmlBox {
    const w = cfg.width;
    const h = cfg.height;
    const x = cfg.x;
    const y = cfg.y;
    const point = cfg.point;
    if (point === "BOTTOM") {
      return { left: sw / 2 + x - w / 2, top: sh - (y + h), width: w, height: h };
    }
    if (point === "TOP") {
      return { left: sw / 2 + x - w / 2, top: -y, width: w, height: h };
    }
    if (point === "TOPRIGHT") {
      return { left: sw + x - w, top: -y, width: w, height: h };
    }
    if (point === "BOTTOMRIGHT") {
      return { left: sw + x - w, top: sh - y - h, width: w, height: h };
    }
    if (point === "TOPLEFT") {
      return { left: x, top: -y, width: w, height: h };
    }
    if (point === "BOTTOMLEFT") {
      return { left: x, top: sh - y - h, width: w, height: h };
    }
    if (point === "RIGHT") {
      return { left: sw + x - w, top: sh / 2 - (y + h / 2), width: w, height: h };
    }
    return { left: sw / 2 + x - w / 2, top: sh / 2 - (y + h / 2), width: w, height: h };
  }

  function onUp(): void {
    if (!session) return;
    session.el.classList.remove("dragging");
    meterGroup(session.el).forEach((node) => node.classList.remove("dragging"));
    const mate = lockedMate(session.el);
    if (mate) mate.classList.remove("dragging");
    session = null;
    showPatch();
  }

  function collectPatch(): Patch {
    const orig = originals[currentClass] || {};
    const patch: Patch = { classFile: currentClass, layout: {} };
    stage.querySelectorAll<HTMLElement>(".widget[data-persist='1']").forEach((el) => {
      const id = el.dataset.id;
      if (!id) return;
      const src = orig[id];
      if (!src) return;
      const box = {
        left: parseFloat(el.style.left),
        top: parseFloat(el.style.top),
        width: parseFloat(el.style.width),
        height: parseFloat(el.style.height),
      };
      const pos = fromHtml(el.dataset.point || "CENTER", box);
      const columns = el.classList.contains("bar") ? Number(el.dataset.columns || src.columns || 0) : undefined;
      const samePos = pos.x === src.x && pos.y === src.y;
      const sameSize = box.width === src.html.width && box.height === src.html.height;
      const sameGrid = columns === undefined || columns === src.columns;
      if (samePos && sameSize && sameGrid) return;
      const entry = {
        point: el.dataset.point || "CENTER",
        relativeTo: "UIParent",
        relativePoint: el.dataset.point || "CENTER",
        x: pos.x,
        y: pos.y,
        target: el.dataset.target || "",
        width: undefined as number | undefined,
        height: undefined as number | undefined,
        buttons: undefined as number | undefined,
        columns: undefined as number | undefined,
      };
      if (el.dataset.target === "chrome") {
        entry.width = box.width;
        entry.height = box.height;
      } else if (columns !== undefined && columns !== src.columns) {
        entry.buttons = Number(el.dataset.buttons || src.buttons || 12);
        entry.columns = columns;
      }
      patch.layout[id] = entry;
    });
    return patch;
  }

  function formatLua(patch: Patch): string {
    const base: string[] = [];
    const klass: string[] = [];
    const chrome: string[] = [];
    Object.keys(patch.layout)
      .sort()
      .forEach((id) => {
        const cfg = patch.layout[id];
        if (cfg.target === "chrome") {
          chrome.push(
            id +
              " = { point = \"" +
              cfg.point +
              "\", x = " +
              cfg.x +
              ", y = " +
              cfg.y +
              ", width = " +
              cfg.width +
              ", height = " +
              cfg.height +
              " },",
          );
          return;
        }
        const extra =
          cfg.columns != null
            ? "      buttons = " + cfg.buttons + ", columns = " + cfg.columns + ",\n"
            : "";
        const block =
          id +
          " = {\n" +
          "      point = \"" +
          cfg.point +
          "\", relativeTo = \"UIParent\", relativePoint = \"" +
          cfg.relativePoint +
          "\",\n" +
          "      x = " +
          cfg.x +
          ", y = " +
          cfg.y +
          ",\n" +
          extra +
          "    },";
        if (cfg.target === "class") klass.push(block);
        else base.push(block);
      });
    let out = "";
    if (base.length) {
      out += "-- defaults/base.lua layout deltas\n" + base.join("\n") + "\n";
    }
    if (klass.length) {
      out += "-- defaults/classes/" + patch.classFile + ".lua layout deltas\n" + klass.join("\n") + "\n";
    }
    if (chrome.length) {
      out += "-- sim/chrome.lua position and size deltas (not Layout; harness only)\n" + chrome.join("\n") + "\n";
    }
    return out || "-- no moves or resizes\n";
  }

  function showPatch(): void {
    const patch = collectPatch();
    luaOut.hidden = false;
    luaOut.textContent = formatLua(patch);
  }

  function downloadPatch(): void {
    const patch = collectPatch();
    const blob = new Blob([JSON.stringify(patch, null, 2)], { type: "application/json" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "patch.json";
    a.click();
    URL.revokeObjectURL(a.href);
  }

  function openSaveDialog(): void {
    saveHint.textContent = currentSave
      ? "Class " + currentClass + ". Active save: " + currentSave + "."
      : "Class " +
        currentClass +
        ". Replace default copies Lua for shipped files. Save as stores a named copy in this browser.";
    saveAsRow.hidden = true;
    saveAsName.value = currentSave || "";
    deleteSaveBtn.hidden = !currentSave;
    saveDialog.showModal();
  }

  function closeSaveDialog(): void {
    if (saveDialog.open) saveDialog.close();
  }

  function copyLua(message?: string): void {
    showPatch();
    navigator.clipboard.writeText(luaOut.textContent || "").then(() => {
      status.textContent = message || "Lua copied";
    });
  }

  function saveNamed(name: string): boolean {
    name = name.replace(/^\s+|\s+$/g, "");
    if (!name) {
      status.textContent = "Enter a save name";
      return false;
    }
    const map = readSaves();
    map[saveId(name)] = {
      name,
      classFile: currentClass,
      widgets: snapshotWidgets(),
    };
    writeSaves(map);
    currentSave = name;
    fillLayoutSelect();
    status.textContent = "Saved " + name;
    return true;
  }

  Object.keys(DATA.classes)
    .sort()
    .forEach((name) => {
      const opt = document.createElement("option");
      opt.value = name;
      opt.textContent = name;
      select.appendChild(opt);
    });
  select.value = currentClass;
  select.addEventListener("change", () => {
    currentClass = select.value;
    currentSave = "";
    history.replaceState(null, "", "?class=" + currentClass);
    fillLayoutSelect();
    render();
    luaOut.hidden = true;
  });
  layoutSelect.addEventListener("change", () => {
    loadNamedSave(layoutSelect.value);
    luaOut.hidden = true;
  });
  requireEl("resetBtn").addEventListener("click", () => {
    originals[currentClass] = {};
    currentSave = "";
    fillLayoutSelect();
    render();
    luaOut.hidden = true;
  });
  requireEl("saveBtn").addEventListener("click", openSaveDialog);
  requireEl("saveCancelBtn").addEventListener("click", closeSaveDialog);
  requireEl("saveAsToggleBtn").addEventListener("click", () => {
    saveAsRow.hidden = false;
    saveAsName.focus();
  });
  requireEl("saveAsConfirmBtn").addEventListener("click", () => {
    if (saveNamed(saveAsName.value)) closeSaveDialog();
  });
  saveAsName.addEventListener("keydown", (ev) => {
    if (ev.key === "Enter") {
      ev.preventDefault();
      if (saveNamed(saveAsName.value)) closeSaveDialog();
    }
  });
  requireEl("replaceDefaultBtn").addEventListener("click", () => {
    copyLua("Replace default: paste Lua into defaults/ and sim/chrome.lua");
    closeSaveDialog();
  });
  requireEl("exportJsonBtn").addEventListener("click", () => {
    downloadPatch();
    closeSaveDialog();
  });
  requireEl("copyLuaBtn").addEventListener("click", () => {
    copyLua("Lua copied");
    closeSaveDialog();
  });
  requireEl("deleteSaveBtn").addEventListener("click", () => {
    if (!currentSave) return;
    const map = readSaves();
    delete map[saveId(currentSave)];
    writeSaves(map);
    currentSave = "";
    fillLayoutSelect();
    render();
    closeSaveDialog();
    status.textContent = "Save deleted";
  });
  window.addEventListener("pointermove", onMove);
  window.addEventListener("pointerup", onUp);
  window.addEventListener("resize", scaleStage);
  fillLayoutSelect();
  render();
  scaleStage();
}
