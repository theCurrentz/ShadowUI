--[[
  Purpose: Apply Player Frame and Target Frame from resolved Layout.
           Creates ShadowUI hosts before any hide of Blizzard frames.
           Cutover is UnitFramesAreLive(): until then hosts stay hidden and
           Blizzard Player/Target stay the live HUD (ADR 0007).
  Deps: ShadowUI:CreateUnitFrame(), ShadowUI:UpdateUnitFrameLayout(),
        ShadowUI:UnitFrameLayoutForApply(), ShadowUI:RefreshUnitFrame()
  Public: ShadowUI:UnitFramesAreLive(), ShadowUI:HideBlizzardUnitFrames(),
          ShadowUI:ApplyUnitFrames()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local BLIZZARD_HOSTS = {
  player = "PlayerFrame",
  target = "TargetFrame",
}

function Addon:UnitFramesAreLive()
  return false
end

local function hideStay(frame)
  if not frame then
    return
  end
  if frame.Hide then
    frame:Hide()
  end
  if frame.UnregisterAllEvents then
    pcall(frame.UnregisterAllEvents, frame)
  end
  if frame.Show then
    frame.Show = function() end
  end
end

function Addon:HideBlizzardUnitFrames()
  if InCombatLockdown and InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  for _, name in pairs(BLIZZARD_HOSTS) do
    hideStay(_G[name])
  end
end

function Addon:ApplyUnitFrames(cfg)
  if InCombatLockdown and InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  cfg = cfg or (self.ResolveEffective and self:ResolveEffective()) or {}
  local layout = cfg.layout or {}
  self.unitFrames = self.unitFrames or {}
  local live = self:UnitFramesAreLive()
  local preview = self.unitFrameMode == true
  for _, id in ipairs(self.UNIT_FRAME_IDS or { "player", "target" }) do
    local frameLayout = layout[id]
    if self.UnitFrameLayoutForApply then
      frameLayout = self:UnitFrameLayoutForApply(layout, id)
    end
    local host = self.unitFrames[id]
    if not host then
      host = self:CreateUnitFrame(id)
      self.unitFrames[id] = host
    end
    if host then
      self:UpdateUnitFrameLayout(host, frameLayout)
      if self.RefreshUnitFrame then
        self:RefreshUnitFrame(host)
      end
      local show = (live or preview) and frameLayout.enabled ~= false
      if show then
        if host.Show then
          host:Show()
        end
      elseif host.Hide then
        host:Hide()
      end
    end
  end
  if live then
    self:HideBlizzardUnitFrames()
  end
end
