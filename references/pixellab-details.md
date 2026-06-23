# PixelLab Details

Read this only when the main skill needs endpoint-specific inputs, paperdolling, tileset details, token setup, browser fallback, or usage reporting.

## Token Setup

- Use PixelLab account API tokens for REST v2 and hosted MCP.
- Prefer `PIXELLAB_API_TOKEN`; accept `PIXELLAB_API_KEY` when the host or existing examples use it.
- Never ask the user to paste a token into chat.
- If credentials are missing, tell the user to configure the token locally through env vars, MCP host secrets, or a local installer/setup command.
- Do not use website/Supabase session tokens for REST/MCP.
- Do not scan broad home/auth/config directories for tokens. Inspect only named config paths and redact secret-like values.

Fallback order:

1. User-scoped OS environment variable or MCP host secret/env config.
2. Hidden local prompt that writes user-scoped env/keychain config.
3. `.env.local` in a private, gitignored app directory.
4. Avoid project `.env`, committed MCP config, generated docs, shell history, chat transcript, and copied browser session tokens.

## Browser Fallback

Browser automation is a fallback for visible website workflows only.

Allowed after explicit user permission:

- Open PixelLab website/editor.
- Help fill visible forms.
- Guide downloads.
- Use website-only flows manually.

Ask again before login, generation submission, credit spending, private asset downloads, or website state changes.

Never scrape DevTools/session tokens, call root website/session endpoints, or treat website auth as REST/MCP auth.

## Paperdolling

Treat paperdolling as a workflow contract, not a separate PixelLab surface.

Ask or infer:

- Base character identity.
- Direction count.
- Sprite and canvas size.
- Animation list.
- Layers such as body, hair, outfit, armor, weapon, accessory, shadow, and VFX.
- Whether outputs must be isolated transparent layers or composited previews.

Preserve:

- Canvas size.
- Frame count.
- Frame order.
- Direction names/order.
- Origin/pivot.
- Transparency/background.
- Palette/style reference where consistency matters.

Route MCP-managed characters through character/state/animation tools. Use REST v2 raw animation, edit-animation, interpolation, and outfit-transfer routes only when exact file-level control matters. Warn that text-only paperdolling drifts without a base frame, seed, or reference.

## Tilesets

"Tiles" is ambiguous. If unclear, ask whether the user wants:

- Terrain/autotile tileset.
- Platformer/sidescroller tileset.
- Individual tile variants such as hex, octagon, square, or isometric.
- One isometric tile/block.
- Manual website Create Tileset Pro.

Capture tile size, view, terrain pair or tile list, transition description, base tile IDs, style/reference/palette images, seed, and target engine/export convention when relevant.

Do not equate website Create Tileset Pro/Gemini with public `create-tiles-pro`.

## Image Inputs

Image input names are endpoint-specific:

| Term | Typical role |
|---|---|
| `reference_images` | Subject guidance for general image generation. |
| `style_image` | Style, pixel-size, or style-transfer guidance depending on endpoint. |
| `style_images` | Multiple style references for style generation or tile variants. |
| `concept_image` | Design concept for UI or character Pro concept mode. |
| `reference_image` for character v3 | South-facing identity/reference to rotate. |
| `reference_image` for character Pro | Style reference, concept aid, or actual character to rotate depending on method. |
| `init_image` | Starting image to transform from. |
| `color_image` / `color_palette` | Palette or color guidance. |
| `first_frame` / `last_frame` | Animation frame guidance. |

Accept file paths and attachments. Ask when one file could be identity, style, concept, edit target, palette, first frame, or last frame. Check current endpoint schema before encoding or naming parameters.

## Usage Reporting

After every live PixelLab call, report:

- Surface: MCP, REST v2, website/manual, Aseprite, or Pixelorama.
- Tool or endpoint.
- Mode/model label supplied by the agent, if any.
- Job, asset, or result IDs.
- Output paths or URLs.
- Balance/credit delta when exposed.

Use `get_balance` or REST `GET /balance` before and after nontrivial generation when available. If only balance is available, report the delta. If neither per-call usage nor balance is exposed, say usage was not exposed. Label estimates as estimates.
