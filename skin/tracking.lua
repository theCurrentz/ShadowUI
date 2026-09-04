--[[
  Purpose: Dock Blizzard XP and reputation bars at the top of the screen.
           XP uses a left-right purple-to-magenta fill like the retail
           experience bar. The native fill stays hidden so the gradient
           does not paint twice. Classic overlay art stays hidden. Fade idle
           registers the XP cover with FadeDriver.
  Deps: MainStatusTrackingBarContainer, SecondaryStatusTrackingBarContainer,
        StatusTrackingBarManager; MainMenuExpBar fallback;
        ShadowUI:ApplyStatusBarGradient(), ShadowUI:ApplyXPFade(),
        ShadowUI:ApplyOuterChrome()
  Public: ShadowUI:SkinTrackingBars(), ShadowUI:DumpXPStack()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local FILL = "Interface\\Buttons\\WHITE8X8"
local HEIGHT = 18
local TEXT_SIZE = 12
local TICKS = 20
-- Retail experience fill: deep violet into a bright magenta sheen.
local XP_FROM = { 0.42, 0.08, 0.62, 1 }
local XP_TO = { 0.96, 0.48, 1.0, 1 }
-- Rested overlay stays a distinct cyan so it does not read as more XP.
local REST_FROM = { 0.08, 0.32, 0.62, 0.9 }
local REST_TO = { 0.32, 0.78, 1.0, 0.9 }
local snapping

local function watch(button)
  if button._shadowUIWatch or not hooksecurefunc then
    return
  end
  button._shadowUIWatch = true
  hooksecurefunc(button, "SetPoint", function()
    if not snapping then
      Addon:SkinTrackingBars()
    end
  end)
  hooksecurefunc(button, "SetParent", function()
    if not snapping then
      Addon:SkinTrackingBars()
    end
  end)
end

local function isShown(frame)
  return not frame.IsShown or frame:IsShown()
end

local function place(bar, relative, relativePoint, height)
  watch(bar)
  bar:SetParent(UIParent)
  if bar.SetAlpha then
    bar:SetAlpha(1)
  end
  bar:ClearAllPoints()
  bar:SetPoint("TOP", relative, relativePoint, 0, 0)
  local width = UIParent.GetWidth and UIParent:GetWidth()
  if height and bar.SetHeight then
    bar:SetHeight(height)
  end
  if width and bar.SetWidth then
    bar:SetWidth(width)
  elseif width and bar.SetSize then
    bar:SetSize(width, height or (bar.GetHeight and bar:GetHeight()) or 13)
  end
end

local function buryOverlay(tex)
  if not tex or tex._shadowUIXPBury then
    return
  end
  tex._shadowUIXPBury = true
  if tex.Hide then
    tex:Hide()
  end
  if tex.SetAlpha then
    tex:SetAlpha(0)
  end
  if hooksecurefunc and tex.Show then
    hooksecurefunc(tex, "Show", function(self)
      if self.Hide then
        self:Hide()
      end
    end)
  end
  if hooksecurefunc and tex.SetShown then
    hooksecurefunc(tex, "SetShown", function(self, shown)
      if shown and self.Hide then
        self:Hide()
      end
    end)
  end
end

local function buryContainerArt(container)
  if not container then
    return
  end
  local lists = { container.MainMenuBarTextures, container.StandaloneTextures }
  for i = 1, #lists do
    local list = lists[i]
    if list then
      for j = 1, #list do
        buryOverlay(list[j])
      end
    end
  end
end

local function watchMethod(frame, method)
  if not frame or not frame[method] or not hooksecurefunc then
    return
  end
  local flag = "_shadowUIWatch_" .. method
  if frame[flag] then
    return
  end
  frame[flag] = true
  hooksecurefunc(frame, method, function()
    if not snapping then
      Addon:SkinTrackingBars()
    end
  end)
end

local function flattenFill(tex)
  if not tex then
    return
  end
  if tex.SetHorizTile then
    tex:SetHorizTile(false)
  end
  if tex.SetVertTile then
    tex:SetVertTile(false)
  end
  if tex.SetTexCoord then
    tex:SetTexCoord(0, 1, 0, 1)
  end
end

local function hideNativeFill(bar)
  if not bar then
    return
  end
  buryOverlay(bar.GetStatusBarTexture and bar:GetStatusBarTexture())
  buryOverlay(bar.shadowUIMeter)
  buryOverlay(bar.Spark or bar.BarSpark)
end

local function overlayOn(host, fill)
  local meter = host.shadowUIMeter
  if not meter then
    if not host.CreateTexture then
      return fill
    end
    meter = host:CreateTexture(nil, "OVERLAY", nil, 6)
    host.shadowUIMeter = meter
  end
  if meter.SetDrawLayer then
    meter:SetDrawLayer("OVERLAY", 6)
  end
  if meter.SetTexture then
    meter:SetTexture(FILL)
  end
  if meter.SetAllPoints then
    meter:SetAllPoints(fill or host)
  end
  flattenFill(meter)
  return meter
end

local function ensureWell(bar)
  if bar.shadowUIWell then
    return bar.shadowUIWell
  end
  if not bar.CreateTexture then
    return nil
  end
  local well = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
  bar.shadowUIWell = well
  if well.SetColorTexture then
    well:SetColorTexture(0.05, 0.05, 0.05, 1)
  elseif well.SetTexture then
    well:SetTexture(FILL)
    if well.SetVertexColor then
      well:SetVertexColor(0.05, 0.05, 0.05, 1)
    end
  end
  if well.SetAllPoints then
    well:SetAllPoints(bar)
  end
  return well
end

local function layoutTick(tick, bar, x)
  if tick.SetDrawLayer then
    tick:SetDrawLayer("OVERLAY", 7)
  end
  if tick.SetColorTexture then
    tick:SetColorTexture(0, 0, 0, 0.45)
  elseif tick.SetTexture then
    tick:SetTexture(FILL)
    if tick.SetVertexColor then
      tick:SetVertexColor(0, 0, 0, 0.45)
    end
  end
  if tick.ClearAllPoints then
    tick:ClearAllPoints()
  end
  if tick.SetPoint then
    tick:SetPoint("TOP", bar, "TOPLEFT", x, 0)
    tick:SetPoint("BOTTOM", bar, "BOTTOMLEFT", x, 0)
  end
  if tick.SetWidth then
    tick:SetWidth(1)
  end
end

local function ensureTicks(bar)
  if not bar.CreateTexture then
    return bar.shadowUITicks
  end
  local ticks = bar.shadowUITicks
  if not ticks then
    ticks = {}
    for i = 1, TICKS - 1 do
      ticks[i] = bar:CreateTexture(nil, "OVERLAY", nil, 7)
    end
    bar.shadowUITicks = ticks
  end
  local width = (bar.GetWidth and bar:GetWidth()) or 1
  for i = 1, #ticks do
    layoutTick(ticks[i], bar, width * (i / TICKS))
  end
  return ticks
end

local function outlineText(fs)
  if not fs then
    return
  end
  local path = _G.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
  if fs.GetFont then
    path = fs:GetFont() or path
  end
  if fs.SetFont and path then
    fs:SetFont(path, TEXT_SIZE, "OUTLINE")
  end
  if fs.SetShadowOffset then
    fs:SetShadowOffset(1, -1)
  end
  if fs.SetShadowColor then
    fs:SetShadowColor(0, 0, 0, 1)
  end
  if fs.SetTextColor then
    fs:SetTextColor(1, 1, 1, 1)
  end
  if fs.SetJustifyH then
    fs:SetJustifyH("CENTER")
  end
  if fs.ClearAllPoints and fs.SetPoint then
    fs:ClearAllPoints()
    fs:SetPoint("CENTER", (fs.GetParent and fs:GetParent()) or _G.MainMenuExpBar, "CENTER", 0, 0)
  end
  if fs.Show then
    fs:Show()
  end
end

local function paintRest(rest)
  if not rest then
    return
  end
  if rest.SetTexture then
    rest:SetTexture(FILL)
  end
  flattenFill(rest)
  if Addon.ApplyStatusBarGradient then
    Addon:ApplyStatusBarGradient(rest, "HORIZONTAL", REST_FROM, REST_TO)
  elseif rest.SetVertexColor then
    rest:SetVertexColor(REST_TO[1], REST_TO[2], REST_TO[3], REST_TO[4])
  end
end

local function buryXPArt(bar)
  buryOverlay(_G.MainMenuXPBarTextureLeft)
  buryOverlay(_G.MainMenuXPBarTextureRight)
  buryOverlay(_G.MainMenuXPBarTextureMid)
  for i = 0, 4 do
    buryOverlay(_G["MainMenuXPBarTexture" .. i])
  end
  for i = 1, 19 do
    buryOverlay(_G["MainMenuXPBarDiv" .. i])
  end
  if not bar or not bar.GetRegions then
    return
  end
  local regions = { bar:GetRegions() }
  for i = 1, #regions do
    local tex = regions[i]
    if tex and tex ~= bar.shadowUIWell and tex ~= bar.shadowUIMeter then
      local name = tex.GetName and tex:GetName() or ""
      if name:find("XPBar", 1, true) or name:find("Div", 1, true) then
        buryOverlay(tex)
      end
    end
  end
end

local function paintFill(bar)
  if bar.SetStatusBarTexture then
    bar:SetStatusBarTexture(FILL)
  end
  local fill = bar.GetStatusBarTexture and bar:GetStatusBarTexture()
  if fill and fill.SetTexture then
    fill:SetTexture(FILL)
  end
  flattenFill(fill)
  local meter = overlayOn(bar, fill)
  if Addon.ApplyStatusBarGradient then
    if fill then
      Addon:ApplyStatusBarGradient(fill, "HORIZONTAL", XP_FROM, XP_TO)
    end
    Addon:ApplyStatusBarGradient(meter, "HORIZONTAL", XP_FROM, XP_TO)
  elseif meter and meter.SetVertexColor then
    meter:SetVertexColor(XP_TO[1], XP_TO[2], XP_TO[3], 1)
  end
end

local function watchColor(bar, host)
  if not bar or bar._shadowUIXPColorWatch or not hooksecurefunc or not bar.SetStatusBarColor then
    return
  end
  bar._shadowUIXPColorWatch = true
  hooksecurefunc(bar, "SetStatusBarColor", function(self)
    if self._shadowUIXPPainting then
      return
    end
    self._shadowUIXPPainting = true
    paintFill(host or self)
    if host and host ~= self then
      hideNativeFill(self)
    end
    self._shadowUIXPPainting = nil
  end)
end

local function coverLevel(bar)
  local level = (bar.GetFrameLevel and bar:GetFrameLevel()) or 0
  local overlay = bar.OverlayFrame
  if overlay and overlay.GetFrameLevel then
    local over = overlay:GetFrameLevel() or 0
    if over > level then
      level = over
    end
  end
  local status = bar.StatusBar
  if status and status.GetFrameLevel then
    local statusLevel = status:GetFrameLevel() or 0
    if statusLevel > level then
      level = statusLevel
    end
  end
  return level + 20
end

local function formatXPText(cur, maxv)
  if not maxv or maxv <= 0 then
    return ""
  end
  return "(" .. math.ceil((cur / maxv) * 100) .. "%) " .. cur .. " / " .. maxv
end

local function liveXP()
  local cur, minv, maxv = 0, 0, 0
  if UnitXP and UnitXPMax then
    maxv = UnitXPMax("player") or 0
    if maxv > 0 then
      cur = UnitXP("player") or 0
    end
  end
  return cur, minv, maxv
end

local function syncCover(bar, host)
  local cur, minv, maxv = liveXP()
  if maxv <= 0 and bar and bar.GetMinMaxValues then
    minv, maxv = bar:GetMinMaxValues()
    cur = (bar.GetValue and bar:GetValue()) or 0
  end
  if host.SetMinMaxValues then
    host:SetMinMaxValues(minv or 0, maxv or 1)
  end
  if host.SetValue then
    host:SetValue(cur or 0)
  end
  local fs = host.shadowUIText
  if fs and fs.SetText then
    fs:SetText(formatXPText(cur, maxv))
    if fs.SetAlpha then
      fs:SetAlpha(1)
    end
    if fs.Show then
      fs:Show()
    end
  end
end

local function say(msg)
  if Addon.Print then
    Addon:Print(msg)
  end
end

local function describe(frame, label)
  if not frame then
    return label .. "=nil"
  end
  local function get(method, ...)
    if not frame[method] then
      return nil
    end
    local ok, a, b, c, d, e = pcall(frame[method], frame, ...)
    if not ok then
      return nil
    end
    return a, b, c, d, e
  end
  local name = get("GetName") or label
  local typ = get("GetObjectType") or "?"
  local parent = get("GetParent")
  local pname = parent and parent.GetName and parent:GetName() or (parent and "?") or "nil"
  local shown = tostring(get("IsShown"))
  local w = get("GetWidth") or 0
  local h = get("GetHeight") or 0
  local strata = get("GetFrameStrata") or "?"
  local level = get("GetFrameLevel")
  local alpha = get("GetAlpha")
  local point, rel, relPoint, x, y = get("GetPoint", 1)
  local relName = rel and rel.GetName and rel:GetName() or (rel and "?") or "nil"
  return string.format(
    "%s name=%s type=%s parent=%s shown=%s size=%.0fx%.0f %s:%s a=%s point=%s,%s,%s,%.0f,%.0f",
    label,
    tostring(name),
    tostring(typ),
    tostring(pname),
    shown,
    w,
    h,
    tostring(strata),
    tostring(level),
    tostring(alpha),
    tostring(point),
    tostring(relName),
    tostring(relPoint),
    x or 0,
    y or 0
  )
end

local function listChildren(frame)
  if not frame or not frame.GetChildren then
    return "-"
  end
  local ok, kids = pcall(function()
    return { frame:GetChildren() }
  end)
  if not ok then
    return "err"
  end
  local names = {}
  for i = 1, math.min(#kids, 16) do
    local child = kids[i]
    local name = (child and child.GetName and child:GetName())
      or (child and child.GetObjectType and child:GetObjectType())
      or "?"
    names[#names + 1] = name
  end
  return table.concat(names, ",")
end

local function listRegions(frame)
  if not frame or not frame.GetRegions then
    return "-"
  end
  local ok, regions = pcall(function()
    return { frame:GetRegions() }
  end)
  if not ok then
    return "err"
  end
  local names = {}
  for i = 1, math.min(#regions, 16) do
    local region = regions[i]
    local name = (region and region.GetName and region:GetName()) or "?"
    local layer = region and region.GetDrawLayer and select(1, region:GetDrawLayer()) or "?"
    local shown = region and region.IsShown and tostring(region:IsShown()) or "?"
    names[#names + 1] = name .. ":" .. tostring(layer) .. ":" .. shown
  end
  return table.concat(names, ",")
end

function Addon:DumpXPStack()
  local build = "?"
  if GetBuildInfo then
    local ok, version, _, _, interface = pcall(GetBuildInfo)
    if ok then
      build = tostring(version) .. "/" .. tostring(interface)
    end
  end
  say("[DEBUG-xpbar] build=" .. build)
  local names = {
    "MainMenuExpBar",
    "ReputationWatchBar",
    "StatusTrackingBarManager",
    "MainStatusTrackingBarContainer",
    "SecondaryStatusTrackingBarContainer",
    "ExhaustionTick",
    "MainMenuBarMaxLevelBar",
    "MainMenuBar",
    "ShadowUIXPHost",
  }
  for i = 1, #names do
    say("[DEBUG-xpbar] " .. describe(_G[names[i]], names[i]))
  end
  local exp = _G.MainMenuExpBar
  if exp then
    say("[DEBUG-xpbar] exp.StatusBar " .. describe(exp.StatusBar, "StatusBar"))
    say("[DEBUG-xpbar] exp.OverlayFrame " .. describe(exp.OverlayFrame, "OverlayFrame"))
    say("[DEBUG-xpbar] exp.host " .. describe(exp.shadowUIXPHost, "shadowUIXPHost"))
    say("[DEBUG-xpbar] exp.children " .. listChildren(exp))
    say("[DEBUG-xpbar] exp.regions " .. listRegions(exp))
    if exp.StatusBar then
      say("[DEBUG-xpbar] status.children " .. listChildren(exp.StatusBar))
      say("[DEBUG-xpbar] status.regions " .. listRegions(exp.StatusBar))
    end
  end
  local main = _G.MainStatusTrackingBarContainer
  if main then
    local shown = main.GetShownBar and main:GetShownBar()
    say("[DEBUG-xpbar] main.shownBar " .. describe(shown, "shownBar"))
    if shown then
      say("[DEBUG-xpbar] shown.StatusBar " .. describe(shown.StatusBar, "StatusBar"))
      say("[DEBUG-xpbar] shown.children " .. listChildren(shown))
    end
    say("[DEBUG-xpbar] main.children " .. listChildren(main))
    local standalone = main.StandaloneTextures and main.StandaloneTextures[1]
    say("[DEBUG-xpbar] standalone1=" .. (standalone and (standalone.IsShown and tostring(standalone:IsShown()) or "yes") or "nil"))
  end
  local mgr = _G.StatusTrackingBarManager
  if mgr then
    say("[DEBUG-xpbar] mgr.children " .. listChildren(mgr))
  end
  local div = _G.MainMenuXPBarDiv1
  local tex = _G.MainMenuXPBarTexture0
  say("[DEBUG-xpbar] Div1=" .. (div and (div.IsShown and tostring(div:IsShown()) or "yes") or "nil")
    .. " Tex0=" .. (tex and (tex.IsShown and tostring(tex:IsShown()) or "yes") or "nil")
    .. " configure=" .. tostring(MainMenuTrackingBar_Configure ~= nil)
    .. " updateXP=" .. tostring(MainMenuBar_UpdateExperienceBars ~= nil)
    .. " setWidth=" .. tostring(MainMenuExpBar_SetWidth ~= nil))
  local focus = GetMouseFocus or (GetMouseFoci and function()
    local foci = GetMouseFoci()
    return foci and foci[1]
  end)
  if focus then
    local ok, hovered = pcall(focus)
    if ok then
      say("[DEBUG-xpbar] mouse " .. describe(hovered, "mouse"))
    end
  end
end

local function ensureCover(anchor, expFrame)
  local host = anchor.shadowUIXPHost
  if not host and CreateFrame then
    local ok, created = pcall(CreateFrame, "StatusBar", "ShadowUIXPHost", UIParent)
    if ok then
      host = created
      anchor.shadowUIXPHost = host
    end
  end
  if not host then
    return expFrame and expFrame.StatusBar or expFrame or anchor
  end
  if host.SetParent then
    host:SetParent(UIParent)
  end
  if host.EnableMouse then
    host:EnableMouse(false)
  end
  if host.SetAllPoints then
    host:SetAllPoints(anchor)
  end
  if host.SetFrameStrata then
    host:SetFrameStrata("HIGH")
  end
  if host.SetFrameLevel then
    host:SetFrameLevel(coverLevel(expFrame or anchor))
  end
  if host.Show then
    host:Show()
  end
  syncCover((expFrame and expFrame.StatusBar) or expFrame or anchor, host)
  return host
end

local function hideBlizzardText(bar)
  local texts = {
    _G.MainMenuBarExpText,
    bar and bar.Text,
    bar and bar.OverlayFrame and bar.OverlayFrame.Text,
  }
  for i = 1, #texts do
    local fs = texts[i]
    if fs and fs.SetAlpha then
      fs:SetAlpha(0)
    end
  end
end

local function shownXPFrame(container)
  if not container then
    return nil
  end
  local bar = container.GetShownBar and container:GetShownBar()
  if bar and bar.isExpBar then
    return bar
  end
  local bars = container.bars
  if bars then
    local enum = _G.StatusTrackingBarInfo and _G.StatusTrackingBarInfo.BarsEnum
    local index = enum and enum.Experience or 4
    local expBar = bars[index]
    if expBar and (expBar.isExpBar or not bar) then
      return expBar
    end
  end
  if container.isExpBar or container.GetStatusBarTexture or container.SetStatusBarTexture then
    return container
  end
end

local function paintXP(anchor, expFrame)
  expFrame = expFrame or shownXPFrame(anchor) or anchor
  if not expFrame then
    return
  end
  local status = expFrame.StatusBar or expFrame
  buryXPArt(status)
  buryContainerArt(anchor)
  watchMethod(anchor, "UseMainMenuBarArt")
  watchMethod(expFrame, "UpdateStatusBarTextures")
  local host = ensureCover(anchor, expFrame)
  ensureWell(host)
  if host.SetClipsChildren then
    host:SetClipsChildren(false)
  end
  if Addon.ApplyOuterChrome then
    Addon:ApplyOuterChrome(host, "square")
  end
  watchColor(status, host)
  status._shadowUIXPPainting = true
  if status.SetStatusBarColor then
    status:SetStatusBarColor(XP_TO[1], XP_TO[2], XP_TO[3], 1)
  end
  paintFill(host)
  hideNativeFill(status)
  status._shadowUIXPPainting = nil
  paintRest(expFrame.ExhaustionLevelFillBar or _G.ExhaustionLevelFillBar)
  ensureTicks(host)
  hideBlizzardText(expFrame)
  if not host.shadowUIText then
    host.shadowUIText = host.CreateFontString and host:CreateFontString(nil, "OVERLAY") or nil
  end
  outlineText(host.shadowUIText or (expFrame.OverlayFrame and expFrame.OverlayFrame.Text) or expFrame.Text or _G.MainMenuBarExpText)
  if host.shadowUIText and host.shadowUIText.SetPoint then
    if host.shadowUIText.ClearAllPoints then
      host.shadowUIText:ClearAllPoints()
    end
    host.shadowUIText:SetPoint("CENTER", host, "CENTER", 0, 0)
  end
  if host.shadowUIText and host.shadowUIText.SetDrawLayer then
    host.shadowUIText:SetDrawLayer("OVERLAY", 8)
  end
  syncCover(status, host)
  watchMethod(expFrame, "SetBarText")
  watchMethod(expFrame, "UpdateCurrentText")
  if Addon.RegisterEvent and not Addon._xpTextEvent then
    Addon._xpTextEvent = true
    pcall(Addon.RegisterEvent, Addon, "PLAYER_XP_UPDATE", "SkinTrackingBars")
  end
end

function Addon:SkinTrackingBars()
  if self._skinTrackingThen then
    return
  end
  self._skinTrackingThen = true
  snapping = true

  local main = _G.MainStatusTrackingBarContainer
  local secondary = _G.SecondaryStatusTrackingBarContainer
  local exp = _G.MainMenuExpBar
  local rep = _G.ReputationWatchBar
  local relative = UIParent
  local relativePoint = "TOP"

  local mgr = _G.StatusTrackingBarManager
  if mgr then
    watch(mgr)
    watchMethod(mgr, "UpdateBarVisuals")
    watchMethod(mgr, "UpdateBarsShown")
    if mgr.Show then
      mgr:Show()
    end
    if mgr.SetAlpha then
      mgr:SetAlpha(1)
    end
  end

  if main and isShown(main) then
    place(main, UIParent, "TOP", HEIGHT)
    pcall(paintXP, main, shownXPFrame(main))
    relative = main
    relativePoint = "BOTTOM"
  elseif exp and isShown(exp) then
    place(exp, UIParent, "TOP", HEIGHT)
    pcall(paintXP, exp, exp)
    relative = exp
    relativePoint = "BOTTOM"
  end

  if secondary and isShown(secondary) then
    place(secondary, relative, relativePoint)
    buryContainerArt(secondary)
  elseif rep and isShown(rep) then
    place(rep, relative, relativePoint)
  end

  snapping = nil
  self._skinTrackingThen = nil
  if self.ApplyXPFade then
    self:ApplyXPFade()
  end
end

local function restyle()
  Addon:SkinTrackingBars()
end

if hooksecurefunc then
  if MainMenuBar_UpdateExperienceBars then
    hooksecurefunc("MainMenuBar_UpdateExperienceBars", restyle)
  end
  if MainMenuTrackingBar_Configure then
    hooksecurefunc("MainMenuTrackingBar_Configure", restyle)
  end
  if UpdateMainMenuBarArt then
    hooksecurefunc("UpdateMainMenuBarArt", restyle)
  end
  if MainMenuExpBar_SetWidth then
    hooksecurefunc("MainMenuExpBar_SetWidth", restyle)
  end
end
