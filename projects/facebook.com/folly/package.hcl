dependencies = {
  "boost.org" = "<1.89"
  darwin = {
    "sourceware.org/bzip2" = "*"
  }
  "facebook.com/zstd" = 1
  "fmt.dev" = "^12"
  "gflags.github.io" = "~2.2"
  "github.com/fastfloat/fast_float" = 7
  "gnu.org/coreutils" = 9
  "google.com/double-conversion" = "^3"
  "google.com/glog" = "^0.7"
  "google.com/googletest" = "^1"
  "google.github.io/snappy" = "*"
  "libevent.org" = "*"
  linux = {
    "elfutils.org" = "^0"
    "gnu.org/gcc/libstdcxx" = 14
    "jemalloc.net" = "^5"
    "libcxx.llvm.org" = "^18"
  }
  "lz4.org" = 1
  "openssl.org" = "^3"
  "tukaani.org/xz" = 5
  "zlib.net" = "^1"
}

build {
  dependencies = {
    "cmake.org" = "^3.0.2"
    linux = {
      "gnu.org/gcc" = 14
    }
    "linux/aarch64" = {
      "curl.se" = "*"
      "gnu.org/patch" = "*"
    }
  }
  env = {
    ARGS = [
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DBUILD_TESTING=OFF",
      "-DCMAKE_VERBOSE_MAKEFILE=ON",
      "-DFOLLY_USE_JEMALLOC=OFF",
      "-DCMAKE_CXX_STANDARD=20",
    ]
    linux = {
      ARGS = [
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-pie,-lrt,-lunwind",
      ]
    }
    "linux/aarch64" = {
      ARGS = [
        "-DCMAKE_LIBRARY_ARCHITECTURE=aarch64",
        "-DCMAKE_C_FLAGS=-fPIC",
        "-DCMAKE_CXX_FLAGS=-fPIC",
      ]
    }
  }
  script = [
    {
      if = ">=2024.07<2024.07.15"
      run = <<EOT
if test "{{hw.platform}}/{{hw.arch}}" = "linux/aarch64"; then
  curl -LS https://github.com/facebook/folly/commit/93525a1b4c395e6afc2fb1c0019f8537916dd4c3.patch | patch -R -p1
  curl -LS https://github.com/facebook/folly/commit/5dccf473579645f2b022bd9eeb6c7a42ea1eb1cb.patch | patch -R -p1 || true
fi
EOT
    },
    {
      if = ">=2026.1.19"
      run = <<EOT
if test "{{hw.platform}}/{{hw.arch}}" = "linux/aarch64"; then
  sed -i '/NAME memcpy_aarch64-use/,/^)/d; /NAME memset_aarch64-use/,/^)/d' folly/external/aor/CMakeLists.txt
  sed -i '/^folly_add_library($/{ N; /\n$/d; }' folly/external/aor/CMakeLists.txt
fi
EOT
    },
    {
      if = ">=2024.08"
      prop = <<EOT
/ChecksumDetail.h/a\
#include <stdexcept>
EOT
      run = "sed -i -f $PROP Checksum.cpp"
      working-directory = "folly/hash"
    },
    {
      if = ">=2026.6.8"
      prop = <<EOT
/#include <exception>/a\
#include <cstring>
EOT
      run = [
        "if ! grep -q '#include <cstring>' folly/lang/Exception.h; then",
        "sed -i -f $PROP folly/lang/Exception.h",
        "fi",
        "for f in $(grep -R -l 'fmt::format' folly); do",
        "if grep -q '#include <fmt/format\\.h>' \"$f\"; then continue; fi",
        <<EOT
sed -i -e '/#include <fmt\/core\.h>/a\
#include <fmt/format.h>' "$f"
EOT
,
        "done",
      ]
    },
    "sed -i '/linux\\.cpp/d' folly/system/os/CMakeLists.txt",
    "cmake $ARGS -DBUILD_SHARED_LIBS=ON -S . -B shared",
    "cmake --build shared",
    "cmake --install shared",
    "cmake $ARGS -DBUILD_SHARED_LIBS=OFF -S . -B static",
    "cmake --build static",
    {
      run = "cp $SRCROOT/static/libfolly.a libfollybenchmark.a"
      working-directory = "$${{prefix}}/static/folly"
    },
    {
      run = "sed -i -E -e \"s:{{pkgx.prefix}}:\\$\\{_IMPORT_PREFIX\\}/../../..:g\" -e '/^  INTERFACE_INCLUDE_DIRECTORIES/ s|/v([0-9]+)(\\.[0-9]+)*[a-z]?/include|/v\\1/include|g' -e '/^  INTERFACE_LINK_LIBRARIES/ s|/v([0-9]+)(\\.[0-9]+)*[a-z]?/lib|/v\\1/lib|g' folly-targets.cmake"
      working-directory = "$${{prefix}}/lib/cmake/folly"
    },
    {
      run = "sed -i -e 's/-I[^ ]* *//g' -e 's:{{pkgx.prefix}}:\\$${prefix}/../../..:g' libfolly.pc"
      working-directory = "$${{prefix}}/lib/pkgconfig"
    },
    {
      if = "darwin"
      run = <<EOT
for LIB in libfolly*.*.*.*-dev.dylib; do
  install_name_tool -add_rpath @loader_path $LIB
done
EOT
      working-directory = "$${{prefix}}/lib"
    },
  ]
  skip = "flatten-includes"
}

distributable {
  strip-components = 0
  url = "https://github.com/facebook/folly/releases/download/{{version.tag}}/folly-{{version.tag}}.tar.gz"
}

test {
  script = [
    {
      fixture = {
        content = <<EOT
#include <folly/FBVector.h>
int main() {
  folly::fbvector<int> numbers({0, 1, 2, 3});
  numbers.reserve(10);
  for (int i = 4; i < 10; i++) {
    numbers.push_back(i * 2);
  }
  assert(numbers[6] == 12);
  return 0;
}
EOT
        extname = "cc"
      }
      run = "c++ -std=c++20 -DGLOG_USE_GLOG_EXPORT $FIXTURE -lfolly -ldl -lfmt -lglog"
    },
    "./a.out",
  ]

  dependencies {
    linux = {
      "gnu.org/gcc" = "*"
    }
  }
}

versions {
  github = "facebook/folly"
}
