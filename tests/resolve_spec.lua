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
