-- Target Frame spell bar sits flush under the mana bar at mana width, with a
-- remaining / duration count. Target of Target stays on the Blizzard default
-- BOTTOMRIGHT offset. Run: lua tests/target_spellbar_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local orig = _G[object]
    if type(orig) ~= "function" then
      return
    end
    _G[object] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  if type(orig) ~= "function" then
    return
  end
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.GetTime = function()
  return 11.2
end

local function fakeFrame(name, parent)
  local frame = { name = name, parent = parent, points = {}, w = 150, h = 10, shown = true }
  function frame:GetName()
    return self.name
  end
  function frame:GetParent()
    return self.parent
  end
  function frame:SetParent(parent)
    self.parent = parent
  end
  function frame:ClearAllPoints()
    self.points = {}
  end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function frame:SetWidth(w)
    self.w = w
  end
  function frame:GetWidth()
    return self.w
  end
  function frame:SetHeight(h)
    self.h = h
  end
  function frame:GetMinMaxValues()
    return 0, self.maxValue or 2.5
  end
  function frame:GetValue()
    return self.value or 1.3
  end
  function frame:CreateFontString()
    local fs = { points = {}, text = "" }
    function fs:SetPoint(...)
      fs.points[#fs.points + 1] = { ... }
    end
    function fs:ClearAllPoints()
      fs.points = {}
    end
    function fs:SetJustifyH(h)
      fs.justifyH = h
    end
    function fs:SetText(text)
      fs.text = text or ""
    end
    function fs:SetFormattedText(fmt, ...)
      fs.text = string.format(fmt, ...)
    end
    function fs:Show()
      fs.shown = true
    end
    function fs:Hide()
      fs.shown = false
    end
    function fs:GetFont()
      return "Fonts\\FRIZQT__.TTF", 10, ""
    end
    function fs:SetFont(path, size, flags)
      fs.fontPath, fs.fontSize, fs.fontFlags = path, size, flags
    end
    frame.font = fs
    return fs
  end
  function frame:HookScript(event, fn)
    frame.hooks = frame.hooks or {}
    frame.hooks[event] = fn
  end
  if name then
    _G[name] = frame
  end
  return frame
end

_G.TargetFrame = fakeFrame("TargetFrame")
_G.TargetFrameManaBar = fakeFrame("TargetFrameManaBar", _G.TargetFrame)
_G.TargetFrameManaBar.w = 119
_G.TargetFrame.manabar = _G.TargetFrameManaBar
_G.TargetFrameSpellBar = fakeFrame("TargetFrameSpellBar", _G.TargetFrame)
_G.TargetFrame.spellbar = _G.TargetFrameSpellBar
_G.TargetFrameSpellBar.casting = true
_G.TargetFrameSpellBar.startTime = 10
_G.TargetFrameSpellBar.endTime = 12.5
_G.TargetFrameToT = fakeFrame("TargetFrameToT", _G.UIParent)
_G.TargetFrame.totFrame = _G.TargetFrameToT
_G.TargetFrameToT:SetPoint("TOPLEFT", _G.TargetFrame, "TOPRIGHT", 4, 0)

_G.TargetSpellBarMixin = {
  AdjustPosition = function(self)
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", self:GetParent(), "BOTTOMLEFT", 43, -25)
    self:SetWidth(150)
  end,
}

function Addon:ParkFrame() end
function Addon:WatchBlizzardUnitEdit() end

assert(loadfile(root .. "skin/darken.lua"))()
assert(loadfile(root .. "skin/frames.lua"))()

assert(Addon:SpellBarTimerCaption(1.24, 2.5) == "1.2 / 2.5",
  "spell bar count is remaining over duration")
assert(Addon:SpellBarTimerCaption(nil, 2.5) == nil, "missing remaining hides the count")

Addon:SkinUnitFrames()
_G.TargetSpellBarMixin.AdjustPosition(_G.TargetFrameSpellBar)

local tot = _G.TargetFrameToT.points[1]
assert(tot[1] == "BOTTOMRIGHT" and tot[2] == _G.TargetFrame and tot[3] == "BOTTOMRIGHT"
    and tot[4] == -35 and tot[5] == -10,
  "target of target stays on the Blizzard default offset")
assert(_G.TargetFrameToT.parent == _G.TargetFrame, "target of target stays a Target Frame child")

local bar = _G.TargetFrameSpellBar
local place = bar.points[1]
assert(place[1] == "TOPLEFT" and place[2] == _G.TargetFrameManaBar
    and place[3] == "BOTTOMLEFT" and place[4] == 0 and place[5] == 0,
  "target spell bar nests under the mana bar")
assert(bar.w == 119, "target spell bar matches mana bar width")
assert(bar.font and bar.font.text == "1.3 / 2.5",
  "target spell bar shows remaining over duration")
assert(bar.font.justifyH == "RIGHT", "cast count sits on the right of the bar")

bar.casting = false
bar.channeling = false
Addon:PaintSpellBarTimer(bar)
assert(bar.font.shown == false, "idle spell bar hides the count")

print("target_spellbar_spec OK")
