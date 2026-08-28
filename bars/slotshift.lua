--[[
  Purpose: Shift and Prune packs Keybinds left and drops gaps with no Keybind.
           Shift+Alt drag inserts the action and Keybind and shifts that row right.
  Deps: ShadowUI addon table, live Action Slots, WriteLayerDelta
  Public: SlotDropKind, OrderedHudButtons, PruneWouldChange, ShiftAndPrune,
          InsertHudSlot, CollectHudButtons, ShiftAndPruneBars, InsertBarSlot,
          HookButtonForSlotShift
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local function slotBindName(slot)
  return "CLICK ShadowUIActionButton" .. slot .. ":Keybind"
end

local function barOrder(barId)
  local n = tonumber((barId or ""):match("^bar(%d+)$"))
  return n or 1000
end

local function copyAction(action)
  if type(action) ~= "table" then
    return action
  end
  if Addon.DeepCopy then
    return Addon:DeepCopy(action)
  end
  local out = {}
  for k, v in pairs(action) do
    out[k] = v
  end
  return out
end

local function copyTable(src)
  local out = {}
  for k, v in pairs(src or {}) do
    out[k] = v
  end
  return out
end

local function canonicalKey(key)
  if type(key) ~= "string" or key == "" then
    return nil
  end
  return key:upper()
end

local function overlayAction(action)
  if type(action) ~= "table" then
    return false
  end
  return copyAction(action)
end

function Addon:SlotDropKind(input)
  input = input or {}
  if input.fromSlot ~= nil and input.shiftKey and input.altKey then
    return "insert"
  end
  return "place"
end

function Addon:OrderedHudButtons(buttons)
  local ordered = {}
  for i, button in ipairs(buttons or {}) do
    ordered[i] = button
  end
  table.sort(ordered, function(a, b)
    local byBar = barOrder(a.barId) - barOrder(b.barId)
    if byBar ~= 0 then
      return byBar < 0
    end
    if a.barId ~= b.barId then
      return tostring(a.barId) < tostring(b.barId)
    end
    return (a.index or 0) < (b.index or 0)
  end)
  return ordered
end

function Addon:PruneWouldChange(buttons)
  local ordered = self:OrderedHudButtons(buttons)
  local kept = {}
  for _, button in ipairs(ordered) do
    if button.key and button.key ~= "" then
      kept[#kept + 1] = button
    end
  end
  for i, dest in ipairs(ordered) do
    local src = kept[i]
    if not src then
      if (dest.key and dest.key ~= "") or dest.action then
        return true
      end
    elseif dest.bindSlot ~= src.bindSlot
      or dest.actionSlot ~= src.actionSlot
      or dest.key ~= src.key
      or ((dest.action and dest.action.id) or "") ~= ((src.action and src.action.id) or "")
    then
      return true
    end
  end
  return false
end

function Addon:ShiftAndPrune(buttons, bindOverlay, actionOverlay)
  local ordered = self:OrderedHudButtons(buttons)
  local kept = {}
  for _, button in ipairs(ordered) do
    if button.key and button.key ~= "" then
      kept[#kept + 1] = button
    end
  end
  local nextBinds = copyTable(bindOverlay)
  local nextActions = copyTable(actionOverlay)
  local moves = {}
  for i, dest in ipairs(ordered) do
    local src = kept[i]
    nextBinds[slotBindName(dest.bindSlot)] = src and canonicalKey(src.key) or false
    nextActions[dest.actionSlot] = src and overlayAction(src.action) or false
    moves[dest.actionSlot] = src and src.actionSlot or false
  end
  return { bindOverlay = nextBinds, actionOverlay = nextActions, moves = moves }
end

local function rowOf(button, cols)
  return math.floor((button.index or 0) / math.max(1, cols or 1))
end

local function buttonsInRow(buttons, barId, row, cols)
  local rowButtons = {}
  for _, button in ipairs(buttons) do
    if button.barId == barId and rowOf(button, cols) == row then
      rowButtons[#rowButtons + 1] = button
    end
  end
  table.sort(rowButtons, function(a, b)
    return (a.index or 0) < (b.index or 0)
  end)
  return rowButtons
end

local function occupancy(button)
  return {
    action = button.action,
    key = button.key or "",
    fromSlot = button.actionSlot,
  }
end

local function writeOccupancy(dest, src, nextBinds, nextActions, moves)
  nextBinds[slotBindName(dest.bindSlot)] = src and canonicalKey(src.key) or false
  nextActions[dest.actionSlot] = src and overlayAction(src.action) or false
  moves[dest.actionSlot] = src and src.fromSlot or false
end

local function moveInRow(items, from, to)
  if from == to then
    return items
  end
  local next = {}
  for i, item in ipairs(items) do
    next[i] = item
  end
  local item = table.remove(next, from)
  if not item then
    return items
  end
  local insertAt = from < to and to - 1 or to
  table.insert(next, insertAt, item)
  return next
end

local function colsFn(colsOf)
  if type(colsOf) == "function" then
    return colsOf
  end
  if type(colsOf) == "number" then
    local n = colsOf
    return function()
      return n
    end
  end
  local t = type(colsOf) == "table" and colsOf or {}
  return function(barId)
    return t[barId] or 12
  end
end

function Addon:InsertHudSlot(buttons, colsOf, fromActionSlot, toActionSlot, bindOverlay, actionOverlay)
  colsOf = colsFn(colsOf)
  local src, dest
  for _, button in ipairs(buttons or {}) do
    if button.actionSlot == fromActionSlot then
      src = button
    end
    if button.actionSlot == toActionSlot then
      dest = button
    end
  end
  if not src or not dest or fromActionSlot == toActionSlot then
    return {
      bindOverlay = bindOverlay or {},
      actionOverlay = actionOverlay or {},
      moves = {},
    }
  end
  local srcCols = colsOf(src.barId)
  local destCols = colsOf(dest.barId)
  local srcRow = rowOf(src, srcCols)
  local destRow = rowOf(dest, destCols)
  local nextBinds = copyTable(bindOverlay)
  local nextActions = copyTable(actionOverlay)
  local moves = {}

  if src.barId == dest.barId and srcRow == destRow then
    local row = buttonsInRow(buttons, src.barId, srcRow, srcCols)
    local fromCol, toCol
    for i, button in ipairs(row) do
      if button.actionSlot == fromActionSlot then
        fromCol = i
      end
      if button.actionSlot == toActionSlot then
        toCol = i
      end
    end
    if not fromCol or not toCol then
      return {
        bindOverlay = bindOverlay or {},
        actionOverlay = actionOverlay or {},
        moves = {},
      }
    end
    local items = {}
    for i, button in ipairs(row) do
      items[i] = occupancy(button)
    end
    local moved = moveInRow(items, fromCol, toCol)
    for i, button in ipairs(row) do
      writeOccupancy(button, moved[i], nextBinds, nextActions, moves)
    end
    return { bindOverlay = nextBinds, actionOverlay = nextActions, moves = moves }
  end

  local destButtons = buttonsInRow(buttons, dest.barId, destRow, destCols)
  local destCol
  for i, button in ipairs(destButtons) do
    if button.actionSlot == toActionSlot then
      destCol = i
      break
    end
  end
  if not destCol then
    return {
      bindOverlay = bindOverlay or {},
      actionOverlay = actionOverlay or {},
      moves = {},
    }
  end
  local destItems = {}
  for i, button in ipairs(destButtons) do
    destItems[i] = occupancy(button)
  end
  table.insert(destItems, destCol, occupancy(src))
  local held
  if #destItems > #destButtons then
    local overflow = table.remove(destItems)
    if overflow and overflow.action then
      held = copyAction(overflow.action)
      held.fromSlot = overflow.fromSlot
    end
  end
  for i, button in ipairs(destButtons) do
    writeOccupancy(button, destItems[i], nextBinds, nextActions, moves)
  end
  writeOccupancy(src, { key = "", fromSlot = nil }, nextBinds, nextActions, moves)
  return {
    bindOverlay = nextBinds,
    actionOverlay = nextActions,
    moves = moves,
    held = held,
  }
end

local function withUnlockedActionBars(fn)
  local lockBars
  if type(GetCVar) == "function" then
    lockBars = GetCVar("lockActionBars")
  end
  if lockBars == "1" and type(SetCVar) == "function" then
    pcall(SetCVar, "lockActionBars", "0")
  end
  fn()
  if lockBars == "1" and type(SetCVar) == "function" then
    pcall(SetCVar, "lockActionBars", lockBars)
  end
end

function Addon:ActionFromSlot(slot)
  if type(slot) ~= "number" or type(GetActionInfo) ~= "function" then
    return nil
  end
  local actionType, id = GetActionInfo(slot)
  if not actionType or actionType == "" then
    return nil
  end
  if actionType == "spell" then
    local name = tostring(id)
    if type(GetSpellInfo) == "function" then
      name = GetSpellInfo(id) or name
    end
    return { id = "spell:" .. tostring(id), name = name, kind = "spell", spellId = id }
  end
  if actionType == "macro" then
    local name = tostring(id)
    if type(GetMacroInfo) == "function" then
      name = GetMacroInfo(id) or name
    end
    local catalog = (self.Defaults or {}).catalog
    if type(catalog) == "table" then
      for catalogId, rec in pairs(catalog) do
        if type(rec) == "table" and rec.name == name then
          return { id = catalogId, name = name }
        end
      end
    end
    if self.ResolveDeck then
      local deck = self:ResolveDeck()
      if type(deck) == "table" then
        for _, entry in pairs(deck) do
          if type(entry) == "table" and entry.name == name then
            return copyAction(entry)
          end
        end
      end
    end
    return { id = name, name = name }
  end
  if actionType == "item" then
    local name = tostring(id)
    if type(GetItemInfo) == "function" then
      name = GetItemInfo(id) or name
    end
    return { id = "item:" .. tostring(id), name = name, kind = "item" }
  end
  return { id = actionType .. ":" .. tostring(id), name = tostring(id), kind = actionType }
end

local function keyByBindSlot(self, binds)
  local keys = {}
  for name, key in pairs(binds or {}) do
    if key and key ~= "" then
      local slot = self.SlotFromBindingName and self:SlotFromBindingName(name)
      if slot then
        keys[slot] = key
      end
    end
  end
  return keys
end

function Addon:CollectHudButtons()
  local cfg = self.ResolveEffective and self:ResolveEffective() or {}
  local layout = cfg.layout or {}
  local binds = cfg.keybinds or {}
  if self.MergeBindingTables and self.CollectClientActionBinds then
    binds = self:MergeBindingTables(self:CollectClientActionBinds(), binds)
  end
  local keys = keyByBindSlot(self, binds)
  local bars = {}
  for _, bar in pairs(self.bars or {}) do
    local barId = bar.barId
    if type(barId) == "string" and barId:match("^bar%d+$") and bar.configEnabled ~= false then
      bars[#bars + 1] = bar
    end
  end
  table.sort(bars, function(a, b)
    return barOrder(a.barId) < barOrder(b.barId)
  end)
  local buttons = {}
  for _, bar in ipairs(bars) do
    local barCfg = layout[bar.barId] or {}
    local bindFirst = self.FirstActionSlot and self:FirstActionSlot(bar.barId, barCfg)
    if bindFirst then
      local cols = bar.columns or barCfg.columns or #(bar.buttons or {})
      for i, button in ipairs(bar.buttons or {}) do
        local bindSlot = bindFirst + i - 1
        local actionSlot = button._state_action
        if type(actionSlot) ~= "number" and button.GetAttribute then
          actionSlot = button:GetAttribute("action")
        end
        if type(actionSlot) ~= "number" then
          actionSlot = bindSlot
        end
        buttons[#buttons + 1] = {
          barId = bar.barId,
          index = i - 1,
          bindSlot = bindSlot,
          actionSlot = actionSlot,
          columns = cols,
          key = keys[bindSlot] or "",
          action = self:ActionFromSlot(actionSlot),
        }
      end
    end
  end
  return buttons
end

local function snapshotSlot(slot)
  if type(GetActionInfo) ~= "function" then
    return nil
  end
  local actionType, id, subType = GetActionInfo(slot)
  if not actionType or actionType == "" then
    return nil
  end
  return { type = actionType, id = id, subType = subType }
end

local function cursorHasPickup()
  if type(GetCursorInfo) ~= "function" then
    return true
  end
  local kind = GetCursorInfo()
  return kind ~= nil and kind ~= ""
end

local function pickupSnap(snap)
  if not snap then
    return false
  end
  if snap.type == "spell" then
    local api = _G.C_Spell
    if api and type(api.PickupSpell) == "function" and snap.id then
      pcall(api.PickupSpell, snap.id)
      if cursorHasPickup() then
        return true
      end
    end
    if type(PickupSpell) == "function" then
      pcall(PickupSpell, snap.id)
      return cursorHasPickup()
    end
    return false
  end
  if snap.type == "macro" and type(PickupMacro) == "function" then
    pcall(PickupMacro, snap.id)
    return cursorHasPickup()
  end
  if snap.type == "item" and type(PickupItem) == "function" then
    pcall(PickupItem, snap.id)
    return cursorHasPickup()
  end
  return false
end

function Addon:ApplySlotMoves(moves, held)
  if type(PickupAction) ~= "function" or type(ClearCursor) ~= "function" then
    return
  end
  local snaps = {}
  local dests = {}
  for dest, src in pairs(moves or {}) do
    dests[#dests + 1] = dest
    if snaps[dest] == nil then
      snaps[dest] = snapshotSlot(dest) or false
    end
    if src and snaps[src] == nil then
      snaps[src] = snapshotSlot(src) or false
    end
  end
  table.sort(dests)
  local heldSnap = held and held.fromSlot and snaps[held.fromSlot]
  if held and not heldSnap then
    heldSnap = snapshotSlot(held.fromSlot)
  end
  withUnlockedActionBars(function()
    ClearCursor()
    for _, dest in ipairs(dests) do
      PickupAction(dest)
      ClearCursor()
    end
    for _, dest in ipairs(dests) do
      local src = moves[dest]
      local snap = src and snaps[src]
      if snap and snap ~= false then
        if pickupSnap(snap) then
          PlaceAction(dest)
          ClearCursor()
        end
      end
    end
    if heldSnap and heldSnap ~= false then
      pickupSnap(heldSnap)
    end
  end)
end

function Addon:WriteHudOverlays(bindOverlay, actionOverlay)
  local layer = self:GetCharDB().editLayer
  for name, key in pairs(bindOverlay or {}) do
    self:WriteLayerDelta(layer, "keybinds", name, key)
  end
  for slot, action in pairs(actionOverlay or {}) do
    self:WriteLayerDelta(layer, "actions", slot, action)
  end
end

function Addon:ShiftAndPruneBars()
  if InCombatLockdown and InCombatLockdown() then
    self:Print("Leave combat to shift Action Slots.")
    return false
  end
  local buttons = self:CollectHudButtons()
  if not self:PruneWouldChange(buttons) then
    self:Print("No keybind gaps to prune.")
    return false
  end
  local result = self:ShiftAndPrune(buttons, {}, {})
  self:WriteHudOverlays(result.bindOverlay, result.actionOverlay)
  self:ApplySlotMoves(result.moves)
  if self.ApplyKeybinds then
    self:ApplyKeybinds(self:ResolveEffective())
  end
  if self.RefreshActionDeckButtons then
    self:RefreshActionDeckButtons()
  end
  self:Print("Shifted keybinds left and pruned gaps.")
  return true
end

function Addon:InsertBarSlot(fromSlot, toSlot)
  if InCombatLockdown and InCombatLockdown() then
    return false
  end
  if type(fromSlot) ~= "number" or type(toSlot) ~= "number" or fromSlot == toSlot then
    return false
  end
  if type(GetCursorInfo) == "function" and GetCursorInfo() and type(PlaceAction) == "function" then
    PlaceAction(fromSlot)
    if type(ClearCursor) == "function" then
      ClearCursor()
    end
  end
  local buttons = self:CollectHudButtons()
  local colsOf = function(barId)
    for _, button in ipairs(buttons) do
      if button.barId == barId then
        return button.columns or 12
      end
    end
    return 12
  end
  local result = self:InsertHudSlot(buttons, colsOf, fromSlot, toSlot, {}, {})
  self:WriteHudOverlays(result.bindOverlay, result.actionOverlay)
  self:ApplySlotMoves(result.moves, result.held)
  if self.ApplyKeybinds then
    self:ApplyKeybinds(self:ResolveEffective())
  end
  if self.RefreshActionDeckButtons then
    self:RefreshActionDeckButtons()
  end
  self:ClearSlotShiftFrom()
  return true
end

function Addon:SetSlotShiftFrom(slot)
  self.slotShiftFrom = slot
  if InCombatLockdown and InCombatLockdown() then
    return
  end
  for _, bar in pairs(self.bars or {}) do
    if bar.SetAttribute and type(bar.barId) == "string" and bar.barId:match("^bar%d+$") then
      bar:SetAttribute("shadowuifromslot", slot)
    end
  end
end

function Addon:ClearSlotShiftFrom()
  self.slotShiftFrom = nil
  if InCombatLockdown and InCombatLockdown() then
    return
  end
  for _, bar in pairs(self.bars or {}) do
    if bar.SetAttribute and type(bar.barId) == "string" and bar.barId:match("^bar%d+$") then
      bar:SetAttribute("shadowuifromslot", nil)
    end
  end
end

function Addon:OnSlotShiftDragStart(button)
  local slot = button and button._state_action
  if type(slot) ~= "number" and button and button.GetAttribute then
    slot = button:GetAttribute("action")
  end
  if type(slot) == "number" then
    self:SetSlotShiftFrom(slot)
  end
end

function Addon:OnSlotShiftInsertReceive(button)
  if InCombatLockdown and InCombatLockdown() then
    return
  end
  local toSlot = button and button._state_action
  if type(toSlot) ~= "number" and button and button.GetAttribute then
    toSlot = button:GetAttribute("action")
  end
  local fromSlot = self.slotShiftFrom
  if type(fromSlot) ~= "number" or type(toSlot) ~= "number" then
    return
  end
  self:InsertBarSlot(fromSlot, toSlot)
end

function Addon:HookButtonForSlotShift(button)
  if not button or button._shadowUISlotShift then
    return
  end
  local header = button.header
  if not header or not header.WrapScript then
    return
  end
  button._shadowUISlotShift = true
  button.ShadowUIDragStart = function(self)
    Addon:OnSlotShiftDragStart(self)
  end
  button.ShadowUIInsertReceive = function(self)
    Addon:OnSlotShiftInsertReceive(self)
  end
  pcall(header.WrapScript, header, button, "OnDragStart", [[
    self:CallMethod("ShadowUIDragStart")
  ]])
  pcall(header.WrapScript, header, button, "OnReceiveDrag", [[
    if IsShiftKeyDown() and IsAltKeyDown() and owner:GetAttribute("shadowuifromslot") then
      self:CallMethod("ShadowUIInsertReceive")
      return false
    end
  ]])
end
