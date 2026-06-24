# Setup Mode

Use this reference when the user asks natural-language setup questions such as installing PixelLab Pip, connecting PixelLab to an assistant, enabling MCP tools, using REST/API v2, fixing authentication, checking readiness, or deciding between MCP and API. This is a reference for the existing PixelLab Pip skill, not a separate skill.

The intended first-run command is one short word after the skill trigger:

```text
/pixellab-pip setup
@pixellab-pip setup
$pixellab-pip setup
```

Some apps expose text after a slash command as arguments, while others treat it as normal prompt text. Treat `setup` the same either way. Do not require flags, positional syntax, or app-specific argument features.

## Setup Intent

First classify what the user wants to set up:

- `mcp`: recommended default; PixelLab tools inside an AI assistant, IDE, desktop app, or MCP-compatible app.
- `api`: backup/advanced path; direct REST v2 usage from scripts, apps, SDKs, curl, or backend code.
- `both`: MCP first, plus REST/API only if the user is also writing direct code or automation.
- `unknown`: recommend MCP first unless the user clearly says they are writing their own code against the API.

Use user wording to infer intent:

- MCP signals: "agent", "assistant", "Claude", "Codex", "Cursor", "MCP", "tools", "desktop app", "connect PixelLab to my assistant".
- API signals: "REST", "API", "curl", "SDK", "Python", "JavaScript", "backend", "endpoint", "batch", "integration", "web app".
- Both signals: "set everything up", "agent and code", "MCP plus API", "use in my app and assistant".

## Readiness Diagnosis

Diagnose before changing anything. Keep checks narrow and relevant to the user's stated environment.

For MCP readiness, check:

- Whether PixelLab MCP tools are currently available in the agent. Match tool names by suffix if they are prefixed.
- Whether the user's assistant/editor is known and what settings screen or config file they want to use.
- Whether an MCP config was explicitly provided or the user asked you to inspect a specific file.
- Whether the assistant/editor can pass `PIXELLAB_SECRET` from an environment variable or secret setting.

For API readiness, check:

- Whether `PIXELLAB_SECRET` is present and non-empty without outputting, logging, measuring, or inspecting the value; only pass it directly to an approved no-credit auth check.
- Whether the user wants shell, Python, JavaScript/TypeScript, or another platform example.
- Whether network access to `https://api.pixellab.ai/v2` is available when a live check is requested.
- Whether any installed SDK is actually present before recommending SDK-specific methods.

Do not scan broad home, auth, shell history, keychain, credential, config, project, or repository directories. For credential-bearing config, inspect only exact paths the user named or explicitly approved after you explain why. Do not recursively search for token, secret, auth, or env var names. Non-secret readiness checks may inspect only the active workspace files needed for the stated setup task.

## Safe Credential Setup

PixelLab uses one account-level bearer token for public REST v2 and PixelLab MCP. The PixelLab UI may call it an API key, API token, secret, or token. For REST/MCP auth, call it a bearer token.

Tell the user to open `https://www.pixellab.ai/account` after signing in and copy the value labeled `Secret`, or follow PixelLab's MCP setup page at `https://www.pixellab.ai/mcp`.

Never ask the user to paste the bearer token into chat. Never print, echo, log, summarize, transform, validate, or copy a token value from chat or config output. If a token appears in chat or tool output, do not repeat it.

Preferred storage order:

1. User-scoped OS environment variable or assistant/editor secret settings using `PIXELLAB_SECRET`.
2. Hidden local prompt or app UI that writes user-scoped env/keychain/secret config.
3. A private `.pixellab` file, gitignored, containing only `PIXELLAB_SECRET`.

Avoid existing `.env*` files, committed MCP config, generated docs, shell history, chat transcripts, copied website session tokens, and literal `Authorization: Bearer ...` values in config files. Do not read existing `.env*` files unless the user names the exact file and explicitly approves inspection.

Use one canonical env var in new examples:

```text
PIXELLAB_SECRET
```

Use it for REST as:

```text
Authorization: Bearer <PIXELLAB_SECRET>
```

Do not introduce aliases such as `PIXELLAB_API_KEY`, `PIXELLAB_TOKEN`, or `YOUR_API_TOKEN` in new instructions. If official docs use another placeholder, explain that the same bearer token should be stored in `PIXELLAB_SECRET`.

## User-Facing Setup Output

For setup readiness output, keep wording friendly, action-oriented, agent-agnostic, and OS-agnostic by default. Prefer "Next step" language over long diagnostic inventories. Avoid jargon such as "host" in user-facing text; say "assistant", "editor", "app", or the named product instead.

- Tell the user to open `https://www.pixellab.ai/account` and copy the value labeled `Secret`.
- Recommend PixelLab's official MCP setup page first: `https://www.pixellab.ai/mcp`. Tell the user to pick their assistant/editor/app, copy the instructions shown there, replace `YOUR_SECRET` or `<PIXELLAB_SECRET>` with the actual Secret value, follow the app-specific instructions, then restart the app if needed.
- Explain that REST/API setup is only needed when they are writing their own code or MCP is not available.
- Use `<PIXELLAB_SECRET>` as the placeholder in prompts and config examples. Explain that it means the actual `Secret` value from the account page, made available locally as `PIXELLAB_SECRET`.
- Do not show Windows, macOS, Linux, shell, package-manager, SDK, or programming-language-specific setup commands unless the user named that OS/tool or asks for manual setup.
- If an OS-specific hidden-input example is needed, tailor it to the user's OS and explain that `<PIXELLAB_SECRET>` means the actual Secret from their PixelLab account page.

- For MCP examples, show:

```text
https://api.pixellab.ai/mcp
Authorization: Bearer <PIXELLAB_SECRET>
```

Then say: "Set up your assistant/editor/app so `<PIXELLAB_SECRET>` comes from a private `PIXELLAB_SECRET` setting. If the app has a secret settings screen, save the value there under `PIXELLAB_SECRET`. Do not paste the real Secret into shared config files."

## MCP Configuration Guidance

For MCP setup, recommend PixelLab's official MCP setup page first unless the user explicitly asks for manual setup: `https://www.pixellab.ai/mcp`. Do not assume a specific assistant, editor, terminal, shell, or operating system.

Good guidance:

- Tell the user to pick their assistant/editor/app on PixelLab's MCP page and follow the exact command or instructions shown there.
- If they need manual setup, use the app's MCP settings screen or documented MCP config file.
- Configure PixelLab MCP to read `PIXELLAB_SECRET` from the app environment or secret store.
- If the app supports a secret store, save the value under `PIXELLAB_SECRET` instead of using a literal token.
- If a config file already contains a literal bearer token, suggest moving it into env/secret config; do not extract or print it.
- After config changes, tell the user to restart or reload the assistant/editor when needed.

Before writing config:

- Explain the exact file or setting you intend to change.
- Show a token-free preview using placeholders or secret references only.
- Ask for confirmation.
- Write only after explicit approval.

If the user asks for a generic MCP snippet, provide a token-free template and note that app settings vary. Prefer the official PixelLab MCP setup page for app-specific details.

## API Configuration Guidance

For REST/API setup, first say this is the backup/advanced path for users writing their own code. Do not assume an OS, shell, SDK, or programming language; tailor examples only after the user names one or asks for one.

Safe examples may show:

- Using `PIXELLAB_SECRET` from the process environment without outputting or inspecting the value.
- Passing `Authorization: Bearer ...` from that environment value.
- A no-credit check against balance or an official lightweight endpoint when the user approves a live check.
- How MCP and API can reuse the same credential source.

Do not hard-code token literals. Do not generate commands that would echo the secret. Avoid commands that persist secrets in shell history. When platform-specific persistent env setup is needed, prefer app secret settings, documented secret stores, OS settings, or user-scoped environment configuration over project files.

## Prompt Before Writes

Any setup action that writes files, environment settings, MCP app config, shell profiles, private PixelLab-only env files, package files, or project scripts needs confirmation first.

Before asking, report:

- Target surface: MCP, API, or both. Recommend MCP first unless the user is writing direct API code.
- Exact destination: config file, app setting, env var, app file, or project file.
- Secret handling: token-free placeholder, `PIXELLAB_SECRET` env var, or app secret setting named `PIXELLAB_SECRET`.
- Reload step: whether a terminal, app, server, or assistant/editor must restart.

If the user only wants instructions, do not write anything.

## No-Credit Live Auth Check

Use live checks only when the user asks to verify readiness or when a setup flow would benefit from confirmation. Never spend credits during setup verification.

Preferred checks:

- MCP: use `get_balance` if available, because it verifies MCP auth without generating assets.
- REST/API: call `GET /balance` with `Authorization: Bearer <env value>` if the user approves a live API check.
- Tool availability: list or identify PixelLab MCP tools without making generation calls.

Before a live check:

- Confirm it should use the locally configured credential.
- State that the token value will not be printed.
- State that no generation or edit will be run.

After a live check:

- Report success/failure, surface checked, and whether credentials were found.
- If balance/usage is returned, summarize it without exposing raw auth headers or full response JSON.
- If failed, report the likely layer: missing env var, assistant/editor not reloaded, auth rejected, network failure, endpoint unavailable, or SDK/tool mismatch.

## What To Report

For setup help, report only what helps the user proceed:

- Detected intent: MCP, API, both, or unknown.
- Current readiness: ready, partially ready, not configured, blocked, or unknown.
- Credential location type: env var, app secret setting, literal config value found, or not found. Never report the credential value.
- Next safest step.
- Any write you propose, with destination and token-handling approach.
- Whether a restart/reload is needed.
- Whether a live auth check was no-credit and what it verified.

## What Not To Do

- Do not ask for, paste, print, echo, log, or quote the bearer token.
- Do not use website/Supabase/browser session tokens for REST or MCP.
- Do not scrape browser storage or session cookies.
- Do not call undocumented website endpoints as setup verification.
- Do not run credit-spending generation/edit endpoints during setup checks.
- Do not write MCP config, env files, shell profiles, package files, or project code without explicit confirmation.
- Do not scan broad credential/config directories.
- Do not claim SDK support, MCP tool availability, pricing, limits, or current endpoint behavior without checking when those facts matter.
- Do not require PixelLab Pip-specific assistant behavior from apps that only support generic MCP or REST.

## Agent- And OS-Agnostic Flow

Use this default flow for natural-language setup mode:

1. Identify whether the user wants MCP, API, or both. Recommend MCP first for normal assistant/editor use.
2. Diagnose current readiness using available tools and only user-approved/specific config paths.
3. Explain the safe credential model: one PixelLab bearer token stored as `PIXELLAB_SECRET` in the user environment or app secret settings.
4. Offer token-free setup steps for the user's app/platform only after identifying it, or route to PixelLab's official MCP setup page when it is unknown.
5. Ask before writing config or changing environment.
6. Run only no-credit readiness checks after approval.
7. Report outcome and the next concrete step.

If app-specific details are unknown, route the user to `https://www.pixellab.ai/mcp` first. Mention `https://api.pixellab.ai/v2/docs` only when they are writing direct API code.
