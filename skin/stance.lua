--[[
  Purpose: Give Blizzard Stance Bar buttons the same chrome as Blizzard
           ActionButtons: native icon and glows, blackened rim, Outer Edge.
           Unused shapeshift slots stay empty. Strip the Stance Bar art.
           ShadowUI does not replace StanceBar / StanceBarFrame / ShapeshiftBarFrame.
  Deps: ShadowUI:SkinBarButton()
  Public: ShadowUI:SkinStanceButton(), ShadowUI:SkinStanceBar()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local LAST = 10
local PREFIXES = { "StanceButton", "ShapeshiftButton" }
local ART = {
  "StanceBarLeft", "StanceBarMiddle", "StanceBarRight",
  "ShapeshiftBarLeft", "ShapeshiftBarMiddle", "ShapeshiftBarRight",
}
local BARS = { "StanceBar", "StanceBarFrame", "ShapeshiftBarFrame" }

local function strip(texture)
  if not texture then
    return
  end
  pcall(texture.SetTexture, texture, "")
end

function Addon:SkinStanceButton(button)
  if button and self.SkinBarButton then
    self:SkinBarButton(button)
  end
end

local function consider(seen, button)
  if not button or seen[button] then
    return
  end
  seen[button] = true
  Addon:SkinStanceButton(button)
end

function Addon:SkinStanceBar()
  for _, name in ipairs(ART) do
    strip(_G[name])
  end
  local seen = {}
  for _, name in ipairs(BARS) do
    local bar = _G[name]
    if bar then
      for _, key in ipairs({ "actionButtons", "buttons", "stanceButtons" }) do
        local list = bar[key]
        if type(list) == "table" then
          for _, button in ipairs(list) do
            consider(seen, button)
          end
        end
      end
    end
  end
  for _, prefix in ipairs(PREFIXES) do
    for i = 1, LAST do
      consider(seen, _G[prefix .. i])
    end
  end
end

local function restyle()
  Addon:SkinStanceBar()
end

if hooksecurefunc then
  if ShapeshiftBar_Update then
    hooksecurefunc("ShapeshiftBar_Update", restyle)
  end
  if StanceBar_Update then
    hooksecurefunc("StanceBar_Update", restyle)
  end
  if ShapeshiftBar_UpdateState then
    hooksecurefunc("ShapeshiftBar_UpdateState", restyle)
  end
  if StanceBar_UpdateState then
    hooksecurefunc("StanceBar_UpdateState", restyle)
  end
  if StanceBarMixin and StanceBarMixin.Update then
    hooksecurefunc(StanceBarMixin, "Update", restyle)
  end
  if StanceButtonMixin then
    if StanceButtonMixin.UpdateState then
      hooksecurefunc(StanceButtonMixin, "UpdateState", restyle)
    end
    if StanceButtonMixin.Update then
      hooksecurefunc(StanceButtonMixin, "Update", restyle)
    end
  end
end
