# Migration patterns

Use these patterns when converting a consumer repo to the shared CI component.

## 1. Platform template selection

| Repo shape | Recommended template | Notes |
|---|---|---|
| Android app, phone/tablet | `android-mobile` | expects Android app module `app-*`, flavor-aware review/staging/production flow |
| Android TV app | `android-tv` | Play-track-centric flow; do not assume mobile Firebase distribution |
| KMP app with Android application module | `kmp` | Android path is primary; iOS/Desktop only if repo and runner prerequisites exist |
| Library repo | artifact/toolbox templates | not the main target of this skill unless user explicitly wants library adoption |

## 2. Include strategy

### Prefer published component usage

```yaml
include:
  - component: gitlab.nweca.com/android-team/v3/devops/ci-component/android-mobile@~latest
    inputs:
      app_module: app-myapp
```

Use this when the Catalog-published component is available and the repo should follow the stable public interface.

### Use project include as a migration fallback

```yaml
include:
  - project: 'android-team/v3/devops/ci-component'
    file: '/templates/android-mobile/template.yml'
    ref: 'main'
```

Use this when:
- testing unreleased template changes
- bypassing Catalog input validation during transition
- matching a branch or repo ref intentionally

## 3. version.properties baseline

Create or normalize:

```properties
versionMajor=1
versionMinor=0
versionPatch=0
lastVersionCode=1
lastProductionVersionCode=1
```

If values already exist, preserve the repo's semantic history unless the user explicitly wants a reset.

## 4. Android/KMP version injection pattern

Consumer Gradle should prefer CI-injected values first, then fall back to `version.properties`, and fail fast for release builds when version metadata is missing.

Targets to inspect:
- `defaultConfig.versionCode`
- `defaultConfig.versionName`
- direct reads from legacy custom files or ad-hoc env vars

## 5. Signing pattern

Preferred lookup pattern:
- check module-local `keystore.properties`
- then repo-root `keystore.properties`
- resolve `STORE_FILE` relative to the chosen properties file

Do not migrate repos toward raw secret env vars for signing.

## 6. Flavor pattern for Android mobile and KMP Android

Standard expected flavors:
- `review`
- `staging`
- `production`

Migration tasks may include:
- renaming `dev` or `qa` flows to `review` only if the team wants full alignment with the shared component
- adding missing `applicationIdSuffix` values for non-production variants
- ensuring task names like `assembleReviewRelease` and `bundleStagingRelease` can exist

## 7. KMP-specific adoption decisions

Before enabling KMP extras, verify:
- Android app module is `app-*`
- shared module name is correct
- `iosApp` or equivalent exists before enabling iOS
- mac-shell/Xcode prerequisites are real before enabling iOS/Desktop in CI

If those prerequisites are absent, keep the KMP adoption focused on the Android path first.

## 8. GitLab-side actions that remain manual

Do not treat these as repo code changes. Call them out separately:
- CI/CD variables
- Secure Files uploads
- Job token push permission
- inherited GitLab UI variable cleanup when overrides are suspected
- runner availability and tag assumptions

## 9. High-risk drift indicators

Escalate these explicitly in your report:
- app module still named `app`
- stale top-level `variables:` overriding desired `inputs:`
- GitLab UI variable likely overriding `ENABLE_DRY_RUN`, `APP_MODULE`, or `ANDROID_IMAGE`
- repo requests Java toolchain incompatible with default Android image
- KMP repo trying to enable iOS/Desktop without mac-shell prerequisites
