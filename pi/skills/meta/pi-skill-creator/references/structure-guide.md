# Structure Guide

Choose the smallest structure that still makes the skill reliable.

## Start simple

```text
~/Developer/pi.dev/pi/skills/<category>/<skill-name>/
└── SKILL.md
```

## Add `references/` when

- the skill needs source-of-truth summaries
- the skill needs schemas, decision trees, or edge cases
- the skill spans multiple variants or subdomains
- `SKILL.md` is getting too long or too branchy

## Add `scripts/` when

- the work is deterministic and repeated
- validation or scaffolding is mechanical
- the same helper logic would otherwise be regenerated repeatedly

## Add `assets/` when

- examples or templates materially improve reliability
- the skill benefits from canonical sample inputs or outputs

## Do not overbuild

Only add files when they improve clarity, reuse, or reliability.

## Practical target

- keep `SKILL.md` focused and operational
- move detailed material into `references/`
- prefer one-level-deep references from `SKILL.md`
