# /investigate

Use this prompt to perform a focused investigation on a repository, issue, or problem statement. The agent should:

- Summarize the context briefly (1-3 sentences).
- Identify key files, commands, or components to inspect.
- Propose a short checklist of steps to reproduce or validate the issue.
- List likely root causes (3-5) with confidence levels (low/med/high).
- Suggest the next concrete action (single step) the human should take.

Template:

```
Context:

1) Files to inspect:
- path/to/file1
- path/to/file2

2) Reproduction steps:
- step 1
- step 2

3) Likely root causes:
- Cause A (confidence: high)
- Cause B (confidence: medium)

4) Next action:
- Run: command or open file
```

Notes:
- Keep the output concise and action-oriented.
- Prefer commands humans can run locally; do not attempt to read protected secrets.
