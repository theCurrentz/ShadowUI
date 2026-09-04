#!/usr/bin/env python3
"""Bake Zen chrome TGA files, including unit-meter masks and shaped drops."""

from __future__ import annotations

import math
import os
import struct

ROOT = os.path.join(os.path.dirname(__file__), "..", "media")


def write_tga(path: str, width: int, height: int, pixels: bytes) -> None:
    header = bytearray(18)
    header[2] = 2
    struct.pack_into("<HH", header, 12, width, height)
    header[16] = 32
    header[17] = 0x08
    with open(path, "wb") as handle:
        handle.write(header)
        handle.write(pixels)


def chat_fade() -> bytes:
    # TGA origin is bottom-left. Darkest at BL; top and right stay near-clear.
    width, height = 256, 256
    near = 10
    buf = bytearray(width * height * 4)
    for y in range(height):
        for x in range(width):
            nx = x / (width - 1)
            ny = y / (height - 1)
            t = (1 - nx) * (1 - ny)
            alpha = int(round(near + (255 - near) * t))
            index = (y * width + x) * 4
            buf[index : index + 4] = bytes((0, 0, 0, alpha))
    return bytes(buf), width, height


def mask_diamond() -> tuple[bytes, int, int]:
    size = 64
    cx = cy = (size - 1) / 2
    buf = bytearray(size * size * 4)
    for y in range(size):
        for x in range(size):
            dist = (abs(x - cx) + abs(y - cy)) / (size / 2)
            alpha = 255 if dist <= 1 else 0
            if 0.92 < dist <= 1.08:
                alpha = int(max(0, min(255, round(255 * (1.08 - dist) / 0.16))))
            index = (y * size + x) * 4
            buf[index : index + 4] = bytes((255, 255, 255, alpha))
    return bytes(buf), size, size


def ring_alpha(dist: float, inner: float, outer: float, peak: int = 230) -> int:
    if dist <= inner or dist >= outer:
        return 0
    mid = inner + (outer - inner) * 0.25
    if dist <= mid:
        t = (dist - inner) / (mid - inner)
        return int(round(peak * t))
    t = (dist - mid) / (outer - mid)
    return int(round(peak * (1 - t)))


def outer_shadow(metric: str) -> tuple[bytes, int, int]:
    size = 64
    cx = cy = (size - 1) / 2
    radius = size / 2
    inner, outer = 0.70, 1.0
    buf = bytearray(size * size * 4)
    for y in range(size):
        for x in range(size):
            if metric == "circle":
                dist = math.hypot(x - cx, y - cy) / radius
            else:
                dist = (abs(x - cx) + abs(y - cy)) / radius
            alpha = ring_alpha(dist, inner, outer)
            index = (y * size + x) * 4
            buf[index : index + 4] = bytes((0, 0, 0, alpha))
    return bytes(buf), size, size


def sdf_roundrect(x: float, y: float, width: float, height: float, radius: float) -> float:
    ax = abs(x) - (width / 2 - radius)
    ay = abs(y) - (height / 2 - radius)
    ox = max(ax, 0.0)
    oy = max(ay, 0.0)
    inside = min(max(ax, ay), 0.0)
    return math.hypot(ox, oy) + inside - radius


def outer_shadow_roundrect() -> tuple[bytes, int, int]:
    # Stretched drop like circle. 2:1 matches the meter well. Square 9-slice
    # corner quads cannot fray because this is not an edgeFile.
    width, height = 128, 64
    pad = 4.0
    radius = 8.0
    glow = 5.0
    peak = 230
    cx = (width - 1) / 2
    cy = (height - 1) / 2
    inner_w = width - pad * 2
    inner_h = height - pad * 2
    buf = bytearray(width * height * 4)
    for y in range(height):
        for x in range(width):
            dist = sdf_roundrect(x - cx, y - cy, inner_w, inner_h, radius)
            if dist <= 0 or dist >= glow:
                alpha = 0
            else:
                alpha = int(round(peak * (1 - dist / glow)))
            index = (y * width + x) * 4
            buf[index : index + 4] = bytes((0, 0, 0, alpha))
    return bytes(buf), width, height


def mask_roundrect() -> tuple[bytes, int, int]:
    # 2:1 well. Corner radius 8px so a 16px name strip is not a pill.
    width, height = 128, 64
    radius = 8.0
    buf = bytearray(width * height * 4)
    for y in range(height):
        for x in range(width):
            dx = min(x, width - 1 - x)
            dy = min(y, height - 1 - y)
            if dx >= radius or dy >= radius:
                alpha = 255
            else:
                dist = math.hypot(radius - dx, radius - dy)
                if dist <= radius - 1:
                    alpha = 255
                elif dist >= radius + 1:
                    alpha = 0
                else:
                    alpha = int(max(0, min(255, round(255 * (radius + 1 - dist) / 2))))
            index = (y * width + x) * 4
            buf[index : index + 4] = bytes((255, 255, 255, alpha))
    return bytes(buf), width, height


def mask_roundrect_square_left() -> tuple[bytes, int, int]:
    """Square left edge and 2px right corners for the Player Unit Meter Stack."""
    width, height = 128, 64
    radius = 2.0
    buf = bytearray(width * height * 4)
    for y in range(height):
        for x in range(width):
            if x < width - radius or radius <= y < height - radius:
                alpha = 255
            else:
                corner_y = radius if y < radius else height - 1 - radius
                dist = math.hypot(x - (width - 1 - radius), y - corner_y)
                if dist <= radius - 1:
                    alpha = 255
                elif dist >= radius + 1:
                    alpha = 0
                else:
                    alpha = int(round(255 * (radius + 1 - dist) / 2))
            index = (y * width + x) * 4
            buf[index : index + 4] = bytes((255, 255, 255, alpha))
    return bytes(buf), width, height


def main() -> None:
    os.makedirs(ROOT, exist_ok=True)
    pixels, width, height = chat_fade()
    write_tga(os.path.join(ROOT, "chat_fade.tga"), width, height, pixels)
    pixels, width, height = mask_diamond()
    write_tga(os.path.join(ROOT, "mask_diamond.tga"), width, height, pixels)
    pixels, width, height = mask_roundrect()
    write_tga(os.path.join(ROOT, "mask_roundrect.tga"), width, height, pixels)
    pixels, width, height = mask_roundrect_square_left()
    write_tga(os.path.join(ROOT, "mask_roundrect_square_left.tga"), width, height, pixels)
    pixels, width, height = outer_shadow("circle")
    write_tga(os.path.join(ROOT, "outer_shadow_circle.tga"), width, height, pixels)
    pixels, width, height = outer_shadow("diamond")
    write_tga(os.path.join(ROOT, "outer_shadow_diamond.tga"), width, height, pixels)
    pixels, width, height = outer_shadow_roundrect()
    write_tga(os.path.join(ROOT, "outer_shadow_roundrect.tga"), width, height, pixels)


if __name__ == "__main__":
    main()
