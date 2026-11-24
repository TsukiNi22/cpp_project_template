# Generated project

## Files

| Path | Content |
| ---- | ------- |
| `CMakeLists.txt` | Options at the top, libutils, exception headers, `release` / `install_release` / `package_release`, CPack |
| `cmake/toolchain/mingw-w64.cmake` | Windows (x86_64) cross compilation toolchain |
| `cmake/package/` | `Config.cmake.in` (`find_package(<project_name>)`), CPack configuration (MinGW prefix, Arch) |
| `cmake/config/exceptions/*.json` | Exception codes of the project (`utils::exception::ExternalCode`) |
| `cmake/scripts/` | Exception header generator (`generate_exception_header.py`, `const.py`), `check_files.sh` |
| `src/<project_name>/` | `main.cpp` (entry, exceptions), `<Core>-init.cpp` (`ArgParser`, `--verbose`), `<Core>.cpp` (`run`) |
| `include/<project_name>/` | Public header, generated `exception/` headers |
| `tests/` | GoogleTest unit tests, `unit_tests` at the root |
| `docs/` | `index.html` (technical page placeholder), `graph.html` (project graph), `logo.svg` |
| `.github/workflows/` | `dispatch`, `lint`, `unit-tests`, `build`, `build-packages`, `release`, `docs` |
| `setup.sh` (`gh-pages` only) | Package repository setup: `--install`, `--pre`, `--windows`, `--no-sudo` |
| `README.md`, `CHANGELOG.md` | Written by `setup.sh` |
| `LICENSE`, `Makefile`, `Doxyfile`, `.gitignore`, `.githooks/` | MIT license, `make` shortcuts, Doxygen, ignored files, pre-commit hook |

A library has no `main.cpp`, a header-only library no `src/`.
GTest is fetched from its sources when cross compiling.

## CMake options
At the top of the `CMakeLists.txt`, `<NAME>` = project name in upper case:

| Option | Default | Content |
| ------ | ------- | ------- |
| `<NAME>_KIND` | the `--kind` | `binary`, `library` or `header-only`: default of the three options below |
| `<NAME>_PACKAGE_BIN` | `ON` for `binary` | Builds and packages the executable |
| `<NAME>_PACKAGE_LIB` | `ON` for `library` | Builds and packages the library |
| `<NAME>_PACKAGE_DEV` | `ON` for `library`, `header-only` | Packages the public headers and the CMake configuration |
| `<NAME>_SHARED_LIB` | `OFF` | Shared library (`.so` / `.dll`) instead of a static one (`.a`) |
| `<NAME>_STABLE_RELEASE` | `OFF` | Package channel: stable (`ON`) or pre-release `-pre` (`OFF`) |
| `<NAME>_DEV_PACKAGE`, `<NAME>_PACKAGE` | `OFF` | Internal, set by `package_release` |
| `BUILD_TESTS` | `OFF` | Builds the unit tests |

> [!TIP]
> A binary ships its library and headers too with `-D<NAME>_PACKAGE_LIB=ON -D<NAME>_PACKAGE_DEV=ON`.

> [!IMPORTANT]
> After a change of these options, update `PACKAGE_BIN` / `PACKAGE_LIB` / `PACKAGE_DEV` in `build.yml` and `build-packages.yml`.
