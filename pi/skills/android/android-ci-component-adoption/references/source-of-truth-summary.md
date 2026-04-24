# Source-of-truth summary

This skill is based on the `android-team/v3/devops/ci-component` repository.

## Canonical template choices

- `templates/android-mobile/template.yml` — Android mobile apps
- `templates/android-tv/template.yml` — Android TV apps
- `templates/kmp/template.yml` — KMP apps with Android support
- `templates/artifacts/*.yml` — library publishing, not the default path for app repos

## Core adoption rules

### 1. App module naming

Android app modules must use the `app-*` naming pattern.

Examples:
- `app-hapidee`
- `app-mytv`
- `app-mykmp`

`APP_NAME` is derived by stripping `app-`.

### 2. version.properties is mandatory

Required keys:

```properties
versionMajor=1
versionMinor=0
versionPatch=0
lastVersionCode=1
lastProductionVersionCode=1
```

This file is the canonical source of truth for version numbers.

### 3. Platform flavors

For Android mobile and KMP Android app flows, the CI expects:

- `review`
- `staging`
- `production`

Do not rename these if the repo is adopting the standard jobs.

### 4. Signing model

Release signing must use GitLab Secure Files:

- keystore binary
- `keystore.properties`

Gradle should read `STORE_FILE` from `keystore.properties` using a two-tier lookup:
- module-local file first
- repo-root fallback second

### 5. CI include style

Preferred for published Catalog usage:

```yaml
include:
  - component: gitlab.nweca.com/android-team/v3/devops/ci-component/android-mobile@~latest
    inputs:
      app_module: app-myapp
```

Safe fallback while testing unpublished changes or bypassing Catalog input validation:

```yaml
include:
  - project: 'android-team/v3/devops/ci-component'
    file: '/templates/android-mobile/template.yml'
    ref: 'main'
```

### 6. Inputs vs variables

- Use `inputs:` for published platform components
- Use `variables:` for runtime env vars and for local/project include patterns
- GitLab UI variables can silently override both `inputs:` and YAML `variables:`

Effective precedence:

```text
GitLab UI variables > job-level variables > pipeline variables > mapped inputs > spec defaults
```

### 7. Runner defaults

Canonical runner pool for Android/KMP work is:

- `RUNNER_TAG=universal-android`

Platform templates map `runner_tag` input into `RUNNER_TAG`.

### 8. Key GitLab variables

Common repo/runtime requirements:

- `GITLAB_PACKAGE_REGISTRY` — required for Gradle dependency resolution; Masked, not Protected
- `PACKAGE_NAME` — production base package name for flavor-aware Firebase/Play flows
- `GOOGLE_PLAY_SERVICE_ACCOUNT` — protected + masked for Play validation/deploy
- `FIREBASE_REVIEW_TESTERS`, `FIREBASE_STAGING_TESTERS`, `FIREBASE_PRODUCTION_TESTERS` — when Firebase distribution is used
- `AI_PROVIDER`, `AI_API_KEY`, `ENABLE_AI_RELEASE_NOTES` — optional release notes path

### 9. Git push behavior

Platform templates prefer `CI_JOB_TOKEN`.

Consumer repos must enable:
- **Settings → CI/CD → Job token permissions → Allow Git push requests**

### 10. Java toolchain rule

Default Android image is pinned around JDK 21. If the repo requests another Java toolchain, override `android_image` or `ANDROID_IMAGE` to a compatible image instead of relying on Foojay auto-download.

### 11. KMP specifics

KMP repos normally need:

- Android app module `app-*`
- shared module, usually `shared`
- optional `enable_ios` and `enable_desktop_macos`
- `mac-shell` prerequisites for iOS/Desktop paths

### 12. Android TV specifics

Android TV relies on Play tracks, not Firebase App Distribution as the main QA model. Do not force mobile-only Firebase assumptions onto TV repos.
