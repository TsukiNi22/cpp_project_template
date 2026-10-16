#!/usr/bin/env bash
set -euo pipefail

##### Configuration #####
SCRIPT_NAME="setup.sh"
REPO_URL="${REPO_URL:-https://github.com/TsukiNi22/cpp_project_template.git}"
BRANCH="${BRANCH:-main}"
TEMPLATE_DIR="${TEMPLATE_DIR:-}" # Local copy of the template used instead of the clone (CI)
GITHUB_REPO="${GITHUB_REPO:-}" # owner/repo of the new project (default: the origin remote, else TsukiNi22/<project_name>)
TARGET_DIR="."
TODAY="$(date +%Y-%m-%d)"

##### Argument #####
usage() {
    echo "Usage: $SCRIPT_NAME <project_name> <core_name> [--kind binary|library|header-only] [--gh-pages|--no-gh-pages] [--push]"
    echo "  <project_name>   Replaces 'template' (target, namespace, folders, packages): a C++ identifier"
    echo "  <core_name>      Replaces 'Core' (main class): a C++ identifier"
    echo "  --kind <kind>    Project kind (CMake TEMPLATE_KIND): binary (default), library or header-only"
    echo "  --gh-pages       Create the gh-pages branch (packages repository + documentation) and keep its workflows"
    echo "  --no-gh-pages    No gh-pages branch: the packages stay as artifacts, no docs publication"
    echo "                   (without these two flags the question is asked in the terminal, 'no' without one)"
    echo "  --push           Commit and push the result (main, and gh-pages when created)"
    echo "Environment: REPO_URL, BRANCH, TEMPLATE_DIR (local template), GITHUB_REPO (owner/repo of the new project)"
    exit 1
}

if [[ "$#" -lt 2 ]]; then
    usage
fi
PROJECT_NAME="$1"
CORE_NAME="$2"
shift 2

KIND=""
GH_PAGES=""
PUSH=false
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --kind)
            [[ "$#" -ge 2 ]] || usage
            KIND="$2"
            shift
            ;;
        --kind=*)
            KIND="${1#--kind=}"
            ;;
        --gh-pages)
            GH_PAGES=true
            ;;
        --no-gh-pages)
            GH_PAGES=false
            ;;
        --push|-push) # -push: previous name of the option
            PUSH=true
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: unknown argument '$1'" >&2
            usage
            ;;
    esac
    shift
done

# Names used as C++ namespace / class and in sed patterns
CPP_RESERVED="alignas alignof and and_eq asm auto bitand bitor bool break case catch char char8_t char16_t char32_t class \
compl concept const consteval constexpr constinit const_cast continue co_await co_return co_yield decltype default delete \
do double dynamic_cast else enum explicit export extern false float for friend goto if inline int long mutable namespace \
new noexcept not not_eq nullptr operator or or_eq private protected public register reinterpret_cast requires return short \
signed sizeof static static_assert static_cast struct switch template this thread_local throw true try typedef typeid \
typename union unsigned using virtual void volatile wchar_t while xor xor_eq std utils"
for name in "$PROJECT_NAME" "$CORE_NAME"; do
    if ! [[ "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
        echo "Invalid name '$name': must be a valid C++ identifier ([A-Za-z_][A-Za-z0-9_]*)"
        exit 1
    fi
    if [[ " $CPP_RESERVED " == *" $name "* ]]; then
        echo "Invalid name '$name': C++ keyword or name reserved by the project (std, utils)"
        exit 1
    fi
done
if [[ "$PROJECT_NAME" == "testing" ]] || [[ "$CORE_NAME" == "Test" ]]; then
    echo "Invalid name: 'testing' / 'Test' clash with the GoogleTest namespace of the unit tests"
    exit 1
fi

##### Interactive questions (terminal only: 'wget ... | bash' still has /dev/tty) #####
ask() { # <question> <default> -> answer in REPLY, the default without a terminal
    REPLY="$2"
    if { : < /dev/tty && : > /dev/tty; } 2> /dev/null; then
        printf '%s [%s] ' "$1" "$2" > /dev/tty
        read -r REPLY < /dev/tty || true
        REPLY="${REPLY:-$2}"
    fi
}

if [[ -z "$KIND" ]]; then
    ask "Project kind: binary, library or header-only?" "binary"
    KIND="$REPLY"
fi
case "$KIND" in
    binary|library|header-only) ;;
    *)
        echo "Invalid kind '$KIND': binary, library or header-only"
        exit 1
        ;;
esac

if [[ -z "$GH_PAGES" ]]; then
    ask "Create the gh-pages branch (signed packages repository + documentation, needs the GPG secrets)? [y/N]" "n"
    case "$REPLY" in
        y|Y|yes|YES) GH_PAGES=true ;;
        *) GH_PAGES=false ;;
    esac
fi

##### Derived names #####
NAME_UPPER="$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]')"
LIB_NAME="${PROJECT_NAME#lib}"
if [[ -z "$GITHUB_REPO" ]]; then
    origin="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"
    if [[ "$origin" =~ github\.com[:/]([^/]+/[^/]+?)(\.git)?$ ]]; then
        GITHUB_REPO="${BASH_REMATCH[1]}"
        GITHUB_REPO="${GITHUB_REPO%.git}"
    else
        GITHUB_REPO="TsukiNi22/$PROJECT_NAME"
    fi
fi
OWNER="${GITHUB_REPO%%/*}"
REPO="${GITHUB_REPO#*/}"
PAGES_URL="https://$(echo "$OWNER" | tr '[:upper:]' '[:lower:]').github.io/$REPO"
case "$KIND" in
    binary) PACKAGE_BIN=ON; PACKAGE_LIB=OFF; PACKAGE_DEV=OFF ;;
    library) PACKAGE_BIN=OFF; PACKAGE_LIB=ON; PACKAGE_DEV=ON ;;
    header-only) PACKAGE_BIN=OFF; PACKAGE_LIB=OFF; PACKAGE_DEV=ON ;;
esac
if [[ "$PACKAGE_BIN" == "ON" ]]; then PACKAGE_BASE="$PROJECT_NAME"; else PACKAGE_BASE="lib$LIB_NAME"; fi

echo "Project: $PROJECT_NAME ($CORE_NAME), kind: $KIND, repository: $GITHUB_REPO, gh-pages: $GH_PAGES"

##### Clone into a temporary directory #####
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if [[ -n "$TEMPLATE_DIR" ]]; then
    echo "Copying the local template ${TEMPLATE_DIR}..."
    tar -C "$TEMPLATE_DIR" --exclude=./.git --exclude='./build*' --exclude=./.cache --exclude=./include/exception -cf - . | tar -C "$TMP_DIR" -xf -
else
    echo "Cloning ${REPO_URL} (branch: ${BRANCH})..."
    git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"
fi
rm -rf "$TMP_DIR/.git"

##### Edit the template copy (never the files already in the target directory) #####
# Remove file & content that are only here for the template repository
rm -f "$TMP_DIR/$SCRIPT_NAME" "$TMP_DIR/scripts.zip" # Remove this script
rm -f "$TMP_DIR/.github/workflows/setup.yml" # Check of the script execution
rm -f "$TMP_DIR/CHANGELOG.md" # History of the template (a new one is written below)
sed -i "/# Don't run on template repository/{N;d;}" "$TMP_DIR/.github/workflows/dispatch.yml" "$TMP_DIR/.github/workflows/docs.yml" # Remove start condition

# Project kind: default of the CMake options and content checked by the workflows
sed -i "s/^set(TEMPLATE_KIND \"binary\" CACHE STRING/set(TEMPLATE_KIND \"$KIND\" CACHE STRING/" "$TMP_DIR/CMakeLists.txt"
sed -i "s/^  PACKAGE_BIN: \"ON\"/  PACKAGE_BIN: \"$PACKAGE_BIN\"/; s/^  PACKAGE_LIB: \"OFF\"/  PACKAGE_LIB: \"$PACKAGE_LIB\"/; s/^  PACKAGE_DEV: \"OFF\"/  PACKAGE_DEV: \"$PACKAGE_DEV\"/" \
    "$TMP_DIR/.github/workflows/build.yml" "$TMP_DIR/.github/workflows/build-packages.yml"
case "$KIND" in
    library)
        # No entry point in a library (the ArgParser init stays available for an executable of the users)
        rm -f "$TMP_DIR/src/template/main.cpp"
        sed -i '/^    src\/template\/main.cpp$/d' "$TMP_DIR/CMakeLists.txt"
        ;;
    header-only)
        # Nothing compiled: the class is defined in its header, the sources and their exception codes are removed
        rm -rf "$TMP_DIR/src"
        sed -i '/^    src\/template\/.*\.cpp$/d' "$TMP_DIR/CMakeLists.txt"
        cat << 'EOF' > "$TMP_DIR/include/template/Core.hpp"
/**************************************************************\

 ██╗  ██╗ █████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗██╗ █████╗
 ╚██╗██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██║██╔══██╗
  ╚███╔╝ ███████║██████╔╝   ██║   ███████║██╔██╗ ██║██║███████║
  ██╔██╗ ██╔══██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║██║██╔══██║
 ██╔╝ ██╗██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║██║██║  ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝

Edition:
##  @date DD/MM/YYYY by @author Tsukini

File Name:
##  @file Core.hpp

File Description:
##  You know, I don t think there are good or bad descriptions,
##  for me, life is all about functions...
\**************************************************************/

#ifndef CORE_H
    #define CORE_H

    //----------------------------------------------------------------//
    /* INCLUDE */

    /* type */
    //#include <iostream>

namespace template { // namespace start
//----------------------------------------------------------------//
/* CLASS */

class Core {
    private:
        /* Nothing */

    public:
        // ---------- Pre-Function -------- //
        inline void run(void)
        {
            /* nothing... */
        }

        // ------------ Operator ---------- //
        Core& operator=(const Core& other) = delete;
        Core& operator=(Core&& other) = delete;

        // ---------- Constructor --------- //
        Core() = default;
        Core(const Core& other) = delete;
        Core(Core&& other) = delete;

        // ----------- Destructor --------- //
        ~Core() = default;
};

} // namespace end
#endif /* CORE_H */
EOF
        cat << 'EOF' > "$TMP_DIR/tests/template/Core.cpp"
/**************************************************************\

 ██╗  ██╗ █████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗██╗ █████╗
 ╚██╗██╔╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██║██╔══██╗
  ╚███╔╝ ███████║██████╔╝   ██║   ███████║██╔██╗ ██║██║███████║
  ██╔██╗ ██╔══██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║██║██╔══██║
 ██╔╝ ██╗██║  ██║██║  ██║   ██║   ██║  ██║██║ ╚████║██║██║  ██║
 ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝

Edition:
##  @date DD/MM/YYYY by @author Tsukini

File Name:
##  @file Core.cpp

File Description:
##  Unit tests of the Core class (header-only)
\**************************************************************/

#include "template/Core.hpp"
#include <gtest/gtest.h>

/* Run */
TEST(Core, RunDoesNothing)
{
    template::Core core;

    EXPECT_NO_THROW(core.run());
}
EOF
        ;;
esac

# gh-pages: the seed of the branch is kept aside, the workflows that need the branch are removed otherwise
GH_PAGES_DIR="$TMP_DIR.gh-pages"
mv "$TMP_DIR/gh-pages" "$GH_PAGES_DIR"
if [[ "$GH_PAGES" == true ]]; then
    mv "$TMP_DIR/install.sh" "$TMP_DIR/setup.sh" # Package repository setup of the project (like libutils)
else
    rm -f "$TMP_DIR/install.sh" "$TMP_DIR/.github/workflows/docs.yml"
    sed -i '/# >>> gh-pages >>>/,/# <<< gh-pages <<</d' "$TMP_DIR/.github/workflows/build-packages.yml"
fi

# Header dates: today
find "$TMP_DIR" -type f \( -name "*.cpp" -o -name "*.hpp" \) -exec sed -i "s|@date \(DD/MM/YYYY\|[0-9]\{2\}/[0-9]\{2\}/[0-9]\{4\}\)|@date $(date +%d/%m/%Y)|" {} +

##### Rename files/directories containing 'template' #####
echo "Renaming files and directories: 'template' -> '${PROJECT_NAME}'..."
for dir in "$TMP_DIR" "$GH_PAGES_DIR"; do
    find "$dir" -mindepth 1 -depth -name "*template*" -not -path "*/.git/*" -not -path "*/include/utils/*" | while read -r path; do
        new_path="$(dirname "$path")/$(basename "$path" | sed "s/\btemplate\b/${PROJECT_NAME}/g")"
        if [[ "$path" != "$new_path" ]]; then
            mv "$path" "$new_path"
        fi
    done
done

##### Replace 'template' inside file contents (CMake, .gitignore, headers, sources, workflows, scripts, repo) #####
echo "Replacing 'template' references inside files..."
for dir in "$TMP_DIR" "$GH_PAGES_DIR"; do
    grep -rlZE --exclude-dir=.git --exclude-dir=utils --exclude-dir=docs --include="*.cpp" --include="*.hpp" --include="CMakeLists.txt" --include="*.cmake" --include="*.in" --include=".gitignore" --include="*.yml" --include="*.sh" --include="*.repo" --include="*.html" '\btemplate\b' "$dir" 2>/dev/null \
        | xargs -0 -r sed -i "s/\btemplate\b/${PROJECT_NAME}/g" || true
    grep -rlZ --exclude-dir=.git --exclude-dir=utils --exclude-dir=docs --include="CMakeLists.txt" --include="*.cmake" --include="*.in" --include="*.yml" 'TEMPLATE_' "$dir" 2>/dev/null \
        | xargs -0 -r sed -i "s/TEMPLATE_/${NAME_UPPER}_/g" || true
done
sed -i "s/^PROJECT_NAME\( *\)= .*/PROJECT_NAME\1= \"${PROJECT_NAME}\"/" "$TMP_DIR/Doxyfile"
sed -i "s|TsukiNi22/${PROJECT_NAME}\b|${GITHUB_REPO}|g; s|tsukini22.github.io/${PROJECT_NAME}\b|${PAGES_URL#https://}|g" \
    "$TMP_DIR/CMakeLists.txt" "$GH_PAGES_DIR/$PROJECT_NAME.repo" $(ls "$TMP_DIR/setup.sh" 2>/dev/null)

##### Rename files/directories containing 'Core' #####
echo "Renaming files and directories: 'Core' -> '${CORE_NAME}'..."
find "$TMP_DIR" -mindepth 1 -depth -name "*Core*" -not -path "*/.git/*" -not -path "*/include/utils/*" | while read -r path; do
    new_path="$(dirname "$path")/$(basename "$path" | sed "s/\bCore\b/${CORE_NAME}/g")"
    if [[ "$path" != "$new_path" ]]; then
        mv "$path" "$new_path"
    fi
done

##### Replace 'Core' inside file contents (CMakeLists.txt, headers, sources) #####
echo "Replacing 'Core' references inside files..."
grep -rlZE --exclude-dir=.git --exclude-dir=utils --exclude-dir=docs --include="*.cpp" --include="*.hpp" --include="CMakeLists.txt" '\bCore\b' "$TMP_DIR" 2>/dev/null \
    | xargs -0 -r sed -i "s/\bCore\b/${CORE_NAME}/g" || true
grep -rlZE --exclude-dir=.git --exclude-dir=utils --include="*.hpp" '\bCORE_H\b' "$TMP_DIR" 2>/dev/null \
    | xargs -0 -r sed -i "s/\bCORE_H\b/${CORE_NAME^^}_H/g" || true

##### Documentation (docs/: technical page placeholder + project graph pointing at the new repository) #####
echo "Setting up the documentation (docs/)..."
python3 - "$TMP_DIR/docs" "$PROJECT_NAME" "$CORE_NAME" "$GITHUB_REPO" << 'EOF'
import glob
import re
import sys

docs, name, core, repo = sys.argv[1:5]
key = re.sub(r"[^a-z0-9]+", "-", name.lower())
for path in glob.glob(f"{docs}/*.html"):
    with open(path, encoding="utf-8") as file:
        page = file.read()
    page = page.replace("TsukiNi22/cpp_project_template", repo)
    page = page.replace('data-storage-key="template"', f'data-storage-key="{key}"')
    page = re.sub(r"(<title>)template\b", rf"\g<1>{name}", page)
    page = page.replace('<span class="repo-name">template</span>', f'<span class="repo-name">{name}</span>')
    # Embedded config & snapshot of the graph (JSON only: the names of the files, classes and namespaces)
    for sid in ("graph-config", "graph-snapshot"):
        match = re.search(rf'(<script id="{sid}" type="application/json">)(.*?)(</script>)', page, re.S)
        if match:
            body = re.sub(r"\btemplate\b", name, match.group(2))
            body = re.sub(r"\bCore\b", core, body)
            page = page[:match.start(2)] + body + page[match.end(2):]
    with open(path, "w", encoding="utf-8") as file:
        file.write(page)
EOF

##### README.md & CHANGELOG.md #####
echo "Writing README.md and CHANGELOG.md..."
write_readme() {
    local lib="lib$LIB_NAME" repo_url="https://github.com/$GITHUB_REPO"
    {
        cat << EOF
# ${PROJECT_NAME}

EOF
        if [[ "$GH_PAGES" == true ]]; then
            cat << EOF
> [!TIP]
> Documentation [${GITHUB_REPO}](${PAGES_URL}/docs/) (v1.0.0): technical documentation (coming soon) and the interactive project graph.

EOF
        fi
        case "$KIND" in
            binary) echo "C++20 executable built with CMake, \`clang++\`, ccache and [libutils](https://github.com/TsukiNi22/libutils); the exception codes are generated from JSON." ;;
            library) echo "C++20 library (\`${lib}.a\`, \`find_package(${PROJECT_NAME})\`) built with CMake, \`clang++\`, ccache and [libutils](https://github.com/TsukiNi22/libutils); the exception codes are generated from JSON." ;;
            header-only) echo "C++20 header-only library (\`find_package(${PROJECT_NAME})\`, target \`${PROJECT_NAME}::${PROJECT_NAME}\`) on top of [libutils](https://github.com/TsukiNi22/libutils)." ;;
        esac
        cat << EOF
Generated from [cpp_project_template](https://github.com/TsukiNi22/cpp_project_template): Linux and Windows (MinGW-w64 cross compilation) builds, RPM / DEB packages and the libutils workflows.

### Table of Contents
 - [Dependencies](#dependencies)
 - [Packages](#packages)
 - [Quick Setup - 1 (all)](#quick-setup---1-all)
EOF
        [[ "$GH_PAGES" == true ]] && echo " - [Quick Setup - 2 (Limited)](#quick-setup---2-limited)"
        cat << EOF
 - [Usage](#usage)
 - [Windows (cross compilation)](#windows-cross-compilation)
 - [Unit tests](#unit-tests)
 - [Workflows/Release](#workflowsrelease)

## Dependencies

> [!CAUTION]
> The MIT license of this project ([LICENSE](LICENSE)) only applies to the code of \`${PROJECT_NAME}\` itself, not to its dependencies.

| Name + Link | Status | Last Update |
| ----------- | ------ | ----------- |
| [libutils](https://github.com/TsukiNi22/libutils) | ![CD - Dispatch](https://github.com/TsukiNi22/libutils/actions/workflows/dispatch.yml/badge.svg) | ![](https://img.shields.io/github/last-commit/TsukiNi22/libutils) |

| Name | Version | Fedora (\`dnf\`) | Debian/Ubuntu (\`apt\`) |
| ---- | ------- | -------------- | --------------------- |
| \`clang++\` / \`cmake\` | C++20 / \`>= 3.20\` | \`clang cmake\` | \`clang cmake\` |
| \`python3\` | \`>= 3.8\` | \`python3\` | \`python3\` |
| \`libutils\` | \`4.x\` (\`>= 4.1.0\`) | \`libutils\` | \`libutils\` |
| GoogleTest (tests only) | any | \`gtest-devel\` | \`libgtest-dev\` |
| MinGW-w64 (Windows only) | GCC \`>= 13\` | \`mingw64-gcc-c++ mingw64-libutils\` | \`g++-mingw-w64-x86-64\` + libutils built for MinGW |
| \`ccache\` **[OPTIONAL]** | any | \`ccache\` | \`ccache\` |

> [!TIP]
> libutils packages and source install: see the [libutils README](https://github.com/TsukiNi22/libutils#packages).

## Packages

> [!NOTE]
> Every package has a pre-release/unstable version named \`<package_name>-pre\`.
> The \`-pre\` packages are marked as obsolete by any release/stable package (without \`-pre\`) of the same version or higher.

EOF
        case "$KIND" in
            binary)
                cat << EOF
| File Name | Content |
| --------- | ------- |
| \`${PROJECT_NAME}\` | Install the default package (\`${PROJECT_NAME}-op\`) |
| \`${PROJECT_NAME}-op\` | Executable compiled with the optimization options |
| \`${PROJECT_NAME}-db\` | Executable compiled with the debug options (intended for debugging only) |
| \`${PROJECT_NAME}-as\` | Executable compiled with the asan options (intended for debugging only) |

> [!WARNING]
> The three variants install the same \`/usr/bin/${PROJECT_NAME}\`: only one of them can be installed at a time.
EOF
                ;;
            library)
                cat << EOF
| File Name | Content |
| --------- | ------- |
| \`${lib}\` | Install the default packages (\`${lib}-dev\`, \`${lib}-op\`) |
| \`${lib}-dev\` | All the includes and the global CMake configuration (requires \`libutils-dev\`) |
| \`${lib}-dev-op\` | CMake configuration for \`${lib}-op\` |
| \`${lib}-dev-db\` | CMake configuration for \`${lib}-db\` |
| \`${lib}-dev-as\` | CMake configuration for \`${lib}-as\` |
| \`${lib}-op\` | Library compiled with the optimization options (\`${lib}.a\`) |
| \`${lib}-db\` | Library compiled with the debug options (\`${lib}_debug.a\`, intended for debugging only) |
| \`${lib}-as\` | Library compiled with the asan options (\`${lib}_asan.a\`, intended for debugging only) |
EOF
                ;;
            header-only)
                cat << EOF
| File Name | Content |
| --------- | ------- |
| \`${lib}\` | Install the default package (\`${lib}-dev\`) |
| \`${lib}-dev\` | All the includes and the CMake configuration (requires \`libutils-dev\`) |
EOF
                ;;
        esac
        cat << EOF

**Windows** (MinGW-w64 cross compilation, installed in the MinGW sysroot: \`/usr/x86_64-w64-mingw32/sys-root/mingw\` on Fedora, \`/usr/x86_64-w64-mingw32\` on Debian/Ubuntu): the same packages prefixed with \`mingw64-\` (ex: \`mingw64-${PACKAGE_BASE}\`), without the \`-as\` variants (no AddressSanitizer with MinGW).

> [!NOTE]
> The content of the packages is chosen at the top of the \`CMakeLists.txt\`: \`${NAME_UPPER}_KIND\` (\`${KIND}\`) sets the defaults of \`${NAME_UPPER}_PACKAGE_BIN\` (executable), \`${NAME_UPPER}_PACKAGE_LIB\` (library, \`${NAME_UPPER}_SHARED_LIB\` for a \`.so\`) and \`${NAME_UPPER}_PACKAGE_DEV\` (headers + CMake config), each one can be forced with \`-D...=ON/OFF\`.
> After a change, update \`PACKAGE_BIN\` / \`PACKAGE_LIB\` / \`PACKAGE_DEV\` in \`.github/workflows/build.yml\` and \`build-packages.yml\`.

## Quick Setup - 1 (all)
> Setup into \`/usr/local\`

### Clone the repository
\`\`\`bash
git clone ${repo_url}.git
cd ${PROJECT_NAME}
\`\`\`

EOF
        if [[ "$KIND" == "binary" ]]; then
            cat << EOF
### Build & install
\`\`\`bash
export BUILD_DIR=build
cmake -S . -B \$BUILD_DIR -DCMAKE_BUILD_TYPE=Optimized
cmake --build \$BUILD_DIR --parallel \$(nproc)                       # ./${PROJECT_NAME} at the root
sudo cmake --build \$BUILD_DIR --target install --parallel \$(nproc) # /usr/local/bin/${PROJECT_NAME}
\`\`\`
EOF
        else
            cat << EOF
### Install the lib
\`\`\`bash
export BUILD_DIR=build
cmake -S . -B \$BUILD_DIR
sudo cmake --build \$BUILD_DIR --target install_release --parallel \$(nproc) # Debug, Asan & Optimized variants
\`\`\`

### Include
\`\`\`cmake
find_package(${PROJECT_NAME} 1.0.0 CONFIG REQUIRED)
target_link_libraries(<target> PRIVATE ${PROJECT_NAME}::${PROJECT_NAME})
\`\`\`

> [!WARNING]
> Everything is defined within the namespace \`${PROJECT_NAME}::\`.

| Include | Content |
| ------- | ------- |
| \`${PROJECT_NAME}/${CORE_NAME}.hpp\` | \`${PROJECT_NAME}::${CORE_NAME}\` (\`run()\`) |
EOF
        fi
        if [[ "$GH_PAGES" == true ]]; then
            cat << EOF

## Quick Setup - 2 (Limited)
> Setup into \`/usr\`

> [!WARNING]
> If during the installation using tools like \`dnf\`, \`apt\`... you see an \`invalid hash\` error, reset the cache of the tool or relaunch the \`setup.sh\` script.
>
> If the error still persists, it might be due to an error in the repository.

> [!WARNING]
> Restriction: \`fedora-based (rpm)\`, \`debian-based (deb)\`

> [!NOTE]
> The usage of \`sudo\` in the script can be removed with the \`--no-sudo\` argument.

Run the setup script directly, without cloning the repository. It registers the package repository (\`gh-pages\` branch) so the system package manager can install the packages:
1. Detect the distribution from \`/etc/os-release\` (\`rpm\` or \`deb\` based).
2. \`rpm\`: add \`/etc/yum.repos.d/${PROJECT_NAME}.repo\` and import the GPG key.
3. \`deb\`: add the GPG key in \`/etc/apt/keyrings/${PROJECT_NAME}.gpg\`, the source in \`/etc/apt/sources.list.d/${PROJECT_NAME}.list\`, then \`apt-get update\`.
4. Install the package \`${PACKAGE_BASE}\` (\`--pre\` for the unstable one, \`--windows\` for \`mingw64-${PACKAGE_BASE}\`).

\`\`\`bash
wget -qO- https://raw.githubusercontent.com/${GITHUB_REPO}/main/setup.sh | bash -s
\`\`\`

or with \`curl\`:

\`\`\`bash
curl -fsSL https://raw.githubusercontent.com/${GITHUB_REPO}/main/setup.sh | bash -s
\`\`\`

| Argument | Effect |
| -------- | ------ |
| \`--no-sudo\` | Run without \`sudo\` (the script must already run as root) |
| \`--pre\` | Install the pre-release/unstable package (\`${PACKAGE_BASE}-pre\`) |
| \`--windows\` | Install the Windows packages (\`mingw64-${PACKAGE_BASE}\`, MinGW sysroot) |
| \`--no-install\` | Only setup the mirror & GPG key, don't install the package |
| \`-h\`, \`--help\` | Display the usage |
EOF
        fi
        cat << EOF

## Usage

\`\`\`bash
make                                                      # Configure & build into build/
make re                                                   # Full rebuild
make fclean                                               # Remove the build directory

export BUILD_DIR=build
cmake -S . -B \$BUILD_DIR -DCMAKE_BUILD_TYPE=Debug         # Debug build (-g -ggdb3)
cmake -S . -B \$BUILD_DIR -DCMAKE_BUILD_TYPE=Asan          # AddressSanitizer build
cmake --build \$BUILD_DIR --target release                 # Debug, Asan & Optimized builds
cmake --build \$BUILD_DIR --target install_release         # Install the three variants
cmake --build \$BUILD_DIR --target package_release         # RPM / DEB packages of every variant (build/*.rpm, *.deb)
cmake --build \$BUILD_DIR --target get_unregistered_files  # .cpp files missing from the SRC list
EOF
        if [[ "$KIND" == "binary" ]]; then
            cat << EOF

./${PROJECT_NAME} --help                                  # Generated help (libutils ArgParser)
./${PROJECT_NAME} -v debug                                # Verbose level: none|basic|advanced|debug
EOF
        fi
        cat << EOF
\`\`\`

| Option | Default | Content |
| ------ | ------- | ------- |
| \`${NAME_UPPER}_KIND\` | \`${KIND}\` | Project kind (\`binary\`, \`library\`, \`header-only\`): defaults of the three options below |
| \`${NAME_UPPER}_PACKAGE_BIN\` | \`${PACKAGE_BIN}\` | Build and package the executable (\`${PROJECT_NAME}-op\` / \`-db\` / \`-as\`) |
| \`${NAME_UPPER}_PACKAGE_LIB\` | \`${PACKAGE_LIB}\` | Build and package the library (\`${lib}-op\` / \`-db\` / \`-as\`) |
| \`${NAME_UPPER}_PACKAGE_DEV\` | \`${PACKAGE_DEV}\` | Package the public headers and the CMake config (\`${lib}-dev\`) |
| \`${NAME_UPPER}_SHARED_LIB\` | \`OFF\` | Shared library (\`.so\` / \`.dll\`) instead of a static one |
| \`${NAME_UPPER}_STABLE_RELEASE\` | \`OFF\` | Package channel: stable (\`ON\`) or pre-release \`-pre\` (\`OFF\`) |
| \`BUILD_TESTS\` | \`OFF\` | Build the unit tests (\`unit_tests\`, GoogleTest) |

| Path | Content |
| ---- | ------- |
EOF
        if [[ "$KIND" != "header-only" ]]; then
            [[ "$KIND" == "binary" ]] && echo "| \`src/${PROJECT_NAME}/\` | Sources: \`main.cpp\` (entry, exception handling), \`${CORE_NAME}-init.cpp\` (arguments parsing), \`${CORE_NAME}.cpp\` (\`run\`) |"
            [[ "$KIND" == "library" ]] && echo "| \`src/${PROJECT_NAME}/\` | Sources: \`${CORE_NAME}-init.cpp\` (arguments parsing), \`${CORE_NAME}.cpp\` (\`run\`) |"
        fi
        cat << EOF
| \`include/${PROJECT_NAME}/\` | Public headers |
| \`tests/${PROJECT_NAME}/\` | Unit tests (one file per module) |
| \`cmake/config/exceptions/*.json\` | Project exception codes (\`utils::exception::ExternalCode\`) |
| \`cmake/scripts/\` | Exception header generator (\`generate_exception_header.py\`, \`const.py\`), \`check_files.sh\` |
| \`cmake/toolchain/mingw-w64.cmake\` | Windows cross compilation toolchain |
| \`cmake/package/\` | CMake package config (\`find_package(${PROJECT_NAME})\`) and the CPack prefix of the Windows packages |
| \`docs/\` | HTML documentation (technical page, project graph) |
| \`include/exception/generated_external_exception_header.hpp\` | Generated at build time from the JSON files (not committed) |

> [!NOTE]
> Every new \`.cpp\` must be added to the \`SRC\` list of the \`CMakeLists.txt\` (\`get_unregistered_files\` lists the missing ones).

## Windows (cross compilation)
> Build for Windows (x86_64) from Linux with the MinGW-w64 toolchain (libutils: \`mingw64-libutils\` packages in the MinGW sysroot)

\`\`\`bash
export BUILD_DIR=build-windows
cmake -S . -B \$BUILD_DIR -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/mingw-w64.cmake -DCMAKE_BUILD_TYPE=Optimized
cmake --build \$BUILD_DIR --parallel \$(nproc)                 # ${PROJECT_NAME}.exe at the root / build-windows/${lib}.a
cmake --build \$BUILD_DIR --target package_release           # mingw64-${PACKAGE_BASE}* RPM/DEB (MinGW sysroot)
WINEPATH=/usr/x86_64-w64-mingw32/sys-root/mingw/bin wine ./${PROJECT_NAME}.exe --help
\`\`\`

> [!NOTE]
> No AddressSanitizer with MinGW: the \`Asan\` mode is built like \`Debug\`. Portable code only: system calls through \`utils::platform::\`, \`<windows.h>\` before \`<utils/utils.hpp>\`.

## Unit tests

\`\`\`bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DBUILD_TESTS=ON
cmake --build build --parallel \$(nproc)                       # ./unit_tests at the root
(cd build && ctest --output-on-failure)
\`\`\`

## Workflows/Release
### Workflows
- \`Dispatch (CI/CD)\`: runs on every push (branch \`main\` or tag \`v*\`, not for \`*.md\` / \`*.txt\` / \`docs/\` only changes) and decides what to trigger from the ref / commit message
- \`Unit Tests (CI)\`: builds and runs the unit tests, always first (Linux in the \`unit-tests\` image, Windows in the \`mingw64-unit-tests\` image under \`wine\`)
- \`Build (CI)\`: only builds the project (Linux in the \`ci\` image, Windows in the \`mingw64-ci\` image) and checks the outputs, without producing packages
EOF
        if [[ "$GH_PAGES" == true ]]; then
            cat << EOF
- \`Build - Packages (CI/CD)\`: builds the packages (RPM/DEB: Linux in the \`ci\` image, Windows \`mingw64-*\` in the \`mingw64-ci\` image), signs them and publishes them on the \`gh-pages\` repository
- \`Release - GitHub (CD)\`: creates the GitHub release of a tag from its section of the \`CHANGELOG.md\`, once the packages are published
- \`Docs - Pages (CD)\`: copies \`docs/\` on the \`gh-pages\` branch on every push changing it (${PAGES_URL}/docs/)
- \`Sync Packages (CD)\` (on \`gh-pages\`): rebuilds the metadata and signatures of the package repository after a manual push on the branch
EOF
        else
            cat << EOF
- \`Build - Packages (CI/CD)\`: builds the packages (RPM/DEB: Linux in the \`ci\` image, Windows \`mingw64-*\` in the \`mingw64-ci\` image), kept as artifacts of the run
- \`Release - GitHub (CD)\`: creates the GitHub release of a tag from its section of the \`CHANGELOG.md\`, once the packages are built
EOF
        fi
        cat << EOF

> [!NOTE]
> \`Build (CI)\` only runs when \`Dispatch (CI/CD)\` decides **not** to build the packages, to check that the code still compiles.

EOF
        local required="The workflows need the repository variable \`RUNNER\` (\`gh variable set RUNNER --body <runner>\`), the containers \`ghcr.io/tsukini22/ci\`, \`unit-tests\`, \`mingw64-ci\`, \`mingw64-unit-tests\`, \`package\`, \`git\`"
        if [[ "$GH_PAGES" == true ]]; then
            required+=", and the secrets \`GPG_PRIVATE_KEY\` (base64), \`GPG_KEY_ID\`, \`GPG_PASSPHRASE\` to sign and publish the packages."
        else
            required+="."
        fi
        printf '> [!IMPORTANT]\n> %s\n' "$required"
        cat << EOF

> [!TIP]
> A commit containing \`[ignore]\` skips the whole CI.

### Pre-Release (unstable)
The pre-release of the packages (\`<package_name>-pre\`) is triggered by:
- a tag with a suffix, matching \`vx.x.x-<suffix>\` (ex: \`v1.0.1-pre\`, \`x\` = \`major\`, \`minor\`, \`fix\`)
- or a commit containing \`[build]\`

EOF
        [[ "$GH_PAGES" == true ]] && printf '> [!NOTE]\n> Only the 5 last versions of each `-pre` package are kept in the package repository, every release is kept.\n\n'
        cat << EOF
### Release (stable)
The release of the packages (channel \`stable\`) and the GitHub release are only triggered by a tag matching exactly \`vx.x.x\` (ex: \`v1.0.0\`), whose section must exist in the \`CHANGELOG.md\`.

### Downstream notification
\`Dispatch (CI/CD)\` has a commented \`notify-downstream\` job (\`repository_dispatch\` to another repository, like libutils -> docker-image), triggered after a package publication or by a commit containing \`[release]\`.
EOF
    } > "$TMP_DIR/README.md"
}
write_readme

cat << EOF > "$TMP_DIR/CHANGELOG.md"
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

| Scope | Content |
| ----- | ------- |
| \`In Progress\` | Work that hasn't been completed yet (typically listed under [pre-release]) |
| \`Added\`       | New features, files, or sections introduced in this release |
| \`Removed\`     | Existing features, files, or sections that have been deleted |
| \`Changed\`     | Existing features or sections that were modified (behavior, structure, or content) |
| \`Fixed\`       | Bugs or issues that have been resolved |

> [!NOTE]
> The \`(unofficial)\` version are sub-versions (typically fixes) that don't have associated tag.
> A package built at this version is not guaranteed!

---

## [pre-release] (empty)

## v1.0.0 - ${TODAY}
### Added
- First version of \`${PROJECT_NAME}\` (${KIND}), set up from [cpp_project_template](https://github.com/TsukiNi22/cpp_project_template)

[v1.0.0]: https://github.com/${GITHUB_REPO}/releases/tag/v1.0.0
EOF

##### Move files to the target directory #####
mkdir -p "$TARGET_DIR"
cp -r "$TMP_DIR"/. "$TARGET_DIR"/
cd "$TARGET_DIR"

##### gh-pages branch (packages repository + documentation), never touching the working tree #####
if [[ "$GH_PAGES" == true ]]; then
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "Initializing the git repository (main)..."
        git init -q -b main
    fi
    if git show-ref --verify --quiet refs/heads/gh-pages; then
        echo "Branch gh-pages already exists: left untouched (seed kept in $GH_PAGES_DIR.seed)"
        rm -rf "$GH_PAGES_DIR.seed"
        cp -r "$GH_PAGES_DIR" "$GH_PAGES_DIR.seed"
    else
        echo "Creating the gh-pages branch..."
        cp -r "$TMP_DIR/docs" "$GH_PAGES_DIR/docs"
        GIT_DIR="$(git rev-parse --git-dir)"
        GIT_DIR="$(cd "$GIT_DIR" && pwd)"
        GH_PAGES_INDEX="$(mktemp -u)" # must not exist yet (git refuses an empty index file)
        (
            cd "$GH_PAGES_DIR"
            export GIT_DIR GIT_WORK_TREE="$GH_PAGES_DIR" GIT_INDEX_FILE="$GH_PAGES_INDEX"
            git add -A .
            TREE="$(git write-tree)"
            COMMIT="$(git commit-tree "$TREE" -m "chore(gh-pages): setup the packages repository and the documentation")"
            git branch gh-pages "$COMMIT"
        )
        rm -f "$GH_PAGES_INDEX"
        echo "Branch gh-pages created: enable GitHub Pages on it (gh api -X POST repos/$GITHUB_REPO/pages -f 'source[branch]=gh-pages' -f 'source[path]=/')"
    fi
fi
rm -rf "$GH_PAGES_DIR"

##### Commit and push #####
if [[ "$PUSH" = true ]]; then
    echo "Pushing changes..."
    git add .
    git commit -m "chore: setup c++20 project from cpp_project_template"
    git push
    if [[ "$GH_PAGES" == true ]]; then
        git push origin gh-pages
    fi
else
    echo "Skipping git push (use --push to enable)"
fi

echo "Project '${PROJECT_NAME}' (${KIND}) set up in '${TARGET_DIR}'"
