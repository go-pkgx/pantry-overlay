dependencies = {
  "facebook.com/edencommon" = "*"
  "facebook.com/fb303" = "*"
  "facebook.com/folly" = "*"
  "fmt.dev" = ">=9"
  "gflags.github.io" = "^2"
  "google.com/glog" = "^0.7"
  "libevent.org" = "^2.1"
  "libsodium.org" = "^1"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
    "libcxx.llvm.org" = 18
  }
  "openssl.org" = "^3"
  "pcre.org/v2" = "^10"
  "python.org" = "~3.11"
}
provides = [
  "bin/watchman",
  "bin/watchman-diag",
  "bin/watchman-make",
  "bin/watchman-wait",
  "bin/watchman-replicate-subscription",
  "bin/watchmanctl",
]

build {
  dependencies = {
    "cmake.org" = "*"
    "curl.se" = "*"
    "facebook.com/fbthrift" = "*"
    "facebook.com/mvfst" = "*"
    "github.com/skystrife/cpptoml" = "*"
    "google.com/googletest" = "*"
    linux = {
      "gnu.org/gcc" = 14
    }
    "rust-lang.org" = "*"
  }
  script = [
    {
      run = [
        "mainfile=$(find . -name \"main.cpp\")",
        "echo \"Found main.cpp at: $mainfile\"",
        "oldline='auto state_dir = computeWatchmanStateDirectory(user);'",
        "newline='const char* env_state_dir = getenv(\"WATCHMAN_STATE_DIR\"); auto state_dir = env_state_dir ? env_state_dir : computeWatchmanStateDirectory(user);'",
        "sed -i \"s/$oldline/$newline/\" \"$mainfile\"",
        "cat $mainfile",
      ]
      working-directory = "watchman"
    },
    {
      run = <<EOT
if test -f Cargo.toml; then
  sed -i 's/watchman_client = { version = ".*", path/watchman_client = { path/' Cargo.toml
fi
EOT
      working-directory = "watchman/cli"
    },
    {
      if = ">=2026.6.8"
      run = [
        "for f in $(grep -R -l 'fmt::format' watchman); do",
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
      if = ">=2026.8.3"
      run = [
        "if test ! -f GlobPath.h; then",
        "curl -LO https://github.com/facebook/sapling/raw/refs/heads/main/eden/fs/utils/GlobPath.h",
        "fi",
      ]
      working-directory = "eden/fs/utils"
    },
    "cmake -S . -B build $CMAKE_ARGS -DCMAKE_C_FLAGS=\"$CFLAGS\" -DCMAKE_CXX_FLAGS=\"$CXXFLAGS\"",
    "cmake --build build",
    "cmake --install build",
    "mkdir -p {{prefix}}/var/run/watchman",
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
      "-DENABLE_EDEN_SUPPORT=ON",
      "-DWATCHMAN_VERSION_OVERRIDE={{version}}",
      "-DPython3_EXECUTABLE={{deps.python.org.prefix}}/bin/python",
      "-DUSE_SYS_PYTHON=OFF",
    ]

    darwin {
      CMAKE_ARGS = [
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-dead_strip_dylibs",
      ]
    }

    linux {
      CC = "gcc"
      CMAKE_ARGS = [
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-pie,-lstdc++",
      ]
      CXX = "g++"
      LD = "g++"
      LDFLAGS = "-Wl,-lpython{{deps.python.org.version.marketing}},-lstdc++"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/facebook/watchman/archive/refs/tags/{{version.tag}}.tar.gz"
}

runtime {

  env {
    WATCHMAN_STATE_DIR = "{{prefix}}/var/run/watchman"
  }
}

test {
  script = [
    <<EOT
if [ -f /etc/os-release ] && grep -q '^ID=arch' /etc/os-release; then
  echo "Arch Linux detected! Not currenlty testable."
  exit 0
fi
EOT
,
    "watchman --version",
    "watchman -v | grep {{version}}",
    "watchman watch $ARGS .",
    "kill $(cat pid)",
    "cat state | grep {{version}}",
  ]

  env {
    ARGS = [
      "--sockname=$PWD/sock",
      "--statefile=$PWD/state",
      "--logfile=$PWD/log",
      "--pidfile=$PWD/pid",
    ]
  }
}

versions {
  github = "facebook/watchman"
}
