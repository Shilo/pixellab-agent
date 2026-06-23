# PixelLab Agent

Agent-agnostic skill for helping AI assistants choose the right PixelLab surface: MCP, REST v2 API, website/editor workflows, Aseprite, Pixelorama, or legacy v1.

Use it when an agent needs to create, edit, animate, or troubleshoot PixelLab assets such as characters, objects, tilesets, tiles, maps, UI, backgrounds, image edits, and animations.

## What It Does

- Routes plain-language asset requests to the best PixelLab tool or endpoint.
- Separates official public REST/MCP surfaces from undocumented website/session endpoints.
- Explains confusing PixelLab terms such as `Pro`, `v3`, `new`, `create tiles`, and `create tileset`.
- Tells agents when to refresh official PixelLab docs before giving exact endpoint, schema, SDK, auth, or model/mode claims.

## Files

- `SKILL.md` - the portable Agent Skills file.

No platform-specific plugin wrapper is required for the first version.

## Recommended Use

Install or point your agent at this folder, then invoke it as `/pixellab-agent` if your agent supports slash commands.

The skill is intentionally small: it is a routing brain, not a PixelLab SDK.
