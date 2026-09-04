# ShadowUI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a Classic Era addon that auto-applies class-profiled action bars, selective chrome skins, and a fixed cast/GCD bar via Base → Class → Variant inheritance.

**Architecture:** AceAddon bootstrap with AceDB account + character stores; `resolve.lua` merges shipped defaults with sparse layer overlays into an effective layout; custom LibActionButton bars replace Blizzard bar chrome; skin/cast/edit/options modules consume the resolved config only.

**Tech Stack:** Lua (WoW Classic Era API), Ace3 (Addon/Event/DB/Config/Console/GUI), LibStub, CallbackHandler-1.0, LibActionButton-1.0, Interface `11509`

## Global Constraints

- Target: Classic Era only — Interface `11509` (patch 1.15.9)
- Addon name: `ShadowUI`; SVs: `ShadowUIDB` (account), `ShadowUICharDB` (character)
- Profiles by **class**, not character; inheritance **Base → Class → Variant**
- Visual buttons: flush square icons, zero gap; empty Action Slots stay empty; Blizzard chrome uses Lorti vertex colors
- Cast/GCD bar fixed by design — no AceConfig options for it
- File size: prefer ≤120 lines, hard cap ~200; no undeclared globals; public API on `ShadowUI` table
- Every Lua file starts with header (purpose, deps, public API)
- Keybind apply respects combat lockdown; queue until `PLAYER_REGEN_ENABLED`
- pnpm/JS tooling does not apply — this is a Lua WoW addon
- Do not comment code beyond required file headers
- Prefer clarity in merge/resolve — correctness core

---

### Task 1: Scaffold TOC, libs loader, README

**Files:**
- Create: `ShadowUI.toc`
- Create: `libs/LibStub/LibStub.lua` (vendor)
- Create: `libs/CallbackHandler-1.0/CallbackHandler-1.0.lua` (vendor)
- Create: `libs/embeds.xml`
- Create: `README.md`
- Create: `scripts/vendor-libs.sh`

**Interfaces:**
- Consumes: none
- Produces: loadable addon shell; libs path convention under `libs/`

- [ ] **Step 1: Create TOC**

```toc
## Interface: 11509
## Title: ShadowUI
## Notes: Opinionated Classic Era bars, chrome, and cast bar. Class-profiled Base → Class → Variant layouts.
## Author: Parker Westfall
## Version: 0.1.0
## SavedVariables: ShadowUIDB
## SavedVariablesPerCharacter: ShadowUICharDB

libs\embeds.xml

core\init.lua
core\db.lua
core\resolve.lua

defaults\base.lua
defaults\classes\WARRIOR.lua
defaults\classes\PALADIN.lua
defaults\classes\HUNTER.lua
defaults\classes\ROGUE.lua
defaults\classes\PRIEST.lua
defaults\classes\SHAMAN.lua
defaults\classes\MAGE.lua
defaults\classes\WARLOCK.lua
defaults\classes\DRUID.lua

bars\button.lua
bars\bar.lua
bars\special.lua
bars\manager.lua

cast\castbar.lua
cast\gcd.lua

skin\chrome.lua
skin\chat.lua
skin\micro.lua
skin\minimap.lua

edit\mode.lua
edit\layer.lua

profile\variants.lua

options\config.lua
```

- [ ] **Step 2: Create libs embed XML stub and vendor script**

`libs/embeds.xml`:

```xml
<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.blizzard.com/wow/ui/
..\FrameXML\UI.xsd">
  <Script file="LibStub\LibStub.lua"/>
  <Include file="CallbackHandler-1.0\CallbackHandler-1.0.xml"/>
  <Include file="AceAddon-3.0\AceAddon-3.0.xml"/>
  <Include file="AceEvent-3.0\AceEvent-3.0.xml"/>
  <Include file="AceDB-3.0\AceDB-3.0.xml"/>
  <Include file="AceDBOptions-3.0\AceDBOptions-3.0.xml"/>
  <Include file="AceConsole-3.0\AceConsole-3.0.xml"/>
  <Include file="AceGUI-3.0\AceGUI-3.0.xml"/>
  <Include file="AceConfig-3.0\AceConfig-3.0.xml"/>
  <Include file="AceConfig-3.0\AceConfigRegistry-3.0\AceConfigRegistry-3.0.xml"/>
  <Include file="AceConfig-3.0\AceConfigCmd-3.0\AceConfigCmd-3.0.xml"/>
  <Include file="AceConfig-3.0\AceConfigDialog-3.0\AceConfigDialog-3.0.xml"/>
  <Include file="LibActionButton-1.0\LibActionButton-1.0.lua"/>
</Ui>
```

`scripts/vendor-libs.sh` — clone/copy from BigWigsMods/packager-style sources into `libs/` (Ace3 from `WoWUI/Ace3` or `https://github.com/nebularg/wow-Ace3`, LibActionButton from `https://github.com/sylvanaar/LibActionButton-1.0`). Run the script and confirm each path in `embeds.xml` exists.

- [ ] **Step 3: Write README**

Cover: install path `Interface/AddOns/ShadowUI`, slash commands from the spec, Base → Class → Variant model, Classic Era only.

- [ ] **Step 4: Commit**

```bash
git add ShadowUI.toc libs README.md scripts/vendor-libs.sh
git commit -m "$(cat <<'EOF'
Scaffold ShadowUI TOC, lib embeds, and README.

EOF
)"
```

---

### Task 2: Core bootstrap — init + AceDB schema

**Files:**
- Create: `core/init.lua`
- Create: `core/db.lua`

**Interfaces:**
- Consumes: AceAddon-3.0, AceEvent-3.0, AceDB-3.0, AceConsole-3.0
- Produces:
  - `ShadowUI` AceAddon object
  - `ShadowUI:GetDB()` → account AceDB root (`ShadowUIDB`)
  - `ShadowUI:GetCharDB()` → character AceDB root (`ShadowUICharDB`)
  - `ShadowUI:GetPlayerClass()` → `"WARRIOR"` etc. (uppercase token)
  - Defaults registered in `db.lua` matching the spec schema

- [ ] **Step 1: Write `core/db.lua`**

```lua
--[[
  Purpose: AceDB schema and default registration for account + character stores.
  Deps: AceDB-3.0, ShadowUI addon table
  Public: ShadowUI:SetupDB(), ShadowUI:GetDB(), ShadowUI:GetCharDB()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

local ACCOUNT_DEFAULTS = {
  profile = {
    base = {
      layout = {},
      keybinds = {},
    },
    classes = {},
  },
}

local CHAR_DEFAULTS = {
  profile = {
    activeVariant = nil,
    editLayer = "variant",
    variantManual = false,
  },
}

function Addon:SetupDB()
  self.db = LibStub("AceDB-3.0"):New("ShadowUIDB", ACCOUNT_DEFAULTS, true)
  self.chardb = LibStub("AceDB-3.0"):New("ShadowUICharDB", CHAR_DEFAULTS, true)
end

function Addon:GetDB()
  return self.db.profile
end

function Addon:GetCharDB()
  return self.chardb.profile
end
```

- [ ] **Step 2: Write `core/init.lua`**

```lua
--[[
  Purpose: AceAddon bootstrap and first-run apply lifecycle.
  Deps: AceAddon-3.0, AceEvent-3.0, AceConsole-3.0; modules loaded later by TOC
  Public: ShadowUI addon table, ShadowUI:GetPlayerClass(), ShadowUI:ApplyAll()
]]

local Addon = LibStub("AceAddon-3.0"):NewAddon("ShadowUI", "AceEvent-3.0", "AceConsole-3.0")

function Addon:OnInitialize()
  self:SetupDB()
  self:RegisterChatCommand("shadowui", "SlashCommand")
end

function Addon:OnEnable()
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerReady")
  self:RegisterEvent("PLAYER_REGEN_ENABLED", "FlushPendingKeybinds")
  self:RegisterEvent("PLAYER_TALENT_UPDATE", "OnTalentUpdate")
end

function Addon:GetPlayerClass()
  local _, classFile = UnitClass("player")
  return classFile
end

function Addon:OnPlayerReady()
  if self._appliedOnce then
    return
  end
  self._appliedOnce = true
  self:ApplyAll()
end

function Addon:ApplyAll()
  local cfg = self:ResolveEffective()
  self:ApplyBars(cfg)
  self:ApplyKeybinds(cfg)
  self:ApplySkins()
  self:ApplyCastBar()
end

function Addon:SlashCommand(input)
  input = (input or ""):match("^%s*(.-)%s*$") or ""
  if input == "" then
    self:OpenOptions()
    return
  end
  local cmd, rest = input:match("^(%S+)%s*(.*)$")
  cmd = cmd and cmd:lower() or ""
  if cmd == "edit" then
    self:ToggleEditMode()
  elseif cmd == "layer" then
    self:SetEditLayer(rest)
  elseif cmd == "variant" then
    self:HandleVariantCommand(rest)
  else
    self:Print("Usage: /shadowui [edit|layer|variant]")
  end
end
```

Stub methods that later tasks fill: `ResolveEffective`, `ApplyBars`, `ApplyKeybinds`, `ApplySkins`, `ApplyCastBar`, `FlushPendingKeybinds`, `OnTalentUpdate`, `OpenOptions`, `ToggleEditMode`, `SetEditLayer`, `HandleVariantCommand` — define empty no-op stubs in init until their modules override via assignment on `Addon`.

- [ ] **Step 3: Smoke-check file load order**

Confirm TOC lists `core/init.lua` before `core/db.lua` is wrong — **db must load after init creates the addon**. Order in TOC: `core\init.lua` then `core\db.lua` (init creates addon; db attaches methods). Fix TOC if needed.

- [ ] **Step 4: Commit**

```bash
git add core/init.lua core/db.lua ShadowUI.toc
git commit -m "$(cat <<'EOF'
Add AceAddon bootstrap and AceDB schema.

EOF
)"
```

---

### Task 3: Resolve — sparse Base → Class → Variant merge

**Files:**
- Create: `core/resolve.lua`
- Create: `tests/resolve_spec.lua` (pure-Lua merge tests runnable with `lua`/`luajit` if available)

**Interfaces:**
- Consumes: `ShadowUI:GetDB()`, `ShadowUI:GetCharDB()`, `ShadowUI:GetPlayerClass()`, shipped defaults via `ShadowUI.Defaults`
- Produces:
  - `ShadowUI:DeepCopy(t)` → table
  - `ShadowUI:SparseMerge(base, overlay)` → mutates/returns merged table (overlay fields win; nested tables merge sparsely)
  - `ShadowUI:ResolveEffective(classFile?, variantName?)` → `{ layout = {}, keybinds = {} }`
  - `ShadowUI:WriteLayerDelta(layer, path, value)` — writes only into selected layer store

- [ ] **Step 1: Write failing pure-Lua merge test**

`tests/resolve_spec.lua` (self-contained copy of merge helpers for offline test, or require pattern if Lua path allows):

```lua
local function SparseMerge(dst, src)
  if type(src) ~= "table" then return dst end
  for k, v in pairs(src) do
    if type(v) == "table" and type(dst[k]) == "table" then
      SparseMerge(dst[k], v)
    else
      if type(v) == "table" then
        local copy = {}
        SparseMerge(copy, v)
        dst[k] = copy
      else
        dst[k] = v
      end
    end
  end
  return dst
end

local base = { layout = { bar1 = { x = 0, y = 0, scale = 1, enabled = true } } }
local class = { layout = { bar1 = { y = 40 }, stance = { x = 10, y = 80, enabled = true } } }
local variant = { layout = { bar1 = { scale = 1.2 } } }

local eff = {}
SparseMerge(eff, base)
SparseMerge(eff, class)
SparseMerge(eff, variant)

assert(eff.layout.bar1.x == 0)
assert(eff.layout.bar1.y == 40)
assert(eff.layout.bar1.scale == 1.2)
assert(eff.layout.bar1.enabled == true)
assert(eff.layout.stance.x == 10)
print("resolve_spec OK")
```

- [ ] **Step 2: Run test**

```bash
lua tests/resolve_spec.lua || luajit tests/resolve_spec.lua
```

Expected: `resolve_spec OK`

- [ ] **Step 3: Implement `core/resolve.lua`**

```lua
--[[
  Purpose: Merge shipped defaults with account Base → Class → Variant into effective config.
  Deps: ShadowUI db helpers, ShadowUI.Defaults
  Public: DeepCopy, SparseMerge, ResolveEffective, GetActiveVariantName, WriteLayerDelta
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")

function Addon:DeepCopy(src)
  if type(src) ~= "table" then return src end
  local out = {}
  for k, v in pairs(src) do
    out[k] = self:DeepCopy(v)
  end
  return out
end

function Addon:SparseMerge(dst, src)
  if type(src) ~= "table" then return dst end
  for k, v in pairs(src) do
    if type(v) == "table" and type(dst[k]) == "table" then
      self:SparseMerge(dst[k], v)
    elseif type(v) == "table" then
      dst[k] = self:DeepCopy(v)
    else
      dst[k] = v
    end
  end
  return dst
end

function Addon:GetActiveVariantName(classFile)
  classFile = classFile or self:GetPlayerClass()
  local char = self:GetCharDB()
  if char.variantManual and char.activeVariant then
    return char.activeVariant
  end
  local classData = self:GetDB().classes[classFile]
  if not classData or not classData.variants then
    return char.activeVariant
  end
  local tree = self:GetPrimaryTalentTree()
  if tree then
    for name, variant in pairs(classData.variants) do
      if variant.talentTree == tree then
        return name
      end
    end
  end
  return char.activeVariant
end

function Addon:GetPrimaryTalentTree()
  local best, bestPts = nil, -1
  for i = 1, GetNumTalentTabs() do
    local _, _, _, _, points = GetTalentTabInfo(i)
    if points and points > bestPts then
      best, bestPts = i, points
    end
  end
  if bestPts <= 0 then return nil end
  return best
end

function Addon:ResolveEffective(classFile, variantName)
  classFile = classFile or self:GetPlayerClass()
  variantName = variantName or self:GetActiveVariantName(classFile)

  local shipped = self.Defaults or { base = { layout = {}, keybinds = {} }, classes = {} }
  local account = self:GetDB()

  local eff = { layout = {}, keybinds = {} }
  self:SparseMerge(eff, shipped.base or {})
  self:SparseMerge(eff, (shipped.classes[classFile] or {}))
  self:SparseMerge(eff, account.base or {})
  local classAcc = account.classes[classFile]
  if classAcc then
    self:SparseMerge(eff, { layout = classAcc.layout or {}, keybinds = classAcc.keybinds or {} })
    local variant = variantName and classAcc.variants and classAcc.variants[variantName]
    if variant then
      self:SparseMerge(eff, { layout = variant.layout or {}, keybinds = variant.keybinds or {} })
    end
  end
  return eff
end

function Addon:WriteLayerDelta(layer, section, key, patch)
  local classFile = self:GetPlayerClass()
  local db = self:GetDB()
  layer = layer or self:GetCharDB().editLayer or "variant"

  if layer == "base" then
    db.base[section] = db.base[section] or {}
    db.base[section][key] = db.base[section][key] or {}
    self:SparseMerge(db.base[section][key], patch)
    return
  end

  db.classes[classFile] = db.classes[classFile] or { layout = {}, keybinds = {}, variants = {} }
  local classAcc = db.classes[classFile]

  if layer == "class" then
    classAcc[section] = classAcc[section] or {}
    classAcc[section][key] = classAcc[section][key] or {}
    self:SparseMerge(classAcc[section][key], patch)
    return
  end

  local name = self:GetActiveVariantName(classFile) or "Default"
  classAcc.variants = classAcc.variants or {}
  classAcc.variants[name] = classAcc.variants[name] or { layout = {}, keybinds = {} }
  local variant = classAcc.variants[name]
  variant[section] = variant[section] or {}
  variant[section][key] = variant[section][key] or {}
  self:SparseMerge(variant[section][key], patch)
end
```

- [ ] **Step 4: Commit**

```bash
git add core/resolve.lua tests/resolve_spec.lua
git commit -m "$(cat <<'EOF'
Add sparse Base→Class→Variant resolve core.

EOF
)"
```

---

### Task 4: Shipped defaults — base layout + class sparse deltas

**Files:**
- Create: `defaults/base.lua`
- Create: `defaults/classes/WARRIOR.lua` (and PALADIN, HUNTER, ROGUE, PRIEST, SHAMAN, MAGE, WARLOCK, DRUID)

**Interfaces:**
- Consumes: none (registers into `ShadowUI.Defaults`)
- Produces: `ShadowUI.Defaults.base`, `ShadowUI.Defaults.classes[CLASS]`
- Bar IDs: `bar1`…`bar10`, `pet`, `stance`, `aura`, `form`, `possess` (use only those that exist for Classic Era)
- Grid: button size `36`, gap `0`; base bars centered lower-middle

- [ ] **Step 1: Create `defaults/base.lua`**

Define 10 action bars + pet/possess placeholders, all `enabled = true`, columns matching button count or 12, scale `1`, points relative to `UIParent` center-bottom cluster (e.g. bar1 at `CENTER, 0, -180`, bar2 above/below on 36px grid). Include empty `keybinds = {}`.

```lua
--[[
  Purpose: Shared centered Base layout; all standard bars enabled.
  Deps: ShadowUI addon table
  Public: populates ShadowUI.Defaults.base
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults = Addon.Defaults or { base = {}, classes = {} }

local SIZE = 36
local function bar(point, x, y, buttons, columns)
  return {
    point = point or "CENTER",
    relativeTo = "UIParent",
    relativePoint = point or "CENTER",
    x = x, y = y,
    buttons = buttons or 12,
    columns = columns or 12,
    scale = 1,
    enabled = true,
    buttonSize = SIZE,
  }
end

Addon.Defaults.base = {
  layout = {
    bar1 = bar("CENTER", 0, -200, 12, 12),
    bar2 = bar("CENTER", 0, -236, 12, 12),
    bar3 = bar("CENTER", 0, -272, 12, 12),
    bar4 = bar("CENTER", -252, -200, 12, 1),
    bar5 = bar("CENTER", 252, -200, 12, 1),
    bar6 = bar("CENTER", 0, -308, 12, 12),
    bar7 = bar("CENTER", 0, -344, 12, 12),
    bar8 = bar("CENTER", 0, -380, 12, 12),
    bar9 = bar("CENTER", 0, -416, 12, 12),
    bar10 = bar("CENTER", 0, -452, 12, 12),
    pet = bar("CENTER", -252, -272, 10, 10),
    possess = bar("CENTER", 0, -160, 2, 2),
  },
  keybinds = {},
}
```

- [ ] **Step 2: Create class files**

Each file only adds sparse special-bar placement. Examples:

- `WARRIOR.lua`: `stance = { point="CENTER", x=0, y=-140, buttons=4, columns=4, enabled=true }`
- `PALADIN.lua`: `aura` bar delta
- `DRUID.lua`: `form` bar delta
- `HUNTER.lua` / `WARLOCK.lua`: ensure `pet` offset if needed
- Others: empty `layout = {}` if no special bar

Pattern:

```lua
local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults.classes.WARRIOR = {
  layout = {
    stance = { point = "CENTER", relativeTo = "UIParent", relativePoint = "CENTER", x = 0, y = -140, buttons = 4, columns = 4, scale = 1, enabled = true, buttonSize = 36 },
  },
  keybinds = {},
}
```

- [ ] **Step 3: Commit**

```bash
git add defaults/
git commit -m "$(cat <<'EOF'
Add shipped Base layout and class sparse defaults.

EOF
)"
```

---

### Task 5: Flush LAB buttons + bar frames

**Files:**
- Create: `bars/button.lua`
- Create: `bars/bar.lua`

**Interfaces:**
- Consumes: LibActionButton-1.0
- Produces:
  - `ShadowUI:CreateBarButton(parent, id, actionSlot)` → LAB button
  - `ShadowUI:CreateBar(barId, cfg)` → bar frame with grid of flush buttons
  - `ShadowUI:UpdateBarLayout(bar, cfg)` — columns, scale, position
  - Button size from `cfg.buttonSize` (default 36); spacing always `0`

- [ ] **Step 1: Implement `bars/button.lua`**

Create LAB buttons with no normal texture / pushed / checked border padding. Strip Blizzard artwork; icon set to full button size (`SetAllPoints`). Export factory on Addon.

- [ ] **Step 2: Implement `bars/bar.lua`**

- Frame strata `MEDIUM`, backdrop black (`bgFile` solid, edge none)
- Soft shadow: child texture or second backdrop frame offset +2,+2 with low alpha black
- Buttons packed in row-major grid: `columns`, `buttons`, `buttonSize`, gap `0`
- Drag header enabled only when edit mode flag `ShadowUI.editMode` is true
- Map every standard Bar to one fixed 12-slot range. Class states do not change bar1.

- [ ] **Step 3: Commit**

```bash
git add bars/button.lua bars/bar.lua
git commit -m "$(cat <<'EOF'
Add flush LibActionButton bars with black chrome.

EOF
)"
```

---

### Task 6: Bar manager + special bars + Blizzard hide

**Files:**
- Create: `bars/special.lua`
- Create: `bars/manager.lua`

**Interfaces:**
- Consumes: `CreateBar`, `UpdateBarLayout`, `ResolveEffective`
- Produces:
  - `ShadowUI:ApplyBars(cfg)`
  - `ShadowUI:HideBlizzardBars()`
  - Stance/aura/form/pet/possess bars wired to correct action/state

- [ ] **Step 1: `bars/special.lua`**

Wire:
- Stance/Shapeshift via LAB or custom buttons bound to stance commands as appropriate for Classic
- Pet bar → pet action slots
- Possess bar → possess actions
- Enable only when `cfg.layout[id].enabled` and class needs them

- [ ] **Step 2: `bars/manager.lua`**

```lua
function Addon:ApplyBars(cfg)
  self:HideBlizzardBars()
  self.bars = self.bars or {}
  for barId, barCfg in pairs(cfg.layout) do
    if barCfg.enabled ~= false then
      local bar = self.bars[barId]
      if not bar then
        bar = self:CreateBar(barId, barCfg)
        self.bars[barId] = bar
      end
      self:UpdateBarLayout(bar, barCfg)
      bar:Show()
    elseif self.bars[barId] then
      self.bars[barId]:Hide()
    end
  end
end

function Addon:HideBlizzardBars()
  local frames = {
    MainMenuBar, MainMenuBarArtFrame, MainMenuBarOverlayFrame,
    MainMenuBarMaxLevelBar, MultiBarBottomLeft, MultiBarBottomRight,
    MultiBarLeft, MultiBarRight, PossessBarFrame, PetActionBarFrame,
    ShapeshiftBarFrame, StanceBarFrame,
  }
  for _, f in ipairs(frames) do
    if f then
      f:Hide()
      f:UnregisterAllEvents()
      f:SetScript("OnShow", f.Hide)
    end
  end
end
```

Adjust names to Classic Era frame names that exist; skip nils safely.

- [ ] **Step 3: Commit**

```bash
git add bars/special.lua bars/manager.lua
git commit -m "$(cat <<'EOF'
Add bar manager, special bars, and Blizzard bar hide.

EOF
)"
```

---

### Task 7: Keybind apply with combat queue

**Files:**
- Modify: `core/init.lua` (or create `core/keybinds.lua` if init would exceed ~120 lines — prefer new file `core/keybinds.lua` + TOC entry after resolve)

**Interfaces:**
- Consumes: resolved `cfg.keybinds` map `{ [bindingName] = key }`
- Produces: `ShadowUI:ApplyKeybinds(cfg)`, `ShadowUI:FlushPendingKeybinds()`

- [ ] **Step 1: Implement deferred apply**

```lua
function Addon:ApplyKeybinds(cfg)
  self._pendingKeybinds = cfg.keybinds or {}
  if InCombatLockdown() then
    return
  end
  self:FlushPendingKeybinds()
end

function Addon:FlushPendingKeybinds()
  local binds = self._pendingKeybinds
  if not binds or InCombatLockdown() then return end
  for name, key in pairs(binds) do
    if key and key ~= "" then
      SetBinding(key, name)
    end
  end
  SaveBindings(GetCurrentBindingSet())
  self._pendingKeybinds = nil
end
```

Only set bindings present in the profile map; do not wipe the entire binding set in v1 unless a key is explicitly cleared in data.

- [ ] **Step 2: Commit**

```bash
git add core/keybinds.lua ShadowUI.toc
git commit -m "$(cat <<'EOF'
Apply keybinds with combat-lockdown deferral.

EOF
)"
```

---

### Task 8: Chrome skins — bars, chat, micro/bags, minimap

**Files:**
- Create: `skin/chrome.lua`
- Create: `skin/chat.lua`
- Create: `skin/micro.lua`
- Create: `skin/minimap.lua`

**Interfaces:**
- Consumes: created ShadowUI bars
- Produces: `ShadowUI:ApplySkins()` orchestrating all four

- [ ] **Step 1: `skin/chrome.lua`** — hide any leftover Bar fill so empty Action Slots stay empty (`ApplyBarChrome(frame)`).

- [ ] **Step 2: `skin/chat.lua`** — for ChatFrame1–N and their backgrounds: set backdrop to black at ~0.6 alpha; leave font/default behavior alone.

- [ ] **Step 3: `skin/micro.lua`** — dock CharacterMicroButton…HelpMicroButton and the backpack to `UIParent` `BOTTOMRIGHT` with no inset. Keep native Blizzard size and art. Hide Store.

- [ ] **Step 4: `skin/minimap.lua`** — hide minimap mask/border art where possible; square large minimap (~250px); black backdrop; keep zoom/mail if present; position upper-right unless Base later overrides (fixed for v1 is fine).

- [ ] **Step 5: `ApplySkins`**

```lua
function Addon:ApplySkins()
  self:SkinBarChrome()
  self:SkinChat()
  self:SkinMicroAndBags()
  self:SkinMinimap()
end
```

- [ ] **Step 6: Commit**

```bash
git add skin/
git commit -m "$(cat <<'EOF'
Add selective chrome skins for bars, chat, micro, minimap.

EOF
)"
```

---

### Task 9: Fixed cast bar + GCD underlay

**Files:**
- Create: `cast/castbar.lua`
- Create: `cast/gcd.lua`

**Interfaces:**
- Consumes: player cast/channel events; GCD via `GetSpellCooldown` / spell book GCD spell
- Produces: `ShadowUI:ApplyCastBar()` — creates/shows fixed bar; hides Blizzard `CastingBarFrame`

- [ ] **Step 1: `cast/castbar.lua`**

- Centered horizontally, `y` above bar cluster (~`-120` from center or anchored above `bar1`)
- Width ≈ primary bar width (`12 * 36`), height ~18–22
- StatusBar with gradient (e.g. dark slate → brighter fill); spark optional
- Events: `UNIT_SPELLCAST_*`, `UNIT_SPELLCAST_CHANNEL_*` for `"player"`
- Hide `CastingBarFrame` permanently (`Hide` + `OnShow = Hide`)

- [ ] **Step 2: `cast/gcd.lua`**

- Thin bar directly under cast bar
- On spell cast / GCD start, fill from full→empty over GCD duration
- No config options

- [ ] **Step 3: Commit**

```bash
git add cast/
git commit -m "$(cat <<'EOF'
Add fixed Quartz-like cast bar and GCD underlay.

EOF
)"
```

---

### Task 10: Edit mode + layer picker

**Files:**
- Create: `edit/mode.lua`
- Create: `edit/layer.lua`

**Interfaces:**
- Consumes: `WriteLayerDelta`, bar frames
- Produces:
  - `ShadowUI:ToggleEditMode()`
  - `ShadowUI:SetEditLayer(layer)` — `"base"|"class"|"variant"`
  - Snap grid overlay (36px)
  - On exit: persist dragged bar positions into selected layer, `ApplyAll()`

- [ ] **Step 1: `edit/layer.lua`**

Layer picker frame always visible in edit mode with three buttons. Default from `chardb.editLayer`. `/shadowui layer X` calls `SetEditLayer`.

- [ ] **Step 2: `edit/mode.lua`**

- Toggle shows grid texture/frame covering UIParent
- Enables bar dragging; on drag stop, compute snapped `x,y` and `WriteLayerDelta(layer, "layout", barId, { point, x, y, ... })`
- Bindable key via `SetBinding` name `SHADOWUI_EDITMODE` registered in defaults keybinds if desired
- Exit edit mode → `ApplyAll()`

- [ ] **Step 3: Commit**

```bash
git add edit/
git commit -m "$(cat <<'EOF'
Add edit mode with grid snap and layer picker.

EOF
)"
```

---

### Task 11: Variants + talent auto-bind

**Files:**
- Create: `profile/variants.lua`

**Interfaces:**
- Consumes: char DB, account class variants
- Produces:
  - `ShadowUI:HandleVariantCommand(rest)`
  - `ShadowUI:SetVariant(name, manual)`
  - `ShadowUI:ClearVariantOverride()`
  - `ShadowUI:OnTalentUpdate()` → re-resolve/apply when not `variantManual`
  - Helpers: create/rename/delete variant tables under `db.classes[class].variants`

- [ ] **Step 1: Implement variant commands**

```lua
function Addon:HandleVariantCommand(rest)
  rest = (rest or ""):match("^%s*(.-)%s*$") or ""
  if rest == "" then
    self:Print("Active variant: " .. tostring(self:GetActiveVariantName()))
    return
  end
  if rest:lower() == "clear" then
    self:ClearVariantOverride()
    return
  end
  self:SetVariant(rest, true)
end

function Addon:SetVariant(name, manual)
  local char = self:GetCharDB()
  char.activeVariant = name
  char.variantManual = not not manual
  self:ApplyAll()
end

function Addon:ClearVariantOverride()
  local char = self:GetCharDB()
  char.variantManual = false
  self:ApplyAll()
end

function Addon:OnTalentUpdate()
  if self:GetCharDB().variantManual then return end
  self:ApplyAll()
end
```

Ensure creating a variant named in SetVariant if missing (empty layout/keybinds).

- [ ] **Step 2: Commit**

```bash
git add profile/variants.lua
git commit -m "$(cat <<'EOF'
Add variant switching and talent-tree auto-bind.

EOF
)"
```

---

### Task 12: AceConfig options panel

**Files:**
- Create: `options/config.lua`

**Interfaces:**
- Consumes: AceConfig-3.0, AceConfigDialog-3.0, variant helpers
- Produces: `ShadowUI:OpenOptions()`; options for variants CRUD, talent tree bind, edit layer indicator, reset layer / reset shipped

- [ ] **Step 1: Register options table**

Include:
- Active variant select / create / rename / delete
- Talent tree index per variant (1–3 or nil)
- Display current edit layer
- Buttons: reset selected layer deltas; reset account profile to empty (shipped defaults remain)
- Explicitly omit cast bar settings
- No large bar enable matrix (all bars on by design)

- [ ] **Step 2: Commit**

```bash
git add options/config.lua
git commit -m "$(cat <<'EOF'
Add AceConfig options for variants and layer reset.

EOF
)"
```

---

### Task 13: Architecture docs + end-to-end checklist

**Files:**
- Create: `docs/architecture.md`
- Modify: `README.md` if slash/options drifted

**Interfaces:**
- Consumes: final module layout
- Produces: docs matching spec architecture tree

- [ ] **Step 1: Write `docs/architecture.md`** summarizing module responsibilities, resolve rules, SV schema, load order.

- [ ] **Step 2: In-game verification checklist** (manual; record results in commit message or leave as README Testing section):

1. Fresh character — centered bars, skins, cast bar, no prompts
2. Edit layer Variant — drag bar — only that class variant changes; alt same class sees it
3. Edit Base — all classes inherit
4. Talent change auto-selects bound variant unless manual
5. Flush icons; square minimap; translucent chat; micro+bags bottom-right
6. Cast + GCD visible; Blizzard cast hidden
7. Unit frames unchanged

- [ ] **Step 3: Final commit**

```bash
git add docs/architecture.md README.md
git commit -m "$(cat <<'EOF'
Document ShadowUI architecture and verify checklist.

EOF
)"
```

---

## Spec coverage self-review

| Spec requirement | Task |
|---|---|
| Custom LAB bars, hide Blizzard bars | 5–6 |
| Base → Class → Variant resolve | 3–4, 11 |
| Account + character DB schema | 2 |
| Flush square buttons + black bar chrome | 5, 8 |
| Edit mode + layer picker | 10 |
| Variants + talent bind + clear | 11–12 |
| Chrome: minimap/chat/micro/bags | 8 |
| Fixed cast + GCD | 9 |
| First-run auto apply | 2 |
| Slash + AceConfig | 2, 12 |
| TOC + libs + README | 1, 13 |
| Combat-safe keybinds | 7 |
| File headers / size discipline | all tasks |

## Placeholder scan

No TBD steps; vendor script is explicit; Classic frame names may need nil-safe adjustment at implement time (called out in Task 6).

## Type consistency

- `ResolveEffective` → `{ layout, keybinds }` used by ApplyBars/ApplyKeybinds
- `WriteLayerDelta(layer, section, key, patch)` used by edit mode
- `GetActiveVariantName` / `SetVariant` / `ClearVariantOverride` shared by resolve, variants, options
