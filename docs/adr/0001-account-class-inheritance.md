---
status: superseded by ADR-0008
---

# Account-owned class inheritance instead of character profiles

Superseded by [ADR 0008](0008-named-profiles.md), then [ADR 0014](0014-one-account-profile.md). ShadowUI stores one Account Profile. Shipped Class defaults still merge first.

Most bar addons store layout per character (AceDB profiles). ShadowUI stored Layout and Keybind overlays on the Account and merged Base → Class → Variant, then a sparse Character overlay so same-class alts inherited Class and Variant with no wizard.
