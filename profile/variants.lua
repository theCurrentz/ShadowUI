--[[
  Purpose: Named class variants, manual switch, and talent-tree auto-bind.
  Deps: ShadowUI db helpers, resolve
  Public: HandleVariantCommand, SetVariant, ClearVariantOverride, OnTalentUpdate,
          EnsureVariant, CreateVariant, RenameVariant, DeleteVariant
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local function classVariants(self, classFile)
  classFile = classFile or self:GetPlayerClass()
  local db = self:GetDB()
  db.classes[classFile] = db.classes[classFile] or { layout = {}, keybinds = {}, variants = {} }
  local classAcc = db.classes[classFile]
  classAcc.variants = classAcc.variants or {}
  return classAcc
end

function Addon:EnsureVariant(name, classFile)
  local classAcc = classVariants(self, classFile)
  classAcc.variants[name] = classAcc.variants[name] or { layout = {}, keybinds = {} }
  return classAcc.variants[name]
end

function Addon:CreateVariant(name, classFile)
  return self:EnsureVariant(name, classFile)
end

function Addon:RenameVariant(oldName, newName, classFile)
  local classAcc = classVariants(self, classFile)
  local variant = classAcc.variants[oldName]
  if not variant or oldName == newName or classAcc.variants[newName] then
    return false
  end
  classAcc.variants[newName] = variant
  classAcc.variants[oldName] = nil
  local char = self:GetCharDB()
  if char.activeVariant == oldName then
    char.activeVariant = newName
  end
  return true
end

function Addon:DeleteVariant(name, classFile)
  local classAcc = classVariants(self, classFile)
  if not classAcc.variants[name] then
    return false
  end
  classAcc.variants[name] = nil
  local char = self:GetCharDB()
  if char.activeVariant == name then
    char.activeVariant = nil
  end
  return true
end

function Addon:HandleVariantCommand(rest)
  rest = (rest or ""):match("^%s*(.-)%s*$") or ""
  if rest == "" then
    self:Print("Active variant: " .. tostring(self:GetActiveVariantName()))
    return
  end
  if rest:lower() == "clear" then
    self:ClearVariantOverride()
    return
  end
  self:SetVariant(rest, true)
end

function Addon:SetVariant(name, manual)
  self:EnsureVariant(name)
  local char = self:GetCharDB()
  char.activeVariant = name
  char.variantManual = not not manual
  self:ApplyAll()
end

function Addon:ClearVariantOverride()
  local char = self:GetCharDB()
  char.variantManual = false
  self:ApplyAll()
end

function Addon:OnTalentUpdate()
  if self:GetCharDB().variantManual then return end
  self:ApplyAll()
end
