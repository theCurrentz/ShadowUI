-- Fill is remaining absorb over max. Icons use SetPortraitToTexture so Classic
-- does not stripe the art with SetTexCoord plus SetMask.
-- Classic Era max is rank base plus 10% school bonus (5% on Mana Shield).
-- Run: lua tests/shields_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local unpack = unpack or table.unpack
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent" }
_G.GetTime = function() return 10 end
_G.UnitGUID = function() return "Player-1" end
_G.GameFontHighlightSmall = {
  GetFont = function() return "Fonts\\FRIZQT__.TTF", 10, "" end,
}

local function fakeTex()
  local tex = { points = {}, a = 1 }
  function tex:SetAllPoints() end
  function tex:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetTexture(path) self.texture = path end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetVertexColor(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:SetTexCoord(l, r, t, b) self.crop = { l, r, t, b } end
  function tex:SetWidth(w) self.width = w end
  function tex:SetHeight(h) self.height = h end
  function tex:SetAlpha(a) self.a = a end
  function tex:SetMask(path) self.mask = path end
  function tex:Show() self.shown = true end
  function tex:Hide() self.shown = false end
  return tex
end

local function fakeFont()
  local fs = { text = "", shown = true, fontSize = 0 }
  function fs:SetPoint() end
  function fs:SetJustifyH() end
  function fs:SetFont(_, size)
    self.fontSize = size
  end
  function fs:SetText(text) self.text = text or "" end
  function fs:SetTextColor() end
  function fs:SetAlpha(a) self.a = a end
  function fs:Show() self.shown = true end
  function fs:Hide() self.shown = false end
  return fs
end

_G.CreateFrame = function(_, name, parent)
  local frame = {
    name = name,
    parent = parent,
    points = {},
    shown = true,
    children = {},
  }
  function frame:SetSize(w, h) self.width = w; self.height = h end
  function frame:SetWidth(w) self.width = w end
  function frame:SetHeight(h) self.height = h end
  function frame:GetWidth() return self.width or 0 end
  function frame:GetHeight() return self.height or 0 end
  function frame:SetAlpha(a) self.a = a end
  function frame:SetFrameStrata() end
  function frame:SetFrameLevel() end
  function frame:SetClipsChildren(clips) self.clips = clips end
  function frame:EnableMouse() end
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...)
    self.points[#self.points + 1] = { ... }
  end
  function frame:CreateTexture()
    local tex = fakeTex()
    self.children[#self.children + 1] = tex
    return tex
  end
  function frame:CreateFontString()
    local fs = fakeFont()
    self.fontString = fs
    return fs
  end
  function frame:CreateFrame(_, childName)
    local child = _G.CreateFrame("Frame", childName, frame)
    self.children[#self.children + 1] = child
    return child
  end
  function frame:SetScript(event, fn) self["script_" .. event] = fn end
  function frame:RegisterEvent() end
  function frame:RegisterUnitEvent() end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:IsShown() return self.shown end
  function frame:GetParent() return self.parent end
  return frame
end

_G.PlayerFrame = _G.CreateFrame("Frame", "PlayerFrame")
_G.PlayerName = _G.CreateFrame("Frame", "PlayerName", _G.PlayerFrame)
_G.SetPortraitToTexture = function(tex, path)
  tex.portrait = path
  tex.texture = path
end

assert(loadfile(root .. "cast/shields.lua"))()
assert(loadfile(root .. "cast/shieldrow.lua"))()

-- Wowhead Classic Fire Ward rank 5 (10225) absorbs 920. School bonus is 10%.
-- 100 generic SP + 100 fire SP is 200 bonus → 920 + 20 = 940.
assert(Addon:ShieldAbsorbMax(10225, 200) == 940,
  "Fire Ward rank 5 adds 10% of fire plus generic spell power")
assert(Addon:ShieldAbsorbMax(28609, 200) == 940,
  "Frost Ward rank 5 uses the same 10% frost bonus")
assert(Addon:ShieldAbsorbMax(28610, 200) == 940,
  "Shadow Ward rank 5 uses 10% shadow bonus")
assert(Addon:ShieldAbsorbMax(10901, 100) == 952,
  "Power Word: Shield rank 10 adds 10% of bonus healing")
assert(Addon:ShieldAbsorbMax(10901, 100, { improvedPowerWordShield = 3 }) == 1094,
  "Improved Power Word: Shield 3 adds 15% after the healing bonus")
assert(Addon:ShieldAbsorbMax(13033, 100) == 828,
  "Ice Barrier rank 4 adds 10% of frost spell power")
assert(Addon:ShieldAbsorbMax(13033, 100, { improvedIceBarrier = 2 }) == 1076,
  "Improved Ice Barrier 2 adds 30% after the frost bonus")
assert(Addon:ShieldAbsorbMax(28609, 200, { frostWarding = 2 }) == 1128,
  "Frost Warding 2 adds 20% to Frost Ward after the frost bonus")
assert(Addon:ShieldAbsorbMax(10193, 200) == 580,
  "Mana Shield rank 6 adds 5% of arcane spell power")
assert(Addon:ShieldAbsorbMax(1, 200) == nil, "unknown spells are not shields")

local half = Addon:ShieldFill(470, 940)
assert(half.ratio == 0.5, "half remaining is a half fill")
assert(half.text == "50%", "half remaining prints 50%")
assert(Addon:ShieldFill(0, 940).text == "0%", "empty shield prints 0%")
assert(Addon:ShieldFill(940, 940).text == "100%", "full shield prints 100%")
assert(Addon:ShieldFill(10, 0).ratio == 0, "zero max does not divide")

local fire = {
  spellId = 10225,
  remaining = 940,
  max = 940,
}
local ice = {
  spellId = 13033,
  remaining = 818,
  max = 818,
}
local shields = { fire, ice }
-- Fire damage hits the fire ward first (school 4), then Ice Barrier.
Addon:ShieldApplyAbsorb(shields, 200, 4)
assert(fire.remaining == 740, "Fire Ward eats fire damage first")
assert(ice.remaining == 818, "Ice Barrier waits until the ward is gone")
Addon:ShieldApplyAbsorb(shields, 800, 4)
assert(fire.remaining == 0, "Fire Ward can empty")
assert(ice.remaining == 758, "overflow fire goes into Ice Barrier")
Addon:ShieldApplyAbsorb(shields, 50, 1, 13033)
assert(ice.remaining == 708, "SPELL_ABSORBED can name Ice Barrier")

-- Combat-log prefix is 11 fields. Fire Ward must read absorbed from both
-- Classic (no overkill) and modern (overkill) SPELL_DAMAGE layouts.
local PREFIX = {
  0, "SPELL_DAMAGE", false,
  "Creature-1", "Hogger", 0, 0,
  "Player-1", "Currentz", 0, 0,
}
local function spellDamage(overkill, absorbed)
  local info = { unpack(PREFIX) }
  info[2] = "SPELL_DAMAGE"
  info[12], info[13], info[14] = 133, "Fireball", 4
  if overkill then
    info[15], info[16], info[17] = 0, 0, 4
    info[18], info[19], info[20] = 0, 0, absorbed
  else
    info[15], info[16], info[17] = 0, 4, 0
    info[18], info[19] = 0, absorbed
  end
  return info
end

local amount, school = Addon:ShieldAbsorbFromInfo("SPELL_DAMAGE", spellDamage(true, 200))
assert(amount == 200 and school == 4, "modern Fireball absorb is 200 fire")

amount, school = Addon:ShieldAbsorbFromInfo("SPELL_DAMAGE", spellDamage(false, 200))
assert(amount == 200 and school == 4, "Classic Fireball absorb is 200 fire")

local missed = { unpack(PREFIX) }
missed[2] = "SPELL_MISSED"
missed[12], missed[13], missed[14] = 133, "Fireball", 4
missed[15], missed[16] = "ABSORB", 200
amount, school = Addon:ShieldAbsorbFromInfo("SPELL_MISSED", missed)
assert(amount == 200, "Classic full absorb uses SPELL_MISSED amount")

missed[16], missed[17] = false, 200
amount = Addon:ShieldAbsorbFromInfo("SPELL_MISSED", missed)
assert(amount == 200, "modern full absorb uses SPELL_MISSED amount")

local ward = { spellId = 10225, remaining = 940, max = 940 }
local a, s = Addon:ShieldAbsorbFromInfo("SPELL_DAMAGE", spellDamage(false, 200))
Addon:ShieldApplyAbsorb({ ward }, a, s)
assert(ward.remaining == 740, "Classic Fireball hits reduce Fire Ward remaining")

Addon:ApplyShields()
local row = Addon.shieldRow
assert(row, "creates the Shield Row")
assert(row.points[1][2] == _G.PlayerName, "locks to the player name")
assert(row.points[1][1] == "BOTTOMLEFT", "anchors left")
assert(row.points[1][3] == "TOPLEFT", "sits on the left of the player name")
assert(row.points[1][5] == 4, "sits 4px above the player name")
assert(row.a == 0.70, "Shield Row is a touch more transparent")

Addon:ShieldSyncAuras(row, { { spellId = 10225 } }, {}, function() return 200 end)
assert(row.shields[1] and row.shields[1].remaining == 940, "new Fire Ward snapshots max absorb")
Addon:ShieldRowPaint(row)
local icon = row.icons[1]
assert(icon.shown, "active shield shows an icon")
assert(icon.width == 22 and icon.height == 22, "shield icons stay square so art is not warped")
assert(icon.art.portrait and icon.art.portrait:find("FireArmor", 1, true),
  "SetPortraitToTexture crops the spell icon to an oval")
assert(not icon.art.crop, "portrait crop must not also SetTexCoord")
assert(not icon.art.mask, "portrait crop must not also SetMask")
assert(icon.clip and icon.clip.clips == true, "fill uses a clip frame, not SetTexCoord after mask")
assert(icon.clip.height == 22, "full shield fills the whole icon")
assert(icon.fill.portrait and icon.fill.portrait:find("FireArmor", 1, true),
  "fill uses the same oval portrait crop")
assert(icon.percent.text == "100%", "full shield reads 100%")
assert(icon.percent.fontSize == 7, "percent text is small")
assert(icon.fill.r > 0.9 and icon.fill.g < 0.6, "Fire Ward fill is fire-coloured")

row.shields[1].remaining = 470
Addon:ShieldRowPaint(row)
assert(icon.clip.height == 11, "half shield clips the lower half")
assert(icon.percent.text == "50%", "half shield reads 50%")

Addon:ShieldSyncAuras(row, { { spellId = 10225 }, { spellId = 13033 } }, {}, function() return 0 end)
assert(#row.shields == 2, "Ice Barrier joins the row")
assert(Addon:ShieldRowSlotX(1, 2) == 0, "first icon sits on the left")
assert(Addon:ShieldRowSlotX(2, 2) == 28, "second icon sits to the right of the first")
row.icons[1].x = -40
row.icons[1].vx = 0
for _ = 1, 90 do
  Addon:ShieldRowPulse(row, 0.016)
end
assert(math.abs(row.icons[1].x - 0) < 1, "icons spring to their slot")

Addon:ShieldSyncAuras(row, {}, {}, function() return 0 end)
Addon:ShieldRowPulse(row, 0.5)
assert(row.icons[1].targetAlpha == 0, "dropped shields fade out")

print("shields_spec OK")
