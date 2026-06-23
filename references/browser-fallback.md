# Browser Fallback

Read this when the user asks to use the website/editor, or when public MCP/REST cannot cover the requested workflow.

Browser automation is a fallback for visible website workflows only.

Allowed after explicit user permission:

- Open PixelLab website/editor.
- Help fill visible forms.
- Guide downloads.
- Use website-only flows manually.

Ask again before:

- Login or session actions.
- Generation submission.
- Credit spending.
- Private asset downloads.
- Website edits or deletes.

Never scrape DevTools/session tokens, call root website/session endpoints, or treat website auth as REST/MCP auth.

