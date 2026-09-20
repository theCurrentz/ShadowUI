# Frame Art source

Classic Era `Interface/TargetingFrame/UI-TargetingFrame` (build 1.15.9, file id 137026).

| File | What it is |
| --- | --- |
| `UI-TargetingFrame.png` | Full atlas, 256×128 |
| `UI-TargetingFrame-target.png` | Displayed Target crop, 232×100 (unflipped) |
| `UI-TargetingFrame-player.png` | Displayed Player crop, 232×100 (X-flipped) |
| `UI-TargetingFrame.blp` | The game file |

Edit the atlas in Aseprite, Krita, Photoshop, or GIMP. Keep 256×128. Convert PNG back to BLP before the client can load it as Frame Art. ShadowUI still paints the Blizzard path until a custom file is wired in.

Displayed UVs: u from 24/256 to 1, v from 0 to 100/128.
