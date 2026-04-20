---
name: android-gradle
description: Build, test, and manage Android projects using Gradle. Use for running builds, executing tests, checking dependencies, and managing version catalogs.
---

# Android Gradle Skill

This skill helps automate Android build tasks.

## Requirements

- `gradle` or `./gradlew` must be available in the project root.

## Usage

### Run a Build
```bash
./gradlew assembleDebug
```

### Run Unit Tests
```bash
./gradlew test
```

### Run Lint
```bash
./gradlew lint
```

### List Dependencies
```bash
./gradlew app:dependencies
```

### Update Dependencies
Use the agent to modify `build.gradle.kts` or `libs.versions.toml`.

## Common Tasks

- **Clean and Build**: `./gradlew clean assembleDebug`
- **Install Debug APK**: `./gradlew installDebug`
- **Check Dependency Updates**: `./gradlew dependencyUpdates` (requires `com.github.ben-manes.versions` plugin)
