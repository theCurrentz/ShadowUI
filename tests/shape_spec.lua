-- Two Bars can use two icon shapes. Micro Cluster shape is independent.
-- Stance buttons stay square. Circle and diamond use CreateMaskTexture plus
-- AddMaskTexture and a matching Outer Edge drop. Press glow uses a mask
-- sized to the 4px inset. A drawable CreateTexture overlay is not a mask.
-- Square keeps the 9-slice outer_shadow. Roundrect chrome uses a 2:1 drop.
-- Run: lua tests/shape_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function(name)
  if name == "LibActionButton-1.0" then
    return { RegisterCallback = function() end }
  end
  return { GetAddon = function() return Addon end }
end
_G.hooksecurefunc = function(object, method, fn)
  local orig = object[method]
  object[method] = function(self, ...)
    orig(self, ...)
    fn(self, ...)
  end
end
_G.InCombatLockdown = function() return false end
_G.UIParent = { name = "UIParent" }

_G.CreateFrame = function(_, _, parent, template)
  local frame = {
    parent = parent,
    template = template,
    points = {},
    shown = true,
    masks = {},
  }
  function frame:ClearAllPoints() self.points = {} end
  function frame:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function frame:SetFrameLevel(level) self.level = level end
  function frame:GetFrameLevel() return self.level or 4 end
  function frame:SetBackdrop(spec) self.backdrop = spec end
  function frame:SetBackdropColor(r, g, b, a) self.fill = { r, g, b, a } end
  function frame:SetBackdropBorderColor(r, g, b, a) self.border = { r, g, b, a } end
  function frame:SetParent(p) self.parent = p end
  function frame:Show() self.shown = true end
  function frame:Hide() self.shown = false end
  function frame:CreateTexture()
    local tex = { points = {}, masks = {} }
    function tex:SetTexture(file) self.file = file end
    function tex:SetAllPoints(target) self.all = target end
    function tex:SetVertexColor(r, g, b, a)
      self.r, self.g, self.b, self.a = r, g, b, a
    end
    function tex:Show() self.shown = true end
    function tex:Hide() self.shown = false end
    function tex:AddMaskTexture(mask)
      self.masks[#self.masks + 1] = mask
    end
    function tex:RemoveMaskTexture(mask)
      for i = #self.masks, 1, -1 do
        if self.masks[i] == mask then
          table.remove(self.masks, i)
        end
      end
    end
    return tex
  end
  return frame
end

local function fakeTex()
  local tex = { points = {}, masks = {}, r = 1, g = 1, b = 1, objectType = "Texture" }
  function tex:IsObjectType(kind) return kind == self.objectType end
  function tex:SetTexture(file, hWrap, vWrap)
    self.file = file
    self.hWrap = hWrap
    self.vWrap = vWrap
  end
  function tex:SetAlpha(a) self.a = a end
  function tex:Hide() self.hidden = true end
  function tex:Show() self.hidden = false end
  function tex:SetVertexColor(r, g, b, a)
    self.r, self.g, self.b = r, g, b
    if a then self.a = a end
  end
  function tex:SetColorTexture(r, g, b, a)
    self.r, self.g, self.b, self.a = r, g, b, a
  end
  function tex:ClearAllPoints() self.points = {} end
  function tex:SetAllPoints(frame) self.all = frame end
  function tex:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function tex:SetTexCoord(l, r, t, b) self.crop = { l, r, t, b } end
  function tex:SetDrawLayer() end
  function tex:SetBlendMode() end
  function tex:SetMask(path) self.setMask = path end
  function tex:AddMaskTexture(mask)
    if not mask or not mask.IsObjectType or not mask:IsObjectType("MaskTexture") then
      error("AddMaskTexture(): maskTexture must be a MaskTexture")
    end
    for i = 1, #self.masks do
      if self.masks[i] == mask then
        error("AddMaskTexture(): mask already applied")
      end
    end
    self.masks[#self.masks + 1] = mask
  end
  function tex:RemoveMaskTexture(mask)
    for i = #self.masks, 1, -1 do
      if self.masks[i] == mask then
        table.remove(self.masks, i)
      end
    end
  end
  return tex
end

local function fakeButton(parent)
  local button = {
    icon = fakeTex(),
    NormalTexture = fakeTex(),
    HighlightTexture = fakeTex(),
    PushedTexture = fakeTex(),
    cooldown = fakeTex(),
    parent = parent,
    alpha = 1,
  }
  button.cooldown.SetDrawSwipe = function() end
  function button:GetParent() return self.parent end
  function button:CreateMaskTexture()
    local tex = fakeTex()
    tex.objectType = "MaskTexture"
    return tex
  end
  function button:CreateTexture()
    local tex = fakeTex()
    if not button.chrome then
      button.chrome = tex
    end
    return tex
  end
  function button:SetAlpha(a) self.alpha = a end
  function button:GetFrameLevel() return 4 end
  function button:SetFrameLevel() end
  function button:SetClipsChildren(clips) self.clipsChildren = clips end
  function button:SetHitRectInsets() end
  function button:HasAction() return true end
  return button
end

assert(loadfile(root .. "skin/shape.lua"))()
assert(loadfile(root .. "skin/chrome.lua"))()
assert(loadfile(root .. "bars/button.lua"))()

assert(Addon:IconMaskFile("square") == nil, "square has no extra mask")
assert(Addon:IconMaskFile("circle"):find("TempPortraitAlphaMask", 1, true),
  "circle uses the portrait alpha mask")
assert(Addon:IconMaskFile("diamond"):find("mask_diamond", 1, true),
  "diamond uses the addon mask")
assert(Addon:RoundRectMaskFile():find("mask_roundrect", 1, true),
  "roundrect mask ships for unit meters")
assert(Addon:OuterEdgeFile("square"):find("outer_shadow", 1, true)
  and not Addon:OuterEdgeFile("square"):find("circle", 1, true),
  "square Outer Edge keeps the 9-slice drop")
assert(Addon:OuterEdgeFile("circle"):find("outer_shadow_circle", 1, true),
  "circle Outer Edge uses the radial drop")
assert(Addon:OuterEdgeFile("diamond"):find("outer_shadow_diamond", 1, true),
  "diamond Outer Edge uses the diamond drop")
assert(Addon:OuterEdgeFile("roundrect"):find("outer_shadow_roundrect", 1, true),
  "roundrect Outer Edge uses the rounded 9-slice drop")

local bar1 = { iconShape = "circle", name = "ShadowUIBar1" }
local bar2 = { iconShape = "diamond", name = "ShadowUIBar2" }
local btn1 = fakeButton(bar1)
local btn2 = fakeButton(bar2)
Addon:SkinBarButton(btn1)
Addon:SkinBarButton(btn2)

assert(btn1.shadowUIShape == "circle", "Bar 1 Action Slots use circle")
assert(btn2.shadowUIShape == "diamond", "Bar 2 Action Slots use diamond")
assert(btn1.icon.masks[1] == btn1.shadowUIShapeMask, "circle masks the icon")
assert(btn1.chrome.masks[1] == btn1.shadowUIShapeMask, "circle masks the chrome fill")
assert(btn1.HighlightTexture.masks[1] == btn1.shadowUIShapeMask, "circle masks hover")
assert(btn1.PushedTexture.masks[1] == btn1.shadowUIShapeMask, "circle masks pressed")
assert(btn1.shadowUIShapeMask:IsObjectType("MaskTexture"),
  "shape mask is a MaskTexture, not a drawable overlay")
assert(btn1.shadowUIShapeMask.hWrap == "CLAMPTOBLACKADDITIVE"
  and btn1.shadowUIShapeMask.vWrap == "CLAMPTOBLACKADDITIVE",
  "mask wrap is CLAMPTOBLACKADDITIVE")
assert(btn1.cooldown.masks[1] == nil, "cooldown frame is not AddMaskTexture'd")
assert(btn1.shadowUIShapeMask.file:find("TempPortraitAlphaMask", 1, true),
  "circle mask file is the portrait mask")
assert(btn2.shadowUIShapeMask.file:find("mask_diamond", 1, true),
  "diamond mask file is the shipped diamond")
Addon:SkinBarButton(btn1)
assert(btn1.icon.masks[1] == btn1.shadowUIShapeMask,
  "a second skin pass keeps one mask")
assert(btn1.shadowUIShapeMask.hidden == false, "MaskTexture stays shown so it applies")
assert(btn1.shadowUIOuterShape == "circle", "Bar 1 Outer Edge is circle")
assert(btn2.shadowUIOuterShape == "diamond", "Bar 2 Outer Edge is diamond")
assert(btn1.shadowUIOuter.shadowUIDrop.file:find("outer_shadow_circle", 1, true),
  "circle drop texture matches the shape")
assert(btn2.shadowUIOuter.shadowUIDrop.file:find("outer_shadow_diamond", 1, true),
  "diamond drop texture matches the shape")
assert(btn1.shadowUIOuter.backdrop == nil, "shaped Outer Edge is not a 9-slice")

Addon:ShowPressGlow(btn1)
Addon:ShowPressGlow(btn2)
local press1 = btn1.shadowUIPressGlow
local press2 = btn2.shadowUIPressGlow
assert(press1, "circle Action Slot creates a press glow")
assert(press1.points[1] and press1.points[1][2] == 4,
  "press glow keeps the 4px inset")
assert(press1.masks[1] == btn1.shadowUIPressMask,
  "circle masks the press glow")
assert(#press1.masks == 1, "press glow uses its own mask, not the full-slot mask")
assert(btn1.shadowUIPressMask ~= btn1.shadowUIShapeMask,
  "press mask is not the full-slot shape mask")
assert(btn1.shadowUIPressMask.all == press1,
  "press mask sizes to the glow so the inset stays a circle")
assert(btn1.shadowUIPressMask:IsObjectType("MaskTexture"),
  "press mask is a MaskTexture")
assert(press2.masks[1] == btn2.shadowUIPressMask,
  "diamond masks the press glow")
assert(btn2.shadowUIPressMask.all == press2,
  "diamond press mask sizes to the glow")
Addon:SkinBarButton(btn1)
assert(press1.masks[1] == btn1.shadowUIPressMask,
  "a later skin pass keeps the press glow mask")

bar1.iconShape = "square"
Addon:SkinBarButton(btn1)
assert(btn1.shadowUIShape == "square", "a Bar can return to square")
assert(btn1.icon.masks[1] == nil, "square removes the shape mask from the icon")
assert(btn1.shadowUIShapeMask.hidden == true, "square hides the unused MaskTexture")
assert(press1.masks[1] == nil, "square removes the press glow mask")
assert(btn1.shadowUIPressMask.hidden == true, "square hides the unused press mask")

local micro = { name = "ShadowUIMicroHost" }
local microBtn = fakeButton(micro)
microBtn._shadowUINativeW = 28
microBtn._shadowUINativeH = 58
Addon:ApplyIconShape(microBtn, "circle")
assert(microBtn.shadowUIShape == "circle", "Micro Cluster can be circle while Bars differ")
assert(microBtn.icon.masks[1] == microBtn.shadowUIShapeMask,
  "Micro Cluster masks the icon when chrome fill is missing")
assert(btn2.shadowUIShape == "diamond", "Bar shape stays when Micro Cluster shape changes")

local leftover = fakeButton(bar1)
local overlay = fakeTex()
leftover.shadowUIShapeMask = overlay
overlay.hidden = false
Addon:ApplyIconShape(leftover, "circle")
assert(overlay.hidden == true, "old drawable overlay hides")
assert(leftover.shadowUIShapeMask:IsObjectType("MaskTexture"),
  "CreateTexture overlay is replaced with CreateMaskTexture")

local classic = fakeButton({ iconShape = "circle" })
classic.CreateMaskTexture = nil
classic.icon.crop = { 0.07, 0.93, 0.07, 0.93 }
Addon:ApplyIconShape(classic, "circle")
assert(classic.icon.masks[1] == nil, "Classic without CreateMaskTexture does not AddMaskTexture")
assert(classic.icon.setMask and classic.icon.setMask:find("TempPortraitAlphaMask", 1, true),
  "Classic without CreateMaskTexture uses SetMask")
assert(classic.icon.crop[1] == 0 and classic.icon.crop[4] == 1,
  "SetMask does not keep the 0.07 crop")
Addon:ShowPressGlow(classic)
assert(classic.shadowUIPressGlow.setMask
    and classic.shadowUIPressGlow.setMask:find("TempPortraitAlphaMask", 1, true),
  "Classic without CreateMaskTexture SetMasks the press glow")
Addon:ApplyIconShape(classic, "square")
assert(classic.icon.setMask == "", "square clears SetMask")
assert(classic.shadowUIPressGlow.setMask == "", "square clears press glow SetMask")

assert(loadfile(root .. "skin/stance.lua"))()
local stance = fakeButton({ name = "StanceBarFrame" })
function stance:GetName() return "StanceButton1" end
function stance:IsShown() return true end
stance.icon.GetTexture = function() return "Interface\\Icons\\Ability_Warrior_OffensiveStance" end
Addon:SkinStanceButton(stance)
assert(stance.shadowUIOuterShape == "square" or stance.shadowUIOuterShape == nil,
  "Stance buttons stay square")
assert(stance.shadowUIShape == nil or stance.shadowUIShape == "square",
  "Stance buttons do not take Bar iconShape")

local well = { name = "ShadowUIMeterHost" }
function well:GetFrameLevel() return 4 end
function well:SetFrameLevel() end
Addon:ApplyOuterChrome(well, "roundrect")
assert(well.shadowUIOuterShape == "roundrect", "meter well requests roundrect Outer Edge")
assert(well.shadowUIOuter.backdrop == nil,
  "roundrect Outer Edge is not a 9-slice so square corner quads cannot fray")
assert(well.shadowUIOuter.shadowUIDrop and well.shadowUIOuter.shadowUIDrop.file
    :find("outer_shadow_roundrect", 1, true),
  "roundrect Outer Edge is a 2:1 drop so corners stay round")

local stale = { name = "ShadowUIStaleWell", shadowUIOuterShape = "roundrect" }
function stale:GetFrameLevel() return 4 end
function stale:SetFrameLevel() end
stale.shadowUIOuter = well.shadowUIOuter
stale.shadowUIOuter.backdrop = { edgeFile = "outer_shadow_roundrect" }
stale.shadowUIOuterRev = nil
Addon:ApplyOuterChrome(stale, "roundrect")
assert(stale.shadowUIOuter.backdrop == nil,
  "a leftover roundrect 9-slice upgrades to the drop so square fringe cannot stay")

local function tgaSize(path)
  local f = assert(io.open(root .. path, "rb"))
  local header = f:read(18)
  f:close()
  local w = header:byte(13) + header:byte(14) * 256
  local h = header:byte(15) + header:byte(16) * 256
  return w, h
end

local function tgaAlpha(path, x, yTop)
  local f = assert(io.open(root .. path, "rb"))
  local data = f:read("*a")
  f:close()
  local w = data:byte(13) + data:byte(14) * 256
  local h = data:byte(15) + data:byte(16) * 256
  local y = h - 1 - yTop
  local i = 18 + (y * w + x) * 4
  return data:byte(i + 4)
end

local media = {
  "media/mask_diamond.tga",
  "media/mask_roundrect.tga",
  "media/mask_roundrect_square_left.tga",
  "media/outer_shadow_circle.tga",
  "media/outer_shadow_diamond.tga",
  "media/outer_shadow_roundrect.tga",
}
for _, path in ipairs(media) do
  local f = io.open(root .. path, "rb")
  assert(f, path .. " must ship")
  f:close()
end

local dropW, dropH = tgaSize("media/outer_shadow_roundrect.tga")
assert(dropW / dropH == 2,
  "roundrect drop is 2:1 so the well does not stretch corners into ovals")
assert(tgaAlpha("media/outer_shadow_roundrect.tga", 64, 32) == 0,
  "roundrect drop is hollow so it cannot paint a square fill")
assert(tgaAlpha("media/outer_shadow_roundrect.tga", 64, 2) > 40,
  "roundrect drop keeps a visible glow on the outer pad")
local maskW, maskH = tgaSize("media/mask_roundrect.tga")
assert(maskW / maskH == 2,
  "roundrect mask is 2:1 so the meter well does not stretch corners into ovals")
assert(tgaAlpha("media/mask_roundrect_square_left.tga", 0, 0) == 255,
  "Player meter mask keeps the portrait-facing left corner square")
assert(tgaAlpha("media/mask_roundrect_square_left.tga", 127, 0) < 255,
  "Player meter mask rounds the outside right corner")

print("shape_spec OK")
