-- Obsolete Blizzard action-bar anchors must not move ShadowUI Bars off-screen.
-- Run: lua tests/db_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
local account = {
  base = {
    layout = {
      bar1 = {
        point = "TOP", relativeTo = "UIParent", relativePoint = "TOP",
        x = 0, y = -800,
      },
      bar2 = {
        point = "TOPLEFT", relativeTo = "MainActionBar", relativePoint = "BOTTOMLEFT",
        x = 4, y = -4, scale = 0.9,
      },
    },
  },
  classes = {
    ROGUE = {
      layout = {
        bar1 = {
          point = "BOTTOMLEFT", relativeTo = "MainMenuBarArtFrame",
          relativePoint = "BOTTOMLEFT", x = 8, y = 4, enabled = true,
        },
      },
      variants = {
        Combat = {
          layout = {
            bar3 = {
              point = "TOPLEFT", relativeTo = "MultiBarBottomLeft",
              relativePoint = "BOTTOMLEFT", x = 0, y = -4, fadeIdle = 0.2,
            },
          },
        },
      },
    },
  },
}
local character = {
  layout = {
    bar4 = {
      point = "TOPLEFT", relativeTo = "MultiBarBottomRight",
      relativePoint = "BOTTOMLEFT", x = 0, y = -4, iconShape = "circle",
    },
  },
}

_G.LibStub = function(name)
  if name == "AceAddon-3.0" then
    return { GetAddon = function() return Addon end }
  end
  if name == "AceDB-3.0" then
    return {
      New = function(_, dbName)
        local profile = dbName == "ShadowUIDB" and account or character
        return { profile = profile }
      end,
    }
  end
end

assert(loadfile(root .. "core/db.lua"))()
assert(loadfile(root .. "core/resolve.lua"))()
assert(loadfile(root .. "defaults/base.lua"))()
assert(loadfile(root .. "defaults/classes/ROGUE.lua"))()
Addon:SetupDB()

local safe = account.base.layout.bar1
assert(safe.relativeTo == "UIParent" and safe.point == "TOP" and safe.y == -800,
  "valid UIParent anchor stays unchanged")

local baseLegacy = account.base.layout.bar2
assert(baseLegacy.point == nil and baseLegacy.relativeTo == nil
  and baseLegacy.relativePoint == nil and baseLegacy.x == nil and baseLegacy.y == nil,
  "Base legacy Blizzard anchor fields are removed")
assert(baseLegacy.scale == 0.9, "Base non-anchor fields stay")

local rogueLegacy = account.classes.ROGUE.layout.bar1
assert(rogueLegacy.point == nil and rogueLegacy.relativeTo == nil
  and rogueLegacy.relativePoint == nil and rogueLegacy.x == nil and rogueLegacy.y == nil,
  "Rogue bar1 no longer follows MainMenuBarArtFrame")
assert(rogueLegacy.enabled == true, "Rogue enabled state stays")
local rogueEffective = Addon:ResolveEffective("ROGUE", nil, "class")
assert(rogueEffective.layout.bar1.enabled == true
  and rogueEffective.layout.bar1.relativeTo == "UIParent",
  "Rogue effective bar1 stays enabled on a visible parent")

local variantLegacy = account.classes.ROGUE.variants.Combat.layout.bar3
assert(variantLegacy.relativeTo == nil and variantLegacy.fadeIdle == 0.2,
  "Variant legacy anchor is removed without changing fade")

local charLegacy = character.layout.bar4
assert(charLegacy.relativeTo == nil and charLegacy.iconShape == "circle",
  "Character legacy anchor is removed without changing shape")

print("db_spec OK")
