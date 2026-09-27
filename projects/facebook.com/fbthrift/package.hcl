dependencies = {
  "boost.org" = "^1.83"
  "facebook.com/folly" = "*"
  "facebook.com/wangle" = "*"
  "facebook.com/zstd" = "^1.5.5"
  "fmt.dev" = "^12"
  "gflags.github.io" = "^2.2.2"
  "github.com/Cyan4973/xxHash" = "^0.8"
  "github.com/facebookincubator/fizz" = "*"
  "google.com/glog" = "^0.7"
  "libsodium.org" = "^1.0.19"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
  "openssl.org" = "^3"
  "zlib.net" = "^1.3"
}
provides = [
  "bin/thrift1",
]
test = [
  {
    if = "linux"
    run = <<EOT
if [ -f /etc/os-release ] && grep -q '^ID=arch' /etc/os-release; then
  echo "Arch Linux detected! Not currently testable."
  exit 0
fi
EOT
  },
  "thrift1 --gen mstch_cpp2 example.thrift",
  "ls | grep gen-cpp2",
]

build {
  dependencies = {
    "cmake.org" = "*"
    "facebook.com/mvfst" = "*"
    "github.com/westes/flex" = "*"
    "gnu.org/bison" = "*"
    linux = {
      "gnu.org/binutils" = "*"
      "gnu.org/gcc" = 14
    }
    "python.org" = "^3.10"
  }
  script = [
    {
      if = "linux/aarch64"
      run = "sed -i 's/^static_assert(is_supported_integral_type<char>);/\\/\\/&/' object.h"
      working-directory = "thrift/compiler/whisker"
    },
    {
      if = "darwin"
      run = <<EOT
if test -f FindFmt.cmake; then
  sed -i 's/add_library(fmt::fmt UNKNOWN IMPORTED)/#&/' FindFmt.cmake
fi
EOT
      working-directory = "thrift/cmake"
    },
    {
      if = "darwin"
      run = "sed -i 's/switch (token_.kind)/switch (tok(token_.kind))/g' parser_core.h"
      working-directory = "thrift/compiler/parse"
    },
    {
      prop = <<EOT
/AsyncProcessor\.h/a\
#include <fmt/ranges.h>
EOT
      run = "sed -i -f $PROP RoundRobinRequestPile.h"
      working-directory = "thrift/lib/cpp2/server"
    },
    {
      if = ">=2026.6.8"
      prop = <<EOT
/#pragma once/a\
#include <cstring>
EOT
      run = [
        "for f in thrift/lib/cpp2/frozen/FixedSizeStringHash.h thrift/lib/cpp2/protocol/JSONProtocolCommon-inl.h; do",
        "if grep -q '#include <cstring>' \"$f\"; then continue; fi",
        "sed -i -f $PROP \"$f\"",
        "done",
        "if ! grep -q '#include <cstring>' thrift/compiler/generate/t_concat_generator.cc; then",
        <<EOT
sed -i -e '/#include <cinttypes>/a\
#include <cstring>' thrift/compiler/generate/t_concat_generator.cc
EOT
,
        "fi",
        "for f in $(grep -R -l 'fmt::format' thrift); do",
        "if grep -q '#include <fmt/format\\.h>' \"$f\"; then continue; fi",
        <<EOT
sed -i -e '/#include <fmt\/core\.h>/a\
#include <fmt/format.h>' "$f"
EOT
,
        "done",
      ]
    },
    {
      if = "linux"
      run = "export PATH={{deps.gnu.org/binutils.prefix}}/bin:$PATH"
    },
    "cmake -S . $CMAKE_ARGS",
    "cmake --build .",
    "cmake --install .",
    {
      run = "sed -i -E -e \"s:{{pkgx.prefix}}:\\$\\{_IMPORT_PREFIX\\}/../../..:g\" -e '/^  INTERFACE_INCLUDE_DIRECTORIES/ s|/v([0-9]+)(\\.[0-9]+)*[a-z]?/include|/v\\1/include|g' -e '/^  INTERFACE_LINK_LIBRARIES/ s|/v([0-9]+)(\\.[0-9]+)*[a-z]?/lib|/v\\1/lib|g' FBThriftTargets.cmake"
      working-directory = "$${{prefix}}/lib/cmake/fbthrift"
    },
  ]

  env {
    CMAKE_ARGS = [
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}",
      "-DCMAKE_INSTALL_LIBDIR=lib",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_FIND_FRAMEWORK=LAST",
      "-DCMAKE_VERBOSE_MAKEFILE=ON",
      "-Wno-dev",
      "-DBUILD_TESTING=OFF",
      "-DBUILD_SHARED_LIBS=OFF",
      "-DCMAKE_CXX_STANDARD=20",
    ]

    darwin {
      CMAKE_ARGS = [
        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-undefined,dynamic_lookup,-dead_strip_dylibs",
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-dead_strip_dylibs",
      ]
      CXXFLAGS = [
        "-fno-assume-unique-vtables",
      ]
    }

    linux {
      CC = "gcc"
      CMAKE_ARGS = [
        "-DCMAKE_C_FLAGS=-fPIC",
        "-DCMAKE_CXX_FLAGS=-fPIC",
        "-DCMAKE_EXE_LINKER_FLAGS=-pie",
      ]
      CXX = "g++"
      LD = "gcc"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/facebook/fbthrift/archive/{{version.tag}}.tar.gz"
}

versions {
  github = "facebook/fbthrift/tags"
  ignore = [
    "v0.x.y",
    "0.x.y",
  ]
}
