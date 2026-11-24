# Usage

## CMake
The `make` shortcuts call these targets.

```bash
export BUILD_DIR=build
cmake -S . -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Debug         # Debug build (-g -ggdb3)
cmake -S . -B $BUILD_DIR -DCMAKE_BUILD_TYPE=Asan          # AddressSanitizer build
cmake --build $BUILD_DIR --target release                 # Debug, Asan & Optimized builds
cmake --build $BUILD_DIR --target install_release         # install the three variants (library) / the executable
cmake --build $BUILD_DIR --target package_release         # RPM / DEB / Arch of every variant (build/*.rpm, *.deb, *.pkg.tar.zst)
cmake --build $BUILD_DIR --target get_unregistered_files  # .cpp files missing from SRC / SRC_SHARED
cmake -S . -B $BUILD_DIR -DBUILD_TESTS=ON -DCMAKE_BUILD_TYPE=Debug && cmake --build $BUILD_DIR && (cd $BUILD_DIR && ctest)
```

| List | Sources of |
| ---- | ---------- |
| `SRC` | The executable only |
| `SRC_SHARED` | The executable and the library |

## Windows
Cross compilation for Windows (x86_64) from Linux, with `mingw64-libutils` installed:

```bash
export BUILD_DIR=build-windows
cmake -S . -B $BUILD_DIR -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain/mingw-w64.cmake -DCMAKE_BUILD_TYPE=Optimized
cmake --build $BUILD_DIR --parallel $(nproc)              # <name>.exe at the root
cmake --build $BUILD_DIR --target package_release         # mingw64-<name>* RPM / DEB
WINEPATH=/usr/x86_64-w64-mingw32/sys-root/mingw/bin wine ./<name>.exe --help
```

> [!IMPORTANT]
> Portable code only: system calls through `utils::platform::`, `<windows.h>` before `<utils/utils.hpp>`.
