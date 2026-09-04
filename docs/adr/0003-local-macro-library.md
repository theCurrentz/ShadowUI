# Macro Cursor is a local library sidecar

Macro Cursor runs next to the addon on disk. `docs/macros/catalog.json` is the Macro Library. Edits write that file. Delete in Macro Cursor removes the catalog record and its live WTF copy. A macro removed from the game is unloaded only, so the library stays. IndexedDB and overlay JSON are not a second source of truth.

Unload still drops a record from the in-game tabs only. Close the client before the sidecar writes `macros-cache.txt`.
