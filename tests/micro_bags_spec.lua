-- After Blizzard bars are hidden, micro and bag buttons stay parented to
-- MainMenuBarArtFrame. SkinMicroAndBags must reparent them to a cluster,
-- keep native Blizzard size and art, dock flush to screen bottom-right,
-- and restore layout when Blizzard SetPoint/SetParent runs.
-- Run: lua tests/micro_bags_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  if type(object) == "string" then
    fn = method
    local name = object
    local orig = _G[name]
    if type(orig) ~= "function" then
      return
    end
    _G[name] = function(...)
      orig(...)
      fn(...)
    end
    return
  end
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.UIParent = { name = "UIParent" }
_G.CreateFrame = function(_, name, parent, template)
  local frame = {
    name = name,
    parent = parent or _G.UIParent,
    template = template,
    shown = true,
    points = {},
  }
  function frame:SetParent(nextParent) self.parent = nextParent end
  function frame:GetParent() return self.parent end
  function frame:SetFrameStrata() end
  function frame:GetFrameLevel() return self.level or 1 end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:SetSize(width, height)
    self.width = width
    self.height = height
  end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:SetAlpha() end
  function frame:SetClipsChildren() end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  return frame
end

local function fakeButton(name, parent, shown)
  local button = {
    name = name,
    parent = parent,
    shown = shown,
    points = {},
    sized = false,
  }
  function button:SetParent(frame) self.parent = frame end
  function button:GetParent() return self.parent end
  function button:SetSize(width, height)
    self.sized = true
    self.width = width
    self.height = height
  end
  function button:GetWidth() return self.width or 28 end
  function button:GetHeight() return self.height or 58 end
  function button:SetScale(scale) self.scale = scale end
  function button:GetHitRectInsets()
    return 0, 0, 18, 0
  end
  function button:SetHitRectInsets(l, r, t, b)
    self.hitInsets = { l, r, t, b }
  end
  function button:GetFrameLevel() return self.level or 4 end
  function button:SetFrameLevel(level) self.level = level end
  function button:SetClipsChildren() end
  local function fakeArt()
    local art = { points = {} }
    function art:SetVertexColor(r)
      button.vertex = r
    end
    function art:SetTexCoord(left, right, top, bottom)
      button.texCoord = { left, right, top, bottom }
    end
    function art:SetAlpha(a)
      button.frameArtAlpha = a
    end
    function art:ClearAllPoints()
      button.artPoints = {}
      art.points = {}
    end
    function art:SetAllPoints(frame)
      button.artFill = frame
    end
    function art:SetPoint(...)
      local point = { ... }
      button.artPoints = button.artPoints or {}
      button.artPoints[#button.artPoints + 1] = point
      art.points[#art.points + 1] = point
    end
    return art
  end
  function button:GetNormalTexture()
    return fakeArt()
  end
  function button:GetPushedTexture()
    return fakeArt()
  end
  function button:GetDisabledTexture()
    return fakeArt()
  end
  function button:GetHighlightTexture()
    return fakeArt()
  end
  function button:Show() self.shown = true end
  function button:Hide() self.shown = false end
  function button:IsShown() return self.shown end
  function button:ClearAllPoints() self.points = {} end
  function button:SetPoint(point, relative, relativePoint, x, y)
    self.points[#self.points + 1] = { point, relative, relativePoint, x, y }
  end
  function button:SetScript() end
  return button
end

local art = { name = "MainMenuBarArtFrame", shown = true }
function art:Show() self.shown = true end
function art:Hide() self.shown = false end
function art:SetParent() end
function art:ClearAllPoints() end
function art:SetPoint() end
function art:SetScript() end
_G.MainMenuBarArtFrame = art
_G.MainMenuBarBackpackButton = fakeButton("MainMenuBarBackpackButton", art, false)
_G.MainMenuBarBackpackButton.width = 37
_G.MainMenuBarBackpackButton.height = 37
_G.CharacterMicroButton = fakeButton("CharacterMicroButton", art, false)
_G.SpellbookMicroButton = fakeButton("SpellbookMicroButton", art, false)
_G.TalentMicroButton = fakeButton("TalentMicroButton", art, false)
_G.AchievementMicroButton = fakeButton("AchievementMicroButton", art, true)
_G.QuestLogMicroButton = fakeButton("QuestLogMicroButton", art, false)
_G.SocialsMicroButton = fakeButton("SocialsMicroButton", art, false)
_G.GuildMicroButton = fakeButton("GuildMicroButton", art, true)
_G.WorldMapMicroButton = fakeButton("WorldMapMicroButton", art, false)
_G.StoreMicroButton = fakeButton("StoreMicroButton", art, true)
_G.MainMenuMicroButton = fakeButton("MainMenuMicroButton", art, false)
_G.HelpMicroButton = fakeButton("HelpMicroButton", art, false)
_G.CharacterBag0Slot = fakeButton("CharacterBag0Slot", art, true)
_G.KeyRingButton = fakeButton("KeyRingButton", art, true)
_G.MicroButtonPortrait = { points = {}, parent = _G.CharacterMicroButton }
function _G.MicroButtonPortrait:SetParent(frame) self.parent = frame end
function _G.MicroButtonPortrait:ClearAllPoints() self.points = {} end
function _G.MicroButtonPortrait:SetPoint(...)
  self.points[#self.points + 1] = { ... }
end
function _G.MicroButtonPortrait:SetSize(width, height)
  self.width = width
  self.height = height
end
function _G.MicroButtonPortrait:SetTexCoord(left, right, top, bottom)
  self.texCoord = { left, right, top, bottom }
end
function _G.MicroButtonPortrait:SetAlpha(a) self.alpha = a end
function _G.CharacterMicroButton_SetNormal()
  _G.MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9)
  _G.MicroButtonPortrait:SetAlpha(1)
end
function _G.CharacterMicroButton_SetPushed()
  _G.MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333)
  _G.MicroButtonPortrait:SetAlpha(0.5)
end

assert(loadfile(root .. "skin/chrome.lua"))()

local char = { useShadowUIMenu = true }
function Addon:GetCharDB()
  return char
end

assert(loadfile(root .. "skin/micro.lua"))()
Addon:SkinMicroAndBags()

local bag = _G.MainMenuBarBackpackButton
assert(bag.parent ~= art, "backpack must leave the art frame")
assert(bag.parent.name == "ShadowUIMicroCluster", "backpack parents to the ShadowUI cluster")
assert(bag.shown, "backpack must be shown")

local character = _G.CharacterMicroButton
local host = character._shadowUIHost
assert(host, "each micro button sits in a native-size host")
assert(not host.clipsChildren, "hosts must not clip Blizzard art")
assert(host.parent.name == "ShadowUIMicroCluster", "hosts parent to the ShadowUI cluster")
assert(character.parent == host, "micro buttons parent to their host")
assert(character.shown, "micro buttons must be shown")
assert(host.width == 28 and host.height == 58, "host matches native 28x58 size")
assert(character.width == 28 and character.height == 58,
  "micro buttons keep native 28x58 size so the glyph is not stretched")
assert(not character.scale or character.scale >= 1, "micro buttons are not scaled down")
assert(character.vertex == nil, "micro buttons keep native vertex colour")
assert(_G.SocialsMicroButton.shown, "Classic Era Socials button must stay in the row")
assert(_G.GuildMicroButton.shown == false, "GuildMicroButton is a no-op on Classic Era and must stay hidden")
assert(_G.AchievementMicroButton.shown == false, "AchievementMicroButton stays out of the Micro Cluster")
assert(_G.StoreMicroButton.shown == false, "StoreMicroButton stays out of the Micro Cluster")
assert(bag.width == 37 and bag.height == 37, "backpack keeps native Blizzard size")

local cluster = host.parent
local dock = cluster.points[#cluster.points]
assert(dock[1] == "BOTTOMRIGHT" and dock[2] == _G.UIParent and dock[3] == "BOTTOMRIGHT",
  "cluster docks to screen bottom-right")
assert(dock[4] == 0 and dock[5] == 0, "cluster has no margin")
assert(host.points[#host.points][1] == "BOTTOMRIGHT", "micro row sits on the bottom edge")
assert(host.points[#host.points][4] == 0,
  "micro frames keep no gap between items")
assert(host.points[#host.points][5] == 0,
  "micro row has no gap above the bottom of the screen")
assert(_G.SpellbookMicroButton.texCoord == nil,
  "micro art must keep native UVs; do not crop or stretch the glyph")
assert(_G.SpellbookMicroButton.artFill == nil,
  "micro art must keep native points; do not fill a square crop")
local portrait = _G.MicroButtonPortrait
assert(portrait.parent == _G.CharacterMicroButton, "portrait stays on the Character button")
assert(portrait.texCoord == nil, "portrait keeps native Blizzard tex coords")
_G.CharacterMicroButton_SetNormal()
assert(portrait.texCoord[1] == 0.2 and portrait.texCoord[3] == 0.0666,
  "SetNormal keeps the native portrait hole")
_G.CharacterMicroButton_SetPushed()
assert(portrait.texCoord[1] == 0.2666 and portrait.texCoord[3] == 0,
  "SetPushed keeps the native portrait shift")
assert(character.shadowUIOuter == nil or character.shadowUIOuter.shown == false,
  "micro buttons do not use Outer Edge")
assert(host.shadowUIOuter == nil or host.shadowUIOuter.shown == false,
  "micro hosts do not use Outer Edge")
assert(bag.shadowUIOuter == nil or bag.shadowUIOuter.shown == false,
  "backpack does not use Outer Edge")

character:SetParent(art)
character:SetPoint("BOTTOMLEFT", art, "BOTTOMLEFT", 552, 2)
assert(character.parent == host, "SetParent to the art frame must be undone")
assert(host.parent.name == "ShadowUIMicroCluster", "host stays on the cluster")
assert(host.points[#host.points][1] == "BOTTOMRIGHT", "SetPoint to the art frame must be undone")

bag:SetParent(art)
bag:SetPoint("BOTTOMRIGHT", art, "BOTTOMRIGHT", 0, 0)
assert(bag.parent.name == "ShadowUIMicroCluster", "bag SetParent to the art frame must be undone")
assert(bag.points[#bag.points][2].name == "ShadowUIMicroCluster", "bag must stay anchored to the cluster")

assert(_G.CharacterBag0Slot.shown == false, "extra bag slots stay hidden")
assert(_G.KeyRingButton.shown == false, "keyring stays hidden")

char.useShadowUIMenu = false
Addon:SkinMicroAndBags()
assert(character.parent == art, "blizzard menu parents micro buttons to MainMenuBarArtFrame")
assert(bag.parent == art, "blizzard menu parents the backpack to MainMenuBarArtFrame")
assert(cluster.shown == false, "Micro Cluster hides when the Blizzard menu is on")
assert(host.shown == false, "hosts hide when the Blizzard menu is on")
assert(_G.CharacterBag0Slot.shown, "blizzard menu shows extra bag slots")
assert(_G.KeyRingButton.shown, "blizzard menu shows the keyring")
assert(art.shown, "blizzard menu keeps MainMenuBarArtFrame shown")

local dbSrc = assert(io.open(root .. "core/db.lua", "r")):read("*a")
assert(dbSrc:find("useShadowUIMenu%s*=%s*true"), "character default uses the ShadowUI menu")

local configSrc = assert(io.open(root .. "options/config.lua", "r")):read("*a")
assert(configSrc:find("useShadowUIMenu"), "/shadowui exposes the menu toggle")

print("micro_bags_spec OK")
