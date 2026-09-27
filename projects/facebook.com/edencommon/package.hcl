dependencies = {
  "boost.org" = "~1.88"
  "facebook.com/fb303" = "*"
  "facebook.com/folly" = "*"
  "facebook.com/mvfst" = "*"
  "gflags.github.io" = "*"
  "google.com/glog" = "*"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
  "openssl.org" = "^3"
  "sourceware.org/bzip2" = "^1"
}

build {
  dependencies = {
    "cmake.org" = "*"
    "google.com/googletest" = "*"
    linux = {
      "gnu.org/gcc" = 14
    }
  }
  script = [
    "sed -i 's/COMPONENTS cpp2 py)/COMPONENTS cpp2)/' CMakeLists.txt",
    {
      run = "sed -i 's/add_subdirectory(test)/#add_subdirectory(test)/' {os,utils}/CMakeLists.txt"
      working-directory = "eden/common"
    },
    {
      if = ">=2026.6.8"
      prop = <<EOT
/#include <fmt\/core\.h>/a\
#include <string>
s/std::string_view{s}/std::string_view{s.data(), s.size()}/
EOT
      run = "sed -i -f $PROP String.h"
      working-directory = "eden/common/utils"
    },
    "cmake -S . -B _build $ARGS",
    "cmake --build _build",
    "cmake --install _build",
  ]

  env {
    ARGS = [
      "-DBUILD_SHARED_LIBS=ON",
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
      "-DCMAKE_INSTALL_LIBDIR=lib",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_VERBOSE_MAKEFILE=ON",
      "-Wno-dev",
      "-DBUILD_TESTING=OFF",
      "-DCMAKE_CXX_STANDARD=20",
      "-DCMAKE_CXX_STANDARD_REQUIRED=ON",
    ]

    linux {
      ARGS = [
        "-DCMAKE_C_FLAGS=-fPIC",
        "-DCMAKE_CXX_FLAGS=-fPIC",
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-pie",
      ]
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/facebookexperimental/edencommon/archive/v{{version.raw}}.tar.gz"
}

test {
  script = [
    "c++ -std=c++20 -DGLOG_USE_GLOG_EXPORT test.cc -o test -ledencommon_utils -lfolly -lglog -lfmt $EXTRA",
    "./test 1",
  ]

  dependencies {
    linux = {
      "gnu.org/gcc" = 14
    }
  }

  env {

    linux {
      EXTRA = "-lc++abi"
    }
  }
}

versions {
  github = "facebookexperimental/edencommon/tags"
}
