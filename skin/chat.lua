--[[
  Purpose: Fill General chat with a bottom-left corner alpha gradient. Fade the
           background only. After 20s with no mouse or edit-box use, slow-fade
           to idle. Messages in every chat window more than 1 minute stale fade
           to invisible until mouse or edit-box use. Place and size stay with
           Blizzard Chat / Edit Mode.
  Deps: Blizzard chat frames; ShadowUI:RegisterFadeHost()
  Public: ShadowUI:SkinChat()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local FONT_SIZE = 16
local IDLE = 0.5
local ACTIVE = 0.95
local LINGER = 20
local ENTER = 0.6
local LEAVE = 2.5
local MESSAGE_STALE = 60
local INNER_PAD = 12
local EDIT_ALPHA = 0.7
local EDIT_SHADOW = 0.55
local EDIT_ART = {
  "Left", "Mid", "Middle", "Right",
  "FocusLeft", "FocusMid", "FocusMiddle", "FocusRight",
}
-- Blizzard Edit Mode draws Chat with ~35px extra bounds. Positive left / bottom
-- lets that empty box hang off-screen so the text can sit on the left edge.
local CLAMP_LEFT = 35
local CLAMP_RIGHT = -35
local CLAMP_TOP = -38
local CLAMP_BOTTOM = 50
local FADE_FILE = "Interface\\AddOns\\ShadowUI\\media\\chat_fade"

local function hideBackground(background)
  if not background then
    return
  end
  if background.SetColorTexture then
    background:SetColorTexture(0, 0, 0, 0)
  end
  if background.SetAlpha then
    background:SetAlpha(0)
  end
  if background.Hide then
    background:Hide()
  end
end

local function backgroundOf(chat)
  if chat.Background then
    return chat.Background
  end
  local name = chat.GetName and chat:GetName()
  if name then
    return _G[name .. "Background"]
  end
end

local function hideChrome(region)
  if not region then
    return
  end
  if region.SetAlpha then
    region:SetAlpha(0)
  end
  if region.EnableMouse then
    region:EnableMouse(false)
  end
  if region.Hide then
    region:Hide()
  end
end

local function applyClamp(chat)
  if not chat.SetClampRectInsets then
    return
  end
  chat._shadowUIClamp = true
  chat:SetClampRectInsets(CLAMP_LEFT, CLAMP_RIGHT, CLAMP_TOP, CLAMP_BOTTOM)
  chat._shadowUIClamp = nil
end

local function watchClamp(chat)
  if chat._shadowUIClampHook or not hooksecurefunc or not chat.SetClampRectInsets then
    return
  end
  chat._shadowUIClampHook = true
  hooksecurefunc(chat, "SetClampRectInsets", function(self)
    if self._shadowUIClamp then
      return
    end
    applyClamp(self)
  end)
end

local function flushOuter(chat)
  if chat.SetClampedToScreen then
    chat:SetClampedToScreen(true)
  end
  applyClamp(chat)
  watchClamp(chat)
  if chat.SetHitRectInsets then
    chat:SetHitRectInsets(0, 0, 0, 0)
  end
  local bg = backgroundOf(chat)
  if bg and bg.ClearAllPoints and bg.SetPoint then
    bg:ClearAllPoints()
    bg:SetPoint("TOPLEFT", chat, "TOPLEFT", 0, 0)
    bg:SetPoint("BOTTOMRIGHT", chat, "BOTTOMRIGHT", 0, 0)
  end
  hideChrome(chat.ScrollBar)
  hideChrome(chat.ScrollToBottomButton)
  hideChrome(chat.resizeButton)
  hideChrome(chat.buttonFrame)
  local name = chat.GetName and chat:GetName()
  if name then
    hideChrome(_G[name .. "ResizeButton"])
    hideChrome(_G[name .. "ButtonFrame"])
  end
end

local function padInner(chat)
  if chat.SetTextInsets then
    pcall(chat.SetTextInsets, chat, INNER_PAD, INNER_PAD, INNER_PAD, INNER_PAD)
  end
end

local function editBoxOf(chat)
  return _G.ChatFrame1EditBox or chat.editBox
end

local function hideEditArt(edit)
  local name = edit.GetName and edit:GetName()
  if not name then
    return
  end
  for _, suffix in ipairs(EDIT_ART) do
    hideChrome(_G[name .. suffix])
  end
end

local function placeEdit(edit, chat)
  if not edit.SetPoint then
    return
  end
  edit._shadowUIPlacing = true
  if edit.ClearAllPoints then
    edit:ClearAllPoints()
  end
  edit:SetPoint("TOPLEFT", chat, "BOTTOMLEFT", 0, 0)
  edit:SetPoint("TOPRIGHT", chat, "BOTTOMRIGHT", 0, 0)
  edit._shadowUIPlacing = nil
end

local function watchEditPlace(edit, chat)
  if edit._shadowUIPlaceHook or not hooksecurefunc or not edit.SetPoint then
    return
  end
  edit._shadowUIPlaceHook = true
  hooksecurefunc(edit, "SetPoint", function(self)
    if self._shadowUIPlacing then
      return
    end
    placeEdit(self, chat)
  end)
end

local function skinEditBox(chat)
  local edit = editBoxOf(chat)
  if not edit then
    return nil
  end
  hideEditArt(edit)
  placeEdit(edit, chat)
  watchEditPlace(edit, chat)
  if edit.SetTextInsets then
    pcall(edit.SetTextInsets, edit, INNER_PAD, INNER_PAD, 0, 0)
  end
  if edit.GetFont and edit.SetFont then
    local file, _, flags = edit:GetFont()
    if file then
      edit:SetFont(file, FONT_SIZE, flags)
    end
  end
  local fill = edit.shadowUIFill
  if not fill and edit.CreateTexture then
    fill = edit:CreateTexture(nil, "BACKGROUND")
    edit.shadowUIFill = fill
  end
  if fill then
    if fill.SetColorTexture then
      fill:SetColorTexture(0, 0, 0, EDIT_ALPHA)
    end
    if fill.SetAllPoints then
      fill:SetAllPoints(edit)
    end
    if fill.Show then
      fill:Show()
    end
  end
  if Addon.ApplyOuterChrome then
    local outer = Addon:ApplyOuterChrome(edit, "square")
    if outer and outer.SetBackdropBorderColor then
      outer:SetBackdropBorderColor(0, 0, 0, EDIT_SHADOW)
    end
  end
  return edit
end

local function ensureFade(chat, edit)
  local host = chat.shadowUIFadeHost
  if not host and CreateFrame then
    host = CreateFrame("Frame", nil, UIParent)
    chat.shadowUIFadeHost = host
  end
  if host then
    if host.SetFrameStrata then
      local strata = chat.GetFrameStrata and chat:GetFrameStrata()
      host:SetFrameStrata(strata or "LOW")
    end
    if chat.GetFrameLevel and host.SetFrameLevel then
      local level = chat:GetFrameLevel() or 1
      if level > 0 then
        host:SetFrameLevel(level - 1)
      end
    end
    if host.ClearAllPoints then
      host:ClearAllPoints()
    end
    if host.SetPoint then
      host:SetPoint("TOPLEFT", chat, "TOPLEFT", -INNER_PAD, INNER_PAD)
      local bottom = edit or chat
      host:SetPoint("BOTTOMRIGHT", bottom, "BOTTOMRIGHT", INNER_PAD, -INNER_PAD)
    end
    if host.Show then
      host:Show()
    end
  end
  local parent = host or chat
  local tex = chat.shadowUIFade
  if not tex and parent.CreateTexture then
    tex = parent:CreateTexture(nil, "BACKGROUND", nil, -8)
    chat.shadowUIFade = tex
  end
  if not tex then
    return nil
  end
  if tex.SetTexture then
    tex:SetTexture(FADE_FILE)
  end
  if tex.SetVertexColor then
    tex:SetVertexColor(0, 0, 0, 1)
  end
  if tex.SetAllPoints then
    tex:SetAllPoints(parent)
  elseif tex.ClearAllPoints and tex.SetPoint then
    tex:ClearAllPoints()
    tex:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    tex:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
  end
  if tex.Show then
    tex:Show()
  end
  return tex
end

local function watchBackgroundAnchors()
  if Addon._chatBgAnchorHook or not hooksecurefunc then
    return
  end
  if not _G.FloatingChatFrame_UpdateBackgroundAnchors then
    return
  end
  Addon._chatBgAnchorHook = true
  hooksecurefunc("FloatingChatFrame_UpdateBackgroundAnchors", function(frame)
    if frame == _G.ChatFrame1 then
      flushOuter(frame)
    end
  end)
end

local function forEachChatFrame(fn)
  local seen = {}
  local function visit(chat)
    if chat and not seen[chat] then
      seen[chat] = true
      fn(chat)
    end
  end
  for i = 1, NUM_CHAT_WINDOWS or 10 do
    visit(_G["ChatFrame" .. i])
  end
  if CHAT_FRAMES then
    for _, name in pairs(CHAT_FRAMES) do
      visit(_G[name])
    end
  end
end

local function applyMessageFade(chat)
  if not chat then
    return
  end
  if chat.SetTimeVisible then
    chat:SetTimeVisible(MESSAGE_STALE)
  end
  if chat.SetFadeDuration then
    chat:SetFadeDuration(LEAVE)
  end
  if chat.SetFading then
    chat:SetFading(true)
  end
  if not chat._shadowUIMessageFade then
    chat._shadowUIMessageFade = true
    if chat.AtBottom and chat.ScrollToBottom and chat:AtBottom() then
      chat:ScrollToBottom()
    elseif chat.GetScrollOffset and chat.SetScrollOffset then
      chat:SetScrollOffset(chat:GetScrollOffset())
    end
  end
end

local function revealMessages(chat)
  applyMessageFade(chat)
  if chat and chat.ResetAllFadeTimes then
    chat:ResetAllFadeTimes()
  end
end

local function revealAllMessages()
  forEachChatFrame(revealMessages)
end

local function hookChat(chat, zen)
  if chat._shadowUIFadeHook or not chat.HookScript then
    return
  end
  chat._shadowUIFadeHook = true
  if chat.EnableMouse then
    chat:EnableMouse(true)
  end
  chat:HookScript("OnEnter", function()
    revealMessages(chat)
    if zen then
      Addon:SetFadeMouseOver(chat, true)
    end
  end)
  chat:HookScript("OnLeave", function()
    if not zen then
      return
    end
    local edit = _G.ChatFrame1EditBox or chat.editBox
    if edit and edit.IsShown and edit:IsShown() then
      return
    end
    Addon:SetFadeMouseOver(chat, false)
  end)
  chat:HookScript("OnMouseDown", function()
    revealMessages(chat)
    if zen then
      Addon:SetFadeMouseOver(chat, true)
    end
  end)
  if not zen then
    return
  end
  local edit = _G.ChatFrame1EditBox or chat.editBox
  if edit and edit.HookScript then
    edit:HookScript("OnShow", function()
      revealAllMessages()
      Addon:SetFadeMouseOver(chat, true)
    end)
    edit:HookScript("OnHide", function()
      if chat.IsMouseOver and chat:IsMouseOver() then
        return
      end
      Addon:SetFadeMouseOver(chat, false)
    end)
  end
end

local function watchNewChatWindows()
  if Addon._chatMessageFadeHook or not hooksecurefunc then
    return
  end
  Addon._chatMessageFadeHook = true
  if FCF_OpenTemporaryWindow then
    hooksecurefunc("FCF_OpenTemporaryWindow", function()
      Addon:SkinChat()
    end)
  end
  if FCF_OpenNewWindow then
    hooksecurefunc("FCF_OpenNewWindow", function()
      Addon:SkinChat()
    end)
  end
end

function Addon:SkinChat()
  for i = 1, NUM_CHAT_WINDOWS or 10 do
    hideBackground(_G["ChatFrame" .. i .. "Background"])
  end

  local chat = _G.ChatFrame1
  if not chat then
    return
  end
  -- Place stays with Blizzard Chat / Edit Mode. Do not ParkFrame.
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
    FCF_SetWindowAlpha(chat, 0)
  end
  if FCF_SetLocked then
    FCF_SetLocked(chat, true)
  end

  flushOuter(chat)
  padInner(chat)
  local edit = skinEditBox(chat)
  watchBackgroundAnchors()
  local fade = ensureFade(chat, edit)
  forEachChatFrame(function(frame)
    applyMessageFade(frame)
    hookChat(frame, frame == chat)
  end)
  watchNewChatWindows()
  if fade and self.RegisterFadeHost then
    self:RegisterFadeHost({
      frame = chat,
      idleAlpha = IDLE,
      activeAlpha = ACTIVE,
      delay = LINGER,
      enterDur = ENTER,
      leaveDur = LEAVE,
      useForced = false,
      setAlpha = function(alpha)
        if fade.SetAlpha then
          fade:SetAlpha(alpha)
        end
      end,
    })
  end
end
