# Setup

## Steps
Each step of `setup.sh`, in order:
1. asks the kind and the `gh-pages` question when the flags are missing (no terminal: `binary`, no `gh-pages`)
2. clones the `main` branch of the template into a temporary directory
3. removes the template only files (`setup.sh`, `readme/`, `.github/workflows/setup.yml`, `gh-pages/`)
4. adapts the copy to the kind: `TEMPLATE_KIND`, `PACKAGE_*` of the workflows, no `main.cpp` for a library
5. with `gh-pages`: keeps `install.sh` as `setup.sh`, the `docs.yml` workflow and the publication job
6. renames each file holding a placeholder, ex: `src/template/Core.cpp` -> `src/my_project/App.cpp`
7. replaces `template`, `TEMPLATE_`, `Core`, `CORE_H` and the repository name in every file
8. writes the `README.md`, the `CHANGELOG.md` (first entry `v1.0.0`) and `docs/` of the project
9. copies the result into the current directory
10. with `gh-pages`: creates the branch with the package repository seed and the docs
11. enables the [pre-commit hook](../README.md#pre-commit-hook), with `git init` when needed
12. with `--push`: commits (`chore: setup c++20 project from cpp_project_template`) and pushes

Without `gh-pages`, the packages stay as artifacts of the workflow runs.
The branch is created without touching the working tree.

## Arguments

| Argument | Effect |
| -------- | ------ |
| `<project_name>` | Replaces `template`: target, namespace, folders, executable, packages |
| `<core_name>` | Replaces `Core`: main class and its files |
| `--kind <kind>` | `binary` (default), `library` (`.a` / `.so` + headers) or `header-only` |
| `--gh-pages` / `--no-gh-pages` | Creates the `gh-pages` branch and keeps its workflows, or not |
| `--push` (`-push`) | Commits and pushes the result |
| `--force` (`-f`) | Overwrites the files already in the directory without asking |

| Environment variable | Effect |
| -------------------- | ------ |
| `REPO_URL` | Template repository to clone (default: this repository) |
| `BRANCH` | Branch to clone (default: `main`) |
| `TEMPLATE_DIR` | Local copy of the template, used instead of the clone (CI) |
| `GITHUB_REPO` | `owner/repo` of the project (default: the `origin` remote) |

`GITHUB_REPO` falls back to `TsukiNi22/<project_name>` without an `origin` remote.
It sets the URLs of the workflows, the docs and the package repository.

## Names

> [!WARNING]
> `<project_name>` and `<core_name>` are a C++ namespace and class: `[A-Za-z_][A-Za-z0-9_]*`.

> [!WARNING]
> `testing` and `Test` are refused (GoogleTest namespace), as the C++ keywords.

The packages use `<project_name>` in lower case with `-` instead of `_`, ex: `My_Project` -> `my-project`, `libmy-project`.

## Existing files
The files the template would overwrite (`README.md`, `LICENSE`, `.gitignore`...) are listed first.
The confirmation is asked in a terminal; `--force` skips it.

## Push

> [!IMPORTANT]
> `--push` needs a Git repository with an `origin` remote, checked before any change.

It runs `git add . && git commit && git push`.
A branch without upstream is pushed with `git push -u origin <branch>`, and a new `gh-pages` branch with `git push origin gh-pages`.
