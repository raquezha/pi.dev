# Investigation patterns

Use the branch that best matches the problem.

## 1. Android / mobile
Use when there is a crash, ANR, device-only bug, startup issue, Gradle problem, or runtime regression.

Typical sources of evidence:
- crash report
- stack trace
- logcat
- adb state
- Gradle output
- repro steps
- affected build variant or flavor

Typical moves:
1. Confirm repro steps.
2. Check whether the issue is variant/device-specific.
3. Inspect logs and stack traces.
4. Narrow to module, screen, flow, or dependency.
5. Identify likely culprit and missing evidence.

## 2. CI/CD / infrastructure
Use when builds, jobs, deployments, or automation fail.

Typical sources of evidence:
- pipeline config
- job logs
- lint or validation output
- runner or environment assumptions
- changed scripts or templates

Typical moves:
1. Identify failing stage/job.
2. Compare expected vs actual job behavior.
3. Inspect config, includes, shared templates, and recent changes.
4. Narrow to command, environment, or orchestration issue.
5. Identify likely culprit and safest next validation step.

## 3. General codebase / debugging
Use when tests fail, regressions appear, behavior changed, or ownership is unclear.

Typical sources of evidence:
- failing tests
- stack traces
- git diff / recent changes
- file ownership and module boundaries
- naming or architecture inconsistencies

Typical moves:
1. Reproduce or confirm the failure.
2. Find the smallest failing surface.
3. Trace the path from input to output.
4. Narrow to one module, one seam, or one change.
5. Distinguish symptom from root cause.

## 4. Non-code / docs / workflow
Use when the problem is in process, documentation, organization, or shared understanding.

Typical sources of evidence:
- docs and notes
- file structure
- missing definitions
- inconsistent terminology
- stale or contradictory instructions

Typical moves:
1. Identify the friction clearly.
2. Inspect current docs/files/process artifacts.
3. Find contradictions, gaps, or ambiguity.
4. Narrow to the decision, artifact, or workflow step that is broken.
5. Recommend whether to frame, rewrite, reorganize, or plan.

## Investigation mindset
- Reproduce -> narrow -> explain.
- Avoid premature fixing.
- Prefer smallest convincing explanation.
- Call out when confidence is low.
