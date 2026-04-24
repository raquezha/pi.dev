---
name: pi-skill-creator
description: Create or improve skills specifically for the pi coding agent and the pi.dev repository. Use when the user wants to turn a workflow, source-of-truth repo, migration pattern, repeated project task, or external skill example into a pi-native skill. First gather the right context, classify the skill type, design the proper structure, and then generate the appropriate SKILL.md, references, scripts, assets, and supporting files.
---

# Pi Skill Creator

Create and refine skills that are tailored for **pi** and this **pi.dev** repository.

Do not jump straight into writing `SKILL.md`. First understand what kind of skill is needed, gather authoritative context, extract the repeatable workflow, and then generate the right skill package.

## What this skill should produce

A finished or improved skill under `pi/skills/<category>/<skill-name>/` that:

- follows the pi / Agent Skills format
- uses a valid lowercase hyphenated `name`
- keeps the `name` equal to the parent directory name
- has a strong `description` that clearly says **what the skill does** and **when to use it**
- includes extra files only when they add real value (`references/`, `scripts/`, `assets/`)
- fits pi.dev repository conventions and skill categories
- reflects real source-of-truth context instead of generic placeholder guidance

## Pi-native operating principles

Always optimize for pi.dev, not generic skill systems.

1. Read local patterns first: `pi/skills/README.md`, nearby skills in the same category, and relevant pi docs.
2. If the skill touches pi features, read the relevant pi docs before drafting instructions.
3. If the user points to an external skill or source repo, study it first and adapt it to pi instead of copying it literally.
4. Prefer the smallest useful skill structure, but do not force everything into one `SKILL.md` when references or examples would make the skill more reliable.
5. Never hardcode secrets. Reference environment variables only.
6. Update `pi/skills/README.md` when adding a new category or notable new skill.
7. After creating or updating a skill, remind the user they can run `./scripts/setup.sh` and `/reload` in pi.

## Skill classes

Before writing files, classify the requested skill. The structure should follow the job.

### 1. Helper skill
Small reusable behaviors or formatting guidance.

Typical output:
- `SKILL.md` only

### 2. Workflow skill
Step-by-step operational process.

Typical output:
- `SKILL.md`
- optional `references/` checklist or deeper guide

### 3. Migration or adoption skill
Moves a project from one state to another, such as XML to Compose, legacy CI to shared CI, or old config to a new standard.

Typical output:
- `SKILL.md`
- `references/` for decision trees, patterns, edge cases, validation
- optional `assets/` examples

### 4. Repo-specific operational skill
Teaches pi how to correctly use a source-of-truth repo, internal framework, component library, or org-standard workflow.

Typical output:
- `SKILL.md`
- `references/` that distill the source repo
- optional `scripts/` or `assets/` if they improve consistency

If unclear, ask enough questions to classify the skill before drafting.

## Context-first workflow

### 1. Capture the target skill
Clarify:

- what the skill should enable pi to do
- when it should trigger
- whether it creates, updates, migrates, reviews, or standardizes something
- whether it is tied to a specific repo, framework, platform, or internal standard
- what a successful outcome looks like

Reuse context already present in the conversation before asking repetitive questions.

### 2. Gather authoritative context
Arm yourself with the right source material before writing the skill.

Depending on the task, this may include:

- source-of-truth repos
- local repository files
- existing pi skills
- pi documentation
- examples and templates
- external skills or docs the user referenced

If web context is needed, use the `brave-search` skill.

### 3. Build a design brief
Before generating files, synthesize what you learned into a compact design brief. It should answer:

- what kind of skill this is
- who or what it applies to
- when it should trigger
- what inputs it inspects
- what outputs or changes it should produce
- what decisions it must make
- what edge cases matter
- what validation is needed
- what file structure the skill should use

Do not skip this step for complex skills.

### 4. Choose the right structure
Use the simplest structure that still preserves reliability.

Start here:

```text
pi/skills/<category>/<skill-name>/
└── SKILL.md
```

Add directories only when justified:

- `references/` for source-of-truth notes, decision trees, schemas, or edge cases
- `scripts/` for deterministic repeatable tasks
- `assets/` for templates, examples, or starter files

### 5. Write the skill package
Create instructions that are practical, pi-native, and actionable.

Preferred sections include:

- purpose
- when to use
- workflow
- decision rules
- validation steps
- repo-specific notes
- references to bundled files

Write for an agent. Be direct. Explain why steps matter when that improves reliability.

### 6. Adapt external material instead of copying it
When the user gives an external skill, article, or repo:

1. read it fully
2. extract the useful workflow and concepts
3. strip harness-specific behavior that does not fit pi
4. rewrite examples, paths, and tooling to match pi.dev
5. preserve the underlying idea, but make the result feel native to pi

### 7. Validate before finishing
Check that:

- the skill name is valid and matches the directory
- the description is explicit enough to trigger reliably
- the structure matches the skill class
- references and scripts are only included when useful
- instructions match pi, not another harness
- repo paths mentioned in the skill actually exist
- no security or secret-handling rules are violated

## Description guidance

A pi skill description should say both **what the skill does** and **when to use it**.

Strong descriptions usually:

- name the capability clearly
- include the user intents that should trigger it
- mention adjacent phrases the user might use
- describe the target repo, framework, or workflow when relevant

Avoid vague descriptions like:
- "helps with skills"
- "assists with development"

## Default scaffold template

Use this as a starting point when drafting a new skill:

````markdown
---
name: skill-name
description: Explain what the skill does and exactly when to use it.
---

# Skill Title

Brief summary of the capability.

## When to use

Use this skill when...

## Workflow

1. Inspect the current context
2. Gather required inputs or source material
3. Apply the skill-specific process
4. Write or modify files
5. Validate the results

## Notes

- Important repo-specific rule
- Important reliability rule

## References

- See [reference-name](references/reference-name.md) when deeper guidance is needed.
````

## Deliverable mindset

For simple skills, a strong `SKILL.md` may be enough.

For complex skills, the real deliverable is often a package:

- `SKILL.md` for the operational workflow
- `references/` for source-of-truth knowledge and decision logic
- `scripts/` for repeatable deterministic behavior
- `assets/` for examples or templates

Choose based on the problem, not habit.

## Pi-specific checklist

Before finishing, confirm:

- the skill lives under `pi/skills/`
- frontmatter is valid
- the directory name and `name` match exactly
- the description is explicit enough to trigger reliably
- extra files are referenced with relative paths
- `pi/skills/README.md` was updated if needed
- the user is reminded about `./scripts/setup.sh` and `/reload`

For a reusable review checklist and planning prompts, see [references/pi-skill-checklist.md](references/pi-skill-checklist.md).
