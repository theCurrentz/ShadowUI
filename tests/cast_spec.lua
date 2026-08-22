-- Cast Bar fill, latency window, and GCD Sweep timing.
-- Run: lua tests/cast_spec.lua
local root = (arg and arg[0] or ""):match("^(.*)tests[/\\]") or ""
local Addon = {}
_G.LibStub = function()
  return { GetAddon = function() return Addon end }
end

assert(loadfile(root .. "cast/castbar.lua"))()
assert(loadfile(root .. "cast/gcd.lua"))()

local cast = Addon:CastMeterState(11, 10, 12, false, 200)
assert(cast, "live cast has state")
assert(cast.duration == 2, "cast duration is end minus start")
assert(cast.remaining == 1, "cast remaining is end minus now")
assert(cast.value == 1, "cast fill is elapsed time")
assert(cast.fillFraction == 0.5, "half-cast spark sits at mid-bar")
assert(cast.lagFraction == 0.1, "200ms lag is a tenth of a 2s cast")
assert(cast.lagOnRight == true, "cast lag sits at the finish")

local channel = Addon:CastMeterState(11, 10, 12, true, 200)
assert(channel.value == 1, "channel fill is remaining time")
assert(channel.lagOnRight == false, "channel lag sits at the start")

assert(Addon:CastMeterState(12, 10, 12, false, 0) == nil, "finished cast hides")
assert(Addon:CastMeterState(10, 12, 10, false, 0) == nil, "invalid window hides")

local blizzard = Addon:CastChannelTickFractions(10)
assert(#blizzard == 7, "Blizzard shows interior ticks, not the channel end")
assert(blizzard[1] == 0.125, "first Blizzard tick is at 1s of 8s")
assert(blizzard[7] == 0.875, "last interior Blizzard tick is at 7s of 8s")
local rain = Addon:CastChannelTickFractions(5740)
assert(#rain == 3, "Rain of Fire has four ticks so three notches")
assert(rain[1] == 0.25, "Rain of Fire ticks every 2s of 8s")
assert(#Addon:CastChannelTickFractions(133) == 0, "hardcast Fireball has no channel ticks")
assert(#Addon:CastChannelTickFractions(nil) == 0, "missing spell id has no ticks")

local gcd = Addon:GCDSweepState(10, 1.5, 1, 10.5)
assert(gcd.remaining == 1.0, "GCD remaining is end minus now")
assert(gcd.duration == 1.5, "GCD keeps its duration")
assert(Addon:GCDSweepState(10, 8, 1, 10.5) == nil, "spell cooldown is not a GCD")
assert(Addon:GCDSweepState(10, 1.5, 0, 10.5) == nil, "disabled cooldown hides")
assert(Addon:GCDSweepState(10, 1.5, 1, 12) == nil, "finished GCD hides")

local fromClient = Addon:GCDSweepFromClient(20, 0, 0, 1, "UNIT_SPELLCAST_START", false)
assert(fromClient and fromClient.duration == 1.5, "Classic START synthesizes a 1.5s GCD")
local channelStart = Addon:GCDSweepFromClient(20, 0, 0, 1, "UNIT_SPELLCAST_CHANNEL_START", false)
assert(channelStart and channelStart.duration == 1.5, "channel START synthesizes a 1.5s GCD")
assert(
  Addon:GCDSweepFromClient(20, 0, 0, 1, "UNIT_SPELLCAST_SUCCEEDED", true) == nil,
  "SUCCEEDED during a hardcast does not restart the GCD"
)
local instant = Addon:GCDSweepFromClient(20, 0, 0, 1, "UNIT_SPELLCAST_SUCCEEDED", false)
assert(instant and instant.duration == 1.5, "instant SUCCEEDED synthesizes a 1.5s GCD")
assert(
  Addon:GCDSweepFromClient(21.6, 0, 0, 1, "UNIT_SPELLCAST_SUCCEEDED", false, fromClient, true) == nil,
  "SUCCEEDED after a hardcast does not start a second GCD"
)
assert(
  Addon:GCDSweepFromClient(20, 0, 0, 1, "ACTIONBAR_UPDATE_COOLDOWN", false) == nil,
  "cooldown events do not invent a GCD"
)
local kept = Addon:GCDSweepFromClient(20.2, 0, 0, 1, "ACTIONBAR_UPDATE_COOLDOWN", false, fromClient)
assert(kept and kept.endTime == fromClient.endTime, "empty cooldown events keep a live GCD")

local real = Addon:GCDSweepFromClient(10.5, 10, 1.5, 1, "ACTIONBAR_UPDATE_COOLDOWN", false)
assert(real and real.remaining == 1.0, "retail GCD spell wins over the fallback")

print("cast_spec OK")
