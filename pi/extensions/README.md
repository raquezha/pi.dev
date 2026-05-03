# Pi Extensions

Repository-local extensions live here. `./scripts/setup.sh` symlinks the default extensions into `~/.pi/agent/extensions/`.

## Included extensions
- `clean-repo` — git cleanup helper
- `powerline-footer` — UI footer styling
- `gemini-api` — manual-only public Gemini API provider under the `gemini-api/...` namespace
- `antigravity-auth-login` — manual-only, experimental Antigravity OAuth/login provider under the `antigravity-cli/...` namespace

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
ANTIGRAVITY_DEBUG=1 pi -e ./pi/extensions/antigravity-auth-login
```

Then pick an `antigravity-cli/...` model, use `/login` as needed, and run `/antigravity.doctor` to confirm the provider/transport wiring.

The extension now uses a direct custom-provider `streamSimple` transport instead of a local proxy, and a minimal `gemini-3-flash` print-mode request is verified on latest Pi.

Status note: this extension is still experimental on latest Pi. See [`./antigravity-auth-login/README.md`](./antigravity-auth-login/README.md) for the version matrix, diagnostics flow, and the go/no-go criteria for "extension path works" vs "pin an older Pi version".
