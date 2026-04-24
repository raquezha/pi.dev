# Pi Skill Checklist

Use this checklist when creating or reviewing a skill for `pi.dev`.

## Planning

- [ ] The requested skill type is clear: helper, workflow, migration/adoption, or repo-specific operational
- [ ] Enough authoritative context was gathered before drafting
- [ ] A short design brief exists for complex skills
- [ ] The final structure matches the complexity of the task
- [ ] The destination repo is explicit: `pi.dev` by default, project-local only if requested

## Discovery and naming

- [ ] The skill is placed under `pi/skills/<category>/<skill-name>/`
- [ ] The directory contains `SKILL.md`
- [ ] `name` is lowercase, hyphenated, and matches the directory name exactly
- [ ] `description` explains both capability and trigger conditions

## Content quality

- [ ] The body is concise and task-oriented
- [ ] Instructions are written for the agent
- [ ] The workflow is explicit enough to be repeatable
- [ ] Decision rules or validation steps are included when needed
- [ ] Large material is moved into `references/` when that improves reliability
- [ ] Repetitive deterministic work is moved into `scripts/` when useful
- [ ] Examples are compatible with pi and this repository

## pi.dev integration

- [ ] The category fits the existing repository layout
- [ ] `pi/skills/README.md` is updated when needed
- [ ] Paths and commands match this repo
- [ ] External repos were treated as source context unless the user requested a project-local skill
- [ ] The skill does not rely on non-pi-only commands unless clearly justified

## Security

- [ ] No secrets are embedded
- [ ] Any credentials are referenced via environment variables only
- [ ] The skill does not instruct the agent to inspect protected secret files

## Finish-up prompt

Before wrapping up, summarize:

1. what files were added or changed
2. what context was used to shape the skill
3. why the skill should trigger correctly
4. whether the skill was created in `pi.dev` or project-local and why
5. any follow-up validation the user should run
6. whether they should run `./scripts/setup.sh` and `/reload`
7. whether the user wants commit and push in `pi.dev`
