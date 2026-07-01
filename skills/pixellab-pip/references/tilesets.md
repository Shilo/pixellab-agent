# Tilesets

Read this for terrain tilesets, platformer tilesets, isometric tiles, tile variants, or website Create Tileset Pro ambiguity.

"Tiles" is ambiguous. If unclear, ask whether the user wants:

- Terrain/autotile tileset.
- Platformer/sidescroller tileset.
- Individual tile variants such as hex, octagon, square, or isometric.
- One isometric tile/block.
- Manual website Create Tileset Pro.

Capture tile size, view, terrain pair or tile list, transition description, base tile IDs, style/reference/palette images, seed, and target engine/export convention when relevant.

Before spending repeated generations on prompt wording, check the visible MCP schema or current REST schema for controllable generation parameters. For top-down and sidescroller tilesets, relevant controls may include:

- `text_guidance_scale`: increases or decreases text-description adherence.
- `tile_strength`: changes tile-pattern adherence.
- `tileset_adherence`: controls reference/texture image and tileset-structure adherence.
- `tileset_adherence_freedom`: controls structural flexibility; higher means more flexibility.
- `seed`: makes a promising setup reproducible when exposed.
- `lower_reference_image`, `upper_reference_image`, and `transition_reference_image`: REST controls for anchoring terrain or transition style.
- `color_image`: REST control for palette anchoring; for top-down REST tilesets, prepare it as a 64x64 palette reference unless current docs or route behavior prove another size is accepted.
- Pro-only shape controls such as `spread_x`, `slope_size`, and `raggedness`.

If the desired result depends on strict palette, dithering placement, or a specific wall/floor material split, prefer REST tileset generation when it exposes reference or palette image fields that the visible MCP tool does not. Use prompt-only MCP retries only after checking that the needed controls are unavailable in the current surface.

The Standard top-down generator does not reliably enforce strict 1-bit black-and-white output or readable wall-surface dithering from text alone, even with high `text_guidance_scale`. Treat `1-bit`, `dithered`, `stippled`, `checker`, `no gray`, and similar wording as soft hints unless a palette/reference control or approved post-processing route is also used.

For REST top-down tilesets, treat `transition_reference_image` as a style reference rather than an exact mask or stamp. If `tile_size` is 16 and `transition_size` is 0.5, prefer a 16x16 reference that shows the desired 8-pixel transition or wall band within tile context. Use a bare 8x8 texture only when the user explicitly wants a generic texture reference without terrain context. Keep `text_guidance_scale` at the default unless the user's text description is more important than matching the reference image; high text guidance can make text/model priors compete with the reference and may worsen palette drift.

Use REST `color_image` when the user clearly wants a fixed palette, such as an explicit color list, `1-bit`, `black and white`, or a supplied palette image. For top-down REST tilesets, the request validator may accept a smaller PNG but the background job can fail later with an internal `Expected image of size 64x64` error. Avoid that process trap by sending a 64x64 palette reference image for `color_image` unless current route behavior proves a different size works. If a tileset job fails with that size expectation and the palette image was smaller or unknown, retry once with a 64x64 `color_image` when the user's budget/attempt count allows; report the mismatch as a PixelLab validation/background-job caveat.

If PixelLab produces a useful tileset whose colors still need exact indexed-palette cleanup, read `aseprite-cli.md` for the palette-clamp route. Report the untouched PixelLab original separately from any Aseprite/local palette-clamped derivative, and do not imply the derivative is the raw PixelLab result.

Do not equate website Create Tileset Pro with public `create-tiles-pro`. Treat older Gemini wording as stale/low-confidence unless current official website docs reintroduce it.
