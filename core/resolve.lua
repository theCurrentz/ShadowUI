--[[
  Purpose: Merge shipped defaults with account Base → Class → Variant into effective config.
  Deps: ShadowUI db helpers, ShadowUI.Defaults
  Public: DeepCopy, SparseMerge, ResolveEffective, GetActiveVariantName, WriteLayerDelta,
          TalentPointsFromTabInfo, GetPrimaryTalentTree
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

function Addon:GetActiveVariantName(classFile)
  classFile = classFile or self:GetPlayerClass()
  local char = self:GetCharDB()
  if char.variantManual and char.activeVariant then
    return char.activeVariant
  end
  local classData = self:GetDB().classes[classFile]
  if not classData or not classData.variants then
    return char.activeVariant
  end
  local tree = self:GetPrimaryTalentTree()
  if tree then
    for name, variant in pairs(classData.variants) do
      if variant.talentTree == tree then
        return name
      end
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

function Addon:ResolveEffective(classFile, variantName)
  classFile = classFile or self:GetPlayerClass()
  variantName = variantName or self:GetActiveVariantName(classFile)

  local shipped = self.Defaults or { base = { layout = {}, keybinds = {} }, classes = {} }
  local account = self:GetDB()

  local eff = { layout = {}, keybinds = {} }
  self:SparseMerge(eff, shipped.base or {})
  self:SparseMerge(eff, (shipped.classes[classFile] or {}))
  self:SparseMerge(eff, account.base or {})
  local classAcc = account.classes[classFile]
  if classAcc then
    self:SparseMerge(eff, { layout = classAcc.layout or {}, keybinds = classAcc.keybinds or {} })
    local variant = variantName and classAcc.variants and classAcc.variants[variantName]
    if variant then
      self:SparseMerge(eff, { layout = variant.layout or {}, keybinds = variant.keybinds or {} })
    end
  end
  return eff
end

function Addon:WriteLayerDelta(layer, section, key, patch)
  local classFile = self:GetPlayerClass()
  local db = self:GetDB()
  layer = layer or self:GetCharDB().editLayer or "variant"

  local store
  if layer == "base" then
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
