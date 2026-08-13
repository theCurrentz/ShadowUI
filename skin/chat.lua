--[[
  Purpose: Add restrained black backdrops to chat windows.
  Deps: Blizzard chat frames
  Public: ShadowUI:SkinChat()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local function darkenBackground(background)
  if background.SetColorTexture then
    background:SetColorTexture(0, 0, 0, 0.6)
  elseif background.SetBackdrop then
    background:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
    })
    background:SetBackdropColor(0, 0, 0, 0.6)
  end
  background:Show()
end

function Addon:SkinChat()
  local glass = self:GetTheme() == "glass"
  for i = 1, NUM_CHAT_WINDOWS or 10 do
    local chat = _G["ChatFrame" .. i]
    if chat then
      local background = _G["ChatFrame" .. i .. "Background"] or chat.shadowUIBackground
      if glass then
        if background then
          background:Hide()
        end
        self:ApplyGlassPanel(chat)
      else
        self:ClearGlassPanel(chat)
        if not background then
          background = chat:CreateTexture(nil, "BACKGROUND", nil, -8)
          background:SetAllPoints(chat)
          chat.shadowUIBackground = background
        end
        darkenBackground(background)
      end
    end
  end
end
