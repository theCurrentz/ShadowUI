-- Shift and Prune packs Keybinds left. Shift+Alt insert shifts a row right.
-- Run: lua tests/slotshift_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end
_G.InCombatLockdown = function() return false end
assert(loadfile(root .. "bars/slotshift.lua"))()

local function hud(barId, index, bindSlot, actionSlot, key, actionId)
  return {
    barId = barId,
    index = index,
    bindSlot = bindSlot,
    actionSlot = actionSlot,
    key = key or "",
    action = actionId and { id = actionId, name = actionId } or nil,
  }
end

local function nextHud(buttons, result)
  local keys, actions = {}, {}
  for name, key in pairs(result.bindOverlay) do
    local slot = tonumber(name:match("ShadowUIActionButton(%d+)"))
    keys[slot] = key ~= false and key or ""
  end
  for slot, action in pairs(result.actionOverlay) do
    actions[slot] = action ~= false and action or nil
  end
  local out = {}
  for _, button in ipairs(buttons) do
    local key = button.key
    if keys[button.bindSlot] ~= nil or result.bindOverlay[("CLICK ShadowUIActionButton%d:Keybind"):format(button.bindSlot)] ~= nil then
      key = keys[button.bindSlot] or ""
    end
    local action = button.action
    if result.actionOverlay[button.actionSlot] ~= nil then
      action = actions[button.actionSlot]
    end
    out[#out + 1] = {
      barId = button.barId,
      index = button.index,
      bindSlot = button.bindSlot,
      actionSlot = button.actionSlot,
      key = key,
      action = action,
    }
  end
  return out
end

assert(Addon:SlotDropKind({ fromSlot = 1, shiftKey = true, altKey = true }) == "insert",
  "Shift+Alt on a slot drag inserts")
assert(Addon:SlotDropKind({ fromSlot = 1, shiftKey = true, altKey = false }) == "place",
  "Shift without Alt places")
assert(Addon:SlotDropKind({ fromSlot = nil, shiftKey = true, altKey = true }) == "place",
  "Shift+Alt without a source slot places")

local packed = {
  hud("bar1", 0, 1, 1, "1", "a"),
  hud("bar1", 1, 2, 2, "3", "c"),
  hud("bar1", 2, 3, 3, "", nil),
}
assert(Addon:PruneWouldChange(packed) == false, "a packed row has no gaps to prune")

local gapped = {
  hud("bar1", 0, 1, 1, "1", "a"),
  hud("bar1", 1, 2, 2, "", nil),
  hud("bar1", 2, 3, 3, "3", "c"),
}
assert(Addon:PruneWouldChange(gapped) == true, "a gap with no Keybind would change")
local pruned = Addon:ShiftAndPrune(gapped, {}, {})
local packedNext = nextHud(gapped, pruned)
assert(packedNext[1].key == "1" and packedNext[1].action.id == "a", "first slot keeps 1")
assert(packedNext[2].key == "3" and packedNext[2].action.id == "c", "3 shifts left into the gap")
assert(packedNext[3].key == "" and packedNext[3].action == nil, "last slot is empty")
assert(pruned.moves[1] == 1, "slot 1 stays")
assert(pruned.moves[2] == 3, "slot 3 moves onto slot 2")
assert(pruned.moves[3] == false, "slot 3 is cleared")

local wrap = {
  hud("bar1", 0, 1, 1, "1", "a"),
  hud("bar1", 1, 2, 2, "", nil),
  hud("bar1", 2, 3, 3, "3", "c"),
  hud("bar1", 3, 4, 4, "", nil),
}
local wrapped = nextHud(wrap, Addon:ShiftAndPrune(wrap, {}, {}))
assert(wrapped[1].key == "1" and wrapped[2].key == "3", "pack wraps onto the next row")
assert(wrapped[2].action.id == "c", "the wrapped action moves with the Keybind")
assert(wrapped[3].key == "" and wrapped[4].key == "", "emptied slots stay empty")

local cascade = {
  hud("bar1", 0, 1, 1, "1", "a"),
  hud("bar1", 1, 2, 2, "", nil),
  hud("bar2", 0, 13, 13, "3", "c"),
  hud("bar2", 1, 14, 14, "", nil),
}
local cascaded = nextHud(cascade, Addon:ShiftAndPrune(cascade, {}, {}))
assert(cascaded[1].key == "1" and cascaded[2].key == "3", "pack continues onto the next Bar")
assert(cascaded[2].action.id == "c", "the next-Bar action moves with the Keybind")
assert(cascaded[3].key == "" and cascaded[3].action == nil, "the source Bar slot is empty")

local row = {
  hud("bar1", 0, 1, 1, "1", "a"),
  hud("bar1", 1, 2, 2, "2", nil),
  hud("bar1", 2, 3, 3, "3", "c"),
  hud("bar1", 3, 4, 4, "4", nil),
}
local inserted = nextHud(row, Addon:InsertHudSlot(row, 2, 1, 3, {}, {}))
assert(inserted[1].action == nil and inserted[1].key == "", "source slot is empty")
assert(inserted[2].key == "2", "the rest of the source row stays")
assert(inserted[3].action.id == "a" and inserted[3].key == "1", "insert places the source before the drop")
assert(inserted[4].action.id == "c" and inserted[4].key == "3", "the drop row shifts right")

local same = {
  hud("bar1", 0, 1, 1, "1", "a"),
  hud("bar1", 1, 2, 2, "2", "b"),
  hud("bar1", 2, 3, 3, "3", "c"),
}
local reordered = nextHud(same, Addon:InsertHudSlot(same, 3, 1, 3, {}, {}))
assert(reordered[1].action.id == "b" and reordered[1].key == "2", "same-row insert shifts left of dest")
assert(reordered[2].action.id == "a" and reordered[2].key == "1", "source sits before dest")
assert(reordered[3].action.id == "c" and reordered[3].key == "3", "dest stays last")

local overflowSrc = {
  hud("bar1", 0, 1, 1, "1", "a"),
  hud("bar1", 1, 2, 2, "2", "b"),
  hud("bar2", 0, 13, 13, "3", "c"),
  hud("bar2", 1, 14, 14, "4", "d"),
}
local overflow = Addon:InsertHudSlot(overflowSrc, 2, 1, 13, {}, {})
local overflowNext = nextHud(overflowSrc, overflow)
assert(overflowNext[1].action == nil and overflowNext[1].key == "", "overflow insert clears the source")
assert(overflowNext[3].action.id == "a" and overflowNext[3].key == "1", "overflow insert lands on the drop slot")
assert(overflowNext[4].action.id == "c" and overflowNext[4].key == "3", "overflow insert shifts the drop row")
assert(overflow.held.id == "d" and overflow.held.fromSlot == 14, "the last slot of a full row stays on the cursor")

local writes, messages, placed, picked, cursor = {}, {}, {}, {}, nil
function Addon:GetCharDB()
  return { editLayer = "class" }
end
function Addon:WriteLayerDelta(layer, section, key, patch)
  writes[#writes + 1] = { layer = layer, section = section, key = key, patch = patch }
end
function Addon:Print(msg)
  messages[#messages + 1] = msg
end
function Addon:ResolveEffective()
  return { keybinds = {} }
end
function Addon:ApplyKeybinds() end
function Addon:RefreshActionDeckButtons() end
function Addon:CollectHudButtons()
  return gapped
end
_G.GetCursorInfo = function() return cursor end
_G.ClearCursor = function() cursor = nil end
_G.PickupAction = function(slot)
  picked[#picked + 1] = slot
  cursor = "action"
end
_G.PlaceAction = function(slot)
  placed[#placed + 1] = slot
  cursor = nil
end
_G.GetActionInfo = function(slot)
  if slot == 1 then return "macro", 1 end
  if slot == 3 then return "macro", 2 end
end
_G.GetMacroInfo = function(index)
  if index == 1 then return "A" end
  if index == 2 then return "C" end
end
_G.PickupMacro = function(index)
  cursor = "macro:" .. tostring(index)
end

assert(Addon:ShiftAndPruneBars() == true, "Shift and Prune runs out of combat")
assert(messages[#messages] == "Shifted keybinds left and pruned gaps.",
  "Shift and Prune reports success")
local bindWrite, actionWrite = 0, 0
for _, write in ipairs(writes) do
  assert(write.layer == "class", "Shift and Prune writes the selected Layer")
  if write.section == "keybinds" then
    bindWrite = bindWrite + 1
  elseif write.section == "actions" then
    actionWrite = actionWrite + 1
  end
end
assert(bindWrite == 3, "Shift and Prune writes each Keybind in the pack")
assert(actionWrite == 3, "Shift and Prune writes each Action Slot in the pack")
assert(#placed >= 1, "Shift and Prune places live Action Slots")

function Addon.CollectHudButtons()
  return packed
end
messages = {}
assert(Addon:ShiftAndPruneBars() == false, "a packed layout does not prune")
assert(messages[#messages] == "No keybind gaps to prune.", "packed layout explains the skip")

_G.InCombatLockdown = function() return true end
messages = {}
assert(Addon:ShiftAndPruneBars() == false, "combat blocks Shift and Prune")
assert(messages[#messages]:find("combat", 1, true), "combat prints a leave-combat note")
_G.InCombatLockdown = function() return false end

local buttonSrc = assert(io.open(root .. "bars/button.lua", "r")):read("*a")
assert(buttonSrc:find("HookButtonForSlotShift"), "create path hooks Shift+Alt insert")

local initSrc = assert(io.open(root .. "core/init.lua", "r")):read("*a")
assert(initSrc:find('cmd == "prune"') or initSrc:find('cmd == "shift"'),
  "/shadowui prune runs Shift and Prune")

local configSrc = assert(io.open(root .. "options/config.lua", "r")):read("*a")
assert(configSrc:find("ShiftAndPruneBars"), "options expose Shift and Prune")
assert(configSrc:find("Shift and Prune"), "options use the Shift and Prune name")

local toc = assert(io.open(root .. "ShadowUI.toc", "r")):read("*a")
assert(toc:find("bars\\slotshift.lua", 1, true), "Era TOC loads slotshift")
local tocTbc = assert(io.open(root .. "ShadowUI_TBC.toc", "r")):read("*a")
assert(tocTbc:find("bars\\slotshift.lua", 1, true), "TBC TOC loads slotshift")

print("slotshift_spec OK")
