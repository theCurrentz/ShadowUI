--[[
  Purpose: Park General chat place and fill it. Size stays with Blizzard Chat.
  Deps: Blizzard chat frames; ShadowUI:ParkFrame()
  Public: ShadowUI:SkinChat()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local FILL = 202 / 255
local FONT_SIZE = 16

local function darkenBackground(background)
  if background.SetColorTexture then
    background:SetColorTexture(0, 0, 0, FILL)
  elseif background.SetBackdrop then
    background:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
    })
    background:SetBackdropColor(0, 0, 0, FILL)
  end
  background:Show()
end

function Addon:SkinChat()
  for i = 1, NUM_CHAT_WINDOWS or 10 do
    local chat = _G["ChatFrame" .. i]
    if chat then
      local background = _G["ChatFrame" .. i .. "Background"]
      if background then
        darkenBackground(background)
      else
        background = chat:CreateTexture(nil, "BACKGROUND", nil, -8)
        background:SetAllPoints(chat)
        chat.shadowUIBackground = background
        darkenBackground(background)
      end
    end
  end

  local chat = _G.ChatFrame1
  if not chat then
    return
  end
  -- Park place only. Size stays with Blizzard Chat / Edit Mode.
  self:ParkFrame(chat, "BOTTOMLEFT", 36, 32)
  if chat.GetFont and chat.SetFont then
    local file, _, flags = chat:GetFont()
    if file then
      chat:SetFont(file, FONT_SIZE, flags)
    end
  end
  if FCF_SetWindowColor then
    FCF_SetWindowColor(chat, 0, 0, 0)
  end
  if FCF_SetWindowAlpha then
    FCF_SetWindowAlpha(chat, FILL)
  end
  if FCF_SetLocked then
    FCF_SetLocked(chat, true)
  end
end
