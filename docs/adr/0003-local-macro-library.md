# Macro Cursor is a local library sidecar

Macro Cursor runs next to the addon on disk. `docs/macros/catalog.json` is the Macro Library. Edits write that file. Delete in Macro Cursor removes the catalog record and its live WTF copy. A macro removed from the game is unloaded only, so an Action Deck replacement cannot erase the library. IndexedDB and overlay JSON are not a second source of truth.

Unload still drops a record from the in-game tabs only. Close the client before the sidecar writes `macros-cache.txt`.

Applying an Action Deck is an explicit replacement operation. ShadowUI validates the selected resolved deck, deletes both in-game macro tabs, and recreates only that deck's unique catalog macros on the General tab. The character tab stays empty.
