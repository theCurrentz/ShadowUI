import {
  useEffect,
  useLayoutEffect,
  useReducer,
  useRef,
  useState,
  type DragEvent as ReactDragEvent,
  type MouseEvent as ReactMouseEvent,
} from "react";
import { flushSync } from "react-dom";
import { createRoot, type Root } from "react-dom/client";
import {
  ArrowRightLeft,
  BookOpen,
  Copy,
  Download,
  Keyboard,
  Layers3,
  Library,
  RefreshCw,
  Save,
  Trash2,
  Upload,
  Users,
  X,
} from "lucide-react";
import type { Catalog, Group, Macro, ScopeFilter, Tab, WowClass } from "./types";
import { scopeLabel } from "./types";
import { CLASS_META, iconUrl, onIconError } from "./icons";
import { exportCache, exportGroupText } from "./export";
import {
  PICKUP_MIME,
  pickupFromDataTransfer,
  writePickup,
  abilityRefIndex,
  familyActionIds,
  familyPlaced,
  familyReferenced,
  findFamily,
  findSpell,
  familyIndex,
  linesForClass,
  pickupFromFamily,
  pickupFromRank,
  refsForFamily,
  slotTip,
  spellActionId,
  type Pickup,
  type SlotTip,
  type SpellFamily,
  type SpellRank,
  type Spellbook,
} from "./spellbook";
import { pickupClickAction, pickupDropOffBarAction } from "./pickup-gesture";
import { tapFeedback } from "./haptics";
import {
  actionToPickup,
  classActionOverlay,
  copyBarPages,
  copyVariantActions,
  dropOffBar,
  dropOnSlot,
  emptyActionStore,
  mergeActionTables,
  overlayForWrite,
  type ActionStore,
  type ActionValue,
} from "./deck-edit";
import {
  describeOwner,
  dropMacro,
  findNameOwner,
  loadGroupIds,
  renameMacro,
  setMacroBody,
} from "./catalog";
import { mergeLive, type LiveCharacter, type SyncResponse } from "./merge";
import {
  actionIdsOnBars,
  applyActionKey,
  assignedKeyLabel,
  bindsForActions,
  canonicalKey,
  classKeyCollisions,
  commentKey,
  pageLabel,
  pageLabels,
  resolveHud,
  setCommentKey,
  type HudButton,
  type KeyCollision,
} from "./binds";
import type { BarCfg, ClassSpec } from "./parse-defaults";
import { mergeActions, shortHotkey } from "./parse-defaults";
import {
  rosterKey,
  sortRoster,
  type RosterCharacter,
} from "./roster";
import {
  applySlotBind,
  baseOverlay,
  bindKeydownAction,
  classOverlay,
  emptyKeybindStore,
  stackBinds,
  wowKeyFromMouseEvent,
  wowKeyFromWheelEvent,
  type KeybindStore,
} from "./keybind-edit";

const FALLBACK: WowClass = "WARRIOR";
const AUTOSAVE_MS = 500;
const SCOPE_CHIPS: { id: ScopeFilter; label: string }[] = [
  { id: "all", label: "All" },
  { id: "global", label: "Global" },
  { id: "class", label: "Class" },
  { id: "character", label: "Character" },
];

type View = "library" | "loaded" | "spellbook" | "characters";

type State = {
  classId: WowClass;
  scope: ScopeFilter;
  toon: string;
  accountName: string;
  liveKey: string;
  groupId: string;
  tab: Tab;
  selectedId: string;
  loadedAccount: string[];
  loadedCharacter: string[];
  workingAccount: boolean;
  workingCharacter: boolean;
  status: string;
  view: View;
  variant: string;
  stance: number;
  keybindMode: boolean;
  spellLine: number;
};

type Model = State & {
  base: Catalog;
  catalog: Catalog;
  live: SyncResponse | null;
  bindStore: KeybindStore;
  actionStore: ActionStore;
  heldPickup?: Pickup;
};

type Bucket = { group: Group; macros: Macro[] };

export type MountOpts = {
  base: Catalog;
  catalog: Catalog;
  live: SyncResponse | null;
  accountName: string;
  toon: LiveCharacter | undefined;
  accountIds: string[];
  characterIds: string[];
  notes: string[];
  baseLayout: Record<string, BarCfg>;
  baseKeybinds: Record<string, string>;
  classSpecs: Record<string, ClassSpec>;
  bindStore?: KeybindStore;
  spellbook: Spellbook;
  actionStore?: ActionStore;
  roster?: RosterCharacter[];
};

type HudState = ReturnType<typeof resolveHud>;

function liveKeyOf(character: LiveCharacter): string {
  return `${character.account}/${character.realm}/${character.name}`;
}

function groupsFor(catalog: Catalog, classId: WowClass, scope: ScopeFilter, toon: string): Group[] {
  return catalog.groups.filter((group) => {
    const classOk =
      group.class === classId ||
      (classId !== "ALL" && group.class === "ALL" && group.scope === "global");
    if (!classOk) return false;
    if (scope !== "all" && group.scope !== scope) return false;
    if (toon && group.character !== toon) return false;
    return true;
  });
}

function toonsFor(catalog: Catalog, classId: WowClass): string[] {
  const names = new Set<string>();
  for (const group of catalog.groups) {
    if (group.class === classId && group.character) names.add(group.character);
  }
  return [...names].sort();
}

function macrosIn(catalog: Catalog, ids: string[]): Macro[] {
  const byId = new Map(catalog.macros.map((macro) => [macro.id, macro]));
  return ids.map((id) => byId.get(id)).filter((macro): macro is Macro => Boolean(macro));
}

function bucketsFor(catalog: Catalog, ids: string[]): Bucket[] {
  const byId = new Map(catalog.macros.map((macro) => [macro.id, macro]));
  const groupById = new Map(catalog.groups.map((group) => [group.id, group]));
  const order: string[] = [];
  const map = new Map<string, Macro[]>();
  for (const id of ids) {
    const macro = byId.get(id);
    if (!macro) continue;
    const groupId = macro.group || "unknown";
    if (!map.has(groupId)) {
      map.set(groupId, []);
      order.push(groupId);
    }
    map.get(groupId)!.push(macro);
  }
  return order.map((groupId) => {
    const macros = map.get(groupId)!;
    const group = groupById.get(groupId) ?? {
      id: groupId,
      title: groupId,
      class: "ALL" as WowClass,
      spec: "all",
      tab: macros[0]?.tab ?? "account",
      scope: "class" as const,
      description: "",
      macroIds: macros.map((macro) => macro.id),
      count: macros.length,
    };
    return { group, macros };
  });
}

function parseQuery(): {
  classId: WowClass;
  scope: ScopeFilter;
  toon: string;
  view: View;
  variant: string;
} {
  const query = new URLSearchParams(location.search);
  const rawClass = query.get("class")?.toUpperCase();
  const classId =
    rawClass && CLASS_META.some((entry) => entry.id === rawClass)
      ? (rawClass as WowClass)
      : FALLBACK;
  const rawScope = query.get("scope");
  const scope: ScopeFilter =
    rawScope === "global" || rawScope === "class" || rawScope === "character"
      ? rawScope
      : "all";
  const rawView = query.get("view");
  const view: View =
    rawView === "loaded" || rawView === "spellbook" || rawView === "characters"
      ? rawView
      : "library";
  return {
    classId,
    scope,
    toon: query.get("toon") ?? "",
    view,
    variant: query.get("variant") ?? "",
  };
}

function setQuery(state: State): void {
  const url = new URL(location.href);
  url.searchParams.set("class", state.classId);
  if (state.scope === "all") url.searchParams.delete("scope");
  else url.searchParams.set("scope", state.scope);
  if (state.toon) url.searchParams.set("toon", state.toon);
  else url.searchParams.delete("toon");
  if (state.variant) url.searchParams.set("variant", state.variant);
  else url.searchParams.delete("variant");
  if (state.view === "library") url.searchParams.delete("view");
  else url.searchParams.set("view", state.view);
  history.replaceState(null, "", url);
}

async function copyText(text: string): Promise<void> {
  await navigator.clipboard.writeText(text);
}

function download(name: string, text: string): void {
  const blob = new Blob([text], { type: "text/plain" });
  const anchor = document.createElement("a");
  anchor.href = URL.createObjectURL(blob);
  anchor.download = name;
  anchor.click();
  URL.revokeObjectURL(anchor.href);
}

function pickVariant(opts: MountOpts, classId: WowClass, requested: string): string {
  const names = opts.classSpecs[classId]?.variants.map((variant) => variant.name) ?? [];
  if (requested && names.includes(requested)) return requested;
  return names[0] ?? "";
}

function createModel(opts: MountOpts): Model {
  const start = parseQuery();
  const liveClass =
    opts.toon?.class && opts.toon.class !== "ALL" ? opts.toon.class : start.classId;
  const firstGroups = groupsFor(opts.catalog, liveClass, start.scope, start.toon);
  const firstGroup = firstGroups[0] ?? groupsFor(opts.catalog, liveClass, "all", "")[0];
  const model: Model = {
    base: opts.base,
    catalog: opts.catalog,
    live: opts.live,
    bindStore: opts.bindStore ?? emptyKeybindStore(),
    actionStore: opts.actionStore ?? emptyActionStore(),
    classId: liveClass,
    scope: start.scope,
    toon: start.toon,
    accountName: opts.accountName,
    liveKey: opts.toon ? liveKeyOf(opts.toon) : "",
    groupId: firstGroup?.id ?? "",
    tab: opts.characterIds.length ? "character" : (firstGroup?.tab ?? "character"),
    selectedId: opts.characterIds[0] ?? opts.accountIds[0] ?? firstGroup?.macroIds[0] ?? "",
    loadedAccount: [...opts.accountIds],
    loadedCharacter: [...opts.characterIds],
    workingAccount: opts.accountIds.length > 0,
    workingCharacter: opts.characterIds.length > 0,
    status:
      opts.notes.join(" ") ||
      (opts.live
        ? `Synced ${opts.accountIds.length} account and ${opts.characterIds.length} character macros.`
        : ""),
    view: start.view,
    variant: pickVariant(opts, liveClass, start.variant),
    stance: 0,
    keybindMode: false,
    spellLine: linesForClass(opts.spellbook, liveClass)[0]?.skillId ?? 0,
  };
  if (model.view === "spellbook") {
    const line = linesForClass(opts.spellbook, model.classId)[0];
    if (line?.families[0]) {
      model.spellLine = line.skillId;
      model.selectedId = `spell:${line.families[0].maxSpellId}`;
    }
  }
  return model;
}

type IconImageProps = { icon?: string; className?: string };

function IconImage({ icon, className }: IconImageProps) {
  if (!icon) return null;
  return (
    <img
      alt=""
      draggable={false}
      className={className}
      src={iconUrl(icon)}
      onError={(event) => {
        onIconError(event.nativeEvent);
      }}
    />
  );
}

type MacroCardProps = {
  macro: Macro;
  selected: boolean;
  onBar: boolean;
  barKey: string;
  loadedTab?: Tab;
  onSelect: () => void;
  onDelete: () => void;
  onDragStart: (event: ReactDragEvent<HTMLButtonElement>) => void;
};

function MacroCard({
  macro,
  selected,
  onBar,
  barKey,
  loadedTab,
  onSelect,
  onDelete,
  onDragStart,
}: MacroCardProps) {
  return (
    <div
      className={`macro-item${selected ? " is-on" : ""}${onBar ? " is-placed" : ""}`}
    >
      <button
        type="button"
        className="macro-card"
        data-macro={macro.id}
        draggable
        onClick={onSelect}
        onDragStart={onDragStart}
      >
        <IconImage icon={macro.icon} />
        <span className="copy">
          <span className="name">{macro.name}</span>
          <span className="id">{macro.id}</span>
          {onBar && <span className="pill bar">{barKey ? shortHotkey(barKey) : "Bar"}</span>}
          {loadedTab && (
            <span className="pill">{loadedTab === "account" ? "General" : "Character"}</span>
          )}
        </span>
      </button>
      <button
        type="button"
        className="card-del"
        aria-label={`Delete ${macro.name}`}
        onClick={onDelete}
      >
        <Trash2 aria-hidden="true" size={14} />
        <span>Delete</span>
      </button>
    </div>
  );
}

type CollisionWarningProps = {
  collisions: KeyCollision[];
  byId: Map<string, Macro>;
};

function CollisionWarning({ collisions, byId }: CollisionWarningProps) {
  if (!collisions.length) {
    return (
      <section id="bindWarn" className="ok">
        No in-class Keybind collisions.
      </section>
    );
  }
  return (
    <section id="bindWarn" className="bad">
      <div>
        <h3>Class Keybinds</h3>
        <ul>
          {collisions.map((collision) => (
            <li key={collision.key}>
              <strong>{collision.key}</strong>
              {" — "}
              {collision.buttons
                .map((button) => {
                  if (button.macroId) {
                    const macro = byId.get(button.macroId);
                    return macro ? `${macro.name} (${macro.id})` : button.macroId;
                  }
                  return `${button.barId} slot ${button.bindSlot}`;
                })
                .join(", ")}
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}

type HudProps = {
  hud: HudState;
  selectedId: string;
  collideKeys: Set<string>;
  stance: number;
  stanceNames: string[];
  variantNames: string[];
  variant: string;
  classId: WowClass;
  spellbook: Spellbook;
  byId: Map<string, Macro>;
  keybindMode: boolean;
  bindTarget: number | null;
  heldPickup?: Pickup;
  onVariant: (name: string) => void;
  onStance: (index: number) => void;
  onToggleBinds: () => void;
  onSaveBindsBase: () => void;
  onCopyBars: (source: string) => void;
  onCopyPages: (barId: string) => void;
  onBindCapture: (key: string) => void;
  onHoverBind: (slot: number | null) => void;
  onPinBind: (slot: number) => void;
  onSelectAction: (id: string) => void;
  onPlaceHeld: (slot: number) => void;
  consumeSuppressedClick: () => boolean;
  onSlotDragStart: (event: ReactDragEvent<HTMLButtonElement>, button: HudButton) => void;
  onSlotDragEnd: () => void;
  onSlotDrop: (event: ReactDragEvent<HTMLButtonElement>, slot: number) => void;
};

const TIP_GAP = 14;

function placeSlotTip(x: number, y: number, width: number, height: number): { left: number; top: number } {
  const viewW = window.innerWidth;
  const viewH = window.innerHeight;
  let left = x + TIP_GAP;
  let top = y + TIP_GAP;
  if (left + width > viewW - 8) left = x - width - TIP_GAP;
  if (top + height > viewH - 8) top = y - height - TIP_GAP;
  return {
    left: Math.max(8, Math.min(left, viewW - width - 8)),
    top: Math.max(8, Math.min(top, viewH - height - 8)),
  };
}

function SlotTooltip({ tip, x, y }: { tip: SlotTip; x: number; y: number }) {
  const node = useRef<HTMLDivElement>(null);
  const [place, setPlace] = useState(() => placeSlotTip(x, y, 320, 200));
  useLayoutEffect(() => {
    const el = node.current;
    const width = el?.offsetWidth || 320;
    const height = el?.offsetHeight || 200;
    setPlace(placeSlotTip(x, y, width, height));
  }, [x, y, tip]);
  return (
    <div
      id="slotTip"
      ref={node}
      role="tooltip"
      className="slot-tip"
      style={{ left: place.left, top: place.top }}
    >
      <div className="slot-tip-row">
        <span>Keybind</span>
        <strong>{tip.keybind}</strong>
      </div>
      {tip.kind === "macro" && (
        <>
          <div className="slot-tip-row">
            <span>Macro</span>
            <strong>{tip.name}</strong>
          </div>
          {tip.notes ? <p className="slot-tip-notes">{tip.notes}</p> : null}
          {tip.body ? <pre className="slot-tip-body">{tip.body}</pre> : null}
        </>
      )}
      {tip.kind === "spell" && (
        <>
          <div className="slot-tip-row">
            <span>Ability</span>
            <strong>
              {tip.name}
              {tip.rank ? ` · ${tip.rank}` : ""}
            </strong>
          </div>
          {tip.abilities[0]?.description ? (
            <p className="slot-tip-notes">{tip.abilities[0].description}</p>
          ) : null}
        </>
      )}
      {tip.kind === "empty" && <p className="slot-tip-empty">Empty Action Slot</p>}
      {tip.kind === "macro" && tip.abilities.length > 0 && (
        <ul className="slot-tip-abilities">
          {tip.abilities.map((ability) => (
            <li key={ability.name}>
              <strong>{ability.name}</strong>
              {ability.description ? <p>{ability.description}</p> : null}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

function ActionBars({
  hud,
  selectedId,
  collideKeys,
  stance,
  stanceNames,
  variantNames,
  variant,
  classId,
  spellbook,
  byId,
  keybindMode,
  bindTarget,
  heldPickup,
  onVariant,
  onStance,
  onToggleBinds,
  onSaveBindsBase,
  onCopyBars,
  onCopyPages,
  onBindCapture,
  onHoverBind,
  onPinBind,
  onSelectAction,
  onPlaceHeld,
  consumeSuppressedClick,
  onSlotDragStart,
  onSlotDragEnd,
  onSlotDrop,
}: HudProps) {
  const [copySource, setCopySource] = useState(
    variantNames.find((name) => name !== variant) ?? "",
  );
  const [tipState, setTipState] = useState<{
    tip: SlotTip;
    x: number;
    y: number;
    slot: number;
  } | null>(null);
  useEffect(() => {
    setCopySource(variantNames.find((name) => name !== variant) ?? "");
  }, [variant, variantNames.join("|")]);
  const families = familyIndex(spellbook, classId);

  const collideSlots = new Set(
    hud.buttons
      .filter((button) => button.key && collideKeys.has(canonicalKey(button.key)))
      .map((button) => `${button.barId}:${button.index}`),
  );
  const byBar = new Map<string, HudButton[]>();
  for (const button of hud.buttons) {
    const list = byBar.get(button.barId) ?? [];
    list.push(button);
    byBar.set(button.barId, list);
  }
  const placed: {
    barId: string;
    left: number;
    bottom: number;
    width: number;
    height: number;
    cols: number;
    size: number;
  }[] = [];
  let minX = 0;
  let maxX = 0;
  let maxY = 40;
  for (const [barId, config] of Object.entries(hud.layout)) {
    if (!config.enabled) continue;
    const size = config.buttonSize;
    const cols = Math.max(1, Math.min(config.columns, config.buttons));
    const width = cols * size;
    const height = Math.ceil(config.buttons / cols) * size;
    const left = config.x - width / 2;
    const bottom = config.y;
    const pageHead = (config.stancePages?.length ?? 0) > 1 ? 22 : 0;
    minX = Math.min(minX, left);
    maxX = Math.max(maxX, left + width);
    maxY = Math.max(maxY, bottom + height + 16 + pageHead);
    placed.push({ barId, left, bottom, width, height, cols, size });
  }
  const pad = 16;
  const originX = -minX + pad;
  const stageWidth = Math.max(400, maxX - minX + pad * 2);
  const stageHeight = maxY + pad;

  return (
    <section id="hud" className={keybindMode ? "is-edit" : undefined}>
      <div id="hudHead">
        <h2>Action Bars</h2>
        <nav id="variantNav" aria-label="Variant">
          {variantNames.map((name) => (
            <button
              type="button"
              className={`chip${name === variant ? " is-on" : ""}`}
              key={name}
              onClick={() => onVariant(name)}
            >
              {name}
            </button>
          ))}
        </nav>
        {stanceNames.length > 1 && (
          <nav id="stanceNav" aria-label="Stance">
            {stanceNames.map((name, index) => (
              <button
                type="button"
                className={`chip${index === stance ? " is-on" : ""}`}
                key={name}
                onClick={() => onStance(index)}
              >
                {name}
              </button>
            ))}
          </nav>
        )}
        <button
          type="button"
          className={`btn${keybindMode ? " btn-primary" : ""}`}
          id="bindMode"
          onClick={onToggleBinds}
        >
          <Keyboard aria-hidden="true" size={16} />
          {keybindMode ? "Keybind edit on" : "Keybind edit"}
        </button>
        <button type="button" className="btn" id="saveBindsBase" onClick={onSaveBindsBase}>
          <Save aria-hidden="true" size={16} />
          Save keybinds as default
        </button>
        {variantNames.length > 1 && (
          <>
            <label className="copy-bars">
              Copy bars from
              <select
                id="copyFromVariant"
                value={copySource}
                onChange={(event) => setCopySource(event.target.value)}
              >
                {variantNames
                  .filter((name) => name !== variant)
                  .map((name) => (
                    <option value={name} key={name}>
                      {name}
                    </option>
                  ))}
              </select>
            </label>
            <button
              type="button"
              className="btn"
              id="copyBars"
              onClick={() => onCopyBars(copySource)}
            >
              <ArrowRightLeft aria-hidden="true" size={16} />
              Copy bars
            </button>
          </>
        )}
      </div>
      {keybindMode && (
        <>
          <p id="bindHelp">
            Click a slot, then press a key. Escape clears. Chrome Gemini steals Ctrl+G: type{" "}
            <kbd>CTRL-G</kbd> and press Enter.
          </p>
          <label id="bindType">
            Type a key{" "}
            <input
              id="bindCapture"
              spellCheck={false}
              autoComplete="off"
              placeholder="CTRL-G"
              onKeyDown={(event) => {
                if (event.key !== "Enter") return;
                event.preventDefault();
                const key = canonicalKey(event.currentTarget.value);
                if (key) onBindCapture(key);
              }}
            />
          </label>
        </>
      )}
      <div id="hudFrame" style={{ height: stageHeight }}>
        <div id="hudStage" style={{ width: stageWidth, height: stageHeight }}>
          {placed.map((bar) => {
            const pages = hud.layout[bar.barId]?.stancePages ?? [];
            const copyPages = pages.length > 1;
            const sourceName = copyPages
              ? pageLabel(pages[Math.max(0, Math.min(stance, pages.length - 1))]!, classId)
              : "";
            return (
            <div
              className="hud-bar-wrap"
              key={bar.barId}
              style={{
                left: bar.left + originX,
                bottom: bar.bottom,
                width: bar.width,
                height: bar.height,
              }}
            >
              {copyPages && (
                <button
                  type="button"
                  className="hud-copy-pages"
                  title={`Copy ${sourceName} onto the other ${bar.barId} pages`}
                  onClick={() => onCopyPages(bar.barId)}
                >
                  <Copy aria-hidden="true" size={12} />
                  Copy to other pages
                </button>
              )}
            <div
              className="hud-bar"
              style={{
                width: bar.width,
                height: bar.height,
                gridTemplateColumns: `repeat(${bar.cols}, ${bar.size}px)`,
              }}
            >
              {(byBar.get(bar.barId) ?? []).map((button) => {
                const macro = button.action ? byId.get(button.action.id) : undefined;
                const actionId = button.action?.id ?? "";
                const name = macro?.name ?? button.action?.name;
                const icon = macro?.icon ?? button.action?.icon;
                const rank = button.action?.rank ? ` · ${button.action.rank}` : "";
                const title = name
                  ? `${name}${rank} · ${button.key || "unbound"} · slot ${button.actionSlot}`
                  : `${bar.barId} slot ${button.actionSlot}${button.key ? ` · ${button.key}` : ""}`;
                const classes = [
                  "hud-slot",
                  name ? "has-action" : "",
                  actionId && actionId === selectedId ? "is-on" : "",
                  collideSlots.has(`${button.barId}:${button.index}`) ? "is-hit" : "",
                  keybindMode && bindTarget === button.bindSlot ? "is-bind" : "",
                ]
                  .filter(Boolean)
                  .join(" ");
                return (
                  <button
                    type="button"
                    className={classes}
                    aria-label={title}
                    aria-describedby={tipState?.slot === button.actionSlot ? "slotTip" : undefined}
                    data-bind-slot={button.bindSlot}
                    data-action-slot={button.actionSlot}
                    data-macro={actionId || undefined}
                    draggable={Boolean(button.action)}
                    key={`${button.barId}:${button.index}`}
                    onMouseEnter={(event) => {
                      onHoverBind(button.bindSlot);
                      setTipState({
                        tip: slotTip({
                          key: button.key,
                          action: button.action,
                          macro,
                          families,
                        }),
                        x: event.clientX,
                        y: event.clientY,
                        slot: button.actionSlot,
                      });
                    }}
                    onMouseMove={(event) => {
                      setTipState((current) =>
                        current && current.slot === button.actionSlot
                          ? { ...current, x: event.clientX, y: event.clientY }
                          : current,
                      );
                    }}
                    onMouseLeave={() => {
                      onHoverBind(null);
                      setTipState(null);
                    }}
                    onClick={(event) => {
                      event.stopPropagation();
                      const suppressAfterDrop = consumeSuppressedClick();
                      const action = pickupClickAction({
                        holding: Boolean(heldPickup),
                        keybindMode,
                        insideHudSlot: true,
                        suppressAfterDrop,
                      });
                      if (action === "place-on-slot") {
                        onPlaceHeld(button.actionSlot);
                        return;
                      }
                      if (keybindMode) {
                        onPinBind(button.bindSlot);
                        return;
                      }
                      if (actionId) onSelectAction(actionId);
                    }}
                    onDragStart={(event) => {
                      setTipState(null);
                      onSlotDragStart(event, button);
                    }}
                    onDragEnd={onSlotDragEnd}
                    onDragEnter={(event) => event.preventDefault()}
                    onDragOver={(event) => {
                      event.preventDefault();
                      event.currentTarget.classList.add("is-drop");
                      if (event.dataTransfer) {
                        event.dataTransfer.dropEffect =
                          event.dataTransfer.effectAllowed === "move" ? "move" : "copy";
                      }
                    }}
                    onDragLeave={(event) => event.currentTarget.classList.remove("is-drop")}
                    onDrop={(event) => {
                      event.preventDefault();
                      event.stopPropagation();
                      event.currentTarget.classList.remove("is-drop");
                      onSlotDrop(event, button.actionSlot);
                    }}
                  >
                    <IconImage icon={icon} />
                    {button.key && <span className="hot">{shortHotkey(button.key)}</span>}
                  </button>
                );
              })}
            </div>
            </div>
            );
          })}
        </div>
      </div>
      {tipState && !heldPickup && <SlotTooltip tip={tipState.tip} x={tipState.x} y={tipState.y} />}
    </section>
  );
}

type InspectorProps = {
  selected?: Macro;
  spell?: SpellRank;
  catalog: Catalog;
  keyValue: string;
  keyMeta: string;
  canAssignSpell: boolean;
  referencedBy: Macro[];
  onOpenMacro: (macro: Macro) => void;
  onQueueName: (id: string, value: string) => void;
  onQueueBody: (id: string, value: string) => void;
  onFlushName: (id: string, value: string) => void;
  onFlushBody: (id: string, value: string) => void;
  onCommitKey: (id: string, value: string, body: string) => void;
  onCopyBody: () => void;
  onCopyGroup: () => void;
  onDelete: () => void;
};

function Inspector({
  selected,
  spell,
  catalog,
  keyValue,
  keyMeta,
  canAssignSpell,
  referencedBy,
  onOpenMacro,
  onQueueName,
  onQueueBody,
  onFlushName,
  onFlushBody,
  onCommitKey,
  onCopyBody,
  onCopyGroup,
  onDelete,
}: InspectorProps) {
  const recordId = selected?.id ?? (spell ? spellActionId(spell.spellId) : "");
  const initialBody = selected
    ? keyValue
      ? setCommentKey(selected.body, keyValue)
      : selected.body
    : "";
  const [name, setName] = useState(selected?.name ?? spell?.name ?? "");
  const [body, setBody] = useState(initialBody);
  const [key, setKey] = useState(keyValue);

  useEffect(() => {
    setName(selected?.name ?? spell?.name ?? "");
    setBody(
      selected ? (keyValue ? setCommentKey(selected.body, keyValue) : selected.body) : "",
    );
    setKey(keyValue);
  }, [recordId, selected?.name, selected?.body, keyValue, spell?.name]);

  if (spell) {
    const id = spellActionId(spell.spellId);
    return (
      <>
        <h2>Ability</h2>
        <label>
          Name
          <input id="nameField" value={name} disabled readOnly />
        </label>
        <label>
          Assigned keybind
          <input
            id="keyField"
            value={key}
            disabled={!canAssignSpell}
            spellCheck={false}
            onChange={(event) => setKey(event.target.value)}
            onKeyDown={(event) => {
              if (event.key !== "Enter") return;
              event.preventDefault();
              onCommitKey(id, key, "");
            }}
            onBlur={() => onCommitKey(id, key, "")}
          />
        </label>
        <p id="keyMeta">{keyMeta}</p>
        <div id="iconRow">
          <div className="slot-preview">
            <IconImage icon={spell.icon} />
          </div>
          <dl>
            <div><dt>id</dt><dd>{id}</dd></div>
            <div><dt>spell</dt><dd>{spell.spellId}</dd></div>
            <div><dt>rank</dt><dd>{spell.rank || "—"}</dd></div>
            <div><dt>level</dt><dd>{spell.level}</dd></div>
            <div><dt>icon</dt><dd>{spell.icon || "—"}</dd></div>
          </dl>
        </div>
        <label>
          Body
          <textarea id="bodyField" disabled value="" readOnly />
        </label>
        <div id="count" />
        <p id="notes">
          Drag this rank, or the family above it, onto an Action Bar slot. The sidecar does not
          write in-game Action Slots.
        </p>
        {referencedBy.length > 0 && (
          <div className="ref-list">
            <p>Catalog macros that cast this ability:</p>
            <ul>
              {referencedBy.map((macro) => (
                <li key={macro.id}>
                  <button
                    type="button"
                    aria-label={`Open ${macro.name}`}
                    onClick={() => onOpenMacro(macro)}
                  >
                    {macro.name}
                  </button>
                </li>
              ))}
            </ul>
          </div>
        )}
        <div className="actions">
          <button type="button" className="btn" id="copyBody" disabled>
            <Copy aria-hidden="true" size={16} /> Copy body
          </button>
          <button type="button" className="btn" id="copyGroup" disabled>
            <Copy aria-hidden="true" size={16} /> Copy group
          </button>
          <button type="button" className="btn danger" id="deleteOne" disabled>
            <Trash2 aria-hidden="true" size={16} /> Delete
          </button>
        </div>
      </>
    );
  }

  return (
    <>
      <h2>Macro</h2>
      <label>
        Name
        <input
          id="nameField"
          maxLength={catalog.limits.nameChars}
          value={name}
          disabled={!selected}
          onChange={(event) => {
            const value = event.target.value;
            setName(value);
            if (selected) onQueueName(selected.id, value);
          }}
          onKeyDown={(event) => {
            if (event.key !== "Enter" || !selected) return;
            event.preventDefault();
            onFlushName(selected.id, name);
          }}
          onBlur={() => {
            if (selected) onFlushName(selected.id, name);
          }}
        />
      </label>
      <label>
        Assigned keybind
        <input
          id="keyField"
          value={key}
          disabled={!selected}
          spellCheck={false}
          onChange={(event) => {
            const value = event.target.value;
            setKey(value);
            if (!selected) return;
            const nextBody = setCommentKey(body, value);
            setBody(nextBody);
            onQueueBody(selected.id, nextBody);
          }}
          onKeyDown={(event) => {
            if (event.key !== "Enter" || !selected) return;
            event.preventDefault();
            onCommitKey(selected.id, key, body);
          }}
          onBlur={() => {
            if (selected) onCommitKey(selected.id, key, body);
          }}
        />
      </label>
      <p id="keyMeta">{keyMeta}</p>
      <div id="iconRow">
        <div className="slot-preview">
          <IconImage icon={selected?.icon} />
        </div>
        <dl>
          <div><dt>id</dt><dd>{selected?.id ?? "—"}</dd></div>
          <div>
            <dt>scope</dt>
            <dd>
              {selected
                ? scopeLabel(selected.scope, selected.class, selected.spec, selected.character)
                : "—"}
            </dd>
          </div>
          <div><dt>toon</dt><dd>{selected?.character ?? "—"}</dd></div>
          <div><dt>source</dt><dd>{selected?.source ?? "—"}</dd></div>
          <div><dt>icon</dt><dd>{selected?.icon ?? "—"}</dd></div>
        </dl>
      </div>
      <label>
        Body
        <textarea
          id="bodyField"
          maxLength={catalog.limits.bodyChars}
          value={body}
          disabled={!selected}
          onChange={(event) => {
            const value = event.target.value;
            setBody(value);
            if (selected) onQueueBody(selected.id, value);
            if (!keyValue) setKey(commentKey(value));
          }}
          onKeyDown={(event) => {
            if (!(event.metaKey || event.ctrlKey) || event.key !== "Enter" || !selected) return;
            event.preventDefault();
            onFlushBody(selected.id, body);
          }}
          onBlur={() => {
            if (selected) onFlushBody(selected.id, body);
          }}
        />
      </label>
      <div
        id="count"
        className={body.length > catalog.limits.bodyChars - 20 ? "tight" : undefined}
      >
        {body.length}/{catalog.limits.bodyChars}
      </div>
      <p id="notes">{selected?.notes ?? ""}</p>
      <div className="actions">
        <button type="button" className="btn" id="copyBody" onClick={onCopyBody}>
          <Copy aria-hidden="true" size={16} /> Copy body
        </button>
        <button type="button" className="btn" id="copyGroup" onClick={onCopyGroup}>
          <Copy aria-hidden="true" size={16} /> Copy group
        </button>
        <button
          type="button"
          className="btn danger"
          id="deleteOne"
          disabled={!selected}
          onClick={onDelete}
        >
          <Trash2 aria-hidden="true" size={16} /> Delete
        </button>
      </div>
    </>
  );
}

type AppProps = { rootElement: HTMLElement; opts: MountOpts };

export function MacroCursorApp({ rootElement, opts }: AppProps) {
  const modelRef = useRef<Model | null>(null);
  if (!modelRef.current) modelRef.current = createModel(opts);
  const model = modelRef.current;
  const [, rerender] = useReducer((value: number) => value + 1, 0);
  const pendingName = useRef<{ id: string; value: string } | undefined>(undefined);
  const pendingBody = useRef<{ id: string; value: string } | undefined>(undefined);
  const autosaveTimer = useRef<number | undefined>(undefined);
  const flushBusy = useRef(false);
  const flushRef = useRef<() => Promise<void>>(async () => undefined);
  const hoverBindSlot = useRef<number | null>(null);
  const pinnedBindSlot = useRef<number | null>(null);
  const dragFromSlot = useRef<number | undefined>(undefined);
  const suppressPickupClick = useRef(false);
  const pendingScroll = useRef(false);
  const pickupCursor = useRef<HTMLDivElement>(null);
  const callbacks = useRef<{
    captureBind: (raw: string | null) => Promise<void>;
    clearHeld: () => void;
    deleteSelected: () => Promise<void>;
  }>({
    captureBind: async () => undefined,
    clearHeld: () => undefined,
    deleteSelected: async () => undefined,
  });

  const byId = new Map(model.catalog.macros.map((macro) => [macro.id, macro]));
  const selected = byId.get(model.selectedId);
  const spellHit = selected
    ? undefined
    : findSpell(
        opts.spellbook,
        model.classId,
        Number(/^spell:(\d+)$/.exec(model.selectedId)?.[1] ?? 0),
      );

  function update(): void {
    flushSync(() => {
      rerender();
    });
  }

  function classSpec(): ClassSpec | undefined {
    return opts.classSpecs[model.classId];
  }

  function activeVariant() {
    return classSpec()?.variants.find((variant) => variant.name === model.variant);
  }

  function hudState(): HudState | undefined {
    const spec = classSpec();
    if (!spec) return undefined;
    return resolveHud(
      opts.baseLayout,
      spec,
      activeVariant(),
      model.stance,
      classOverlay(model.bindStore, model.classId),
      classActionOverlay(model.actionStore, model.classId, model.variant),
      opts.baseKeybinds,
      baseOverlay(model.bindStore),
    );
  }

  function lookupIds(id: string): string[] {
    if (!id.startsWith("spell:")) return [id];
    const spellId = Number(id.slice(6));
    const family = findFamily(opts.spellbook, model.classId, spellId);
    if (family && family.maxSpellId === spellId) return familyActionIds(family);
    return [id];
  }

  function bindsForId(id: string) {
    const hud = hudState();
    if (!hud) return [];
    return bindsForActions(hud.layout, hud.actions, hud.keybinds, lookupIds(id));
  }

  function placedSet(): Set<string> {
    const hud = hudState();
    return hud ? actionIdsOnBars(hud.actions) : new Set();
  }

  function keybindValue(macro: Macro | undefined, actionId?: string): string {
    const id = actionId ?? macro?.id;
    if (!id) return "";
    const hud = hudState();
    if (!hud) return macro ? commentKey(macro.body) : "";
    return assignedKeyLabel(bindsForId(id), macro ? commentKey(macro.body) : "");
  }

  function keybindMeta(macro: Macro | undefined, actionId?: string): string {
    const id = actionId ?? macro?.id;
    if (!id) return "";
    const hud = hudState();
    if (!hud) return "No ShadowUI Class Keybinds for this class.";
    const binds = bindsForId(id);
    if (!binds.length) {
      return macro ? "Not on the Action Deck. Comment key only." : "Not on the Action Bars.";
    }
    return binds
      .map((bind) => {
        const stanceName = bind.stance ? ` ${bind.stance}` : "";
        return `${bind.barId} slot ${bind.actionSlot}${stanceName}${
          bind.key ? ` · ${bind.key}` : " · unbound"
        }`;
      })
      .join(" · ");
  }

  function pickGroup(
    classId: WowClass,
    scope: ScopeFilter,
    toon: string,
    keepSelection = false,
  ): void {
    const next = groupsFor(model.catalog, classId, scope, toon)[0];
    model.groupId = next?.id ?? "";
    if (keepSelection) return;
    model.tab = next?.tab ?? "character";
    model.selectedId = next?.macroIds[0] ?? "";
  }

  function activeGroup(): Group | undefined {
    return model.catalog.groups.find((group) => group.id === model.groupId);
  }

  function loadedCount(group: Group): number {
    const ids = group.tab === "account" ? model.loadedAccount : model.loadedCharacter;
    const loaded = new Set(ids);
    return group.macroIds.filter((id) => loaded.has(id)).length;
  }

  function loadedTab(id: string): Tab | undefined {
    if (model.loadedAccount.includes(id)) return "account";
    if (model.loadedCharacter.includes(id)) return "character";
    return undefined;
  }

  function activeLiveToon(): LiveCharacter | undefined {
    return model.live?.characters.find((character) => liveKeyOf(character) === model.liveKey);
  }

  function applyMerged(
    accountName: string,
    toon: LiveCharacter | undefined,
    extra: string[] = [],
  ): void {
    if (!model.live) return;
    const next = mergeLive(model.base, model.live, accountName, toon);
    model.catalog = next.catalog;
    model.accountName = accountName;
    model.liveKey = toon ? liveKeyOf(toon) : "";
    model.loadedAccount = next.accountIds;
    model.loadedCharacter = next.characterIds;
    model.workingAccount = next.accountIds.length > 0;
    model.workingCharacter = next.characterIds.length > 0;
    if (toon?.class && toon.class !== "ALL") model.classId = toon.class;
    model.tab = next.characterIds.length ? "character" : "account";
    model.selectedId = next.characterIds[0] ?? next.accountIds[0] ?? "";
    pickGroup(model.classId, model.scope, model.toon, true);
    model.status = [...extra, ...next.notes].join(" ");
  }

  async function resync(): Promise<void> {
    try {
      const response = await fetch("/api/sync");
      if (!response.ok) {
        model.status = "Sync failed.";
        update();
        return;
      }
      model.live = (await response.json()) as SyncResponse;
      const toon =
        activeLiveToon() ??
        model.live.characters.find((character) => character.account === model.accountName);
      applyMerged(model.accountName || model.live.accounts[0]?.account || "", toon, ["Resynced."]);
      update();
    } catch {
      model.status = "Sync failed. Open Macro Cursor with pnpm --dir macro-cursor dev.";
      update();
    }
  }

  function loadGroup(replace: boolean): void {
    const group = activeGroup();
    if (!group) return;
    const cap =
      group.tab === "account" ? model.catalog.limits.account : model.catalog.limits.character;
    const current = group.tab === "account" ? model.loadedAccount : model.loadedCharacter;
    const result = loadGroupIds(current, group.macroIds, model.catalog, cap, replace);
    if (result.error) {
      model.status = `${group.title} ${result.error}`;
      update();
      return;
    }
    if (group.tab === "account") {
      model.loadedAccount = result.ids;
      model.workingAccount = true;
    } else {
      model.loadedCharacter = result.ids;
      model.workingCharacter = true;
    }
    model.tab = group.tab;
    model.selectedId = group.macroIds[0] ?? "";
    model.status = replace
      ? `Replaced ${group.tab} with ${group.title} (${result.ids.length}/${cap}).`
      : `Loaded ${group.title} → ${group.tab} (${result.ids.length}/${cap}).`;
    update();
  }

  function unloadGroup(): void {
    const group = activeGroup();
    if (!group) return;
    const drop = new Set(group.macroIds);
    if (group.tab === "account") {
      model.loadedAccount = model.loadedAccount.filter((id) => !drop.has(id));
    } else {
      model.loadedCharacter = model.loadedCharacter.filter((id) => !drop.has(id));
    }
    model.status = `Unloaded ${group.title}.`;
    update();
  }

  function adoptCatalog(catalog: Catalog): void {
    model.catalog = catalog;
    model.base = catalog;
  }

  async function persistPrune(id: string): Promise<boolean> {
    try {
      const response = await fetch("/api/prune", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id }),
      });
      return response.ok;
    } catch {
      return false;
    }
  }

  async function persistRename(
    id: string,
    name: string,
  ): Promise<{ ok: boolean; catalog?: Catalog; error?: string }> {
    try {
      const response = await fetch("/api/rename", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, name }),
      });
      const payload = (await response.json()) as {
        catalog?: Catalog;
        error?: string;
        owner?: { id: string; group: string; class: string; scope: string };
      };
      if (!response.ok) {
        const owner = payload.owner
          ? `${payload.owner.id} (${payload.owner.group}, ${payload.owner.class}, ${payload.owner.scope})`
          : "";
        return {
          ok: false,
          error: owner
            ? `Name "${name}" is already used by ${owner}.`
            : payload.error || "Rename failed.",
        };
      }
      return { ok: true, catalog: payload.catalog };
    } catch {
      return { ok: false, error: "Rename failed. Run pnpm --dir macro-cursor dev to save." };
    }
  }

  async function commitName(id: string, raw: string): Promise<void> {
    const macro = new Map(model.catalog.macros.map((item) => [item.id, item])).get(id);
    const name = raw.trim();
    if (!macro) return;
    if (!name) {
      model.status = "Name is empty.";
      update();
      return;
    }
    if (name.length > model.catalog.limits.nameChars) {
      model.status = `Name is longer than ${model.catalog.limits.nameChars} characters.`;
      update();
      return;
    }
    if (name === macro.name) return;
    const owner = findNameOwner(model.catalog, name, macro.id);
    if (owner) {
      model.status = `Name "${name}" is already used by ${describeOwner(owner)}.`;
      update();
      return;
    }
    if (macro.source === "ingame") {
      model.catalog = renameMacro(model.catalog, macro.id, name);
      model.status = `Renamed to ${name} in this session. In-game extras are not in the catalog source.`;
      update();
      return;
    }
    const saved = await persistRename(macro.id, name);
    if (!saved.ok || !saved.catalog) {
      model.status = saved.error || "Rename failed.";
      update();
      return;
    }
    adoptCatalog(saved.catalog);
    model.status = `Saved name ${name}.`;
    update();
  }

  async function persistBody(
    id: string,
    body: string,
  ): Promise<{ ok: boolean; catalog?: Catalog; error?: string }> {
    try {
      const response = await fetch("/api/body", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, body }),
      });
      const payload = (await response.json()) as { catalog?: Catalog; error?: string };
      if (!response.ok) return { ok: false, error: payload.error || "Save body failed." };
      return { ok: true, catalog: payload.catalog };
    } catch {
      return {
        ok: false,
        error: "Save body failed. Run pnpm --dir macro-cursor dev to save.",
      };
    }
  }

  async function commitBody(id: string, raw: string): Promise<void> {
    const macro = new Map(model.catalog.macros.map((item) => [item.id, item])).get(id);
    const body = raw.replace(/\r\n/g, "\n");
    if (!macro) return;
    if (body.length > model.catalog.limits.bodyChars) {
      model.status = `Body is longer than ${model.catalog.limits.bodyChars} characters.`;
      update();
      return;
    }
    if (body === macro.body) return;
    if (macro.source === "ingame") {
      model.catalog = setMacroBody(model.catalog, macro.id, body);
      model.status = `Updated ${macro.name} in this session. In-game extras are not in the catalog source.`;
      update();
      return;
    }
    const saved = await persistBody(macro.id, body);
    if (!saved.ok || !saved.catalog) {
      model.status = saved.error || "Save body failed.";
      update();
      return;
    }
    adoptCatalog(saved.catalog);
    model.status = `Saved body for ${macro.name}.`;
    update();
  }

  function scheduleFlush(): void {
    window.clearTimeout(autosaveTimer.current);
    autosaveTimer.current = window.setTimeout(() => {
      void flushRef.current();
    }, AUTOSAVE_MS);
  }

  function queueName(id: string, value: string): void {
    pendingName.current = { id, value };
    scheduleFlush();
  }

  function queueBody(id: string, value: string): void {
    pendingBody.current = { id, value };
    scheduleFlush();
  }

  async function flushEdits(): Promise<void> {
    window.clearTimeout(autosaveTimer.current);
    autosaveTimer.current = undefined;
    if (flushBusy.current) return;
    flushBusy.current = true;
    try {
      while (pendingName.current || pendingBody.current) {
        const nameJob = pendingName.current;
        const bodyJob = pendingBody.current;
        pendingName.current = undefined;
        pendingBody.current = undefined;
        if (nameJob) await commitName(nameJob.id, nameJob.value);
        if (bodyJob) await commitBody(bodyJob.id, bodyJob.value);
      }
    } finally {
      flushBusy.current = false;
      if (pendingName.current || pendingBody.current) void flushRef.current();
    }
  }
  flushRef.current = flushEdits;

  function applyDrop(id: string): void {
    if (pendingName.current?.id === id) pendingName.current = undefined;
    if (pendingBody.current?.id === id) pendingBody.current = undefined;
    model.catalog = dropMacro(model.catalog, id);
    model.base = dropMacro(model.base, id);
    model.loadedAccount = model.loadedAccount.filter((loadedId) => loadedId !== id);
    model.loadedCharacter = model.loadedCharacter.filter((loadedId) => loadedId !== id);
    if (!model.catalog.groups.some((group) => group.id === model.groupId)) {
      pickGroup(model.classId, model.scope, model.toon, true);
    }
    if (!model.catalog.macros.some((macro) => macro.id === model.selectedId)) {
      const group = activeGroup();
      model.selectedId = group?.macroIds[0] ?? model.catalog.macros[0]?.id ?? "";
    }
  }

  async function deleteSelected(id = model.selectedId): Promise<void> {
    const macro = new Map(model.catalog.macros.map((item) => [item.id, item])).get(id);
    if (!macro) {
      model.status = "Select a macro to delete.";
      update();
      return;
    }
    const permanent = macro.source !== "ingame";
    const confirmed = window.confirm(
      permanent
        ? `Remove "${macro.name}" from the catalog permanently?\nIt will not come back on rebuild.`
        : `Remove "${macro.name}" from this session?\nIn-game extras return on resync.`,
    );
    if (!confirmed) return;
    applyDrop(macro.id);
    if (permanent) {
      const saved = await persistPrune(macro.id);
      model.status = saved
        ? `Removed ${macro.name} from the catalog.`
        : `Removed ${macro.name} in this session only. Run pnpm --dir macro-cursor dev to save.`;
    } else {
      model.status = `Removed ${macro.name} from this session.`;
    }
    update();
  }

  function deleteTab(tab: Tab): void {
    const deck = tab === "account" ? model.loadedAccount : model.loadedCharacter;
    if (!deck.length) {
      model.status = `No ${tab} macros to delete.`;
      update();
      return;
    }
    if (!window.confirm(`Delete all ${deck.length} macros on the ${tab} tab?\nThe catalog is unchanged.`)) {
      return;
    }
    const count = deck.length;
    if (tab === "account") model.loadedAccount = [];
    else model.loadedCharacter = [];
    model.status = `Deleted ${count} ${tab} macros from the deck.`;
    update();
  }

  function exportTab(tab: Tab): void {
    const ids = tab === "account" ? model.loadedAccount : model.loadedCharacter;
    const list = macrosIn(model.catalog, ids);
    download(`macros-cache-${tab}.txt`, exportCache(list, tab));
    model.status = `Exported ${list.length} ${tab} macros. Close WoW before you replace macros-cache.txt.`;
    update();
  }

  async function persistOverlay(
    classId: string,
    overlay: Record<string, string | false>,
  ): Promise<boolean> {
    try {
      const response = await fetch("/api/keybinds", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ classId, overlay }),
      });
      if (!response.ok) return false;
      const payload = (await response.json()) as {
        base?: KeybindStore["base"];
        classes?: KeybindStore["classes"];
      };
      model.bindStore = {
        base: payload.base ?? model.bindStore.base,
        classes: payload.classes ?? model.bindStore.classes,
      };
      return true;
    } catch {
      return false;
    }
  }

  async function persistActions(): Promise<boolean> {
    try {
      const overlay = overlayForWrite(
        classActionOverlay(model.actionStore, model.classId, model.variant),
      );
      const response = await fetch("/api/actions", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ classId: model.classId, variant: model.variant, overlay }),
      });
      if (!response.ok) return false;
      const payload = (await response.json()) as {
        classes?: ActionStore["classes"];
        classSpec?: ClassSpec;
      };
      if (payload.classes) model.actionStore = { classes: payload.classes };
      if (payload.classSpec) opts.classSpecs[model.classId] = payload.classSpec;
      return true;
    } catch {
      return false;
    }
  }

  function writeOverlay(overlay: Record<number, ActionValue>): void {
    const variants = {
      ...(model.actionStore.classes[model.classId] ?? {}),
      [model.variant]: overlayForWrite(overlay),
    };
    model.actionStore = {
      classes: { ...model.actionStore.classes, [model.classId]: variants },
    };
  }

  async function saveBindsAsBase(): Promise<void> {
    const hud = hudState();
    if (!hud) return;
    if (!window.confirm("Save these Action Bar keybinds as the default for every class and Variant?")) {
      return;
    }
    const baseOk = await persistOverlay("BASE", hud.keybinds);
    const classOk = await persistOverlay(model.classId, {});
    model.status =
      baseOk && classOk
        ? "Saved Action Bar keybinds as the default for every class."
        : "Saved default keybinds in this session only. Run pnpm --dir macro-cursor dev to save.";
    update();
  }

  async function copyBarsFrom(sourceName: string): Promise<void> {
    const spec = classSpec();
    if (!spec || !sourceName || sourceName === model.variant) return;
    const sourceVariant = spec.variants.find((variant) => variant.name === sourceName);
    const sourceMerged = mergeActionTables(
      mergeActions(spec, sourceVariant),
      classActionOverlay(model.actionStore, model.classId, sourceName),
    );
    const overlay = copyVariantActions(sourceMerged, mergeActions(spec, activeVariant()));
    if (!window.confirm(`Copy all Action Bar slots from ${sourceName} onto ${model.variant}?`)) {
      return;
    }
    writeOverlay(overlay);
    const saved = await persistActions();
    model.status = saved
      ? `Copied ${sourceName} bars onto ${model.variant}.`
      : `Copied ${sourceName} bars onto ${model.variant} in this session. Run pnpm --dir macro-cursor dev to save.`;
    update();
  }

  async function copyPagesOnBar(barId: string): Promise<void> {
    const spec = classSpec();
    const hud = hudState();
    const cfg = hud?.layout[barId];
    const pages = cfg?.stancePages ?? [];
    if (!spec || !cfg || pages.length < 2) return;
    const sourceIndex = Math.max(0, Math.min(model.stance, pages.length - 1));
    const sourceName = pageLabel(pages[sourceIndex]!, model.classId);
    const others = pages
      .filter((_, index) => index !== sourceIndex)
      .map((first) => pageLabel(first, model.classId))
      .join(" and ");
    if (!window.confirm(`Copy ${barId} ${sourceName} onto ${others}?`)) return;
    const overlay = copyBarPages(
      mergeActions(spec, activeVariant()),
      classActionOverlay(model.actionStore, model.classId, model.variant),
      pages,
      sourceIndex,
      cfg.buttons,
    );
    writeOverlay(overlay);
    const saved = await persistActions();
    model.status = saved
      ? `Copied ${barId} ${sourceName} onto ${others}.`
      : `Copied ${barId} ${sourceName} onto ${others} in this session. Run pnpm --dir macro-cursor dev to save.`;
    update();
  }

  async function dropPickup(slot: number, pickup: Pickup): Promise<void> {
    const spec = classSpec();
    if (!spec) return;
    const result = dropOnSlot(
      mergeActions(spec, activeVariant()),
      classActionOverlay(model.actionStore, model.classId, model.variant),
      slot,
      pickup,
    );
    writeOverlay(result.overlay);
    tapFeedback(result.held ? "medium" : "light");
    model.heldPickup = result.held;
    suppressPickupClick.current = true;
    window.setTimeout(() => {
      suppressPickupClick.current = false;
    }, 50);
    if (model.heldPickup && !model.heldPickup.icon) {
      const macro = new Map(model.catalog.macros.map((item) => [item.id, item])).get(
        model.heldPickup.id,
      );
      if (macro) model.heldPickup = { ...model.heldPickup, icon: macro.icon };
      else if (model.heldPickup.kind === "spell") {
        const spell = findSpell(opts.spellbook, model.classId, model.heldPickup.spellId);
        if (spell) model.heldPickup = { ...model.heldPickup, icon: spell.icon };
      }
    }
    model.selectedId = pickup.id;
    model.status = result.held
      ? `Placed ${pickup.name} on slot ${slot}. Holding ${result.held.name}. Drop it on another slot. Escape or click outside clears held.`
      : `Placed ${pickup.name} on slot ${slot}.`;
    update();
    const saved = await persistActions();
    model.status = result.held
      ? saved
        ? `Placed ${pickup.name} on slot ${slot}. Holding ${result.held.name}. Drop it on another slot. Escape or click outside clears held.`
        : `Placed ${pickup.name} on slot ${slot} in this session. Holding ${result.held.name}.`
      : saved
        ? `Placed ${pickup.name} on slot ${slot}.`
        : `Placed ${pickup.name} on slot ${slot} in this session. Run pnpm --dir macro-cursor dev to save.`;
    update();
  }

  async function clearSlot(slot: number): Promise<void> {
    writeOverlay(
      dropOffBar(classActionOverlay(model.actionStore, model.classId, model.variant), slot),
    );
    const saved = await persistActions();
    model.status = saved
      ? `Cleared slot ${slot}.`
      : `Cleared slot ${slot} in this session. Run pnpm --dir macro-cursor dev to save.`;
    update();
  }

  function clearHeld(): void {
    if (!model.heldPickup) return;
    tapFeedback("light");
    model.status = `Cleared held ${model.heldPickup.name}.`;
    model.heldPickup = undefined;
    update();
  }

  function bindTargetSlot(): number | null {
    return hoverBindSlot.current ?? pinnedBindSlot.current;
  }

  async function captureBind(raw: string | null): Promise<void> {
    const slot = bindTargetSlot();
    if (!model.keybindMode || slot === null || !raw) return;
    const spec = classSpec();
    if (!spec) return;
    const shipped = stackBinds(
      opts.baseKeybinds,
      spec.keybinds,
      activeVariant()?.keybinds ?? {},
      baseOverlay(model.bindStore),
    );
    const overlay = classOverlay(model.bindStore, model.classId);
    const next = applySlotBind(overlay, shipped, slot, raw === "ESCAPE" ? false : raw);
    model.bindStore = {
      ...model.bindStore,
      classes: { ...model.bindStore.classes, [model.classId]: next },
    };
    const ok = await persistOverlay(model.classId, next);
    model.status = ok
      ? raw === "ESCAPE"
        ? `Cleared keybind on slot ${slot}.`
        : `Bound ${raw} to slot ${slot}.`
      : `Bound ${raw} in this session only. Run pnpm --dir macro-cursor dev to save.`;
    update();
  }

  async function commitAssignedKey(id: string, value: string, body: string): Promise<void> {
    const hud = hudState();
    const spec = classSpec();
    if (!hud || !spec) return;
    const ids = lookupIds(id);
    if (!bindsForActions(hud.layout, hud.actions, hud.keybinds, ids).length) return;
    const raw = value.trim();
    const nextKey = raw ? canonicalKey(raw) : "";
    const current = assignedKeyLabel(bindsForId(id), "");
    if (nextKey === current) return;
    const next = applyActionKey(
      classOverlay(model.bindStore, model.classId),
      stackBinds(
        opts.baseKeybinds,
        spec.keybinds,
        activeVariant()?.keybinds ?? {},
        baseOverlay(model.bindStore),
      ),
      hud.layout,
      hud.actions,
      ids,
      nextKey,
    );
    model.bindStore = {
      ...model.bindStore,
      classes: { ...model.bindStore.classes, [model.classId]: next },
    };
    const ok = await persistOverlay(model.classId, next);
    if (byId.has(id)) {
      pendingBody.current = { id, value: body };
      await flushEdits();
    }
    model.status = ok
      ? nextKey
        ? `Bound ${nextKey} on the Action Bars.`
        : "Cleared the Action Bar keybind."
      : "Assigned key in this session only. Run pnpm --dir macro-cursor dev to save.";
    tapFeedback("light");
    update();
  }

  callbacks.current = { captureBind, clearHeld, deleteSelected: () => deleteSelected() };

  useEffect(() => {
    let lightRaf = 0;
    function onKeydown(event: KeyboardEvent): void {
      const current = modelRef.current!;
      const target = event.target as HTMLElement | null;
      const typing = target && (target.tagName === "INPUT" || target.tagName === "TEXTAREA");
      if (!current.keybindMode) {
        if (event.key === "Escape" && current.heldPickup) {
          event.preventDefault();
          callbacks.current.clearHeld();
          return;
        }
        if (event.key === "Delete" && !typing) {
          event.preventDefault();
          void callbacks.current.deleteSelected();
        }
        return;
      }
      if (typing) return;
      const action = bindKeydownAction(event, true, hoverBindSlot.current ?? pinnedBindSlot.current);
      if (action.preventDefault) {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
      }
      if (action.key) void callbacks.current.captureBind(action.key);
    }
    function onKeyup(event: KeyboardEvent): void {
      if (!modelRef.current!.keybindMode) return;
      if (
        hoverBindSlot.current === null &&
        pinnedBindSlot.current === null &&
        !(event.ctrlKey || event.metaKey || event.altKey)
      ) {
        return;
      }
      event.preventDefault();
      event.stopPropagation();
    }
    function onMousedown(event: MouseEvent): void {
      if (
        !modelRef.current!.keybindMode ||
        (hoverBindSlot.current === null && pinnedBindSlot.current === null)
      ) {
        return;
      }
      const key = wowKeyFromMouseEvent(event);
      if (!key) return;
      event.preventDefault();
      event.stopPropagation();
      void callbacks.current.captureBind(key);
    }
    function onWheel(event: WheelEvent): void {
      if (
        !modelRef.current!.keybindMode ||
        (hoverBindSlot.current === null && pinnedBindSlot.current === null)
      ) {
        return;
      }
      const key = wowKeyFromWheelEvent(event);
      if (!key) return;
      event.preventDefault();
      void callbacks.current.captureBind(key);
    }
    function onContextMenu(event: MouseEvent): void {
      if (
        modelRef.current!.keybindMode &&
        (hoverBindSlot.current !== null || pinnedBindSlot.current !== null)
      ) {
        event.preventDefault();
      }
    }
    function onMousemove(event: MouseEvent): void {
      const x = event.clientX;
      const y = event.clientY;
      if (!lightRaf) {
        lightRaf = window.requestAnimationFrame(() => {
          lightRaf = 0;
          document.documentElement.style.setProperty("--lx", `${x}px`);
          document.documentElement.style.setProperty("--ly", `${y}px`);
        });
      }
      const ghost = pickupCursor.current;
      if (!ghost) return;
      ghost.style.left = `${x}px`;
      ghost.style.top = `${y}px`;
    }
    function flush(): void {
      void flushRef.current();
    }
    function onVisibility(): void {
      if (document.visibilityState === "hidden") flush();
    }
    window.addEventListener("keydown", onKeydown, { capture: true, passive: false });
    window.addEventListener("keyup", onKeyup, { capture: true, passive: false });
    window.addEventListener("mousedown", onMousedown, true);
    window.addEventListener("wheel", onWheel, { capture: true, passive: false });
    window.addEventListener("contextmenu", onContextMenu, true);
    window.addEventListener("mousemove", onMousemove);
    window.addEventListener("pagehide", flush);
    document.addEventListener("visibilitychange", onVisibility);
    return () => {
      window.cancelAnimationFrame(lightRaf);
      window.removeEventListener("keydown", onKeydown, true);
      window.removeEventListener("keyup", onKeyup, true);
      window.removeEventListener("mousedown", onMousedown, true);
      window.removeEventListener("wheel", onWheel, true);
      window.removeEventListener("contextmenu", onContextMenu, true);
      window.removeEventListener("mousemove", onMousemove);
      window.removeEventListener("pagehide", flush);
      document.removeEventListener("visibilitychange", onVisibility);
      window.clearTimeout(autosaveTimer.current);
    };
  }, []);

  useEffect(() => {
    document.body.classList.toggle("is-holding", Boolean(model.heldPickup));
    return () => document.body.classList.remove("is-holding");
  }, [Boolean(model.heldPickup)]);

  useLayoutEffect(() => {
    if (!pendingScroll.current) return;
    pendingScroll.current = false;
    rootElement
      .querySelector(`[data-group-block="${CSS.escape(model.groupId)}"]`)
      ?.scrollIntoView?.({ block: "nearest" });
  });

  const groups = groupsFor(model.catalog, model.classId, model.scope, model.toon);
  const toons = toonsFor(model.catalog, model.classId);
  const placed = placedSet();
  const abilityIndex = abilityRefIndex(
    model.catalog.macros.filter(
      (macro) => macro.class === model.classId || macro.class === "ALL",
    ),
  );
  const selectedFamily = spellHit
    ? findFamily(opts.spellbook, model.classId, spellHit.spellId)
    : undefined;
  const referencedBy = (selectedFamily ? refsForFamily(selectedFamily, abilityIndex) : [])
    .map((id) => byId.get(id))
    .filter((macro): macro is Macro => Boolean(macro));
  const hud = hudState();
  const collisions = hud ? classKeyCollisions(hud.buttons) : [];
  const collideKeys = new Set(collisions.map((collision) => collision.key));
  const pagedBar = Object.values(hud?.layout ?? {}).find(
    (config) => (config.stancePages?.length ?? 0) > 1,
  );
  const stanceNames = pagedBar?.stancePages
    ? pageLabels(pagedBar.stancePages, model.classId)
    : [];
  const variantNames = classSpec()?.variants.map((variant) => variant.name) ?? [];
  const loadedTotal = model.loadedAccount.length + model.loadedCharacter.length;
  const characterTitle = model.classId === "ALL" ? "Character" : titleCase(model.classId);

  function selectMacro(macro: Macro): void {
    model.selectedId = macro.id;
    model.groupId = macro.group;
    model.tab = macro.tab;
    update();
  }

  function startMacroDrag(
    event: ReactDragEvent<HTMLButtonElement>,
    macro: Macro,
  ): void {
    if (model.heldPickup || !event.dataTransfer) {
      event.preventDefault();
      return;
    }
    const pickup: Pickup = {
      kind: "macro",
      id: macro.id,
      name: macro.name,
      icon: macro.icon,
    };
    writePickup(event.dataTransfer, pickup, "copy");
  }

  function renderMacroCard(macro: Macro, showLoaded: boolean) {
    const binds = bindsForId(macro.id);
    return (
      <MacroCard
        macro={macro}
        selected={macro.id === model.selectedId}
        onBar={placed.has(macro.id)}
        barKey={assignedKeyLabel(binds, "")}
        loadedTab={showLoaded ? loadedTab(macro.id) : undefined}
        onSelect={() => selectMacro(macro)}
        onDelete={() => void deleteSelected(macro.id)}
        onDragStart={(event) => startMacroDrag(event, macro)}
        key={macro.id}
      />
    );
  }

  function SpellRankCard({
    rank,
    family,
    nested,
  }: {
    rank: SpellRank;
    family: SpellFamily;
    nested: boolean;
  }) {
    const id = spellActionId(rank.spellId);
    const onBar = nested ? placed.has(id) : familyPlaced(family, placed);
    const referenced = familyReferenced(family, abilityIndex);
    const label = rank.rank || (family.ranks.length === 1 ? "no rank" : "max");
    return (
      <div
        className={`macro-item spell-rank${id === model.selectedId ? " is-on" : ""}${
          nested ? " is-nested" : ""
        }${onBar ? " is-placed" : ""}${referenced ? " is-referenced" : ""}`}
      >
        <button
          type="button"
          className="macro-card"
          data-spell={rank.spellId}
          data-family={family.name}
          draggable
          onClick={() => {
            model.selectedId = id;
            update();
          }}
          onDragStart={(event) => {
            if (model.heldPickup || !event.dataTransfer) {
              event.preventDefault();
              return;
            }
            const pickup = nested ? pickupFromRank(rank) : pickupFromFamily(family);
            writePickup(event.dataTransfer, pickup, "copy");
          }}
        >
          <IconImage icon={rank.icon || family.icon} />
          <span className="copy">
            <span className="name">{nested ? label : family.name}</span>
            <span className="id">
              {nested ? `Lv ${rank.level}` : label}
              {nested ? "" : ` · ${family.ranks.length} ranks`}
            </span>
            {onBar && (
              <span className="pill bar">
                {assignedKeyLabel(bindsForId(id), "")
                  ? shortHotkey(assignedKeyLabel(bindsForId(id), ""))
                  : "Bar"}
              </span>
            )}
            {referenced && <span className="pill ref">Macro</span>}
          </span>
        </button>
      </div>
    );
  }

  function LibraryStage() {
    if (!groups.length) return <div className="empty">No groups for this class and filter.</div>;
    return (
      <>
        {groups.map((group) => {
          const tabLabel = group.tab === "account" ? "General" : "character";
          return (
            <section
              className="group-block"
              id={`g-${group.id}`}
              data-group-block={group.id}
              key={group.id}
            >
              <div className="group-head">
                <div>
                  <h2>{group.title}</h2>
                  <p className="blurb">{group.description}</p>
                </div>
                <div className="actions">
                  <button
                    type="button"
                    className="btn btn-primary"
                    onClick={() => {
                      model.groupId = group.id;
                      loadGroup(false);
                    }}
                  >
                    <Upload aria-hidden="true" size={16} /> Load {tabLabel}
                  </button>
                  <button
                    type="button"
                    className="btn"
                    onClick={() => {
                      model.groupId = group.id;
                      loadGroup(true);
                    }}
                  >
                    <ArrowRightLeft aria-hidden="true" size={16} /> Replace
                  </button>
                  <button
                    type="button"
                    className="btn"
                    onClick={() => {
                      model.groupId = group.id;
                      unloadGroup();
                    }}
                  >
                    <X aria-hidden="true" size={16} /> Unload
                  </button>
                </div>
              </div>
              <p className="blurb">
                {group.count} macros · {group.scope} · {tabLabel} · {loadedCount(group)} loaded ·
                drag onto an Action Bar
              </p>
              <div className="macro-list">
                {macrosIn(model.catalog, group.macroIds).map((macro) =>
                  renderMacroCard(macro, true),
                )}
              </div>
            </section>
          );
        })}
      </>
    );
  }

  function LoadedPane({
    tab,
    title,
    cap,
  }: {
    tab: Tab;
    title: string;
    cap: number;
  }) {
    const ids = tab === "account" ? model.loadedAccount : model.loadedCharacter;
    const buckets = bucketsFor(model.catalog, ids);
    return (
      <section className="loaded-pane">
        <div className="pane-head">
          <div>
            <h2>{title}</h2>
            <p className="blurb">
              {ids.length}/{cap} slots
            </p>
          </div>
          <div className="actions">
            <button type="button" className="btn" onClick={() => exportTab(tab)}>
              <Download aria-hidden="true" size={16} /> Export cache
            </button>
            <button type="button" className="btn danger" onClick={() => deleteTab(tab)}>
              <Trash2 aria-hidden="true" size={16} /> Delete tab
            </button>
          </div>
        </div>
        <div className="meter">
          <i style={{ width: `${Math.min(100, (ids.length / cap) * 100)}%` }} />
        </div>
        {buckets.length ? (
          buckets.map((bucket) => (
            <div
              className="bucket"
              id={`g-${bucket.group.id}`}
              data-group-block={bucket.group.id}
              key={`${tab}:${bucket.group.id}`}
            >
              <h3>
                {bucket.group.title} ({bucket.macros.length})
              </h3>
              <div className="macro-list">
                {bucket.macros.map((macro) => renderMacroCard(macro, false))}
              </div>
            </div>
          ))
        ) : (
          <p className="empty">Nothing loaded. Open Library and load a group.</p>
        )}
      </section>
    );
  }

  function SpellbookStage() {
    const lines = linesForClass(opts.spellbook, model.classId);
    if (!lines.length) return <div className="empty">No class spellbook for {model.classId}.</div>;
    const line = lines.find((entry) => entry.skillId === model.spellLine) ?? lines[0]!;
    return (
      <section className="group-block">
        <div className="group-head">
          <div>
            <h2>{line.title}</h2>
            <p className="blurb">
              Nested ranks. Drag a family (max rank) or a rank onto an Action Bar slot.
            </p>
          </div>
        </div>
        <div className="spell-list">
          {line.families.map((family) => {
            const max = family.ranks[family.ranks.length - 1]!;
            const open = family.ranks.some(
              (rank) => `spell:${rank.spellId}` === model.selectedId,
            );
            if (family.ranks.length === 1) {
              return (
                <div key={family.name}>
                  {SpellRankCard({ rank: max, family, nested: false })}
                </div>
              );
            }
            return (
              <details className="spell-family" open={open} key={family.name}>
                <summary>
                  {SpellRankCard({ rank: max, family, nested: false })}
                </summary>
                <div className="spell-ranks">
                  {family.ranks.map((rank) => (
                    <div key={rank.spellId}>
                      {SpellRankCard({ rank, family, nested: true })}
                    </div>
                  ))}
                </div>
              </details>
            );
          })}
        </div>
      </section>
    );
  }

  function classLabel(classId: WowClass | null): string {
    return CLASS_META.find((entry) => entry.id === classId)?.label ?? "Unknown";
  }

  function RosterStage() {
    const rows = sortRoster(opts.roster ?? []);
    if (!rows.length) {
      return (
        <div className="empty">No character folders at the Classic Era WTF path.</div>
      );
    }
    return (
      <section className="group-block">
        <div className="group-head">
          <div>
            <h2>Characters</h2>
            <p className="blurb">
              {rows.length} toons from the Classic Era WTF folder.
            </p>
          </div>
        </div>
        <div className="roster-list">
          {rows.map((character) => {
            const meta = CLASS_META.find((entry) => entry.id === character.class);
            const selected = rosterKey(character) === model.liveKey;
            return (
              <button
                type="button"
                className={`roster-row${selected ? " is-on" : ""}`}
                key={rosterKey(character)}
                onClick={() => {
                  model.liveKey = rosterKey(character);
                  model.toon = character.name;
                  if (character.class && character.class !== "ALL") {
                    model.classId = character.class;
                    model.variant = pickVariant(opts, character.class, "");
                    model.spellLine =
                      linesForClass(opts.spellbook, character.class)[0]?.skillId ?? 0;
                  }
                  setQuery(model);
                  update();
                }}
              >
                <IconImage icon={meta?.icon ?? "inv_misc_questionmark"} />
                <span className="copy">
                  <span className="name">{character.name}</span>
                  <span className="id">
                    {character.realm} · {character.account}
                  </span>
                </span>
                <span className="roster-class">{classLabel(character.class)}</span>
                <span className="roster-level">
                  {character.level != null ? `Lv ${character.level}` : "Lv —"}
                </span>
              </button>
            );
          })}
        </div>
      </section>
    );
  }

  function ViewSwitch() {
    return (
      <nav id="viewSwitch" aria-label="View">
        <button
          type="button"
          className={model.view === "library" ? "is-on" : undefined}
          onClick={() => {
            model.view = "library";
            setQuery(model);
            update();
          }}
        >
          <Library aria-hidden="true" size={16} /> Library
        </button>
        <button
          type="button"
          className={model.view === "spellbook" ? "is-on" : undefined}
          onClick={() => {
            model.view = "spellbook";
            const line =
              linesForClass(opts.spellbook, model.classId).find(
                (entry) => entry.skillId === model.spellLine,
              ) ?? linesForClass(opts.spellbook, model.classId)[0];
            if (line) {
              model.spellLine = line.skillId;
              if (!model.selectedId.startsWith("spell:")) {
                model.selectedId = `spell:${line.families[0]?.maxSpellId ?? ""}`;
              }
            }
            setQuery(model);
            update();
          }}
        >
          <BookOpen aria-hidden="true" size={16} /> Spellbook
        </button>
        <button
          type="button"
          className={model.view === "loaded" ? "is-on" : undefined}
          onClick={() => {
            model.view = "loaded";
            setQuery(model);
            update();
          }}
        >
          <Layers3 aria-hidden="true" size={16} /> Loaded <span>{loadedTotal}</span>
        </button>
        <button
          type="button"
          className={model.view === "characters" ? "is-on" : undefined}
          onClick={() => {
            model.view = "characters";
            setQuery(model);
            update();
          }}
        >
          <Users aria-hidden="true" size={16} /> Characters{" "}
          <span>{(opts.roster ?? []).length}</span>
        </button>
      </nav>
    );
  }

  function Sidebar() {
    if (model.view === "characters") {
      const rows = opts.roster ?? [];
      const unknown = rows.filter((row) => !row.class).length;
      return (
        <>
          <h2>Characters</h2>
          {CLASS_META.filter((entry) => entry.id !== "ALL").map((entry) => {
            const count = rows.filter((row) => row.class === entry.id).length;
            if (!count) return null;
            return (
              <div className="nav-group" key={entry.id}>
                <span className="title">{entry.label}</span>
                <span className="meta">{count}</span>
              </div>
            );
          })}
          {unknown > 0 && (
            <div className="nav-group">
              <span className="title">Unknown</span>
              <span className="meta">{unknown}</span>
            </div>
          )}
          {!rows.length && <p className="empty">No toons.</p>}
        </>
      );
    }
    if (model.view === "spellbook") {
      const lines = linesForClass(opts.spellbook, model.classId);
      return (
        <>
          <h2>Spellbook</h2>
          {lines.map((line) => (
            <button
              type="button"
              className={`nav-group${line.skillId === model.spellLine ? " is-on" : ""}`}
              key={line.skillId}
              onClick={() => {
                model.spellLine = line.skillId;
                if (line.families[0]) model.selectedId = `spell:${line.families[0].maxSpellId}`;
                update();
              }}
            >
              <span className="title">{line.title}</span>
              <span className="meta">{line.families.length}</span>
            </button>
          ))}
          {!lines.length && <p className="empty">No spells.</p>}
        </>
      );
    }
    if (model.view === "loaded") {
      const sections: { title: string; tab: Tab; ids: string[] }[] = [
        { title: "General", tab: "account", ids: model.loadedAccount },
        { title: "Character", tab: "character", ids: model.loadedCharacter },
      ];
      return (
        <>
          {sections.map((section) => {
            const buckets = bucketsFor(model.catalog, section.ids);
            return (
              <div className="nav-section" key={section.tab}>
                <h2>
                  {section.title} · {section.ids.length}
                </h2>
                {!buckets.length && <p className="blurb">Empty</p>}
                {buckets.map((bucket) => (
                  <button
                    type="button"
                    className={`nav-group${
                      bucket.group.id === model.groupId ? " is-on" : ""
                    }`}
                    key={bucket.group.id}
                    onClick={() => {
                      model.groupId = bucket.group.id;
                      model.tab = section.tab;
                      model.selectedId = bucket.macros[0]?.id ?? "";
                      pendingScroll.current = true;
                      update();
                    }}
                  >
                    <span className="title">{bucket.group.title}</span>
                    <span className="meta">{bucket.macros.length}</span>
                  </button>
                ))}
              </div>
            );
          })}
        </>
      );
    }
    return (
      <>
        <h2>Groups</h2>
        {groups.map((group) => (
          <button
            type="button"
            className={`nav-group${group.id === model.groupId ? " is-on" : ""}`}
            key={group.id}
            onClick={() => {
              model.groupId = group.id;
              model.tab = group.tab;
              model.selectedId = group.macroIds[0] ?? "";
              pendingScroll.current = true;
              update();
            }}
          >
            <span>
              <span className="title">{group.title}</span>
            </span>
            <span className="meta">
              {group.count}
              {loadedCount(group) ? ` · ${loadedCount(group)} on` : ""}
            </span>
          </button>
        ))}
        {!groups.length && <p className="empty">No groups.</p>}
      </>
    );
  }

  const selectedKey = keybindValue(selected, spellHit ? spellActionId(spellHit.spellId) : undefined);

  return (
    <div
      id="macroCursorApp"
      onClick={(event: ReactMouseEvent<HTMLDivElement>) => {
        if (suppressPickupClick.current) {
          suppressPickupClick.current = false;
          return;
        }
        if (!model.heldPickup) return;
        const target = event.target as HTMLElement;
        if (!target.closest(".hud-slot")) clearHeld();
      }}
      onDragOver={(event) => {
        const types = event.dataTransfer?.types ? Array.from(event.dataTransfer.types) : [];
        const fromSlot = dragFromSlot.current !== undefined;
        if (!fromSlot && !types.includes(PICKUP_MIME) && !types.includes("text/plain")) return;
        event.preventDefault();
        event.dataTransfer.dropEffect = fromSlot ? "move" : "copy";
      }}
      onDrop={(event) => {
        const fromSlot = dragFromSlot.current;
        if (
          pickupDropOffBarAction({
            fromSlot,
            droppedOnSlot: Boolean((event.target as HTMLElement).closest(".hud-slot")),
          }) !== "clear-source" ||
          fromSlot === undefined
        ) {
          return;
        }
        event.preventDefault();
        dragFromSlot.current = undefined;
        void clearSlot(fromSlot);
      }}
    >
      <header id="top">
        <div id="topRow">
          <div id="brand">
            <h1>Macro Cursor</h1>
            <p className="lede">
              {model.catalog.limits.account} account + {model.catalog.limits.character} character
              {" · "}
              {model.catalog.macros.length} in catalog
            </p>
          </div>
        </div>
        <nav id="classes" aria-label="Class">
          {CLASS_META.map((entry) => (
            <button
              type="button"
              className={`class-btn${entry.id === model.classId ? " is-on" : ""}`}
              title={entry.label}
              key={entry.id}
              onClick={() => {
                model.classId = entry.id;
                model.toon = "";
                model.view = "library";
                model.variant = pickVariant(opts, entry.id, "");
                model.stance = 0;
                pickGroup(entry.id, model.scope, "");
                model.spellLine = linesForClass(opts.spellbook, entry.id)[0]?.skillId ?? 0;
                model.status = "";
                setQuery(model);
                update();
              }}
            >
              <IconImage icon={entry.icon} />
              <span>{entry.label}</span>
            </button>
          ))}
        </nav>
      </header>

      {model.live && (
        <section id="liveBar">
          <label>
            Account{" "}
            <select
              id="liveAccount"
              value={model.accountName}
              onChange={(event) => {
                const account = event.target.value;
                const toon = model.live?.characters.find(
                  (character) => character.account === account,
                );
                applyMerged(account, toon);
                setQuery(model);
                update();
              }}
            >
              {model.live.accounts.map((account) => (
                <option value={account.account} key={account.account}>
                  {account.account} ({account.macros.length})
                </option>
              ))}
            </select>
          </label>
          <label>
            Character{" "}
            <select
              id="liveToon"
              value={model.liveKey}
              onChange={(event) => {
                const toon = model.live?.characters.find(
                  (character) => liveKeyOf(character) === event.target.value,
                );
                applyMerged(model.accountName, toon);
                setQuery(model);
                update();
              }}
            >
              <option value="">Account only</option>
              {model.live.characters
                .filter(
                  (character) => !model.accountName || character.account === model.accountName,
                )
                .map((character) => (
                  <option value={liveKeyOf(character)} key={liveKeyOf(character)}>
                    {character.realm} / {character.name} ({character.class ?? "?"},{" "}
                    {character.macros.length})
                  </option>
                ))}
            </select>
          </label>
          <button type="button" className="btn" id="resync" onClick={() => void resync()}>
            <RefreshCw aria-hidden="true" size={16} /> Resync
          </button>
          <span id="liveMeta">
            {activeLiveToon()
              ? `${model.accountName} · ${activeLiveToon()!.realm}/${activeLiveToon()!.name}`
              : model.accountName || model.live.wowPath}
          </span>
          {model.live.wowRunning && (
            <span className="warn">WoW is open. Heal stays in memory.</span>
          )}
        </section>
      )}

      <CollisionWarning collisions={collisions} byId={byId} />
      {hud && (
        <ActionBars
          hud={hud}
          selectedId={model.selectedId}
          collideKeys={collideKeys}
          stance={model.stance}
          stanceNames={stanceNames}
          variantNames={variantNames}
          variant={model.variant}
          classId={model.classId}
          spellbook={opts.spellbook}
          byId={byId}
          keybindMode={model.keybindMode}
          bindTarget={bindTargetSlot()}
          heldPickup={model.heldPickup}
          onVariant={(name) => {
            model.variant = name;
            setQuery(model);
            update();
          }}
          onStance={(index) => {
            model.stance = index;
            update();
          }}
          onToggleBinds={() => {
            model.keybindMode = !model.keybindMode;
            if (!model.keybindMode) {
              hoverBindSlot.current = null;
              pinnedBindSlot.current = null;
            }
            model.status = model.keybindMode
              ? "Keybind Edit Mode: click a slot, then press a key. Type CTRL-G if Chrome steals it."
              : "Keybind Edit Mode off.";
            update();
          }}
          onSaveBindsBase={() => void saveBindsAsBase()}
          onCopyBars={(source) => void copyBarsFrom(source)}
          onCopyPages={(barId) => void copyPagesOnBar(barId)}
          onBindCapture={(key) => void captureBind(key)}
          onHoverBind={(slot) => {
            hoverBindSlot.current = slot;
            if (model.keybindMode) update();
          }}
          onPinBind={(slot) => {
            pinnedBindSlot.current = slot;
            update();
          }}
          onSelectAction={(id) => {
            model.selectedId = id;
            update();
          }}
          onPlaceHeld={(slot) => {
            if (model.heldPickup) void dropPickup(slot, model.heldPickup);
          }}
          consumeSuppressedClick={() => {
            const suppressed = suppressPickupClick.current;
            suppressPickupClick.current = false;
            return suppressed;
          }}
          onSlotDragStart={(event, button) => {
            if (model.heldPickup || !event.dataTransfer) {
              event.preventDefault();
              return;
            }
            if (!button.action) return;
            const pickup = actionToPickup(button.action, button.actionSlot);
            writePickup(event.dataTransfer, pickup, "move");
            dragFromSlot.current = button.actionSlot;
          }}
          onSlotDragEnd={() => {
            dragFromSlot.current = undefined;
          }}
          onSlotDrop={(event, slot) => {
            if (!event.dataTransfer) return;
            const dt = event.dataTransfer;
            const pickup = pickupFromDataTransfer((type) => dt.getData(type));
            if (pickup && slot) void dropPickup(slot, pickup);
          }}
        />
      )}

      <div id="workspace">
        <aside id="groupNav">
          {Sidebar()}
        </aside>
        <div id="stageFolder">
          {ViewSwitch()}
          <div id="filters" hidden={model.view !== "library"}>
            <nav id="scopeNav" aria-label="Scope">
              {SCOPE_CHIPS.map((scope) => (
                <button
                  type="button"
                  className={`chip${scope.id === model.scope ? " is-on" : ""}`}
                  key={scope.id}
                  onClick={() => {
                    model.scope = scope.id;
                    if (scope.id !== "character") model.toon = "";
                    pickGroup(model.classId, model.scope, model.toon);
                    setQuery(model);
                    update();
                  }}
                >
                  {scope.label}
                </button>
              ))}
            </nav>
            <nav id="toonNav" aria-label="Character">
              {toons.length > 0 && (
                <button
                  type="button"
                  className={`chip${!model.toon ? " is-on" : ""}`}
                  onClick={() => {
                    model.toon = "";
                    pickGroup(model.classId, model.scope, "");
                    setQuery(model);
                    update();
                  }}
                >
                  All toons
                </button>
              )}
              {toons.map((toon) => (
                <button
                  type="button"
                  className={`chip${toon === model.toon ? " is-on" : ""}`}
                  key={toon}
                  onClick={() => {
                    model.toon = toon;
                    model.scope = "character";
                    pickGroup(model.classId, "character", toon);
                    setQuery(model);
                    update();
                  }}
                >
                  {toon}
                </button>
              ))}
            </nav>
          </div>
          <main id="stage" className={model.view}>
            {model.view === "library" ? (
              LibraryStage()
            ) : model.view === "spellbook" ? (
              SpellbookStage()
            ) : model.view === "characters" ? (
              RosterStage()
            ) : (
              <>
                {LoadedPane({
                  tab: "account",
                  title: "General",
                  cap: model.catalog.limits.account,
                })}
                {LoadedPane({
                  tab: "character",
                  title: characterTitle,
                  cap: model.catalog.limits.character,
                })}
              </>
            )}
          </main>
        </div>
        <aside id="inspector">
          <Inspector
            selected={selected}
            spell={spellHit}
            catalog={model.catalog}
            keyValue={selectedKey}
            keyMeta={keybindMeta(
              selected,
              spellHit ? spellActionId(spellHit.spellId) : undefined,
            )}
            canAssignSpell={Boolean(spellHit && bindsForId(spellActionId(spellHit.spellId)).length)}
            referencedBy={referencedBy}
            onOpenMacro={(macro) => {
              model.view = "library";
              model.selectedId = macro.id;
              model.groupId = macro.group;
              model.tab = macro.tab;
              pendingScroll.current = true;
              setQuery(model);
              update();
            }}
            onQueueName={queueName}
            onQueueBody={queueBody}
            onFlushName={(id, value) => {
              pendingName.current = { id, value };
              void flushEdits();
            }}
            onFlushBody={(id, value) => {
              pendingBody.current = { id, value };
              void flushEdits();
            }}
            onCommitKey={(id, value, body) => void commitAssignedKey(id, value, body)}
            onCopyBody={async () => {
              if (!selected) return;
              await flushEdits();
              const macro =
                new Map(model.catalog.macros.map((item) => [item.id, item])).get(selected.id) ??
                selected;
              await copyText(macro.body);
              model.status = `Copied ${macro.name}.`;
              update();
            }}
            onCopyGroup={async () => {
              const group = activeGroup();
              if (!group) return;
              await flushEdits();
              await copyText(exportGroupText(macrosIn(model.catalog, group.macroIds)));
              model.status = `Copied ${group.title}.`;
              update();
            }}
            onDelete={() => void deleteSelected()}
          />
        </aside>
      </div>
      <p id="status">{model.status}</p>
      {model.heldPickup && (
        <div id="pickupCursor" ref={pickupCursor}>
          <IconImage icon={model.heldPickup.icon} />
        </div>
      )}
    </div>
  );
}

const roots = new WeakMap<HTMLElement, Root>();

export function mount(root: HTMLElement, opts: MountOpts): void {
  roots.get(root)?.unmount();
  const reactRoot = createRoot(root);
  roots.set(root, reactRoot);
  flushSync(() => {
    reactRoot.render(<MacroCursorApp rootElement={root} opts={opts} />);
  });
}

function titleCase(value: string): string {
  return value.slice(0, 1) + value.slice(1).toLowerCase();
}
