--[[
  Purpose: Create and lay out standard action bar frames.
  Deps: ShadowUI:CreateBarButton(), ShadowUI:ApplyBarChrome(), ShadowUI:AttachBarDragOverlay()
  Public: ShadowUI:FirstActionSlot(), ShadowUI:StancePageDriver(), ShadowUI:CreateBar(),
          ShadowUI:PlaceBarButtons(), ShadowUI:UpdateBarLayout()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local function stancePages(cfg)
  local pages = cfg and cfg.stancePages
  if type(pages) ~= "table" or type(pages[1]) ~= "number" then
    return nil
  end
  return pages
end

-- bonusbar:1 = slots 73, :2 = 85, :3 = 97, :4 = 109. No bonus bar uses the
-- page whose first slot is 1 (caster / unstealthed), else page 1.
local function bonusBarOfSlot(first)
  if type(first) ~= "number" or first < 73 or (first - 73) % 12 ~= 0 then
    return nil
  end
  return 1 + (first - 73) / 12
end

function Addon:StancePageDriver(pages)
  if not pages or #pages < 2 then
    return nil
  end
  local parts = {}
  local fallback = 1
  for i, first in ipairs(pages) do
    local bonus = bonusBarOfSlot(first)
    if bonus then
      parts[#parts + 1] = { bonus = bonus, state = i }
    end
    if first == 1 then
      fallback = i
    end
  end
  table.sort(parts, function(a, b) return a.bonus > b.bonus end)
  local driver = {}
  for _, part in ipairs(parts) do
    driver[#driver + 1] = string.format("[bonusbar:%d] %d", part.bonus, part.state)
  end
  driver[#driver + 1] = tostring(fallback)
  return table.concat(driver, "; ")
end

local function configureStancePages(bar, pages)
  if not pages then
    return
  end
  bar:SetAttribute("state", 1)
  bar:SetAttribute("_onstate-page", [[
    self:SetAttribute("state", newstate)
    control:ChildUpdate("state", newstate)
  ]])
  for i, button in ipairs(bar.buttons) do
    for state, firstSlot in ipairs(pages) do
      button:SetState(state, "action", firstSlot + i - 1)
    end
  end
  RegisterStateDriver(bar, "page", Addon:StancePageDriver(pages))
end

function Addon:PlaceBarButtons(bar, columns, size)
  local count = #bar.buttons
  columns = math.max(1, math.min(columns or count, count))
  bar.buttonSize = size
  bar.columns = columns
  bar:SetSize(columns * size, math.ceil(count / columns) * size)
  for i, button in ipairs(bar.buttons) do
    local column = (i - 1) % columns
    local row = math.floor((i - 1) / columns)
    button:ClearAllPoints()
    button:SetSize(size, size)
    button:SetPoint("TOPLEFT", bar, "TOPLEFT", column * size, -row * size)
  end
  if bar.dragOverlay and bar.dragOverlay.SetAllPoints then
    bar.dragOverlay:SetAllPoints(bar)
  end
end

function Addon:UpdateBarLayout(bar, cfg)
  local size = cfg.buttonSize or 36
  self:PlaceBarButtons(bar, cfg.columns or #bar.buttons, size)
  bar:SetScale(cfg.scale or 1)
  bar:ClearAllPoints()
  bar:SetPoint(
    cfg.point or "CENTER",
    _G[cfg.relativeTo or "UIParent"] or UIParent,
    cfg.relativePoint or cfg.point or "CENTER",
    cfg.x or 0,
    cfg.y or 0
  )

  local editable = self.editMode == true
  bar:SetMovable(editable)
  if self.UpdateBarDragOverlay then
    self:UpdateBarDragOverlay(bar, editable)
  end
end

function Addon:FirstActionSlot(barId, cfg)
  local pages = stancePages(cfg)
  if pages then
    return pages[1]
  end
  if cfg and type(cfg.firstSlot) == "number" then
    return cfg.firstSlot
  end
  local page = tonumber((barId or ""):match("^bar(%d+)$"))
  if not page then
    return nil
  end
  return (page - 1) * 12 + 1
end

function Addon:CreateBar(barId, cfg)
  local page = tonumber(barId:match("^bar(%d+)$"))
  assert(page, "CreateBar requires a standard action bar id")

  -- SecureHandlerStateTemplate must be the only template so WrapScript exists.
  -- BackdropTemplate on the same CreateFrame can fail on Classic Era.
  local bar = CreateFrame("Frame", "ShadowUIBar" .. page, UIParent, "SecureHandlerStateTemplate")
  bar:SetFrameStrata("MEDIUM")
  bar:SetClampedToScreen(true)
  if bar.SetClampRectInsets then
    bar:SetClampRectInsets(0, 0, 0, 0)
  end
  self:ApplyBarChrome(bar)
  bar.buttons = {}
  bar.barId = barId

  local firstSlot = self:FirstActionSlot(barId, cfg)
  for i = 1, cfg.buttons or 12 do
    local slot = firstSlot + i - 1
    bar.buttons[i] = self:CreateBarButton(bar, slot, slot)
  end
  configureStancePages(bar, stancePages(cfg))

  if self.AttachBarDragOverlay then
    self:AttachBarDragOverlay(bar)
  end
  self:UpdateBarLayout(bar, cfg)
  return bar
end
