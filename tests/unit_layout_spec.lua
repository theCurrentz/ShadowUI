-- Baseline Player Frame and Target Frame Layout: Classic targeting-frame
-- Widgets, horizontal mirror, sparse Profile overlay, and Widget place.
-- Run: lua tests/unit_layout_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "units/layout.lua"))()
assert(loadfile(root .. "defaults/base.lua"))()
assert(loadfile(root .. "defaults/units.lua"))()

local player = Addon:BaselineUnitFrameLayout("player")
assert(player.width == 232 and player.height == 100, "Baseline host is the targeting frame")
assert(player.point == "CENTER" and player.x == -200 and player.y == -179, "Player park matches chrome lock")
assert(player.portraitSide == "left", "Player portrait is on the left")
assert(player.art.width == 232 and player.art.height == 100, "Frame Art fills the host")
local pl, pr, pt, pb = Addon:UnitFrameArtTexCoord("player")
assert(pl == 1 and pr == 0.09375 and pt == 0 and pb == 0.78125,
  "Player Frame Art uses the flipped targeting-frame crop")
local tl, tr = Addon:UnitFrameArtTexCoord("target")
assert(tl == 0.09375 and tr == 1, "Target Frame Art uses the unflipped crop")
local cropU0, cropU1 = Addon:UnitFrameArtTexCoord("player", {
  left = 16, bottom = 0, width = 216, height = 100,
})
assert(math.abs(cropU0 - 0.9375) < 0.0001 and math.abs(cropU1 - 0.09375) < 0.0001,
  "a smaller Frame Art box crops the atlas instead of stretching it")
assert(Addon:WidgetStack(nil, "art") == 1, "Frame Art starts at the back of the stack")
assert(Addon:WidgetStack({ stack = 9 }, "health") == 9, "Profile stack wins")
assert(player.portrait.x == 42 and player.portrait.y == -12, "Player portrait hole")
assert(player.portrait.width == 64 and player.portrait.height == 64, "Portrait is 64")
assert(player.health.x == 106 and player.health.width == 119 and player.health.height == 12, "Player health slot")
assert(player.power.x == 106 and player.power.y == -52, "Player power sits under health")
assert(player.healthText.relativeTo == "health", "Status Text anchors to health")
assert(player.powerText.relativeTo == "power", "power text anchors to power")
assert(player.level.relativeTo == "portrait", "level sits on the portrait")
assert(player.nameBackground == nil, "Player has no Name Background")
assert(player.auras == nil, "Player has no target aura Widget")
assert(player.spellBar == nil, "Player has no target spell bar")

local target = Addon:BaselineUnitFrameLayout("target")
assert(target.x == 202 and target.y == -179, "Target park matches chrome lock")
assert(target.portraitSide == "right", "Target portrait is on the right")
assert(target.portrait.x == 232 - 42 - 64, "Target portrait is the Player hole mirrored")
assert(target.health.x == 232 - 106 - 119, "Target health is the Player slot mirrored")
assert(target.power.x == target.health.x, "Target power shares health x")
assert(target.nameBackground.x == 7 and target.nameBackground.width == 119, "Name Background is on the bar well")
assert(target.auras.relativePoint == "TOPRIGHT" and target.auras.x == 2, "auras sit 2px to the right")
assert(target.spellBar.relativeTo == "nameBackground" and target.spellBar.y == 2, "spell bar sits 2px above Name Background")
assert(target.healthText.relativeTo == "health" and target.healthText.x == 0, "mirrored Status Text keeps its Widget anchor")

local mirrored = Addon:MirrorUnitFrameLayout(Addon:BaselineUnitFrameLayout("player"))
assert(mirrored.portrait.x == target.portrait.x, "Mirror is the Target portrait x")
assert(mirrored.health.x == target.health.x, "Mirror is the Target health x")
assert(mirrored.portraitSide == "right", "Mirror flips portraitSide")

assert(Addon.Defaults.base.layout.player.portrait.x == 42, "Defaults seed Player Baseline")
assert(Addon.Defaults.base.layout.target.health.x == 7, "Defaults seed Target Baseline")

Addon.GetDB = function()
  return {
    defaultProfile = "Default",
    profiles = {
      Default = { layout = { player = { health = { y = -48 } } }, keybinds = {} },
    },
  }
end
Addon.GetCharDB = function()
  return { activeProfile = nil }
end
Addon.GetPlayerClass = function() return "MAGE" end
local eff = Addon:ResolveEffective("MAGE")
local applied = Addon:UnitFrameLayoutForApply(eff.layout, "player")
assert(applied.health.y == -48, "Profile Widget delta wins")
assert(applied.health.x == 106, "untouched Widget fields keep Baseline")
assert(applied.portrait.x == 42, "other Widgets keep Baseline")

local function fakeRegion()
  local region = { points = {}, shown = true }
  function region:SetSize(w, h) self.width, self.height = w, h end
  function region:SetWidth(w) self.width = w end
  function region:SetHeight(h) self.height = h end
  function region:GetWidth() return self.width or 0 end
  function region:GetHeight() return self.height or 0 end
  function region:ClearAllPoints() self.points = {} end
  function region:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function region:Show() self.shown = true end
  function region:Hide() self.shown = false end
  function region:SetFrameLevel(level) self.level = level end
  function region:GetFrameLevel() return self.level or 1 end
  return region
end

local host = fakeRegion()
host.widgets = {
  art = fakeRegion(),
  portrait = fakeRegion(),
  health = fakeRegion(),
  power = fakeRegion(),
  name = fakeRegion(),
  level = fakeRegion(),
  healthText = fakeRegion(),
  powerText = fakeRegion(),
}
Addon:PlaceUnitWidgets(host, player)
assert(host.width == 232 and host.height == 100, "place sizes the host")
assert(host.widgets.portrait.points[1][1] == "TOPLEFT", "portrait uses TOPLEFT")
assert(host.widgets.portrait.points[1][2] == host, "portrait anchors to the host")
assert(host.widgets.portrait.points[1][4] == 42, "portrait keeps Baseline x")
assert(host.widgets.healthText.points[1][2] == host.widgets.health, "health text anchors to health")
assert(host.widgets.level.points[1][2] == host.widgets.portrait, "level anchors to portrait")
assert(host.widgets.portrait.level == (host.level or 1) + 2, "place applies Widget stack")

local px, py = Addon:OffsetsForAnchor(
  { left = 42, bottom = 24, width = 64, height = 64 },
  { left = 0, bottom = 0, width = 232, height = 100 },
  "TOPLEFT",
  "TOPLEFT"
)
assert(px == 42 and py == -12, "portrait TOPLEFT on the host is Baseline 42, -12")

local rects = Addon:ResolveWidgetRects(player)
assert(rects.portrait.left == 42 and rects.portrait.bottom == 24, "solver places the portrait hole")
assert(rects.portrait.width == 64 and rects.portrait.height == 64, "solver keeps portrait size")
assert(rects.health.left == 106 and rects.health.width == 119, "solver places health")
assert(math.abs(rects.healthText.left - rects.health.left) < 0.01, "Status Text shares the health slot")
assert(math.abs(rects.level.left + rects.level.width / 2 - (rects.portrait.left + 32)) < 0.01,
  "level sits on the portrait centre")

local hx, hy = Addon:OffsetsForAnchor(
  { left = 106, bottom = 47, width = 119, height = 12 },
  { left = 0, bottom = 0, width = 232, height = 100 },
  "TOPLEFT",
  "TOPLEFT"
)
assert(hx == 106 and hy == -41, "health TOPLEFT on the host is Baseline 106, -41")

local textPatch = Addon:WidgetGeometryFromRect(
  player.healthText,
  { left = 106, bottom = 43, width = 119, height = 12 },
  { left = 106, bottom = 47, width = 119, height = 12 }
)
assert(textPatch.relativeTo == "health", "Status Text keeps its Widget relativeTo")
assert(textPatch.point == "CENTER" and textPatch.relativePoint == "CENTER", "Status Text keeps CENTER")
assert(textPatch.x == 0 and textPatch.y == -4, "a 4px drop becomes offset y -4")

local applied = Addon:UnitFrameLayoutForApply({
  player = { art = { width = 662, height = 31672478, x = -158, y = -10 } },
}, "player")
assert(applied.art.width == 232 and applied.art.height == 100, "insane Frame Art size is discarded")
assert(applied.art.x == 0, "Frame Art x outside the host is discarded")
assert(applied.art.y == -10, "a small Frame Art y crop is kept")
local clamped = Addon:ClampWidgetRect("art", { left = -20, bottom = -8, width = 900, height = 40 }, 232, 100)
assert(clamped.width == 232 and clamped.left == 0, "Frame Art crop stays on the host")
local profileStore = { layout = {} }
Addon.GetProfile = function()
  return profileStore
end
Addon.unitFrameMode = true
host.unitFrameId = "player"
host.left, host.bottom = 0, 0
host.GetLeft = function(self) return self.left end
host.GetBottom = function(self) return self.bottom end
host.widgets.health.left, host.widgets.health.bottom = 106, 47
host.widgets.health.GetLeft = function(self) return self.left end
host.widgets.health.GetBottom = function(self) return self.bottom end
host.widgets.healthText.left, host.widgets.healthText.bottom = 106, 43
host.widgets.healthText.width, host.widgets.healthText.height = 119, 12
host.widgets.healthText.GetLeft = function(self) return self.left end
host.widgets.healthText.GetBottom = function(self) return self.bottom end
host.widgets.healthText.GetPoint = function()
  return "CENTER", host, "CENTER", 0, 0
end
local persisted = Addon:PersistWidgetGeometry("player", "healthText", {
  left = 106, bottom = 43, width = 119, height = 12,
})
assert(persisted.healthText.relativeTo == "health", "persist does not flatten Status Text onto the host")
assert(persisted.healthText.y == -4, "persist writes the new offset")
assert(profileStore.layout.player.healthText.relativeTo == "health", "Profile keeps relativeTo")

print("unit_layout_spec OK")
