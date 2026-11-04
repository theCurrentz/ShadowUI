--[[
  Purpose: Create LibActionButton action buttons with Action Slot Lock and Lorti-dark icon chrome.
           Skin Forever Blizzard ActionButtons lightly: the icon, IconMask, cooldowns,
           hover and checked glows, Flash, equipped Border, and spell alerts stay native.
           Only the slot rim is blackened and the empty-slot art dimmed, under an Outer Edge.
           An Action Slot with no spell, macro, or item stays hidden, including the Keybind
           label. A pickup or ACTIONBAR_SHOWGRID still shows empty slots as drop targets
           and shows every Keybind. Keybind Edit Mode hides slot Keybind labels unless
           a pickup is active. Forever Blizzard ActionButtons follow the host show state
           instead of HasAction. Do not write Blizzard keys (icon, HotKey, Count) on
           those hosts: Blizzard Update reads them, and taint there stops the drag
           grid from showing empty slots, so a drop clicks through.
           Shift+Alt drag inserts the action and Keybind. Pressed LAB slots show a green
           colour overlay on key down and click down. The overlay snaps off on up.
           A player cast or channel on that Action Slot keeps the overlay until it
           completes. The icon size does not change. Macro names stay hidden.
           Keybind labels are gold thick-outlined uppercase text. Item counts are
           pale lime outlined text inset inside the Action Slot.
  Deps: ShadowUI addon table, LibActionButton-1.0, ShadowUI:ApplyOuterChrome(),
        ShadowUI:LockVertex()
  Public: ShadowUI:CreateBarButton(parent, id, actionSlot), ShadowUI:SkinBarButton(),
          ShadowUI:ShouldShowEmptyActionSlots(), ShadowUI:PaintEmptySlotVisibility(),
          ShadowUI:RefreshActionPlacement(), ShadowUI:OnActionBarShowGrid(),
          ShadowUI:OnActionBarHideGrid(), ShadowUI:OnCursorChanged(),
          ShadowUI:LockBarButton(), ShadowUI:ApplyActionSlotLock(),
          ShadowUI:SetActionSlotHardLock(),
          ShadowUI:PressGlowAlpha(), ShadowUI:PressGlowIsActive(),
          ShadowUI:ActionSlotSpellID(), ShadowUI:OnPressCastEvent(),
          ShadowUI:ShowPressGlow(), ShadowUI:HidePressGlow(),
          ShadowUI:ClearPressGlow(), ShadowUI:PlayPressGlow(),
          ShadowUI:BindingKeyIsDown()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local LAB = LibStub("LibActionButton-1.0", true)
-- Crop rounded LAB icon art. 0.07 keeps the square fill without over-zoom.
local CROP = 0.07
local INSET = 2
local HOVER_ALPHA = 0.22
-- Colour overlay only. Do not inset the icon: a push-in can stick after
-- AnyDown clicks, and it is a weak press cue. Snap off on up. A cast keeps
-- the overlay until STOP.
local PRESS_R, PRESS_G, PRESS_B, PRESS_A = 0.35, 1.0, 0.45, 0.40
local PRESS_INSET = 4
local PRESS_CAST_BEGIN = {
  UNIT_SPELLCAST_START = true,
  UNIT_SPELLCAST_CHANNEL_START = true,
}
local PRESS_CAST_END = {
  UNIT_SPELLCAST_STOP = true,
  UNIT_SPELLCAST_FAILED = true,
  UNIT_SPELLCAST_INTERRUPTED = true,
  UNIT_SPELLCAST_CHANNEL_STOP = true,
}
-- Gold Keybind labels. Gray LAB defaults are hard to read on Darken icons.
local SLOT_LABEL_GOLD = { 1, 0.82, 0, 1 }
local SLOT_LABEL_LIME = { 0.7, 0.88, 0.55, 0.75 }
local HOTKEY_SIZE = 16
local HOTKEY_FLAGS = "THICKOUTLINE"
local COUNT_SIZE = 15
local COUNT_OFFSET_X = -3
local COUNT_OFFSET_Y = 3
local MOUSE_BUTTONS = {
  "LeftButton", "RightButton", "MiddleButton", "Button4", "Button5",
}

function Addon:PressGlowAlpha(elapsed, duration)
  duration = duration or 0
  if not elapsed or elapsed < 0 or duration <= 0 then
    return 0
  end
  if elapsed >= duration then
    return 0
  end
  return PRESS_A * (1 - elapsed / duration)
end

function Addon:BindingKeyIsDown(key)
  if type(key) ~= "string" or key == "" then
    return false
  end
  local rest = key:match("([^-]+)$") or key
  local mouseIndex = tonumber(rest:match("^BUTTON(%d+)$"))
  if mouseIndex then
    local mouse = MOUSE_BUTTONS[mouseIndex]
    return mouse and IsMouseButtonDown and IsMouseButtonDown(mouse) and true or false
  end
  if not IsKeyDown then
    return false
  end
  local ok, down = pcall(IsKeyDown, rest)
  return ok and down and true or false
end

function Addon:ActionSlotSpellID(button)
  -- GetActionInfo is secret on Forever while this addon is tainted.
  return button and button.shadowUISpellID or nil
end

function Addon:PressGlowIsActive(button, now)
  if not button then
    return false
  end
  if button.shadowUIPressCast then
    return true
  end
  if button.shadowUIPressHeld then
    return true
  end
  if self:BindingKeyIsDown(button.shadowUIBindingKey) then
    return true
  end
  return false
end

local function ensurePressGlow(button)
  local glow = button.shadowUIPressGlow
  if glow or not button.CreateTexture then
    return glow
  end
  glow = button:CreateTexture(nil, "OVERLAY", nil, 6)
  button.shadowUIPressGlow = glow
  if glow.ClearAllPoints then
    glow:ClearAllPoints()
  end
  if glow.SetPoint then
    glow:SetPoint("TOPLEFT", PRESS_INSET, -PRESS_INSET)
    glow:SetPoint("BOTTOMRIGHT", -PRESS_INSET, PRESS_INSET)
  elseif glow.SetAllPoints then
    glow:SetAllPoints(button)
  end
  if glow.SetColorTexture then
    glow:SetColorTexture(PRESS_R, PRESS_G, PRESS_B, PRESS_A)
  end
  if glow.SetBlendMode then
    glow:SetBlendMode("ADD")
  end
  if glow.Hide then
    glow:Hide()
  end
  -- Glow is created on first press, after the last SkinBarButton. Re-apply
  -- the host shape so Extra Action keeps circle chrome.
  if Addon.ApplyIconShape then
    Addon:ApplyIconShape(button, button.shadowUIShape or "square")
  end
  return glow
end

-- Textures have SetScript on Classic but reject OnUpdate. Drive the fade
-- from a child Frame so the overlay stays a Texture.
local function ensurePressWatch(button)
  local watch = button.shadowUIPressWatch
  if watch then
    return watch
  end
  if not CreateFrame then
    return nil
  end
  watch = CreateFrame("Frame", nil, button)
  button.shadowUIPressWatch = watch
  if watch.EnableMouse then
    watch:EnableMouse(false)
  end
  if watch.SetAllPoints then
    watch:SetAllPoints(button)
  end
  return watch
end

local function stopPressWatch(watch)
  if watch and watch.SetScript then
    watch:SetScript("OnUpdate", nil)
  end
end

local function mouseButtonIsDown()
  if type(IsMouseButtonDown) ~= "function" then
    return nil
  end
  for i = 1, #MOUSE_BUTTONS do
    if IsMouseButtonDown(MOUSE_BUTTONS[i]) then
      return true
    end
  end
  return false
end

local function releaseHeldIfMouseUp(button)
  if not button.shadowUIPressHeld then
    return
  end
  if mouseButtonIsDown() == false then
    button.shadowUIPressHeld = nil
  end
end

local function eachActionButton(callback)
  for _, bar in pairs(Addon.bars or {}) do
    for _, btn in ipairs(bar.buttons or {}) do
      callback(btn)
    end
  end
end

local function playerIsBusy()
  if UnitCastingInfo and UnitCastingInfo("player") then
    return true
  end
  if UnitChannelInfo and UnitChannelInfo("player") then
    return true
  end
  return false
end

local function slotMatchesSpell(button, spellID)
  if type(spellID) ~= "number" then
    return true
  end
  local id = Addon:ActionSlotSpellID(button)
  if type(id) ~= "number" then
    return true
  end
  return id == spellID
end

local function snapHideGlow(button, glow)
  stopPressWatch(button.shadowUIPressWatch)
  if not glow then
    return
  end
  glow.shadowUIFadeFrom = nil
  if glow.SetAlpha then
    glow:SetAlpha(0)
  end
  if glow.Hide then
    glow:Hide()
  end
end

local function watchPressGlow(button, glow)
  local watch = ensurePressWatch(button)
  if not glow or not watch or not watch.SetScript then
    return
  end
  watch:SetScript("OnUpdate", function(self)
    releaseHeldIfMouseUp(button)
    if Addon:PressGlowIsActive(button) then
      if glow.SetAlpha then
        glow:SetAlpha(PRESS_A)
      end
      if glow.Show then
        glow:Show()
      end
      return
    end
    snapHideGlow(button, glow)
  end)
end

function Addon:ShowPressGlow(button)
  if not button then
    return
  end
  local glow = ensurePressGlow(button)
  if not glow then
    return
  end
  Addon.pressGlowButton = button
  if glow.SetAlpha then
    glow:SetAlpha(PRESS_A)
  end
  if glow.Show then
    glow:Show()
  end
  watchPressGlow(button, glow)
end

function Addon:HidePressGlow(button, opts)
  if not button then
    return
  end
  opts = opts or {}
  button.shadowUIPressHeld = nil
  if opts.clearCast then
    button.shadowUIPressCast = nil
  end
  local glow = button.shadowUIPressGlow
  if Addon:PressGlowIsActive(button) then
    if glow then
      watchPressGlow(button, glow)
    end
    return
  end
  snapHideGlow(button, glow)
end

function Addon:ClearPressGlow(button)
  if not button then
    return
  end
  button.shadowUIPressHeld = nil
  button.shadowUIPressCast = nil
  if Addon.pressGlowButton == button then
    Addon.pressGlowButton = nil
  end
  snapHideGlow(button, button.shadowUIPressGlow)
end

function Addon:PlayPressGlow(button)
  self:ShowPressGlow(button)
end

local function latchPressCast(button, spellID)
  if not button or not slotMatchesSpell(button, spellID) then
    return
  end
  button.shadowUIPressCast = true
  Addon:ShowPressGlow(button)
end

local function releasePressCast(spellID, immediate)
  eachActionButton(function(btn)
    if not btn.shadowUIPressCast then
      return
    end
    if spellID and not slotMatchesSpell(btn, spellID) then
      return
    end
    Addon:HidePressGlow(btn, { clearCast = true, immediate = immediate ~= false })
  end)
end

function Addon:OnPressCastEvent(event, unit, ...)
  if unit ~= "player" then
    return
  end
  local spellID
  if event == "UNIT_SPELLCAST_SENT" then
    spellID = select(3, ...)
  else
    spellID = select(2, ...)
  end
  if type(spellID) ~= "number" then
    spellID = nil
  end
  if PRESS_CAST_BEGIN[event] then
    local pending = self.pressGlowButton
    if pending then
      latchPressCast(pending, spellID)
    else
      eachActionButton(function(btn)
        if self:PressGlowIsActive(btn) then
          latchPressCast(btn, spellID)
        end
      end)
    end
    return
  end
  if event == "UNIT_SPELLCAST_SUCCEEDED" then
    if playerIsBusy() then
      return
    end
    releasePressCast(spellID, true)
    return
  end
  if PRESS_CAST_END[event] then
    releasePressCast(spellID, true)
  end
end

local function hookPressGlow(button)
  if button._shadowUIPressHook or not button.HookScript then
    return
  end
  button._shadowUIPressHook = true
  button:HookScript("OnMouseDown", function()
    button.shadowUIPressHeld = true
    Addon:ShowPressGlow(button)
  end)
  button:HookScript("OnMouseUp", function()
    Addon:HidePressGlow(button)
  end)
  button:HookScript("OnHide", function()
    Addon:ClearPressGlow(button)
  end)
  button:HookScript("OnClick", function()
    Addon:ShowPressGlow(button)
  end)
end

local CONFIG = {
  outOfRangeColoring = "button",
  showGrid = false,
  colors = {
    range = { 0.8, 0.1, 0.1 },
    mana = { 0.5, 0.5, 1 },
  },
  hideElements = {
    border = true,
    borderIfEmpty = true,
    equipped = true,
    macro = true,
  },
  masqueSkinned = true,
  text = {
    hotkey = {
      font = {
        size = HOTKEY_SIZE,
        flags = HOTKEY_FLAGS,
      },
      color = { SLOT_LABEL_GOLD[1], SLOT_LABEL_GOLD[2], SLOT_LABEL_GOLD[3] },
      position = {
        anchor = "TOPRIGHT",
        relAnchor = "TOPRIGHT",
        offsetX = -2,
        offsetY = -3,
      },
      justifyH = "RIGHT",
    },
    count = {
      font = {
        size = COUNT_SIZE,
        flags = "OUTLINE",
      },
      color = {
        SLOT_LABEL_LIME[1], SLOT_LABEL_LIME[2], SLOT_LABEL_LIME[3], SLOT_LABEL_LIME[4],
      },
      position = {
        anchor = "BOTTOMRIGHT",
        relAnchor = "BOTTOMRIGHT",
        offsetX = COUNT_OFFSET_X,
        offsetY = COUNT_OFFSET_Y,
      },
      justifyH = "RIGHT",
    },
  },
}

local function strip(texture)
  if not texture then
    return
  end
  pcall(texture.SetTexture, texture, "")
  texture:SetAlpha(0)
  texture:Hide()
end

local function flatten(button, texture, r, g, b, a, blend)
  if not texture then
    return
  end
  texture:SetTexture("Interface\\Buttons\\WHITE8X8")
  texture:SetVertexColor(r, g, b, a)
  texture:SetBlendMode(blend or "ADD")
  texture:ClearAllPoints()
  texture:SetAllPoints(button)
  texture:SetAlpha(a)
end

local function inset(region)
  if not region then
    return
  end
  region:ClearAllPoints()
  region:SetPoint("TOPLEFT", INSET, -INSET)
  region:SetPoint("BOTTOMRIGHT", -INSET, INSET)
end

local function skinCooldown(button)
  local cooldown = button.cooldown
  if not cooldown or button.shadowUICooldownSkinned then
    return
  end
  button.shadowUICooldownSkinned = true
  inset(cooldown)
  if cooldown.SetDrawSwipe then
    cooldown:SetDrawSwipe(true)
  end
  if cooldown.SetSwipeColor then
    cooldown:SetSwipeColor(0, 0, 0, 0.8)
  end
  if cooldown.SetDrawEdge then
    cooldown:SetDrawEdge(true)
  end
  if cooldown.SetDrawBling then
    cooldown:SetDrawBling(true)
  end
  if button.GetFrameLevel and cooldown.SetFrameLevel then
    cooldown:SetFrameLevel(button:GetFrameLevel() + 1)
  end
end

local function paintSlotLabel(fs, size, color, flags)
  if not fs then
    return
  end
  local path = _G.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
  if fs.GetFont then
    path = fs:GetFont() or path
  end
  if fs.SetFont and path then
    fs:SetFont(path, size, flags or "OUTLINE")
  end
  local r, g, b, a = color[1], color[2], color[3], color[4] or 1
  if fs.SetTextColor then
    fs:SetTextColor(r, g, b, a)
  end
  if fs.SetVertexColor then
    fs:SetVertexColor(r, g, b, a)
  end
  if fs.SetShadowOffset then
    fs:SetShadowOffset(1, -1)
  end
  if fs.SetShadowColor then
    fs:SetShadowColor(0, 0, 0, 1)
  end
end

local function paintCountLabel(fs)
  paintSlotLabel(fs, COUNT_SIZE, SLOT_LABEL_LIME)
  if not fs then
    return
  end
  if fs.ClearAllPoints then
    fs:ClearAllPoints()
  end
  if fs.SetPoint then
    fs:SetPoint("BOTTOMRIGHT", COUNT_OFFSET_X, COUNT_OFFSET_Y)
  end
end

local function hideButtonChrome(button)
  if button.shadowUIChrome and button.shadowUIChrome.Hide then
    button.shadowUIChrome:Hide()
  end
  if button.shadowUIOuter and button.shadowUIOuter.Hide then
    button.shadowUIOuter:Hide()
  end
end

local function paintChrome(button)
  local chrome = button.shadowUIChrome
  if not chrome and button.CreateTexture then
    chrome = button:CreateTexture(nil, "BACKGROUND", nil, -8)
    button.shadowUIChrome = chrome
  end
  if not chrome then
    return
  end
  chrome:ClearAllPoints()
  chrome:SetAllPoints(button)
  local black = Addon.DARKEN_BLACK or { 0.05, 0.05, 0.05 }
  chrome:SetColorTexture(black[1], black[2], black[3], 1)
  chrome:Show()
end

local function buttonName(button)
  local name = button and button.GetName and button:GetName()
  if type(name) ~= "string" then
    return nil
  end
  return name
end

local function isDefaultActionButton(button)
  local name = buttonName(button)
  if not name then
    return false
  end
  return name:find("^ActionButton%d+$")
    or name:find("^MultiBar")
    or name:find("^PetActionButton")
    or name:find("^StanceButton")
    or name:find("^ShapeshiftButton")
    or name:find("^BonusActionButton")
    or name:find("^PossessButton")
    or name:find("^OverrideActionButton")
    or name:find("^OverrideActionBarButton")
    or name:find("^ExtraActionButton")
end

local function placeActionOuter(button, outer)
  if not outer then
    return
  end
  local parent = button.GetParent and button:GetParent()
  if parent and outer.SetParent then
    outer:SetParent(parent)
  end
  if not isDefaultActionButton(button) and button.SetClipsChildren then
    button:SetClipsChildren(false)
  end
  if button.GetFrameLevel and outer.SetFrameLevel then
    local level = button:GetFrameLevel()
    if level > 0 then
      outer:SetFrameLevel(level - 1)
    end
  end
  Addon:PaintOuterChrome(outer)
end

local function slotHasAction(button)
  if isDefaultActionButton(button) then
    return true
  end
  if not button.HasAction then
    return true
  end
  return button:HasAction() and true or false
end

-- Forever forbids HasAction on default ActionButtons. Blizzard already hides
-- an empty slot (or its icon) when Always Show is off. Read that show state.
local function defaultActionSlotIsFilled(button)
  if button.IsShown and not button:IsShown() then
    return false
  end
  local icon = button.icon or button.Icon
  if icon and icon.IsShown and not icon:IsShown() then
    return false
  end
  return true
end

local function cursorHasPickup()
  if not GetCursorInfo then
    return false
  end
  local kind = GetCursorInfo()
  return kind ~= nil and kind ~= ""
end

function Addon:ShouldShowEmptyActionSlots()
  if self.keybindMode == true then
    return true
  end
  if self.IsActionSlotPickup then
    return self:IsActionSlotPickup()
  end
  if (self.actionBarGridCount or 0) > 0 then
    return true
  end
  return cursorHasPickup()
end

local function showEmptyActionSlot()
  return Addon:ShouldShowEmptyActionSlots()
end

local function paintOuterEdge(button)
  local outer = Addon:ApplyOuterChrome(button, "square")
  placeActionOuter(button, outer)
  if outer and outer.Show then
    outer:Show()
  end
end

local function paintSlotChrome(button)
  paintChrome(button)
  if Addon.ApplyIconShape then
    Addon:ApplyIconShape(button, "square")
  end
  paintOuterEdge(button)
end

local function paintHotkeyVisibility(button, filled)
  local hotkey = button.HotKey
  if not hotkey and button.GetName then
    hotkey = _G[button:GetName() .. "HotKey"]
    if not isDefaultActionButton(button) then
      button.HotKey = hotkey
    end
  end
  if not hotkey then
    return
  end
  local show
  if Addon.ShouldShowActionSlotKeybind then
    show = Addon:ShouldShowActionSlotKeybind(filled) == true
  else
    show = filled == true and Addon.keybindMode ~= true
  end
  if show and not isDefaultActionButton(button) and not button.shadowUIHotkey then
    show = false
  end
  if show then
    if hotkey.Show then
      hotkey:Show()
    end
    return
  end
  if hotkey.Hide then
    hotkey:Hide()
  end
end

function Addon:PaintEmptySlotVisibility(button)
  if not button then
    return
  end
  local showEmpty = showEmptyActionSlot()
  if isDefaultActionButton(button) then
    local filled = defaultActionSlotIsFilled(button)
    if filled or showEmpty then
      paintOuterEdge(button)
    else
      hideButtonChrome(button)
    end
    paintHotkeyVisibility(button, filled)
    return
  end
  local filled = slotHasAction(button)
  local visible = filled or showEmpty
  if button.SetAlpha then
    button:SetAlpha(visible and 1 or 0)
  end
  if visible then
    paintSlotChrome(button)
  else
    hideButtonChrome(button)
    Addon:ClearPressGlow(button)
  end
  paintHotkeyVisibility(button, filled)
end

function Addon:RefreshActionPlacement()
  if self.ShowBarsForActionPlacement then
    self:ShowBarsForActionPlacement(self:ShouldShowEmptyActionSlots())
  end
  if self.SkinBlizzardActionBars then
    self:SkinBlizzardActionBars()
  end
  for _, bar in pairs(self.bars or {}) do
    for _, button in ipairs(bar.buttons or {}) do
      self:SkinBarButton(button)
    end
  end
end

function Addon:OnActionBarShowGrid()
  self.actionBarGridCount = (self.actionBarGridCount or 0) + 1
  self:RefreshActionPlacement()
  if self.WakeFadeDriver then
    self:WakeFadeDriver()
  end
end

function Addon:OnActionBarHideGrid()
  local count = self.actionBarGridCount or 0
  if count > 0 then
    count = count - 1
  end
  self.actionBarGridCount = count
  self:RefreshActionPlacement()
  if self.WakeFadeDriver then
    self:WakeFadeDriver()
  end
end

function Addon:OnCursorChanged()
  self:RefreshActionPlacement()
  if self.ClearSlotShiftFrom and not cursorHasPickup() then
    self:ClearSlotShiftFrom()
  end
  if self.WakeFadeDriver then
    self:WakeFadeDriver()
  end
end

local function hideMacroName(button)
  local name = button.Name
  if not name and button.GetName then
    name = _G[button:GetName() .. "Name"]
  end
  if not name then
    return
  end
  if name.SetText then
    name:SetText("")
  end
  if name.Hide then
    name:Hide()
  end
end

-- Only the rim and the empty-slot art. The icon, IconMask, glows, Flash,
-- Border, and spell alerts carry Blizzard feedback and stay native.
-- FloatingBG and NormalTexture2 match DarkMode Forever slot chrome.
local function darkenDefaultArt(button)
  if not Addon.LockVertex then
    return
  end
  local rim, well = Addon.DARKEN_BLACK, Addon.DARKEN_BAR
  local name = buttonName(button)
  Addon:LockVertex(button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture()), rim)
  Addon:LockVertex(button.PushedTexture or (button.GetPushedTexture and button:GetPushedTexture()), rim)
  Addon:LockVertex(button.SlotArt, well)
  Addon:LockVertex(button.SlotBackground, well)
  local floating = button.FloatingBG
  if not floating and name then
    floating = _G[name .. "FloatingBG"]
  end
  Addon:LockVertex(floating, rim)
  if name then
    Addon:LockVertex(_G[name .. "NormalTexture2"], rim)
  end
end

-- HookScript, SetPoint, and SetScript on default ActionButtons and their
-- cooldown frames raise ADDON_ACTION_FORBIDDEN. Cooldown times are secret.
local function skinDefaultButton(button)
  Addon:PaintEmptySlotVisibility(button)
  darkenDefaultArt(button)
  hideMacroName(button)
  paintSlotLabel(button.HotKey, HOTKEY_SIZE, SLOT_LABEL_GOLD, HOTKEY_FLAGS)
  local count = button.Count
  if not count and button.GetName then
    count = _G[button:GetName() .. "Count"]
  end
  paintCountLabel(count)
end

function Addon:SkinBarButton(button)
  if isDefaultActionButton(button) then
    skinDefaultButton(button)
    return
  end
  local icon = button.icon or button.Icon
  if not icon and button.GetName then
    icon = _G[button:GetName() .. "Icon"]
    button.icon = icon
  end
  self:PaintEmptySlotVisibility(button)
  strip(button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture()))
  strip(button.Border)
  strip(button.SlotBackground)
  strip(button.Flash)
  strip(button.FloatingBG)
  strip(button.IconBorder)
  flatten(button, button.CheckedTexture or (button.GetCheckedTexture and button:GetCheckedTexture()), 1, 0.82, 0.25, 0.22)
  local hover = button.HighlightTexture or (button.GetHighlightTexture and button:GetHighlightTexture())
  local pressed = button.PushedTexture or (button.GetPushedTexture and button:GetPushedTexture())
  flatten(button, hover, 0, 0, 0, HOVER_ALPHA, "BLEND")
  strip(pressed)
  inset(hover)

  hideMacroName(button)
  paintSlotLabel(button.HotKey, HOTKEY_SIZE, SLOT_LABEL_GOLD, HOTKEY_FLAGS)
  local count = button.Count
  if not count and button.GetName then
    count = _G[button:GetName() .. "Count"]
    button.Count = count
  end
  paintCountLabel(count)

  icon = button.icon or button.Icon or icon
  if icon then
    if button.IconMask and icon.RemoveMaskTexture then
      pcall(icon.RemoveMaskTexture, icon, button.IconMask)
    end
    inset(icon)
    icon:SetTexCoord(CROP, 1 - CROP, CROP, 1 - CROP)
    if icon.SetDrawLayer then
      icon:SetDrawLayer("ARTWORK", 0)
    end
  end
  if self.ApplyIconShape then
    self:ApplyIconShape(button, "square")
  end
  hookPressGlow(button)
  skinCooldown(button)
end

if LAB and LAB.RegisterCallback then
  LAB.RegisterCallback("ShadowUI", "OnButtonUpdate", function(_, button)
    Addon:SkinBarButton(button)
  end)
end

function Addon:LockBarButton(button)
  if not button or isDefaultActionButton(button) then
    return
  end
  -- buttonlock: click uses the action. Drag needs IsModifiedClick("PICKUPACTION")
  -- (Shift by default) and must not fire the action.
  button:SetAttribute("buttonlock", true)
  button:SetAttribute("useOnKeyDown", true)
  -- AnyDown+AnyUp would use the action twice on Classic. Prefer down only.
  if not pcall(button.RegisterForClicks, button, "AnyDown") then
    button:RegisterForClicks("AnyUp")
  end
  local char = self.GetCharDB and self:GetCharDB()
  local hard = char and char.hardLockActionSlots == true
  if button.DisableDragNDrop then
    button:DisableDragNDrop(hard)
  else
    button:SetAttribute("LABdisableDragNDrop", hard or nil)
  end
end

function Addon:ApplyActionSlotLock()
  if InCombatLockdown() then
    self.pendingApplyAll = true
    return
  end
  for _, bar in pairs(self.bars or {}) do
    for _, button in ipairs(bar.buttons or {}) do
      self:LockBarButton(button)
    end
  end
end

function Addon:SetActionSlotHardLock(locked)
  local char = self:GetCharDB()
  char.hardLockActionSlots = locked and true or false
  self:ApplyActionSlotLock()
end

function Addon:CreateBarButton(parent, id, actionSlot)
  if not LAB then
    return nil
  end
  local name = "ShadowUIActionButton" .. id
  local button = LAB:CreateButton(id, name, parent, CONFIG)
  button.MasqueSkinned = true
  self:SkinBarButton(button)
  button:SetState(0, "action", actionSlot)
  self:LockBarButton(button)
  if self.HookButtonForKeybinds then
    self:HookButtonForKeybinds(button)
  end
  if self.HookButtonForSlotShift then
    self:HookButtonForSlotShift(button)
  end
  return button
end
