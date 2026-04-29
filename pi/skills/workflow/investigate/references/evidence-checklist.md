# Evidence checklist

Use this checklist to keep investigation grounded.

## Always try to capture
- exact symptom
- where it appears
- when it started
- affected users/system/scope
- repro steps if known
- error output or observable failure
- recent changes if relevant

## Distinguish clearly
- **Facts**: directly observed from files, logs, commands, tests, or user-provided evidence
- **Hypotheses**: plausible explanations not yet proven
- **Unknowns**: missing information blocking confidence

## Confidence guide
- **High**: multiple evidence points point to the same culprit
- **Medium**: likely culprit identified, but not yet fully verified
- **Low**: only partial evidence, multiple plausible causes remain

## Stop conditions
Stop investigating and recommend the next step when:
- the likely culprit is clear enough to describe
- open questions are known and bounded
- a `PROBLEM.md` can now be written without major guessing

Do not stop early just because a plausible explanation exists.
