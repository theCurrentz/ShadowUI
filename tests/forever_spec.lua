-- Forever-only LAB skips retail Execute. Forever TOC is game 1.60.1 / interface 16001.
-- Run: lua tests/forever_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local lab = assert(io.open(root .. "libs/LibActionButton-1.0/LibActionButton-1.0.lua", "r")):read("*a")
assert(lab:find("local WoWForever = true", 1, true), "LAB is Forever-only")
assert(lab:find("not WoWForever and (WoWRetail", 1, true), "Forever must not use retail flyouts")

local toc = assert(io.open(root .. "ShadowUI.toc", "r")):read("*a")
assert(toc:find("Interface: 16001", 1, true), "TOC is Forever interface 16001")
assert(not toc:find("Interface: 11509", 1, true), "TOC must not declare Era")
assert(not toc:find("Interface: 20506", 1, true), "TOC must not declare TBC")

local embeds = assert(io.open(root .. "libs/embeds.xml", "r")):read("*a")
assert(not embeds:find("LibActionButton", 1, true), "do not load LibActionButton")
assert(not embeds:find("LibRangeCheck", 1, true), "do not load LibRangeCheck")

local blizzardbars = assert(io.open(root .. "skin/blizzardbars.lua", "r")):read("*a")
assert(not blizzardbars:find(":SetAlpha", 1, true)
  and not blizzardbars:find(".SetAlpha", 1, true),
  "do not SetAlpha default bar art")

local button = assert(io.open(root .. "bars/button.lua", "r")):read("*a")
assert(not button:find("GetActionInfo(", 1, true), "chrome must not call GetActionInfo")
assert(button:find("isDefaultActionButton", 1, true), "Blizzard ActionButtons skip HasAction")

assert(not toc:find("cooldown.lua", 1, true), "do not load Cooldown Count")
assert(not toc:find("range.lua", 1, true), "do not load Range Display")
assert(not toc:find("shield", 1, true), "do not load Shield Row")
assert(not toc:find("ccportrait", 1, true), "do not load Crowd Control Portrait")
assert(not toc:find("threat.lua", 1, true), "do not load Threat Bar")
assert(not button:find("SkinCooldownCount", 1, true), "chrome must not tick secret cooldown times")

local slotshift = assert(io.open(root .. "bars/slotshift.lua", "r")):read("*a")
assert(not slotshift:find("GetActionInfo(", 1, true), "Shift and Prune must not call GetActionInfo")
assert(not slotshift:find("WrapScript", 1, true), "Shift and Prune must not WrapScript")
assert(not slotshift:find("GetSpellInfo(", 1, true), "Shift and Prune must not call GetSpellInfo")

local resolve = assert(io.open(root .. "core/resolve.lua", "r")):read("*a")
assert(not resolve:find("GetTalentTabInfo", 1, true), "resolve must not call Classic talent APIs")

local keybinds = assert(io.open(root .. "core/keybinds.lua", "r")):read("*a")
assert(not keybinds:find("SetOverrideBindingClick", 1, true), "do not override-click missing LAB hosts")

local auras = assert(io.open(root .. "skin/auras.lua", "r")):read("*a")
assert(auras:find("issecretvalue", 1, true), "aura chrome must not compare secret textures")

local frames = assert(io.open(root .. "skin/frames.lua", "r")):read("*a")
assert(not frames:find("tot:SetParent", 1, true), "do not SetParent Target of Target or Focus")

local forever = assert(io.open(root .. "ShadowUI_Forever.toc", "r")):read("*a")
assert(forever:find("Interface: 16001", 1, true), "flavor TOC is Forever 16001")

local camelot = assert(io.open(root .. "ShadowUI_Camelot.toc", "r")):read("*a")
assert(camelot:find("Interface: 16001", 1, true), "flavor TOC is Camelot 16001")
assert(forever == camelot and camelot == toc, "Forever, Camelot, and base TOC files match")

print("forever_spec OK")
