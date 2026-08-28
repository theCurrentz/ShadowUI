--[[
  Purpose: AceConfig panel for variants, talent binding, Action Slot hard lock,
  ShadowUI vs Blizzard menu, on/off toggles for every Bar including pet and possess,
  edit layers, and resets. Bar toggles read Layout through the selected Layer.
  Deps: AceConfig-3.0, AceConfigDialog-3.0, profile and edit-layer helpers
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
  db.classes[class] = db.classes[class] or { layout = {}, keybinds = {}, actions = {}, variants = {} }
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
local HOST_LAYOUT = { player = true, target = true, cast = true, range = true, stance = true }
local BAR_TOGGLE_IDS = {
  "bar1", "bar2", "bar3", "bar4", "bar5", "bar6", "bar7", "bar8", "bar9", "bar10",
  "pet", "possess",
}
local function barToggleName(id)
  local index = id:match("^bar(%d+)$")
  if index then
    return "Bar " .. index
  end
  return (id:sub(1, 1):upper() .. id:sub(2))
end
local function shippedBarLayout(id)
  local defaults = Addon.Defaults
  if not defaults then
    return nil
  end
  local base = defaults.base and defaults.base.layout
  return base and base[id]
end
local function barTogglePatch(id, value)
  local patch = { enabled = value and true or false }
  if not value or not Addon.DeepCopy then
    return patch
  end
  local current = (Addon:ResolveEffective(nil, nil, Addon:GetCharDB().editLayer or "variant").layout or {})[id]
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
local function barToggleArgs()
  local args = {}
  for order, id in ipairs(BAR_TOGGLE_IDS) do
    args[id] = {
      type = "toggle", name = barToggleName(id), order = order,
      desc = "On shows the Bar. Off hides it. Reads and writes the selected Layer.",
      hidden = function()
        return HOST_LAYOUT[id] == true
      end,
      get = function()
        local layer = Addon:GetCharDB().editLayer or "variant"
        local bar = (Addon:ResolveEffective(nil, nil, layer).layout or {})[id]
        return not bar or bar.enabled ~= false
      end,
      set = function(_, value)
        Addon:WriteLayerDelta(Addon:GetCharDB().editLayer, "layout", id, barTogglePatch(id, value))
        Addon:ApplyAll()
      end,
    }
  end
  return args
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
    variants = {
      type = "group", name = "Variants", order = 10, inline = true,
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
    layer = {
      type = "select", name = "Current edit layer", order = 17,
      desc = "Writes and Action bar toggles use this Layer: Base, Class, Variant, or Character.",
      values = { base = "Base", class = "Class", variant = "Variant", character = "Character" },
      get = function() return Addon:GetCharDB().editLayer or "variant" end,
      set = function(_, value) Addon:SetEditLayer(value) end,
    },
    bars = {
      type = "group", name = "Action bars", order = 18, inline = true,
      args = barToggleArgs(),
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
    shiftAndPrune = {
      type = "execute", name = "Shift and Prune", order = 22.5,
      desc = "Pack Keybinds left and drop gaps with no Keybind. Actions on those Keybinds move with them. The pack wraps to the next row and continues onto the next Bar. Writes go to the selected Layer. Out of combat only.",
      confirm = true,
      func = function()
        Addon:ShiftAndPruneBars()
      end,
    },
    deck = {
      type = "group", name = "Action Deck", order = 23, inline = true,
      args = {
        from = {
          type = "select", name = "Loadout", order = 10,
          desc = "Class still includes the active Variant, matching the Macro Cursor Action Bars. Variant skips Character. Character is this toon on top.",
          values = { class = "Class", variant = "Variant", character = "Character" },
          get = function()
            return Addon:GetCharDB().placeDeckFrom or "character"
          end,
          set = function(_, value)
            Addon:GetCharDB().placeDeckFrom = value
          end,
        },
        place = {
          type = "execute", name = "Place Action Deck", order = 20,
          desc = "Replace the General and character macro tabs with the selected loadout macros, then overwrite its Action Slots. Out of combat only. Does not change Keybinds.",
          confirm = true,
          func = function()
            Addon:PlaceDeck()
          end,
        },
      },
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
}
function Addon:OpenOptions()
  if not self._optionsRegistered then
    AceConfig:RegisterOptionsTable("ShadowUI", options)
    self._optionsRegistered = true
  end
  AceConfigDialog:Open("ShadowUI")
end
