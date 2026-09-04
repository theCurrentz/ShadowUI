--[[
  Purpose: Park Details! damage and threat charts when that addon is loaded.
           Apply the Chat zen fade to those windows, including DetailsRowFrame
           (meter bars parent to UIParent, not to DetailsBaseFrame).
  Deps: ShadowUI:ParkFrame(); ShadowUI:RegisterFadeHost(); optional Details!
  Public: ShadowUI:SkinDetails()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local DAMAGE = { point = "RIGHT", x = 0, y = -194, width = 153, height = 164 }
local THREAT = { point = "BOTTOMRIGHT", x = 0, y = 150, width = 153, height = 106 }
local IDLE = 0.35
local ACTIVE = 0.85
local LINGER = 20
local ENTER = 0.6
local LEAVE = 2.5

local applying = {}
local probes = {}

local function isThreat(inst)
  return inst.last_raid_plugin == "DETAILS_PLUGIN_TINY_THREAT" or inst.modo == 4
end

local function windowId(frame, inst)
  if inst and inst.meu_id then
    return inst.meu_id
  end
  local name = frame and frame.GetName and frame:GetName()
  if type(name) == "string" then
    return name:match("DetailsBaseFrame(%d+)$") or name:match("DetailsRowFrame(%d+)$")
  end
end

-- Details parents meter bars to DetailsRowFrame on UIParent, and the switch
-- button is also a UIParent sibling. SetAlpha on baseframe does not fade them.
local function fadeFrames(inst, frame)
  local frames = {}
  local seen = {}
  local function add(f)
    if f and not seen[f] then
      seen[f] = true
      frames[#frames + 1] = f
    end
  end
  add(frame)
  if inst and inst ~= frame then
    add(inst.baseframe)
    add(inst.rowframe)
    add(inst.windowSwitchButton)
  end
  local id = windowId(frame, inst)
  if id then
    add(_G["DetailsBaseFrame" .. id])
    add(_G["DetailsRowFrame" .. id])
    add(_G["Details_SwitchButtonFrame" .. id])
  end
  return frames
end

local function hostFrame(inst, frame)
  if inst and inst.baseframe then
    return inst.baseframe
  end
  return frame
end

local function hookMouse(frame, host)
  if not frame or not host or frame._shadowUIFadeHook or not frame.HookScript then
    return
  end
  frame._shadowUIFadeHook = true
  frame:HookScript("OnEnter", function()
    Addon:SetFadeMouseOver(host, true)
  end)
  frame:HookScript("OnLeave", function()
    Addon:SetFadeMouseOver(host, false)
  end)
  frame:HookScript("OnMouseDown", function()
    Addon:SetFadeMouseOver(host, true)
  end)
end

local function hookKeepAlpha(frame)
  if not frame or frame._shadowUIFadeKeep or not hooksecurefunc then
    return
  end
  frame._shadowUIFadeKeep = true
  hooksecurefunc(frame, "SetAlpha", function(self)
    if applying[self] then
      return
    end
    local keep = self._shadowUIFadeAlpha
    if keep == nil or not self.SetAlpha then
      return
    end
    applying[self] = true
    self:SetAlpha(keep)
    applying[self] = nil
  end)
end

local function applyFade(inst, frame)
  local host = hostFrame(inst, frame)
  if not host or not Addon.RegisterFadeHost then
    return
  end
  local frames = fadeFrames(inst, host)
  if host.EnableMouse then
    host:EnableMouse(true)
  end
  for _, f in ipairs(frames) do
    hookMouse(f, host)
    hookKeepAlpha(f)
  end
  Addon:RegisterFadeHost({
    frame = host,
    idleAlpha = IDLE,
    activeAlpha = ACTIVE,
    delay = LINGER,
    enterDur = ENTER,
    leaveDur = LEAVE,
    useForced = false,
    setAlpha = function(alpha)
      for _, f in ipairs(frames) do
        f._shadowUIFadeAlpha = alpha
        if f.SetAlpha then
          applying[f] = true
          f:SetAlpha(alpha)
          applying[f] = nil
        end
      end
    end,
  })
  probes[host] = frames
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
  applyFade(inst, frame)
end

local function watchLateDetails()
  local details = _G.Details
  if details and hooksecurefunc then
    if not Addon._detailsPosHook and details.RestoreMainWindowPosition then
      Addon._detailsPosHook = true
      hooksecurefunc(details, "RestoreMainWindowPosition", function()
        Addon:SkinDetails()
      end)
    end
    if not Addon._detailsCreateHook and details.CreateInstance then
      Addon._detailsCreateHook = true
      hooksecurefunc(details, "CreateInstance", function()
        Addon:SkinDetails()
      end)
    end
    if not Addon._detailsMouseHook and details.OnEnterMainWindow then
      Addon._detailsMouseHook = true
      hooksecurefunc(details, "OnEnterMainWindow", function(instancia)
        local host = instancia and instancia.baseframe
        if host then
          Addon:SetFadeMouseOver(host, true)
        end
      end)
      if details.OnLeaveMainWindow then
        hooksecurefunc(details, "OnLeaveMainWindow", function(instancia)
          local host = instancia and instancia.baseframe
          if host then
            Addon:SetFadeMouseOver(host, false)
          end
        end)
      end
    end
  end
  if Addon._detailsWatch or not CreateFrame then
    return
  end
  Addon._detailsWatch = true
  local watch = CreateFrame("Frame", "ShadowUIDetailsWatch")
  if watch.RegisterEvent then
    watch:RegisterEvent("ADDON_LOADED")
    watch:RegisterEvent("PLAYER_ENTERING_WORLD")
  end
  if watch.SetScript then
    watch:SetScript("OnEvent", function(_, event, name)
      if event == "PLAYER_ENTERING_WORLD"
          or name == "Details"
          or name == "Details_TinyThreat" then
        Addon:SkinDetails()
      end
    end)
    -- Bar buttons sit on DetailsRowFrame (UIParent). They eat OnEnter on
    -- DetailsBaseFrame. Sample the window rect so hover still wakes fade.
    watch:SetScript("OnUpdate", function()
      for host, frames in pairs(probes) do
        local over = false
        for _, f in ipairs(frames) do
          if f.IsMouseOver and f:IsMouseOver() then
            over = true
            break
          end
        end
        Addon:SetFadeMouseOver(host, over)
      end
    end)
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(1, function()
      Addon:SkinDetails()
    end)
    C_Timer.After(3, function()
      Addon:SkinDetails()
    end)
  end
end

function Addon:SkinDetails()
  if self._skinDetailsBusy then
    return
  end
  self._skinDetailsBusy = true
  local details = _G.Details
  local parkedDamage, parkedThreat
  if details and details.GetInstance then
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
  watchLateDetails()
  self._skinDetailsBusy = false
end
