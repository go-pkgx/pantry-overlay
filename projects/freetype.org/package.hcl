dependencies = {
  "github.com/google/brotli" = "*"
  "libpng.org" = 1
  "sourceware.org/bzip2" = 1
  "zlib.net" = 1
}

build {
  dependencies = {
    "cmake.org" = "*"
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

distributable {
  strip-components = 1
  url = "https://download.savannah.gnu.org/releases/freetype/freetype-{{ version }}.tar.gz"
}

test {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
  }
  fixture = <<EOT
#include <ft2build.h>
#include FT_FREETYPE_H

FT_Library  library;

int main() {
  return FT_Init_FreeType( &library );
}
EOT
  script = <<EOT
mv $FIXTURE test.c
cc -o test test.c $(pkg-config --cflags --libs freetype2)
./test
EOT
}

versions {
  match = "/freetype-(\\d+\\.\\d+(\\.\\d+)?)\\.tar\\.gz/"
  strip = [
    "/freetype-/",
    "/.tar.gz/",
  ]
  url = "https://download.savannah.gnu.org/releases/freetype/"
}
