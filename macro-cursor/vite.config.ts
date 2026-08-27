import path from "node:path";
import { fileURLToPath } from "node:url";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vitest/config";
import { wowMacrosPlugin } from "./wow-macros-plugin.ts";

const appDir = path.dirname(fileURLToPath(import.meta.url));
const addonRoot = path.resolve(appDir, "..");
const catalogPath = path.join(addonRoot, "docs/macros/catalog.json");

export default defineConfig({
  server: {
    port: 5174,
    open: "/?class=WARRIOR",
    fs: { allow: [addonRoot] },
    watch: {
      ignored: ["**/defaults/classes/*.lua", "**/docs/macros/actions.json"],
    },
  },
  preview: {
    port: 5174,
  },
  plugins: [react(), wowMacrosPlugin(catalogPath)],
  resolve: {
    alias: {
      "@catalog": catalogPath,
      "@spells": path.join(addonRoot, "docs/macros/spells.json"),
    },
  },
  test: {
    environment: "jsdom",
    setupFiles: ["./test/setup.ts"],
    include: ["test/**/*.dom.test.ts"],
    restoreMocks: true,
  },
});
