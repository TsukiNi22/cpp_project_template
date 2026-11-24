# Packages

One version for the whole project: `project(... VERSION X.Y.Z)`.
`<name>` = project name in lower case with `-` instead of `_`; `lib<name>` = the library, never `liblib...`.

## Linux

| File Name | Content | With |
| --------- | ------- | ---- |
| `<name>` / `lib<name>` | Global package: installs the `-op` variants and `-dev` | always |
| `<name>-op` | Executable, optimization options | `PACKAGE_BIN` |
| `<name>-db` | Executable, debug options (suggests `gdb`) | `PACKAGE_BIN` |
| `<name>-as` | Executable, asan options | `PACKAGE_BIN` |
| `lib<name>-op` | Library, optimization options (`lib<name>.a`) | `PACKAGE_LIB` |
| `lib<name>-db` | Library, debug options (`lib<name>_debug.a`) | `PACKAGE_LIB` |
| `lib<name>-as` | Library, asan options (`lib<name>_asan.a`) | `PACKAGE_LIB` |
| `lib<name>-dev` | Every include and the global CMake configuration (requires `libutils-dev`) | `PACKAGE_DEV` |
| `lib<name>-dev-op` / `-db` / `-as` | CMake configuration of each library variant (requires `libutils-op` / `-db` / `-as`) | `PACKAGE_DEV` + `PACKAGE_LIB` |

Each package has a `-pre` version, made obsolete by a stable package of the same version or newer.

> [!WARNING]
> The three executables install the same `/usr/bin/<name>`: one at a time. The libraries install side by side.

## Windows
MinGW-w64 cross compilation gives the same packages prefixed with `mingw64-`, ex: `mingw64-<name>`, `mingw64-lib<name>-dev`.
They have no `-as` variant (no AddressSanitizer with MinGW) and require `mingw64-libutils*` / `mingw64-openssl`.

| Distribution | MinGW sysroot (`noarch` packages) |
| ------------ | --------------------------------- |
| Fedora | `/usr/x86_64-w64-mingw32/sys-root/mingw` |
| Debian/Ubuntu | `/usr/x86_64-w64-mingw32` |
