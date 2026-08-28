# Shared macros (General tab)

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Other — global

In-game macros with no catalog group. Auto-heal keeps them for Export.

### pi — `ingame-other-account-pi`

Imported from in-game macros-cache.txt.

```
/w Stinkytoez ——————————————————
/w Stinkytoez {star} • • Requesting Power Infusion • • {star}
/w Stinkytoez ——————————————————
/cast Fireball
```

## Shared core — global

General-tab utilities that need a macro: assist, focus, trinket slots, pet attack / follow, and cursor items. Put potions, the hearthstone, and racials on the bar. Class spells stay in class groups.

### t13 — `shared-t13`

```
#showtooltip
# global ALL all
/use 13
```

### t14 — `shared-t14`

```
#showtooltip
# global ALL all
/use 14
```

### pa — `shared-pa`

Hunter, Warlock, and any other pet class. One General-tab body.

```
# global ALL all | key (`)
/petattack
```

### pf — `shared-pf`

Shift-backtick. Split from pet attack so Shift is a bind, not a modifier.

```
# global ALL all | key (SHIFT-`)
/petfollow
```

## Shared TBC — global — TBC

TBC racial wrappers that need a modifier or stopcasting. Blood Elf and Draenei passives stay on the bar. Mana Tap is a plain racial.

### gotn — `shared-gotn`

Draenei heal. Alt self.

```
#showtooltip Gift of the Naaru
# global ALL all
/cast [mod:alt,target=player] Gift of the Naaru; Gift of the Naaru
```

### atorrent — `shared-at`

Blood Elf interrupt. Stops a queued spell first.

```
#showtooltip Arcane Torrent
# global ALL all
/stopcasting
/cast Arcane Torrent
```

## Other Curents — character-specific Curents

In-game macros with no catalog group. Auto-heal keeps them for Export.

### adad — `ingame-other-Curents-adad`

Imported from in-game macros-cache.txt.

```
/tar p
```

### hloe — `ingame-other-Curents-hloe`

Imported from in-game macros-cache.txt.

```
/use Light of Elune
/use Hearthstone
```
