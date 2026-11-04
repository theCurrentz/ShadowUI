--[[
  Purpose: AceConfig panel for Character chrome, edit sessions, and resets.
  Deps: AceConfig-3.0, AceConfigDialog-3.0, options/nav.lua, options/scroll.lua
  Public: ShadowUI:OpenOptions()
]]
local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local function resetProfile()
  local profile = Addon:GetProfile()
  if profile then
    profile.layout, profile.keybinds, profile.actions = {}, {}, {}
  end
  Addon:ApplyAll()
end
local options = {
  type = "group", name = "ShadowUI",
  childGroups = "tree",
  args = {
    search = {
      type = "input", name = "Search", order = 0, width = "full",
      desc = "Filter the outline by name or description.",
      get = function()
        return Addon:GetOptionsSearch()
      end,
      set = function(_, value)
        Addon:SetOptionsSearch(value)
      end,
    },
    general = {
      type = "group", name = "General", order = 1,
      args = {
        version = {
          type = "description", name = function()
            return "Version: Forever"
          end, order = 1,
        },
        hardLockActionSlots = {
      type = "toggle", name = "Hard lock action slots", order = 15,
      desc = "Block Shift-drag and Shift+Alt insert between Action Slots. A click still uses the action. Without this, bars stay locked: a click uses the action, Shift-drag moves a spell or item, and Shift+Alt drag inserts.",
      get = function() return Addon:GetCharDB().hardLockActionSlots == true end,
      set = function(_, value) Addon:SetActionSlotHardLock(value) end,
    },
    useShadowUIMenu = {
      type = "toggle", name = "Shadow menu and bag borders", order = 16,
      desc = "On: shadow the borders of the Blizzard micro menu and bag bar. Off: leave those bars as Blizzard draws them.",
      get = function() return Addon:GetCharDB().useShadowUIMenu ~= false end,
      set = function(_, value)
        Addon:GetCharDB().useShadowUIMenu = value and true or false
        Addon:ApplyAll()
      end,
    },
    darkness = {
      type = "range", name = "Darkness", order = 16.05,
      desc = "How dark Blizzard chrome is. Higher is darker. 1 is the shipped Lorti look. 0 leaves chrome native white.",
      min = 0, max = 1, step = 0.05,
      get = function()
        local darkness = Addon:GetCharDB().darkness
        if darkness == nil then
          return 1
        end
        return darkness
      end,
      set = function(_, value)
        Addon:GetCharDB().darkness = value
        if Addon.RefreshDarkenPalette then
          Addon:RefreshDarkenPalette()
        end
        Addon:ApplyAll()
      end,
    },
    microFadeIdle = {
      type = "range", name = "Micro and bag fade idle", order = 16.1,
      desc = "Idle alpha for the Blizzard micro menu and bag bar. 1 keeps them fully visible.",
      min = 0, max = 1, step = 0.05,
      get = function()
        local idle = Addon:GetCharDB().microFadeIdle
        if idle == nil then
          return 1
        end
        return idle
      end,
      set = function(_, value)
        Addon:GetCharDB().microFadeIdle = value
        Addon:ApplyAll()
      end,
    },
    useShadowUIMinimap = {
      type = "toggle", name = "Use ShadowUI minimap", order = 16.2,
      desc = "On: square the Forever minimap and replace the compass with a Darken fade. Off: use the default Blizzard map.",
      get = function() return Addon:GetCharDB().useShadowUIMinimap ~= false end,
      set = function(_, value)
        Addon:GetCharDB().useShadowUIMinimap = value and true or false
        Addon:ApplyAll()
      end,
    },
        editLayout = {
          type = "execute", name = "Edit layout", order = 21,
          desc = "Move Bars on the snap grid. Hold Shift to skip snap. Writes go to the Profile.",
          func = function()
            AceConfigDialog:Close("ShadowUI")
            Addon:ToggleEditMode()
          end,
        },
        editKeybinds = {
          type = "execute", name = "Edit keybinds", order = 22,
          desc = "Hover a button and press a key. Writes go to the Profile. Does not write SavedBindings.",
          func = function()
            AceConfigDialog:Close("ShadowUI")
            Addon:ToggleKeybindMode()
          end,
        },
        resetLayer = {
          type = "execute", name = "Reset Profile", order = 30,
          desc = "Clear Layout, Keybinds, and Action Deck overlays. Shipped defaults remain.",
          confirm = true, func = resetProfile,
        },
        resetAccount = {
          type = "execute", name = "Reset saved data", order = 40,
          desc = "Clear the Account Profile. Shipped defaults remain.",
          confirm = true,
          func = function() Addon.db:ResetProfile(); Addon:ApplyAll() end,
        },
      },
    },
  },
}
function Addon:OpenOptions()
  if not self._optionsRegistered then
    self._optionsTable = options
    self:KeepOptionsSearch(options.args.search)
    self:InstallOptionsSearchHide(options)
    self:MarkOptionsSearch(options)
    AceConfig:RegisterOptionsTable("ShadowUI", options)
    if AceConfigDialog.SetDefaultSize then
      AceConfigDialog:SetDefaultSize("ShadowUI", 960, 640)
    end
    self._optionsRegistered = true
  end
  AceConfigDialog:Open("ShadowUI")
end
