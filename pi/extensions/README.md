# Pi Extensions

Repository-local extensions live here. `./scripts/setup.sh` symlinks the default extensions into `~/.pi/agent/extensions/`.

## Included extensions
- `clean-repo` — git cleanup helper
- `powerline-footer` — UI footer styling
- `gemini-api` — manual-only public Gemini API provider under the `gemini-api/...` namespace

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
