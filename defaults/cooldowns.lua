--[[
  Purpose: Shipped Cooldown Manager spell lists per Class.
  Deps: ShadowUI addon table
  Public: ShadowUI:CooldownSpellList()
]]

local Addon = LibStub("AceAddon-3.0"):GetAddon("ShadowUI")
Addon.Defaults = Addon.Defaults or { base = {}, classes = {} }

local function spells(...)
  local list = {}
  for i = 1, select("#", ...), 2 do
    local spellId, label = select(i, ...)
    list[#list + 1] = { spellId = spellId, label = label }
  end
  return list
end

Addon.Defaults.cooldowns = {
  WARRIOR = spells(
    1719, "Recklessness",
    871, "Shield Wall",
    12975, "Last Stand",
    20230, "Retaliation",
    12292, "Death Wish",
    12328, "Sweeping Strikes",
    1680, "Whirlwind",
    18499, "Berserker Rage",
    23920, "Spell Reflection",
    12294, "Mortal Strike",
    23881, "Bloodthirst",
    23922, "Shield Slam",
    20252, "Intercept",
    3411, "Intervene",
    100, "Charge",
    2565, "Shield Block",
    676, "Disarm",
    5246, "Intimidating Shout",
    6552, "Pummel",
    72, "Shield Bash"
  ),
  PALADIN = spells(
    642, "Divine Shield",
    498, "Divine Protection",
    633, "Lay on Hands",
    853, "Hammer of Justice",
    1022, "Blessing of Protection",
    20066, "Repentance",
    20216, "Divine Favor",
    20925, "Holy Shield",
    20473, "Holy Shock",
    31884, "Avenging Wrath",
    31842, "Divine Illumination",
    1044, "Blessing of Freedom",
    6940, "Blessing of Sacrifice",
    20271, "Judgement"
  ),
  HUNTER = spells(
    19574, "Bestial Wrath",
    19577, "Intimidation",
    3045, "Rapid Fire",
    19263, "Deterrence",
    5384, "Feign Death",
    23989, "Readiness",
    19386, "Wyvern Sting",
    1499, "Freezing Trap",
    34490, "Silencing Shot",
    34477, "Misdirection",
    34600, "Snake Trap",
    19503, "Scatter Shot",
    5116, "Concussive Shot",
    19801, "Tranquilizing Shot",
    13795, "Immolation Trap",
    13809, "Frost Trap"
  ),
  ROGUE = spells(
    13750, "Adrenaline Rush",
    13877, "Blade Flurry",
    5277, "Evasion",
    2983, "Sprint",
    1856, "Vanish",
    14185, "Preparation",
    2094, "Blind",
    408, "Kidney Shot",
    14177, "Cold Blood",
    31224, "Cloak of Shadows",
    36554, "Shadowstep",
    1725, "Distract",
    1766, "Kick",
    1776, "Gouge",
    1966, "Feint",
    14183, "Premeditation"
  ),
  PRIEST = spells(
    14751, "Inner Focus",
    10060, "Power Infusion",
    8122, "Psychic Scream",
    15487, "Silence",
    586, "Fade",
    6346, "Fear Ward",
    33206, "Pain Suppression",
    34433, "Shadowfiend",
    32379, "Shadow Word: Death",
    13908, "Desperate Prayer",
    9484, "Shackle Undead",
    32375, "Mass Dispel",
    33076, "Prayer of Mending"
  ),
  SHAMAN = spells(
    16166, "Elemental Mastery",
    16188, "Nature's Swiftness",
    8177, "Grounding Totem",
    20608, "Reincarnation",
    17364, "Stormstrike",
    30823, "Shamanistic Rage",
    2825, "Bloodlust",
    32182, "Heroism",
    2894, "Fire Elemental Totem",
    2062, "Earth Elemental Totem",
    16190, "Mana Tide Totem",
    2484, "Earthbind Totem",
    8143, "Tremor Totem"
  ),
  MAGE = spells(
    11958, "Ice Block",
    45438, "Ice Block",
    12472, "Cold Snap",
    12051, "Evocation",
    2139, "Counterspell",
    1953, "Blink",
    11129, "Combustion",
    12042, "Arcane Power",
    12043, "Presence of Mind",
    11426, "Ice Barrier",
    66, "Invisibility",
    122, "Frost Nova",
    543, "Fire Ward",
    6143, "Frost Ward",
    31687, "Summon Water Elemental"
  ),
  WARLOCK = spells(
    6789, "Death Coil",
    5484, "Howl of Terror",
    18708, "Fel Domination",
    18288, "Amplify Curse",
    17877, "Shadowburn",
    17962, "Conflagrate",
    1122, "Inferno",
    29858, "Soulshatter",
    30283, "Shadowfury",
    19647, "Spell Lock",
    6229, "Shadow Ward",
    698, "Ritual of Summoning",
    29893, "Ritual of Souls"
  ),
  DRUID = spells(
    29166, "Innervate",
    22812, "Barkskin",
    17116, "Nature's Swiftness",
    18562, "Swiftmend",
    740, "Tranquility",
    16689, "Nature's Grasp",
    1850, "Dash",
    22842, "Frenzied Regeneration",
    5211, "Bash",
    16979, "Feral Charge",
    33831, "Force of Nature",
    20484, "Rebirth",
    5209, "Challenging Roar",
    6795, "Growl",
    2637, "Hibernate"
  ),
}

function Addon:CooldownSpellList(classFile)
  classFile = classFile or (self.GetPlayerClass and self:GetPlayerClass())
  local all = self.Defaults and self.Defaults.cooldowns
  return (classFile and all and all[classFile]) or {}
end
