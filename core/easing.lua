--[[
  Purpose: Cubic-bezier ease for Chrome fade. Control points (0.16, 1, 0.3, 1).
  Deps: ShadowUI addon table
  Public: ShadowUI:Ease(x)
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local X1, Y1, X2, Y2 = 0.16, 1, 0.3, 1

local function sample(t, a, b)
  local mt = 1 - t
  return 3 * mt * mt * t * a + 3 * mt * t * t * b + t * t * t
end

local function sampleDx(t)
  local mt = 1 - t
  return 3 * mt * mt * X1 + 6 * mt * t * (X2 - X1) + 3 * t * t * (1 - X2)
end

local function solveT(x)
  local t = x
  for _ = 1, 12 do
    local dx = sampleDx(t)
    if math.abs(dx) < 1e-8 then
      break
    end
    t = t - (sample(t, X1, X2) - x) / dx
    if t < 0 then
      t = 0
    elseif t > 1 then
      t = 1
    end
  end
  return t
end

function Addon:Ease(x)
  if x <= 0 then
    return 0
  end
  if x >= 1 then
    return 1
  end
  return sample(solveT(x), Y1, Y2)
end
