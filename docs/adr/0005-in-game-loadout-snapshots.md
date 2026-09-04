# In-game Loadout Snapshots bridge Character action slots

Blizzard owns live Action Slot contents. ShadowUI SavedVariables and offline WTF scripts cannot put spells, items, or macros into those slots. Copying a complete action-bar setup must therefore capture and place Actions through the running client.

ShadowUI stores Version-specific Loadout Snapshots on the Account. A source Character saves its effective physical Bar map in game. A target Character previews selected sections, then applies them out of combat. Layout and Keybind changes write only to the target Character Layer. Live Actions use Blizzard pickup and place functions.

Same-Class and Cross-Class copies map fixed physical Bar and button positions. An old snapshot with multiple main-Bar pages requires an explicit source-page and target-range map. Cross-Class copies skip abilities the target does not know. ShadowUI does not guess equivalent class abilities.

This keeps the game as the writer of live Actions, works across realms on one Account, and avoids fragile edits to client-owned action data. Macro Cursor remains unchanged.
