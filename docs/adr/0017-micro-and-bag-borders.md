# Forever leaves the micro menu and bag bar in place

The Micro Cluster docked `MicroMenu` and the backpack, parked Shop and extra bag slots, and stripped the tray. That replaced the Blizzard bars. Forever now leaves those bars where Blizzard put them, including every button and the tray art. ShadowUI adds an Outer Edge on the Micro Bar and Bag Bar borders. `/shadowui` can turn that shadow off.

Hide, SetPoint, and SetAlpha on the protected micro and bag buttons stay off. The bars are not moved, so those calls are not needed.

## Considered Options

- Keep the Micro Cluster and only restore tray art — rejected; the row, the hidden buttons, and the parked bag slots are not the original bars.
- Darken the whole bar — rejected; the interior and the icons stay Blizzard. Only the border is shadowed.

Status: accepted.
