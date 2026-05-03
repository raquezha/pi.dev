# Antigravity OAuth/Login extension

Manual-only Google Antigravity support for Pi.

## Current status
This extension is **experimental on latest Pi**.

What currently works:
- OAuth login flow can be restored with `/login`
- Antigravity models can be registered and shown in model selection
- The extension now defaults to a repo-local provider identity: `antigravity-cli`
- A local proxy can be started for request inspection and request-shape experiments
- `/antigravity.doctor` can report the active provider/proxy wiring

What is still unstable:
- Latest Pi does not yet have a proven, reproducible Antigravity request path that returns real model responses from extension space alone
- Older Pi builds reportedly still work end-to-end with the same account, which points to a runtime/provider compatibility gap rather than an auth problem

## Version matrix
| Pi path | Status | Evidence |
| --- | --- | --- |
| Latest Pi (`0.72.1` observed during planning) | OAuth + model registration work; response path still under investigation | Local extension starts, now defaults to `antigravity-cli`, provider registers, proxy can run |
| Known-good older Pi | End-to-end responses reportedly worked with the old built-in provider path | Record the exact version during Phase 0 verification before choosing a long-term pin |

## Load the extension
```bash
ANTIGRAVITY_DEBUG=1 pi -e ./pi/extensions/antigravity-auth-login
```

Then select an `antigravity-cli/...` model and use `/login` if needed.

To compare against the legacy built-in-looking identity, override the provider id for one run:

```bash
ANTIGRAVITY_DEBUG=1 ANTIGRAVITY_PROVIDER_ID=google-gemini-cli pi -e ./pi/extensions/antigravity-auth-login
```

## Diagnostics
Use the doctor command after startup:

```text
/antigravity.doctor
```

With `ANTIGRAVITY_DEBUG=1`, sanitized runtime diagnostics are written to:

```text
~/.pi/agent/antigravity-proxy.log
```

The log is intentionally limited to routing metadata such as:
- provider id
- API type
- proxy base URL
- request path
- inferred model id
- request type
- upstream HTTP status

The log must **not** be used to capture tokens, refresh credentials, authorization headers, or full prompt bodies.

## Reproduction loop
1. Start Pi with the extension and `ANTIGRAVITY_DEBUG=1`
2. Run `/antigravity.doctor`
3. Authenticate with `/login` if needed
4. Select an `antigravity-cli/...` model
5. Send one minimal prompt
6. Inspect `~/.pi/agent/antigravity-proxy.log`
7. If needed, repeat once with `ANTIGRAVITY_PROVIDER_ID=google-gemini-cli` to compare logs against the legacy provider identity

## Exit criteria
Choose **latest-Pi extension path** only if all of the following are true:
- a selected Antigravity model returns a real response
- the same behavior survives a Pi restart and extension reload
- the docs in this repo match the observed behavior

Choose **pin a known-good older Pi** if any of the following remain true after the provider/proxy experiments:
- latest Pi bypasses the extension proxy
- latest Pi reaches the proxy but still never produces a stable response
- the required behavior depends on core functionality that cannot be recreated through repo-local extensions
