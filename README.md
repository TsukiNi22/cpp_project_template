# cpp_project_template

A ready-to-use C++20 project template (CMake, Clang, ccache, generated exception headers).

## Dependencies

| Name + Link | Status | Last Update |
| ----------- | ------ | ----------- |
| [my_lib_cpp](https://github.com/TsukiNi22/my_lib_cpp) | ![CI/CD - Library](https://github.com/TsukiNi22/my_lib_cpp/actions/workflows/build-sync.yml/badge.svg) | ![](https://img.shields.io/github/last-commit/TsukiNi22/my_lib_cpp) |


## Quick Setup

Run the setup script directly, without cloning the repository manually. It downloads the latest version of the template from `main`, renames every `project` occurrence to your chosen project name, and commits/pushes the result to the current repository.

> [!IMPORTANT]
> Remove `-push` to disable the automatic commit of the setup

```bash
wget -qO- https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> -push
```

or with `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/TsukiNi22/cpp_project_template/main/setup.sh | bash -s -- <project_name> <core_name> -push
```

> [!IMPORTANT]
> This must be run from inside an existing Git repository with a configured remote — the script finishes with `git add . && git commit && git push` in the current directory.

## What the script does

1. Clones the latest version of the template (`main` branch) into a temporary directory
2. Copies its files into the current directory
3. Renames any file or directory containing `project` (e.g. `src/project/main.cpp` → `src/my_project/main.cpp`)
4. Replaces every whole-word `project` occurrence inside `CMakeLists.txt`, `.cpp`, and `.hpp` files with the given name
5. Commits and pushes the result (`git add . && git commit -m "Setup c++20 project template" && git push`)

## Requirements

- `git`
- `bash`
- A Git repository with a configured remote (for the final commit/push step)
