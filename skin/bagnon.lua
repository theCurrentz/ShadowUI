--[[
  Purpose: Skin Bagnon inventory and bank with Darken fill and Outer Edge.
           Keep search and sort. Turn bag breaks off so the Rainbow Organizer
           can group by category.
  Deps: ShadowUI:ApplyOuterChrome(), ShadowUI:LayoutRainbowGroup(); optional Bagnon
  Public: ShadowUI:SkinBagnon(), ShadowUI:SkinBagnonFrame()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local FILL = { 0.05, 0.05, 0.05, 0.92 }
local BORDER = { 0, 0, 0, 1 }

local function bagnonAddon()
  return _G.Bagnon
end

local function paintRegion(region, r, g, b, a)
  if not region then
    return
  end
  if region.SetColorTexture then
    region:SetColorTexture(r, g, b, a)
  elseif region.SetVertexColor then
    region:SetVertexColor(r, g, b, a)
  end
end

local function registerSkin(bagnon)
  local skins = bagnon.Skins
  if not skins or not skins.Register or (skins.Registry and skins.Registry.ShadowUI) then
    return
  end
  skins:Register({
    id = "ShadowUI",
    template = "BagnonOnePixelTemplate",
    margin = 3,
    centerColor = function(frame, r, g, b, a)
      paintRegion(frame.Center, r, g, b, a)
    end,
    borderColor = function(frame, r, g, b, a)
      paintRegion(frame.TopEdge, r, g, b, a)
      paintRegion(frame.BottomEdge, r, g, b, a)
      paintRegion(frame.LeftEdge, r, g, b, a)
      paintRegion(frame.RightEdge, r, g, b, a)
    end,
    load = function(frame)
      local panel = frame.GetParent and frame:GetParent() or frame.parent
      if panel then
        Addon:ApplyOuterChrome(panel)
      end
    end,
  })
end

function Addon:SkinBagnonFrame(frame)
  if not frame then
    return
  end
  local profile = frame.GetProfile and frame:GetProfile() or frame.profile
  if profile then
    profile.skin = "ShadowUI"
    profile.bagBreak = 0
    profile.search = true
    profile.sort = true
    profile.color = { FILL[1], FILL[2], FILL[3], FILL[4] }
    profile.borderColor = { BORDER[1], BORDER[2], BORDER[3], BORDER[4] }
  end
  self:ApplyOuterChrome(frame)
  if frame.UpdateVisuals then
    frame:UpdateVisuals()
  end
end

local function eachFrame(bagnon, call)
  local frames = bagnon.Frames
  if frames and frames.Iterate then
    for _, frame in frames:Iterate() do
      if frame and (frame[0] or frame.GetProfile or frame.profile) then
        call(frame)
      end
    end
  end
end

local function hookBagnon(bagnon)
  if Addon._bagnonHook then
    return
  end
  Addon._bagnonHook = true
  if hooksecurefunc and bagnon.ItemGroup and bagnon.ItemGroup.Layout then
    hooksecurefunc(bagnon.ItemGroup, "Layout", function(group)
      Addon:LayoutRainbowGroup(group)
    end)
  end
  if hooksecurefunc and bagnon.Item and bagnon.Item.UpdateBorder then
    hooksecurefunc(bagnon.Item, "UpdateBorder", function(button)
      Addon:PaintRainbowGlow(button)
    end)
  end
  if hooksecurefunc and bagnon.Frames and bagnon.Frames.Show then
    hooksecurefunc(bagnon.Frames, "Show", function(_, id, owner)
      local frames = bagnon.Frames
      local frame = frames.Get and frames:Get(id)
      if type(frame) == "table" then
        Addon:SkinBagnonFrame(frame)
      end
    end)
  end
end

local function watchLateLoad()
  if Addon._bagnonWatch or not CreateFrame then
    return
  end
  Addon._bagnonWatch = true
  local watch = CreateFrame("Frame", "ShadowUIBagnonWatch")
  if watch.RegisterEvent then
    watch:RegisterEvent("ADDON_LOADED")
  end
  if watch.SetScript then
    watch:SetScript("OnEvent", function(_, _, name)
      if name == "Bagnon" or name == "Bagnon_Bank" then
        Addon:SkinBagnon()
      end
    end)
  end
  if C_Timer and C_Timer.After and not Addon._bagnonRetry then
    Addon._bagnonRetry = true
    C_Timer.After(1, function()
      Addon:SkinBagnon()
    end)
  end
end

function Addon:SkinBagnon()
  local bagnon = bagnonAddon()
  if not bagnon then
    watchLateLoad()
    return
  end
  registerSkin(bagnon)
  hookBagnon(bagnon)
  eachFrame(bagnon, function(frame)
    Addon:SkinBagnonFrame(frame)
  end)
  if C_AddOns and C_AddOns.LoadAddOn then
    pcall(C_AddOns.LoadAddOn, "Bagnon_Bank")
  elseif LoadAddOn then
    pcall(LoadAddOn, "Bagnon_Bank")
  end
  watchLateLoad()
end
