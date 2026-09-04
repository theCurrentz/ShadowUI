--[[
  Purpose: Save, preview, and apply account-owned Character Loadout Snapshots.
  Deps: ShadowUI DB/resolve/keybind helpers, bar slot mapping, WoW action/macro APIs
  Public: CurrentLoadoutKey, SaveCurrentLoadout, DeleteLoadout, LoadoutValues,
          DefaultLoadoutOptions, BuildLoadoutPlan, DescribeLoadoutPlan,
          ApplyLoadoutPlan, RestoreLoadoutBackup, HandleLoadoutCommand
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local SCHEMA = 1
local STANDARD_BARS = {
  "bar1", "bar2", "bar3", "bar4", "bar5",
  "bar6", "bar7", "bar8", "bar9", "bar10",
}
local LAYOUT_BARS = {
  "bar1", "bar2", "bar3", "bar4", "bar5",
  "bar6", "bar7", "bar8", "bar9", "bar10", "pet", "possess",
}
local HOSTS = { "player", "target", "cast", "range", "stance", "cooldown" }
local BAR_VISUAL_FIELDS = {
  "point", "relativeTo", "relativePoint", "x", "y", "columns",
  "scale", "fadeIdle", "iconShape", "enabled", "buttonSize",
  "gap", "gapAbove", "gapBelow", "vertical", "direction", "max", "group", "rowGaps",
}

local function copy(self, value)
  if self.DeepCopy then
    return self:DeepCopy(value)
  end
  if type(value) ~= "table" then
    return value
  end
  local out = {}
  for key, child in pairs(value) do
    out[key] = copy(self, child)
  end
  return out
end

local function same(a, b)
  if type(a) ~= type(b) then
    return false
  end
  if type(a) ~= "table" then
    return a == b
  end
  for key, value in pairs(a) do
    if not same(value, b[key]) then
      return false
    end
  end
  for key in pairs(b) do
    if a[key] == nil then
      return false
    end
  end
  return true
end

local function currentCharacter()
  local name = type(UnitName) == "function" and UnitName("player") or nil
  return name or "Unknown"
end

local function currentRealm()
  local realm = type(GetRealmName) == "function" and GetRealmName() or nil
  return realm or "Unknown"
end

local function now()
  if type(GetServerTime) == "function" then
    return GetServerTime()
  end
  if type(time) == "function" then
    return time()
  end
  return 0
end

local function bindName(slot)
  return "CLICK ShadowUIActionButton" .. tostring(slot) .. ":Keybind"
end

local function keysBySlot(self, binds)
  local out = {}
  for name, key in pairs(binds or {}) do
    local slot = self.SlotFromBindingName and self:SlotFromBindingName(name)
    if slot and key and key ~= "" then
      out[slot] = key
    end
  end
  return out
end

local function pagesFor(self, barId, cfg)
  if type(cfg) ~= "table" then
    return {}
  end
  local first = self.FirstActionSlot and self:FirstActionSlot(barId, cfg)
  return first and { first } or {}
end

local function macroBody(index, fromInfo)
  if type(fromInfo) == "string" then
    return fromInfo
  end
  if type(GetMacroBody) == "function" then
    return GetMacroBody(index) or ""
  end
  return ""
end

function Addon:PortableActionFromSlot(slot)
  if type(GetActionInfo) ~= "function" then
    return false
  end
  local actionType, id, subType = GetActionInfo(slot)
  if not actionType or actionType == "" then
    return false
  end
  if actionType == "spell" then
    local name = type(GetSpellInfo) == "function" and GetSpellInfo(id) or nil
    return {
      type = "spell",
      id = id,
      name = name or tostring(id),
      subType = subType,
    }
  end
  if actionType == "item" then
    local name = type(GetItemInfo) == "function" and GetItemInfo(id) or nil
    return {
      type = "item",
      id = id,
      name = name or tostring(id),
      subType = subType,
    }
  end
  if actionType == "macro" then
    local name, icon, body
    if type(GetMacroInfo) == "function" then
      name, icon, body = GetMacroInfo(id)
    end
    local accountCap = _G.MAX_ACCOUNT_MACROS or 120
    return {
      type = "macro",
      name = name or tostring(id),
      icon = icon,
      body = macroBody(id, body),
      scope = id > accountCap and "character" or "account",
    }
  end
  return {
    type = actionType,
    id = id,
    name = tostring(id),
    subType = subType,
    unsupported = true,
  }
end

function Addon:CurrentLoadoutKey()
  return table.concat({
    self:GetVersion(),
    currentRealm(),
    currentCharacter(),
  }, "/")
end

function Addon:BackupLoadoutKey()
  return "__backup__/" .. self:CurrentLoadoutKey()
end

function Addon:CaptureCurrentLoadout(isBackup)
  local cfg = self:ResolveEffective()
  local mergedBinds = cfg.keybinds or {}
  if self.MergeBindingTables and self.CollectClientActionBinds then
    mergedBinds = self:MergeBindingTables(self:CollectClientActionBinds(), mergedBinds)
  end
  local slotKeys = keysBySlot(self, mergedBinds)
  local snapshot = {
    schema = SCHEMA,
    character = currentCharacter(),
    realm = currentRealm(),
    class = self:GetPlayerClass(),
    version = self:GetVersion(),
    capturedAt = now(),
    activeVariant = self.GetActiveVariantName and self:GetActiveVariantName() or nil,
    backup = isBackup == true,
    layout = copy(self, cfg.layout or {}),
    keybinds = {},
    actions = {},
  }

  for _, barId in ipairs(STANDARD_BARS) do
    local barCfg = (cfg.layout or {})[barId] or {}
    local pages = pagesFor(self, barId, barCfg)
    local buttonCount = barCfg.buttons or 12
    local bindFirst = pages[1]
    snapshot.keybinds[barId] = {}
    for index = 1, buttonCount do
      snapshot.keybinds[barId][index] = (bindFirst and slotKeys[bindFirst + index - 1]) or false
    end
    snapshot.actions[barId] = { buttons = buttonCount, pages = {} }
    for pageIndex, first in ipairs(pages) do
      local page = { firstSlot = first, actions = {} }
      for index = 1, buttonCount do
        page.actions[index] = self:PortableActionFromSlot(first + index - 1)
      end
      snapshot.actions[barId].pages[pageIndex] = page
    end
  end
  return snapshot
end

function Addon:SaveCurrentLoadout(key, isBackup)
  local db = self:GetDB()
  db.loadouts = db.loadouts or {}
  local supplied = key and key ~= ""
  if not supplied then
    key = self:CurrentLoadoutKey()
  elseif not isBackup then
    key = self:GetVersion() .. "/named/" .. key
  end
  db.loadouts[key] = self:CaptureCurrentLoadout(isBackup)
  if not isBackup then
    self:Print("Saved Loadout Snapshot: " .. key)
  end
  return key
end

function Addon:DeleteLoadout(key)
  local loadouts = self:GetDB().loadouts or {}
  if not key or not loadouts[key] or loadouts[key].backup then
    return false
  end
  loadouts[key] = nil
  self:Print("Deleted Loadout Snapshot: " .. key)
  return true
end

function Addon:LoadoutValues(includeBackup)
  local values = {}
  for key, snapshot in pairs(self:GetDB().loadouts or {}) do
    if snapshot.version == self:GetVersion() and (includeBackup or not snapshot.backup) then
      local label = (snapshot.character or "?") .. " - " .. (snapshot.realm or "?")
        .. " (" .. (snapshot.class or "?") .. ")"
      local named = key:match("^[^/]+/named/(.+)$")
      if named then
        label = named .. " — " .. label
      end
      values[key] = snapshot.backup and ("Backup: " .. label) or label
    end
  end
  return values
end

function Addon:DefaultLoadoutOptions()
  local bars = {}
  for _, barId in ipairs(LAYOUT_BARS) do
    bars[barId] = true
  end
  return {
    actions = true,
    macros = true,
    keybinds = true,
    barLayout = true,
    otherLayout = false,
    selectedBars = bars,
    includeDisabledBars = false,
    exact = false,
    macroConflict = "skip",
    sourcePage = 0,
    targetPage = 0,
  }
end

local function selected(options, barId)
  return options.selectedBars == nil or options.selectedBars[barId] ~= false
end

local function addWarning(plan, text)
  plan.warnings[#plan.warnings + 1] = text
end

local function knownSpell(id)
  local checked = false
  if type(IsSpellKnown) == "function" then
    checked = true
    if IsSpellKnown(id) then
      return true
    end
  end
  if type(IsPlayerSpell) == "function" then
    checked = true
    if IsPlayerSpell(id) then
      return true
    end
  end
  if type(GetNumSpellTabs) == "function"
    and type(GetSpellTabInfo) == "function"
    and type(GetSpellBookItemInfo) == "function"
  then
    checked = true
    for tab = 1, GetNumSpellTabs() or 0 do
      local _, _, offset, count = GetSpellTabInfo(tab)
      for index = (offset or 0) + 1, (offset or 0) + (count or 0) do
        local _, spellId = GetSpellBookItemInfo(index, _G.BOOKTYPE_SPELL or "spell")
        if spellId == id then
          return true
        end
      end
    end
  end
  if checked then
    return false
  end
  return nil
end

local function allMacros()
  local records = {}
  local accountCount, characterCount = 0, 0
  if type(GetNumMacros) == "function" then
    accountCount, characterCount = GetNumMacros()
  end
  accountCount, characterCount = accountCount or 0, characterCount or 0
  local accountCap = _G.MAX_ACCOUNT_MACROS or 120
  for index = 1, accountCount do
    local name, icon, body = GetMacroInfo(index)
    records[#records + 1] = {
      index = index, name = name, icon = icon, body = macroBody(index, body), scope = "account",
    }
  end
  for localIndex = 1, characterCount do
    local index = accountCap + localIndex
    local name, icon, body = GetMacroInfo(index)
    records[#records + 1] = {
      index = index, name = name, icon = icon, body = macroBody(index, body), scope = "character",
    }
  end
  return records, characterCount
end

local function macroSignature(action)
  return (action.name or "") .. "\031" .. (action.body or "")
end

local function safeMacroName(base, used)
  base = (base and base ~= "" and base or "Loadout"):sub(1, 16)
  if not used[base] then
    used[base] = true
    return base
  end
  for number = 2, 999 do
    local suffix = tostring(number)
    local name = base:sub(1, 16 - #suffix) .. suffix
    if not used[name] then
      used[name] = true
      return name
    end
  end
  return nil
end

local function prepareMacros(plan, options)
  local existing, characterCount = allMacros()
  local bySignature, usedNames = {}, {}
  for _, macro in ipairs(existing) do
    bySignature[macroSignature(macro)] = macro.index
    if macro.name then
      usedNames[macro.name] = true
    end
  end
  local characterCap = _G.MAX_CHARACTER_MACROS or 18
  local remaining = math.max(0, characterCap - characterCount)
  local creates = {}

  for _, placement in ipairs(plan.actionOps) do
    local action = placement.action
    if not placement.skip and action and action ~= false and action.type == "macro" then
      local signature = macroSignature(action)
      local index = bySignature[signature]
      if index then
        placement.macroIndex = index
      elseif not options.macros then
        placement.skip = "macro is not loaded on the target"
      elseif creates[signature] then
        placement.macroCreate = signature
      elseif remaining <= 0 then
        placement.skip = "target character macro tab is full"
      else
        local nameConflict = usedNames[action.name or ""]
        if nameConflict and options.macroConflict ~= "character-copy" then
          placement.skip = "target has a different macro named " .. (action.name or "?")
        else
          local name = safeMacroName(action.name, usedNames)
          if not name then
            placement.skip = "could not make a unique macro name"
          else
            creates[signature] = {
              key = signature,
              name = name,
              icon = action.icon,
              body = action.body or "",
            }
            plan.macroCreates[#plan.macroCreates + 1] = creates[signature]
            placement.macroCreate = signature
            remaining = remaining - 1
          end
        end
      end
      if placement.skip then
        plan.skipped = plan.skipped + 1
        addWarning(plan, placement.barId .. " slot " .. placement.index .. ": " .. placement.skip)
      end
    end
  end
end

local function pairPages(plan, snapshot, sourceBar, targetPages, options, barId)
  local sourcePages = sourceBar.pages or {}
  if snapshot.class == plan.targetClass then
    local pairsOut = {}
    for index = 1, math.min(#sourcePages, #targetPages) do
      pairsOut[#pairsOut + 1] = { sourcePages[index], targetPages[index] }
    end
    return pairsOut
  end
  if #sourcePages <= 1 and #targetPages <= 1 then
    return sourcePages[1] and targetPages[1] and { { sourcePages[1], targetPages[1] } } or {}
  end
  local sourceIndex = tonumber(options.sourcePage) or 0
  local targetIndex = tonumber(options.targetPage) or 0
  if sourcePages[sourceIndex] and targetPages[targetIndex] then
    return { { sourcePages[sourceIndex], targetPages[targetIndex] } }
  end
  addWarning(plan, barId .. ": choose a source and target page for this cross-Class copy")
  return {}
end

local function visualFields(self, source, fields)
  local out = {}
  for _, field in ipairs(fields) do
    if source[field] ~= nil then
      out[field] = copy(self, source[field])
    end
  end
  return out
end

function Addon:BuildLoadoutPlan(key, options)
  options = options or self:DefaultLoadoutOptions()
  local snapshot = (self:GetDB().loadouts or {})[key]
  local plan = {
    key = key,
    snapshot = snapshot,
    options = copy(self, options),
    targetClass = self:GetPlayerClass(),
    actionOps = {},
    keybindOps = {},
    layoutOps = {},
    macroCreates = {},
    warnings = {},
    skipped = 0,
    canApply = true,
  }
  if not snapshot then
    plan.canApply = false
    addWarning(plan, "Loadout Snapshot not found")
    return plan
  end
  if snapshot.schema ~= SCHEMA then
    plan.canApply = false
    addWarning(plan, "Loadout Snapshot schema is not supported")
  end
  if snapshot.version ~= self:GetVersion() then
    plan.canApply = false
    addWarning(plan, "Loadout Snapshot Version does not match this client")
  end

  local targetCfg = self:ResolveEffective()
  local targetLayout = targetCfg.layout or {}
  local targetActionSlots = {}
  if options.barLayout then
    for _, barId in ipairs(LAYOUT_BARS) do
      if selected(options, barId) and type((snapshot.layout or {})[barId]) == "table" then
        plan.layoutOps[#plan.layoutOps + 1] = {
          id = barId,
          fields = visualFields(self, snapshot.layout[barId], BAR_VISUAL_FIELDS),
        }
      end
    end
    for _, extraId in ipairs({ "global", "barGroups" }) do
      if type((snapshot.layout or {})[extraId]) == "table" then
        plan.layoutOps[#plan.layoutOps + 1] = {
          id = extraId,
          fields = copy(self, snapshot.layout[extraId]),
        }
      end
    end
  end
  if options.otherLayout then
    for _, hostId in ipairs(HOSTS) do
      if type((snapshot.layout or {})[hostId]) == "table" then
        plan.layoutOps[#plan.layoutOps + 1] = {
          id = hostId,
          fields = copy(self, snapshot.layout[hostId]),
        }
      end
    end
  end

  for _, barId in ipairs(STANDARD_BARS) do
    if selected(options, barId) then
      local sourceBar = (snapshot.actions or {})[barId]
      local sourceKeys = (snapshot.keybinds or {})[barId] or {}
      local sourceLayout = (snapshot.layout or {})[barId] or {}
      local sourceEnabled = sourceLayout.enabled ~= false or options.includeDisabledBars
      local targetBarCfg = targetLayout[barId] or {}
      local targetPages = pagesFor(self, barId, targetBarCfg)
      local bindFirst = targetPages[1]
      local targetButtons = targetBarCfg.buttons or 12

      if options.keybinds and sourceEnabled and bindFirst then
        for index = 1, math.min(#sourceKeys, targetButtons) do
          plan.keybindOps[#plan.keybindOps + 1] = {
            barId = barId,
            index = index,
            slot = bindFirst + index - 1,
            key = sourceKeys[index],
          }
        end
      end

      if options.actions and sourceEnabled and sourceBar then
        for _, pair in ipairs(pairPages(plan, snapshot, sourceBar, targetPages, options, barId)) do
          local sourcePage, targetFirst = pair[1], pair[2]
          local buttonCount = math.min(sourceBar.buttons or 12, targetButtons)
          for index = 1, buttonCount do
            local action = sourcePage.actions[index]
            if action ~= false or options.exact then
              local targetSlot = targetFirst + index - 1
              local placement = {
                barId = barId,
                page = sourcePage.firstSlot,
                index = index,
                slot = targetSlot,
                action = copy(self, action),
              }
              local prior = targetActionSlots[targetSlot]
              if prior and not same(prior.action, action) then
                placement.skip = "target Action Slot " .. targetSlot
                  .. " is already mapped from " .. prior.barId
                plan.skipped = plan.skipped + 1
                addWarning(plan, barId .. " slot " .. index .. ": " .. placement.skip)
              elseif prior then
                placement = nil
              elseif action and action ~= false and action.type == "spell" then
                local available = knownSpell(action.id)
                if available == false then
                  placement.skip = "target does not know " .. (action.name or tostring(action.id))
                  plan.skipped = plan.skipped + 1
                  addWarning(plan, barId .. " slot " .. index .. ": " .. placement.skip)
                end
              elseif action and action ~= false and action.unsupported then
                placement.skip = "unsupported action type " .. tostring(action.type)
                plan.skipped = plan.skipped + 1
                addWarning(plan, barId .. " slot " .. index .. ": " .. placement.skip)
              end
              if placement then
                targetActionSlots[targetSlot] = placement
                plan.actionOps[#plan.actionOps + 1] = placement
              end
            end
          end
        end
      end
    end
  end

  if options.actions then
    prepareMacros(plan, options)
  end
  return plan
end

function Addon:DescribeLoadoutPlan(plan)
  if not plan then
    return "No Loadout copy preview."
  end
  local source = plan.snapshot
  local label = source and ((source.character or "?") .. " - " .. (source.realm or "?")) or "missing"
  return string.format(
    "%s: %d actions, %d Keybinds, %d Layout entries, %d new macros, %d skipped, %d warnings.",
    label,
    #plan.actionOps - plan.skipped,
    #plan.keybindOps,
    #plan.layoutOps,
    #plan.macroCreates,
    plan.skipped,
    #plan.warnings
  )
end

local function applyLayout(self, plan)
  if #plan.layoutOps == 0 then
    return
  end
  local char = self:GetCharDB()
  char.layout = char.layout or {}
  local inherited = (self:ResolveEffective(nil, nil, "variant").layout or {})
  for _, operation in ipairs(plan.layoutOps) do
    local target = char.layout[operation.id] or {}
    local baseline = inherited[operation.id] or {}
    for field, desired in pairs(operation.fields) do
      if same(desired, baseline[field]) then
        target[field] = nil
      else
        target[field] = copy(self, desired)
      end
    end
    char.layout[operation.id] = next(target) and target or nil
  end
end

local function applyKeybinds(self, plan)
  if #plan.keybindOps == 0 then
    return
  end
  local char = self:GetCharDB()
  char.keybinds = char.keybinds or {}
  local baselineCfg = self:ResolveEffective(nil, nil, "variant")
  local baseline = baselineCfg.keybinds or {}
  if self.MergeBindingTables and self.CollectClientActionBinds then
    baseline = self:MergeBindingTables(self:CollectClientActionBinds(), baseline)
  end
  local baselineSlots = keysBySlot(self, baseline)
  local copiedSlots = {}
  for _, operation in ipairs(plan.keybindOps) do
    copiedSlots[operation.slot] = true
  end

  -- A copied key must win over an inherited or Character bind on another slot.
  -- Write a tombstone for an unselected collision before writing the new map.
  local collisionSlots = {}
  for _, operation in ipairs(plan.keybindOps) do
    local desired = operation.key
    if desired and desired ~= "" then
      for slot, key in pairs(baselineSlots) do
        if key == desired and slot ~= operation.slot and not copiedSlots[slot] then
          collisionSlots[slot] = true
        end
      end
      for name, key in pairs(char.keybinds) do
        local slot = self:SlotFromBindingName(name)
        if key == desired and slot and slot ~= operation.slot and not copiedSlots[slot] then
          collisionSlots[slot] = true
        end
      end
    end
  end
  for slot in pairs(collisionSlots) do
    for name in pairs(char.keybinds) do
      if self:SlotFromBindingName(name) == slot then
        char.keybinds[name] = nil
      end
    end
    char.keybinds[bindName(slot)] = false
  end

  for _, operation in ipairs(plan.keybindOps) do
    for name in pairs(char.keybinds) do
      if self:SlotFromBindingName(name) == operation.slot then
        char.keybinds[name] = nil
      end
    end
    local desired = operation.key
    local name = bindName(operation.slot)
    if desired == baselineSlots[operation.slot] then
      char.keybinds[name] = nil
    elseif desired and desired ~= "" then
      char.keybinds[name] = desired
    else
      char.keybinds[name] = false
    end
  end
end

local function cursorHasAction()
  if type(GetCursorInfo) ~= "function" then
    return true
  end
  local actionType = GetCursorInfo()
  return actionType ~= nil and actionType ~= ""
end

local function pickupPortable(operation, created)
  local action = operation.action
  if not action or action == false then
    return false
  end
  if action.type == "spell" then
    if _G.C_Spell and type(_G.C_Spell.PickupSpell) == "function" then
      pcall(_G.C_Spell.PickupSpell, action.id)
      if cursorHasAction() then
        return true
      end
    end
    if type(PickupSpell) == "function" then
      pcall(PickupSpell, action.id)
      return cursorHasAction()
    end
  elseif action.type == "item" and type(PickupItem) == "function" then
    pcall(PickupItem, action.id)
    return cursorHasAction()
  elseif action.type == "macro" and type(PickupMacro) == "function" then
    local index = operation.macroIndex or created[operation.macroCreate]
    if index then
      pcall(PickupMacro, index)
      return cursorHasAction()
    end
  end
  return false
end

local function createPlanMacros(plan)
  local created = {}
  if type(CreateMacro) ~= "function" then
    return created
  end
  for _, macro in ipairs(plan.macroCreates) do
    local ok, index = pcall(
      CreateMacro,
      macro.name,
      macro.icon or "INV_MISC_QUESTIONMARK",
      macro.body or "",
      true
    )
    if ok and type(index) == "number" then
      created[macro.key] = index
    end
  end
  return created
end

local function applyActions(self, plan, created)
  local applicable, needsPlace, needsClear = 0, false, false
  for _, operation in ipairs(plan.actionOps) do
    if not operation.skip then
      applicable = applicable + 1
      if operation.action ~= false then
        needsPlace = true
      else
        needsClear = true
      end
    end
  end
  if applicable == 0 then
    return 0
  end
  if type(ClearCursor) ~= "function"
    or (needsClear and type(PickupAction) ~= "function")
    or (needsPlace and type(PlaceAction) ~= "function")
  then
    return applicable
  end
  local failures = 0
  local run = function()
    ClearCursor()
    for _, operation in ipairs(plan.actionOps) do
      if not operation.skip then
        local ok = pcall(function()
          if operation.action == false then
            if type(PickupAction) == "function" then
              PickupAction(operation.slot)
              ClearCursor()
            else
              error("action clear is unavailable")
            end
          elseif pickupPortable(operation, created) then
            PlaceAction(operation.slot)
            ClearCursor()
          else
            error("action pickup failed")
          end
        end)
        if not ok then
          failures = failures + 1
          pcall(ClearCursor)
        end
      end
    end
  end
  local ok = pcall(function()
    if self.WithUnlockedActionBars then
      self:WithUnlockedActionBars(run)
    else
      run()
    end
  end)
  if not ok then
    failures = failures + 1
    pcall(ClearCursor)
  end
  return failures
end

function Addon:ApplyLoadoutPlan(plan, skipBackup)
  if not plan or not plan.canApply then
    self:Print("Loadout copy cannot apply. Preview the warnings.")
    return false
  end
  if type(InCombatLockdown) == "function" and InCombatLockdown() then
    self:Print("Leave combat to apply a Loadout Snapshot.")
    return false
  end
  if not skipBackup then
    self:SaveCurrentLoadout(self:BackupLoadoutKey(), true)
  end
  local created = createPlanMacros(plan)
  applyLayout(self, plan)
  applyKeybinds(self, plan)
  local failures = applyActions(self, plan, created)
  if self.ApplyAll then
    self:ApplyAll()
  end
  if failures > 0 then
    self:Print(self:DescribeLoadoutPlan(plan) .. " " .. failures .. " actions could not be placed.")
  else
    self:Print("Applied " .. self:DescribeLoadoutPlan(plan))
  end
  return failures == 0
end

function Addon:ApplyLoadout(key, options, skipBackup)
  return self:ApplyLoadoutPlan(self:BuildLoadoutPlan(key, options), skipBackup)
end

function Addon:RestoreLoadoutBackup()
  local key = self:BackupLoadoutKey()
  local options = self:DefaultLoadoutOptions()
  options.otherLayout = true
  options.exact = true
  options.includeDisabledBars = true
  return self:ApplyLoadout(key, options, true)
end

function Addon:FindLoadoutKey(query)
  query = query and query:match("^%s*(.-)%s*$") or ""
  local loadouts = self:GetDB().loadouts or {}
  local namedKey = self:GetVersion() .. "/named/" .. query
  if query ~= "" and loadouts[namedKey] and not loadouts[namedKey].backup then
    return namedKey
  end
  if query ~= "" and loadouts[query] and not loadouts[query].backup
    and loadouts[query].version == self:GetVersion()
  then
    return query
  end
  local found
  for key, snapshot in pairs(loadouts) do
    if not snapshot.backup and snapshot.version == self:GetVersion() then
      local label = (snapshot.character or "") .. " - " .. (snapshot.realm or "")
      if query == "" or label:lower():find(query:lower(), 1, true) then
        if found then
          return nil
        end
        found = key
      end
    end
  end
  return found
end

function Addon:HandleLoadoutCommand(rest)
  local action, query = (rest or ""):match("^(%S*)%s*(.-)%s*$")
  action = (action or ""):lower()
  if action == "save" then
    self:SaveCurrentLoadout(query ~= "" and query or nil)
    return
  end
  if action == "restore" then
    self:RestoreLoadoutBackup()
    return
  end
  local key = self:FindLoadoutKey(query)
  if not key then
    self:Print("Choose one Loadout Snapshot in /shadowui, or give its exact name.")
    return
  end
  if action == "preview" then
    local plan = self:BuildLoadoutPlan(key, self:DefaultLoadoutOptions())
    self:Print(self:DescribeLoadoutPlan(plan))
    for _, warning in ipairs(plan.warnings) do
      self:Print(warning)
    end
  elseif action == "apply" then
    self:ApplyLoadout(key, self:DefaultLoadoutOptions())
  elseif action == "delete" then
    self:DeleteLoadout(key)
  else
    self:Print("Usage: /shadowui loadout save|preview|apply|delete|restore [name]")
  end
end
