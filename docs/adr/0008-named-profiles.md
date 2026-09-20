# Named Profiles replace the Layer stack

Base → Class → Variant → Character made every edit pick a Layer, and alts inherited Class and Variant whether they wanted that or not. Players asked for a named save they can copy and mark Default.

ShadowUI stores Layout, Keybinds, and the Action Deck on Account **Profiles**. A Character selects one Profile, or follows the Default Profile. Shipped Class defaults still merge first so stance paging and class facts stay in code. Edit Mode writes only to the active Profile.

## Considered Options

- Keep the Layer stack and add Profiles on top — rejected; two save models.
- One AceDB profile per Character — rejected; alts could not share a named layout without a wizard (the old ADR 0001 concern). Account-owned named Profiles keep sharing without a hierarchy.
