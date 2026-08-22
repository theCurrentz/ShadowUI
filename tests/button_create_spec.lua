-- Classic ActionButtonTemplate has no SlotBackground. LAB Update runs inside
-- UpdateConfig, so MasqueSkinned must already be set from config.
-- Run: lua tests/button_create_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local src = assert(io.open(root .. "libs/LibActionButton-1.0/LibActionButton-1.0.lua", "r")):read("*a")
local start = src:find("function lib:CreateButton", 1, true)
local configAt = src:find("button:UpdateConfig", start, true)
assert(start and configAt, "could not find CreateButton / UpdateConfig")
local beforeConfig = src:sub(start, configAt)
assert(beforeConfig:find("MasqueSkinned", 1, true), "MasqueSkinned must be set before UpdateConfig")
assert(beforeConfig:find("pcall", 1, true), "Classic rejects AnyDown; RegisterForClicks must be pcalled")

local barSrc = assert(io.open(root .. "bars/bar.lua", "r")):read("*a")
assert(not barSrc:find("SecureHandlerStateTemplate,BackdropTemplate", 1, true),
  "combining SecureHandler + Backdrop templates can fail CreateFrame on Classic")

local buttonSrc = assert(io.open(root .. "bars/button.lua", "r")):read("*a")
assert(buttonSrc:find("masqueSkinned%s*=%s*true"), "CONFIG must set masqueSkinned before LAB UpdateAction")
assert(not buttonSrc:find("SetNormalTexture(nil)", 1, true), "Classic SetNormalTexture rejects nil")
assert(not buttonSrc:find("SetPushedTexture(nil)", 1, true), "Classic SetPushedTexture rejects nil")

local embeds = assert(io.open(root .. "libs/embeds.xml", "r")):read("*a")
local _, count = embeds:gsub("AceConfigCmd%-3%.0%.xml", "")
assert(count == 0, "AceConfigCmd must load only via AceConfig-3.0.xml")
print("button_create_spec OK")
