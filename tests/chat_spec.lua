-- General chat is parked and filled from the Currentz chrome lock.
-- Run: lua tests/chat_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.UIParent = { name = "UIParent" }
_G.NUM_CHAT_WINDOWS = 2

local function fakeChat(name)
  local chat = { name = name, points = {}, fontSize = 14 }
  function chat:ClearAllPoints() self.points = {} end
  function chat:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function chat:SetWidth(width) self.width = width end
  function chat:SetHeight(height) self.height = height end
  function chat:SetSize(width, height)
    self.width, self.height = width, height
  end
  function chat:SetUserPlaced(placed) self.userPlaced = placed end
  function chat:IsMovable() return true end
  function chat:GetFont() return "Fonts\\FRIZQT__.TTF", self.fontSize, "" end
  function chat:SetFont(file, size, flags)
    self.fontFile, self.fontSize, self.fontFlags = file, size, flags
  end
  function chat:CreateTexture()
    local tex = { points = {} }
    function tex:SetAllPoints(target) self.all = target end
    function tex:SetColorTexture(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    function tex:Show() self.shown = true end
    chat.shadowUIBackground = tex
    return tex
  end
  return chat
end

_G.ChatFrame1 = fakeChat("ChatFrame1")
_G.ChatFrame2 = fakeChat("ChatFrame2")
_G.ChatFrame1Background = {
  shown = false,
}
function _G.ChatFrame1Background:SetColorTexture(r, g, b, a)
  self.r, self.g, self.b, self.a = r, g, b, a
end
function _G.ChatFrame1Background:Show() self.shown = true end

function _G.FCF_SetWindowColor(frame, r, g, b)
  frame.windowColor = { r, g, b }
end
function _G.FCF_SetWindowAlpha(frame, alpha)
  frame.windowAlpha = alpha
end
function _G.FCF_SetLocked(frame, locked)
  frame.locked = locked
end

assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "skin/chat.lua"))()
Addon:SkinChat()

local chat = _G.ChatFrame1
local fill = _G.ChatFrame1Background
assert(math.abs(fill.a - 202 / 255) < 0.001, "chat fill matches Currentz alpha")
assert(fill.r == 0 and fill.g == 0 and fill.b == 0, "chat fill is black")
assert(chat.points[1][1] == "BOTTOMLEFT", "chat docks to bottom-left")
assert(chat.points[1][4] == 36 and chat.points[1][5] == 32, "chat offset matches Currentz")
assert(chat.width == 608 and chat.height == 294, "chat size matches Currentz")
assert(chat.fontSize == 16, "chat font size matches Currentz")
assert(chat.locked == true, "chat stays locked")
assert(chat.userPlaced == true, "chat keeps the parked place")

chat:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", 0, 0)
assert(chat.points[#chat.points][4] == 36, "Blizzard chat anchors must be undone")

print("chat_spec OK")
