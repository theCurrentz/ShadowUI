-- Cubic-bezier (0.16, 1, 0.3, 1) maps unit time to fade progress.
-- Run: lua tests/easing_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end

assert(loadfile(root .. "core/easing.lua"))()

assert(Addon:Ease(0) == 0, "ease starts at 0")
assert(Addon:Ease(1) == 1, "ease ends at 1")
assert(math.abs(Addon:Ease(0.5) - 0.971779) < 0.0005, "ease mid sample matches cubic-bezier (0.16, 1, 0.3, 1)")
assert(Addon:Ease(-1) == 0, "ease clamps below 0")
assert(Addon:Ease(2) == 1, "ease clamps above 1")

local toc = assert(io.open(root .. "ShadowUI.toc", "r")):read("*a")
assert(toc:find("core\\easing.lua", 1, true), "TOC loads easing")
assert(toc:find("skin\\fade.lua", 1, true), "TOC loads fade")
assert(toc:find("skin\\shape.lua", 1, true), "TOC loads shape")

print("easing_spec OK")
