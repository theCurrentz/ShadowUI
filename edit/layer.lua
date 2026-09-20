--[[
  Purpose: Edit Mode HUD that names the active Profile and closes the session.
  Deps: ShadowUI character DB
  Public: ShadowUI:ShowLayerPicker()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:CreateLayerPicker()
  local picker = CreateFrame("Frame", "ShadowUILayerPicker", UIParent, "BackdropTemplate")
  picker:SetSize(420, 108)
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

  local title = picker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", 0, -16)
  title:SetText("Layout Edit Mode")
  picker.title = title

  local profile = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  profile:SetPoint("TOP", 0, -38)
  picker.profile = profile

  local hint = picker:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  hint:SetPoint("BOTTOMLEFT", 20, 18)
  hint:SetPoint("RIGHT", picker, "RIGHT", -84, 18)
  hint:SetJustifyH("LEFT")
  hint:SetText("Drag a host. Hold Shift to skip snap. Writes go to this Profile.")
  picker.hint = hint

  local function closeEdit()
    if Addon.editMode then
      Addon:ToggleEditMode()
    elseif Addon.keybindMode then
      Addon:ToggleKeybindMode()
    elseif Addon.unitFrameMode then
      Addon:ToggleUnitFrameMode()
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
    local title = "Layout Edit Mode"
    if self.keybindMode then
      title = "Keybind Edit Mode"
    elseif self.unitFrameMode then
      title = "Unit Frame Designer"
    end
    picker.title:SetText(title)
  end
  local name = self.GetActiveProfileName and self:GetActiveProfileName() or "Default"
  local defaultName = self.GetDB and self:GetDB().defaultProfile
  local label = "Profile: " .. tostring(name)
  if defaultName == name then
    label = label .. " (Default)"
  end
  if picker.profile then
    picker.profile:SetText(label)
  end
  if picker.hint then
    local hint = "Drag a host. Hold Shift to skip snap. Writes go to this Profile."
    if self.keybindMode then
      hint = "Hover a button, then press a key. Writes go to this Profile."
    elseif self.unitFrameMode then
      hint = "Drag a Widget. Hold Shift to skip snap. Writes go to this Profile."
    end
    picker.hint:SetText(hint)
  end
  picker:Show()
end
