# Credentials

Read this for PixelLab bearer-token setup, PixelLab UI naming, or reusing MCP auth for REST API calls.

PixelLab uses one account-level bearer token for public REST v2 and PixelLab MCP. End-user setup should store that token in `PIXELLAB_SECRET`. PixelLab UI and examples may call the same value an API key, API token, or secret; when discussing REST/MCP authentication, use the technical term `bearer token`.

User-facing setup wording:

- Open `https://www.pixellab.ai/account` after signing in and copy the value labeled `Secret`.
- Store that Secret value locally as `PIXELLAB_SECRET`, preferably in the assistant/editor/app secret settings, an app secret store, or a user-level environment setting.
- If the user chooses Manual setup, open or link to `https://www.pixellab.ai/mcp`, tell them to pick their app there, and stop.
- The PixelLab API/account UI may label this value as an API key, API token, or secret.
- Do not paste the value into chat.
- Do not put the value in an assistant shell escape such as Claude Code `!` or Codex CLI `!`, or in a Codex app integrated terminal command that Codex can read.
- Prefer app/OS secret settings, environment-variable UI, secret stores, or hidden prompts over literal-token shell commands that can be saved in shell history.
- If the user wants a CLI option such as `setx`, `export`, PowerShell `$env:`, or `ENV=value command`, explain that the command itself is allowed in a normal external terminal, but the literal Secret in command text may be saved or exposed. Use placeholders in examples.

Use the bearer token as:

```text
Authorization: Bearer <PIXELLAB_SECRET>
```

Use one canonical local env var for new agent/API examples:

```text
PIXELLAB_SECRET
```

Do not create additional env var aliases. Official examples may say `YOUR_API_TOKEN` or `YOUR_SECRET`; put that same bearer token in `PIXELLAB_SECRET`.

In setup previews, `<PIXELLAB_SECRET>` means a private local secret reference. It does not mean the user should paste the real Secret into chat, a shared config file, or a generated doc.

## MCP Reuse

If PixelLab MCP is already configured, reuse its credential source when safe:

- If the MCP config uses `PIXELLAB_SECRET`, REST code can read the same env var.
- If the MCP config uses an app secret setting or secret store named `PIXELLAB_SECRET`, tell the user to configure REST/API code to use that same `PIXELLAB_SECRET` source when the app or runtime supports it.
- If the MCP config contains a literal `Authorization: Bearer ...` value, do not extract, print, or copy it. Suggest moving it to env/secret config.

Never ask the user to paste the bearer token into chat. Never print, echo, log, summarize, measure, transform, or validate token values. Never use website/Supabase session tokens for REST or MCP.

Never suggest `! setx ...`, `! export ...`, or similar assistant-shell commands that include a literal token. This includes Claude Code and Codex CLI `!` shell commands. Even when a command is executed by the user's local shell, the command text may still be visible to the assistant session, saved in transcripts/logs, visible in Codex-readable terminal output, or preserved in command history.

Do not describe `setx`, `export`, PowerShell `$env:`, or `ENV=value command` as inherently forbidden. The risk is the literal Secret appearing in command text. If users ask for CLI setup, show a placeholder-based command for a normal external terminal and explain the shell-history/process-history tradeoff. For the safest default, list secret UIs, secret stores, or hidden prompts first.

When checking MCP config files for credential setup, inspect only the specific config paths referenced by the user or approved after a token-free explanation. Do not scan broad home/auth/config directories, shell history, keychains, project trees, or existing `.env*` files because tool output can leak secrets.

Before writing environment settings, keychain/secret-store entries, MCP app config, private PixelLab-only env files, shell profiles, deployment settings, or project files, follow `references/setup.md`: explain the destination, show a token-free preview or secret reference, and get explicit approval.

Fallback order:

1. Assistant/editor/app secret settings, app secret store, or user-scoped OS environment variable named `PIXELLAB_SECRET`.
2. Hidden local prompt that writes user-scoped env/keychain config.
3. A private `.pixellab` file, gitignored, containing only `PIXELLAB_SECRET`, only if the user explicitly chooses that option.
4. Avoid existing `.env*` files, committed MCP config, generated docs, shell history, chat transcript, and copied browser session tokens. Do not read existing `.env*` files unless the user names the exact file and explicitly approves inspection.
