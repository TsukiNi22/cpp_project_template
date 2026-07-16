#!/usr/bin/env bash
set -euo pipefail

##### Configuration #####
REPO_URL="https://github.com/TsukiNi22/cpp_project_template.git"
BRANCH="main"
TARGET_DIR="."

##### Argument #####
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <project_name> <core_name>"
    exit 1
fi
PROJECT_NAME="$1"
CORE_NAME="$2"

##### Clone into a temporary directory #####
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning ${REPO_URL} (branch: ${BRANCH})..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"
rm -rf "$TMP_DIR/.git"

##### Move files to the target directory #####
mkdir -p "$TARGET_DIR"
cp -r "$TMP_DIR"/. "$TARGET_DIR"/

##### Rename files/directories containing 'template' #####
echo "Renaming files and directories: 'template' -> '${PROJECT_NAME}'..."
find "$TARGET_DIR" -depth -iname "*template*" -not -path "*/.git/*" -not -path "*/include/utils/*" | while read -r path; do
    new_path="$(dirname "$path")/$(basename "$path" | sed "s/template/${PROJECT_NAME}/g")"
    if [ "$path" != "$new_path" ]; then
        mv "$path" "$new_path"
    fi
done

##### Replace 'template' inside file contents (CMakeLists.txt, .gitignore, headers, sources) #####
echo "Replacing 'template' references inside files..."
grep -rlZE --exclude-dir=.git --exclude-dir=utils --include="*.cpp" --include="*.hpp" --include="CMakeLists.txt" --include=".gitignore" '\btemplate\b' "$TARGET_DIR" 2>/dev/null \
    | xargs -0 -r sed -i "s/\btemplate\b/${PROJECT_NAME}/g"

##### Rename files/directories containing 'Core' #####
echo "Renaming files and directories: 'Core' -> '${CORE_NAME}'..."
find "$TARGET_DIR" -depth -iname "*Core*" -not -path "*/.git/*" -not -path "*/include/utils/*" | while read -r path; do
    new_path="$(dirname "$path")/$(basename "$path" | sed "s/Core/${CORE_NAME}/g")"
    if [ "$path" != "$new_path" ]; then
        mv "$path" "$new_path"
    fi
done

##### Replace 'Core' inside file contents (CMakeLists.txt, headers, sources) #####
echo "Replacing 'Core' references inside files..."
grep -rlZE --exclude-dir=.git --exclude-dir=utils --include="*.cpp" --include="*.hpp" --include="CMakeLists.txt" '\bCore\b' "$TARGET_DIR" 2>/dev/null \
    | xargs -0 -r sed -i "s/\bCore\b/${CORE_NAME}/g"

##### Commit and push #####
cd "$TARGET_DIR"
git add .
git commit -m "Setup c++20 project template"
git push

echo "Project '${PROJECT_NAME}' set up in '${TARGET_DIR}'"
