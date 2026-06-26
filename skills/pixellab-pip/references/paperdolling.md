# Paperdolling

Read this for layered characters, outfit variants, equipment swaps, or animation-consistent paperdoll workflows.

Treat paperdolling as a character-anchored edit workflow first, then a composition workflow. For a paperdoll "item", infer any visual entity that belongs on a character body part: hair, eyes, facial features, horns, accessories, clothing, armor, hats, held items, footwear, VFX, or similar wearable/attached details. Do not narrow "item" to standalone object/prop.

PixelLab can generate base sprites, edited states, outfit-transfer frames, masked inpaints, image edits, and standalone transparent objects. Public REST v2/MCP docs do not expose first-class layer creation, layer assignment, semantic layer extraction, or isolated changed-part outputs. The Aseprite extension, as a visible editor surface, exposes output modes such as `New layer with changes`; treat that as the preferred human/editor route for fitted paperdoll layers when the user is working in Aseprite.

Paperdoll rule: visible body/layer pixels must come from PixelLab or the user. Local tools may compose, align, package, import/export, mask, resize, crop, and verify layers, but must not draw or repaint them unless the user explicitly requests or approves a labeled non-PixelLab fallback.

Ask or infer:

- Base character identity.
- Direction count.
- Current character direction for each edit, such as south/down-facing, east/right-facing, north/up-facing, west/left-facing, or diagonal.
- Sprite and canvas size.
- Animation list.
- Layers such as body, hair, outfit, armor, weapon, accessory, shadow, and VFX.
- For every requested paperdoll item: item identity, intended body part, position, facing/rotation, attachment/occlusion rule, and whether it should appear in front of or behind the base body.
- Whether outputs must be isolated transparent layers or composited previews.
- Whether an existing composite may be edited lossily, or whether reusable isolated layers are required.

Preserve:

- Canvas size.
- Frame count.
- Frame order.
- Direction names/order.
- Origin/pivot.
- Transparency/background.
- Palette/style reference where consistency matters.

For reusable sets, confirm the base character and frame-grid contract before variants. Inspect outputs against the preservation list above before describing them as reusable layers.

## Route Contract

| Goal | Route | Warning |
|---|---|---|
| Fitted isolated paperdoll layer in Aseprite | Use the visible Aseprite extension `Edit image (Pro)` tool on the base character frame. Set output to `New layer with changes` when the user wants an isolated layer. Prompt with the character identity, current direction, item, target body part, exact placement, rotation/facing, scale, occlusion, and preservation rules. | This is an editor-surface workflow, not a stable headless API. Do not automate extension internals or call private operation URLs. The agent can guide the user or package verified exported layers afterward. |
| Fitted paperdoll edit from code/API | Use REST v2 `edit-images-v2` / Edit images (Pro) on the base image when a public API route is required. Use a detailed character-anchored edit prompt and same canvas size. If the API returns a composite, label it composite unless a separate changes-only layer is actually produced by the editor/export workflow. | Public REST docs describe image editing outputs, not Aseprite layer modes. Do not promise an isolated layer from REST unless verified in the returned file. |
| Masked fitted layer attempt | Use visible Aseprite `Edit image (Pro)` with selection/output `New layer with changes`, or REST `inpaint-v3` only when the user supplies or approves a mask for the body region to edit. | Inpainting returns an edited image, not semantic layer extraction. Aseprite changes-only output is the better layer path when available. |
| Standalone item sprite | Use MCP object tools or REST object/image routes only when the user asks for a separate reusable prop/accessory sprite that does not need to be fitted to the current body pose. | Do not use standalone object generation for fitted hair, clothes, hats, eyes, or accessories on an existing character; it commonly produces unregistered item sheets. |
| Dressed character preview/state | MCP `create_character_state`, REST character/edit routes, or visible Aseprite Edit image (Pro) with normal `New frame` / composite output. | Output is a character variant/composite, not a separate reusable layer unless generated with a changes-only layer mode and visually verified. |
| Outfit/equipment across animation frames | REST `transfer-outfit-v2` or `edit-animation-v2`; MCP character animation only when working with managed character assets. | Preserve frame count/order and label output as composited animation frames. |
| Existing composite to isolated layer | Require an explicit mask or editor cleanup plan; use REST inpaint/edit only as a fallback. | PixelLab does not document semantic layer extraction, character subtraction, or occluded item reconstruction. |
| Website Try on | Use only as visible/manual website assistance when appropriate. | It returns one composited image and is experimental; it is not a layer pipeline. |

## Aseprite Edit Image Pro Paperdoll Workflow

Use this workflow when the user wants a layerable paperdoll result and is working in Aseprite or accepts visible editor guidance:

1. Put the base character frame on its own layer, with the correct direction/frame active.
2. Choose PixelLab `Edit image (Pro)` rather than object/map-object generation.
3. Set the output method to `New layer with changes` for a new layer containing only changed pixels. Use `Modify current layer, only changes` only when the user explicitly wants to write changes into the active layer.
4. If available, use the current selection to constrain the edit region around the body part. For example, select the head for hair/hat, torso for shirt/coat, hands for gloves, feet for boots, face for eyes, or weapon hand for a held item.
5. Use a detailed prompt that describes the existing character and the item placement. Include:
   - Character identity and silhouette: species/body type, colors, scale, and style.
   - Direction: south/down-facing, east/right-facing, north/up-facing, west/left-facing, or diagonal.
   - Target item/entity: hair, hat, clothing, eyes, accessory, armor, held item, etc.
   - Body part and side: on top of head, behind head, around neck, torso, left hand, right hip, both feet, etc.
   - Position and rotation: centered, tilted left, wraps behind ears, follows body perspective, front-facing brim, side-facing sleeve, etc.
   - Preservation: keep all existing character pixels unchanged except where the item naturally occludes them; keep transparent background and exact canvas size.
6. After generation, inspect the layer by hiding/showing the base. The layer is successful only if it registers to the body in the same canvas and does not contain a duplicated/redrawn character.
7. If the layer contains full-body redraw, extra anatomy, or item-sheet parts, reject it and retry with tighter body-part selection, a stricter prompt, or a smaller edit region.

Example prompt:

```text
Edit this south-facing 92x92 chibi amphibian-dragon creature sprite. Add only a mint green leafy hair tuft as a paperdoll layer on the top/front of the head, following the head perspective and centered above the eyes. Keep the teal body, face, limbs, outline, pose, canvas size, and transparent background unchanged. Output only the changed hair pixels on the new layer; do not redraw the character, do not add a second head, and do not create a separate item sheet.
```

For clothing plus a hat:

```text
Edit this south-facing 92x92 chibi amphibian-dragon creature sprite. Add only a fitted adventurer outfit and small rounded explorer hat as paperdoll changes: hat on top of the head with front brim, scarf around the neck, short tunic over the torso, belt at the waist, gloves on both hands, and boots on both feet. Match the existing pixel-art outline, shading, palette weight, and camera angle. Keep the base creature pixels unchanged except where the clothing naturally covers the body. Keep exact canvas size and transparent background. Output only the changed clothing and hat pixels on the new layer; do not redraw the creature and do not generate loose item parts.
```

`inpaint-v3` requires `description`, `inpainting_image`, and `mask_image`; white mask areas are generated/replaced and black areas are preserved. Treat its output as a whole edited image, not a layer. `context_image` and `bounding_box` are deprecated in current OpenAPI.

`edit-images-v2` supports `edit_with_text` and `edit_with_reference` for 1-16 images depending on size. It can help keep related edits consistent, but public REST output should be treated as an edited image/composite unless a separate changes-only layer is verified from an editor workflow.

`edit-animation-v2` and `transfer-outfit-v2` operate on 2-16 frames and return edited/composited frames, not equipment/body layers.

If layer fidelity matters and the user is in Aseprite, prefer the visible editor `Edit image (Pro)` plus `New layer with changes` route over generating standalone objects. Create and save each layer separately through PixelLab or user-supplied source files before compositing in Aseprite, Pixelorama, or local tooling.

Route MCP-managed characters through character/state/animation tools. Use REST v2 raw animation, edit-animation, interpolation, and outfit-transfer routes only when exact file-level control matters. Warn that text-only paperdolling drifts without a base frame, seed, or reference.
