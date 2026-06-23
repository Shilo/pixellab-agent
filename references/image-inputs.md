# Image Inputs

Read this when the user supplies attachments or file paths, or when an endpoint has `reference`, `style`, `concept`, `init`, `color`, or frame image parameters.

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

