# PixelLab Pip Developer Notes

## Codex Local Plugin Testing

Codex installs both remote and local plugins into its plugin cache. Editing files in this repository, such as `skills/pixellab-pip/SKILL.md`, does not live-update the active Codex skill. Refresh the local development install after repo edits, then open a fresh Codex thread so the new cached snapshot is loaded.

Use the Codex-only helper:

```powershell
.\dev-tools\manage-codex-plugin.ps1
```

The script resolves the repository path from its own location, so it can be launched from another working directory or by double-clicking the `.ps1` file. It pauses before exit so the result stays visible.

The menu offers:

- `Install <opposite mode>` - switch between `development local` and `production remote`.
- `Update <current mode>` - refresh the currently installed mode.
- `Uninstall <current mode>` - remove the installed plugin and marketplace entry.
- `Cancel` - exit without changes.

When no plugin is installed, the menu offers `Install development local`, `Install production remote`, `Uninstall pixellab-pip (not installed)`, and `Cancel`.

For `development local`, the script temporarily writes a Codex cachebuster version to `.codex-plugin/plugin.json`, installs from this repository, then restores the manifest. This creates a fresh cache path such as `0.2.0+codex.dev-YYYYMMDDHHMMSS` without permanently changing the repo version.

For `production remote`, the script installs from the GitHub marketplace source in `plugin.json`. Production updates run `codex plugin marketplace upgrade` before reinstalling because Codex does not currently provide a `codex plugin update` command.

To verify which build Codex is using, check the path shown when a skill is invoked or run:

```powershell
codex plugin list --json
codex debug prompt-input '@pixellab-pip bark off'
```

`development local` should show this repository as the source and a version containing `+codex.dev-`. `production remote` should show the GitHub marketplace source and the normal release version.
