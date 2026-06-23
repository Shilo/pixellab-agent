# PixelLab Pip Docs

Last reviewed: 2026-06-23.

These docs explain the PixelLab surfaces, asset workflows, terminology, SDK boundaries, and auth rules that Pip needs in order to automate PixelLab correctly. They supplement the repository README; install, update, and plugin metadata stay there.

For exact current endpoint schemas, tool lists, model/mode availability, pricing, and authentication behavior, verify against the official PixelLab docs:

- [PixelLab.ai](https://www.pixellab.ai/)
- [PixelLab account page](https://www.pixellab.ai/account)
- [PixelLab REST v2 LLM guide](https://api.pixellab.ai/v2/llms.txt)
- [PixelLab REST v2 docs](https://api.pixellab.ai/v2/docs)
- [PixelLab REST v2 OpenAPI](https://api.pixellab.ai/v2/openapi.json)
- [PixelLab MCP docs](https://api.pixellab.ai/mcp/docs)
- [PixelLab MCP setup](https://www.pixellab.ai/mcp)
- [PixelLab GitHub organization](https://github.com/pixellab-code)

## Contents

- [PixelLab Surfaces And Services](pixellab/surfaces-and-services.md) - MCP, REST v2, website/editor, Aseprite, Pixelorama, SDK, and legacy v1 boundaries.
- [PixelLab Asset Routing](pixellab/asset-routing.md) - how common asset requests map to PixelLab tools, endpoints, and workflows.
- [PixelLab Terminology](pixellab/terminology.md) - public product labels, endpoint labels, and terms agents should not over-interpret.
- [PixelLab SDK Compatibility](pixellab/sdk-compatibility.md) - official SDK guidance and when to call REST v2 directly.
- [PixelLab Auth And Security](pixellab/auth-and-security.md) - bearer-token handling and automation boundaries.

## Publication Rules

These docs intentionally avoid:

- Copied credentials, session tokens, cookies, JWTs, or private account data.
- Instructions for automating undocumented website session endpoints.
- Local machine paths or user-specific filesystem details.
- Provider/internal model claims not documented in public PixelLab sources.
- Informal, mocking, or critical language about PixelLab.

PixelLab Pip can document caveats when they matter for correct implementation, but the tone should stay neutral and technical.
