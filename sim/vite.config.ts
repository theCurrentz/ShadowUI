import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { defineConfig, type Plugin } from "vite";

const simDir = path.dirname(fileURLToPath(import.meta.url));
const addonRoot = path.resolve(simDir, "..");

function dumpLayout(): void {
  const result = spawnSync("lua", ["sim/dump_layout.lua"], {
    cwd: addonRoot,
    encoding: "utf8",
  });
  if (result.error || result.status !== 0) {
    const detail =
      result.error?.message ||
      (result.stderr || result.stdout || "unknown error").trim();
    throw new Error("lua sim/dump_layout.lua failed: " + detail);
  }
  if (result.stdout) process.stdout.write(result.stdout);
}

function isDumpSource(file: string): boolean {
  const n = file.replace(/\\/g, "/");
  return (
    n.endsWith("/defaults/base.lua") ||
    (n.includes("/defaults/classes/") && n.endsWith(".lua")) ||
    n.endsWith("/core/resolve.lua") ||
    n.endsWith("/sim/chrome.lua") ||
    n.endsWith("/sim/rect.lua") ||
    n.endsWith("/sim/dump_layout.lua")
  );
}

function dumpLayoutPlugin(): Plugin {
  let timer: ReturnType<typeof setTimeout> | undefined;

  function scheduleDump(): void {
    clearTimeout(timer);
    timer = setTimeout(() => {
      try {
        dumpLayout();
      } catch (err) {
        console.error("[sim]", err instanceof Error ? err.message : err);
      }
    }, 50);
  }

  return {
    name: "shadowui-dump-layout",
    buildStart() {
      dumpLayout();
    },
    configureServer(server) {
      server.watcher.add([
        path.join(addonRoot, "defaults"),
        path.join(addonRoot, "core", "resolve.lua"),
        path.join(simDir, "chrome.lua"),
        path.join(simDir, "rect.lua"),
        path.join(simDir, "dump_layout.lua"),
      ]);
      server.watcher.on("change", (file) => {
        if (isDumpSource(file)) scheduleDump();
      });
      server.watcher.on("add", (file) => {
        if (isDumpSource(file)) scheduleDump();
      });
    },
  };
}

export default defineConfig({
  server: {
    port: 5173,
    open: "/?class=MAGE",
    fs: { allow: [addonRoot] },
  },
  plugins: [dumpLayoutPlugin()],
});
