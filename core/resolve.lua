--[[
  Purpose: Merge shipped Class defaults with the active Account Profile.
  Deps: ShadowUI db helpers, ShadowUI.Defaults
  Public: DeepCopy, SparseMerge, ShippedClass, EnsureProfiles, GetActiveProfileName,
          GetProfile, ResolveShipped, ResolveEffective, ResolveBarVisual, ResolveBarRowGaps,
          BarLayoutForApply, WriteProfileDelta, WriteLayerDelta, TalentPointsFromTabInfo,
          GetPrimaryTalentTree
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:DeepCopy(src)
  if type(src) ~= "table" then return src end
  local out = {}
  for k, v in pairs(src) do
    out[k] = self:DeepCopy(v)
  end
  return out
end

function Addon:SparseMerge(dst, src)
  if type(src) ~= "table" then return dst end
  for k, v in pairs(src) do
    if type(v) == "table" and type(dst[k]) == "table" then
      self:SparseMerge(dst[k], v)
    elseif type(v) == "table" then
      dst[k] = self:DeepCopy(v)
    else
      dst[k] = v
    end
  end
  return dst
end

function Addon:ShippedClass(classFile)
  classFile = classFile or self:GetPlayerClass()
  local shipped = self.Defaults or { classes = {} }
  return (shipped.classes or {})[classFile] or {}
end

local FALLBACK_PROFILE = "Default"

local function emptyProfile()
  return { layout = {}, keybinds = {}, actions = {} }
end

local function profileFields(src)
  if type(src) ~= "table" then
    return { layout = {}, keybinds = {} }
  end
  return { layout = src.layout or {}, keybinds = src.keybinds or {} }
end

function Addon:EnsureProfiles()
  local db = self:GetDB()
  db.profiles = db.profiles or {}
  if type(db.defaultProfile) ~= "string" or db.defaultProfile == "" then
    db.defaultProfile = FALLBACK_PROFILE
  end
  if not next(db.profiles) then
    db.profiles[db.defaultProfile] = emptyProfile()
  elseif not db.profiles[db.defaultProfile] then
    local name = next(db.profiles)
    db.defaultProfile = name
  end
end

function Addon:GetActiveProfileName()
  self:EnsureProfiles()
  local db = self:GetDB()
  local char = self:GetCharDB()
  local selected = char.activeProfile
  if type(selected) == "string" and db.profiles[selected] then
    return selected
  end
  return db.defaultProfile
end

function Addon:GetProfile(name)
  self:EnsureProfiles()
  name = name or self:GetActiveProfileName()
  local db = self:GetDB()
  local profile = db.profiles[name]
  if not profile then
    return nil
  end
  profile.layout = profile.layout or {}
  profile.keybinds = profile.keybinds or {}
  profile.actions = profile.actions or {}
  return profile
end

-- Classic Era returns (name, texture, pointsSpent, ...) while modernized clients
-- return (id, name, description, texture, pointsSpent, ...). Taking the largest
-- numeric candidate of the two slots reads both shapes without guessing a client.
function Addon:TalentPointsFromTabInfo(a, b, c, d, e)
  local third = type(c) == "number" and c or 0
  local fifth = type(e) == "number" and e or 0
  return third > fifth and third or fifth
end

function Addon:GetPrimaryTalentTree()
  if type(GetNumTalentTabs) ~= "function" or type(GetTalentTabInfo) ~= "function" then
    return nil
  end
  local best, bestPts = nil, 0
  for i = 1, GetNumTalentTabs() or 0 do
    local points = self:TalentPointsFromTabInfo(GetTalentTabInfo(i))
    if points > bestPts then
      best, bestPts = i, points
    end
  end
  return best
end

function Addon:ResolveShipped(classFile)
  classFile = classFile or self:GetPlayerClass()
  local shipped = self.Defaults or { base = { layout = {}, keybinds = {} }, classes = {} }
  local eff = { layout = {}, keybinds = {} }
  self:SparseMerge(eff, shipped.base or {})
  local shippedClass = (shipped.classes or {})[classFile] or {}
  self:SparseMerge(eff, profileFields(shippedClass))
  return eff
end

function Addon:ResolveEffective(classFile, profileName)
  local eff = self:ResolveShipped(classFile)
  local profile = self:GetProfile(profileName)
  if profile then
    self:SparseMerge(eff, profileFields(profile))
  end
  return eff
end

local function pickVisual(barCfg, group, global, field, fallback)
  if barCfg[field] ~= nil then
    return barCfg[field]
  end
  if group and group[field] ~= nil then
    return group[field]
  end
  if global and global[field] ~= nil then
    return global[field]
  end
  return fallback
end

local function layoutBarGroup(layout, barCfg)
  local groupName = barCfg and barCfg.group
  if type(groupName) ~= "string" or groupName == "" then
    return nil
  end
  local found = layout.barGroups and layout.barGroups[groupName]
  if type(found) == "table" then
    return found
  end
  return nil
end

function Addon:ResolveBarVisual(layout, barId, barCfg)
  layout = layout or {}
  barCfg = barCfg or layout[barId] or {}
  local group = layoutBarGroup(layout, barCfg)
  local global = layout.global
  if type(global) ~= "table" then
    global = nil
  end
  return {
    gap = pickVisual(barCfg, group, global, "gap", 0),
    iconShape = pickVisual(barCfg, group, global, "iconShape", "square"),
    scale = pickVisual(barCfg, group, global, "scale", 1),
    fadeIdle = pickVisual(barCfg, group, global, "fadeIdle", 1),
  }
end

function Addon:ResolveBarRowGaps(layout, barId, barCfg)
  layout = layout or {}
  barCfg = barCfg or layout[barId] or {}
  local group = layoutBarGroup(layout, barCfg)
  local buttons = math.max(1, barCfg.buttons or 12)
  local columns = math.max(1, barCfg.columns or buttons)
  local rows = math.ceil(buttons / columns)
  local above, below = 0, 0
  if group then
    above = group.gapAbove or 0
    below = group.gapBelow or 0
  elseif barCfg.gapAbove ~= nil or barCfg.gapBelow ~= nil then
    above = barCfg.gapAbove or 0
    below = barCfg.gapBelow or 0
  else
    local rg = barCfg.rowGaps and barCfg.rowGaps[1]
    above = (rg and rg.above) or 0
    below = (rg and rg.below) or 0
  end
  local out = {}
  if above > 0 or below > 0 then
    local pad = { above = above, below = below }
    for row = 1, rows do
      out[row] = pad
    end
  end
  return out
end

function Addon:BarLayoutForApply(layout, barId, barCfg)
  barCfg = barCfg or {}
  local visual = self:ResolveBarVisual(layout, barId, barCfg)
  local out = {}
  for key, value in pairs(barCfg) do
    out[key] = value
  end
  out.gap = visual.gap
  out.iconShape = visual.iconShape
  out.scale = visual.scale
  out.fadeIdle = visual.fadeIdle
  if self.ResolveBarRowGaps then
    out.rowGaps = self:ResolveBarRowGaps(layout, barId, barCfg)
  end
  return out
end

function Addon:WriteProfileDelta(section, key, patch)
  local profile = self:GetProfile()
  if not profile then
    return
  end
  profile[section] = profile[section] or {}
  local store = profile[section]
  -- Layout patches are tables. Keybinds are strings, or false to unbind.
  if type(patch) ~= "table" then
    store[key] = patch
    return
  end
  if type(store[key]) ~= "table" then
    store[key] = {}
  end
  self:SparseMerge(store[key], patch)
end

function Addon:WriteLayerDelta(_, section, key, patch)
  self:WriteProfileDelta(section, key, patch)
end
