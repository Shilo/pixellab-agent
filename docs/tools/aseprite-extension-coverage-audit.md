# PixelLab Aseprite Extension Coverage Audit

Last investigated: 2026-06-25.

Source inspected: a locally installed PixelLab Aseprite extension package. This public note intentionally omits user-specific filesystem paths and account-specific values.

## Summary

PixelLab Pip should not use every Aseprite tool by calling the same route names. The official Aseprite extension is an editor integration that sends JSON over WebSocket to unversioned root routes under `http://api.pixellab.ai/`. Public agent/code surfaces are different:

- Hosted MCP tools for managed characters, objects, tilesets, tile variants, map objects, chat/sandbox helpers, projects, and balance.
- REST v2 endpoints under `https://api.pixellab.ai/v2` for code/API work.
- Aseprite/Pixelorama/website for editor-only workflows.

Pip should cover every Aseprite workflow by routing to the closest documented surface, not by treating Aseprite WebSocket route names as public REST or MCP contracts.

## Agent Automation Finding

The installed extension has enough internal structure to support a future agent bridge, but it does not currently expose a clean MCP or headless control surface.

Observed extension structure:

- `plugin-menu.lua` registers Aseprite menu commands. Most commands open PixelLab dialogs rather than executing fully parameterized headless generation.
- Individual `generate-*.lua` tools expose Lua model tables with `default_json`, `current_json`, `prepare_image`, `generate`, and sometimes `openDialog` or `onClose` functions.
- `create-json.lua` builds extension request JSON and injects runtime account metadata. Public docs must not copy account values from installed extension files.
- `websocket.lua` and `websocket-multi-layer.lua` send extension requests over WebSocket and place returned image data into Aseprite cels.
- `request-history.lua` records request JSON and generated preview images, which could be useful for status/result reporting.

Practical implication: an agent such as Codex or Claude can already automate PixelLab through official MCP/REST and then import files into Aseprite, but it cannot reliably drive the current Aseprite extension directly without either UI automation or an added bridge.

## Possible Aseprite MCP Bridge

The safest design is a companion local MCP server plus a small extension bridge, not making the Aseprite Lua extension itself host MCP.

Recommended shape:

```text
MCP-capable agent
  -> local Aseprite bridge MCP server
  -> localhost WebSocket or file-command queue
  -> Aseprite PixelLab extension bridge script
  -> existing generate-* model functions and websocket placement logic
```

Two bridge options are plausible:

- Local WebSocket bridge: the extension connects outward to a localhost service and receives commands such as `generate_image`, `animate_with_text`, `reduce_colors`, or `export_active_sprite`.
- File-command queue: the MCP server writes command JSON into an extension-owned queue folder; the extension polls on an Aseprite timer, executes approved commands, and writes result/status JSON back.

The file-command queue is simpler and more crash-tolerant. The WebSocket bridge is better for interactive status updates, cancellation, and live result streaming.

An MCP bridge should expose editor operations, not extension-internal PixelLab route names. Example tool concepts:

| MCP tool concept | Aseprite-side behavior |
|---|---|
| `list_pixellab_aseprite_tools` | Return supported extension tool names and required parameters from curated bridge metadata. |
| `open_pixellab_tool` | Open the existing PixelLab dialog for a named tool. |
| `run_pixellab_tool_preview` | Populate a model and ask the user to approve generation in Aseprite before spending credits. |
| `run_pixellab_tool` | Execute an approved generation through existing `generate-*` functions. |
| `get_active_sprite_context` | Return non-sensitive canvas metadata such as size, color mode, frame count, selected layer, and whether a sprite is open. |
| `export_active_sprite` | Export the active sprite or selected frames to a user-approved local path. |

Bridge guardrails:

- Do not expose or return the extension's stored secret, bearer token, session data, request auth fields, or full request JSON when it contains credentials.
- Require explicit user approval before credit-spending generation, destructive edits, downloads, deletes, or session/auth actions.
- Treat unversioned extension WebSocket routes as extension-internal editor routes, not public REST v2 endpoints.
- Prefer official PixelLab MCP/REST for pure agent asset generation when the user does not need the result placed into the live Aseprite document.
- Keep Aseprite-specific commands scoped to the active editor session and visible user workflow.

## Evidence

- `plugin-menu.lua` sets `_url = "http://api.pixellab.ai/"`.
- `websocket.lua` and `websocket-multi-layer.lua` connect directly to the supplied `_url` and send JSON over `WebSocket:sendText`.
- `create-json.lua` adds runtime metadata such as extension version, account credential fields, and tier into extension request bodies.
- `package.json` registers 50+ Lua scripts, including generation tools plus editor helpers such as quantize, unzoom, skeleton, place-image, request history, and update checks.
- Official REST v2 docs list public paths under `/v2`, such as `/generate-image-v2`, `/edit-images-v2`, `/inpaint-v3`, `/animate-with-text-v3`, `/create-tileset`, `/create-tiles-pro`, `/resize`, and `/remove-background`.
- Official MCP docs explicitly distinguish MCP, REST v2, web interfaces, editor plugins, and legacy v1.

## Public Coverage Map

| Aseprite workflow family | Aseprite route examples | Pip route |
|---|---|---|
| General image, Pixen, style reference, Flux-like image generation | `generate-image-new`, `generate-image-pixen`, `generate-pixelart-flux`, `generate-consistent-style`, `generate-flux-same-style`, `generate-style` | REST v2 image endpoints such as `generate-image-v2`, `create-image-pixen`, `create-image-pixflux`, `create-image-bitforge`, `generate-with-style-v2`; Aseprite for exact in-editor behavior. |
| UI generation | `generate-ui`, `generate-ui-template`, `generate-pixelart-flux` UI mode | REST v2 `generate-ui-v2`; website/editor for visual UI-library flows. |
| Image edit, inpaint, conversion, resize, remove background | `generate-edit`, `generate-edit-image-pro`, `generate-inpainting`, `generate-inpainting-v3`, `generate-image-to-pixelart`, `generate-image-to-pixelart-pro`, `generate-resize`, `remove-background` | REST v2 `edit-image`, `edit-images-v2`, `inpaint`, `inpaint-v3`, `image-to-pixelart`, `image-to-pixelart-pro`, `resize`, `remove-background`. |
| Multi-image edit | `generate-multi-edit` | REST v2 `edit-images-v2` when the task is a multi-source image edit; website/editor for visual experimental flows. |
| Animation, interpolation, skeleton, outfit transfer | `animate-with-text-v3`, `generate-animate-with-text`, `generate-animation`, `generate-edit-animation-pro`, `generate-interpolation-pro`, `generate-transfer-outfit-pro`, `estimate-skeleton` | REST v2 `animate-with-text*`, `animate-with-skeleton`, `estimate-skeleton`, `edit-animation-v2`, `interpolation-v2`, `transfer-outfit-v2`; MCP animation tools for managed characters/objects. |
| Rotation and directional assets | `generate-4-rotations`, `generate-8-rotations`, `generate-reference-to-8-rotations`, `generate-8-rotations-v3`, `generate-rotate-single` | REST v2 `rotate`, `generate-8-rotations-v2`, `generate-8-rotations-v3`; MCP character/object workflows when managed assets fit. No public REST v2 `generate-4-rotations` route was documented. |
| Characters and objects | `generate-spritesheet`, `generate-complete-character`, style/rotation/animation chains | MCP character/object tools by default; REST v2 character/object endpoints for exact API control. |
| Tiles, tilesets, isometric tiles | `generate-tiles`, `generate-tiles-style`, `generate-tileset`, `generate-tileset-sidescroller`, `generate-isometric-tile`, `generate-tiles-pro` | MCP tileset/tile tools by default; REST v2 `create-tileset`, `create-tileset-sidescroller`, `create-isometric-tile`, `create-tiles-pro`. |
| Map image, map extension, texture | `generate-map-flux`, `generate-inpainting-map`, `generate-inpainting-map-v2`, `generate-texture` | REST v2 image/background or tileset routes for generated assets; website/Aseprite for exact map-extension or texture editor workflows. No full public REST/MCP map CRUD or map-extension surface was documented. |
| Try-on and reshape | `generate-try-on`, `generate-reshape` | Website/editor for single-image try-on/reshape behavior; REST v2 `transfer-outfit-v2` only for animation-frame outfit transfer. No public REST v2/MCP reshape endpoint was documented. |
| Quantize/reduce colors, unzoom, pixel correction | `quantize-image`, `unzoom-pixelart`, `correct-pixelart` | Aseprite/Pixelorama editor workflow. Use local fallback only when clearly labeled as non-PixelLab. No public REST v2/MCP route was documented for these exact tools. |

## Gaps Fixed In Pip

- Multi-image routing now points to REST v2 `edit-images-v2` instead of saying no public route exists.
- Quantize and unzoom are now described as extension-only PixelLab editor workflows, not simply local tooling.
- Canny/sketch, pose/depth/style-reference, pixel correction, 4-rotation, map-extension, and texture workflows are explicitly labeled as either closest documented REST routes or Aseprite/editor-only behavior.

## Rule

If a PixelLab capability appears only as an Aseprite unversioned root WebSocket route, Pip must not expose it as a public REST/MCP endpoint. It should route to Aseprite/Pixelorama/website when the user wants that exact editor behavior, or choose the closest documented REST v2/MCP path when the user wants code/agent execution.

If a future Aseprite MCP bridge is added, document it as a local editor-control bridge. Do not describe it as PixelLab's public REST API, and do not include user-specific paths, credentials, or private account data in public documentation.
