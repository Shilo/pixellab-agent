# Bark

Use this reference when the user runs a bark command or when a live PixelLab generation, edit, transform, conversion, background-removal, or animation job finishes successfully.

The intended command is one short word after the skill trigger:

```text
/pixellab-pip bark
@pixellab-pip bark
$pixellab-pip bark
```

Explicit state commands are also supported:

```text
/pixellab-pip bark on
/pixellab-pip bark off
```

Some apps expose text after a slash command as arguments, while others treat it as normal prompt text. Treat `bark`, `bark on`, and `bark off` the same either way.

## Config

Persist bark state in `config.json` next to this skill's `SKILL.md`:

```json
{
  "bark": true,
  "sound": "success"
}
```

No `config.json` means bark is enabled and the sound is `success`.

Read and write only this skill-local `config.json` for bark state. Do not scan broad config, home, shell, credential, or project directories.

If `config.json` exists but is invalid JSON, preserve no invalid fields, treat bark as enabled for the current command, and overwrite it with the valid shape above when the user explicitly runs `bark`, `bark on`, or `bark off`. Do not rewrite config during normal generation completion.

If `config.json` exists and contains extra fields, preserve them when changing `bark` or `sound` if the available file editing tools make that practical. If preserving extra fields is not practical, keep only `bark` and `sound`.

## Bark Commands

- `bark`: read the persisted state, toggle it, and write the new state.
- `bark on`: write `"bark": true`.
- `bark off`: write `"bark": false`.

Keep `sound` as `"success"` unless it already has another non-empty string value.

After a successful write, respond briefly with the new state:

- `Bark is on.`
- `Bark is off.`

If the write fails because the skill directory is read-only or filesystem writes are unavailable, say that bark could not be saved persistently. Do not claim the setting changed.

## When To Play

When bark is enabled, play the configured sound only after a live PixelLab generation, edit, transform, conversion, background-removal, or animation job or task finishes successfully.

Eligible completions:

- Successful PixelLab asset generation.
- Successful PixelLab image edit, transform, conversion, or background-removal job that produces a new generated result.
- Successful PixelLab animation or animation-edit job.
- Successful MCP managed asset task after the final asset/result existence and requested constraints are verified.
- Successful REST async job after polling reaches a final success state and the result is verified.

Do not bark for:

- Setup, auth, readiness, or no-credit balance checks.
- Status checks for jobs that were already completed earlier.
- Docs lookups, endpoint selection, prompt enhancement alone, or normal chat answers.
- Failed, canceled, rejected, timed-out, still-pending, or unknown-status jobs.
- Downloads, local file assembly, local previews, spritesheet/GIF assembly, or validation when no live PixelLab generation/edit/animation job finished in this turn.
- Manual website instructions unless the assistant directly observed a PixelLab generation finish in the visible website flow and the user had approved that action.

## Sound

Use `sound` as a logical sound id. For now, `success` means the current agent/app should use any available generic success completion sound.

Use an available host, app, or MCP notification primitive only if one is exposed in the current tools. Match tools by their visible names and schemas, such as sound, notification, completion, or play-notification tools that accept a sound or type value. Pass the logical sound id `success` when supported.

Do not run OS-specific shell commands to play audio. Do not install audio tools or MCP servers during generation reporting. If no sound-capable primitive is available, fail quietly and continue the normal PixelLab report.

Future bark audio assets may live under `assets/audio/` and may use `.wav`, `.wave`, or `.mp4`. Do not hard-code a file extension in the config.
