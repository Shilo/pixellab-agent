# Usage Reporting

Read this before or after live PixelLab calls, especially credit-spending generation or async jobs.

After every live PixelLab call, report:

- Surface: MCP, REST v2, website/manual, Aseprite, or Pixelorama.
- Tool or endpoint.
- Mode/model label supplied by the agent, if any.
- Job, asset, or result IDs.
- Output paths or URLs.
- Async polling/status when relevant.
- Balance/credit delta when exposed.

Use `get_balance` or REST `GET /balance` before and after nontrivial generation when available. If only balance is available, report the delta. If neither per-call usage nor balance is exposed, say usage was not exposed. Label estimates as estimates.

