dependencies = {
  "facebook.com/zstd" = "*"
  "gnome.org/libxml2" = "^2"
  "zlib.net" = 1
}
provides = [
  "bin/lld",
  "bin/lldb",
  "bin/clang",
  "bin/clang++",
  "bin/clangd",
  "bin/cc",
  "bin/c++",
  "bin/cpp",
  "bin/nm",
  "bin/objcopy",
  "bin/ranlib",
  "bin/readelf",
  "bin/strings",
  "bin/strip",
  "bin/llvm-profdata",
  "bin/llvm-cov",
]

build {
  dependencies = {
    "cmake.org" = ">=3<3.29"
    "crates.io/semverator" = "*"
    "ninja-build.org" = 1
    "python.org" = ">=3<3.12"
  }
  env = {
    ARGS = [
      "-DCMAKE_INSTALL_PREFIX=\"{{ prefix }}\"",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DLLVM_ENABLE_PROJECTS='lld;lldb;clang;clang-tools-extra'",
      "-DLLVM_INCLUDE_DOCS=OFF",
      "-DLLVM_INCLUDE_TESTS=OFF",
      "-DLLVM_ENABLE_RTTI=ON",
      "-DLLVM_BUILD_LLVM_DYLIB=ON",
    ]
    darwin = {
      ARGS = [
        "-DDEFAULT_SYSROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk",
        "-DLLVM_BUILD_LLVM_C_DYLIB=ON",
        "-DLLVM_ENABLE_LIBCXX=ON",
        "-DLIBCXX_HAS_ATOMIC_LIB=ON",
      ]
    }
    linux = {
      ARGS = [
        "-DCLANG_DEFAULT_LINKER=lld",
        "-DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON",
      ]
    }
    "linux/aarch64" = {
      ARGS = [
        "-DCMAKE_C_COMPILER_TARGET=\"aarch64-unknown-linux-gnu\"",
      ]
    }
    "linux/x86-64" = {
      ARGS = [
        "-DCLANG_DEFAULT_CXX_STDLIB=libstdc++",
        "-DCLANG_DEFAULT_RTLIB=libgcc",
        "-DCOMPILER_RT_INCLUDE_TESTS=OFF",
        "-DCOMPILER_RT_USE_LIBCXX=OFF",
        "-DCMAKE_C_COMPILER_TARGET=\"x86_64-unknown-linux-gnu\"",
      ]
    }
  }
  receipt = [
    "LLVMConfig.cmake",
  ]
  script = [
    {
      run = <<EOT
RUNTIMES="-DLLVM_ENABLE_RUNTIMES='compiler-rt'"
if test "{{hw.platform}}" = "linux"; then
  ARGS="$ARGS $RUNTIMES"
elif semverator satisfies '>=14' {{version}}; then
  ARGS="$ARGS $RUNTIMES"
elif test "{{hw.arch}}" = "x86-64" && semverator satisfies '>=14' {{version}}; then
  ARGS="$ARGS $RUNTIMES"
fi
EOT
    },
    "cmake ../llvm -G Ninja $ARGS",
    "ninja",
    "ninja install",
    {
      run = [
        "ln -sf clang cc",
        "ln -sf clang++ c++",
        "ln -sf clang-cpp cpp",
        <<EOT
for x in nm objcopy ranlib readelf strings strip; do
  ln -sf llvm-$x $x
done
EOT
,
      ]
      working-directory = "$${{prefix}}/bin"
    },
    {
      if = "linux"
      run = <<EOT
TARGET="$(find . -maxdepth 1 -type d -name \*-unknown-linux-gnu)"
if test -n "$TARGET"; then
  mv "$TARGET"/* .
  rmdir "$TARGET"
  ln -s . "$TARGET"
fi
EOT
      working-directory = "$${{prefix}}/lib"
    },
  ]
  working-directory = "build"
}

distributable {
  strip-components = 1
  url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-{{ version }}/llvm-project-{{ version }}.src.tar.xz"
}

test {
  dependencies = {
    "crates.io/semverator" = "*"
  }
  fixture = <<EOT
#include <stdio.h>
int main() {
  printf("Hello World!\n");
  return 0;
}
EOT
  script = [
    {
      run = <<EOT
if test "{{hw.platform}}" = "linux"; then
  ARGS="$ARGS -fsanitize=address,undefined"
elif test "{{hw.arch}}" = "x86_64" && semverator satisfies '>=13' {{version}}; then
  ARGS="$ARGS -fsanitize=address,undefined"
elif semverator satisfies '>=14' {{version}}; then
  ARGS="$ARGS -fsanitize=address,undefined"
fi
EOT
    },
    "mv $FIXTURE $FIXTURE.c",
    "clang $ARGS $FIXTURE.c",
    "./a.out",
  ]

  env {
    ARGS = [
      "-Wl,-rpath,$PKGX_DIR",
    ]
  }
}

versions {
  github = "llvm/llvm-project"
  strip = "/^llvmorg-/"
}
