# PixelLab Skill Icon Generation Spike

Last reviewed: 2026-06-28.

Purpose: capture live-generation findings for fantasy RPG skill icon and item icon requests so `pixellab-pip` can route future "skill icon", "ability icon", "spell icon", "action bar icon", and similar requests with better defaults.

This spike is based on live PixelLab generations and human visual review. The current human-ranked winner is REST v2 `POST /generate-image-v2` ("Create S-XL image (Pro)") for complete 8x8 finished skill icon sheets, despite the winning run still violating the strict borderless target with a subtle dark card-edge treatment.

## Target Asset Definition

A finished skill icon sheet means:

- A structured grid, usually 8x8 for 64 icons.
- Each icon is exactly one 32x32 cell when the user asks for 32px icons.
- Full colorful illustrated background in every cell.
- A large, readable central pictorial symbol.
- No text, labels, letters, numbers, fake writing, runes, or glyph-like marks.
- No transparency.
- No borders, frames, UI slots, rounded corners, gutters, or decorative dividers unless the user explicitly asks for them.

The last point is important: downstream users can add borders in their game UI. PixelLab should produce clean borderless art by default.

## Current Recommendation

Use REST v2 `POST /generate-image-v2` first when the user asks for a complete finished skill icon sheet, especially an 8x8 or 64-icon sheet.

Why:

- It produced the strongest human-rated result in this spike.
- It generated the full 8x8 sheet in one call.
- It created full colorful backgrounds.
- The foreground symbols were extremely clear and readable.
- It produced a consistent set with useful symbol variety.
- It returned an exact 256x256 opaque image for an 8x8 sheet of 32px cells.

Known downside:

- It tends to add a subtle 1px dark border/card-slot treatment around each icon even when instructed not to. Future prompts should emphasize "borderless art only", "no black outline around cell edges", "no separating cell lines", and "background continues to cell edges".
- The likely cause is training-prior vocabulary: `skill icons`, `game UI`, `strict grid`, `cell`, and `spritesheet` often imply action-bar slots. Reframe the sheet as a `borderless spritesheet mosaic`, say the grid is invisible, and avoid `UI`, `button`, `slot`, `card`, and `frame` wording unless the user wants those elements.

Use `create_tiles_pro` as an experimental alternative when the user wants a tile-like set or when Pro image generation keeps failing semantic style, but do not treat it as the default for finished skill icon sheets yet.

## Prompting Rules Learned

Use these phrases for skill icon prompts:

- `Pictorial symbols only`
- `Use clear centered pictures and silhouettes`
- `Do not use runes or glyphs`
- `No text-like marks`
- `No letters, no words, no numbers, no labels, no captions, no handwriting, no decorative script, no fake writing, no alphabet-like shapes`
- `Every pixel must be painted`
- `Fully opaque`
- `No transparent pixels, no alpha, no blank corners, no padding`
- `No borders, no frames, no UI slots, no rounded corners, no gutters, no decorative dividers`
- `No black outline around each cell`
- `No separating lines between icons`
- `Invisible grid only`
- `Borderless spritesheet mosaic`
- `Do not draw separator lines, seams, perimeter strokes, boxes, card edges, icon slots, frames, borders, or outlines around square areas`
- `Background artwork must reach all four edges and all four corners and touch neighboring artwork directly`

Avoid these phrases unless the user explicitly wants them:

- `rune`
- `glyph`
- `spellbook labels`
- `numbered icon labels`
- `UI slot`
- `button`
- `frame`
- `border`
- `card`
- `game UI`

Even negative mentions of `rune` and `glyph` helped only when paired with "do not use"; positive use of those words can drift into text-like marks.

## Route Findings

### REST `POST /generate-image-v2`

Observed as "Create S-XL image (Pro)" / generic Pro image generation.

Tested parameters:

- Endpoint: REST v2 `POST /generate-image-v2`
- `image_size`: `{ "width": 256, "height": 256 }`
- `no_background`: `false`
- Best human-ranked seed so far: `24062805`
- Border-reduction trial seed: `24062806`

Best use:

- Complete 8x8 skill icon spritesheets.
- Finished action-bar icon sets.
- Skill icons where readability and colorful backgrounds matter more than exact per-icon semantic uniqueness.

Pros:

- Best human-ranked result so far.
- Clear, readable symbols.
- Full colorful backgrounds.
- Strong consistency across the sheet.
- Good mixture of skills and item-like symbols.
- Can produce an exact `256x256` sheet for 64 `32x32` cells.
- Produced fully opaque output in the winning run.

Cons:

- Tends to add a subtle 1px black border/card edge around cells.
- Can repeat visual categories, especially shields, weapons, potions, portals, and elemental effects.
- Can still hallucinate text if the prompt does not strongly ban all text-like marks.
- Single-shot sheets can obey the overall grid while not perfectly matching every requested individual skill concept.

Winning trial input:

```json
{
  "endpoint": "POST https://api.pixellab.ai/v2/generate-image-v2",
  "body": {
    "description": "A complete 8 by 8 spritesheet of 64 unique fantasy RPG ability icons. Exact canvas 256x256 pixels. Strict grid: 8 columns, 8 rows, each cell exactly 32x32 pixels, no spacing, no overlap, no cropped cells. Pixel art game UI skill icons, cohesive high fantasy theme, readable at 32px.\n\nEach cell is a finished opaque square icon with a full-bleed illustrated fantasy background touching all four edges and all four corners. Every pixel must be painted. No transparent pixels, no alpha, no blank corners, no padding.\n\nPictorial symbols only. Use clear centered pictures and silhouettes: flames, ice shards, lightning bolts, shields, hands, daggers, arrows, skulls, leaves, spirits, portals, stars, wings, claws, weapons, masks, potions, celestial beams, aura effects. Do not use runes or glyphs. No text-like marks. No letters, no words, no numbers, no labels, no captions, no handwriting, no decorative script, no fake writing, no alphabet-like shapes.\n\nUnique varied abilities: elemental magic, weapon attacks, healing, protection, stealth, curses, nature magic, summoning, movement, utility, crafting, survival, resurrection, treasure sense. No terrain tiles, no map tiles, no inventory item sheet. No borders, no frames, no UI slots, no rounded corners, no decorative dividers, no watermark. Palette: sapphire blue, ember orange, moonlit violet, emerald green, gold highlights.",
    "image_size": {
      "width": 256,
      "height": 256
    },
    "no_background": false,
    "seed": 24062805
  }
}
```

Winning trial verification:

- Output file: `generated/fantasy_skill_icons_create_image_pro_trial/create_image_pro_skill_icons_pictorial_8x8_32px.png`
- Dimensions: `256x256`
- Alpha: fully opaque. Report alpha as `alpha_min=255`, `alpha_max=255` when using 8-bit alpha, or explicitly say `normalized alpha=1.0` if using normalized tooling.
- Cropped cell hashes: 64 pixel-hash-unique cells. This proves non-identical pixel data, not semantic uniqueness.
- Usage: 20 generations
- Main issue: subtle black border around each icon cell.

Border-reduction trial:

```json
{
  "endpoint": "POST https://api.pixellab.ai/v2/generate-image-v2",
  "body": {
    "description": "Complete borderless 8x8 pixel-art spritesheet mosaic of 64 unique fantasy RPG ability pictograms. Exact canvas 256x256. Invisible grid only: 8 columns, 8 rows, each adjacent square area exactly 32x32, packed edge-to-edge, no spacing, no gaps, no overlap, no cropped art.\n\nEach 32x32 area is a full-bleed opaque miniature fantasy painting with a large clear centered ability symbol. The painted background must reach all four edges and all four corners and touch neighboring artwork directly. Do not draw the grid. Do not draw separator lines, seams, perimeter strokes, boxes, card edges, icon slots, frames, borders, outlines around square areas, or dark edge pixels along the 32x32 boundaries. Square fully painted corners, never rounded.\n\nPictorial symbols only: flames, ice, lightning, shields, hands, daggers, arrows, skulls, leaves, spirits, portals, stars, wings, claws, weapons, masks, potions, beams, aura effects, waves, stones, vines, eyes, chains, hearts, crowns, hammers, hooks, moons, suns. Large readable symbols, integrated into the background, not enclosed in UI.\n\nNo text, letters, words, numbers, labels, captions, handwriting, decorative script, fake writing, runes, glyphs, alphabet-like marks, watermark, transparent pixels, alpha, blank pixels. Varied abilities: elements, healing, protection, stealth, curses, nature, summoning, movement, crafting, survival, resurrection, treasure sense, weapon attacks, mind, time, gravity, poison, holy, shadow, blood, mana, rage, tracking, mining, fishing, cooking, alchemy, lockpicking, leadership, taunt, cleanse, traps, phoenix, dragon breath. Palette: sapphire blue, ember orange, moonlit violet, emerald green, gold highlights.",
    "image_size": {
      "width": 256,
      "height": 256
    },
    "no_background": false,
    "seed": 24062806
  }
}
```

Border-reduction trial verification:

- Output file: `generated/fantasy_skill_icons_create_image_pro_borderless_trial/create_image_pro_skill_icons_borderless_8x8_32px.png`
- Dimensions: `256x256`
- Alpha: `alpha_min=255`, `alpha_max=255`, `transparent_pixels=0`
- Cropped cell hashes: 64 pixel-hash-unique cells; semantic uniqueness still needs visual review.
- Visual result: reduced the obvious 1px card-grid border compared with the previous winning run, but many symbols still use dark pixel outlines and boundary-edge pixels remain darker than the sheet average. Treat this as an improvement, not a solved no-border guarantee.

### REST `POST /create-image-pixen`

Best use:

- Fast one-shot experiments for full icon sheets.
- Cases where the user wants a simpler, flatter icon style.

Tested parameters:

- Endpoint: REST v2 `POST /create-image-pixen`
- Target: one-shot 8x8, `256x256`, 64 fantasy skill icons.

Pros:

- Understood "skill icons" better than object generation.
- Produced clear central foregrounds.
- Produced unique backgrounds.
- One-call 8x8 sheet generation.

Cons:

- Added gutters/spacing.
- Added rounded dark cell shapes and implied borders.
- Foreground symbols were effectively smaller than the requested 32px cell, closer to roughly 26px.
- Backgrounds were simpler than desired.
- Less strong than `generate-image-v2` for the finished fantasy skill icon target.

### MCP `create_tiles_pro`

Best use:

- Experimental route for skill icon-like tile cells.
- Possible fallback when the user wants 16-icon batches or tile-like ability icons.
- Style exploration before a final Pro image generation prompt.

Tested parameters:

- Tool: MCP `create_tiles_pro`
- `tile_type`: `square_topdown`
- `tile_view`: `top-down`
- `tile_size`: `32`
- `outline_mode`: `segmentation`

Pros:

- Produced outputs that looked much more like actual skill icons than object generation.
- Strong icon-read at 32px after prompt optimization.
- Good high-fantasy backgrounds.
- `tile_size=32` produced exact 32x32 source tiles.
- The "pictorial symbols only" prompt reduced text-like artifacts.

Cons:

- At `tile_size=32`, one generation produced 16 variations, not 64. A full 8x8 sheet requires four jobs and local assembly.
- It is still tile-system prompted; output can inherit tile/cutout behavior.
- Raw outputs often contain transparent pixels/corners despite "no transparency" wording.
- Numbered per-tile prompts and `rune`/`glyph` language can create text-like marks.
- A full-sheet REST `edit-images-v2` pass was observed to fix opacity in one 4x4 source sheet, but verify afterward; it costs another generation batch and may not improve art quality.

Best prompt additions:

- `Pictorial symbols only`
- `Do not use runes or glyphs`
- `Every pixel must be painted`
- `Background must fill the entire 32x32 square and touch all four edges and all four corners`

### REST `POST /edit-images-v2`

Best use:

- Sheet-level cleanup after a promising generation.
- Filling transparency after `create_tiles_pro` or another route, when the source art is already good.
- Preserving a grid while fixing opacity/background fill.

Pros:

- One full-sheet pass fixed alpha in the 4x4 tiles-pro trial.
- Cheaper operationally than editing each tile independently.
- Can preserve the overall icon look while making the sheet fully opaque.

Cons:

- Does not reliably fix underlying semantic problems such as scene-heavy icons.
- Can inherit weak foreground readability from the source image.
- Can subtly alter pixels; use only when the source art is already close.

Recommendation:

- Use sheet-level edit, not per-tile edit, when the sheet is already visually good but has opacity/background issues. Treat this as observed cleanup, not a reliable rescue path; always verify opacity and visual quality afterward.

### MCP `create_1_direction_object`

Best use:

- Standalone transparent item/object icons.
- Pickups, props, inventory items, weapons, materials, furniture, and other object-like assets.

Tested parameters:

- Tool: MCP `create_1_direction_object`
- `size`: `32`
- `view`: `sidescroller`
- `item_descriptions`: 64 unique fantasy skill/icon descriptions.

Pros:

- Strong for isolated objects and item-like foregrounds.
- Good symbol silhouettes when the target can be treated as an object.
- Can produce many candidates in a review pack.

Cons for skill icon sheets:

- Object-first behavior, not GUI/skill-icon behavior.
- Produces item/object-like assets rather than finished action-bar icons.
- Tends toward transparent backgrounds unless heavily prompted otherwise.
- Background-heavy prompting overcorrected into scene-based miniatures with weak skill readability.

Recommendation:

- Do not default to this for finished skill icons.
- Use it when the user asks for transparent item icons, pickup icons, or object sprites.

### REST `POST /create-image-pixflux`, `POST /create-image-bitforge`, `POST /generate-with-style-v2`

Status:

- Not evaluated in this spike for finished skill icon sheets.

Possible future use:

- Style reference workflows if the user provides a preferred icon sheet.
- Alternative image models if `generate-image-v2` keeps adding borders.

### REST `POST /generate-ui-v2`

Status:

- Not yet evaluated in this spike.

Hypothesis:

- It may understand action-bar/UI icon semantics, but it may also increase the risk of UI slots, borders, frames, rounded corners, or button-like styling.
- It should be tested after this spike because the current winning issue is exactly a UI-like border.

Recommended test:

- Raw 8x8 skill icon sheet prompt with "borderless art only", `no_background=false`, exact `256x256`.
- Compare text artifacts, cell borders, and symbol clarity against `generate-image-v2`.

### REST `POST /create-ui-asset` and MCP `create_ui_asset`

Status:

- Not yet evaluated for skill icon sheets in this spike.

Hypothesis:

- Structured UI asset routes are likely useful for panels, buttons, icon buttons, toolbars, and action bars.
- They may be a poor default for borderless skill icon artwork because they are explicitly UI-asset/panel oriented and may encourage frames, slots, and rounded rectangles.

Recommended test:

- Try only after `generate-ui-v2`, and treat as a UI-slot/action-bar test rather than a pure icon-art test.

## Item Icon Guidance

"Item icon" is ambiguous:

- If the user wants transparent inventory objects or pickups, use MCP `create_1_direction_object` or REST object/image routes.
- If the user wants finished action-bar item icons with colorful square backgrounds, use the same skill-icon guidance as above and prefer REST `generate-image-v2`.
- If the user wants both item and skill icons in one sheet, `generate-image-v2` handled mixed symbols well in the winning run.

## Suggested `SKILL.md` Routing Update

Future `SKILL.md` guidance should distinguish:

- `skill icon`, `ability icon`, `spell icon`, `action-bar icon`, `hotbar icon`: finished UI icon art, default to REST `generate-image-v2` for complete sheets.
- `item icon` with transparent/backgroundless wording: object/icon asset, likely object route.
- `item icon` with action-bar/UI/backgrounded wording: finished icon art, default to REST `generate-image-v2`.

Draft routing rule:

> For finished skill/ability/spell/action-bar icon sheets, prefer REST `generate-image-v2` over object generation, Pixen, and tiles-pro. Use strict prompt wording for pictorial symbols only, no text-like marks, fully opaque painted cells, and no borders/frames/UI slots. Verify dimensions, alpha, grid structure, visual text artifacts, and cell-edge borders before calling the output final. Use `create_tiles_pro` only as an experimental/fallback style route, and use sheet-level `edit-images-v2` only for opacity/background cleanup on an already-good sheet.

Avoid routing finished skill icon sheets to UI routes merely because the user says `action bar` or `hotbar`; use UI routes only when the user asks for the slot/button/container itself.

## Verification Checklist

Always verify:

- Output dimensions match the requested sheet size.
- Sheet divides exactly into requested cell dimensions.
- Alpha is fully opaque when the user requests backgrounded/no transparency.
- Cropped cells are unique by hash when uniqueness is required; this checks pixel uniqueness only.
- Human visual check for semantic uniqueness when each icon must represent a distinct skill concept.
- Human visual check for text-like marks.
- Human visual check for borders, frames, gutters, rounded corners, or slot styling.
- Human visual check that central symbols are readable at 32px.

For border detection, metadata is not enough. A 1px black border can be fully opaque and structurally valid while still violating the user's art requirement.

## Open Questions

- Can prompt wording eliminate the 1px border in `generate-image-v2`, or is it a model habit for icon sheets?
- Does REST `generate-ui-v2` produce cleaner borderless skill icons or more UI-slot artifacts?
- Can `create-ui-asset` or MCP `create_ui_asset` be coerced into borderless icon-art sheets, or are they inherently panel/slot oriented?
- Does `generate-with-style-v2` using the current winner as style reference preserve clarity while removing borders?
- For production 64-icon sheets, is it better to generate one full sheet, four 4x4 sheets, or individual icons when exact per-icon semantics matter?
