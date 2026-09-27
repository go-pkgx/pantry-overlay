dependencies = {
  "libpng.org" = "^1"
  "littlecms.com" = "^2"
  "simplesystems.org/libtiff" = "^4"
}
provides = [
  "bin/opj_compress",
  "bin/opj_decompress",
  "bin/opj_dump",
]

build {
  dependencies = {
    "cmake.org" = "^3"
  }
  script = <<EOT
cmake .. -DCMAKE_INSTALL_PREFIX={{prefix}} -DCMAKE_BUILD_TYPE=Release $LCMS_ARGS
make --jobs {{ hw.concurrency }} install
EOT
  working-directory = "build"

  env {
    LCMS_ARGS = ""

    darwin {
      LCMS_ARGS = [
        "-DLCMS2_INCLUDE_DIR={{deps.littlecms.com.prefix}}/include",
        "-DLCMS2_LIBRARY={{deps.littlecms.com.prefix}}/lib/liblcms2.dylib",
      ]
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/uclouvain/openjpeg/archive/v2.5.0.tar.gz"
}

test {
  fixture = <<EOT
#include <openjpeg.h>
int main () {
  opj_image_cmptparm_t cmptparm;
  const OPJ_COLOR_SPACE color_space = OPJ_CLRSPC_GRAY;
  opj_image_t *image;
  image = opj_image_create(1, &cmptparm, color_space);
  opj_image_destroy(image);
  return 0;
}
EOT
  script = <<EOT
mv $FIXTURE test.c
cc test.c -lopenjp2
./a.out
EOT
}

versions {
  github = "uclouvain/openjpeg/tags"
}
