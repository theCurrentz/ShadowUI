--[[
  Purpose: Geometric Classic chrome for the HTML harness. Not Blizzard art.
  Deps: none
  Public: list of widgets. Sizes sit on the 12px harness grid.
]]

-- Geometric placeholders snapped to the 12px harness grid.
-- Currentz / skin numbers are the source; dump_layout snaps HTML edges.
-- Range Display in-game is CENTER -6,-170 112x36; harness uses the on-grid
-- lock -6,-174 108x36.
-- Shield Row in-game parents to PlayerFrame; harness sits 12px above Player.
-- Cast Bar in-game is CENTER -6,-132 from Currentz Quartz (288x20).
-- Harness uses 0,-132 288x24 so HTML left tiles the 12px grid.

return {
  { id = "xp", kind = "xp", label = "XP", persist = true,
    point = "TOP", x = 0, y = 0, width = 1920, height = 12 },
  { id = "rep", kind = "rep", label = "Rep", persist = true,
    point = "TOP", x = 0, y = -12, width = 1920, height = 12 },
  { id = "player", kind = "unit", label = "Player", persist = true, lock = "shields",
    point = "CENTER", x = -198, y = -186, width = 228, height = 84 },
  { id = "shields", kind = "shields", label = "Shields", persist = false, lock = "player",
    point = "CENTER", x = -198, y = -114, width = 108, height = 36 },
  { id = "target", kind = "unit", label = "Target", persist = true,
    point = "CENTER", x = 198, y = -186, width = 228, height = 84 },
  { id = "manaTicker", kind = "ticker", label = "Mana", persist = true,
    point = "TOPLEFT", x = 724, y = -756, width = 120, height = 12,
    hideFor = { WARRIOR = true } },
  { id = "minimap", kind = "minimap", label = "Minimap", persist = true,
    point = "TOPRIGHT", x = 0, y = 0, width = 192, height = 192 },
  { id = "chat", kind = "chat", label = "Chat", persist = true,
    point = "BOTTOMLEFT", x = 36, y = 24, width = 612, height = 300 },
  { id = "detailsDamage", kind = "details", label = "Damage", persist = true,
    point = "RIGHT", x = 0, y = -192, width = 156, height = 168 },
  { id = "detailsThreat", kind = "details", label = "Threat", persist = true,
    point = "BOTTOMRIGHT", x = 0, y = 144, width = 156, height = 108 },
  { id = "micro", kind = "micro", label = "Micro", persist = true,
    point = "BOTTOMRIGHT", x = 0, y = 0, width = 264, height = 60 },
  -- Combat meter group: Cast Bar, GCD Sweep, then Swing Timer. The spell icon
  -- overlays the left of the Cast Bar. GCD Sweep and Swing Timer share Cast Bar width.
  -- Width is 8×36 so the meter is narrower than a 12-slot Action Bar.
  { id = "castbar", kind = "cast", label = "Cast", persist = true, lock = "gcd",
    point = "CENTER", x = 0, y = -132, width = 288, height = 24 },
  { id = "gcd", kind = "gcd", label = "GCD", persist = true, lock = "castbar",
    point = "CENTER", x = 0, y = -150, width = 288, height = 12 },
  { id = "swing", kind = "swing", label = "Swing", persist = true, lock = "gcd",
    point = "CENTER", x = 0, y = -168, width = 288, height = 24 },
  { id = "range", kind = "range", label = "Range", persist = true,
    point = "CENTER", x = -6, y = -174, width = 108, height = 36 },
}
