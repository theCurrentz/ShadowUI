-- /shadowui AceGUI host uses Darken fill, not DialogBox parchment.
-- Controls created while the pane is open get the same treatment.
-- Run: lua tests/options_chrome_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local unpack = unpack or table.unpack
local Addon = {
  DARKEN_BLACK = { 0.05, 0.05, 0.05 },
  DARKEN_GREY = { 0.35, 0.35, 0.35 },
}
local created = {}
local acegui = {
  Create = function(_, widgetType)
    local widget = { type = widgetType, frame = { regions = {} } }
    created[#created + 1] = widget
    return widget
  end,
}
local opened
local dialog = {
  OpenFrames = {},
  Open = function(self, app)
    opened = app
    local host = { type = "Frame", titlebg = {}, frame = {} }
    self.OpenFrames.ShadowUI = host
  end,
}
_G.LibStub = function(name, silent)
  if name == "AceAddon-3.0" then
    return { GetAddon = function() return Addon end }
  end
  if name == "AceGUI-3.0" then
    return acegui
  end
  if name == "AceConfigDialog-3.0" then
    return dialog
  end
  if silent then
    return nil
  end
  error("unexpected LibStub " .. tostring(name))
end

local function fakeRegion(path)
  local region = { shown = true, path = path, r = 1, g = 1, b = 1 }
  function region:GetTexture()
    return self.path
  end
  function region:Hide()
    self.shown = false
  end
  function region:SetVertexColor(r, g, b)
    self.r, self.g, self.b = r, g, b
  end
  function region:IsObjectType(kind)
    return kind == "Texture"
  end
  function region:GetName()
    return ""
  end
  return region
end

local function fakeFrame(kids, regions)
  local frame = {
    backdrop = nil,
    br = 1, bg = 1, bb = 1, ba = 1,
    rr = 1, rg = 1, rb = 1, ra = 1,
    kids = kids or {},
    regions = regions or {},
  }
  function frame:SetBackdrop(spec)
    self.backdrop = spec
  end
  function frame:SetBackdropColor(r, g, b, a)
    self.br, self.bg, self.bb, self.ba = r, g, b, a
  end
  function frame:SetBackdropBorderColor(r, g, b, a)
    self.rr, self.rg, self.rb, self.ra = r, g, b, a
  end
  function frame:GetChildren()
    return unpack(self.kids)
  end
  function frame:GetRegions()
    return unpack(self.regions)
  end
  return frame
end

assert(loadfile(root .. "options/chrome.lua"))()

local header = fakeRegion(131080)
local parchment = fakeRegion("Interface\\DialogFrame\\UI-DialogBox-Background")
local titlebg = fakeRegion("Interface\\DialogFrame\\UI-DialogBox-Header")
function titlebg:Hide()
  self.shown = false
end
local close = fakeFrame({}, { fakeRegion("Interface\\Buttons\\UI-Panel-Button-Up") })
local hostFrame = fakeFrame({ close }, { header, parchment })
local host = { type = "Frame", frame = hostFrame, titlebg = titlebg }
Addon:SkinOptionsHost(host)
assert(hostFrame.backdrop, "host gets a ShadowUI pane backdrop")
assert(hostFrame.backdrop.bgFile:find("ChatFrameBackground", 1, true),
  "host fill is ChatFrameBackground, not DialogBox")
assert(not tostring(hostFrame.backdrop.bgFile):find("DialogBox", 1, true),
  "host does not keep DialogBox parchment")
assert(hostFrame.br == 0.05 and hostFrame.bg == 0.05 and hostFrame.bb == 0.05,
  "host fill is DARKEN_BLACK")
assert(hostFrame.rr == 0.35 and hostFrame.rg == 0.35 and hostFrame.rb == 0.35,
  "host border is DARKEN_GREY")
assert(titlebg.shown == false, "DialogBox title plate is hidden")
assert(header.shown == false, "DialogBox header file id is hidden")
assert(parchment.shown == false, "DialogBox parchment texture is hidden")
assert(close.regions[1].r == 0.35, "close button art is darkened")
assert(Addon:SkinOptionsHost(host) == host, "host skin is idempotent")

local checkbg = fakeRegion("Interface\\Buttons\\UI-CheckBox-Up")
local check = {
  type = "CheckBox",
  checkbg = checkbg,
  frame = fakeFrame({}, { checkbg }),
}
Addon:SkinOptionsWidget(check)
assert(checkbg.r == 0.35 and checkbg.g == 0.35 and checkbg.b == 0.35,
  "checkbox plate uses DARKEN_GREY")

local tree = {
  type = "TreeGroup",
  treeframe = fakeFrame(),
  border = fakeFrame(),
  frame = fakeFrame(),
}
Addon:SkinOptionsWidget(tree)
assert(tree.treeframe.br == 0.05, "tree list fill is DARKEN_BLACK")
assert(tree.border.br == 0.05, "tree content fill is DARKEN_BLACK")

created = {}
dialog.OpenFrames.ShadowUI = host
local live = acegui:Create("CheckBox")
assert(live._suiOptionsChrome, "widget created while options are open is darkened")

dialog.OpenFrames.ShadowUI = nil
local otherCheck = { checkbg = fakeRegion("Interface\\Buttons\\UI-CheckBox-Up") }
local other = acegui:Create("CheckBox")
assert(not other._suiOptionsChrome, "widget outside ShadowUI options is not skinned")

dialog:Open("ShadowUI")
assert(opened == "ShadowUI", "Open still opens AceConfigDialog")
assert(dialog.OpenFrames.ShadowUI._suiOptionsChrome, "Open skins the ShadowUI host")

local toc = assert(io.open(root .. "ShadowUI.toc", "r")):read("*a")
assert(toc:find("options\\chrome.lua", 1, true), "Era TOC loads options chrome")
local tocTbc = assert(io.open(root .. "ShadowUI_TBC.toc", "r")):read("*a")
assert(tocTbc:find("options\\chrome.lua", 1, true), "TBC TOC loads options chrome")

print("options_chrome_spec OK")
