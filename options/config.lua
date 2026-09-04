--[[
  Purpose: AceConfig panel for variants, Character controls, Bars, Bar Groups,
           Cooldown Manager, Experience bar fade, Loadout Snapshots, edit
           sessions, Layers, and resets.
  Deps: AceConfig-3.0, AceConfigDialog-3.0, options/nav.lua, options/scroll.lua,
        profile/loadout/edit-layer helpers
  Public: ShadowUI:OpenOptions()
]]
local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local function clean(value)
  return type(value) == "string" and value:match("^%s*(.-)%s*$") or ""
end
local function classData()
  local db = Addon:GetDB()
  local class = Addon:GetPlayerClass()
  db.classes[class] = db.classes[class] or { layout = {}, keybinds = {}, variants = {} }
  return db.classes[class]
end
local function activeName()
  return Addon:GetActiveVariantName()
end
local function activeVariant()
  local name = activeName()
  return name and classData().variants[name]
end
local function shippedVariants()
  local defaults = Addon.Defaults
  local class = Addon:GetPlayerClass()
  local shipped = defaults and defaults.classes and defaults.classes[class]
  return shipped and shipped.variants or {}
end
local function variantValues()
  local values = {}
  for name in pairs(shippedVariants()) do
    values[name] = name
  end
  for name in pairs(classData().variants) do
    values[name] = name
  end
  return values
end
local HOST_LAYOUT = {
  player = true, target = true, cast = true, range = true, stance = true, cooldown = true,
  global = true, barGroups = true,
}
local BAR_TOGGLE_IDS = {
  "bar1", "bar2", "bar3", "bar4", "bar5", "bar6", "bar7", "bar8", "bar9", "bar10",
  "pet", "possess",
}
local MAX_BAR_GROUPS = 8
local RESERVED_GROUP_NAMES = {
  global = true, barGroups = true,
  player = true, target = true, cast = true, range = true, stance = true, cooldown = true,
}
for _, id in ipairs(BAR_TOGGLE_IDS) do
  RESERVED_GROUP_NAMES[id] = true
end
local function barToggleName(id)
  local index = id:match("^bar(%d+)$")
  if index then
    return "Bar " .. index
  end
  return (id:sub(1, 1):upper() .. id:sub(2))
end
local BAR_MEMBER_VALUES = {}
for _, id in ipairs(BAR_TOGGLE_IDS) do
  BAR_MEMBER_VALUES[id] = barToggleName(id)
end
local ICON_SHAPES = { square = "Square", circle = "Circle", diamond = "Diamond" }
local function shippedBarLayout(id)
  local defaults = Addon.Defaults
  if not defaults then
    return nil
  end
  local base = defaults.base and defaults.base.layout
  return base and base[id]
end
local function layerLayout()
  local layer = Addon:GetCharDB().editLayer or "variant"
  return (Addon:ResolveEffective(nil, nil, layer).layout or {})
end
local function layerBar(id)
  return layerLayout()[id]
end
local function barVisual(id)
  local layout = layerLayout()
  if Addon.ResolveBarVisual then
    return Addon:ResolveBarVisual(layout, id, layout[id])
  end
  local bar = layout[id] or {}
  return {
    gap = bar.gap or 0,
    iconShape = bar.iconShape or "square",
    scale = bar.scale or 1,
    fadeIdle = bar.fadeIdle or 1,
  }
end
local function groupNames()
  local names = {}
  local groups = layerLayout().barGroups or {}
  for name, cfg in pairs(groups) do
    if type(cfg) == "table" then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names
end
local function barGroupValues()
  local values = { [""] = "None" }
  for _, name in ipairs(groupNames()) do
    values[name] = name
  end
  return values
end
local function writeBarPatch(id, patch)
  Addon:WriteLayerDelta(Addon:GetCharDB().editLayer, "layout", id, patch)
  Addon:ApplyAll()
end
local function barTogglePatch(id, value)
  local patch = { enabled = value and true or false }
  if not value or not Addon.DeepCopy then
    return patch
  end
  local current = layerBar(id)
  if current and current.buttons then
    return patch
  end
  local shipped = shippedBarLayout(id)
  if not shipped then
    return patch
  end
  patch = Addon:DeepCopy(shipped)
  patch.enabled = true
  return patch
end
local function barInGroup(id)
  local bar = layerBar(id)
  local groupName = bar and bar.group
  if type(groupName) ~= "string" or groupName == "" then
    return false
  end
  local groups = layerLayout().barGroups or {}
  return type(groups[groupName]) == "table"
end
local function barGapPad(id, field, legacyKey)
  local bar = layerBar(id)
  if not bar then
    return 0
  end
  if bar[field] ~= nil then
    return bar[field]
  end
  local rg = bar.rowGaps and bar.rowGaps[1]
  return (rg and rg[legacyKey]) or 0
end
local function barGroupArgs()
  local args = {}
  for order, id in ipairs(BAR_TOGGLE_IDS) do
    local barArgs = {
      enabled = {
        type = "toggle", name = "Enabled", order = 1,
        desc = "On shows the Bar. Off hides it. Reads and writes the selected Layer.",
        get = function()
          local bar = layerBar(id)
          return not bar or bar.enabled ~= false
        end,
        set = function(_, value)
          writeBarPatch(id, barTogglePatch(id, value))
        end,
      },
      group = {
        type = "select", name = "Group", order = 1.5,
        desc = "Put this Bar in a Bar Group so it inherits that group's settings.",
        values = barGroupValues,
        get = function()
          local bar = layerBar(id)
          local name = bar and bar.group
          if type(name) == "string" and name ~= "" then
            return name
          end
          return ""
        end,
        set = function(_, value)
          writeBarPatch(id, { group = value ~= "" and value or false })
        end,
      },
      scale = {
        type = "range", name = "Scale", order = 2,
        desc = "Bar scale on the selected Layer. Layout Edit Mode does not change scale.",
        min = 0.6, max = 1.4, step = 0.05,
        get = function()
          return barVisual(id).scale
        end,
        set = function(_, value)
          writeBarPatch(id, { scale = value })
        end,
      },
      gap = {
        type = "range", name = "Gap between", order = 3,
        desc = "Pixels between Action Slots on this Bar.",
        min = 0, max = 16, step = 1,
        get = function()
          return barVisual(id).gap
        end,
        set = function(_, value)
          writeBarPatch(id, { gap = value })
        end,
      },
      fadeIdle = {
        type = "range", name = "Fade idle", order = 4,
        desc = "Idle alpha for this Bar. 1 keeps the Bar fully visible.",
        min = 0, max = 1, step = 0.05,
        get = function()
          return barVisual(id).fadeIdle
        end,
        set = function(_, value)
          writeBarPatch(id, { fadeIdle = value })
        end,
      },
      iconShape = {
        type = "select", name = "Shape", order = 5,
        desc = "Action Slot icon shape on the selected Layer.",
        values = ICON_SHAPES,
        get = function()
          return barVisual(id).iconShape
        end,
        set = function(_, value)
          writeBarPatch(id, { iconShape = value })
        end,
      },
      gapAbove = {
        type = "range", name = "Gap above", order = 6,
        desc = "Padding above this Bar. Icons shrink so the Bar size does not change.",
        min = 0, max = 64, step = 1,
        hidden = function()
          return barInGroup(id)
        end,
        get = function()
          return barGapPad(id, "gapAbove", "above")
        end,
        set = function(_, value)
          writeBarPatch(id, { gapAbove = value })
        end,
      },
      gapBelow = {
        type = "range", name = "Gap below", order = 7,
        desc = "Padding below this Bar. Icons shrink so the Bar size does not change.",
        min = 0, max = 64, step = 1,
        hidden = function()
          return barInGroup(id)
        end,
        get = function()
          return barGapPad(id, "gapBelow", "below")
        end,
        set = function(_, value)
          writeBarPatch(id, { gapBelow = value })
        end,
      },
    }
    args[id] = {
      type = "group", name = barToggleName(id), order = order,
      hidden = function()
        return HOST_LAYOUT[id] == true
      end,
      args = barArgs,
    }
  end
  return args
end
local function groupField(name, field, fallback)
  local groups = layerLayout().barGroups or {}
  local group = name and groups[name]
  if type(group) == "table" and group[field] ~= nil then
    return group[field]
  end
  local global = layerLayout().global or {}
  if (field == "gap" or field == "iconShape") and global[field] ~= nil then
    return global[field]
  end
  return fallback
end
local function barGroupsArgs()
  local args = {
    create = {
      type = "input", name = "Create group", order = 1,
      desc = "Name a Bar Group, then assign Bars to it.",
      set = function(_, value)
        value = clean(value)
        if value == "" or RESERVED_GROUP_NAMES[value] then
          return
        end
        local names = groupNames()
        if #names >= MAX_BAR_GROUPS then
          return
        end
        for _, existing in ipairs(names) do
          if existing == value then
            return
          end
        end
        writeBarPatch("barGroups", { [value] = {} })
      end,
    },
  }
  for index = 1, MAX_BAR_GROUPS do
    local function name()
      return groupNames()[index]
    end
    args["group" .. index] = {
      type = "group", name = function() return name() or "" end, order = 10 + index,
      inline = true,
      hidden = function()
        return name() == nil
      end,
      args = {
        members = {
          type = "multiselect", name = "Bars", order = 1,
          desc = "Bars in this Bar Group inherit its settings unless a Bar sets its own.",
          values = BAR_MEMBER_VALUES,
          get = function(_, barId)
            local bar = layerBar(barId)
            return bar and bar.group == name()
          end,
          set = function(_, barId, value)
            local groupName = name()
            if not groupName then
              return
            end
            writeBarPatch(barId, { group = value and groupName or false })
          end,
        },
        scale = {
          type = "range", name = "Scale", order = 2,
          min = 0.6, max = 1.4, step = 0.05,
          get = function() return groupField(name(), "scale", 1) end,
          set = function(_, value)
            local groupName = name()
            if groupName then
              writeBarPatch("barGroups", { [groupName] = { scale = value } })
            end
          end,
        },
        gap = {
          type = "range", name = "Gap between", order = 3,
          min = 0, max = 16, step = 1,
          get = function() return groupField(name(), "gap", 0) end,
          set = function(_, value)
            local groupName = name()
            if groupName then
              writeBarPatch("barGroups", { [groupName] = { gap = value } })
            end
          end,
        },
        gapAbove = {
          type = "range", name = "Gap above", order = 3.5,
          desc = "Padding above each Bar in this Bar Group. Icons shrink so the Bar size does not change.",
          min = 0, max = 64, step = 1,
          get = function() return groupField(name(), "gapAbove", 0) end,
          set = function(_, value)
            local groupName = name()
            if groupName then
              writeBarPatch("barGroups", { [groupName] = { gapAbove = value } })
            end
          end,
        },
        gapBelow = {
          type = "range", name = "Gap below", order = 3.6,
          desc = "Padding below each Bar in this Bar Group. Icons shrink so the Bar size does not change.",
          min = 0, max = 64, step = 1,
          get = function() return groupField(name(), "gapBelow", 0) end,
          set = function(_, value)
            local groupName = name()
            if groupName then
              writeBarPatch("barGroups", { [groupName] = { gapBelow = value } })
            end
          end,
        },
        fadeIdle = {
          type = "range", name = "Fade idle", order = 4,
          min = 0, max = 1, step = 0.05,
          get = function() return groupField(name(), "fadeIdle", 1) end,
          set = function(_, value)
            local groupName = name()
            if groupName then
              writeBarPatch("barGroups", { [groupName] = { fadeIdle = value } })
            end
          end,
        },
        iconShape = {
          type = "select", name = "Shape", order = 5,
          values = ICON_SHAPES,
          get = function() return groupField(name(), "iconShape", "square") end,
          set = function(_, value)
            local groupName = name()
            if groupName then
              writeBarPatch("barGroups", { [groupName] = { iconShape = value } })
            end
          end,
        },
        shiftAndPrune = {
          type = "execute", name = "Shift and Prune", order = 5.5,
          desc = "Pack Keybinds left on Bars in this Bar Group and drop gaps with no Keybind. Actions on those Keybinds move with them. The pack wraps to the next row and continues onto the next Bar in this Bar Group. Writes go to the selected Layer. Out of combat only.",
          confirm = true,
          func = function()
            local groupName = name()
            if groupName then
              Addon:ShiftAndPruneBars(groupName)
            end
          end,
        },
        delete = {
          type = "execute", name = "Delete group", order = 6, confirm = true,
          func = function()
            local groupName = name()
            if not groupName then
              return
            end
            for _, id in ipairs(BAR_TOGGLE_IDS) do
              local bar = layerBar(id)
              if bar and bar.group == groupName then
                writeBarPatch(id, { group = false })
              end
            end
            writeBarPatch("barGroups", { [groupName] = false })
          end,
        },
      },
    }
  end
  return args
end
local function actionBarArgs()
  local args = barGroupArgs()
  args.global = {
    type = "group", name = "Global", order = 0.1,
    desc = "Gap and shape for every Bar that does not set its own, and is not in a Bar Group that sets them.",
    args = {
      gap = {
        type = "range", name = "Gap between", order = 1,
        desc = "Pixels between Action Slots on every Bar that inherits Global.",
        min = 0, max = 16, step = 1,
        get = function()
          local global = layerLayout().global or {}
          if global.gap ~= nil then
            return global.gap
          end
          return 0
        end,
        set = function(_, value)
          writeBarPatch("global", { gap = value })
        end,
      },
      iconShape = {
        type = "select", name = "Shape", order = 2,
        desc = "Action Slot icon shape for every Bar that inherits Global.",
        values = ICON_SHAPES,
        get = function()
          local global = layerLayout().global or {}
          return global.iconShape or "square"
        end,
        set = function(_, value)
          writeBarPatch("global", { iconShape = value })
        end,
      },
    },
  }
  args.groups = {
    type = "group", name = "Groups", order = 0.2,
    desc = "Bar Groups share settings. A Bar in a group inherits those settings unless it sets its own.",
    args = barGroupsArgs(),
  }
  return args
end
local function cooldownLayout()
  return layerBar("cooldown") or {}
end
local function cooldownSpellArgs()
  local args = {}
  for i = 1, 32 do
    args["spell" .. i] = {
      type = "toggle", name = function()
        local list = Addon.CooldownSpellList and Addon:CooldownSpellList() or {}
        local spell = list[i]
        if not spell then
          return ""
        end
        if GetSpellInfo then
          local live = GetSpellInfo(spell.spellId)
          if live then
            return live
          end
        end
        return spell.label or tostring(spell.spellId)
      end, order = i,
      hidden = function()
        local list = Addon.CooldownSpellList and Addon:CooldownSpellList() or {}
        return list[i] == nil
      end,
      get = function()
        local list = Addon.CooldownSpellList and Addon:CooldownSpellList() or {}
        local spell = list[i]
        if not spell or not Addon.CooldownSpellHidden then
          return true
        end
        return not Addon:CooldownSpellHidden(spell.spellId)
      end,
      set = function(_, value)
        local list = Addon.CooldownSpellList and Addon:CooldownSpellList() or {}
        local spell = list[i]
        if spell and Addon.SetCooldownSpellHidden then
          Addon:SetCooldownSpellHidden(spell.spellId, not value)
          if Addon.ApplyCooldownManager then
            Addon:ApplyCooldownManager()
          end
        end
      end,
    }
  end
  return args
end
local LOADOUT_BAR_VALUES = {
  bar1 = "Bar 1", bar2 = "Bar 2", bar3 = "Bar 3", bar4 = "Bar 4", bar5 = "Bar 5",
  bar6 = "Bar 6", bar7 = "Bar 7", bar8 = "Bar 8", bar9 = "Bar 9", bar10 = "Bar 10",
  pet = "Pet", possess = "Possess",
}
local loadoutUI = {
  source = nil,
  options = nil,
  preview = "Save this Character or select a source Loadout Snapshot.",
}
local function loadoutOptions()
  if not loadoutUI.options then
    loadoutUI.options = Addon:DefaultLoadoutOptions()
  end
  return loadoutUI.options
end
local function loadoutSnapshot()
  return loadoutUI.source and (Addon:GetDB().loadouts or {})[loadoutUI.source] or nil
end
local function loadoutValues()
  local values = Addon:LoadoutValues()
  if loadoutUI.source and not values[loadoutUI.source] then
    loadoutUI.source = nil
  end
  return values
end
local function sourcePageValues()
  local values = { [0] = "Skip main Bar" }
  local snapshot = loadoutSnapshot()
  local pages = snapshot and snapshot.actions and snapshot.actions.bar1
    and snapshot.actions.bar1.pages or {}
  for index, page in ipairs(pages) do
    values[index] = ("Page %d (slots %d-%d)"):format(index, page.firstSlot, page.firstSlot + 11)
  end
  return values
end
local function targetPageValues()
  local values = { [0] = "Skip main Bar" }
  local layout = (Addon:ResolveEffective().layout or {}).bar1 or {}
  local pages = { Addon:FirstActionSlot("bar1", layout) }
  for index, first in ipairs(pages) do
    values[index] = ("Page %d (slots %d-%d)"):format(index, first, first + 11)
  end
  return values
end
local function isCrossClass()
  local snapshot = loadoutSnapshot()
  return snapshot and snapshot.class ~= Addon:GetPlayerClass()
end
local function needsPageMap()
  local snapshot = loadoutSnapshot()
  local pages = snapshot and snapshot.actions and snapshot.actions.bar1
    and snapshot.actions.bar1.pages or {}
  return isCrossClass() and #pages > 1
end
local function previewLoadout()
  if not loadoutUI.source then
    loadoutUI.preview = "Select a source Loadout Snapshot."
    return nil
  end
  local plan = Addon:BuildLoadoutPlan(loadoutUI.source, loadoutOptions())
  loadoutUI.preview = Addon:DescribeLoadoutPlan(plan)
  Addon:Print(loadoutUI.preview)
  for _, warning in ipairs(plan.warnings or {}) do
    Addon:Print(warning)
  end
  return plan
end
local function resetLayer()
  local layer = Addon:GetCharDB().editLayer or "variant"
  local db = Addon:GetDB()
  if layer == "base" then
    db.base = { layout = {}, keybinds = {} }
  elseif layer == "class" then
    local class = classData()
    class.layout, class.keybinds = {}, {}
  else
    local variant = activeVariant()
    if variant then
      variant.layout, variant.keybinds = {}, {}
    end
  end
  Addon:ApplyAll()
end
local options = {
  type = "group", name = "ShadowUI",
  childGroups = "tree",
  args = {
    search = {
      type = "input", name = "Search", order = 0, width = "full",
      desc = "Filter the outline by name or description.",
      get = function()
        return Addon:GetOptionsSearch()
      end,
      set = function(_, value)
        Addon:SetOptionsSearch(value)
      end,
    },
    general = {
      type = "group", name = "General", order = 1,
      args = {
        version = {
          type = "description", name = function()
            local version = Addon.GetVersion and Addon:GetVersion() or "ERA"
            if version == "TBC" then
              return "Version: TBC"
            end
            return "Version: Era"
          end, order = 1,
        },
        hardLockActionSlots = {
      type = "toggle", name = "Hard lock action slots", order = 15,
      desc = "Block Shift-drag and Shift+Alt insert between Action Slots. A click still uses the action. Without this, bars stay locked: a click uses the action, Shift-drag moves a spell or item, and Shift+Alt drag inserts.",
      get = function() return Addon:GetCharDB().hardLockActionSlots == true end,
      set = function(_, value) Addon:SetActionSlotHardLock(value) end,
    },
    useShadowUIMenu = {
      type = "toggle", name = "Use ShadowUI menu", order = 16,
      desc = "On: dock the micro menu and backpack in the ShadowUI Micro Cluster. Off: use the default Blizzard menu and bags.",
      get = function() return Addon:GetCharDB().useShadowUIMenu ~= false end,
      set = function(_, value)
        Addon:GetCharDB().useShadowUIMenu = value and true or false
        Addon:ApplyAll()
      end,
    },
    microFadeIdle = {
      type = "range", name = "Micro Cluster fade idle", order = 16.1,
      desc = "Idle alpha for the Micro Cluster. 1 keeps the row fully visible.",
      min = 0, max = 1, step = 0.05,
      get = function()
        local idle = Addon:GetCharDB().microFadeIdle
        if idle == nil then
          return 1
        end
        return idle
      end,
      set = function(_, value)
        Addon:GetCharDB().microFadeIdle = value
        Addon:ApplyAll()
      end,
    },
    microIconShape = {
      type = "select", name = "Micro Cluster shape", order = 16.2,
      desc = "Icon shape for the Micro Cluster. Square keeps native micro art.",
      values = ICON_SHAPES,
      get = function()
        return Addon:GetCharDB().microIconShape or "square"
      end,
      set = function(_, value)
        Addon:GetCharDB().microIconShape = value
        Addon:ApplyAll()
      end,
    },
    xpFadeIdle = {
      type = "range", name = "Experience bar fade idle", order = 16.3,
      desc = "Idle alpha for the Experience bar. 1 keeps the bar fully visible.",
      min = 0, max = 1, step = 0.05,
      get = function()
        local idle = Addon:GetCharDB().xpFadeIdle
        if idle == nil then
          return 1
        end
        return idle
      end,
      set = function(_, value)
        Addon:GetCharDB().xpFadeIdle = value
        Addon:ApplyAll()
      end,
    },
    layer = {
      type = "select", name = "Current edit layer", order = 17,
      desc = "Writes and Action bar controls use this Layer: Base, Class, Variant, or Character.",
      values = { base = "Base", class = "Class", variant = "Variant", character = "Character" },
      get = function() return Addon:GetCharDB().editLayer or "variant" end,
      set = function(_, value) Addon:SetEditLayer(value) end,
    },
        editLayout = {
          type = "execute", name = "Edit layout", order = 21,
          desc = "Move Bars on the snap grid. Hold Shift to skip snap. Writes go to the selected Layer.",
          func = function()
            AceConfigDialog:Close("ShadowUI")
            Addon:ToggleEditMode()
          end,
        },
        editKeybinds = {
          type = "execute", name = "Edit keybinds", order = 22,
          desc = "Hover a button and press a key. Writes go to the selected Layer. Does not write SavedBindings.",
          func = function()
            AceConfigDialog:Close("ShadowUI")
            Addon:ToggleKeybindMode()
          end,
        },
        resetLayer = {
          type = "execute", name = "Reset selected layer deltas", order = 30,
          confirm = true, func = resetLayer,
        },
        resetAccount = {
          type = "execute", name = "Reset account profile", order = 40,
          desc = "Clear account overrides. Shipped defaults remain.",
          confirm = true,
          func = function() Addon.db:ResetProfile(); Addon:ApplyAll() end,
        },
      },
    },
    variants = {
      type = "group", name = "Variants", order = 10,
      args = {
        active = {
          type = "select", name = "Active variant", order = 10,
          values = variantValues, get = activeName,
          set = function(_, value) Addon:SetVariant(value, true) end,
        },
        create = {
          type = "input", name = "Create variant", order = 20,
          set = function(_, value)
            value = clean(value)
            if value ~= "" then Addon:CreateVariant(value); Addon:SetVariant(value, true) end
          end,
        },
        rename = {
          type = "input", name = "Rename active variant", order = 30,
          disabled = function() return not activeVariant() end,
          set = function(_, value)
            value = clean(value)
            local current = activeName()
            if value ~= "" and current and Addon:RenameVariant(current, value) then Addon:ApplyAll() end
          end,
        },
        delete = {
          type = "execute", name = "Delete active variant", order = 40,
          disabled = function() return not activeVariant() end,
          confirm = true,
          func = function()
            local current = activeName()
            if current and Addon:DeleteVariant(current) then Addon:ApplyAll() end
          end,
        },
        talent = {
          type = "select", name = "Talent tree", order = 50,
          values = { [0] = "None", [1] = "Tree 1", [2] = "Tree 2", [3] = "Tree 3" },
          disabled = function() return not activeVariant() end,
          get = function() return activeVariant() and activeVariant().talentTree or 0 end,
          set = function(_, value)
            activeVariant().talentTree = value ~= 0 and value or nil
            Addon:ApplyAll()
          end,
        },
      },
    },
    bars = {
      type = "group", name = "Action bars", order = 18, childGroups = "tree",
      args = actionBarArgs(),
    },
    cooldown = {
      type = "group", name = "Cooldown manager", order = 18.5,
      args = {
        enabled = {
          type = "toggle", name = "Enabled", order = 1,
          desc = "On shows the Cooldown Manager. Off hides it. Reads and writes the selected Layer.",
          get = function()
            local cfg = cooldownLayout()
            return cfg.enabled ~= false
          end,
          set = function(_, value)
            writeBarPatch("cooldown", { enabled = value and true or false })
          end,
        },
        scale = {
          type = "range", name = "Scale", order = 2,
          desc = "Cooldown Manager scale on the selected Layer.",
          min = 0.6, max = 1.4, step = 0.05,
          get = function()
            return cooldownLayout().scale or 1
          end,
          set = function(_, value)
            writeBarPatch("cooldown", { scale = value })
          end,
        },
        gap = {
          type = "range", name = "Gap", order = 3,
          desc = "Space between cooldown icons.",
          min = 0, max = 16, step = 1,
          get = function()
            local gap = cooldownLayout().gap
            if gap == nil then
              return 4
            end
            return gap
          end,
          set = function(_, value)
            writeBarPatch("cooldown", { gap = value })
          end,
        },
        direction = {
          type = "select", name = "Direction", order = 4,
          desc = "Grow Right, Left, Up, or Down. Layout Edit Mode resize sets wrap.",
          values = { right = "Right", left = "Left", up = "Up", down = "Down" },
          get = function()
            if Addon.CooldownDirection then
              return Addon:CooldownDirection(cooldownLayout())
            end
            return cooldownLayout().direction or "right"
          end,
          set = function(_, value)
            writeBarPatch("cooldown", {
              direction = value,
              vertical = value == "up" or value == "down",
            })
          end,
        },
        max = {
          type = "range", name = "Maximum", order = 5,
          desc = "Maximum cooldown icons in the queue.",
          min = 1, max = 24, step = 1,
          get = function()
            return cooldownLayout().max or 8
          end,
          set = function(_, value)
            writeBarPatch("cooldown", { max = value })
          end,
        },
        spells = {
          type = "group", name = "Spells", order = 6, inline = true,
          desc = "Choose which class cooldowns enter the queue. Off hides that spell for this Class.",
          args = cooldownSpellArgs(),
        },
      },
    },
    loadouts = {
      type = "group", name = "Loadouts", order = 19,
      args = {
        save = {
          type = "execute", name = "Save / update this Character", order = 1,
          desc = "Capture this Character's current Layout, Keybinds, macros, and standard Action Slots.",
          func = function()
            loadoutUI.source = Addon:SaveCurrentLoadout()
            loadoutUI.preview = "Saved " .. loadoutUI.source
          end,
        },
        source = {
          type = "select", name = "Copy from", order = 2,
          values = loadoutValues,
          get = function() return loadoutUI.source end,
          set = function(_, value)
            loadoutUI.source = value
            loadoutUI.preview = "Choose what to copy, then preview."
          end,
        },
        actions = {
          type = "toggle", name = "Actions", order = 10,
          desc = "Copy spells, items, macros, and empty slots from selected standard Bars.",
          get = function() return loadoutOptions().actions end,
          set = function(_, value) loadoutOptions().actions = value end,
        },
        macros = {
          type = "toggle", name = "Required macros", order = 11,
          desc = "Create missing macros in the target Character tab. Account macros are never overwritten.",
          disabled = function() return not loadoutOptions().actions end,
          get = function() return loadoutOptions().macros end,
          set = function(_, value) loadoutOptions().macros = value end,
        },
        keybinds = {
          type = "toggle", name = "Keybinds", order = 12,
          desc = "Copy the actual keys by physical Bar and button position.",
          get = function() return loadoutOptions().keybinds end,
          set = function(_, value) loadoutOptions().keybinds = value end,
        },
        barLayout = {
          type = "toggle", name = "Bar Layout", order = 13,
          desc = "Copy Bar place, columns, scale, enabled state, and visual fields. Keep target Class slot routing.",
          get = function() return loadoutOptions().barLayout end,
          set = function(_, value) loadoutOptions().barLayout = value end,
        },
        otherLayout = {
          type = "toggle", name = "Other Layout hosts", order = 14,
          desc = "Also copy Player Frame, Target Frame, Cast Bar, Range Display, and Stance Bar place.",
          get = function() return loadoutOptions().otherLayout end,
          set = function(_, value) loadoutOptions().otherLayout = value end,
        },
        selectedBars = {
          type = "multiselect", name = "Selected Bars", order = 20,
          values = LOADOUT_BAR_VALUES,
          get = function(_, key) return loadoutOptions().selectedBars[key] ~= false end,
          set = function(_, key, value) loadoutOptions().selectedBars[key] = value end,
        },
        includeDisabledBars = {
          type = "toggle", name = "Include disabled source Bars", order = 20.5,
          desc = "Also copy Actions and Keybinds from source Bars that are off.",
          get = function() return loadoutOptions().includeDisabledBars end,
          set = function(_, value) loadoutOptions().includeDisabledBars = value end,
        },
        exact = {
          type = "toggle", name = "Clear source empty slots", order = 21,
          desc = "Off merges filled source actions into the target. On also clears target slots that are empty in the source.",
          disabled = function() return not loadoutOptions().actions end,
          get = function() return loadoutOptions().exact end,
          set = function(_, value) loadoutOptions().exact = value end,
        },
        macroConflict = {
          type = "select", name = "Macro name conflicts", order = 22,
          values = {
            skip = "Skip the action",
            ["character-copy"] = "Create a unique Character macro",
          },
          disabled = function() return not loadoutOptions().actions or not loadoutOptions().macros end,
          get = function() return loadoutOptions().macroConflict end,
          set = function(_, value) loadoutOptions().macroConflict = value end,
        },
        sourcePage = {
          type = "select", name = "Legacy source main-Bar page", order = 23,
          desc = "Old Loadout Snapshots can contain multiple main-Bar pages.",
          hidden = function() return not needsPageMap() end,
          values = sourcePageValues,
          get = function() return loadoutOptions().sourcePage or 0 end,
          set = function(_, value) loadoutOptions().sourcePage = value end,
        },
        targetPage = {
          type = "select", name = "Fixed target main-Bar range", order = 24,
          hidden = function() return not needsPageMap() end,
          values = targetPageValues,
          get = function() return loadoutOptions().targetPage or 0 end,
          set = function(_, value) loadoutOptions().targetPage = value end,
        },
        previewText = {
          type = "description", name = function() return loadoutUI.preview end, order = 30,
        },
        preview = {
          type = "execute", name = "Preview copy", order = 31,
          disabled = function() return not loadoutUI.source end,
          func = previewLoadout,
        },
        apply = {
          type = "execute", name = "Apply copy", order = 32,
          desc = "Apply the current choices to this Character. A rolling backup is saved first.",
          disabled = function() return not loadoutUI.source end,
          confirm = true,
          func = function()
            local plan = previewLoadout()
            if plan then Addon:ApplyLoadoutPlan(plan) end
          end,
        },
        restore = {
          type = "execute", name = "Restore last backup", order = 33,
          desc = "Restore the target state saved before the last Loadout copy.",
          disabled = function()
            return not (Addon:GetDB().loadouts or {})[Addon:BackupLoadoutKey()]
          end,
          confirm = true,
          func = function() Addon:RestoreLoadoutBackup() end,
        },
        delete = {
          type = "execute", name = "Delete source snapshot", order = 34,
          disabled = function() return not loadoutUI.source end,
          confirm = true,
          func = function()
            if Addon:DeleteLoadout(loadoutUI.source) then
              loadoutUI.source = nil
              loadoutUI.preview = "Loadout Snapshot deleted."
            end
          end,
        },
      },
    },
  },
}
function Addon:OpenOptions()
  if not self._optionsRegistered then
    self._optionsTable = options
    self:KeepOptionsSearch(options.args.search)
    self:InstallOptionsSearchHide(options)
    self:MarkOptionsSearch(options)
    AceConfig:RegisterOptionsTable("ShadowUI", options)
    if AceConfigDialog.SetDefaultSize then
      AceConfigDialog:SetDefaultSize("ShadowUI", 840, 560)
    end
    self._optionsRegistered = true
  end
  AceConfigDialog:Open("ShadowUI")
end
