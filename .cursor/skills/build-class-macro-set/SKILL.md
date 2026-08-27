---
name: build-class-macro-set
description: Build and audit one complete ShadowUI Classic Era class macro set.
disable-model-invocation: true
---

# Build a Class Macro Set

Use the requested class as the scope. Ask for the class only when the request
does not identify it.

## 1. Load the sources of truth

Read:

- `CONTEXT.md` and relevant `docs/adr/` records
- `docs/macros/README.md`
- `docs/macros/rules.md`
- `docs/macros/inventory.md`
- `docs/macros/<class>.md`, when it exists
- `docs/macros/build_catalog.py`
- `docs/classic-keymaps.md`
- relevant catalog, Macro Cursor, class-default, and test files

Treat `build_catalog.py` as the editable catalog source. Its generated Markdown,
JSON, and Lua files are outputs.

## 2. Research the class

Confirm the work targets Classic Era. Use high-trust Classic Era sources to
verify:

- trainer and class-quest abilities
- active abilities unlocked by each Talent Tree
- stance, form, pet, equipment, rank, and global-cooldown behavior
- common endgame builds and the practical jobs their macros must cover

Create or update `docs/macros/<class>-research.md`. Record claims, sources, and
the catalog decisions that follow from them. Mark uncertain client behavior for
in-game verification instead of presenting it as fact.

Research is complete when every retained, added, moved, and pruned macro has a
clear reason.

## 3. Audit the current set

For every current and proposed macro, decide:

1. What play job does it perform?
2. Does it add useful behavior beyond dragging the spell or item to a bar?
3. Is another macro already responsible for the same job?
4. Is its scope account, class, or Character?
5. Is it core, Talent Tree-specific, or named gear?

Use this taxonomy:

- `<class>-core`: trainer and class-quest abilities useful across builds.
- `<class>-<tree>`: only active abilities unlocked by that Talent Tree.
- `<class>-gear`: named equipment or Character-specific item sets.

The catalog `spec` field names macro grouping. It does not redefine ShadowUI
Variant.

Prune:

- plain `/cast Spell` bodies with no condition, rank control, or other command
- plain item, racial, mount, or hearthstone wrappers
- duplicate normalized bodies
- alternate names that do not provide a distinct behavior
- obsolete, social, encounter-target, addon-stub, and out-of-era bodies

Preserve a plain cast only when the macro prevents an unwanted rank or adds
another clear behavior.

## 4. Design the complete set

Cover the class's relevant play jobs from the list in
`docs/macros/README.md`. Include only jobs that benefit from a macro.

Follow the existing bodies in `docs/macros/inventory.md` and the conventions in
`docs/macros/rules.md` before generic macro advice. Keep each macro easy to
explain and useful in normal play.

For each macro:

- Keep the name at 16 characters or fewer.
- Keep the final body at 255 characters or fewer, including comments and
  newlines.
- Use stable, unique ids and globally unique names.
- Put `#showtooltip` on line 1 when used.
- Add the generated scope label after it.
- Add `| key (<hotkey>)` to the label.
- Use the documented Class Keybind or Action Deck key.
- Use `key (unbound)` when no shared recommendation exists.

Use this label form:

```text
# class-specific WARRIOR all | key (Q)
```

Do not invent an Action Deck for another class as part of a macro-set audit.
Add or change an Action Deck only when the user requests it.

## 5. Implement and synchronize

Edit `docs/macros/build_catalog.py` and the smallest necessary hand-authored
docs, defaults, and tests.

When the class already has an Action Deck, keep its macro ids, body markers,
placements, Variant overlays, and Class Keybinds synchronized. Follow the
Base → Class → Variant inheritance in `CONTEXT.md`.

Regenerate all catalog outputs:

```bash
python3 docs/macros/build_catalog.py
```

Do not hand-edit generated files after generation.

## 6. Add quality guards

Add or update tests that prove:

- core contains only `all` abilities in its intended tab
- Talent Tree groups contain only abilities unlocked by that tree
- removed ids stay absent
- macro names and normalized bodies are unique
- no retained class macro is a plain cast without added value
- all class labels include a recommended key or `unbound`
- important bodies contain their required commands and conditionals
- any existing Action Deck still identifies and places its macros safely

## 7. Verify

Run:

```bash
python3 docs/macros/build_catalog.py
pnpm --dir macro-cursor test
pnpm --dir macro-cursor build
```

Run relevant Lua tests when addon defaults or an Action Deck changed.

Finish only when generation reports no over-limit bodies or dropped labels,
all relevant tests pass, generated files match the source, and the research
note matches the implemented result.
