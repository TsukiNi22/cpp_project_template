# cpp_project_template

<p align="center">
  <img alt="CI - Setup" src="https://github.com/TsukiNi22/cpp_project_template/actions/workflows/setup.yml/badge.svg">
  <img alt="Lint" src="https://github.com/TsukiNi22/cpp_project_template/actions/workflows/lint.yml/badge.svg">
  <img alt="Last commit" src="https://img.shields.io/github/last-commit/TsukiNi22/cpp_project_template">
  <img alt="License" src="https://img.shields.io/github/license/TsukiNi22/cpp_project_template">
</p>

C++20 project template with CMake, libutils, GoogleTest, packages and CI/CD.
`setup.sh` renames it to your project and adapts it to its kind.

### Table of Contents
 - [Features](#features)
 - [Dependencies](#dependencies)
 - [Quick Setup](#quick-setup)
 - [Generated project](#generated-project)
 - [Packages](#packages)
 - [Usage](#usage)
 - [Pre-commit hook](#pre-commit-hook)
 - [Workflows/Release](#workflowsrelease)
 - [License](#license)

## Features
- **Kinds:** binary, static or shared library, header-only
- **Build:** `clang++`, ccache, `Debug` / `Asan` / `Optimized` modes, Windows (MinGW-w64)
- **libutils:** `ArgParser`, verbose levels, exception codes generated from JSON
- **Tests:** GoogleTest, run under AddressSanitizer in the CI
- **Packages:** RPM / DEB / Arch of every variant, `mingw64-*` for Windows
- **CI/CD:** tests, packages, GitHub release, signed package repository, docs

## Dependencies

> [!CAUTION]
> This project's license does not apply to the content of the dependencies used by `cpp_project_template`.

| Name + Link | Status | Last Update |
| ----------- | ------ | ----------- |
| [libutils](https://github.com/TsukiNi22/libutils) | ![CD - Dispatch](https://github.com/TsukiNi22/libutils/actions/workflows/dispatch.yml/badge.svg) | ![](https://img.shields.io/github/last-commit/TsukiNi22/libutils) |

Build requirements (of a generated project):

| Name | Version | Fedora (`dnf`) | Debian/Ubuntu (`apt`) | Arch (`pacman`) |
| ---- | ------- | -------------- | --------------------- | --------------- |
| `clang++` / `cmake` | C++20 / `>= 3.20` | `clang cmake` | `clang cmake` | `clang cmake` |
| `python3` | `>= 3.8` | `python3` | `python3` | `python` |
| `libutils` | `>= 4.1.0` (Arch: `>= 4.2.0`) | `libutils` | `libutils` | `libutils` |
| GoogleTest (tests only) | any | `gtest-devel` | `libgtest-dev` | `gtest` |
| MinGW-w64 (Windows only) | GCC `>= 13` | `mingw64-gcc-c++ mingw64-libutils` | `g++-mingw-w64-x86-64` + MinGW libutils | - |
| Package tools (packages only) | any | `rpm-build dpkg bsdtar` | `rpm dpkg-dev libarchive-tools` | `rpm-tools dpkg libarchive` |
| `ccache` **[OPTIONAL]** | any | `ccache` | `ccache` | `ccache` |

> [!TIP]
> libutils packages and source install: [libutils README](https://github.com/TsukiNi22/libutils#packages).

## Quick Setup
> Setup into the current directory

> [!WARNING]
> `<project_name>` and `<core_name>` must be C++ identifiers, ex: `my_project`, not `my-project`.

The script:
1. clones the template into a temporary directory
2. renames `template` / `Core` and adapts the copy to the kind
3. writes the `README.md`, `CHANGELOG.md` and `docs/`, then copies the result here

```bash
curl -fsSL https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> --kind binary --gh-pages
```

or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> --kind binary --gh-pages
```

| Argument | Effect |
| -------- | ------ |
| `--kind <kind>` | `binary` (default), `library` or `header-only` |
| `--gh-pages` | Package repository and docs branch |
| `--push` | Commits and pushes the result |

Every step, argument and variable: [`readme/setup.md`](readme/setup.md).

## Generated project

| Path | Content |
| ---- | ------- |
| `CMakeLists.txt` | Options, libutils, exceptions, release targets, CPack |
| `src/<project_name>/`, `include/<project_name>/` | `main.cpp`, the `<core_name>` class |
| `cmake/` | Toolchain, packaging, exception codes |
| `tests/` | GoogleTest unit tests |
| `docs/` | HTML documentation and project graph |
| `.github/workflows/` | [Workflows](#workflowsrelease) |

Every file and the CMake options: [`readme/project.md`](readme/project.md).

## Packages

> [!NOTE]
> `<package>-pre` is the pre-release: a stable package of the same version or newer replaces it.

`<name>` is the project name in lower case with `-` instead of `_`.

| File Name | Content |
| --------- | ------- |
| `<name>` / `lib<name>` | Default packages (`-op`, `-dev`) |
| `<name>-op` / `-db` / `-as` | Executable: optimized / debug / asan |
| `lib<name>-op` / `-db` / `-as` | Library: optimized / debug / asan |
| `lib<name>-dev` | Headers and CMake configuration |
| `mingw64-<name>*` | Windows packages, no `-as` |

Conditions, conflicts and Windows sysroot: [`readme/packages.md`](readme/packages.md).

## Usage

> [!WARNING]
> The template does not compile as is (`template` is a C++ keyword): run `setup.sh` first.

```bash
make                            # configure & build into build/ (executable at the root)
make debug / asan / optimized   # build in this mode
make tests                      # build (Debug) and run the unit tests
make release / package          # every variant / their RPM, DEB, Arch packages
sudo make install               # install the current build
make re / fclean                # full rebuild / remove build/
./<project_name> --help         # generated help (libutils ArgParser)
./<project_name> -v debug       # verbose: none, basic, advanced, debug
```

| Mode | Package suffix | Options |
| ---- | -------------- | ------- |
| `Debug` | `-db` | `-g -ggdb3` |
| `Asan` | `-as` | `-fsanitize=address -fno-omit-frame-pointer -g -ggdb3` (Linux only) |
| `Optimized` | `-op` | `-O3 -ffast-math -funroll-loops -fno-plt -pipe -DNDEBUG` |

> [!IMPORTANT]
> Add each new `.cpp` to `SRC` or `SRC_SHARED` in the `CMakeLists.txt`.

CMake targets, Windows build and portable code: [`readme/usage.md`](readme/usage.md).

## Pre-commit hook
`.githooks/pre-commit` checks the committed code with [xstyle](https://github.com/TsukiNi22/ai-utils).
In a generated project, it checks the staged lines only and refuses `major` issues.

```bash
git config core.hooksPath .githooks   # enable it (done by setup.sh)
git commit --no-verify                # skip it once (or XSTYLE_HOOK=0 git commit)
xstyle --fix --staged                 # fix what can be, then git add -u
```

> [!NOTE]
> Without `xstyle`, the hook only warns. Thresholds: `SCOPE`, `FAIL_ON`, `WARN_ON` at its top.

## Workflows/Release
### Workflows of the template
- `CI - Setup`: runs `setup.sh` for every kind, then builds, tests and packages
- `Lint (CI)`: `shellcheck`, `actionlint` and `xstyle` (also in a generated project)

### Workflows of a generated project
- `Dispatch (CI/CD)`: on each push to `main` or a `v*` tag, picks the jobs
- `Unit Tests (CI)`, `Build - Packages (CI/CD)`, `Release - GitHub (CD)`: tests, packages, release
- `Docs - Pages (CD)`: publishes `docs/` on `gh-pages`

> [!IMPORTANT]
> Requires the repository variable `RUNNER`, and the `GPG_*` secrets to publish.

Every workflow, image and secret: [`readme/workflows.md`](readme/workflows.md).

### Pre-Release (unstable)
- a tag `vX.Y.Z-<suffix>` (ex: `v1.0.1-pre`), or a commit with `[build]`

### Release (stable)
- a tag `vX.Y.Z` only, matching `project(... VERSION X.Y.Z)` and a `CHANGELOG.md` section

### Downstream notification
- a commit with `[release]`, for the commented `notify-downstream` job

## License
[MIT](LICENSE)
