-- Cooldown Manager queues tracked class cooldowns with insert and pop.
-- Run: lua tests/cdmanager_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.GetTime = function() return 40 end
_G.GetSpellInfo = function(id)
  if id == 1719 then
    return "Recklessness", "Interface\\Icons\\Ability_CriticalStrike"
  end
  if id == 871 then
    return "Shield Wall", "Interface\\Icons\\Ability_Warrior_ShieldWall"
  end
  if id == 1680 then
    return "Whirlwind", "Interface\\Icons\\Ability_Whirlwind"
  end
  if id == 1725 then
    return "Distract", "Rank 1", "Interface\\Icons\\Ability_Rogue_Distract"
  end
  if id == 45438 then
    return "Ice Block", "", 135841
  end
  if id == 2983 or id == 8696 or id == 11305 then
    return "Sprint", "Rank 3", "Interface\\Icons\\Ability_Rogue_Sprint"
  end
  if id == 5277 then
    return "Evasion", "Rank 1", "Interface\\Icons\\Spell_Shadow_ShadowWard"
  end
  if id == 26669 then
    return "Evasion", "Rank 2", "Interface\\Icons\\Spell_Shadow_ShadowWard"
  end
  if id == 99991 then
    return "Bar Utility", "Rank 2", "Interface\\Icons\\INV_Misc_QuestionMark"
  end
end
_G.GetSpellCooldown = function(id)
  if id == 1719 or id == "Recklessness" then
    return 20, 30, 1
  end
  if id == 871 then
    return 0, 0, 1
  end
  if id == 1680 then
    return 39, 1.5, 1
  end
  if id == 1725 then
    return 20, 30, 1
  end
  if id == 2983 or id == 8696 or id == 11305 or id == "Sprint" then
    return 20, 30, 1
  end
  if id == 5277 or id == 26669 or id == "Evasion" then
    return 20, 30, 1
  end
  if id == 99991 then
    return 20, 30, 1
  end
  return 0, 0, 0
end

assert(loadfile(root .. "defaults/cooldowns.lua"))()
assert(loadfile(root .. "bars/grid.lua"))()
assert(loadfile(root .. "bars/cdmanager.lua"))()

local list = Addon:CooldownSpellList("WARRIOR")
assert(#list >= 8, "Warrior ships a Cooldown Manager list")
assert(list[1].spellId and list[1].label, "each shipped cooldown has an id and label")

local account = { classes = {} }
function Addon:GetDB()
  return account
end
function Addon:GetPlayerClass()
  return "WARRIOR"
end
assert(Addon:CooldownSpellHidden(1719) == false, "shipped cooldowns start shown")
Addon:SetCooldownSpellHidden(1719, true)
assert(account.classes.WARRIOR.cooldownHidden[1719] == true, "hide writes Class")
assert(Addon:CooldownSpellHidden(1719) == true, "hidden spells drop from the queue")

local active = Addon:CooldownQueueState(40, {
  { spellId = 1719, start = 20, duration = 30 },
  { spellId = 871, start = 0, duration = 0 },
  { spellId = 1680, start = 39, duration = 1.5 },
})
assert(#active == 1, "GCD and ready spells stay out of the queue")
assert(active[1].spellId == 1719, "Recklessness is on cooldown")
assert(active[1].text == "10", "queue uses remaining seconds")

local diff = Addon:CooldownQueueDiff({ 871, 1719 }, { 1719, 1680 })
assert(diff.insert[1] == 1680, "a new cooldown inserts")
assert(diff.remove[1] == 871, "a finished cooldown pops")
assert(diff.keep[1] == 1719, "a live cooldown stays")

assert(Addon:CooldownDirection({ vertical = true }) == "down",
  "a Vertical layout becomes Down")
assert(Addon:CooldownDirection({ direction = "left" }) == "left",
  "Direction wins over Vertical")
assert(Addon:CooldownDirection({}) == "right", "the default Direction is Right")

local x, y = Addon:CooldownSlotOffset(1, 3, { buttonSize = 32, gap = 4, vertical = false })
assert(x == -36 and y == 0, "first icon sits left of centre in a horizontal queue")
local x2 = Addon:CooldownSlotOffset(2, 3, { buttonSize = 32, gap = 4, vertical = false })
assert(x2 == 0, "middle icon sits on centre")
local _, yv = Addon:CooldownSlotOffset(1, 2, { buttonSize = 32, gap = 4, vertical = true })
assert(yv == 18, "Down starts at the top of a vertical queue")

local wrap = { buttonSize = 32, gap = 4, columns = 2, max = 4, direction = "right" }
local wx, wy = Addon:CooldownSlotOffset(3, 4, wrap)
assert(wx == -18 and wy == -18, "Right wrap puts slot 3 on the second row")
local lx = Addon:CooldownSlotOffset(1, 4, {
  buttonSize = 32, gap = 4, columns = 2, max = 4, direction = "left",
})
assert(lx == 18, "Left starts on the right")
local _, uy = Addon:CooldownSlotOffset(1, 2, {
  buttonSize = 32, gap = 4, columns = 1, max = 2, direction = "up",
})
assert(uy == -18, "Up starts at the bottom")

local grid = Addon:CooldownGridMetrics({
  buttonSize = 32, gap = 4, columns = 4, max = 8, direction = "right",
})
assert(grid.columns == 4 and grid.rows == 2, "wrap uses columns and max")
assert(grid.width == 4 * 32 + 3 * 4, "grid width is columns of icons plus gaps")
assert(grid.height == 2 * 32 + 4, "grid height is rows of icons plus gaps")

local capped = Addon:CooldownQueueCap({
  { spellId = 1 }, { spellId = 2 }, { spellId = 3 },
}, 2)
assert(#capped == 2 and capped[1].spellId == 1 and capped[2].spellId == 2,
  "max keeps the front of the sorted queue")
assert(#Addon:CooldownQueueCap({ { spellId = 1 } }, 8) == 1,
  "max does not invent icons")

assert(Addon:CooldownInsertAlpha(0, 0.2) == 0, "insert starts hidden")
assert(math.abs(Addon:CooldownInsertAlpha(0.2, 0.2) - 1) < 0.001, "insert ends opaque")
assert(math.abs(Addon:CooldownPopAlpha(0, 0.2) - 1) < 0.001, "pop starts opaque")
assert(Addon:CooldownPopAlpha(0.2, 0.2) == 0, "pop ends hidden")
assert(Addon:CooldownPopDrop(0, 0.2) == 0, "drop starts at the queue slot")
assert(Addon:CooldownPopDrop(0.2, 0.2) == 14, "drop ends 14px off the slot")
assert(Addon:CooldownShiftCoord(10, 20, 0, 0.2) == 10, "shift starts at the old slot")
assert(Addon:CooldownShiftCoord(10, 20, 0.2, 0.2) == 20, "shift ends at the new slot")

account.classes.WARRIOR.cooldownHidden[1719] = true
local tracked = Addon:TrackedCooldownEntries(40)
local foundWall, foundReck
for _, entry in ipairs(tracked) do
  if entry.spellId == 871 then foundWall = true end
  if entry.spellId == 1719 then foundReck = true end
end
assert(foundReck == nil, "a hidden spell is not tracked")
assert(foundWall == nil, "a ready spell is not queued")

assert(Addon:LooksLikeSpellIcon("Rank 1") == false, "Classic rank is not an icon")
assert(Addon:LooksLikeSpellIcon("Interface\\Icons\\Ability_Rogue_Distract") == true,
  "a texture path is an icon")
assert(Addon:LooksLikeSpellIcon(135841) == true, "a file id is an icon")
assert(Addon:SpellInfoIcon(1725) == "Interface\\Icons\\Ability_Rogue_Distract",
  "Classic GetSpellInfo uses the third return as the icon")
assert(Addon:SpellInfoIcon(45438) == 135841, "a file id from GetSpellInfo still SetTexture")
assert(Addon:SpellInfoIcon(1719) == "Interface\\Icons\\Ability_CriticalStrike",
  "a two-return GetSpellInfo still yields the icon")

local rogue = Addon:CooldownSpellList("ROGUE")
local hasDistract, hasKick
for _, spell in ipairs(rogue) do
  if spell.spellId == 1725 then hasDistract = true end
  if spell.spellId == 1766 then hasKick = true end
end
assert(hasDistract, "Rogue Cooldown Manager includes Distract")
assert(hasKick, "Rogue Cooldown Manager includes Kick")

function Addon:GetPlayerClass()
  return "ROGUE"
end
account.classes.ROGUE = { layout = {}, keybinds = {}, variants = {}, cooldownHidden = {} }
local rogueQueue = Addon:TrackedCooldownEntries(40)
local distractIcon
for _, entry in ipairs(rogueQueue) do
  if entry.spellId == 1725 then
    distractIcon = entry.icon
  end
end
assert(distractIcon == "Interface\\Icons\\Ability_Rogue_Distract",
  "Distract queues with the spell icon, not the rank string")

_G.GetActionInfo = function(slot)
  if slot == 8 then
    return "spell", 99991
  end
  if slot == 3 then
    return "spell", 11305
  end
end
_G.GetActionTexture = function(slot)
  if slot == 8 then
    return "Interface\\Icons\\INV_Misc_QuestionMark"
  end
  if slot == 3 then
    return "Interface\\Icons\\Ability_Rogue_Sprint"
  end
end
local withBar = Addon:TrackedCooldownEntries(40)
local foundBar
for _, entry in ipairs(withBar) do
  if entry.spellId == 99991 then
    foundBar = entry
  end
end
assert(foundBar and foundBar.icon == "Interface\\Icons\\INV_Misc_QuestionMark",
  "a long cooldown on an Action Slot joins the queue")

Addon:SetCooldownSpellHidden(1725, true)
local hiddenDistract
for _, entry in ipairs(Addon:TrackedCooldownEntries(40)) do
  if entry.spellId == 1725 then
    hiddenDistract = true
  end
end
assert(hiddenDistract == nil, "Class hide still drops a listed spell that is on a bar")

assert(Addon:CooldownSpellKey(2983) == "sprint", "Sprint key is the spell name")
assert(Addon:CooldownSpellKey(11305) == "sprint", "Sprint ranks share one key")
assert(Addon:CooldownSpellKey(5277) == Addon:CooldownSpellKey(26669),
  "Evasion ranks share one key")
local sprintIds = {}
for _, entry in ipairs(Addon:TrackedCooldownEntries(40)) do
  if entry.spellId == 2983 or entry.spellId == 8696 or entry.spellId == 11305 then
    sprintIds[#sprintIds + 1] = entry.spellId
  end
end
assert(#sprintIds == 1, "Sprint ranks collapse to one queue icon")
assert(sprintIds[1] == 2983, "the Class list Sprint id stays the queue key")

Addon:SetCooldownSpellHidden(2983, true)
local sprintHidden
for _, entry in ipairs(Addon:TrackedCooldownEntries(40)) do
  if entry.spellId == 2983 or entry.spellId == 11305 then
    sprintHidden = true
  end
end
assert(sprintHidden == nil, "hiding listed Sprint drops every rank")

-- Stealth is on an Action Slot, not the Class list. Classic GetSpellCooldown
-- can return start = now and duration = 10 on every poll (energy tick).
local clock = 200
local oldInfo = _G.GetSpellInfo
_G.GetSpellInfo = function(id)
  if id == 1784 then
    return "Stealth", "Rank 1", "Interface\\Icons\\Ability_Stealth"
  end
  return oldInfo(id)
end
local oldCd = _G.GetSpellCooldown
_G.GetSpellCooldown = function(id)
  if id == 1784 or id == "Stealth" then
    return clock, 10, 1
  end
  return oldCd(id)
end
local oldAction = _G.GetActionInfo
_G.GetActionInfo = function(slot)
  if slot == 2 then
    return "spell", 1784
  end
  return oldAction(slot)
end
clock = 200
local stealthAtStart
for _, entry in ipairs(Addon:TrackedCooldownEntries(200)) do
  if entry.spellId == 1784 then
    stealthAtStart = entry
  end
end
assert(stealthAtStart and stealthAtStart.text == "10", "Stealth joins the queue from an Action Slot")
clock = 204
local stealthLater
for _, entry in ipairs(Addon:TrackedCooldownEntries(204)) do
  if entry.spellId == 1784 then
    stealthLater = entry
  end
end
assert(stealthLater, "Stealth stays on the queue while the cooldown runs")
assert(stealthLater.text == "6", "a drifting GetSpellCooldown start does not stick remaining seconds")
assert(math.abs(stealthLater.remaining - 6) < 0.01, "Stealth remaining follows wall clock")
assert(stealthLater.start == 200 and stealthLater.duration == 10,
  "the Cooldown Manager keeps the first Stealth clock")

-- While stealthed, Classic sets enabled=0 and start=now. Duration stays 10.
-- That is not a new cooldown. The 10s clock started on enter.
_G.GetSpellCooldown = function(id)
  if id == 1784 or id == "Stealth" then
    return clock, 10, 0
  end
  return oldCd(id)
end
clock = 206
local stealthActive
for _, entry in ipairs(Addon:TrackedCooldownEntries(206)) do
  if entry.spellId == 1784 then
    stealthActive = entry
  end
end
assert(stealthActive and stealthActive.text == "4",
  "Stealth still counts down while the spell is active")
assert(stealthActive.start == 200, "an active Stealth poll does not move the pin")

clock = 211
local stealthStillActive
for _, entry in ipairs(Addon:TrackedCooldownEntries(211)) do
  if entry.spellId == 1784 then
    stealthStillActive = true
  end
end
assert(stealthStillActive == nil,
  "Stealth leaves the queue when the enter cooldown ends, even if still stealthed")

clock = 215
local stealthSecondCountdown
for _, entry in ipairs(Addon:TrackedCooldownEntries(215)) do
  if entry.spellId == 1784 then
    stealthSecondCountdown = true
  end
end
assert(stealthSecondCountdown == nil,
  "a later active Stealth poll does not start a second countdown")

_G.GetSpellCooldown = function(id)
  if id == 1784 or id == "Stealth" then
    return 0, 0, 1
  end
  return oldCd(id)
end
local stealthIdle
for _, entry in ipairs(Addon:TrackedCooldownEntries(216)) do
  if entry.spellId == 1784 then
    stealthIdle = true
  end
end
assert(stealthIdle == nil, "Stealth leaves the queue when GetSpellCooldown is idle")

_G.GetSpellCooldown = function(id)
  if id == 1784 or id == "Stealth" then
    return clock, 10, 0
  end
  return oldCd(id)
end
clock = 220
local stealthAgain
for _, entry in ipairs(Addon:TrackedCooldownEntries(220)) do
  if entry.spellId == 1784 then
    stealthAgain = entry
  end
end
assert(stealthAgain and stealthAgain.start == 220,
  "a new Stealth cooldown pins a new clock")
clock = 224
local stealthAgainLater
for _, entry in ipairs(Addon:TrackedCooldownEntries(224)) do
  if entry.spellId == 1784 then
    stealthAgainLater = entry
  end
end
assert(stealthAgainLater and stealthAgainLater.text == "6",
  "the first active Stealth poll still counts down")
clock = 231
local stealthAgainDone
for _, entry in ipairs(Addon:TrackedCooldownEntries(231)) do
  if entry.spellId == 1784 then
    stealthAgainDone = true
  end
end
assert(stealthAgainDone == nil,
  "a new Stealth period does not restart after its own 10s clock")

_G.CreateFrame = function(_, _, parent, template)
  local frame = { points = {}, parent = parent, template = template, shown = true }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetAllPoints(host) self.all = host end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level or 4 end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a)
    self.fill = { r, g, b, a }
  end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.border = { r, g, b, a }
  end
  function frame:SetParent(parent) self.parent = parent end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:SetClipsChildren(clips) self.clipsChildren = clips end
  function frame:SetSize(w, h) self.w, self.h = w, h end
  function frame:GetWidth() return self.w end
  function frame:GetHeight() return self.h end
  function frame:CreateTexture()
    local tex = { points = {} }
    function tex:ClearAllPoints() self.points = {} end
    function tex:SetAllPoints(host) self.all = host end
    function tex:SetPoint(...) self.points[#self.points + 1] = { ... } end
    function tex:SetColorTexture(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    function tex:SetTexture(path) self.file = path end
    function tex:SetTexCoord(l, r, t, b) self.crop = { l, r, t, b } end
    function tex:SetDrawLayer() end
    function tex:Show() self.hidden = false end
    function tex:Hide() self.hidden = true end
    return tex
  end
  return frame
end

assert(loadfile(root .. "skin/chrome.lua"))()

local host = { name = "ShadowUICooldownManager", clips = true }
function host:SetClipsChildren(clips) self.clips = clips end
local cdIcon = _G.CreateFrame("Frame", nil, host)
cdIcon.texture = cdIcon:CreateTexture()
function cdIcon.texture:SetTexture(path) self.file = path end
cdIcon.swipe = _G.CreateFrame("Cooldown", nil, cdIcon, "CooldownFrameTemplate")
function cdIcon.swipe:SetDrawSwipe(on) self.swipe = on end
function cdIcon.swipe:SetDrawEdge(on) self.edge = on end
function cdIcon:GetParent() return host end
cdIcon:SetSize(36, 80)
cdIcon.texture.file = "Interface\\Icons\\Ability_Warrior_OffensiveStance"

Addon:SkinCooldownIcon(cdIcon, 36)
assert(cdIcon.w == 36 and cdIcon.h == 36, "Cooldown Manager icon stays square")
assert(cdIcon.shadowUIChrome and cdIcon.shadowUIChrome.r == 0.05,
  "Cooldown Manager chrome is Lorti darkest")
assert(cdIcon.texture.points[1] and cdIcon.texture.points[1][2] == cdIcon
    and cdIcon.texture.points[1][4] == 2,
  "Cooldown Manager icon insets 2px on the square")
assert(cdIcon.texture.crop and cdIcon.texture.crop[1] == 0.07,
  "Cooldown Manager icon crop matches action icons")
assert(cdIcon.swipe.points[1] and cdIcon.swipe.points[1][2] == cdIcon
    and cdIcon.swipe.points[1][4] == 2,
  "Cooldown Manager swipe insets with the icon")
local cdOuter = cdIcon.shadowUIOuter
assert(cdOuter, "Cooldown Manager keeps a Lorti Outer Edge")
assert(cdOuter.backdrop and cdOuter.backdrop.edgeFile:find("outer_shadow", 1, true),
  "Cooldown Manager Outer Edge uses the Lorti shadow texture")
assert(cdOuter.parent == cdIcon, "Outer Edge stays on the square icon")
assert(cdOuter.points[1] and cdOuter.points[1][2] == cdIcon,
  "Outer Edge anchors to the icon, not the queue host")
assert(cdIcon.clipsChildren == false, "the Cooldown Manager icon does not clip Outer Edge")
assert(host.clips == false, "the Cooldown Manager does not clip Outer Edge")

print("cdmanager_spec OK")
