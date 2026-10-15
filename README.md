# cpp_project_template

A ready-to-use C++20 project template: CMake, `clang++`, ccache, [libutils](https://github.com/TsukiNi22/libutils) and exception headers generated from JSON.
The `setup.sh` script downloads it, renames the placeholders (`template` and `Core`) to your project name and core class name, and can commit/push the result.

### Table of Contents
 - [Dependencies](#dependencies)
 - [Quick Setup](#quick-setup)
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
| `libutils` | `4.x` (`>= 4.0.0`) | `libutils` | `libutils` |
| `ccache` **[OPTIONAL]** | any | `ccache` | `ccache` |

> [!TIP]
> libutils packages and source install: see the [libutils README](https://github.com/TsukiNi22/libutils#packages).

## Quick Setup

> Setup into the current directory

> [!IMPORTANT]
> With `-push`, the script must be run from inside an existing Git repository with a configured remote: it finishes with `git add . && git commit && git push` in the current directory.

> [!WARNING]
> `<project_name>` and `<core_name>` are used as C++ namespace and class name: they must be valid C++ identifiers (`[A-Za-z_][A-Za-z0-9_]*`), ex: `my_project`, not `my-project`.

1. Clones the latest version of the template (`main` branch) into a temporary directory
2. Copies its files into the current directory and removes the template only files (`setup.sh`, `.github/workflows/setup.yml`)
3. Renames every file or directory containing a placeholder (ex: `src/template/Core.cpp` -> `src/my_project/App.cpp`)
4. Replaces every placeholder inside the sources, headers, `CMakeLists.txt`, `.gitignore`, workflows and the `Doxyfile` project name
5. Writes a minimal `README.md`
6. With `-push`: commits and pushes the result (`git add . && git commit -m "Setup c++20 project template" && git push`)

```bash
wget -qO- https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> -push
```

or with `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> -push
```

| Argument | Effect |
| -------- | ------ |
| `<project_name>` | Replaces `template` (target, namespace, `include/`/`src/` folders, executable) |
| `<core_name>` | Replaces `Core` (main class and its files) |
| `-push` | Commits and pushes the result (skipped by default) |

| Environment variable | Effect |
| -------------------- | ------ |
| `REPO_URL` | Template repository to clone (default: `https://github.com/TsukiNi22/cpp_project_template.git`) |
| `BRANCH` | Branch to clone (default: `main`) |
| `TEMPLATE_DIR` | Local copy of the template used instead of the clone (used by the CI) |

## Usage

```bash
make                                          # Configure & build into build/ (executable at the root)
make re                                       # Full rebuild
make fclean                                   # Remove the build directory

export BUILD_DIR=build
cmake -S . -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Debug     # Debug build (-g -ggdb3)
cmake -S . -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Asan      # AddressSanitizer build
cmake --build $BUILD_DIR --target release             # Optimized build (-O3 -march=native)
cmake --build $BUILD_DIR --target get_unregistered_files  # .cpp files missing from the SRC list

./<project_name> --help                      # Generated help (libutils ArgParser)
./<project_name> -v debug                    # Verbose level: none|basic|advanced|debug
```

| Path | Content |
| ---- | ------- |
| `src/<project_name>/` | Sources: `main.cpp` (entry, exception handling), `<Core>-init.cpp` (arguments parsing), `<Core>.cpp` (`run`) |
| `include/<project_name>/` | Headers |
| `cmake/config/exceptions/*.json` | Project exception codes (`utils::exception::ExternalCode`) |
| `cmake/scripts/` | Exception header generator (`generate_exception_header.py`, `const.py`), `check_files.sh` |
| `include/exception/generated_external_exception_header.hpp` | Generated at build time from the JSON files (not committed) |

> [!NOTE]
> Every new `.cpp` must be added to the `SRC` list of the `CMakeLists.txt` (`get_unregistered_files` lists the missing ones).

## Workflows/Release
### Workflows
- The workflow `CI - Setup` runs on every push on `main` of the template repository: it runs the `setup.sh` of the pushed commit with test names, builds the result and checks the executable
- The workflow `CI - Executables` runs on every push on `main` of a generated project (skipped on the template repository): it builds the project and checks the executables listed in `EXECUTABLES`

> [!NOTE]
> Both workflows run on the runner set by the repository variable `RUNNER`, inside the `ghcr.io/tsukini22/ci:latest` container (which must provide libutils `4.x`, `>= 4.0.0`).
