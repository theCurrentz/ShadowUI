--[[
  Purpose: AceConfig panel for variants, talent binding, edit layers, and resets.
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
local function variantValues()
  local values = {}
  for name in pairs(classData().variants) do
    values[name] = name
  end
  return values
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
    layer = {
      type = "select", name = "Current edit layer", order = 20,
      values = { base = "Base", class = "Class", variant = "Variant" },
      get = function() return Addon:GetCharDB().editLayer or "variant" end,
      set = function(_, value) Addon:SetEditLayer(value) end,
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
