# Layout harness

Geometric Classic HUD for ShadowUI placement. It does not run the game client and does not ship Blizzard textures.

The preview is a Vite + TypeScript app. Serve it with Node. Do not use Python.

## Dump

From the addon root:

```bash
lua sim/dump_layout.lua
```

This writes `sim/layout.json` from shipped Base + Class defaults.

## Open

From the addon root:

```bash
pnpm --dir sim install
pnpm --dir sim dev
```

Vite dumps `sim/layout.json`, then opens `http://localhost:5173/?class=MAGE`. Omit `class` for Mage by default.

The preview reloads when you change TypeScript, CSS, or Layout Lua (`defaults/`, `sim/chrome.lua`, `sim/rect.lua`). You do not need to restart Vite or run the dump by hand while `dev` is running.

## Edit

1. Pick a class.
2. Drag to move. Drag an edge or corner to resize. Chrome snap is 12px so the 1920×1080 stage fills the grid. Action buttons are 32.4px (90% of 36). Action Bars snap resize to 12-slot grids (columns 12, 6, 4, 3, 2, or 1). Other Bars snap to grids that fill their slot count. Tracking (XP and reputation) drags the same way as other Chrome. The Cast Bar, GCD Sweep, and Swing Timer lock: the spell icon overlays the left of the Cast Bar at the same height, they share the Cast Bar width, the GCD Sweep stays under the Cast Bar, and the Swing Timer stays under the GCD Sweep. The Shield Row stays on the Player Frame.
3. **Save** opens a dialog:
   - **Replace default** copies Lua. Paste bar deltas into `defaults/base.lua` or `defaults/classes/<CLASS>.lua`. Paste Chrome deltas into `sim/chrome.lua`.
   - **Save as...** stores a named copy in this browser. Pick it from **Layout**.
   - **Download patch.json** or **Copy Lua**.
4. Drag again and run `lua tests/layout_spec.lua`. Chrome, combat meters, Chat, and Details Windows are not Layout. Game Layout Edit Mode drags Bars, the Player Frame, and the Target Frame. It does not move other Chrome.
