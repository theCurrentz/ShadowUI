-- General chat place stays with Blizzard Edit Mode. Fill is a bottom-left
-- background fades after 20s with no mouse or edit-box use. Messages
-- more than 1 minute stale fade to invisible until the frame is used.
-- Size stays with Blizzard Chat.
-- Run: lua tests/chat_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    method = object
    object = _G
  end
  local orig = object[method]
  if not orig then
    return
  end
  object[method] = function(...)
    local a, b, c, d, e = orig(...)
    fn(...)
    return a, b, c, d, e
  end
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent" }
_G.NUM_CHAT_WINDOWS = 2
_G.CreateFrame = function(_, name, parent, template)
  local frame = {
    name = name,
    parent = parent,
    template = template,
    scripts = {},
    points = {},
    shown = true,
  }
  function frame:SetScript(event, fn) self.scripts[event] = fn end
  function frame:GetScript(event) return self.scripts[event] end
  function frame:RegisterEvent() end
  function frame:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetFrameStrata(strata) self.strata = strata end
  function frame:SetBackdrop(backdrop) self.backdrop = backdrop end
  function frame:SetBackdropColor() end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:SetParent(parent) self.parent = parent end
  function frame:CreateTexture()
    local tex = { points = {}, a = 1 }
    function tex:SetAllPoints(target) self.all = target end
    function tex:ClearAllPoints() self.points = {} end
    function tex:SetPoint(point, relative, relativePoint, x, y)
      self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
    end
    function tex:SetTexture(file) self.file = file end
    function tex:SetVertexColor(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a or self.a
    end
    function tex:SetColorTexture(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    function tex:SetAlpha(a) self.a = a end
    function tex:Show() self.shown = true end
    return tex
  end
  return frame
end

local function fakeChat(name)
  local chat = { name = name, points = {}, fontSize = 14, scripts = {}, alpha = 1, mouseOver = false }
  function chat:GetName() return self.name end
  function chat:ClearAllPoints() self.points = {} end
  function chat:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function chat:SetWidth(width) self.width = width end
  function chat:SetHeight(height) self.height = height end
  function chat:GetWidth() return self.width end
  function chat:GetHeight() return self.height end
  function chat:SetSize(width, height)
    self.width, self.height = width, height
  end
  function chat:SetUserPlaced(placed) self.userPlaced = placed end
  function chat:IsUserPlaced() return self.userPlaced == true end
  function chat:GetFrameStrata() return "LOW" end
  function chat:GetFrameLevel() return 2 end
  function chat:GetParent() return _G.UIParent end
  function chat:GetFont() return "Fonts\\FRIZQT__.TTF", self.fontSize, "" end
  function chat:SetFont(file, size, flags)
    self.fontFile, self.fontSize, self.fontFlags = file, size, flags
  end
  function chat:SetAlpha(a) self.alpha = a end
  function chat:GetAlpha() return self.alpha end
  function chat:IsMouseOver() return self.mouseOver end
  function chat:EnableMouse(on) self.mouse = on end
  function chat:SetClampedToScreen(on) self.clamped = on and true or false end
  function chat:SetClampRectInsets(l, r, t, b)
    self.clampInsets = { l, r, t, b }
  end
  function chat:SetHitRectInsets(l, r, t, b)
    self.hitInsets = { l, r, t, b }
  end
  function chat:SetTextInsets(l, r, t, b)
    self.textInsets = { l, r, t, b }
  end
  function chat:SetFading(on) self.fading = on and true or false end
  function chat:GetFading() return self.fading end
  function chat:SetTimeVisible(seconds) self.timeVisible = seconds end
  function chat:GetTimeVisible() return self.timeVisible end
  function chat:SetFadeDuration(seconds) self.fadeDuration = seconds end
  function chat:GetFadeDuration() return self.fadeDuration end
  function chat:AtBottom() return self.atBottom ~= false end
  function chat:ScrollToBottom()
    self.scrollToBottom = (self.scrollToBottom or 0) + 1
  end
  function chat:ResetAllFadeTimes()
    self.resetFades = (self.resetFades or 0) + 1
  end
  function chat:HookScript(event, fn)
    self.scripts[event] = self.scripts[event] or {}
    self.scripts[event][#self.scripts[event] + 1] = fn
  end
  function chat:CreateTexture()
    local tex = { points = {}, a = 1 }
    function tex:SetAllPoints(target) self.all = target end
    function tex:ClearAllPoints() self.points = {} end
    function tex:SetPoint(point, relative, relativePoint, x, y)
      self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
    end
    function tex:SetTexture(file) self.file = file end
    function tex:SetVertexColor(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a or self.a
    end
    function tex:SetAlpha(a) self.a = a end
    function tex:Show() self.shown = true end
    chat.shadowUIFade = tex
    return tex
  end
  return chat
end

local function fakeBackground()
  local fill = { shown = true, a = 1, points = {} }
  function fill:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function fill:SetAlpha(a) self.a = a end
  function fill:Show() self.shown = true end
  function fill:Hide() self.shown = false end
  function fill:ClearAllPoints() self.points = {} end
  function fill:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  return fill
end

local function fakeChrome()
  local region = { shown = true, a = 1, mouse = true }
  function region:SetAlpha(a) self.a = a end
  function region:EnableMouse(on) self.mouse = on and true or false end
  function region:Hide() self.shown = false end
  function region:Show() self.shown = true end
  return region
end

_G.ChatFrame1 = fakeChat("ChatFrame1")
_G.ChatFrame1.ScrollBar = fakeChrome()
_G.ChatFrame1.ScrollToBottomButton = fakeChrome()
_G.ChatFrame1.resizeButton = fakeChrome()
_G.ChatFrame1.buttonFrame = fakeChrome()
_G.ChatFrame2 = fakeChat("ChatFrame2")
_G.ChatFrame1Background = fakeBackground()
_G.ChatFrame2Background = fakeBackground()
_G.FloatingChatFrame_UpdateBackgroundAnchors = function(frame)
  local bg = _G[frame:GetName() .. "Background"]
  if not bg then
    return
  end
  bg:ClearAllPoints()
  bg:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 3)
  bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, -6)
  frame:SetClampRectInsets(-35, 35, 38, -50)
end
_G.ChatFrame1EditBoxLeft = fakeChrome()
_G.ChatFrame1EditBoxMid = fakeChrome()
_G.ChatFrame1EditBoxRight = fakeChrome()
_G.ChatFrame1EditBox = {
  name = "ChatFrame1EditBox",
  shown = false,
  scripts = {},
  points = {},
  fontSize = 14,
}
function _G.ChatFrame1EditBox:GetName() return self.name end
function _G.ChatFrame1EditBox:IsShown() return self.shown end
function _G.ChatFrame1EditBox:Show()
  self.shown = true
  for _, fn in ipairs(self.scripts.OnShow or {}) do
    fn(self)
  end
end
function _G.ChatFrame1EditBox:Hide()
  self.shown = false
  for _, fn in ipairs(self.scripts.OnHide or {}) do
    fn(self)
  end
end
function _G.ChatFrame1EditBox:HookScript(event, fn)
  self.scripts[event] = self.scripts[event] or {}
  self.scripts[event][#self.scripts[event] + 1] = fn
end
function _G.ChatFrame1EditBox:ClearAllPoints() self.points = {} end
function _G.ChatFrame1EditBox:SetPoint(point, relative, relativePoint, x, y)
  self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
end
function _G.ChatFrame1EditBox:GetFrameLevel() return 3 end
function _G.ChatFrame1EditBox:SetFrameLevel(level) self.level = level end
function _G.ChatFrame1EditBox:GetFont() return "Fonts\\FRIZQT__.TTF", self.fontSize, "" end
function _G.ChatFrame1EditBox:SetFont(file, size, flags)
  self.fontFile, self.fontSize, self.fontFlags = file, size, flags
end
function _G.ChatFrame1EditBox:SetTextInsets(l, r, t, b)
  self.textInsets = { l, r, t, b }
end
function _G.ChatFrame1EditBox:CreateTexture()
  local tex = { points = {}, a = 1 }
  function tex:SetAllPoints(target) self.all = target end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:Show() self.shown = true end
  _G.ChatFrame1EditBox.shadowUIFill = tex
  return tex
end

function _G.FCF_SetWindowColor(frame, r, g, b)
  frame.windowColor = { r, g, b }
end
function _G.FCF_SetWindowAlpha(frame, alpha)
  frame.windowAlpha = alpha
end
function _G.FCF_SetLocked(frame, locked)
  frame.locked = locked
end
function _G.FCF_OpenTemporaryWindow()
  _G.ChatFrame3 = fakeChat("ChatFrame3")
  _G.CHAT_FRAMES = { "ChatFrame1", "ChatFrame2", "ChatFrame3" }
  return _G.ChatFrame3
end

assert(loadfile(root .. "core/easing.lua"))()
assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/fade.lua"))()
assert(loadfile(root .. "skin/chat.lua"))()
Addon:SkinChat()

local chat = _G.ChatFrame1
local fade = chat.shadowUIFade
local host = chat.shadowUIFadeHost
local edit = _G.ChatFrame1EditBox
local fill = _G.ChatFrame1Background
assert(fill.shown == false, "Blizzard chat background stays hidden")
assert(fill.a == 0, "Blizzard chat background alpha is zero")
assert(chat.windowAlpha == 0, "Blizzard chat window alpha is zero")
assert(fade.file:find("chat_fade", 1, true), "chat fill is the corner fade texture")
assert(fade.all == host, "fade covers the host that includes the edit box")
assert(host.points[1][1] == "TOPLEFT" and host.points[1][4] == -12 and host.points[1][5] == 12,
  "fade host has 12px pad on the top-left")
assert(host.points[2][1] == "BOTTOMRIGHT" and host.points[2][2] == edit
  and host.points[2][4] == 12 and host.points[2][5] == -12,
  "fade host extends 12px past the chat input")
assert(chat.textInsets[1] == 12 and chat.textInsets[4] == 12,
  "chat text has 12px insets")
assert(edit.textInsets[1] == 12 and edit.textInsets[2] == 12,
  "chat input text has 12px side insets")
assert(edit.points[1][1] == "TOPLEFT" and edit.points[1][2] == chat
  and edit.points[1][3] == "BOTTOMLEFT",
  "chat input sits under the message frame")
assert(edit.shadowUIFill.r == 0 and edit.shadowUIFill.a == 0.7,
  "chat input fill is 70% transparent black")
assert(edit.shadowUIOuter.backdrop.edgeFile:find("outer_shadow", 1, true),
  "chat input uses the Lorti Outer Edge")
assert(math.abs(edit.shadowUIOuter.border[4] - 0.55) < 0.001,
  "chat input Outer Edge is a faded drop")
assert(_G.ChatFrame1EditBoxLeft.shown == false, "Blizzard chat input left art stays hidden")
assert(_G.ChatFrame1EditBoxMid.shown == false, "Blizzard chat input mid art stays hidden")
assert(_G.ChatFrame1EditBoxRight.shown == false, "Blizzard chat input right art stays hidden")
assert(edit.fontSize == 16, "chat input font size matches chat")
assert(math.abs(fade.a - 0.5) < 0.001, "chat fill starts at idle alpha")
assert(chat.alpha == 1, "chat text does not fade with the background")
assert(chat.clamped == true, "chat stays clamped to the screen")
assert(chat.clampInsets[1] == 35 and chat.clampInsets[2] == -35
  and chat.clampInsets[3] == -38 and chat.clampInsets[4] == 50,
  "chat clamp lets the Edit Mode box hang off the left edge")
assert(chat.hitInsets[1] == 0 and chat.hitInsets[2] == 0
  and chat.hitInsets[3] == 0 and chat.hitInsets[4] == 0,
  "chat hit insets match the visible fill")
assert(_G.ChatFrame1Background.points[1][4] == 0 and _G.ChatFrame1Background.points[1][5] == 0,
  "Blizzard chat background sits flush on the top-left")
assert(_G.ChatFrame1Background.points[2][4] == 0 and _G.ChatFrame1Background.points[2][5] == 0,
  "Blizzard chat background sits flush on the bottom-right")
assert(chat.ScrollBar.shown == false and chat.ScrollBar.mouse == false,
  "chat scrollbar does not keep an invisible right margin")
assert(chat.buttonFrame.shown == false and chat.buttonFrame.mouse == false,
  "chat button frame does not keep an invisible left margin")
assert(chat.resizeButton.shown == false and chat.resizeButton.mouse == false,
  "chat resize grip does not keep an invisible corner margin")
assert(chat.fading == true, "stale chat messages fade when the frame is idle")
assert(chat.timeVisible == 60, "chat messages fade after 1 minute")
assert(math.abs(chat.fadeDuration - 2.5) < 0.001, "chat messages fade out over the leave duration")
assert(chat.scrollToBottom == 1, "existing chat lines pick up the 1 minute fade")
assert(_G.ChatFrame2.fading == true, "Combat Log messages fade after 1 minute")
assert(_G.ChatFrame2.timeVisible == 60, "Combat Log uses the same stale time")
assert(_G.ChatFrame2.scrollToBottom == 1, "existing Combat Log lines pick up the 1 minute fade")
assert(#chat.points == 0, "SkinChat must not park chat place")
assert(chat.width == nil and chat.height == nil, "SkinChat must not set chat size")
assert(chat.fontSize == 16, "chat font size matches Currentz")
assert(chat.locked == true, "chat stays locked")
assert(#_G.ChatFrame2.points == 0, "only ChatFrame1 is skinned for place chrome")
assert(_G.ChatFrame2Background.shown == false, "other chat backgrounds stay hidden")

chat:SetWidth(400)
chat:SetHeight(200)
chat:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 0, 0)
assert(chat.points[#chat.points][4] == 0, "Blizzard Edit Mode chat place must stay")
assert(chat.width == 400 and chat.height == 200, "Blizzard Edit Mode chat size must stay")

Addon:SkinChat()
assert(chat.points[#chat.points][4] == 0, "later SkinChat must keep the Edit Mode place")
assert(chat.width == 400 and chat.height == 200, "later SkinChat must keep the Edit Mode size")
assert(chat.scrollToBottom == 1, "later SkinChat must not re-scroll chat")
assert(chat.fading == true, "later SkinChat keeps message fade on")

chat.userPlaced = false
Addon:SkinChat()
assert(chat.width == 400 and chat.height == 200, "reload SkinChat must keep Blizzard Chat size")

chat.mouseOver = true
Addon:SkinChat()
assert(chat.fading == true, "SkinChat does not disable fade while the mouse is over chat")
chat.mouseOver = false

for _, fn in ipairs(chat.scripts.OnEnter) do
  fn(chat)
end
Addon:TickFade(0.6)
assert(math.abs(fade.a - 0.95) < 0.001, "mouse enter darkens the chat fill")
assert(chat.alpha == 1, "mouse enter does not fade chat text")
assert(chat.fading == true, "mouse enter does not disable chat message fade")
assert(chat.resetFades == 1, "mouse enter shows faded chat messages")

for _, fn in ipairs(chat.scripts.OnLeave) do
  fn(chat)
end
Addon:TickFade(20)
Addon:TickFade(2.5)
assert(math.abs(fade.a - 0.5) < 0.001, "after 20s with no use, chat fill slow-fades to idle")
assert(chat.fading == true, "chat messages fade again when the frame is not in use")

for _, fn in ipairs(chat.scripts.OnMouseDown) do
  fn(chat)
end
Addon:TickFade(0.6)
assert(math.abs(fade.a - 0.95) < 0.001, "mouse down darkens the chat fill")
assert(chat.fading == true, "mouse down does not disable chat message fade")
assert(chat.resetFades == 2, "mouse down shows faded chat messages")

_G.ChatFrame1EditBox:Show()
Addon:TickFade(0)
assert(math.abs(fade.a - 0.95) < 0.001, "edit box keeps the chat fill active")
assert(chat.fading == true, "edit box does not disable chat message fade")
assert(chat.resetFades == 3, "edit box shows faded chat messages")
assert(_G.ChatFrame2.resetFades == 1, "edit box shows faded messages in every chat window")
for _, fn in ipairs(chat.scripts.OnLeave) do
  fn(chat)
end
Addon:TickFade(20)
assert(math.abs(fade.a - 0.95) < 0.001, "edit box blocks the linger fade")
_G.ChatFrame1EditBox:Hide()
Addon:TickFade(20)
Addon:TickFade(2.5)
assert(math.abs(fade.a - 0.5) < 0.001, "hiding the edit box starts the linger fade")
assert(chat.fading == true, "hiding the edit box lets stale chat messages fade")

for _, fn in ipairs(_G.ChatFrame2.scripts.OnEnter) do
  fn(_G.ChatFrame2)
end
assert(_G.ChatFrame2.resetFades == 2, "Combat Log mouse enter shows faded messages")
assert(_G.ChatFrame2.fading == true, "Combat Log mouse enter does not disable fade")
assert(math.abs(fade.a - 0.5) < 0.001, "Combat Log enter does not darken General fill")

local whisper = _G.FCF_OpenTemporaryWindow()
assert(whisper.fading == true, "whisper window messages fade after 1 minute")
assert(whisper.timeVisible == 60, "whisper window uses the same stale time")

_G.FloatingChatFrame_UpdateBackgroundAnchors(chat)
assert(chat.clampInsets[1] == 35 and chat.clampInsets[4] == 50,
  "Blizzard background anchors must not restore the left-edge clamp")
assert(_G.ChatFrame1Background.points[1][4] == 0,
  "Blizzard background anchors must stay flush")

local src = assert(io.open(root .. "skin/chat.lua", "r")):read("*a")
assert(not src:find("CHAT_MSG", 1, true), "incoming messages do not drive Chat fade")
local fadePath = root .. "media/chat_fade.tga"
local fadeTex = assert(io.open(fadePath, "rb"))
local tga = fadeTex:read("*a")
fadeTex:close()
local function u16(offset)
  return tga:byte(offset) + tga:byte(offset + 1) * 256
end
local function pixel(x, y)
  local width = u16(13)
  local i = 19 + (y * width + x) * 4
  local b, g, r, a = tga:byte(i, i + 3)
  return r, g, b, a
end
assert(u16(13) == 256 and u16(15) == 256, "chat_fade.tga is a 2D gradient")
local _, _, _, bl = pixel(0, 0)
local _, _, _, br = pixel(255, 0)
local _, _, _, tl = pixel(0, 255)
local _, _, _, tr = pixel(255, 255)
assert(bl == 255, "bottom-left of the fade is solid black alpha")
assert(br <= 12 and tl <= 12 and tr <= 12, "top and right of the fade stay near transparent")
assert(bl > br and bl > tl, "the fade is darkest at the bottom-left")

print("chat_spec OK")
