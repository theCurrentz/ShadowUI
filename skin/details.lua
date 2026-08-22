--[[
  Purpose: Park Details! damage and threat charts when that addon is loaded.
  Deps: ShadowUI:ParkFrame(); optional Details!
  Public: ShadowUI:SkinDetails()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local DAMAGE = { point = "RIGHT", x = 0, y = -194, width = 153, height = 164 }
local THREAT = { point = "BOTTOMRIGHT", x = 0, y = 150, width = 153, height = 106 }

local function isThreat(inst)
  return inst.last_raid_plugin == "DETAILS_PLUGIN_TINY_THREAT" or inst.modo == 4
end

local function park(inst, spec)
  if not inst then
    return
  end
  local frame = inst.baseframe or inst
  Addon:ParkFrame(frame, spec.point, spec.x, spec.y, spec.width, spec.height)
  if inst.LockInstance then
    pcall(inst.LockInstance, inst, true)
  elseif inst.isLocked ~= nil then
    inst.isLocked = true
  end
end

function Addon:SkinDetails()
  local details = _G.Details
  local parkedDamage, parkedThreat
  if details and details.GetInstance then
    if hooksecurefunc and not self._detailsHook and details.RestoreMainWindowPosition then
      self._detailsHook = true
      hooksecurefunc(details, "RestoreMainWindowPosition", function()
        Addon:SkinDetails()
      end)
    end
    for i = 1, 5 do
      local inst = details:GetInstance(i)
      if inst then
        if not parkedThreat and isThreat(inst) then
          park(inst, THREAT)
          parkedThreat = true
        elseif not parkedDamage and not isThreat(inst) then
          park(inst, DAMAGE)
          parkedDamage = true
        end
      end
    end
  end
  if not parkedDamage then
    park(_G.DetailsBaseFrame1, DAMAGE)
  end
  if not parkedThreat then
    park(_G.DetailsBaseFrame3, THREAT)
  end
  if C_Timer and C_Timer.After and not self._detailsRetry then
    self._detailsRetry = true
    C_Timer.After(1, function()
      Addon:SkinDetails()
    end)
  end
end
