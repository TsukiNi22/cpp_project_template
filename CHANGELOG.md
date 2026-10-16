# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

| Scope | Content |
| ----- | ------- |
| `In Progress` | Work that hasn't been completed yet (typically listed under [pre-release]) |
| `Added`       | New features, files, or sections introduced in this release |
| `Removed`     | Existing features, files, or sections that have been deleted |
| `Changed`     | Existing features or sections that were modified (behavior, structure, or content) |
| `Fixed`       | Bugs or issues that have been resolved |

> [!NOTE]
> The template has no tag: this file is replaced by the `CHANGELOG.md` of the generated project (its first entry is `v1.0.0`).

---

## [pre-release]
### Changed
- **[MAJOR]** `CMakeLists.txt`: options at the top (`TEMPLATE_KIND` -> `TEMPLATE_PACKAGE_BIN` / `_LIB` / `_DEV`, `TEMPLATE_SHARED_LIB`, `TEMPLATE_STABLE_RELEASE`, `BUILD_TESTS`), library target and `find_package` config, `release` / `install_release` / `package_release` targets building every variant, no `-march=native` (distributed binaries)
- `setup.sh`: `--kind binary|library|header-only`, `--gh-pages` / `--no-gh-pages` (or the questions in the terminal), `--push` (`-push` kept), the repository from the `origin` remote or `GITHUB_REPO`, a full README (readme-style), the `CHANGELOG.md` and the documentation of the generated project, the header dates set to today, `testing` / `Test` refused
- `.github/workflows/build.yml`: triggered by `Dispatch (CI/CD)`, builds the `release` target on Linux and Windows and checks the executable / libraries from the `PACKAGE_*` content
- `.github/workflows/setup.yml`: matrix of the kinds with `--gh-pages`, a Windows job without it, checks of the generated project (placeholders, files, `gh-pages` branch), build, unit tests and packages
- `cmake/scripts/check_files.sh`: tolerates a project without `src/` (header-only)
- libutils requirement raised to `4.1.0` (`find_package(utils 4.1.0)`, package dependencies `libutils-<variant> >= 4.1.0`): needed by the Windows support (`mingw64-libutils*`)
- `README.md`: documents the kinds, the options, the package matrix, the workflows and the setup script flags

### Added
- Windows (x86_64) cross compilation with MinGW-w64: `cmake/toolchain/mingw-w64.cmake`, `cmake/package/CPackProjectConfig.cmake`, `mingw64-<name>*` packages installed in the MinGW sysroot (no Asan with MinGW)
- Packages with the libutils naming: `<name>` / `lib<name>` global, `-op` / `-db` / `-as` variants of the executable and of the library, `lib<name>-dev` (+ `-dev-op` / `-db` / `-as`), channels stable / `-pre`, the variants of the executable in conflict (one `/usr/bin/<name>`)
- `cmake/package/Config.cmake.in`: `find_package(<name> CONFIG)` with the check of the installed variant (`<name>::<name>`)
- `tests/`: GoogleTest skeleton (`tests/CMakeLists.txt`, `tests/template/Core.cpp`), GTest fetched from the sources when cross compiling, run with `wine` on Windows
- Workflows like libutils: `dispatch.yml` (`[ignore]` / `[build]` / `[release]`, tags `vX.Y.Z` / `vX.Y.Z-pre`, commented downstream notification example), `unit-tests.yml` (Linux + Windows), `build-packages.yml` (Linux + Windows, signed publication on `gh-pages`), `release.yml` (GitHub release from the `CHANGELOG.md` section of the tag), `docs.yml` (`docs/` copied on `gh-pages`)
- `gh-pages/`: seed of the `gh-pages` branch created by `setup.sh` (`Sync Packages (CD)` workflow, `<name>.repo`, `RPM-GPG-KEY-tsukini`, root `index.html` redirecting to `docs/`, `.nojekyll`)
- `install.sh`: package repository setup script of a generated project (its `setup.sh` with gh-pages: mirror + GPG key + install, `--pre`, `--windows`, `--no-install`, `--no-sudo`)
- `docs/`: HTML documentation (html-doc style) with a custom logo: `index.html` technical page placeholder ("coming soon" sections, EN / FR), `graph.html` interactive project graph refreshed from the repository
- `CHANGELOG.md` of the template

### Removed
- `-march=native` from the Optimized build (packaged binaries)
