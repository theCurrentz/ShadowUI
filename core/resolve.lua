--[[
  Purpose: Merge shipped defaults with account Base → Class → Variant into effective config.
  Deps: ShadowUI db helpers, ShadowUI.Defaults
  Public: DeepCopy, SparseMerge, ResolveEffective, GetActiveVariantName, WriteLayerDelta
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

function Addon:GetPrimaryTalentTree()
  local best, bestPts = nil, -1
  for i = 1, GetNumTalentTabs() do
    local _, _, _, _, points = GetTalentTabInfo(i)
    if points and points > bestPts then
      best, bestPts = i, points
    end
  end
  if bestPts <= 0 then return nil end
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

  if layer == "base" then
    db.base[section] = db.base[section] or {}
    db.base[section][key] = db.base[section][key] or {}
    self:SparseMerge(db.base[section][key], patch)
    return
  end

  db.classes[classFile] = db.classes[classFile] or { layout = {}, keybinds = {}, variants = {} }
  local classAcc = db.classes[classFile]

  if layer == "class" then
    classAcc[section] = classAcc[section] or {}
    classAcc[section][key] = classAcc[section][key] or {}
    self:SparseMerge(classAcc[section][key], patch)
    return
  end

  local name = self:GetActiveVariantName(classFile) or "Default"
  classAcc.variants = classAcc.variants or {}
  classAcc.variants[name] = classAcc.variants[name] or { layout = {}, keybinds = {} }
  local variant = classAcc.variants[name]
  variant[section] = variant[section] or {}
  variant[section][key] = variant[section][key] or {}
  self:SparseMerge(variant[section][key], patch)
end
