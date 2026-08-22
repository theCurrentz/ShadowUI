# Warlock

## Life Tap ranks

```
#showtooltip Life Tap
/cast Life Tap
```

Cheap tap:

```
#showtooltip Life Tap(Rank 1)
/cast Life Tap(Rank 1)
```

Shift for Rank 1:

```
#showtooltip
/cast [mod:shift] Life Tap(Rank 1); Life Tap
```

## Dark Pact (aff talent, tap pet mana)

```
#showtooltip Dark Pact
/cast Dark Pact
```

## Shadow Bolt ranks

```
#showtooltip Shadow Bolt
/cast Shadow Bolt
```

```
#showtooltip Shadow Bolt(Rank 1)
/cast Shadow Bolt(Rank 1)
```

Nightfall proc is still `/cast Shadow Bolt`. No aura test for the proc in Era macros.

## Searing Pain / Immolate / Conflagrate / Soul Fire

```
#showtooltip Searing Pain
/cast Searing Pain
```

```
#showtooltip Immolate
/cast Immolate
```

```
#showtooltip Conflagrate
/cast Conflagrate
```

```
#showtooltip Soul Fire
/cast Soul Fire
```

## Corruption / Siphon Life / Drain Life

```
#showtooltip Corruption
/cast Corruption
```

Rank 1 Corruption (tag / contest):

```
#showtooltip Corruption(Rank 1)
/cast Corruption(Rank 1)
```

```
#showtooltip Siphon Life
/cast Siphon Life
```

```
#showtooltip Drain Life
/cast Drain Life
```

## Drain Soul / Drain Mana

```
#showtooltip Drain Soul
/cast Drain Soul
```

Rank 1 Drain Soul (shard farming, less overkill):

```
#showtooltip Drain Soul(Rank 1)
/cast Drain Soul(Rank 1)
```

```
#showtooltip Drain Mana
/cast Drain Mana
```

## Shadowburn (destro talent)

```
#showtooltip Shadowburn
/cast Shadowburn
```

## Curses (one on the target)

Elements (raid caster):

```
#showtooltip Curse of the Elements
/cast Curse of the Elements
```

Shadow (shadow raid):

```
#showtooltip Curse of Shadow
/cast Curse of Shadow
```

Agony (affliction):

```
#showtooltip Curse of Agony
/cast Curse of Agony
```

Recklessness (pve stun-immune packs, pvp):

```
#showtooltip Curse of Recklessness
/cast Curse of Recklessness
```

Weakness:

```
#showtooltip Curse of Weakness
/cast Curse of Weakness
```

Tongues:

```
#showtooltip Curse of Tongues
/cast Curse of Tongues
```

Exhaustion (aff talent):

```
#showtooltip Curse of Exhaustion
/cast Curse of Exhaustion
```

Doom (destro talent):

```
#showtooltip Curse of Doom
/cast Curse of Doom
```

Shift Agony, else Elements (solo vs raid):

```
#showtooltip
/cast [mod:shift] Curse of Agony; Curse of the Elements
```

## Fear / Howl of Terror / Death Coil / Banish

```
#showtooltip Fear
/stopcasting
/cast Fear
```

Rank 1 Fear (pvp, shorter):

```
#showtooltip Fear(Rank 1)
/cast Fear(Rank 1)
```

```
#showtooltip Howl of Terror
/cast Howl of Terror
```

```
#showtooltip Death Coil
/cast Death Coil
```

```
#showtooltip Banish
/stopcasting
/cast [target=mouseover,harm,nodead] Banish; Banish
```

## Enslave Demon / Inferno / Ritual

```
#showtooltip Enslave Demon
/cast Enslave Demon
```

```
#showtooltip Inferno
/cast Inferno
```

```
#showtooltip Ritual of Summoning
/cast Ritual of Summoning
```

```
#showtooltip Ritual of Doom
/cast Ritual of Doom
```

## Soulstone / Healthstone / Firestone / Spellstone

```
#showtooltip Create Soulstone
/cast Create Soulstone
```

Use the created item (name follows rank, e.g. Major Soulstone):

```
#showtooltip Major Soulstone
/use [target=mouseover,help,nodead] Major Soulstone; Major Soulstone
```

```
/raid Soulstone on %t
```

```
#showtooltip Create Healthstone
/cast Create Healthstone
```

```
#showtooltip Major Healthstone
/use Major Healthstone
```

```
#showtooltip Create Firestone
/cast Create Firestone
```

```
#showtooltip Create Spellstone
/cast Create Spellstone
```

## Pets

```
#showtooltip Summon Imp
/cast Summon Imp
```

```
#showtooltip Summon Voidwalker
/cast Summon Voidwalker
```

```
#showtooltip Summon Succubus
/cast Summon Succubus
```

```
#showtooltip Summon Felhunter
/cast Summon Felhunter
```

Shift succubus, else felhunter (example):

```
#showtooltip
/cast [mod:shift] Summon Succubus; Summon Felhunter
```

## Voidwalker Sacrifice

```
#showtooltip Sacrifice
/cast Sacrifice
```

## Felhunter Spell Lock (interrupt)

```
#showtooltip Spell Lock
/stopcasting
/cast Spell Lock
```

If the pet bar is the one that has Spell Lock, you can also `/cast Spell Lock` from a player macro when the felhunter is out.

## Devour Magic / Seduction / Suffering / Torment

```
#showtooltip Devour Magic
/cast [target=mouseover,exists,nodead] Devour Magic; Devour Magic
```

```
#showtooltip Seduction
/petattack
/cast Seduction
```

```
#showtooltip Suffering
/cast Suffering
```

```
#showtooltip Torment
/cast Torment
```

## Pet stance (shared hunter-style)

```
/petattack
```

```
/petfollow
```

```
/petpassive
```

## Detect Invisibility / Unending Breath / Eye of Kilrogg

```
#showtooltip Detect Invisibility
/cast [target=mouseover,help,nodead] Detect Invisibility; Detect Invisibility
```

```
#showtooltip Unending Breath
/cast [target=mouseover,help,nodead] Unending Breath; Unending Breath
```

```
#showtooltip Eye of Kilrogg
/cast Eye of Kilrogg
```

## Wand

```
#showtooltip Shoot
/cast Shoot
```

## Demon Armor / Fel Armor / Shadow Ward

Fel Armor is TBC. Era:

```
#showtooltip Demon Armor
/cast Demon Armor
```

```
#showtooltip Demon Skin
/cast Demon Skin
```

```
#showtooltip Shadow Ward
/cast Shadow Ward
```

## SoD note

SoD adds extra pets and runes (for example Chaos Bolt, Haunt, Metamorphosis by phase). Life Tap downrank and Spell Lock `/stopcasting` stay valid.
