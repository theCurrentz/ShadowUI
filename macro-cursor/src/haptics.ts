/** Short device pulse. No-op when the browser cannot vibrate, or when motion is reduced. */
export function tapFeedback(kind: "light" | "medium" = "light"): void {
  if (typeof navigator === "undefined" || typeof navigator.vibrate !== "function") return;
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
  navigator.vibrate(kind === "medium" ? 14 : 8);
}
