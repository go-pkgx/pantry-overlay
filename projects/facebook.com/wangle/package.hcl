dependencies = {
  "boost.org" = "*"
  darwin = {
    "sourceware.org/bzip2" = "*"
    "zlib.net" = "*"
  }
  "facebook.com/folly" = "*"
  "facebook.com/zstd" = "^1"
  "fmt.dev" = "^12"
  "gflags.github.io" = "*"
  "github.com/facebookincubator/fizz" = "*"
  "google.com/double-conversion" = "^3"
  "google.com/glog" = "^0.7"
  "google.github.io/snappy" = "*"
  "libevent.org" = "*"
  "libsodium.org" = "*"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
  "lz4.org" = "^1"
  "openssl.org" = "^3"
}

build {
  dependencies = {
    "cmake.org" = "^3"
    linux = {
      "gnu.org/gcc" = 14
    }
  }
  script = [
    "cmake . -DBUILD_SHARED_LIBS=ON $ARGS",
    "make install",
    "make clean",
    "cmake . -DBUILD_SHARED_LIBS=OFF $ARGS",
    "make",
    "cp lib/libwangle.a {{prefix}}/lib",
    {
      run = <<EOT
sed -E -i.bak \
  -e "s:{{pkgx.prefix}}:\$\{_IMPORT_PREFIX\}/../../..:g" \
  -e '/^  INTERFACE_INCLUDE_DIRECTORIES/ s|/v([0-9]+)(\.[0-9]+)*[a-z]?/include|/v\1/include|g' \
  -e '/^  INTERFACE_LINK_LIBRARIES/ s|/v([0-9]+)(\.[0-9]+)*[a-z]?/lib|/v\1/lib|g' \
wangle-targets.cmake
rm wangle-targets.cmake.bak
EOT
      working-directory = "{{prefix}}/lib/cmake/wangle"
    },
  ]
  working-directory = "wangle"

  env {
    ARGS = [
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DBUILD_TESTS=OFF",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/facebook/wangle/archive/refs/tags/v{{version.raw}}.tar.gz"
}

test {
  dependencies = {
    "curl.se" = "*"
    linux = {
      "gnu.org/gcc" = 14
    }
  }
  script = [
    {
      if = "<2026.3.23"
      run = "STD=c++17"
    },
    {
      if = ">=2026.3.23"
      run = "STD=c++20"
    },
    "c++ -std=$STD -DGLOG_USE_GLOG_EXPORT 'EchoClient.cpp' -o EchoClient $LIBS",
    "c++ -std=$STD -DGLOG_USE_GLOG_EXPORT 'EchoServer.cpp' -o EchoServer $LIBS",
  ]

  env {
    LIBS = [
      "-lgflags",
      "-lglog",
      "-lfolly",
      "-lfizz",
      "-lwangle",
      "-lssl",
      "-lcrypto",
      "-lfmt",
      "-ldouble-conversion",
      "-levent",
      "-lboost_context",
    ]

    darwin {
      LIBS = [
        "-lc++abi",
      ]
    }

    linux {
      LIBS = [
        "-ldl",
        "-lpthread",
        "-latomic",
      ]
    }
  }
}

versions {
  github = "facebook/wangle"
  strip = "/v/"
}
