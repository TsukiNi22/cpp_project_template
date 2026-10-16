# cpp_project_template

A ready-to-use C++20 project template: CMake, `clang++`, ccache, [libutils](https://github.com/TsukiNi22/libutils), exception headers generated from JSON, GoogleTest, Linux and Windows (MinGW-w64) builds, RPM / DEB packages with the libutils naming and the libutils workflows (dispatch, unit tests, packages, GitHub release, `gh-pages` repository and documentation).
The `setup.sh` script downloads it, renames the placeholders (`template` and `Core`) to your project name and core class name, adapts it to the project kind (binary, library, header-only), writes the README / CHANGELOG / documentation, optionally creates the `gh-pages` branch, and can commit/push the result.

### Table of Contents
 - [Dependencies](#dependencies)
 - [Quick Setup](#quick-setup)
 - [Generated project](#generated-project)
 - [Packages](#packages)
 - [Usage](#usage)
 - [Workflows/Release](#workflowsrelease)

## Dependencies

> [!CAUTION]
> This project's license does not apply to the content of the dependencies used by the template.

| Name + Link | Status | Last Update |
| ----------- | ------ | ----------- |
| [libutils](https://github.com/TsukiNi22/libutils) | ![CD - Dispatch](https://github.com/TsukiNi22/libutils/actions/workflows/dispatch.yml/badge.svg) | ![](https://img.shields.io/github/last-commit/TsukiNi22/libutils) |

Build requirements:

| Name | Version | Fedora (`dnf`) | Debian/Ubuntu (`apt`) |
| ---- | ------- | -------------- | --------------------- |
| `clang++` / `cmake` | C++20 / `>= 3.20` | `clang cmake` | `clang cmake` |
| `python3` | `>= 3.8` | `python3` | `python3` |
| `libutils` | `4.x` (`>= 4.1.0`) | `libutils` | `libutils` |
| GoogleTest (tests only) | any | `gtest-devel` | `libgtest-dev` |
| MinGW-w64 (Windows only) | GCC `>= 13` | `mingw64-gcc-c++ mingw64-libutils` | `g++-mingw-w64-x86-64` + libutils built for MinGW |
| `rpm-build`, `dpkg` (packages only) | any | `rpm-build dpkg` | `rpm dpkg-dev` |
| `ccache` **[OPTIONAL]** | any | `ccache` | `ccache` |

> [!TIP]
> libutils packages (Linux `libutils*`, Windows `mingw64-libutils*`) and source install: see the [libutils README](https://github.com/TsukiNi22/libutils#packages).

## Quick Setup

> Setup into the current directory

> [!IMPORTANT]
> With `--push`, the script must be run from inside an existing Git repository with a configured remote: it finishes with `git add . && git commit && git push` (and `git push origin gh-pages` when the branch is created).

> [!WARNING]
> `<project_name>` and `<core_name>` are used as C++ namespace and class name: they must be valid C++ identifiers (`[A-Za-z_][A-Za-z0-9_]*`), ex: `my_project`, not `my-project`. `testing` / `Test` are refused (GoogleTest namespace).

1. Clones the latest version of the template (`main` branch) into a temporary directory
2. Asks the project kind and the `gh-pages` question in the terminal when they are not given as flags (defaults: `binary`, no `gh-pages`, also without a terminal)
3. Removes the template only files (`setup.sh`, `.github/workflows/setup.yml`, `gh-pages/`) and adapts the copy to the kind (`TEMPLATE_KIND` of the CMake, `PACKAGE_*` of the workflows, no `main.cpp` for a library, no `src/` for a header-only library)
4. Renames every file or directory containing a placeholder (ex: `src/template/Core.cpp` -> `src/my_project/App.cpp`) and replaces every placeholder inside the sources, headers, CMake files, workflows, scripts, `.gitignore` and the `Doxyfile` (`template`, `TEMPLATE_`, `Core`, `CORE_H`, the repository `TsukiNi22/<project_name>` from the `origin` remote or `GITHUB_REPO`)
5. Writes the `README.md` (dependencies, packages, setup, usage, workflows of the project), the `CHANGELOG.md` (first entry `v1.0.0`: kind, date, repository; the template repository has no changelog of its own) and the documentation `docs/` (technical page placeholder, project graph pointing at the new repository)
6. With `gh-pages`: keeps the package repository setup script as `setup.sh`, the `docs.yml` workflow and the publication job of `build-packages.yml`, and creates the `gh-pages` branch (never touching the working tree) with the packages repository seed (`<project_name>.repo`, `RPM-GPG-KEY-tsukini`, `Sync Packages (CD)` workflow), the documentation (`docs/`) and the root `index.html` redirecting to it. Without: no publication, the packages stay as artifacts of the workflow runs
7. With `--push`: commits and pushes the result (`chore: setup c++20 project from cpp_project_template`)

```bash
wget -qO- https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> --kind binary --gh-pages --push
```

or with `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> --kind binary --gh-pages --push
```

| Argument | Effect |
| -------- | ------ |
| `<project_name>` | Replaces `template` (target, namespace, `include/`/`src/` folders, executable, packages) |
| `<core_name>` | Replaces `Core` (main class and its files) |
| `--kind <kind>` | Project kind: `binary` (default), `library` (`.a` / `.so` + headers) or `header-only` (asked in the terminal when missing) |
| `--gh-pages` / `--no-gh-pages` | Create (or not) the `gh-pages` branch and keep its workflows (asked in the terminal when missing, `no` without a terminal) |
| `--push` (`-push`) | Commits and pushes the result (skipped by default) |

| Environment variable | Effect |
| -------------------- | ------ |
| `REPO_URL` | Template repository to clone (default: `https://github.com/TsukiNi22/cpp_project_template.git`) |
| `BRANCH` | Branch to clone (default: `main`) |
| `TEMPLATE_DIR` | Local copy of the template used instead of the clone (used by the CI) |
| `GITHUB_REPO` | `owner/repo` of the new project (default: the `origin` remote, else `TsukiNi22/<project_name>`): workflows, docs, package repository URL |

## Generated project

| Path | Content |
| ---- | ------- |
| `CMakeLists.txt` | Options at the top (kind, package content), libutils, exception header generation, `release` / `install_release` / `package_release` targets, CPack |
| `cmake/toolchain/mingw-w64.cmake` | Windows (x86_64) cross compilation toolchain: `cmake -S . -B build-windows -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/mingw-w64.cmake` |
| `cmake/package/` | `Config.cmake.in` (`find_package(<project_name>)`, checks the installed variant), `CPackProjectConfig.cmake` (MinGW sysroot prefix of the Windows packages) |
| `cmake/config/exceptions/*.json`, `cmake/scripts/` | Project exception codes (`utils::exception::ExternalCode`) and their generator (`generate_exception_header.py`, `const.py`), `check_files.sh` |
| `src/<project_name>/`, `include/<project_name>/` | `main.cpp` (entry, exception handling), `<Core>-init.cpp` (libutils `ArgParser`, `--verbose`), `<Core>.cpp` (`run`), the public header |
| `tests/` | GoogleTest unit tests (`-DBUILD_TESTS=ON`, `unit_tests` at the root, GTest fetched from the sources when cross compiling) |
| `docs/` | HTML documentation: `index.html` (technical page, placeholder "coming soon"), `graph.html` (interactive project graph, refreshed from the repository), `logo.svg` |
| `.github/workflows/` | `dispatch.yml`, `unit-tests.yml`, `build.yml`, `build-packages.yml`, `release.yml`, `docs.yml` (see [Workflows](#workflowsrelease)) |
| `setup.sh` (gh-pages only) | Package repository setup of the project (mirror + GPG key + install, `--pre`, `--windows`, `--no-install`, `--no-sudo`), from `install.sh` of the template |
| `README.md`, `CHANGELOG.md` (both written by `setup.sh`), `LICENSE` (MIT), `Makefile`, `Doxyfile`, `.gitignore` | Project files |

### CMake options

The options are at the very top of the `CMakeLists.txt` (`<NAME>` = project name in upper case):

| Option | Default | Content |
| ------ | ------- | ------- |
| `<NAME>_KIND` | the `--kind` | `binary`, `library` or `header-only`: sets the defaults of the three package options below |
| `<NAME>_PACKAGE_BIN` | `ON` for `binary` | Build and package the executable (`<name>-op` / `-db` / `-as`) |
| `<NAME>_PACKAGE_LIB` | `ON` for `library` | Build and package the library (`lib<name>-op` / `-db` / `-as`, `lib<name>.a` / `_debug.a` / `_asan.a`) |
| `<NAME>_PACKAGE_DEV` | `ON` for `library`, `header-only` | Package the public headers and the CMake config (`lib<name>-dev`, `-dev-op` / `-db` / `-as` with a library) |
| `<NAME>_SHARED_LIB` | `OFF` | Shared library (`.so` / `.dll`) instead of a static one (`.a`) |
| `<NAME>_STABLE_RELEASE` | `OFF` | Package channel: stable (`ON`) or pre-release `-pre` (`OFF`) |
| `<NAME>_DEV_PACKAGE`, `<NAME>_PACKAGE` | `OFF` | Internal: the headers packages / the global package build (set by `package_release`) |
| `BUILD_TESTS` | `OFF` | Build the unit tests |

> [!NOTE]
> A binary can also ship its library and headers: `-D<NAME>_PACKAGE_LIB=ON -D<NAME>_PACKAGE_DEV=ON` (the executable is linked on the library target `<name>_lib`). After a change of these options, update `PACKAGE_BIN` / `PACKAGE_LIB` / `PACKAGE_DEV` in `.github/workflows/build.yml` and `build-packages.yml`.

## Packages

> [!NOTE]
> Every package has a pre-release/unstable version named `<package_name>-pre`.
> The `-pre` packages are marked as obsolete by any release/stable package (without `-pre`) of the same version or higher.

One version for the whole project (`project(... VERSION X.Y.Z)`), the same naming as libutils (`<name>` = project name, `lib<name>` = the library, never `liblib...`):

| File Name | Content | With |
| --------- | ------- | ---- |
| `<name>` / `lib<name>` | Global package: installs the default packages (`-op` variants, `-dev`) | always |
| `<name>-op` | Executable compiled with the optimization options | `PACKAGE_BIN` |
| `<name>-db` | Executable compiled with the debug options (suggests `gdb`) | `PACKAGE_BIN` |
| `<name>-as` | Executable compiled with the asan options | `PACKAGE_BIN` |
| `lib<name>-op` | Library compiled with the optimization options (`lib<name>.a`) | `PACKAGE_LIB` |
| `lib<name>-db` | Library compiled with the debug options (`lib<name>_debug.a`) | `PACKAGE_LIB` |
| `lib<name>-as` | Library compiled with the asan options (`lib<name>_asan.a`) | `PACKAGE_LIB` |
| `lib<name>-dev` | All the includes and the global CMake configuration (requires `libutils-dev`) | `PACKAGE_DEV` |
| `lib<name>-dev-op` / `-db` / `-as` | CMake configuration of each library variant (requires `libutils-op` / `-db` / `-as`) | `PACKAGE_DEV` + `PACKAGE_LIB` |

> [!WARNING]
> The three variants of the executable install the same `/usr/bin/<name>`: they conflict with each other, only one is installed at a time (the libraries are installed side by side, like libutils).

**Windows** (MinGW-w64 cross compilation, `noarch` packages installed in the MinGW sysroot: `/usr/x86_64-w64-mingw32/sys-root/mingw` on Fedora, `/usr/x86_64-w64-mingw32` on Debian/Ubuntu): the same packages prefixed with `mingw64-` (`mingw64-<name>`, `mingw64-lib<name>-dev`...), without the `-as` variants (no AddressSanitizer with MinGW), requiring `mingw64-libutils*` / `mingw64-openssl`.

| Build type | Package suffix | Options |
| ---------- | -------------- | ------- |
| `Debug` | `-db` | `-g -ggdb3` |
| `Asan` | `-as` | `-fsanitize=address -fno-omit-frame-pointer -g -ggdb3` (Linux only) |
| `Optimized` | `-op` | `-O3 -ffast-math -funroll-loops -fno-plt -pipe -DNDEBUG` (no `-march=native`: distributed) |

## Usage

Of the template itself (the template does not compile as is: `template` is a C++ keyword, run `setup.sh` first) and of a generated project:

```bash
make                                                      # Configure & build into build/ (executable at the root)
make re                                                   # Full rebuild
make fclean                                               # Remove the build directory

export BUILD_DIR=build
cmake -S . -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Debug         # Debug build (-g -ggdb3)
cmake -S . -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Asan          # AddressSanitizer build
cmake --build $BUILD_DIR --target release                 # Debug, Asan & Optimized builds
cmake --build $BUILD_DIR --target install_release         # Install the three variants (library) / the executable
cmake --build $BUILD_DIR --target package_release         # RPM / DEB of every variant + headers + global (build/*.rpm, *.deb)
cmake --build $BUILD_DIR --target get_unregistered_files  # .cpp files missing from the SRC / SRC_SHARED lists
cmake -S . -B $BUILD_DIR -DBUILD_TESTS=ON -DCMAKE_BUILD_TYPE=Debug && cmake --build $BUILD_DIR && (cd $BUILD_DIR && ctest)

export BUILD_DIR=build-windows                            # Windows (x86_64) from Linux, mingw64-libutils installed
cmake -S . -B $BUILD_DIR -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/mingw-w64.cmake -DCMAKE_BUILD_TYPE=Optimized
cmake --build $BUILD_DIR --parallel $(nproc)              # <name>.exe at the root
cmake --build $BUILD_DIR --target package_release         # mingw64-<name>* RPM / DEB
WINEPATH=/usr/x86_64-w64-mingw32/sys-root/mingw/bin wine ./<name>.exe --help

./<project_name> --help                                   # Generated help (libutils ArgParser)
./<project_name> -v debug                                 # Verbose level: none|basic|advanced|debug
```

> [!NOTE]
> Every new `.cpp` must be added to the `SRC` (executable only) or `SRC_SHARED` (executable and library) list of the `CMakeLists.txt` (`get_unregistered_files` lists the missing ones). Portable code only for Windows: system calls through `utils::platform::`, `<windows.h>` before `<utils/utils.hpp>`.

## Workflows/Release
### Workflows of the template
- `CI - Setup` runs on every push on `main` of the template repository: it runs the `setup.sh` of the pushed commit for each kind (`binary`, `library`, `header-only`, with `--gh-pages`) and once for Windows (`--no-gh-pages`), checks the result (no placeholder left, generated files, `gh-pages` branch content), builds the project, runs its unit tests and builds its packages

### Workflows of a generated project
- `Dispatch (CI/CD)`: runs on every push (branch `main` or tag `v*`, not for `*.md` / `*.txt` / `docs/` only changes) and decides what to trigger from the ref / commit message
- `Unit Tests (CI)`: builds and runs the unit tests, always first (Linux in the `unit-tests` image, Windows in the `mingw64-unit-tests` image under `wine`)
- `Build (CI)`: only builds the project (Linux in the `ci` image, Windows in the `mingw64-ci` image) and checks the outputs (executable / libraries), without producing packages
- `Build - Packages (CI/CD)`: builds the packages (RPM/DEB: Linux in the `ci` image, Windows `mingw64-*` in the `mingw64-ci` image), checks them against the `PACKAGE_*` content, then (gh-pages only) signs and publishes them on the `gh-pages` repository (`fedora/44/x86_64`, `debian/`, 5 last `-pre` versions kept)
- `Release - GitHub (CD)`: creates the GitHub release of a tag from its section of the `CHANGELOG.md` (`## vX.Y.Z - date` / `## [vX.Y.Z-pre] - date`), once the packages are built / published
- `Docs - Pages (CD)` (gh-pages only): copies `docs/` on the `gh-pages` branch on every push changing it (`https://<owner>.github.io/<repo>/`)
- `Sync Packages (CD)` (on the `gh-pages` branch): rebuilds the metadata and signatures of the package repository after a manual push on the branch (not the bot / docs commits)

> [!NOTE]
> `Build (CI)` only runs when `Dispatch (CI/CD)` decides **not** to build the packages, to check that the code still compiles. The disabled `notify-downstream` job of `dispatch.yml` is an example of `repository_dispatch` to another repository (like libutils -> docker-image).

> [!IMPORTANT]
> The workflows run on the runner set by the repository variable `RUNNER` (`gh variable set RUNNER --body <runner>`), inside the containers `ghcr.io/tsukini22/ci`, `unit-tests`, `mingw64-ci`, `mingw64-unit-tests`, `package` and `git` (libutils `4.x` inside). The publication needs the secrets `GPG_PRIVATE_KEY` (base64), `GPG_KEY_ID`, `GPG_PASSPHRASE`, and GitHub Pages enabled on the `gh-pages` branch (`gh api -X POST repos/<owner>/<repo>/pages -f 'source[branch]=gh-pages' -f 'source[path]=/'`).

> [!TIP]
> A commit containing `[ignore]` skips the whole CI.

### Pre-Release (unstable)
The pre-release of the packages (`<package_name>-pre`) is triggered by:
- a tag with a suffix, matching `vx.x.x-<suffix>` (ex: `v1.0.1-pre`, `x` = `major`, `minor`, `fix`)
- or a commit containing `[build]`

### Release (stable)
The release of the packages (channel `stable`) and the GitHub release are only triggered by a tag matching exactly `vx.x.x` (ex: `v1.0.0`), whose section must exist in the `CHANGELOG.md`.

### Downstream notification
A commit containing `[release]` (or a package publication) is the trigger of the commented `notify-downstream` job of `Dispatch (CI/CD)`.
