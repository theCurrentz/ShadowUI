# Shared macros (every class)

## Assist and marks

```
#showtooltip
/assist
```

```
/target [@target,exists]
/assist [help]
```

```
/focus
/clearfocus [mod:shift]
```

```
/targetlasttarget
```

Mouseover assist (click a friendly to attack their target):

```
/assist [target=mouseover,help,exists]
/startattack
```

## Start and stop attack

```
/startattack
```

```
/stopattack
```

```
/petattack
/startattack
```

## Mouseover generic (template)

Replace the spell:

```
#showtooltip
/cast [target=mouseover,exists,nodead] SPELL; SPELL
```

Alt-self, else mouseover, else target:

```
#showtooltip
/cast [mod:alt,target=player] SPELL; [target=mouseover,help,nodead] SPELL; SPELL
```

## Trinkets

Use with the next spell (255 limit: keep names short):

```
#showtooltip SPELL
/use 13
/cast SPELL
```

```
#showtooltip SPELL
/use 14
/cast SPELL
```

Both slots then the spell (can fail if both on CD; usually you want one button per trinket):

```
/use 13
/use 14
```

## Engineering

```
#showtooltip
/use 10
```

```
#showtooltip Dense Dynamite
/use Dense Dynamite
```

```
#showtooltip Iron Grenade
/use Iron Grenade
```

```
#showtooltip Thorium Grenade
/use Thorium Grenade
```

Goblin / Gnomish sapper (self AoE — stand in melee):

```
#showtooltip Goblin Sapper Charge
/use Goblin Sapper Charge
```

## Consumes

```
#showtooltip Major Healing Potion
/use Major Healing Potion
```

```
#showtooltip Major Mana Potion
/use Major Mana Potion
```

```
#showtooltip Limited Invulnerability Potion
/use Limited Invulnerability Potion
```

```
#showtooltip Free Action Potion
/use Free Action Potion
```

```
#showtooltip Restorative Potion
/use Restorative Potion
```

```
#showtooltip Greater Stoneshield Potion
/use Greater Stoneshield Potion
```

```
#showtooltip Whipper Root Tuber
/use Whipper Root Tuber
```

```
#showtooltip Heavy Runecloth Bandage
/use [@player] Heavy Runecloth Bandage
```

Healthstone name depends on rank (see [warlock.md](warlock.md)). Other classes `/use` the item they were given.

## Food, drink, vendor

```
#showtooltip
/use Conjured Crystal Water
```

```
#showtooltip
/use Conjured Cinnamon Roll
```

```
/run for b=0,4 do for s=1,32 do local n=GetContainerItemLink(b,s) if n and (n:find("Conjured") or n:find("Water")) then PickupContainerItem(b,s) if MerchantFrame:IsShown() then DeleteCursorItem() end end end end
```

The vendor-delete script is optional and long. Prefer a dedicated bag addon. Keep a simple `/use` drink on a bar.

## Mount and hearth

Classic Era has many mount item names. Bind the item you own:

```
#showtooltip
/use ITEMNAME
```

AQ mounts vs world mounts: two macros, or one modifier:

```
#showtooltip
/use [mod:shift] AQ MOUNT; WORLD MOUNT
```

```
#showtooltip Hearthstone
/use Hearthstone
```

## Announce (raid)

Keep these short. Change the channel if you are not in a raid (`/p` party, `/s` say).

```
/raid {rt8} Rebirth on %t {rt8}
```

```
/raid Innervate on %t
```

```
/raid Soulstone on %t
```

```
/raid Fear Ward on %t
```

```
/raid Misdirect is not in Classic Era
```

## Targeting helpers

```
/cleartarget
```

```
/targetenemy
```

```
/cleartarget [dead]
/targetenemy [noexists]
```

## Cancel aura (template)

```
/cancelaura SPELL
```

Common: Ice Block, Divine Shield, Blessing of Protection, Stealth after a misclick, Power Word: Shield before a pull that must not eat the shield.

## SoD note

SoD adds extra consumes and engineering. Names change by phase. Keep `/use` on the item tooltip name from your bag.
