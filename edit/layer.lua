--[[
  Purpose: Select the account layer receiving edit-mode layout changes.
  Deps: ShadowUI character DB
  Public: ShadowUI:SetEditLayer(), ShadowUI:ShowLayerPicker()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local LAYERS = { "base", "class", "variant" }
local VALID = { base = true, class = true, variant = true }

local function updateButtons(picker, selected)
  for layer, button in pairs(picker.buttons) do
    local active = layer == selected
    button:SetBackdropColor(active and 0.85 or 0.08, active and 0.2 or 0.08, active and 0.12 or 0.08, 0.95)
    button:SetBackdropBorderColor(active and 1 or 0.3, active and 0.35 or 0.3, active and 0.2 or 0.3, 1)
  end
end

function Addon:CreateLayerPicker()
  local picker = CreateFrame("Frame", "ShadowUILayerPicker", UIParent, "BackdropTemplate")
  picker:SetSize(264, 58)
  picker:SetPoint("TOP", UIParent, "TOP", 0, -48)
  picker:SetFrameStrata("DIALOG")
  picker:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
  picker:SetBackdropColor(0.02, 0.02, 0.02, 0.92)
  picker.buttons = {}

  local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("TOP", 0, -7)
  title:SetText("EDIT LAYER")

  for index, layer in ipairs(LAYERS) do
    local button = CreateFrame("Button", nil, picker, "BackdropTemplate")
    button:SetSize(78, 26)
    button:SetPoint("BOTTOMLEFT", 6 + (index - 1) * 86, 6)
    button:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
    })
    -- BackdropTemplate carries no label, so SetText alone would render nothing.
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    button:SetFontString(label)
    button:SetText(layer:upper())
    button:SetScript("OnClick", function()
      Addon:SetEditLayer(layer)
    end)
    picker.buttons[layer] = button
  end

  picker:Hide()
  self.layerPicker = picker
  return picker
end

function Addon:ShowLayerPicker()
  local picker = self.layerPicker or self:CreateLayerPicker()
  updateButtons(picker, self:GetCharDB().editLayer or "variant")
  picker:Show()
end

function Addon:SetEditLayer(layer)
  layer = type(layer) == "string" and layer:match("^%s*(.-)%s*$"):lower() or ""
  if not VALID[layer] then
    self:Print("Layer must be base, class, or variant.")
    return false
  end
  self:GetCharDB().editLayer = layer
  if self.layerPicker then
    updateButtons(self.layerPicker, layer)
  end
  return true
end
