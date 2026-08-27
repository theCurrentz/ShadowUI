import fs from "node:fs";
import path from "node:path";

const pending = new Set<string>();

function aliases(file: string): string[] {
  const resolved = path.resolve(file);
  const out = [resolved];
  try {
    const real = fs.realpathSync.native?.(resolved) ?? fs.realpathSync(resolved);
    if (real !== resolved) out.push(real);
  } catch {
    /* file may not exist yet */
  }
  return out;
}

export function markSelfWrite(file: string): void {
  for (const p of aliases(file)) pending.add(p);
}

/** True when Vite should skip HMR for a file this process just wrote. */
export function consumeSelfWrite(file: string): boolean {
  const names = aliases(file);
  let hit = false;
  for (const p of names) {
    if (pending.has(p)) {
      pending.delete(p);
      hit = true;
    }
  }
  if (hit) {
    for (const p of names) pending.delete(p);
  }
  return hit;
}

export function writeWatchedFile(file: string, content: string): boolean {
  if (fs.existsSync(file) && fs.readFileSync(file, "utf8") === content) return false;
  markSelfWrite(file);
  fs.writeFileSync(file, content);
  return true;
}
