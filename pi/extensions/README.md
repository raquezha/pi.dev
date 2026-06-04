# Pi Extensions

Repository-local extensions live here. `./scripts/setup.sh` symlinks the default extensions into `~/.pi/agent/extensions/`.

## Included extensions
- `clean-repo` — git cleanup helper
- `powerline-footer` — UI footer styling
- `nosearch` — spawns isolated child pi sessions for Brave/Search work
- `gemini-api` — manual-only public Gemini API provider under the `gemini-api/...` namespace
- `noantigravity` — manual-only, experimental Antigravity OAuth/login provider under the `antigravity-cli/...` namespace

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

### Antigravity OAuth/login extension
Load it manually when you want the old Antigravity login flow back for investigation:

```bash
pi --antigravity
# or
ANTIGRAVITY_DEBUG=1 pi -e ./pi/extensions/noantigravity
```

Then pick an `antigravity-cli/...` model, use `/login antigravity-cli` as needed, and run `/antigravity.doctor` to confirm the provider/transport wiring.

If token exchange says `client_secret is missing`, add `ANTIGRAVITY_CLIENT_SECRET` to your shell or `~/.pi-secrets/.env`.

The extension now uses a direct custom-provider `streamSimple` transport instead of a local proxy, and a minimal `gemini-3-flash` print-mode request is verified on latest Pi.

Status note: this extension is still experimental on latest Pi. See [`./noantigravity/README.md`](./noantigravity/README.md) for the version matrix, diagnostics flow, and the go/no-go criteria for "extension path works" vs "pin an older Pi version".
