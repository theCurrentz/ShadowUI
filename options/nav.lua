--[[
  Purpose: Tree outline and Search filter for the AceConfig options panel.
  Deps: AceConfigRegistry-3.0 (optional NotifyChange)
  Public: ShadowUI:GetOptionsSearch(), ShadowUI:SetOptionsSearch(),
          ShadowUI:KeepOptionsSearch(), ShadowUI:MarkOptionsSearch(),
          ShadowUI:InstallOptionsSearchHide()
]]
local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

-- AceConfigRegistry rejects unknown option keys. Keep Search state off the table.
local searchShow = {}
local searchKeep = {}
local hideInstalled = {}

local function cleanQuery(value)
  if type(value) ~= "string" then
    return ""
  end
  return (value:match("^%s*(.-)%s*$") or ""):lower()
end

local function optionText(node)
  if type(node) ~= "table" then
    return ""
  end
  local name = node.name
  if type(name) == "function" then
    name = name()
  end
  local desc = node.desc
  if type(desc) == "function" then
    desc = desc()
  end
  return (tostring(name or "") .. " " .. tostring(desc or "")):lower()
end

function Addon:KeepOptionsSearch(node)
  if type(node) == "table" then
    searchKeep[node] = true
  end
end

function Addon:GetOptionsSearch()
  return self._optionsSearch or ""
end

function Addon:SetOptionsSearch(query)
  self._optionsSearch = cleanQuery(query)
  if self._optionsTable then
    self:MarkOptionsSearch(self._optionsTable)
  end
  local AceConfigRegistry = LibStub("AceConfigRegistry-3.0", true)
  if AceConfigRegistry and AceConfigRegistry.NotifyChange then
    AceConfigRegistry:NotifyChange("ShadowUI")
  end
end

function Addon:MarkOptionsSearch(node, query, ancestorMatch)
  if type(node) ~= "table" then
    return false
  end
  query = query or self:GetOptionsSearch()
  local keep = searchKeep[node] == true
  local selfMatch = query == "" or keep or optionText(node):find(query, 1, true) ~= nil
  local inherited = query == "" or ancestorMatch or keep
  local anyChild = false
  if node.args then
    for _, child in pairs(node.args) do
      if self:MarkOptionsSearch(child, query, inherited or selfMatch) then
        anyChild = true
      end
    end
  end
  local show = inherited or selfMatch or anyChild
  searchShow[node] = show
  return show
end

function Addon:InstallOptionsSearchHide(node)
  if type(node) ~= "table" or hideInstalled[node] then
    return
  end
  hideInstalled[node] = true
  if not searchKeep[node] then
    local orig = node.hidden
    node.hidden = function(...)
      if searchShow[node] == false then
        return true
      end
      if orig then
        return orig(...)
      end
    end
  end
  if node.args then
    for _, child in pairs(node.args) do
      self:InstallOptionsSearchHide(child)
    end
  end
end
