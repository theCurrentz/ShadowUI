--[[
  Purpose: HUD drag hosts for Player Frame, Target Frame, Cast Bar, and Range Display.
  Deps: ShadowUI:SnapFrameToGrid(), ShadowUI:PersistHostPosition(),
        ShadowUI:SnapFrameSize(), ShadowUI:SelectEditOverlay()
  Public: ShadowUI:RefreshUnitDragOverlays()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local HUD_BLUE = { 0.0, 0.447, 0.875 }
local HUD_FILL = 0.33
local HOSTS = {
  { id = "player", global = "PlayerFrame", overlay = "ShadowUIPlayerDrag", label = "Player" },
  { id = "target", global = "TargetFrame", overlay = "ShadowUITargetDrag", label = "Target" },
  { id = "cast", overlay = "ShadowUICastDrag", label = "Cast", resizable = true,
    resolve = function() return Addon.castGroup end,
    visual = function() return Addon.castBar or Addon.castGroup end },
  { id = "range", overlay = "ShadowUIRangeDrag", label = "Range",
    resolve = function() return Addon.rangeDisplay end },
}

local function paint(overlay)
  if overlay.fill then
    overlay.fill:SetColorTexture(HUD_BLUE[1], HUD_BLUE[2], HUD_BLUE[3], HUD_FILL)
  end
  if overlay.SetBackdropBorderColor then
    overlay:SetBackdropBorderColor(0.45, 0.81, 1, 0.95)
  end
end

local function createOverlay(host, spec)
  if not CreateFrame then
    return nil
  end
  local visual = spec.visual and spec.visual() or host
  local ok, overlay = pcall(CreateFrame, "Button", spec.overlay, UIParent, "BackdropTemplate")
  if not ok or not overlay then
    overlay = CreateFrame("Button", spec.overlay, UIParent)
  end
  overlay:SetFrameStrata("DIALOG")
  overlay:SetFrameLevel(200)
  overlay:SetAllPoints(visual or host)
  overlay:EnableMouse(false)
  overlay:RegisterForDrag("LeftButton")
  if overlay.SetBackdrop then
    overlay:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      edgeFile = "Interface\\Buttons\\WHITE8X8",
      edgeSize = 1,
    })
    overlay:SetBackdropColor(0, 0, 0, 0)
    overlay:SetBackdropBorderColor(0.45, 0.81, 1, 0.95)
  end
  local fill = overlay:CreateTexture(nil, "ARTWORK")
  fill:SetAllPoints(overlay)
  fill:SetColorTexture(HUD_BLUE[1], HUD_BLUE[2], HUD_BLUE[3], HUD_FILL)
  overlay.fill = fill
  local label = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("CENTER")
  label:SetTextColor(1, 1, 1, 1)
  label:SetText(spec.label)
  overlay.fontString = label
  overlay.host = host
  overlay.hostId = spec.id
  local moving = false
  local sizing = false
  local function beginMove()
    if not Addon.editMode or moving or sizing then
      return
    end
    moving = true
    host._shadowUIDragging = true
    if host.SetMovable then
      host:SetMovable(true)
    end
    if Addon.SelectEditOverlay then
      Addon:SelectEditOverlay(overlay)
    end
    host:StartMoving()
  end
  local function endMove()
    if not moving then
      return
    end
    moving = false
    host:StopMovingOrSizing()
    if Addon.PersistHostPosition then
      Addon:PersistHostPosition(host, spec.id)
    end
    host._shadowUIDragging = false
  end
  overlay:SetScript("OnMouseDown", function(_, button)
    if button == "LeftButton" then
      beginMove()
    end
  end)
  overlay:SetScript("OnMouseUp", endMove)
  overlay:SetScript("OnDragStart", beginMove)
  overlay:SetScript("OnDragStop", endMove)
  if spec.resizable then
    local grip = CreateFrame("Button", spec.overlay .. "Size", overlay)
    grip:SetSize(12, 12)
    grip:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)
    grip:SetFrameLevel((overlay.GetFrameLevel and overlay:GetFrameLevel() or 200) + 1)
    grip:EnableMouse(true)
    grip:RegisterForDrag("LeftButton")
    local gripFill = grip:CreateTexture(nil, "ARTWORK")
    gripFill:SetAllPoints(grip)
    gripFill:SetColorTexture(1, 1, 1, 0.85)
    overlay.resizeGrip = grip
    local function beginSize()
      if not Addon.editMode or moving or sizing then
        return
      end
      sizing = true
      host._shadowUIDragging = true
      if host.SetResizable then
        host:SetResizable(true)
      end
      if Addon.SelectEditOverlay then
        Addon:SelectEditOverlay(overlay)
      end
      if host.StartSizing then
        host:StartSizing("BOTTOMRIGHT")
      end
    end
    local function endSize()
      if not sizing then
        return
      end
      sizing = false
      host:StopMovingOrSizing()
      if Addon.PersistHostPosition then
        Addon:PersistHostPosition(host, spec.id, true)
      end
      host._shadowUIDragging = false
    end
    grip:SetScript("OnMouseDown", function(_, button)
      if button == "LeftButton" then
        beginSize()
      end
    end)
    grip:SetScript("OnMouseUp", endSize)
    grip:SetScript("OnDragStart", beginSize)
    grip:SetScript("OnDragStop", endSize)
  end
  overlay:Hide()
  paint(overlay)
  return overlay
end

local function hostFrame(spec)
  if spec.resolve then
    return spec.resolve()
  end
  if spec.global then
    return _G[spec.global]
  end
end

function Addon:RefreshUnitDragOverlays()
  self.unitHosts = self.unitHosts or {}
  local editable = self.editMode == true
  for _, spec in ipairs(HOSTS) do
    local frame = hostFrame(spec)
    if frame then
      local host = self.unitHosts[spec.id]
      if not host then
        host = { id = spec.id, overlay = createOverlay(frame, spec) }
        self.unitHosts[spec.id] = host
      end
      host.frame = frame
      local overlay = host.overlay
      if overlay then
        overlay.host = frame
        local visual = spec.visual and spec.visual() or frame
        overlay:SetAllPoints(visual or frame)
        overlay:EnableMouse(editable)
        overlay:SetShown(editable)
        if overlay.resizeGrip then
          overlay.resizeGrip:EnableMouse(editable)
          overlay.resizeGrip:SetShown(editable)
        end
      end
      if frame.SetMovable then
        frame:SetMovable(editable)
      end
      if spec.resizable and frame.SetResizable then
        frame:SetResizable(editable)
        if editable then
          if frame.SetResizeBounds then
            frame:SetResizeBounds(36 * 0.9 * 4, 12, 36 * 0.9 * 16, 72)
          elseif frame.SetMinResize then
            frame:SetMinResize(36 * 0.9 * 4, 12)
            if frame.SetMaxResize then
              frame:SetMaxResize(36 * 0.9 * 16, 72)
            end
          end
        end
      end
    end
  end
end
