export type Point =
  | "CENTER"
  | "BOTTOM"
  | "TOP"
  | "TOPRIGHT"
  | "BOTTOMRIGHT"
  | "TOPLEFT"
  | "BOTTOMLEFT"
  | "RIGHT"
  | "LEFT";

export type HtmlBox = {
  left: number;
  top: number;
  width: number;
  height: number;
};

export type SwingHands = {
  main?: boolean;
  off?: boolean;
  range?: boolean;
};

export type WidgetCfg = {
  id: string;
  kind?: string;
  label?: string;
  persist?: boolean;
  lock?: string;
  target?: string;
  point?: Point | string;
  x: number;
  y: number;
  width?: number;
  height?: number;
  html: HtmlBox;
  buttons?: number;
  columns?: number;
  buttonSize?: number;
  hands?: SwingHands;
};

export type ClassPack = {
  bars: WidgetCfg[];
  chrome: WidgetCfg[];
};

export type LayoutDump = {
  screen: { width: number; height: number };
  grid: number;
  classes: Record<string, ClassPack>;
};

export type PatchEntry = {
  point: string;
  relativeTo: string;
  relativePoint: string;
  x: number;
  y: number;
  target: string;
  width?: number;
  height?: number;
  buttons?: number;
  columns?: number;
};

export type Patch = {
  classFile: string;
  layout: Record<string, PatchEntry>;
};

export type WidgetSnapshot = {
  point: string;
  x: number;
  y: number;
  width: number;
  height: number;
  columns?: number;
};

export type NamedSave = {
  name: string;
  classFile: string;
  widgets: Record<string, WidgetSnapshot>;
};
