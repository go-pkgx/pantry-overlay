dependencies = {
  "boost.org" = "*"
  "facebook.com/folly" = "*"
  "facebook.com/zstd" = 1
  "fmt.dev" = "^12"
  "gflags.github.io" = "*"
  "google.com/double-conversion" = "^3"
  "google.com/glog" = "^0.7"
  "google.github.io/snappy" = "*"
  "libevent.org" = "*"
  "libsodium.org" = "*"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
  "lz4.org" = 1
  "openssl.org" = "^3"
  "sourceware.org/bzip2" = 1
  "zlib.net" = "^1"
}
provides = [
  "bin/fizz",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    linux = {
      "gnu.org/gcc" = 14
    }
    "ninja-build.org" = "^1"
  }
  env = {
    ARGS = [
      "-GNinja",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}\"",
      "-DBUILD_TESTS=OFF",
      "-DBUILD_SHARED_LIBS=ON",
      "-DCMAKE_INSTALL_RPATH=\"{{prefix}}\"",
    ]
    "linux/aarch64" = {
      ARGS = [
        "-DCMAKE_C_FLAGS=-fPIC",
        "-DCMAKE_CXX_FLAGS=-fPIC",
        "-DCMAKE_EXE_LINKER_FLAGS=-pie",
      ]
    }
  }
  script = [
    {
      if = ">=2023.12.18.0"
      prop = <<EOT
/#include <fizz\/crypto\/aead\/AESGCM128.h>/a\
#include <fizz/crypto/exchange/X25519.h>\
#include <fizz/protocol/OpenSSLFactory.h>
EOT
      run = "sed -i -f $PROP FizzServerCommand.cpp"
      working-directory = "fizz/tool"
    },
    {
      if = "darwin"
      run = "sed -i 's/FIZZ_CHECK_EQ(awaiter_, nullptr)/FIZZ_CHECK(awaiter_ == nullptr)/' fizz/experimental/psp/PSP.cpp"
    },
    {
      if = ">=2026.2.2.0"
      run = <<EOT
if ! grep -q 'Folly::folly_benchmark[^_]' {{deps.facebook.com/folly.prefix}}/lib/cmake/folly/folly-targets.cmake; then
  sed -i 's/Folly::folly_benchmark/Folly::follybenchmark/' fizz/CMakeLists.txt
fi
EOT
    },
    "cmake -S fizz -B build $ARGS",
    "cmake --build build",
    "cmake --install build",
    {
      run = "sed -E -i -e \"s:{{pkgx.prefix}}:\\$\\{_IMPORT_PREFIX\\}/../../../..:g\" -e '/^  INTERFACE_INCLUDE_DIRECTORIES/ s|/v([0-9]+)(\\.[0-9]+)*[a-z]?/include|/v\\1/include|g' -e '/^  INTERFACE_LINK_LIBRARIES/ s|/v([0-9]+)(\\.[0-9]+)*[a-z]?/lib|/v\\1/lib|g' fizz-targets.cmake"
      working-directory = "{{prefix}}/lib/cmake/fizz"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/facebookincubator/fizz/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  script = [
    {
      if = "<2026.3.23"
      run = "STD=c++17"
    },
    {
      if = ">=2026.3.23"
      run = "STD=c++20"
    },
    {
      fixture = {
        content = <<EOT
#include <fizz/client/AsyncFizzClient.h>
#include <iostream>

int main() {
  auto context = fizz::client::FizzClientContext();
  std::cout << toString(context.getSupportedVersions()[0]) << std::endl;
}
EOT
        extname = "cpp"
      }
      run = "c++ -std=$STD -DGLOG_USE_GLOG_EXPORT $FIXTURE -lfizz -lfolly -lgflags -lglog -levent -lsodium -lcrypto -lssl -lboost_context -o fixture"
    },
    "./fixture | grep TLS",
  ]

  dependencies {
    linux = {
      "gnu.org/gcc" = 14
    }
  }
}

versions {
  github = "facebookincubator/fizz/releases/tags"
}
