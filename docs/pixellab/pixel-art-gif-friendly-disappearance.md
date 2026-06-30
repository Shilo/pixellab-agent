# Pixel-Art GIF-Friendly Disappearance Research

Generated: 2026-06-26.

This is a research note for prompt wording and asset QA. It is not a PixelLab Pip skill reference and should not be copied into the Pip skill routing files unless later promoted intentionally.

## Problem

Pixel-art animations often need an object to disappear while remaining GIF-friendly. GIF transparency is effectively binary: a pixel is either transparent or opaque. Pixel art also usually benefits from crisp whole-pixel changes rather than smooth opacity, feathering, or antialiasing.

The target constraint is:

- Pixel-art style.
- Short animation, usually 6-10 frames and under 1 second.
- Transparent background is allowed.
- No semi-transparent pixels.
- No alpha fade, smooth opacity, feathering, or shader-style soft erosion.
- Each output pixel alpha should be either 0 or 255.

## Recommended Term

Use this as the clearest practical phrase:

```text
pixel-art 1-bit transparency dithered cutout dissolve
```

For natural short animation, combine it with:

```text
pixel-art particle dissipation / poof vanish
```

Best full wording:

```text
Use a short pixel-art particle dissipation / poof vanish animation with a 1-bit transparency dithered cutout dissolve. The object disappears by breaking into fully opaque smoke puffs, sparks, dust, chunks, or pixels that shrink, drift, and vanish over 6-10 frames. Every pixel must be either fully opaque or fully transparent. No semi-transparent pixels, no alpha fade, no smooth opacity, no feathering.
```

## Shortest High-Confidence Wording

Use this when prompt space is tight:

```text
short pixel-art poof vanish, 1-bit transparency, no semi-transparent pixels
```

If the model/tool tends to ignore constraints, use the slightly safer version:

```text
6-10 frame pixel-art poof vanish / particle dissipation, 1-bit transparency only, no alpha fade or semi-transparent pixels
```

This is the shortest combination that still carries the three important ideas: pixel-art style, natural short disappearance motion, and binary alpha.

## Why This Wording

No single standard term reliably implies both "pixel art" and "binary alpha" on its own.

- `pixel-art` locks the expected aesthetic.
- `1-bit transparency` is the clearest technical phrase for binary alpha.
- `dithered cutout dissolve` describes the on/off pixel removal method.
- `particle dissipation` or `poof vanish` nudges the result toward a hand-animated, short, natural sprite effect instead of a long procedural mask wipe.
- Explicit negatives prevent common failures: semi-transparent PNG frames, alpha fades, smoothstep opacity, feathered masks, and shader-style erosion.

## Preferred Visual Approach

For arbitrary pixel-art objects, prefer a short hand-animated-looking disappearance:

1. Start from the original object silhouette.
2. Break the silhouette from the edges and high-energy areas first, not random holes from the center.
3. Convert remaining shape into readable particles: smoke puffs, sparks, dust, ash, fragments, magic motes, or debris depending on the object.
4. Shrink or remove those particles over a few frames.
5. End fully empty or with a tiny fully opaque residue, depending on the effect.

For smoke/fire/magic, the best natural look is usually:

```text
puffs drift, shrink, and vanish; embers wink out; ash motes separate and disappear.
```

For solid objects, use:

```text
edge-first crumble into chunks and dust, then particles shrink and vanish.
```

For fade-like disappearance without semi-transparency, use:

```text
dither/noise cutout pattern removes whole pixels over time.
```

## Terms To Use Carefully

### Alpha Erosion

`alpha erosion` is common in realtime VFX, but it is risky for pixel-art GIF prompting. It often implies procedural masks, smooth thresholds, feathering, or many-frame shader transitions. In a subagent test, a bare instruction to make an "alpha erosion" animation produced PNG frames with many semi-transparent alpha values, even though the final GIF preview had binary transparency.

Use only with explicit constraints:

```text
binary alpha erosion, edge-first, 6-10 frames, no smoothstep, no feathering, no partial alpha.
```

### Pixel Disintegration

`pixel disintegration` is visually descriptive, but it does not guarantee pixel-art style or binary transparency. It can imply modern VFX particles, shader effects, or smooth alpha unless constrained.

### Dithered Transparency

`dithered transparency`, `screen-door transparency`, and `stipple transparency` are technically close: they fake transparency by omitting pixels. However, these terms are common in shader/rendering contexts, not necessarily pixel-art GIF asset generation. Pair them with `pixel-art`, `1-bit transparency`, and `no semi-transparent pixels`.

### GIF Transparency

GIF transparency implies binary transparency at the file format level, but it does not describe how the object should disappear. It also does not guarantee the source PNG frames are binary alpha unless verified.

## Recommended Prompt Template

```text
Make the object disappear in a short pixel-art GIF-friendly animation.
Use pixel-art particle dissipation / poof vanish with a 1-bit transparency dithered cutout dissolve.
Use 6-10 frames max.
The object should break from the edges or active areas into fully opaque smoke puffs, sparks, dust, chunks, or pixels that shrink, drift, and vanish.
Every pixel must be either fully opaque or fully transparent: alpha 0 or 255 only.
No semi-transparent pixels, no alpha fade, no smooth opacity, no feathering, no antialiased transparent edges.
Keep the canvas fixed and animate in place so the game can move the effect at runtime.
```

## Meteor Example

```text
After impact, make the remaining meteor crater/fire disappear in 6-8 frames using pixel-art particle dissipation / poof vanish with 1-bit transparency. Embers wink out, smoke puffs shrink and drift upward, debris chunks settle or vanish, and the silhouette clears from the edges and active glowing areas. Every pixel must be fully opaque or fully transparent. No semi-transparent pixels, no alpha fade, no smooth opacity, no feathering.
```

## Verification Checklist

For quality review, verify original generated frames before any GIF assembly or post-processing:

- Keep the original PNG frames returned by the generator.
- Verify every frame has fixed dimensions.
- Verify alpha values are only `0` and `255`.
- Verify there are no matte backgrounds unless intentionally requested.
- Verify the animation is short enough for a sprite effect, usually 6-10 frames.
- Verify disappearance reads as object-specific motion, not a generic center-out mask.
- Treat GIF previews as export artifacts; inspect source PNG frames for real alpha quality.

Example alpha check with Pillow:

```python
from pathlib import Path
from PIL import Image

for path in sorted(Path("frames").glob("*.png")):
    alpha = Image.open(path).convert("RGBA").getchannel("A")
    values = set(alpha.getdata())
    bad = sorted(v for v in values if v not in (0, 255))
    print(path.name, "ok" if not bad else f"bad alpha values: {bad[:10]}")
```

## Source Notes

- Aseprite community guidance says GIF animation export does not support alpha channels; pixels are fully opaque or fully transparent: https://community.aseprite.org/t/i-need-to-make-a-gif-with-colors-that-become-transparent-or-semi-transparent-layers/7507
- Graphic Design Stack Exchange describes GIF as indexed transparency where each pixel is transparent or not: https://graphicdesign.stackexchange.com/questions/86249/transparent-gif-with-media-encoder
- Alex Ocias describes stipple/screen-door/dithered transparency as omitting more pixels from an object as transparency increases: https://ocias.com/blog/unity-stipple-transparency-shader/
- PixStipple describes dither-patterned transparency for pixel-art animations: https://wunkolo.itch.io/pixstipple
- PNG specification defines intermediate alpha values as partially transparent pixels, which are exactly what this workflow avoids: https://www.w3.org/TR/PNG-DataRep.html
