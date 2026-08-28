--[[
  Purpose: Select the Layer receiving Layout, Keybind, and Action Deck edits.
  Deps: ShadowUI character DB
  Public: ShadowUI:SetEditLayer(), ShadowUI:ShowLayerPicker()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local LAYERS = { "base", "class", "variant", "character" }
local VALID = { base = true, class = true, variant = true, character = true }

local function updateButtons(picker, selected)
  for layer, button in pairs(picker.buttons) do
    local active = layer == selected
    button:SetBackdropColor(active and 0.21 or 0.08, active and 0.18 or 0.08, active and 0.05 or 0.08, 0.95)
    button:SetBackdropBorderColor(active and 1 or 0.4, active and 0.82 or 0.4, active and 0.1 or 0.4, 1)
  end
end

function Addon:CreateLayerPicker()
  local picker = CreateFrame("Frame", "ShadowUILayerPicker", UIParent, "BackdropTemplate")
  picker:SetSize(500, 108)
  picker:SetPoint("TOP", UIParent, "TOP", 0, -24)
  picker:SetFrameStrata("FULLSCREEN_DIALOG")
  picker:SetFrameLevel(500)
  picker:EnableMouse(true)
  picker:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  picker.buttons = {}

  local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", 0, -16)
  title:SetText("Layout Edit Mode")
  picker.title = title

  for index, layer in ipairs(LAYERS) do
    local button = CreateFrame("Button", nil, picker, "BackdropTemplate")
    button:SetSize(108, 24)
    button:SetPoint("TOPLEFT", 16 + (index - 1) * 112, -42)
    button:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
    })
    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    button:SetFontString(label)
    button:SetText(layer:upper())
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp")
    button:SetScript("OnClick", function()
      Addon:SetEditLayer(layer)
    end)
    button:SetScript("OnMouseUp", function(_, mouse)
      if mouse == "LeftButton" then
        Addon:SetEditLayer(layer)
      end
    end)
    picker.buttons[layer] = button
  end

  local hint = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint:SetPoint("BOTTOMLEFT", 20, 18)
  hint:SetPoint("RIGHT", picker, "RIGHT", -84, 18)
  hint:SetJustifyH("LEFT")
  hint:SetText("Drag a host. Hold Shift to skip snap. Writes go to this Layer.")
  picker.hint = hint

  local function closeEdit()
    if Addon.editMode then
      Addon:ToggleEditMode()
    elseif Addon.keybindMode then
      Addon:ToggleKeybindMode()
    end
  end
  local ok, done = pcall(CreateFrame, "Button", "ShadowUIEditDone", picker, "UIPanelButtonTemplate")
  if not ok or not done then
    done = CreateFrame("Button", "ShadowUIEditDone", picker, "BackdropTemplate")
    done:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
    })
    done:SetBackdropColor(0.12, 0.12, 0.12, 0.95)
    done:SetBackdropBorderColor(1, 0.82, 0.1, 0.9)
    local doneLabel = done:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    doneLabel:SetPoint("CENTER")
    done:SetFontString(doneLabel)
  end
  done:SetSize(64, 24)
  done:SetPoint("BOTTOMRIGHT", -20, 16)
  done:EnableMouse(true)
  done:RegisterForClicks("LeftButtonUp")
  done:SetFrameLevel((picker:GetFrameLevel() or 500) + 20)
  done:SetText("Done")
  -- Backdrop buttons on Classic often skip OnClick. MouseUp always fires.
  done:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" then
      closeEdit()
    end
  end)
  picker.done = done

  picker:Hide()
  self.layerPicker = picker
  return picker
end

function Addon:ShowLayerPicker()
  local picker = self.layerPicker or self:CreateLayerPicker()
  if picker.title then
    picker.title:SetText(self.keybindMode and "Keybind Edit Mode" or "Layout Edit Mode")
  end
  if picker.hint then
    picker.hint:SetText(self.keybindMode
      and "Hover a button, then press a key."
      or "Drag a host. Hold Shift to skip snap. Writes go to this Layer.")
  end
  updateButtons(picker, self:GetCharDB().editLayer or "variant")
  picker:Show()
end

function Addon:SetEditLayer(layer)
  layer = type(layer) == "string" and layer:match("^%s*(.-)%s*$"):lower() or ""
  if not VALID[layer] then
    self:Print("Layer must be base, class, variant, or character.")
    return false
  end
  self:GetCharDB().editLayer = layer
  if self.layerPicker then
    updateButtons(self.layerPicker, layer)
  end
  return true
end
