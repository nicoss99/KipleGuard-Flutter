# KipleGuard Flutter — Documentation Index

Professional handover documentation for the KipleGuard guard mobile app (Flutter + Riverpod).

## Documents

| # | Topic | Markdown | Word |
|---|--------|----------|------|
| — | **Index (this page)** | [README.md](README.md) | [docx/00_DOCUMENTATION_INDEX.docx](docx/00_DOCUMENTATION_INDEX.docx) |
| 1 | Setup Guide | [01_SETUP_GUIDE.md](01_SETUP_GUIDE.md) | [docx/01_SETUP_GUIDE.docx](docx/01_SETUP_GUIDE.docx) |
| 2 | Architecture | [02_ARCHITECTURE.md](02_ARCHITECTURE.md) | [docx/02_ARCHITECTURE.docx](docx/02_ARCHITECTURE.docx) |
| 3 | API Documentation | [03_API_DOCUMENTATION.md](03_API_DOCUMENTATION.md) | [docx/03_API_DOCUMENTATION.docx](docx/03_API_DOCUMENTATION.docx) |
| 4 | Environment / Flavor Guide | [04_ENVIRONMENT_FLAVOR_GUIDE.md](04_ENVIRONMENT_FLAVOR_GUIDE.md) | [docx/04_ENVIRONMENT_FLAVOR_GUIDE.docx](docx/04_ENVIRONMENT_FLAVOR_GUIDE.docx) |
| 5 | Feature Documentation | [05_FEATURE_DOCUMENTATION.md](05_FEATURE_DOCUMENTATION.md) | [docx/05_FEATURE_DOCUMENTATION.docx](docx/05_FEATURE_DOCUMENTATION.docx) |
| 6 | Release Checklist | [06_RELEASE_CHECKLIST.md](06_RELEASE_CHECKLIST.md) | [docx/06_RELEASE_CHECKLIST.docx](docx/06_RELEASE_CHECKLIST.docx) |
| 7 | Play Store Deployment | [07_PLAY_STORE_DEPLOYMENT.md](07_PLAY_STORE_DEPLOYMENT.md) | [docx/07_PLAY_STORE_DEPLOYMENT.docx](docx/07_PLAY_STORE_DEPLOYMENT.docx) |
| 8 | Git Workflow | [08_GIT_WORKFLOW_GUIDE.md](08_GIT_WORKFLOW_GUIDE.md) | [docx/08_GIT_WORKFLOW_GUIDE.docx](docx/08_GIT_WORKFLOW_GUIDE.docx) |
| 9 | Testing Guide | [09_TESTING_GUIDE.md](09_TESTING_GUIDE.md) | [docx/09_TESTING_GUIDE.docx](docx/09_TESTING_GUIDE.docx) |

## Source of truth in code

When documentation and code disagree, prefer the code:

| Area | Authoritative file(s) |
|------|------------------------|
| API paths | `lib/core/guard_api_paths.dart` |
| Base URLs & keys | `lib/core/app_config.dart` (override via `--dart-define`) |
| Flavors & entrypoints | `lib/main_dev.dart`, `lib/main_prod.dart`, `android/app/build.gradle.kts` |
| Routes | `lib/router/app_route.dart` |
| Architecture rules | `.cursor/rules/flutter-riverpod-fast-ui.mdc` |

## Legacy note

Build commands previously documented in [BUILD_APK.md](BUILD_APK.md) are now consolidated in [04_ENVIRONMENT_FLAVOR_GUIDE.md](04_ENVIRONMENT_FLAVOR_GUIDE.md).
