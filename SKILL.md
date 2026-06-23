---
name: pixellab-agent
description: Route and answer PixelLab game-asset requests across MCP, REST v2 API, website/editor workflows, Aseprite, Pixelorama, and legacy v1. Use when creating, editing, animating, generating, integrating, troubleshooting, or choosing PixelLab tools/endpoints for characters, objects, tilesets, tiles, maps, UI, backgrounds, image edits, animations, SDKs, or vibe-coding.
---

# PixelLab Agent

Use this skill to choose the right PixelLab surface before answering or acting.

## Workflow

1. Classify the request: question, create asset, edit/transform, animate, integrate/code, troubleshoot docs/API, or automate website/editor.
2. Classify the asset intent: character, object, top-down tileset, sidescroller tileset, isometric tile, tile variants, animation, UI, background, general image, map object, whole map, or image edit/transform.
3. Choose a surface:
   - Hosted MCP for managed coding-agent assets.
   - REST v2 for direct primitives, scripts, batch jobs, exact endpoints, raw image/edit/animation primitives, and current public API use.
   - Website, Aseprite, and Pixelorama as human/editor surfaces unless PixelLab documents an automation contract.
   - REST v1 only for legacy compatibility.
4. Verify official docs before exact endpoint/schema/auth/SDK/latest claims.
5. Act or answer with the chosen route.

## Intent Router

| User wants | Default route |
|---|---|
| Character, player, NPC, enemy, creature | MCP `create_character`, then animation/get tools as needed. Use REST v2 for exact v3/Pro/template control. |
| Object, prop, item, weapon, furniture | MCP object tools. Use `create_map_object` when it must blend into a map. |
| Top-down terrain, Wang, autotile, transition tileset | MCP `create_topdown_tileset`. |
| Platformer or sidescroller tileset | MCP `create_sidescroller_tileset`. |
| Individual tiles, tile variants, hex/octagon tiles | MCP `create_tiles_pro`. |
| Isometric tile/block | MCP `create_isometric_tile`. |
| UI, HUD, buttons, health bars, menu, panel | REST v2 `generate-ui-v2`. |
| Background, scene, environment image | REST v2 image/background endpoint. |
| General sprite or image | REST v2 image endpoint unless it should become a managed MCP asset. |
| Inpaint, edit, mask, resize, remove background, pixel-art conversion | REST v2 edit/transform endpoints. |
| Raw animation, skeleton animation, interpolate, transfer outfit, edit animation | REST v2 animation endpoints unless animating an existing MCP character/object. |
| Whole map | Website/manual workflow, or generate component tilesets/map objects with MCP/REST. Do not claim public map CRUD/export unless documented. |

Ask a short clarification only for collisions:

- "tiles" without context: individual tile variants or terrain tileset?
- "map": whole map, map object, map image, or tileset?
- "effect": static sprite or animation?
- "object/character": reusable animated character or prop/item?
- "isometric tileset": one isometric tile or a full tileset?

## Surface Rules

- Use hosted MCP by default when the user is coding with an AI assistant and wants managed game assets.
- Use REST v2 when the user needs code, batches, exact endpoints, prompt enhancement, UI generation, raw image generation, image conversion, inpaint/edit/resize/remove-background, or raw animation.
- Treat website, Aseprite, Pixelorama, and Map Workshop as editor/manual contexts unless PixelLab documents automation for the exact action.
- Use REST v1 only for old SDKs or legacy code.

## Current Docs

Refresh official PixelLab docs when the user asks for latest/current facts, exact schemas, auth wording, SDK coverage, pricing, model/mode availability, endpoint parameters, or MCP/API parity.

Official sources to prefer:

- https://api.pixellab.ai/mcp/docs
- https://api.pixellab.ai/v2/llms.txt
- https://api.pixellab.ai/v2/docs
- https://api.pixellab.ai/v2/openapi.json
- https://www.pixellab.ai/mcp
- https://api.pixellab.ai/v1/openapi.json for legacy checks only
- https://github.com/pixellab-code for official SDK/MCP repository state

If browsing is unavailable, answer from this skill and say the specific API claim was not freshly verified.

## Do Not Use

- Do not call or recommend website session endpoints such as `/tilesets/create` for automation.
- Do not use copied browser bearer tokens or website session auth as API auth.
- Do not treat `https://api.pixellab.ai/` redirecting to v1 docs as proof that root website routes are public REST endpoints.
- Do not confuse `create_tiles_pro` with website Create Tileset Pro.
- Do not use `Pro`, `new`, `v3`, `S-XL`, `M-XL`, `S-M`, or `M-L` as primary asset intents; they are product or mode labels.
- Do not claim PixelLab model provider internals where official docs are silent.
- Do not assume `pip install pixellab` has complete v2 SDK coverage without checking.

## Examples

| Request | Route |
|---|---|
| "Make a cute wizard with walk and idle animations for Godot." | MCP `create_character`, then `animate_character` for walk/idle, then `get_character`. |
| "Generate a 2D platformer mossy stone tileset." | MCP `create_sidescroller_tileset`; REST v2 `create-tileset-sidescroller` if writing code. |
| "Create a 512x512 title screen background." | REST v2 image/background route. |
| "Make UI buttons and health bars." | REST v2 `generate-ui-v2`. |
| "Convert this photo into pixel art." | REST v2 image-to-pixel-art route. |
| "Inpaint this masked area." | REST v2 inpaint route. |
| "Make an 8-direction treasure chest object." | MCP `create_8_direction_object`; REST v2 equivalent for custom integration. |
| "Make hex terrain tiles." | MCP `create_tiles_pro`, not top-down Wang tileset. |
