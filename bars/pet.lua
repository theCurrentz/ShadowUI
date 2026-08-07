--[[
  Purpose: Bind and refresh the pet action bar across pet API return shapes.
  Deps: Classic Era pet action APIs
  Public: ShadowUI:BindPetButton(), ShadowUI:RefreshPetBar()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

-- Token actions (Attack, Follow, aggressive stance, ...) return a global name
-- rather than a texture path.
local function resolveTexture(texture, isToken)
  if isToken and type(texture) == "string" then
    return _G[texture] or texture
  end
  return texture
end

-- Older signatures place subtext second: (name, subtext, texture, isToken, isActive).
-- Modernized clients drop it: (name, texture, isToken, isActive).
local function petAction(index)
  local name, second, third, fourth, fifth = GetPetActionInfo(index)
  if type(third) == "string" or type(third) == "number" then
    return name, resolveTexture(third, fourth), fifth
  end
  return name, resolveTexture(second, third), fourth
end

function Addon:BindPetButton(button, index)
  button:SetState(0, "empty")
  button:SetAttribute("type", "pet")
  button:SetAttribute("action", index)
end

function Addon:RefreshPetBar(bar)
  for i, button in ipairs(bar.buttons) do
    local name, texture, active = petAction(i)
    button.icon:SetTexture(texture)
    button.icon:SetShown(texture ~= nil)
    button:SetChecked(active == true or active == 1)
    button:SetShown(name ~= nil)
  end
  bar:SetShown(UnitExists("pet"))
end
