# Live overlays live in WTF SavedVariables

Macro Cursor and ShadowUI share one live overlay: Account `ShadowUIDB` and Character `ShadowUICharDB`. A Keybind or Layout edit writes the active Profile on the Account. Sidecar JSON (`keybinds.json`, `actions.json`) is not a second live store.

The client can write SavedVariables only. Macro Cursor writes those files when the client is closed, the same rule as `macros-cache.txt`. AceDB flushes on logout, so same-session sync while the client is open is not possible. Shipped `defaults/*.lua` stays the seed; Save as default still promotes into Lua for git.
