/// <reference types="vite/client" />

declare module "@catalog" {
  import type { Catalog } from "./types";
  const catalog: Catalog;
  export default catalog;
}

declare module "@spells" {
  import type { Spellbook } from "./spellbook";
  const spellbook: Spellbook;
  export default spellbook;
}

declare module "*.lua?raw" {
  const src: string;
  export default src;
}
