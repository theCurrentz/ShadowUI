--[[
  Purpose: Unit Frame Designer as a visual studio inside /shadowui.
           Tree, canvas preview, and inspector edit Widget geometry.
           Writes keep relativeTo. Does not overlay the live HUD.
  Deps: ShadowUI:ResolveWidgetRects(), ShadowUI:PersistWidgetGeometry(),
        ShadowUI:UnitFrameLayoutForApply()
  Public: ShadowUI:CreateUnitStudio(), ShadowUI:RefreshUnitStudio(),
          ShadowUI:SelectStudioWidget(), ShadowUI:OpenUnitFrameDesigner(),
          ShadowUI:LayoutUnitStudioHost(),
          ShadowUI:SetSelectedWidgetOffset(), ShadowUI:SetSelectedWidgetSize(),
          ShadowUI:SetSelectedWidgetAnchor(), ShadowUI:CommitWidgetInspector(),
          ShadowUI:RefreshUnitDesignerOverlays()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local MIN_SIZE = 4
local TREE_W = 128
local INSPECTOR_W = 196

local BAR_FILE = "Interface\\TargetingFrame\\UI-StatusBar"
local PORTRAIT_FILE = "Interface\\CharacterFrame\\TempPortrait"
local AURA_FILE = "Interface\\Icons\\Spell_Holy_Renew"
local CLASS_RGB = {
  WARRIOR = { 0.78, 0.61, 0.43 },
  PALADIN = { 0.96, 0.55, 0.73 },
  HUNTER = { 0.67, 0.83, 0.45 },
  ROGUE = { 1.0, 0.96, 0.41 },
  PRIEST = { 1.0, 1.0, 1.0 },
  SHAMAN = { 0.0, 0.44, 0.87 },
  MAGE = { 0.41, 0.8, 0.94 },
  WARLOCK = { 0.58, 0.51, 0.79 },
  DRUID = { 1.0, 0.49, 0.04 },
}

local function widgetLabel(widgetId)
  local labels = Addon.UNIT_WIDGET_LABELS or {}
  return labels[widgetId] or widgetId
end

local function classRgb(classFile)
  if RAID_CLASS_COLORS and classFile and RAID_CLASS_COLORS[classFile] then
    local c = RAID_CLASS_COLORS[classFile]
    return c.r or 1, c.g or 1, c.b or 1
  end
  local rgb = CLASS_RGB[classFile] or CLASS_RGB.WARRIOR
  return rgb[1], rgb[2], rgb[3]
end

function Addon:StudioPreviewUnit(frameId)
  local token = frameId == "target" and "target" or "player"
  local mock = {
    name = frameId == "target" and "Arthas" or "Player",
    level = 60,
    health = 7432,
    maxHealth = 10000,
    power = 3120,
    maxPower = 5000,
    class = frameId == "target" and "PALADIN" or "WARRIOR",
    reaction = frameId == "target" and "hostile" or "friendly",
  }
  if UnitExists and UnitExists(token) then
    if UnitName then
      mock.name = UnitName(token) or mock.name
    end
    if UnitLevel then
      mock.level = UnitLevel(token) or mock.level
    end
    if UnitHealth and UnitHealthMax then
      mock.health = UnitHealth(token) or mock.health
      mock.maxHealth = UnitHealthMax(token) or mock.maxHealth
    end
    if UnitPower and UnitPowerMax then
      mock.power = UnitPower(token) or mock.power
      mock.maxPower = UnitPowerMax(token) or mock.maxPower
    end
    if UnitClass then
      mock.class = select(2, UnitClass(token)) or mock.class
    end
  end
  if mock.maxHealth == 0 then
    mock.maxHealth = 1
  end
  if mock.maxPower == 0 then
    mock.maxPower = 1
  end
  return mock
end

local function mockTex(node, key, layer)
  node.mock = node.mock or {}
  local tex = node.mock[key]
  if tex then
    return tex
  end
  tex = node:CreateTexture(nil, layer or "ARTWORK")
  node.mock[key] = tex
  return tex
end

local function setTex(tex, file)
  if not tex then
    return
  end
  if tex.SetTexture then
    tex:SetTexture(file)
  end
end

function Addon:PaintStudioMock(node, widgetId, frameId)
  if not node or not widgetId then
    return
  end
  local mock = self:StudioPreviewUnit(frameId or "player")
  local kind = (self.UNIT_WIDGET_KIND or {})[widgetId]
  if node.fill then
    node.fill:SetColorTexture(1, 0.82, 0.1, 0)
  end
  if widgetId == "art" then
    local chrome = mockTex(node, "chrome", "BACKGROUND")
    if chrome.SetAllPoints then
      chrome:SetAllPoints(node)
    end
    if self.PaintUnitFrameArt then
      self:PaintUnitFrameArt(chrome, frameId, {
        left = node.rectLeft or 0,
        bottom = node.rectBottom or 0,
        width = node.GetWidth and node:GetWidth() or 0,
        height = node.GetHeight and node:GetHeight() or 0,
      })
    end
    if chrome.SetVertexColor then
      chrome:SetVertexColor(0.05, 0.05, 0.05, 1)
    end
    if node.fontString then
      node.fontString:SetText("")
    end
    return chrome
  end
  if widgetId == "portrait" then
    local face = mockTex(node, "face", "ARTWORK")
    if face.SetAllPoints then
      face:SetAllPoints(node)
    end
    local token = frameId == "target" and "target" or "player"
    local painted
    if SetPortraitTexture and UnitExists and UnitExists(token) then
      painted = pcall(SetPortraitTexture, face, token)
    end
    if not painted and SetPortraitToTexture then
      painted = pcall(SetPortraitToTexture, face, PORTRAIT_FILE)
    end
    if not painted then
      setTex(face, PORTRAIT_FILE)
    end
    if node.fontString then
      node.fontString:SetText("")
    end
    return face
  end
  if widgetId == "nameBackground" then
    local well = mockTex(node, "well", "ARTWORK")
    if well.SetAllPoints then
      well:SetAllPoints(node)
    end
    setTex(well, "Interface\\Buttons\\WHITE8X8")
    local r, g, b = 0.8, 0.1, 0.1
    if mock.reaction ~= "hostile" then
      r, g, b = classRgb(mock.class)
    end
    if well.SetVertexColor then
      well:SetVertexColor(r, g, b, 0.85)
    elseif well.SetColorTexture then
      well:SetColorTexture(r, g, b, 0.85)
    end
    if node.fontString then
      node.fontString:SetText("")
    end
    return well
  end
  if widgetId == "health" or widgetId == "power" then
    local bg = mockTex(node, "bg", "BACKGROUND")
    if bg.SetAllPoints then
      bg:SetAllPoints(node)
    end
    setTex(bg, BAR_FILE)
    if bg.SetVertexColor then
      bg:SetVertexColor(0.08, 0.08, 0.08)
    end
    local fill = mockTex(node, "bar", "ARTWORK")
    local ratio = widgetId == "health" and (mock.health / mock.maxHealth) or (mock.power / mock.maxPower)
    if ratio > 1 then
      ratio = 1
    end
    if fill.ClearAllPoints then
      fill:ClearAllPoints()
    end
    fill:SetPoint("TOPLEFT", node, "TOPLEFT", 0, 0)
    fill:SetPoint("BOTTOMLEFT", node, "BOTTOMLEFT", 0, 0)
    local width = (node.GetWidth and node:GetWidth() or 0) * ratio
    if fill.SetWidth then
      fill:SetWidth(width)
    end
    setTex(fill, BAR_FILE)
    local r, g, b = 0.0, 0.8, 0.0
    if widgetId == "power" then
      if mock.class == "WARRIOR" then
        r, g, b = 0.9, 0.15, 0.15
      else
        r, g, b = 0.0, 0.4, 1.0
      end
    end
    if self.LightingGradient and fill.SetTexture then
      local from, to = self:LightingGradient(r, g, b, 1)
      if self.ApplyStatusBarGradient then
        self:ApplyStatusBarGradient(fill, "HORIZONTAL", from, to)
      elseif fill.SetVertexColor then
        fill:SetVertexColor(to[1], to[2], to[3], 1)
      end
    elseif fill.SetVertexColor then
      fill:SetVertexColor(r, g, b)
    end
    if node.fontString then
      node.fontString:SetText("")
    end
    return fill
  end
  if widgetId == "name" then
    if node.fontString then
      node.fontString:SetText(mock.name)
      if node.fontString.SetTextColor then
        node.fontString:SetTextColor(1, 0.82, 0, 1)
      end
    end
    return
  end
  if widgetId == "level" then
    if node.fontString then
      node.fontString:SetText(tostring(mock.level))
      if node.fontString.SetTextColor then
        node.fontString:SetTextColor(1, 0.82, 0, 1)
      end
    end
    return
  end
  if widgetId == "healthText" then
    if node.fontString then
      node.fontString:SetText(string.format("%d / %d", mock.health, mock.maxHealth))
      if node.fontString.SetTextColor then
        node.fontString:SetTextColor(1, 1, 1, 1)
      end
    end
    return
  end
  if widgetId == "powerText" then
    if node.fontString then
      node.fontString:SetText(string.format("%d / %d", mock.power, mock.maxPower))
      if node.fontString.SetTextColor then
        node.fontString:SetTextColor(1, 1, 1, 1)
      end
    end
    return
  end
  if widgetId == "auras" then
    local icon = mockTex(node, "icon", "ARTWORK")
    if icon.SetAllPoints then
      icon:SetAllPoints(node)
    end
    setTex(icon, AURA_FILE)
    if node.fontString then
      node.fontString:SetText("")
    end
    return icon
  end
  if widgetId == "spellBar" then
    local bg = mockTex(node, "bg", "BACKGROUND")
    if bg.SetAllPoints then
      bg:SetAllPoints(node)
    end
    setTex(bg, BAR_FILE)
    if bg.SetVertexColor then
      bg:SetVertexColor(0.08, 0.08, 0.08)
    end
    local fill = mockTex(node, "bar", "ARTWORK")
    if fill.ClearAllPoints then
      fill:ClearAllPoints()
    end
    fill:SetPoint("TOPLEFT", node, "TOPLEFT", 0, 0)
    fill:SetPoint("BOTTOMLEFT", node, "BOTTOMLEFT", 0, 0)
    if fill.SetWidth then
      fill:SetWidth((node.GetWidth and node:GetWidth() or 0) * 0.45)
    end
    setTex(fill, BAR_FILE)
    if fill.SetVertexColor then
      fill:SetVertexColor(1.0, 0.7, 0.0)
    end
    if node.fontString then
      node.fontString:SetText("Frostbolt")
      if node.fontString.SetTextColor then
        node.fontString:SetTextColor(1, 1, 1, 1)
      end
    end
    return fill
  end
  if kind == "fontstring" and node.fontString then
    node.fontString:SetText(widgetLabel(widgetId))
  end
end

local function studioLayout(frameId)
  local cfg = (Addon.ResolveEffective and Addon:ResolveEffective()) or {}
  if Addon.UnitFrameLayoutForApply then
    return Addon:UnitFrameLayoutForApply(cfg.layout or {}, frameId)
  end
  return (cfg.layout or {})[frameId] or {}
end

local function formatOffset(x, y)
  return string.format("%+.0f, %+.0f", tonumber(x) or 0, tonumber(y) or 0)
end

local function cursorOn(frame)
  local uiScale = 1
  if UIParent and UIParent.GetEffectiveScale then
    uiScale = UIParent:GetEffectiveScale() or 1
  end
  if not uiScale or uiScale == 0 then
    uiScale = 1
  end
  local cx, cy = 0, 0
  if Addon.EditCursor then
    cx, cy = Addon:EditCursor()
  elseif GetCursorPosition then
    cx, cy = GetCursorPosition()
    cx, cy = cx / uiScale, cy / uiScale
  end
  if not frame then
    return nil
  end
  local left = frame.GetLeft and frame:GetLeft()
  local bottom = frame.GetBottom and frame:GetBottom()
  if left == nil or bottom == nil then
    return nil
  end
  local frameScale = uiScale
  if frame.GetEffectiveScale then
    frameScale = frame:GetEffectiveScale() or uiScale
  elseif frame.GetScale then
    frameScale = (frame:GetScale() or 1) * uiScale
  end
  if not frameScale or frameScale == 0 then
    frameScale = uiScale
  end
  local localScale = frameScale / uiScale
  if not localScale or localScale == 0 then
    localScale = 1
  end
  return (cx - left) / localScale, (cy - bottom) / localScale
end

function Addon:RefreshUnitDesignerOverlays()
  -- World HUD chips are not part of the studio.
end

function Addon:EnsureUnitStudio(parent)
  if self.unitStudio and self.unitStudio.frame then
    return self.unitStudio
  end
  if not CreateFrame then
    return nil
  end
  parent = parent or UIParent
  local frame = CreateFrame("Frame", "ShadowUIUnitStudio", parent)
  frame:SetSize(720, 420)
  local bg = frame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(frame)
  bg:SetColorTexture(0.07, 0.07, 0.08, 1)
  local tree = CreateFrame("Frame", "ShadowUIUnitStudioTree", frame)
  tree:SetPoint("TOPLEFT", 0, 0)
  tree:SetPoint("BOTTOMLEFT", 0, 0)
  tree:SetWidth(TREE_W)
  local treeFill = tree:CreateTexture(nil, "BACKGROUND")
  treeFill:SetAllPoints(tree)
  treeFill:SetColorTexture(0.1, 0.1, 0.11, 1)
  local canvas = CreateFrame("Frame", "ShadowUIUnitStudioCanvas", frame)
  canvas:SetPoint("TOPLEFT", TREE_W, -28)
  canvas:SetPoint("BOTTOMRIGHT", -INSPECTOR_W, 0)
  canvas:EnableMouse(true)
  if canvas.SetClipsChildren then
    canvas:SetClipsChildren(true)
  end
  canvas:SetScript("OnMouseUp", function()
    Addon.selectedStudioWidget = nil
    Addon:RefreshUnitStudio()
  end)
  canvas:SetScript("OnSizeChanged", function()
    if Addon.LayoutUnitStudioHost then
      Addon:LayoutUnitStudioHost()
    end
  end)
  local canvasFill = canvas:CreateTexture(nil, "BACKGROUND")
  canvasFill:SetAllPoints(canvas)
  canvasFill:SetColorTexture(0.11, 0.11, 0.13, 1)
  local host = CreateFrame("Frame", "ShadowUIUnitStudioHost", canvas)
  host:SetPoint("CENTER", canvas, "CENTER", 0, 0)
  local hostFill = host:CreateTexture(nil, "BACKGROUND")
  hostFill:SetAllPoints(host)
  hostFill:SetColorTexture(0, 0, 0, 0)
  host.fill = hostFill
  local inspector = CreateFrame("Frame", "ShadowUIWidgetInspector", frame)
  inspector:SetPoint("TOPRIGHT", 0, 0)
  inspector:SetPoint("BOTTOMRIGHT", 0, 0)
  inspector:SetWidth(INSPECTOR_W)
  local inspectorFill = inspector:CreateTexture(nil, "BACKGROUND")
  inspectorFill:SetAllPoints(inspector)
  inspectorFill:SetColorTexture(0.09, 0.09, 0.1, 1)
  local title = inspector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 10, -12)
  inspector.title = title
  local computed = inspector:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  computed:SetPoint("TOPLEFT", 10, -32)
  computed:SetJustifyH("LEFT")
  inspector.computed = computed
  local anchor = inspector:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  anchor:SetPoint("TOPLEFT", 10, -88)
  anchor:SetJustifyH("LEFT")
  inspector.anchor = anchor
  local function makeBox(name)
    local ok, box = pcall(CreateFrame, "EditBox", name, inspector, "InputBoxTemplate")
    if not ok or not box then
      box = CreateFrame("EditBox", name, inspector)
    end
    box:SetSize(72, 18)
    if box.SetAutoFocus then
      box:SetAutoFocus(false)
    end
    box:SetScript("OnEnterPressed", function()
      if Addon.CommitWidgetInspector then
        Addon:CommitWidgetInspector()
      end
      if box.ClearFocus then
        box:ClearFocus()
      end
    end)
    return box
  end
  inspector.widthBox = makeBox("ShadowUIWidgetWidth")
  inspector.widthBox:SetPoint("TOPLEFT", 10, -168)
  inspector.heightBox = makeBox("ShadowUIWidgetHeight")
  inspector.heightBox:SetPoint("TOPLEFT", 90, -168)
  inspector.xBox = makeBox("ShadowUIWidgetOffX")
  inspector.xBox:SetPoint("TOPLEFT", 10, -194)
  inspector.yBox = makeBox("ShadowUIWidgetOffY")
  inspector.yBox:SetPoint("TOPLEFT", 90, -194)
  inspector.pointBox = makeBox("ShadowUIWidgetPoint")
  inspector.pointBox:SetPoint("TOPLEFT", 10, -220)
  inspector.relativeBox = makeBox("ShadowUIWidgetRel")
  inspector.relativeBox:SetPoint("TOPLEFT", 90, -220)
  inspector.relativePointBox = makeBox("ShadowUIWidgetRelPoint")
  inspector.relativePointBox:SetPoint("TOPLEFT", 10, -246)
  inspector.stackBox = makeBox("ShadowUIWidgetStack")
  inspector.stackBox:SetPoint("TOPLEFT", 10, -272)
  inspector.stackBox:SetWidth(40)
  local raise = CreateFrame("Button", "ShadowUIWidgetStackRaise", inspector)
  raise:SetSize(56, 18)
  raise:SetPoint("TOPLEFT", 56, -272)
  local raiseLabel = raise:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  raiseLabel:SetPoint("CENTER")
  raiseLabel:SetText("Front")
  raise:SetScript("OnMouseUp", function()
    if Addon.NudgeWidgetStack and Addon.selectedStudioWidget then
      Addon:NudgeWidgetStack(Addon.studioFrameId or "player", Addon.selectedStudioWidget, 1)
    end
  end)
  inspector.raiseBtn = raise
  local lower = CreateFrame("Button", "ShadowUIWidgetStackLower", inspector)
  lower:SetSize(56, 18)
  lower:SetPoint("TOPLEFT", 116, -272)
  local lowerLabel = lower:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  lowerLabel:SetPoint("CENTER")
  lowerLabel:SetText("Back")
  lower:SetScript("OnMouseUp", function()
    if Addon.NudgeWidgetStack and Addon.selectedStudioWidget then
      Addon:NudgeWidgetStack(Addon.studioFrameId or "player", Addon.selectedStudioWidget, -1)
    end
  end)
  inspector.lowerBtn = lower
  local hint = inspector:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  hint:SetPoint("BOTTOMLEFT", 10, 10)
  hint:SetPoint("BOTTOMRIGHT", -10, 10)
  hint:SetJustifyH("LEFT")
  hint:SetText("Click a Widget and drag it. Resize Frame Art to crop the chrome. Stack is paint order.")
  inspector.hint = hint
  local tabs = {}
  for i, id in ipairs({ "player", "target" }) do
    local tab = CreateFrame("Button", "ShadowUIUnitStudioTab" .. id, frame)
    tab:SetSize(72, 22)
    tab:SetPoint("TOPLEFT", TREE_W + (i - 1) * 80, -4)
    local tabFill = tab:CreateTexture(nil, "ARTWORK")
    tabFill:SetAllPoints(tab)
    tabFill:SetColorTexture(0.2, 0.2, 0.22, 1)
    tab.fill = tabFill
    local label = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    label:SetText(id == "player" and "Player" or "Target")
    tab.label = label
    tab.frameId = id
    tab:SetScript("OnMouseUp", function()
      Addon.studioFrameId = id
      Addon.selectedStudioWidget = nil
      Addon:RefreshUnitStudio()
    end)
    tabs[id] = tab
  end
  local studio = {
    frame = frame,
    tree = tree,
    canvas = canvas,
    host = host,
    inspector = inspector,
    tabs = tabs,
    nodes = {},
    treeRows = {},
  }
  self.unitStudio = studio
  self.widgetInspector = inspector
  self.studioFrameId = self.studioFrameId or "player"
  self:LayoutUnitStudioHost()
  return studio
end

function Addon:CreateUnitStudio(parent)
  return self:EnsureUnitStudio(parent)
end

function Addon:LayoutUnitStudioHost()
  local studio = self.unitStudio
  if not studio or not studio.host or not studio.canvas then
    return
  end
  local layout = studioLayout(self.studioFrameId or "player")
  local hw, hh = self:UnitFrameHostSize(layout)
  studio.host:SetSize(hw, hh)
  if studio.host.ClearAllPoints then
    studio.host:ClearAllPoints()
  end
  studio.host:SetPoint("CENTER", studio.canvas, "CENTER", 0, 0)
  if studio.host.SetScale then
    studio.host:SetScale(1)
  end
end

local function showSelect(node, selected)
  if not node then
    return
  end
  if not node.selectTop then
    local function edge()
      local tex = node:CreateTexture(nil, "OVERLAY")
      tex:SetColorTexture(1, 0.82, 0.1, 1)
      return tex
    end
    node.selectTop = edge()
    node.selectTop:SetHeight(1)
    node.selectTop:SetPoint("TOPLEFT", node, "TOPLEFT", 0, 0)
    node.selectTop:SetPoint("TOPRIGHT", node, "TOPRIGHT", 0, 0)
    node.selectBottom = edge()
    node.selectBottom:SetHeight(1)
    node.selectBottom:SetPoint("BOTTOMLEFT", node, "BOTTOMLEFT", 0, 0)
    node.selectBottom:SetPoint("BOTTOMRIGHT", node, "BOTTOMRIGHT", 0, 0)
    node.selectLeft = edge()
    node.selectLeft:SetWidth(1)
    node.selectLeft:SetPoint("TOPLEFT", node, "TOPLEFT", 0, 0)
    node.selectLeft:SetPoint("BOTTOMLEFT", node, "BOTTOMLEFT", 0, 0)
    node.selectRight = edge()
    node.selectRight:SetWidth(1)
    node.selectRight:SetPoint("TOPRIGHT", node, "TOPRIGHT", 0, 0)
    node.selectRight:SetPoint("BOTTOMRIGHT", node, "BOTTOMRIGHT", 0, 0)
  end
  local show = selected and true or false
  node.selectTop:SetShown(show)
  node.selectBottom:SetShown(show)
  node.selectLeft:SetShown(show)
  node.selectRight:SetShown(show)
  if node.resizeGrip then
    node.resizeGrip:SetShown(show)
    if node.resizeGrip.EnableMouse then
      node.resizeGrip:EnableMouse(show)
    end
  end
end

local function paintNode(node, selected)
  showSelect(node, selected)
end

local function ensureNode(studio, widgetId)
  local node = studio.nodes[widgetId]
  if node then
    return node
  end
  local overlay = CreateFrame("Button", "ShadowUIStudioNode" .. widgetId, studio.host)
  overlay:SetFrameLevel((studio.host.GetFrameLevel and studio.host:GetFrameLevel() or 1) + 2)
  overlay:EnableMouse(true)
  local fill = overlay:CreateTexture(nil, "BACKGROUND")
  fill:SetAllPoints(overlay)
  fill:SetColorTexture(0, 0, 0, 0)
  overlay.fill = fill
  local label = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  label:SetPoint("CENTER")
  label:SetTextColor(1, 1, 1, 1)
  overlay.fontString = label
  overlay.widgetId = widgetId
  local drag
  local sizing
  local origin
  local function hostSize()
    if Addon.UnitFrameHostSize then
      return Addon:UnitFrameHostSize(studioLayout(Addon.studioFrameId or "player"))
    end
    return 232, 100
  end
  local function applyRect(left, bottom, width, height)
    local hw, hh = hostSize()
    local clamped = overlay
    if Addon.ClampWidgetRect then
      clamped = Addon:ClampWidgetRect(overlay.widgetId, {
        left = left,
        bottom = bottom,
        width = width,
        height = height,
      }, hw, hh)
    else
      clamped = { left = left, bottom = bottom, width = width, height = height }
    end
    overlay.rectLeft = clamped.left
    overlay.rectBottom = clamped.bottom
    overlay:SetSize(clamped.width, clamped.height)
    overlay:ClearAllPoints()
    overlay:SetPoint("BOTTOMLEFT", studio.host, "BOTTOMLEFT", clamped.left, clamped.bottom)
  end
  local function persist()
    Addon:PersistWidgetGeometry(Addon.studioFrameId or "player", overlay.widgetId, {
      left = overlay.rectLeft or 0,
      bottom = overlay.rectBottom or 0,
      width = overlay:GetWidth(),
      height = overlay:GetHeight(),
    })
  end
  overlay:SetScript("OnMouseDown", function(_, button)
    if button ~= "LeftButton" then
      return
    end
    Addon:SelectStudioWidget(overlay.widgetId)
    local lx, ly = cursorOn(studio.host)
    if lx == nil then
      return
    end
    drag = {
      dx = lx - (overlay.rectLeft or 0),
      dy = ly - (overlay.rectBottom or 0),
    }
  end)
  overlay:SetScript("OnMouseUp", function()
    if drag then
      drag = nil
      persist()
    elseif sizing then
      sizing = false
      persist()
    end
  end)
  overlay:SetScript("OnUpdate", function()
    if not drag and not sizing then
      return
    end
    local lx, ly = cursorOn(studio.host)
    if lx == nil then
      return
    end
    if drag then
      applyRect(lx - drag.dx, ly - drag.dy, overlay:GetWidth(), overlay:GetHeight())
      Addon:RefreshStudioInspector(overlay.widgetId)
      if overlay.widgetId == "art" then
        Addon:PaintStudioMock(overlay, "art", Addon.studioFrameId or "player")
      end
    elseif sizing and origin then
      applyRect(origin.left, origin.top - math.max(MIN_SIZE, origin.top - ly), math.max(MIN_SIZE, lx - origin.left), math.max(MIN_SIZE, origin.top - ly))
      Addon:RefreshStudioInspector(overlay.widgetId)
      if overlay.widgetId == "art" then
        Addon:PaintStudioMock(overlay, "art", Addon.studioFrameId or "player")
      end
    end
  end)
  local grip = CreateFrame("Button", nil, overlay)
  grip:SetSize(6, 6)
  grip:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT", 0, 0)
  local gripFill = grip:CreateTexture(nil, "ARTWORK")
  gripFill:SetAllPoints(grip)
  gripFill:SetColorTexture(1, 0.82, 0.1, 1)
  overlay.resizeGrip = grip
  grip:Hide()
  grip:EnableMouse(false)
  grip:SetScript("OnMouseDown", function(_, button)
    if button ~= "LeftButton" then
      return
    end
    Addon:SelectStudioWidget(overlay.widgetId)
    origin = {
      left = overlay.rectLeft or 0,
      top = (overlay.rectBottom or 0) + (overlay:GetHeight() or 0),
    }
    sizing = true
    drag = nil
  end)
  grip:SetScript("OnMouseUp", function()
    if sizing then
      sizing = false
      persist()
    end
  end)
  studio.nodes[widgetId] = overlay
  return overlay
end

function Addon:SelectStudioWidget(widgetId)
  local studio = self.unitStudio
  if not studio then
    return
  end
  self.selectedStudioWidget = widgetId
  for id, node in pairs(studio.nodes) do
    paintNode(node, id == widgetId)
  end
  self:RefreshStudioInspector(widgetId)
end

function Addon:RefreshStudioInspector(widgetId)
  local studio = self.unitStudio
  local panel = studio and studio.inspector
  if not panel then
    return
  end
  widgetId = widgetId or self.selectedStudioWidget
  if not widgetId then
    if panel.title then
      panel.title:SetText("Widget")
    end
    return
  end
  local layout = studioLayout(self.studioFrameId or "player")
  local spec = layout[widgetId] or {}
  local rects = self:ResolveWidgetRects(layout)
  local rect = rects[widgetId] or {}
  local node = studio.nodes[widgetId]
  if node then
    rect = {
      left = node.rectLeft or rect.left,
      bottom = node.rectBottom or rect.bottom,
      width = node.GetWidth and node:GetWidth() or rect.width,
      height = node.GetHeight and node:GetHeight() or rect.height,
    }
  end
  local relativeTo = spec.relativeTo or "host"
  local relative = rects[relativeTo] or rects.host
  local geometry = self:WidgetGeometryFromRect(spec, rect, relative)
  if panel.title then
    panel.title:SetText(widgetLabel(widgetId))
  end
  if panel.computed then
    panel.computed:SetText(string.format(
      "On canvas\nX %s  Y %s\nW %s  H %s",
      tostring(math.floor((rect.left or 0) + 0.5)),
      tostring(math.floor((rect.bottom or 0) + 0.5)),
      tostring(math.floor((rect.width or 0) + 0.5)),
      tostring(math.floor((rect.height or 0) + 0.5))
    ))
  end
  if panel.anchor then
    panel.anchor:SetText(string.format(
      "SetPoint\n%s → %s.%s\n%s",
      geometry.point or "TOPLEFT",
      relativeTo,
      geometry.relativePoint or "TOPLEFT",
      formatOffset(geometry.x, geometry.y)
    ))
  end
  local function setBox(box, value)
    if box and box.SetText then
      box:SetText(tostring(value or ""))
    end
  end
  setBox(panel.widthBox, math.floor((geometry.width or rect.width or 0) + 0.5))
  setBox(panel.heightBox, math.floor((geometry.height or rect.height or 0) + 0.5))
  setBox(panel.xBox, geometry.x)
  setBox(panel.yBox, geometry.y)
  setBox(panel.pointBox, geometry.point)
  setBox(panel.relativeBox, relativeTo)
  setBox(panel.relativePointBox, geometry.relativePoint)
  setBox(panel.stackBox, Addon:WidgetStack(spec, widgetId))
  panel.frameId = self.studioFrameId or "player"
  panel.widgetId = widgetId
end

function Addon:RefreshStudioGuide()
  -- Inspector shows SetPoint. The canvas does not draw anchor lines.
end

local function ensureTreeRow(studio, index)
  local row = studio.treeRows[index]
  if row then
    return row
  end
  row = CreateFrame("Button", "ShadowUIStudioTree" .. index, studio.tree)
  row:SetHeight(18)
  row:SetPoint("TOPLEFT", 6, -8 - (index - 1) * 18)
  row:SetPoint("RIGHT", -4, 0)
  local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  label:SetPoint("LEFT", 0, 0)
  label:SetJustifyH("LEFT")
  row.label = label
  row:SetScript("OnMouseUp", function()
    if row.widgetId then
      Addon:SelectStudioWidget(row.widgetId)
    end
  end)
  studio.treeRows[index] = row
  return row
end

function Addon:RefreshUnitStudio()
  local studio = self:EnsureUnitStudio()
  if not studio then
    return
  end
  local frameId = self.studioFrameId or "player"
  local layout = studioLayout(frameId)
  local rects = self:ResolveWidgetRects(layout)
  self:LayoutUnitStudioHost()
  for id, tab in pairs(studio.tabs or {}) do
    if tab.fill then
      if id == frameId then
        tab.fill:SetColorTexture(0.2, 0.45, 0.75, 1)
      else
        tab.fill:SetColorTexture(0.2, 0.2, 0.22, 1)
      end
    end
  end
  local used = {}
  for _, widgetId in ipairs(self.UNIT_WIDGET_ORDER or {}) do
    local spec = layout[widgetId]
    local rect = rects[widgetId]
    if spec and spec.enabled ~= false and rect then
      local node = ensureNode(studio, widgetId)
      node.rectLeft, node.rectBottom = rect.left, rect.bottom
      node:SetSize(rect.width, rect.height)
      node:ClearAllPoints()
      node:SetPoint("BOTTOMLEFT", studio.host, "BOTTOMLEFT", rect.left, rect.bottom)
      local hostLevel = studio.host.GetFrameLevel and studio.host:GetFrameLevel() or 1
      if node.SetFrameLevel then
        node:SetFrameLevel(hostLevel + self:WidgetStack(spec, widgetId))
      end
      self:PaintStudioMock(node, widgetId, frameId)
      node:EnableMouse(true)
      node:Show()
      paintNode(node, widgetId == self.selectedStudioWidget)
      used[widgetId] = true
    end
  end
  for widgetId, node in pairs(studio.nodes) do
    if not used[widgetId] then
      node:Hide()
    end
  end
  local row = 0
  local listed = {}
  for _, widgetId in ipairs(self.UNIT_WIDGET_ORDER or {}) do
    if used[widgetId] then
      listed[#listed + 1] = widgetId
    end
  end
  table.sort(listed, function(a, b)
    local sa = Addon:WidgetStack(layout[a], a)
    local sb = Addon:WidgetStack(layout[b], b)
    if sa ~= sb then
      return sa > sb
    end
    return a < b
  end)
  for _, widgetId in ipairs(listed) do
    row = row + 1
    local button = ensureTreeRow(studio, row)
    button.widgetId = widgetId
    if button.label then
      button.label:SetText(tostring(Addon:WidgetStack(layout[widgetId], widgetId)) .. "  " .. widgetLabel(widgetId))
    end
    button:Show()
  end
  for i = row + 1, #(studio.treeRows or {}) do
    studio.treeRows[i]:Hide()
    studio.treeRows[i].widgetId = nil
  end
  if self.selectedStudioWidget then
    self:RefreshStudioInspector(self.selectedStudioWidget)
  end
  if studio.frame and studio.frame.Show then
    studio.frame:Show()
  end
  return studio
end

local function selectedSpec(self)
  local widgetId = self.selectedStudioWidget
  if not widgetId then
    return
  end
  local layout = studioLayout(self.studioFrameId or "player")
  return layout[widgetId], widgetId, layout
end

function Addon:SetSelectedWidgetOffset(x, y)
  local spec, widgetId = selectedSpec(self)
  if not spec then
    return
  end
  self:WriteProfileDelta("layout", self.studioFrameId or "player", {
    [widgetId] = { x = tonumber(x) or 0, y = tonumber(y) or 0 },
  })
  self:RefreshUnitStudio()
end

function Addon:SetSelectedWidgetSize(width, height)
  local spec, widgetId = selectedSpec(self)
  if not spec then
    return
  end
  self:WriteProfileDelta("layout", self.studioFrameId or "player", {
    [widgetId] = {
      width = math.max(MIN_SIZE, tonumber(width) or MIN_SIZE),
      height = math.max(MIN_SIZE, tonumber(height) or MIN_SIZE),
    },
  })
  self:RefreshUnitStudio()
end

function Addon:SetSelectedWidgetAnchor(point, relativeTo, relativePoint)
  local spec, widgetId, layout = selectedSpec(self)
  if not spec or widgetId == "art" then
    return
  end
  point = self:NormalizeAnchorPoint(point or spec.point)
  relativePoint = self:NormalizeAnchorPoint(relativePoint or spec.relativePoint or point)
  if relativeTo == "" or relativeTo == "host" then
    relativeTo = nil
  elseif relativeTo and not (self.UNIT_WIDGET_KIND or {})[relativeTo] then
    relativeTo = spec.relativeTo
  end
  local rects = self:ResolveWidgetRects(layout)
  local child = rects[widgetId]
  local relative = relativeTo and rects[relativeTo] or rects.host
  local nextSpec = {
    point = point,
    relativePoint = relativePoint,
    relativeTo = relativeTo,
    width = spec.width,
    height = spec.height,
  }
  local geometry = child and relative and self:WidgetGeometryFromRect(nextSpec, child, relative) or nextSpec
  if not geometry.relativeTo then
    geometry.relativeTo = false
  end
  self:WriteProfileDelta("layout", self.studioFrameId or "player", { [widgetId] = geometry })
  self:RefreshUnitStudio()
end

function Addon:CommitWidgetInspector()
  local panel = self.widgetInspector
  if not panel or not panel.widgetId then
    return
  end
  local function read(box)
    if box and box.GetText then
      return box:GetText()
    end
    return box and box.text
  end
  self.studioFrameId = panel.frameId or self.studioFrameId or "player"
  self.selectedStudioWidget = panel.widgetId
  local spec = select(1, selectedSpec(self)) or {}
  local point, relativeTo, relativePoint = read(panel.pointBox), read(panel.relativeBox), read(panel.relativePointBox)
  local currentRel = spec.relativeTo or "host"
  if (point and point ~= spec.point)
    or (relativePoint and relativePoint ~= (spec.relativePoint or spec.point))
    or (relativeTo and relativeTo ~= currentRel)
  then
    self:SetSelectedWidgetAnchor(point, relativeTo, relativePoint)
  end
  self:SetSelectedWidgetSize(read(panel.widthBox), read(panel.heightBox))
  self:SetSelectedWidgetOffset(read(panel.xBox), read(panel.yBox))
  local stack = tonumber(read(panel.stackBox))
  if stack and Addon.NudgeWidgetStack then
    local current = Addon:WidgetStack(spec, panel.widgetId)
    Addon:NudgeWidgetStack(self.studioFrameId or "player", panel.widgetId, stack - current)
  end
end

function Addon:OpenUnitFrameDesigner()
  self.studioFrameId = self.studioFrameId or "player"
  if self.OpenOptions then
    self:OpenOptions()
  end
  local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
  if AceConfigDialog and AceConfigDialog.SelectGroup then
    AceConfigDialog:SelectGroup("ShadowUI", "unitFrames")
  end
  self:RefreshUnitStudio()
end

local AceGUI = LibStub("AceGUI-3.0", true)
if AceGUI and AceGUI.RegisterWidgetType then
  local Type, Version = "ShadowUI-UnitStudio", 3
  local function Constructor()
    local widget = { type = Type }
    local studio = Addon:EnsureUnitStudio(UIParent)
    widget.frame = studio and studio.frame or CreateFrame("Frame", nil, UIParent)
    widget.frame:SetHeight(420)
    function widget:OnWidthSet()
      Addon:LayoutUnitStudioHost()
    end
    function widget:OnHeightSet()
      Addon:LayoutUnitStudioHost()
    end
    function widget:OnAcquire()
      if widget.SetFullWidth then
        widget:SetFullWidth(true)
      end
      if widget.SetHeight then
        widget:SetHeight(420)
      else
        widget.frame:SetHeight(420)
      end
      Addon:RefreshUnitStudio()
      if widget.frame.Show then
        widget.frame:Show()
      end
    end
    function widget:OnRelease()
      if widget.frame.Hide then
        widget.frame:Hide()
      end
    end
    function widget:SetLabel() end
    function widget:SetText() end
    function widget:SetDisabled() end
    return AceGUI:RegisterAsWidget(widget)
  end
  AceGUI:RegisterWidgetType(Type, Constructor, Version)
end
