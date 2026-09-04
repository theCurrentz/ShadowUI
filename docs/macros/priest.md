# Priest

Generated from `build_catalog.py`.
Full records: [catalog.md](catalog.md).

## Priest Holy / Disc — class-specific

Alt self. Shift cheap rank. Ctrl Rank 1. Mouseover on dispel.

### fh — `pr-fh`

```
#showtooltip
/cast [mod:alt,target=player] Flash Heal; [mod:shift] Flash Heal(Rank 4); [mod:ctrl] Flash Heal(Rank 1); Flash Heal
```

### gh — `pr-gh`

```
#showtooltip
/cast [mod:alt,target=player] Greater Heal; [mod:shift] Greater Heal(Rank 1); Greater Heal
```

### rn — `pr-renew`

```
#showtooltip
/cast [mod:alt,target=player] Renew; [mod:shift] Renew(Rank 3); Renew
```

### pws — `pr-pws`

```
#showtooltip
/cast [mod:alt,target=player] Power Word: Shield; [mod:shift] Power Word: Shield(Rank 1); Power Word: Shield
```

### poh — `pr-poh`

```
#showtooltip Prayer of Healing
/cast Inner Focus
/cast Prayer of Healing
```

### disp — `pr-dispel`

```
#showtooltip Dispel Magic
/cast [mod:alt,target=player] Dispel Magic; [target=mouseover,exists] Dispel Magic; Dispel Magic
```

### fade — `pr-fade`

```
#showtooltip Fade
/cast Fade
```

### ps — `pr-scream`

```
#showtooltip Psychic Scream
/cast Psychic Scream
```

### fw — `pr-fw`

```
#showtooltip Fear Ward
/raid Fear Ward on %t
/cast [mod:alt,target=player] Fear Ward; Fear Ward
```

### fort — `pr-fort`

```
#showtooltip Power Word: Fortitude
/cast [mod:alt,target=player] Power Word: Fortitude; Power Word: Fortitude
```

### rez — `pr-rez`

```
#showtooltip Resurrection
/cast Resurrection
```

### ifr — `pr-if`

```
#showtooltip Inner Fire
/cast Inner Fire
```

### hn — `pr-nova`

```
#showtooltip
/cast [mod:shift] Holy Nova(Rank 1); Holy Nova
```

### wand — `pr-wand`

```
#showtooltip Shoot
/cast Shoot
```

### ad — `pr-abolish`

```
#showtooltip Abolish Disease
/cast [mod:alt,target=player] Abolish Disease; [target=mouseover,exists] Abolish Disease; Abolish Disease
```

### pof — `pr-pof`

```
#showtooltip Prayer of Fortitude
/cast Prayer of Fortitude
```

### pos — `pr-spirit`

```
#showtooltip Prayer of Spirit
/cast Prayer of Spirit
```

## Priest ranks — class-specific

Downrank wrappers for trainer abilities with more than one rank. Shift is Rank 1. Talent-granted rank macros stay here and stay off the Class Action Bar.

### egrace — `pr-egrace`

```
#showtooltip
/cast [nomod]Elune's Grace;[mod:shift]Elune's Grace(Rank 1)
```

### fback — `pr-fback`

```
#showtooltip
/cast [nomod]Feedback;[mod:shift]Feedback(Rank 1)
```

### mburn — `pr-mburn`

```
#showtooltip
/cast [nomod]Mana Burn;[mod:shift]Mana Burn(Rank 1)
```

### shards — `pr-shards`

```
#showtooltip
/cast [nomod]Starshards;[mod:shift]Starshards(Rank 1)
```

### dpray — `pr-dpray`

```
#showtooltip
/cast [nomod]Desperate Prayer;[mod:shift]Desperate Prayer(Rank 1)
```

### heal — `pr-heal`

```
#showtooltip
/cast [mod:alt,target=player] Heal; [mod:shift] Heal(Rank 1); Heal
```

### hfire — `pr-hfire`

```
#showtooltip
/cast [nomod]Holy Fire;[mod:shift]Holy Fire(Rank 1)
```

### lheal — `pr-lheal`

```
#showtooltip
/cast [mod:alt,target=player] Lesser Heal; [mod:shift] Lesser Heal(Rank 1); Lesser Heal
```

### smite — `pr-smite`

```
#showtooltip
/cast [nomod]Smite;[mod:shift]Smite(Rank 1)
```

### dplague — `pr-dplague`

```
#showtooltip
/cast [nomod]Devouring Plague;[mod:shift]Devouring Plague(Rank 1)
```

### hexw — `pr-hexw`

```
#showtooltip
/cast [nomod]Hex of Weakness;[mod:shift]Hex of Weakness(Rank 1)
```

### mc — `pr-mc`

```
#showtooltip
/cast [nomod]Mind Control;[mod:shift]Mind Control(Rank 1)
```

### msoothe — `pr-msoothe`

```
#showtooltip
/cast [nomod]Mind Soothe;[mod:shift]Mind Soothe(Rank 1)
```

### mvis — `pr-mvis`

```
#showtooltip
/cast [nomod]Mind Vision;[mod:shift]Mind Vision(Rank 1)
```

### sprot — `pr-sprot`

```
#showtooltip
/cast [nomod]Shadow Protection;[mod:shift]Shadow Protection(Rank 1)
```

### sguard — `pr-sguard`

```
#showtooltip
/cast [nomod]Shadowguard;[mod:shift]Shadowguard(Rank 1)
```

### tow — `pr-tow`

```
#showtooltip
/cast [nomod]Touch of Weakness;[mod:shift]Touch of Weakness(Rank 1)
```

## Priest Shadow — class-specific

Dots and form. Cancel form to heal.

### swp — `pr-swp`

```
#showtooltip
/cast [mod:shift] Shadow Word: Pain(Rank 1); Shadow Word: Pain
```

### mf — `pr-mf`

```
#showtooltip Mind Flay
/cast Mind Flay
```

### mblast — `pr-mb`

```
#showtooltip Mind Blast
/cast Mind Blast
```

### ve — `pr-ve`

```
#showtooltip Vampiric Embrace
/cast Vampiric Embrace
```

### sf — `pr-sf`

```
#showtooltip Shadowform
/cast Shadowform
```

### sil — `pr-silence`

```
#showtooltip Silence
/stopcasting
/cast Silence
```

### shk — `pr-shackle`

```
#showtooltip Shackle Undead
/stopcasting
/cast Shackle Undead
```

### hf — `pr-healform`

```
#showtooltip Flash Heal
/cancelaura Shadowform
/cast [mod:alt,target=player] Flash Heal; Flash Heal
```

## Priest TBC — class-specific — TBC

TBC trainer and talent heals. Fear Ward is baseline. Blood Elf Consume Magic and Draenei/Dwarf Chastise stay here because they need stopcasting.

### swd — `pr-swd`

```
#showtooltip Shadow Word: Death
/cast Shadow Word: Death
```

### pom — `pr-pom`

```
#showtooltip Prayer of Mending
/cast [mod:alt,target=player] Prayer of Mending; Prayer of Mending
```

### coh — `pr-coh`

```
#showtooltip Circle of Healing
/cast [mod:alt,target=player] Circle of Healing; Circle of Healing
```

### psup — `pr-psup`

```
#showtooltip Pain Suppression
/raid Pain Suppression on %t
/cast [mod:alt,target=player] Pain Suppression; Pain Suppression
```

### mdisp — `pr-mdisp`

```
#showtooltip Mass Dispel
/stopcasting
/cast Mass Dispel
```

### sfiend — `pr-sfiend`

```
#showtooltip Shadowfiend
/cast Shadowfiend
```

### bheal — `pr-bheal`

```
#showtooltip Binding Heal
/cast Binding Heal
```

### vt — `pr-vt`

```
#showtooltip Vampiric Touch
/cast Vampiric Touch
```

### cmagic — `pr-cmagic`

Blood Elf priest racial.

```
#showtooltip Consume Magic
/stopcasting
/cast Consume Magic
```

### chast — `pr-chast`

Dwarf and Draenei priest racial.

```
#showtooltip Chastise
/stopcasting
/cast Chastise
```
