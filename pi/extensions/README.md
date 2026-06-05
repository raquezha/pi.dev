# Pi Extensions

Repository-local extensions live here. `./scripts/setup.sh` symlinks the default extensions into `~/.pi/agent/extensions/`.

## Included extensions
- `clean-repo` — git cleanup helper
- `nofooter` — UI footer styling
- `nosearch` — spawns isolated child pi sessions for Brave/Search work
- `gemini-api` — manual-only public Gemini API provider under the `gemini-api/...` namespace
- `noagy` — manual-only, independent native Antigravity provider under the `antigravity/...` namespace

## Gemini API extension
Load it manually when you want Gemini models:

```bash
pi -e ./pi/extensions/gemini-api
```

Set one of these in your shell rc (`~/.zshrc`, etc.) before starting pi:

```bash
export GEMINI_API_KEY='your_key_here'
# or
export GOOGLE_API_KEY='your_key_here'
```

Then pick a `gemini-api/...` model.

## Antigravity native extension

Load it manually when you want Antigravity models through Pi:

```bash
pi --antigravity
# or
pi -e ./pi/extensions/noagy
```

Then use `/login antigravity`, select an `antigravity/...` model, and run `/antigravity.doctor` for sanitized diagnostics.

This extension uses a native custom `streamSimple` transport and does not shell out to the official `agy` CLI.
