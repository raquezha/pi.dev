---
name: android-ci-component-adoption
description: Inspect, migrate, and validate Android mobile, Android TV, or KMP repositories so they adopt the android-team/v3/devops/ci-component GitLab CI component correctly. Use when onboarding a repo, auditing CI usage, repairing drift, or updating .gitlab-ci.yml, Gradle files, version.properties, flavors, signing, and GitLab setup expectations.
---

# Android CI Component Adoption

Use this skill to help Android mobile, Android TV, and KMP repositories adopt the shared GitLab CI component from `android-team/v3/devops/ci-component` correctly.

This is a repo-specific adoption and inspection skill. Do not jump straight into editing `.gitlab-ci.yml`. First inspect the repo, classify the platform, identify drift from the source-of-truth conventions, then apply only the changes needed.

## When to use

Use this skill when the user wants to:

- add the shared CI component to a repo
- migrate from custom or legacy GitLab CI to the shared templates
- inspect whether a repo is configured correctly for the component
- repair drift after template, variable, project-structure, or release-process changes
- update Android/KMP project structure so the CI templates can work
- fix problems around `version.properties`, `app-*` modules, flavors, signing, or GitLab variables
- understand whether a repo should use `android-mobile`, `android-tv`, or `kmp`

## Operating rules

- Treat `android-team/v3/devops/ci-component` as the source of truth.
- Re-read the relevant source docs or templates when the repo shape is ambiguous or the source-of-truth may have changed.
- Separate **repo changes** from **GitLab UI / Secure Files actions**.
- Never read or expose secrets. Do not open protected files such as real keystores, `.env`, or credentials.
- Prefer small, explicit migrations over broad speculative rewrites.
- If the repo is not clearly an app repo, verify whether artifact/toolbox templates are the better fit before changing app CI.

## First-pass response contract

Before editing, give the user a compact adoption assessment:

1. detected repo type
2. recommended template
3. main adoption gaps
4. whether the job is primarily:
   - audit only
   - partial migration
   - full migration
   - drift repair

Do not skip the inspection phase unless the user explicitly asks for a direct rewrite.

## Workflow

### 1. Classify the target repo

Inspect the repository before proposing changes.

Determine:
- Android mobile app
- Android TV app
- KMP app with Android module
- non-app/library repo

Use these signals:
- `.gitlab-ci.yml`
- `settings.gradle` / `settings.gradle.kts`
- app module names
- presence of `shared/`, `iosApp/`, desktop modules
- current CI include paths and variables
- Android-specific Gradle plugins and Play/Firebase configuration

### 2. Choose the correct template

Map the repo to one primary platform template:

- Android mobile → `android-mobile`
- Android TV → `android-tv`
- KMP app → `kmp`

Do not force Android mobile guidance onto Android TV or KMP when their constraints differ.

Use [references/migration-patterns.md](references/migration-patterns.md) for the baseline mapping and include strategy.

### 3. Audit the repo against the required conventions

Check the following before editing:

1. **Module naming**
   - main Android app module should be `app-*`
2. **Version file**
   - `version.properties` exists with all five required keys
3. **Gradle version injection**
   - build logic accepts `-PversionCode` and `-PversionName`
   - local fallback comes from `version.properties`
   - release builds fail fast when version info is missing
4. **Flavors**
   - Android mobile and KMP Android paths should support `review`, `staging`, `production`
5. **Signing**
   - Gradle uses two-tier `keystore.properties` lookup
   - `STORE_FILE` is resolved relative to the properties file location
6. **CI entrypoint**
   - `.gitlab-ci.yml` uses the right include strategy
7. **Runtime assumptions**
   - required variables and Secure Files are identified
8. **Override traps**
   - check for `inputs:` vs `variables:` vs GitLab UI variable conflicts
9. **Toolchain fit**
   - requested Java toolchain matches the selected Android image
10. **Platform-specific fit**
   - TV repos are not incorrectly treated as Firebase-first mobile apps
   - KMP iOS/Desktop paths are only enabled when repo and runner prerequisites exist

Use [references/adoption-checklist.md](references/adoption-checklist.md) as the audit baseline.

### 4. Choose the include style deliberately

Prefer `component:` plus `inputs:` when the published component is the intended path.

Use `project:` include temporarily when:
- Catalog publication is not available yet
- the user needs a direct branch or repo reference
- input validation in the Catalog would block a safe migration

When using platform components:
- `inputs:` keys are lowercase snake_case
- runtime variables are UPPERCASE

Remember that GitLab UI variables can silently override both mapped inputs and YAML variables.

### 5. Apply repo changes in the right order

When migration is needed, use this order:

1. fix app module naming and `settings.gradle*`
2. create or repair `version.properties`
3. patch Gradle version injection
4. patch signing lookup
5. add or repair flavors for Android mobile / KMP Android
6. update `.gitlab-ci.yml` include and inputs
7. document remaining GitLab UI / Secure Files actions

Do not claim the migration is complete if GitLab-side setup is still missing.

## Decision rules

### Android mobile

Expect:
- `app-*` module naming
- `review`, `staging`, `production` flavors
- Firebase distribution support
- Play Store release path
- `PACKAGE_NAME` as the production base package

### Android TV

Expect:
- `app-*` module naming
- Play-focused workflow
- no assumption that Firebase App Distribution mirrors Android mobile
- Play Publisher setup may be needed in Gradle

### KMP

Expect:
- Android app module using `app-*`
- shared module, usually `shared`
- optional iOS/Desktop paths only when repo structure and runner prerequisites exist
- Android flavor, versioning, and signing rules still apply on the Android app module

### Include and override behavior

If behavior looks wrong, inspect in this order:
1. GitLab UI variables
2. job-level `variables:`
3. pipeline-level `variables:`
4. `inputs:`
5. template defaults

High-risk silent overrides include:
- `APP_MODULE`
- `RUNNER_TAG`
- `PLAY_STORE_RELEASE_TRACK`
- `ENABLE_DRY_RUN`
- `ANDROID_IMAGE`

## Expected edits

Common files this skill may update:

- `.gitlab-ci.yml`
- `settings.gradle`
- `settings.gradle.kts`
- `version.properties`
- `app-*/build.gradle.kts`
- KMP Android app module build files
- project docs or onboarding notes when the user asks for them

## Validation

After editing, validate what can be validated locally:

- confirm `.gitlab-ci.yml` include structure and keys are coherent
- confirm `version.properties` has required keys
- confirm app module naming and Gradle includes are aligned
- confirm Gradle snippets are internally consistent
- check that the migration did not blur repo changes with GitLab-side configuration
- call out GitLab-side tasks still required:
  - CI/CD variables
  - Secure Files
  - job token push permission
  - runner/tag assumptions
  - cleanup of stale GitLab UI variables if suspected

If the repo contains YAML linting or CI validation commands, suggest running them.

## Output format

When reporting back, separate results into:

1. **What I inspected**
2. **What I changed**
3. **What still must be configured in GitLab**
4. **Risks or follow-up checks**

If no changes were made, still provide:
- recommended template
- adoption status
- exact blockers
- next safe step

## References

- [Design brief](references/design-brief.md)
- [Source-of-truth summary](references/source-of-truth-summary.md)
- [Adoption checklist](references/adoption-checklist.md)
- [Migration patterns](references/migration-patterns.md)
