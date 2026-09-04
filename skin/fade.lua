--[[
  Purpose: One OnUpdate FadeDriver for Chat, Bars, the Micro Cluster, Details
           Windows, and the Experience bar. Enter is 0.6s bezier, leave is
           0.4s bezier, optional delay before leave. The driver is off when
           every host is at rest. Fade the host frame, not LAB buttons: empty
           Action Slots already use button alpha.
  Deps: ShadowUI:Ease()
  Public: ShadowUI:RegisterFadeHost(), ShadowUI:UnregisterFadeHost(),
          ShadowUI:SetFadeMouseOver(), ShadowUI:TickFade(), ShadowUI:WakeFadeDriver(),
          ShadowUI:FadeDriverRunning(), ShadowUI:ApplyBarFades(),
          ShadowUI:ApplyMicroFade(), ShadowUI:ApplyXPFade()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local ENTER_DUR = 0.6
local LEAVE_DUR = 0.4

local hosts = {}
local driver = CreateFrame("Frame")
if driver.RegisterEvent then
  pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_DISABLED")
  pcall(driver.RegisterEvent, driver, "PLAYER_REGEN_ENABLED")
end
if driver.SetScript then
  driver:SetScript("OnEvent", function()
    Addon:WakeFadeDriver()
  end)
end

local function applyAlpha(host, alpha)
  host.alpha = alpha
  if host.setAlpha then
    host.setAlpha(alpha)
  elseif host.frame.SetAlpha then
    host.frame:SetAlpha(alpha)
  end
end

local function forcedActive()
  if InCombatLockdown and InCombatLockdown() then
    return true
  end
  if Addon.editMode or Addon.keybindMode then
    return true
  end
  if Addon.ShouldShowEmptyActionSlots and Addon:ShouldShowEmptyActionSlots() then
    return true
  end
  return false
end

local function wantedActive(host)
  if host.mouseOver then
    return true
  end
  if host.useForced ~= false and forcedActive() then
    return true
  end
  return false
end

local function atRest(host)
  if host.delayLeft and host.delayLeft > 0 then
    return false
  end
  if host.anim then
    return false
  end
  return true
end

local function allRest()
  for _, host in pairs(hosts) do
    if not atRest(host) then
      return false
    end
  end
  return true
end

local function stopDriver()
  driver:SetScript("OnUpdate", nil)
end

local function startDriver()
  if driver:GetScript("OnUpdate") then
    return
  end
  driver:SetScript("OnUpdate", function(_, elapsed)
    Addon:TickFade(elapsed)
  end)
end

function Addon:FadeDriverRunning()
  return driver:GetScript("OnUpdate") ~= nil
end

function Addon:WakeFadeDriver()
  if next(hosts) then
    startDriver()
  end
end

local function beginEnter(host)
  host.delayLeft = nil
  local from = host.alpha
  local to = host.activeAlpha
  if math.abs(from - to) < 1e-4 then
    host.anim = nil
    applyAlpha(host, to)
    return
  end
  host.anim = {
    from = from,
    to = to,
    t = 0,
    dur = host.enterDur,
  }
  startDriver()
end

local function beginLeave(host)
  local from = host.alpha
  local to = host.idleAlpha
  if math.abs(from - to) < 1e-4 then
    host.anim = nil
    host.delayLeft = nil
    applyAlpha(host, to)
    return
  end
  host.anim = {
    from = from,
    to = to,
    t = 0,
    dur = host.leaveDur,
  }
  startDriver()
end

function Addon:RegisterFadeHost(spec)
  if not spec or not spec.frame then
    return
  end
  local frame = spec.frame
  local host = hosts[frame] or {}
  host.frame = frame
  host.idleAlpha = spec.idleAlpha
  if host.idleAlpha == nil then
    host.idleAlpha = 1
  end
  host.activeAlpha = spec.activeAlpha
  if host.activeAlpha == nil then
    host.activeAlpha = 1
  end
  host.delay = spec.delay or 0
  host.enterDur = spec.enterDur or ENTER_DUR
  host.leaveDur = spec.leaveDur or LEAVE_DUR
  host.setAlpha = spec.setAlpha
  if spec.useForced == nil then
    host.useForced = true
  else
    host.useForced = spec.useForced and true or false
  end
  host.mouseOver = host.mouseOver or false
  local first = hosts[frame] == nil
  hosts[frame] = host
  if first or host.alpha == nil then
    local alpha = wantedActive(host) and host.activeAlpha or host.idleAlpha
    applyAlpha(host, alpha)
  else
    startDriver()
  end
end

function Addon:UnregisterFadeHost(frame)
  if frame then
    hosts[frame] = nil
  end
  if allRest() then
    stopDriver()
  end
end

function Addon:SetFadeMouseOver(frame, over)
  local host = hosts[frame]
  if not host then
    return
  end
  local nextOver = over and true or false
  if host.mouseOver == nextOver then
    return
  end
  host.mouseOver = nextOver
  startDriver()
end

function Addon:TickFade(elapsed)
  elapsed = elapsed or 0
  for _, host in pairs(hosts) do
    local wanted = wantedActive(host)
    if wanted then
      host.delayLeft = nil
      if host.anim and host.anim.to == host.activeAlpha then
        -- keep entering
      elseif math.abs(host.alpha - host.activeAlpha) > 1e-4 then
        beginEnter(host)
      else
        host.anim = nil
      end
    else
      if host.anim and host.anim.to == host.idleAlpha then
        -- keep leaving
      elseif math.abs(host.alpha - host.idleAlpha) > 1e-4 then
        if host.delay > 0 and not host.anim then
          if not host.delayLeft then
            host.delayLeft = host.delay
          end
        else
          beginLeave(host)
        end
      else
        host.anim = nil
        host.delayLeft = nil
      end
    end

    if host.delayLeft and not wanted then
      host.delayLeft = host.delayLeft - elapsed
      if host.delayLeft <= 0 then
        host.delayLeft = nil
        beginLeave(host)
      end
    end

    local anim = host.anim
    if anim then
      anim.t = anim.t + elapsed
      local p = anim.t / anim.dur
      if p >= 1 then
        applyAlpha(host, anim.to)
        host.anim = nil
      else
        local from, to = anim.from, anim.to
        applyAlpha(host, from + (to - from) * Addon:Ease(p))
      end
    end
  end
  if allRest() then
    stopDriver()
  end
end

function Addon:ApplyBarFades(cfg)
  local layout = cfg and cfg.layout or {}
  for barId, bar in pairs(self.bars or {}) do
    local shown = not bar.IsShown or bar:IsShown()
    if shown then
      local barCfg = layout[barId] or {}
      local idle = barCfg.fadeIdle
      if Addon.ResolveBarVisual then
        idle = Addon:ResolveBarVisual(layout, barId, barCfg).fadeIdle
      elseif idle == nil then
        idle = 1
      end
      self:RegisterFadeHost({
        frame = bar,
        idleAlpha = idle,
        activeAlpha = 1,
      })
      for _, button in ipairs(bar.buttons or {}) do
        if not button._shadowUIFadeMouse then
          button._shadowUIFadeMouse = true
          local host = bar
          local function enter()
            Addon:SetFadeMouseOver(host, true)
          end
          local function leave()
            Addon:SetFadeMouseOver(host, false)
          end
          if button.HookScript then
            button:HookScript("OnEnter", enter)
            button:HookScript("OnLeave", leave)
          end
        end
      end
    else
      self:UnregisterFadeHost(bar)
    end
  end
  self:WakeFadeDriver()
end

function Addon:ApplyMicroFade()
  local cluster = _G.ShadowUIMicroCluster
  local char = self.GetCharDB and self:GetCharDB()
  local useMenu = not char or char.useShadowUIMenu ~= false
  if not cluster or not useMenu or (cluster.IsShown and not cluster:IsShown()) then
    if cluster then
      self:UnregisterFadeHost(cluster)
    end
    return
  end
  local idle = char and char.microFadeIdle
  if idle == nil then
    idle = 1
  end
  self:RegisterFadeHost({
    frame = cluster,
    idleAlpha = idle,
    activeAlpha = 1,
  })
  local names = {
    "MainMenuBarBackpackButton",
    "CharacterMicroButton",
    "SpellbookMicroButton",
    "TalentMicroButton",
    "QuestLogMicroButton",
    "SocialsMicroButton",
    "GuildMicroButton",
    "LFDMicroButton",
    "WorldMapMicroButton",
    "CollectionsMicroButton",
    "EJMicroButton",
    "MainMenuMicroButton",
    "HelpMicroButton",
  }
  for _, name in ipairs(names) do
    local button = _G[name]
    if button and not button._shadowUIFadeMouse then
      button._shadowUIFadeMouse = true
      local function enter()
        Addon:SetFadeMouseOver(cluster, true)
      end
      local function leave()
        Addon:SetFadeMouseOver(cluster, false)
      end
      if button.HookScript then
        button:HookScript("OnEnter", enter)
        button:HookScript("OnLeave", leave)
      end
    end
  end
  self:WakeFadeDriver()
end

local function hookXPFadeMouse(frame, host)
  if not frame or frame._shadowUIFadeMouse then
    return
  end
  frame._shadowUIFadeMouse = true
  local function enter()
    Addon:SetFadeMouseOver(host, true)
  end
  local function leave()
    Addon:SetFadeMouseOver(host, false)
  end
  if frame.HookScript then
    frame:HookScript("OnEnter", enter)
    frame:HookScript("OnLeave", leave)
  end
end

function Addon:ApplyXPFade()
  local host = _G.ShadowUIXPHost
  if not host then
    local anchor = _G.MainStatusTrackingBarContainer or _G.MainMenuExpBar
    host = anchor and anchor.shadowUIXPHost
  end
  if not host or (host.IsShown and not host:IsShown()) then
    if host then
      self:UnregisterFadeHost(host)
    end
    return
  end
  local char = self.GetCharDB and self:GetCharDB()
  local idle = char and char.xpFadeIdle
  if idle == nil then
    idle = 1
  end
  self:RegisterFadeHost({
    frame = host,
    idleAlpha = idle,
    activeAlpha = 1,
  })
  hookXPFadeMouse(host, host)
  hookXPFadeMouse(_G.MainStatusTrackingBarContainer, host)
  hookXPFadeMouse(_G.MainMenuExpBar, host)
  local shown = _G.MainStatusTrackingBarContainer
  shown = shown and shown.GetShownBar and shown:GetShownBar()
  if shown then
    hookXPFadeMouse(shown, host)
    hookXPFadeMouse(shown.StatusBar, host)
  end
  self:WakeFadeDriver()
end
