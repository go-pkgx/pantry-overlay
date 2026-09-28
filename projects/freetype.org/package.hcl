dependencies = {
  "github.com/google/brotli" = "*"
  "libpng.org"               = 1
  "sourceware.org/bzip2"     = 1
  "zlib.net"                 = 1
}

build {
  dependencies = {
    "cmake.org"                  = "*"
    "freedesktop.org/pkg-config" = "^0.29"
  }
  script = [
    "cmake .. $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]
  working-directory = "build"

  env {
    ARGS = [
      "-DBUILD_SHARED_LIBS=true",
      "-DCMAKE_INSTALL_PREFIX=\"{{ prefix }}\"",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DFT_REQUIRE_ZLIB=TRUE",
      "-DFT_REQUIRE_BZIP2=TRUE",
      "-DFT_REQUIRE_PNG=TRUE",
      "-DFT_REQUIRE_BROTLI=TRUE",
    ]
  }
}
