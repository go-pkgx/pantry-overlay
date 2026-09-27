dependencies = {
  "facebook.com/fbthrift" = ">=2023.12.18.0"
  "facebook.com/folly" = "*"
  "facebook.com/wangle" = "*"
  "fmt.dev" = "^12"
  "gflags.github.io" = "^2.2.2"
  "github.com/Cyan4973/xxHash" = "^0.8"
  "github.com/facebookincubator/fizz" = "*"
  "google.com/glog" = "^0.7"
  "libsodium.org" = "^1.0.19"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
    "zlib.net" = "^1"
  }
  "openssl.org" = "^3"
}

build {
  dependencies = {
    "boost.org" = "^1.84"
    "cmake.org" = "*"
    "facebook.com/mvfst" = "*"
    linux = {
      "gnu.org/gcc" = 14
    }
  }
  env = {
    CMAKE_ARGS = [
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}",
      "-DCMAKE_INSTALL_LIBDIR=lib",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_FIND_FRAMEWORK=LAST",
      "-DCMAKE_VERBOSE_MAKEFILE=ON",
      "-Wno-dev",
      "-DBUILD_TESTING=OFF",
      "-DPYTHON_EXTENSIONS=OFF",
      "-DBUILD_SHARED_LIBS=ON",
      "-DCMAKE_CXX_STANDARD=20",
    ]
    darwin = {
      CMAKE_ARGS = [
        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-undefined,dynamic_lookup",
      ]
    }
    linux = {
      CMAKE_ARGS = [
        "-DCMAKE_C_FLAGS=-fPIC",
        "-DCMAKE_CXX_FLAGS=-fPIC",
      ]
    }
    "linux/aarch64" = {
      CMAKE_ARGS = [
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-pie,-latomic",
      ]
    }
    "linux/x86-64" = {
      CMAKE_ARGS = [
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-pie",
      ]
    }
  }
  script = [
    "cmake -S . -B build $CMAKE_ARGS",
    "cmake --build build",
    "cmake --install build",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/facebook/fb303/archive/v{{version.raw}}.tar.gz"
}

test {
  dependencies = {
    "boost.org" = "^1.84"
    linux = {
      "gnu.org/gcc" = 14
    }
  }
  script = [
    "c++ -std=c++20 -DGLOG_USE_GLOG_EXPORT test.cpp -o test $LDFLAGS $EXTRA_LIBS -lfb303_thrift_cpp -lfolly -lglog -lthriftprotocol -lthriftcpp2 -ldl -lboost_context -lfmt",
    "./test | grep 'BaseService'",
  ]

  env {
    LDFLAGS = "-Wl,--allow-shlib-undefined"

    darwin {
      LDFLAGS = "-Wl,-undefined,dynamic_lookup"
    }

    linux {
      EXTRA_LIBS = "-latomic"
    }
  }
}

versions {
  github = "facebook/fb303/tags"
}
