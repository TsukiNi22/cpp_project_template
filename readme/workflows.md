# Workflows

## Template

| Workflow | Runs on | Does |
| -------- | ------- | ---- |
| `CI - Setup` | each push to `main` | runs `setup.sh` for each kind (`--gh-pages`) and once for Windows (`--no-gh-pages`) |
| `Lint (CI)` | each push to `main` | `shellcheck`, `actionlint`, `xstyle` (refuses a `major` issue) |

`CI - Setup` checks the result (no placeholder left, generated files, `gh-pages` content), then builds, tests and packages it.

## Generated project

| Workflow | Runs on | Does |
| -------- | ------- | ---- |
| `Dispatch (CI/CD)` | each push to `main`, each `v*` tag | picks the jobs from the ref and the commit message |
| `Lint (CI)` | each push to `main` | `shellcheck`, `actionlint`, `xstyle`; a missing tool is a warning |
| `Unit Tests (CI)` | Dispatch, always first | Linux: Debug then AddressSanitizer; Windows: under `wine` |
| `Build (CI)` | Dispatch, without package build | builds the project and checks its outputs |
| `Build - Packages (CI/CD)` | Dispatch, a pre-release or a release | builds, checks and (with `gh-pages`) signs and publishes the packages |
| `Release - GitHub (CD)` | Dispatch, a tag, after the packages | GitHub release from the `CHANGELOG.md`, with the packages attached |
| `Docs - Pages (CD)` | a push changing `docs/` (`gh-pages` only) | copies `docs/` to `https://<owner>.github.io/<repo>/` |
| `Sync Packages (CD)` | a manual push on `gh-pages` | rebuilds the metadata and signatures of the package repository |

`Dispatch (CI/CD)` ignores the pushes changing only `*.md`, `*.txt` or `docs/`.
A commit with `[ignore]` skips the whole CI.

The package repository keeps `fedora/44/x86_64`, `debian/`, `arch/x86_64` and the 5 last `-pre` versions.
`Build - Packages (CI/CD)` refuses a tag whose version is not the one of `project(... VERSION X.Y.Z)`.

## Runner, images and secrets

| Need | Value |
| ---- | ----- |
| Runner | repository variable `RUNNER`: `gh variable set RUNNER --body <runner>` |
| Images | `ghcr.io/tsukini22/` `ci`, `unit-tests`, `mingw64-ci`, `mingw64-unit-tests`, `package`, `git` |
| Publication secrets | `GPG_PRIVATE_KEY` (base64), `GPG_KEY_ID`, `GPG_PASSPHRASE` |
| GitHub Pages | on the `gh-pages` branch, root folder |

```bash
gh api -X POST repos/<owner>/<repo>/pages -f 'source[branch]=gh-pages' -f 'source[path]=/'   # enable GitHub Pages
```

## Pre-release (channel `unstable`)
- a tag `vX.Y.Z-<suffix>` (ex: `v1.0.1-pre`): `-pre` packages and a GitHub pre-release
- or a commit with `[build]`: `-pre` packages only

The pre-release notes are its `## [vX.Y.Z-<suffix>]` section of the `CHANGELOG.md`, else the `## [pre-release]` one.

## Release (channel `stable`)
- a tag `vX.Y.Z` only: stable packages and the GitHub release

Its `## vX.Y.Z - date` section must exist in the `CHANGELOG.md`.

## Downstream notification
A commit with `[release]`, or a package publication, triggers the `notify-downstream` job of `dispatch.yml`.
The job is commented: an example of `repository_dispatch` to another repository, like libutils -> docker-image.
