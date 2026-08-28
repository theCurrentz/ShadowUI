# Version is a client flavor, not a Layer

Era and TBC are different clients (`_classic_era_` vs `_anniversary_`), different Interface numbers, and different spellbooks. Mixing them in Base → Class → Variant would make every field a Version overlay and mix WTF caches. Version sits outside that stack: Macro Cursor picks Era or TBC, and ShadowUI reads the running client.
