# Credentials

Read this for PixelLab token setup, token terminology, or reusing MCP auth for REST API calls.

PixelLab appears to use one account credential for public REST v2 and hosted MCP. Official docs call it an API token, bearer token, or secret depending on surface. Treat those as names for the same account API token/secret, not different token types.

Use the token as:

```text
Authorization: Bearer <PixelLab account API token>
```

Prefer one canonical local env var:

```text
PIXELLAB_API_TOKEN
```

Compatibility aliases are allowed only when already present in a user's environment, SDK, or existing MCP config:

- `PIXELLAB_API_KEY`
- `PIXELLAB_SECRET`

Do not tell users to create all three. Do not imply they are different tokens.

## MCP Reuse

If PixelLab MCP is already configured, reuse its token source when safe:

- If the MCP config uses an env var, such as `bearer_token_env_var = "PIXELLAB_API_TOKEN"` or `${env:PIXELLAB_API_TOKEN}`, REST code can read the same env var.
- If the MCP config uses a host secret reference, tell the user to configure REST/API code to use that same secret mechanism when the host supports it.
- If the MCP config contains a literal `Authorization: Bearer ...` value, do not extract, print, or copy it. Suggest moving it to env/secret config.

Never ask the user to paste the token into chat. Never use website/Supabase session tokens for REST or MCP.

Inspect only named config paths and redact secret-like values. Do not scan broad home/auth/config directories because tool output can leak secrets.

Fallback order:

1. User-scoped OS environment variable or MCP host secret/env config.
2. Hidden local prompt that writes user-scoped env/keychain config.
3. `.env.local` in a private, gitignored app directory.
4. Avoid project `.env`, committed MCP config, generated docs, shell history, chat transcript, and copied browser session tokens.

