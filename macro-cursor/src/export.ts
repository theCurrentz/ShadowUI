import type { Macro, Tab } from "./types";

function padId(n: number, character: boolean): string {
  const hex = n.toString(16).toUpperCase().padStart(8, "0");
  return character ? `01000000${hex}` : `00000000${hex}`;
}

export function exportCache(macros: Macro[], tab: Tab): string {
  const character = tab === "character";
  const blocks = macros.map((m, i) => {
    const icon = m.icon.toUpperCase().replace(/-/g, "_");
    return `VER 3 ${padId(i + 1, character)} "${m.name}" "${icon}"\n${m.body}\nEND`;
  });
  return blocks.join("\n") + (blocks.length ? "\n" : "");
}

export function exportGroupText(macros: Macro[]): string {
  return macros
    .map((m) => `--- ${m.name} (${m.id})\n${m.body}`)
    .join("\n\n");
}
