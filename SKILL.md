---
name: pixellab-agent
description: Route and answer PixelLab game-asset requests across MCP, REST v2 API, website/editor workflows, Aseprite, Pixelorama, and legacy v1. Use when creating, editing, animating, generating, integrating, troubleshooting, or choosing PixelLab tools/endpoints for characters, objects, tilesets, tiles, maps, UI, backgrounds, image edits, animations, SDKs, API auth, MCP setup, or vibe-coding.
---

# PixelLab Agent

Use this skill as a PixelLab routing brain. Classify the user's asset or API intent first, then choose the supported PixelLab surface. Answer questions directly when the request is a question.

## Workflow

1. Classify the request:
   `question | create asset | edit/transform | animate | integrate/code | troubleshoot docs/API | automate website/editor`.
2. Classify the asset intent:
   `general_image | background | character | object | effect_vfx | ui | whole_map | map_object | top_down_tileset | sidescroller_tileset | isometric_tile | tile_variants | animation | image_edit_transform`.
3. Choose the surface:
   use hosted MCP for managed coding-agent assets, REST v2 for direct API/code/batch primitives, website/Aseprite/Pixelorama only as human/editor surfaces, and REST v1 only for legacy compatibility.
4. Refresh current facts when exact endpoint names, parameters, auth, SDK support, pricing, model/mode availability, or latest MCP tools matter.
5. Act or answer. Ask a short clarification only for known collisions.

## Surface Rules

| Surface | Use for | Avoid |
|---|---|---|
| Hosted MCP | Coding-agent workflows that should create managed PixelLab assets with IDs, polling, downloads, list/get/delete helpers, and project/sandbox/agent helpers. | Raw image/edit/UI primitives that MCP does not expose. |
| REST v2 | Scripts, batch jobs, server integrations, exact endpoint control, generic images, backgrounds, UI, inpaint/edit, prompt enhancement, raw animation, rotate, resize, remove background, and API parity checks. | Guessing SDK methods without checking the installed SDK or current docs. |
| Website, Aseprite, Pixelorama | Human/editor workflows, existing website assets, editor save-back, and manual Map Workshop work. | Programmatic use of copied browser session tokens or undocumented root endpoints. |
| REST v1 | Existing legacy code and old SDK compatibility. | New work unless the user explicitly needs v1. |

Hosted MCP tool names are not REST endpoints. Do not curl MCP tool names as `/v2/...` paths.

## Intent Router

| User intent | Default route | REST v2 route when coding/exact control is needed |
|---|---|---|
| Character, player, NPC, enemy, creature | MCP `create_character`, then `create_character_state`, `animate_character`, `get_character`, list/delete helpers as needed. | Character endpoints such as `create-character-v3`, 4/8-direction character endpoints, `create-character-pro`, state, animation, tags, ZIP/list/get/delete endpoints. |
| Object, prop, item, pickup, weapon, furniture | MCP `create_1_direction_object`, `create_8_direction_object`, `create_map_object`, object state/animation/review tools. | Object endpoints such as `create-1-direction-object`, `create-8-direction-object`, `map-objects`, object state/animation/list/get/delete endpoints. |
| Top-down terrain tileset, Wang/autotile/RPG tileset | MCP `create_topdown_tileset`. | `create-tileset`, `tilesets`. |
| Sidescroller/platformer tileset | MCP `create_sidescroller_tileset`. | `create-tileset-sidescroller`, sidescroller tileset endpoints. |
| Isometric tile/block/floor | MCP `create_isometric_tile`. | `create-isometric-tile`. |
| Individual tiles, tile variants, hex/octagon/square tile pack, tiles pro | MCP `create_tiles_pro`. | `create-tiles-pro`, `tiles-pro/{tile_id}`. |
| General image, sprite, icon-like standalone asset | REST v2. | `create-image-pixen`, `generate-image-v2`, `create-image-pixflux`, `create-image-bitforge`, `generate-with-style-v2`. |
| Background, scene, environment, backdrop | REST v2. | `create-image-pixflux-background` or normal image generation with background in the prompt. |
| UI, HUD, button, panel, health bar, menu | REST v2. | `generate-ui-v2`. Website UI library is a human/editor surface unless public lifecycle endpoints exist. |
| Image edit, inpaint, mask, convert, resize, remove background | REST v2. | `inpaint`, `inpaint-v3`, `edit-image`, `edit-images-v2`, `image-to-pixelart`, `image-to-pixelart-pro`, `resize`, `remove-background`. |
| Raw animation, skeleton, interpolation, outfit transfer, rotate | REST v2 unless animating a managed MCP character/object. | `animate-with-text*`, `animate-with-skeleton`, `estimate-skeleton`, `edit-animation-v2`, `interpolation-v2`, `transfer-outfit-v2`, `rotate`, `generate-8-rotations-v2/v3`. |
| Map object | MCP `create_map_object` by default. | `map-objects`. |
| Whole map, Map Workshop, map CRUD/export | Website manually, or generate components with MCP/REST. | No full public REST/MCP map CRUD surface was documented in the research. |
| Static effect or VFX sprite | REST v2 image/object route depending whether it should be a reusable object. | No standalone public VFX endpoint was documented. |
| Animated effect or VFX | REST v2 raw animation or MCP object animation if it should become a managed object. | Use animation endpoints; treat VFX as an option/description, not a separate public model. |

## Clarify Only For Collisions

- "Tiles": ask whether the user wants individual tile variants or a terrain/autotile tileset.
- "Map": ask whether they want a whole map, map object, map image, tileset, isometric tile, or tile variants.
- "Object/character": infer character for people, NPCs, creatures, body templates, or identity/state animation; infer object for props/items/furniture/weapons. Ask only if unclear.
- "Effect": ask static sprite or animated effect when not obvious.
- "Isometric tileset": ask whether they need one isometric tile or a full tileset, because public docs expose a single isometric tile route.

## Model And Mode Terms

Treat PixelLab model/provider language as product labels unless official docs disclose more.

- `Pixen`, `PixFlux`, `BitForge`, `PixPatch`: public product/workflow labels, not guaranteed provider names.
- `Pro`: quality/tier/mode label across many unrelated tools, not one endpoint or model.
- `v3` and `new`: workflow/version labels scoped to a selected operation, not a universal model.
- `S-XL`, `M-XL`, `S-M`, `M-L`: size/product labels, not asset intents.
- `Gemini`: observed in website Create Tileset Pro copy, but no public v2 tileset parameter was documented that exactly selects that website Pro/Gemini mode.

Do not invent provider internals where PixelLab docs are silent.

## Do Not Use

- Do not automate undocumented website/session endpoints such as root `/tilesets/create` with copied DevTools bearer tokens. Treat them as unsupported unless PixelLab documents them.
- Do not treat `https://api.pixellab.ai/` redirecting to v1 docs as proof that root website routes map to `/v1`.
- Do not confuse website Create Tileset Pro with public `create_tiles_pro` / `create-tiles-pro`; they are different flows.
- Do not call website session bearer tokens API tokens. Public REST/MCP bearer tokens and website session tokens are different auth contexts.
- Do not default to v1 or old SDK README examples for new work.
- Do not claim public SDK coverage without checking the installed package or current official repo state.

## Current Docs Refresh

Use local routing rules for stable judgment. Check official docs before exact current claims or code:

- `https://api.pixellab.ai/mcp/docs`
- `https://api.pixellab.ai/v2/llms.txt`
- `https://api.pixellab.ai/v2/docs`
- `https://api.pixellab.ai/v2/openapi.json`
- `https://www.pixellab.ai/mcp`
- `https://github.com/pixellab-code` for official SDK/MCP repo state
- `https://api.pixellab.ai/v1/openapi.json` only for legacy checks

If web access is unavailable, answer from this skill and say which current claim was not freshly verified.

## Answer Shape

For questions, answer with:

1. Recommended surface or endpoint/tool.
2. Why that route fits.
3. Warnings for unsupported or confusing alternatives.
4. Official-doc caveat when the answer was not freshly verified.

For tasks, proceed with the selected MCP tool or REST v2 endpoint when credentials/tooling are available. Otherwise provide the exact route and minimal code or call shape the user needs.

## Examples

| Request | Route |
|---|---|
| "Make a wizard with idle and walk animations." | MCP `create_character`, then `animate_character`. |
| "Generate a mossy platformer tileset from code." | REST v2 `create-tileset-sidescroller`; use MCP `create_sidescroller_tileset` if working inside an MCP-enabled agent. |
| "Make HUD buttons and a health bar." | REST v2 `generate-ui-v2`. |
| "Convert this image to pixel art and remove the background." | REST v2 `image-to-pixelart` or Pro variant, then `remove-background`. |
| "Use `/tilesets/create` with my browser token." | Do not use it; route to public MCP/REST tileset tools or manual website use. |
| "What does Pro use?" | Explain only documented/product-level facts; do not infer provider internals. Refresh official docs if current model/mode details matter. |
