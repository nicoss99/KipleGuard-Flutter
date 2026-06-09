# Git Workflow Guide

Conventions for branching, commits, and pull requests on KipleGuard Flutter.

## Branching

| Branch | Purpose |
|--------|---------|
| `main` / `master` | Production-ready code |
| `feature/<name>` | New features |
| `fix/<name>` | Bug fixes |
| `chore/<name>` | Tooling, docs, deps |

Keep branches short-lived; rebase or merge from main regularly.

## Commit messages

Follow recent project style — short imperative summary:

```text
fix verify PIN API issue
implement API for verify PIN, search booking, booking category in filter list
fix data is not cleared when reinstall the app
integrate new API
```

Guidelines:

- Start with verb: `fix`, `add`, `implement`, `update`, `remove`
- One logical change per commit when possible
- Reference ticket/issue ID if your team uses one (e.g. `KG-123: fix booking search`)

## Pull requests

1. Push feature branch to remote
2. Open PR against `main`
3. PR description should include:
   - **Summary** — what and why
   - **Test plan** — checklist of manual/automated verification
4. Require at least one review before merge
5. Ensure CI / local `dart analyze` and `flutter test` pass

Use `gh pr create` if GitHub CLI is available.

## Do not commit

| Item | Reason |
|------|--------|
| `.env`, credentials | Secrets |
| `*.jks`, `key.properties` | Signing keys |
| `build/`, `.dart_tool/` | Generated artifacts |
| IDE personal settings | Use shared `.vscode/launch.json` only |
| Large binaries without need | Prefer LFS or external storage |

`.gitignore` should cover these; verify before first commit on a new machine.

## Code review focus

Aligned with `.cursor/rules/flutter-riverpod-fast-ui.mdc`:

- Feature code under `lib/page/<feature>/`
- No HTTP from widgets; use repositories
- No hardcoded colors/fonts — use theme
- Navigation via go_router only
- Providers at top level, not inside widget classes
- Hand-written files ~100 lines where practical

## Release tagging

After release approval:

```bash
git tag -a v1.0.1 -m "Release 1.0.1"
git push origin v1.0.1
```

Tag matches `pubspec.yaml` version name.

## Documentation updates

When changing API paths or architecture:

- Update `lib/core/guard_api_paths.dart` (source of truth)
- Update [03_API_DOCUMENTATION.md](03_API_DOCUMENTATION.md)
- Regenerate Word docs if team distributes `.docx` copies

## Related documents

- [06_RELEASE_CHECKLIST.md](06_RELEASE_CHECKLIST.md)
- [09_TESTING_GUIDE.md](09_TESTING_GUIDE.md)
