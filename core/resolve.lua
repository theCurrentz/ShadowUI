--[[
  Purpose: Merge shipped defaults with Account Base → Class → Variant then Character.
  Deps: ShadowUI db helpers, ShadowUI.Defaults
  Public: DeepCopy, SparseMerge, ShippedClass, ResolveEffective, GetActiveVariantName,
          ResolveBarVisual, ResolveBarRowGaps, BarLayoutForApply, WriteLayerDelta, TalentPointsFromTabInfo,
          GetPrimaryTalentTree
  Notes: ResolveEffective(classFile?, variantName?, through?) stops the merge after
         through (base, class, variant, or character). Omit through for the full merge.
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

local function matchTalentTree(variants, tree)
  if type(variants) ~= "table" or not tree then
    return nil
  end
  for name, variant in pairs(variants) do
    if variant and variant.talentTree == tree then
      return name
    end
  end
  return nil
end

function Addon:GetActiveVariantName(classFile)
  classFile = classFile or self:GetPlayerClass()
  local char = self:GetCharDB()
  if char.variantManual and char.activeVariant then
    return char.activeVariant
  end
  local tree = self:GetPrimaryTalentTree()
  if tree then
    local classAcc = self:GetDB().classes[classFile]
    local accountName = matchTalentTree(classAcc and classAcc.variants, tree)
    if accountName then
      return accountName
    end
    local shippedName = matchTalentTree(self:ShippedClass(classFile).variants, tree)
    if shippedName then
      return shippedName
    end
  end
  return char.activeVariant
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

function Addon:ResolveEffective(classFile, variantName, through)
  classFile = classFile or self:GetPlayerClass()
  variantName = variantName or self:GetActiveVariantName(classFile)
  if through ~= "base" and through ~= "class" and through ~= "variant" then
    through = "character"
  end

  local shipped = self.Defaults or { base = { layout = {}, keybinds = {} }, classes = {} }
  local account = self:GetDB()
  local char = self:GetCharDB()

  local function layerFields(src)
    if type(src) ~= "table" then
      return { layout = {}, keybinds = {} }
    end
    return { layout = src.layout or {}, keybinds = src.keybinds or {} }
  end

  local includeClass = through ~= "base"
  local includeVariant = through == "variant" or through == "character"
  local includeCharacter = through == "character"

  local eff = { layout = {}, keybinds = {} }
  self:SparseMerge(eff, shipped.base or {})
  local shippedClass = (shipped.classes or {})[classFile] or {}
  if includeClass then
    self:SparseMerge(eff, layerFields(shippedClass))
  end
  local shippedVariant = includeVariant and variantName and shippedClass.variants and shippedClass.variants[variantName]
  if shippedVariant then
    self:SparseMerge(eff, layerFields(shippedVariant))
  end
  self:SparseMerge(eff, account.base or {})
  local classAcc = account.classes[classFile]
  if classAcc then
    if includeClass then
      self:SparseMerge(eff, layerFields(classAcc))
    end
    local variant = includeVariant and variantName and classAcc.variants and classAcc.variants[variantName]
    if variant then
      self:SparseMerge(eff, layerFields(variant))
    end
  end
  if includeCharacter then
    self:SparseMerge(eff, layerFields(char))
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

function Addon:WriteLayerDelta(layer, section, key, patch)
  local classFile = self:GetPlayerClass()
  local db = self:GetDB()
  local char = self:GetCharDB()
  layer = layer or char.editLayer or "variant"

  local store
  if layer == "character" then
    char[section] = char[section] or {}
    store = char[section]
  elseif layer == "base" then
    db.base[section] = db.base[section] or {}
    store = db.base[section]
  else
    db.classes[classFile] = db.classes[classFile] or { layout = {}, keybinds = {}, variants = {} }
    local classAcc = db.classes[classFile]
    if layer == "class" then
      classAcc[section] = classAcc[section] or {}
      store = classAcc[section]
    else
      local name = self:GetActiveVariantName(classFile) or "Default"
      classAcc.variants = classAcc.variants or {}
      classAcc.variants[name] = classAcc.variants[name] or { layout = {}, keybinds = {} }
      local variant = classAcc.variants[name]
      variant[section] = variant[section] or {}
      store = variant[section]
    end
  end

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
