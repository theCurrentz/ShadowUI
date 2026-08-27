export type Scope = "global" | "class" | "character";
export type Tab = "account" | "character";
export type Source = "existing" | "plan" | "hybrid" | "ingame";
export type ScopeFilter = "all" | Scope;

export type WowClass =
  | "ALL"
  | "WARRIOR"
  | "PALADIN"
  | "HUNTER"
  | "ROGUE"
  | "PRIEST"
  | "SHAMAN"
  | "MAGE"
  | "WARLOCK"
  | "DRUID";

export type Macro = {
  id: string;
  name: string;
  scope: Scope;
  class: WowClass;
  spec: string;
  character?: string;
  tab: Tab;
  icon: string;
  group: string;
  source: Source;
  body: string;
  chars: number;
  notes?: string;
  labelDropped?: boolean;
};

export type Group = {
  id: string;
  title: string;
  class: WowClass;
  spec: string;
  tab: Tab;
  scope: Scope;
  character?: string;
  description: string;
  macroIds: string[];
  count: number;
};

export type Catalog = {
  version: number;
  limits: { account: number; character: number; bodyChars: number; nameChars: number };
  iconCdn: string;
  iconNote: string;
  groups: Group[];
  macros: Macro[];
};

export function scopeLabel(scope: Scope, classId: string, spec: string, toon?: string): string {
  if (scope === "character") {
    return ["character-specific", classId, spec, toon].filter(Boolean).join(" ");
  }
  if (scope === "class") return `class-specific ${classId} ${spec}`;
  return `global ${classId} ${spec}`;
}
