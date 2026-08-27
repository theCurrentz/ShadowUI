import type { WowClass } from "./types";

const QUESTION = "inv_misc_questionmark";
const CDN = "https://wow.zamimg.com/images/wow/icons/large";

export const CLASS_META: {
  id: WowClass;
  label: string;
  icon: string;
}[] = [
  { id: "ALL", label: "Shared", icon: "inv_misc_book_09" },
  { id: "WARRIOR", label: "Warrior", icon: "classicon_warrior" },
  { id: "PALADIN", label: "Paladin", icon: "classicon_paladin" },
  { id: "HUNTER", label: "Hunter", icon: "classicon_hunter" },
  { id: "ROGUE", label: "Rogue", icon: "classicon_rogue" },
  { id: "PRIEST", label: "Priest", icon: "classicon_priest" },
  { id: "SHAMAN", label: "Shaman", icon: "classicon_shaman" },
  { id: "MAGE", label: "Mage", icon: "classicon_mage" },
  { id: "WARLOCK", label: "Warlock", icon: "classicon_warlock" },
  { id: "DRUID", label: "Druid", icon: "classicon_druid" },
];

export function iconUrl(icon: string): string {
  const slug = icon.trim().toLowerCase().replace(/^interface\\icons\\/, "");
  if (!slug || slug === "inv_misc_questionmark" || /^\d+$/.test(slug)) {
    return `${CDN}/${QUESTION}.jpg`;
  }
  return `${CDN}/${slug}.jpg`;
}

export function onIconError(ev: Event): void {
  const img = ev.target as HTMLImageElement;
  if (img.dataset.fallback === "1") return;
  img.dataset.fallback = "1";
  img.src = `${CDN}/${QUESTION}.jpg`;
}
