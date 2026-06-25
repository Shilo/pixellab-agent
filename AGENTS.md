# Repository Guidelines

## Project Structure & Module Organization

PixelLab Pip is an agent plugin/skill repository. The canonical runtime contract is `skills/pixellab-pip/SKILL.md`; supporting guidance lives in `skills/pixellab-pip/references/`. Bundled local assets, such as the bark helper and sound, are in `skills/pixellab-pip/assets/`.

Root manifests target different agent surfaces: `plugin.json`, `.codex-plugin/plugin.json`, `.claude-plugin/`, `.cursor-plugin/`, `.github/plugin/`, `gemini-extension.json`, and `GEMINI.md`. Human-facing documentation lives in `README.md` and `docs/`. Development helpers are in `dev-tools/`.

## Build, Test, and Development Commands

- `.\dev-tools\manage-codex-plugin.ps1` refreshes a local or production Codex plugin install for manual testing.
- `codex plugin list --json` verifies which cached plugin build Codex is using.
- `codex debug prompt-input '@pixellab-pip bark off'` checks that the installed skill can be invoked.
- `git diff --check` catches trailing whitespace and patch formatting mistakes.

There is no app build step. Release packaging is handled by `.github/workflows/release-skill.yml`, which bumps manifest versions and zips `skills/pixellab-pip/`.

## Coding Style & Naming Conventions

Use Markdown for skill and docs content, with concise headings and task-oriented language. Keep file names lowercase with hyphens, such as `image-input-roles.md`. JSON manifests use two-space indentation and synchronized `MAJOR.MINOR.PATCH` versions. PowerShell scripts should use strict mode, explicit errors, and repository-relative path resolution as shown in `dev-tools/manage-codex-plugin.ps1`.

## Testing Guidelines

Before opening a PR, validate changed Markdown links and examples by reading the affected workflow end to end. For skill behavior changes, reinstall locally with the dev helper and test at least one representative invocation. For manifest changes, confirm every agent-specific manifest still points to `skills/pixellab-pip/SKILL.md`.

## Commit & Pull Request Guidelines

History uses Conventional Commit style, for example `docs(aseprite): add aseprite-mcp documentation` or `feat(aseprite-cli): enhance safety guidelines`. Prefer `docs(scope): ...`, `feat(scope): ...`, or `fix(scope): ...` with a specific scope.

PRs should include a short summary, files or workflows changed, validation performed, and screenshots or terminal excerpts only when they clarify plugin behavior. Link related issues when available.

## Security & Configuration Tips

Do not commit user-local runtime config such as `skills/pixellab-pip/pixellab-pip.json`. Never ask users to paste bearer tokens into chat, print token values, or automate undocumented internal PixelLab endpoints. Prefer documented MCP and REST v2 surfaces.
