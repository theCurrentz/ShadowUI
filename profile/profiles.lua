--[[
  Purpose: Named Account Profiles, Default Profile, and Character selection.
  Deps: ShadowUI db helpers, resolve
  Public: HandleProfileCommand, SetActiveProfile, SetDefaultProfile, CreateProfile,
          RenameProfile, DeleteProfile, ProfileValues
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local function clean(name)
  return type(name) == "string" and name:match("^%s*(.-)%s*$") or ""
end

function Addon:ProfileValues()
  self:EnsureProfiles()
  local values = {}
  for name in pairs(self:GetDB().profiles) do
    values[name] = name
  end
  return values
end

function Addon:CreateProfile(name, copyFrom)
  name = clean(name)
  if name == "" then
    return false
  end
  self:EnsureProfiles()
  local db = self:GetDB()
  if db.profiles[name] then
    return false
  end
  copyFrom = clean(copyFrom)
  if copyFrom == "" then
    copyFrom = self:GetActiveProfileName()
  end
  local source = db.profiles[copyFrom]
  if source and self.DeepCopy then
    db.profiles[name] = self:DeepCopy(source)
  else
    db.profiles[name] = { layout = {}, keybinds = {}, actions = {} }
  end
  return true
end

function Addon:RenameProfile(oldName, newName)
  oldName = clean(oldName)
  newName = clean(newName)
  self:EnsureProfiles()
  local db = self:GetDB()
  local profile = db.profiles[oldName]
  if not profile or newName == "" or oldName == newName or db.profiles[newName] then
    return false
  end
  db.profiles[newName] = profile
  db.profiles[oldName] = nil
  if db.defaultProfile == oldName then
    db.defaultProfile = newName
  end
  local char = self:GetCharDB()
  if char.activeProfile == oldName then
    char.activeProfile = newName
  end
  return true
end

function Addon:DeleteProfile(name)
  name = clean(name)
  self:EnsureProfiles()
  local db = self:GetDB()
  if not db.profiles[name] then
    return false
  end
  local count = 0
  for _ in pairs(db.profiles) do
    count = count + 1
  end
  if count <= 1 then
    return false
  end
  db.profiles[name] = nil
  if db.defaultProfile == name then
    db.defaultProfile = next(db.profiles)
  end
  local char = self:GetCharDB()
  if char.activeProfile == name then
    char.activeProfile = nil
  end
  return true
end

function Addon:SetActiveProfile(name)
  name = clean(name)
  if name == "" then
    return false
  end
  self:EnsureProfiles()
  local db = self:GetDB()
  if not db.profiles[name] then
    if not self:CreateProfile(name) then
      return false
    end
  end
  self:GetCharDB().activeProfile = name
  if self.ApplyAll then
    self:ApplyAll()
  end
  return true
end

function Addon:SetDefaultProfile(name)
  name = clean(name)
  if name == "" then
    name = self:GetActiveProfileName()
  end
  self:EnsureProfiles()
  local db = self:GetDB()
  if not db.profiles[name] then
    return false
  end
  db.defaultProfile = name
  return true
end

function Addon:HandleProfileCommand(rest)
  rest = clean(rest)
  if rest == "" then
    local active = self:GetActiveProfileName()
    local defaultName = self:GetDB().defaultProfile
    local mark = active == defaultName and " (Default Profile)" or ""
    self:Print("Active Profile: " .. tostring(active) .. mark)
    return
  end
  local cmd, name = rest:match("^(%S+)%s*(.*)$")
  cmd = cmd and cmd:lower() or ""
  name = clean(name)
  if cmd == "default" then
    if self:SetDefaultProfile(name) then
      self:Print("Default Profile: " .. self:GetDB().defaultProfile)
    end
    return
  end
  self:SetActiveProfile(rest)
end

function Addon:OnTalentUpdate()
end
