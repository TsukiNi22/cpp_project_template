#!/usr/bin/env bash
set -euo pipefail

##### Configuration #####
REPO_URL="https://github.com/TsukiNi22/cpp_project_template.git"
BRANCH="main"
TARGET_DIR="."

##### Argument #####
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi
PROJECT_NAME="$1"

##### Clone into a temporary directory #####
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning ${REPO_URL} (branch: ${BRANCH})..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"
rm -rf "$TMP_DIR/.git"

##### Move files to the target directory #####
mkdir -p "$TARGET_DIR"
cp -r "$TMP_DIR"/. "$TARGET_DIR"/

##### Rename files/directories containing 'project' #####
echo "Renaming files and directories: 'project' -> '${PROJECT_NAME}'..."
find "$TARGET_DIR" -depth -iname "*project*" -not -path "*/.git/*" | while read -r path; do
    new_path="$(dirname "$path")/$(basename "$path" | sed "s/project/${PROJECT_NAME}/g")"
    if [ "$path" != "$new_path" ]; then
        mv "$path" "$new_path"
    fi
done

##### Replace 'project' inside file contents (CMakeLists.txt, headers, sources) #####
echo "Replacing 'project' references inside files..."
grep -rlZE --include="*.cpp" --include="*.hpp" --include="CMakeLists.txt" '\bproject\b' "$TARGET_DIR" 2>/dev/null \
    | xargs -0 -r sed -i "s/\bproject\b/${PROJECT_NAME}/g"

##### Commit and push #####
cd "$TARGET_DIR"
git add .
git commit -m "Setup c++20 project template"
git push

echo "Project '${PROJECT_NAME}' set up in '${TARGET_DIR}'"
