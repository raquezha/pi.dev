antigravity extension for pi.dev

Purpose

This small extension restores the "antigravity" helper that was removed from the official pi-mono project in the v0.71.0 release (https://github.com/badlogic/pi-mono/releases/tag/v0.71.0). The upstream maintainers chose to remove the feature, and that broke internal tooling and quick prototypes that depended on it. This extension aims to be a compact, well-tested replacement that targets the same public API surface and works with pi-mono v0.71.0.

Why I built this (what I went through)

Short version: they removed it, so I built one.

Long version (the hell I went through):
- Discovery: I noticed multiple internal prototypes and a few automation scripts silently breaking after upgrading to pi-mono v0.71.0.
- Investigation: I dug into the upstream release notes and tags, and confirmed the antigravity helper had been intentionally removed in the 0.71.0 release.
- Attempts to recover: I tried several approaches before deciding to implement a repo-local replacement:
  - Rewinding to an earlier pi-mono version — this worked, but pinned projects to an old dependency and wasn't a long-term option.
  - Forking upstream pi-mono and reintroducing the helper — heavy-handed and would require long-term maintenance and coordination with upstream.
  - Implementing a small, well-scoped extension that restores the helper without touching pi-mono — chosen solution.
- Implementation pain points:
  - Reconstructing the exact public surface the original helper exposed (documentation was sparse).
  - Ensuring no private/internal APIs were relied on.
  - Adding tests and compatibility checks to avoid regressions.
  - Keeping the surface minimal so future upstream restores will be easy to reconcile.
- Outcome: a small extension that restores the necessary behavior and includes notes about why it exists and how to migrate off it if upstream changes again.

Compatibility & Target

- Target: pi-mono v0.71.0
- Backwards-compatible with earlier versions in most cases, but it was written specifically to address the removal in v0.71.0.

Design goals

- Minimal surface area: match the original helper's public API only — no scope creep.
- Test-first: include unit tests and a small integration check to validate behavior against expected outputs.
- Easy removal: annotate code and README so this replacement can be removed if upstream restores antigravity in a future release.

Usage

- Install or symlink this extension into your local pi agent extensions directory (see repo root README for setup.sh):

  ln -s $(pwd)/pi/extensions/antigravity ~/.pi/agent/extensions/antigravity

- Load in a session when you need antigravity:

  pi -e ~/.pi/agent/extensions/antigravity

Files

- This README.md — high-level motivation and usage notes.
- src/ — implementation files (if present).
- tests/ — unit & integration tests (if present).

Testing

- Unit tests verify the public API behavior.
- Run tests with your usual test runner (see project conventions). Keep tests small and focused.

Migration notes

- If upstream restores antigravity in a later pi-mono release:
  - Prefer the upstream implementation if it has the same API and is maintained.
  - Remove this extension and update consumers to the upstream one.
  - Keep a small migration stub if you need to support both (extension can detect upstream presence and no-op).

Suggested commit / PR message

- feat(extensions): add antigravity extension (target: pi-mono v0.71.0) — restore removed helper

Maintainer / Contact

- This was implemented by the pi.dev workspace owner. File issues or PRs in this repo if you find regressions or compatibility problems.

Notes

- This replacement intentionally keeps behavior small and focused. If you need a more featureful variant, open an issue to discuss scope and safety.
