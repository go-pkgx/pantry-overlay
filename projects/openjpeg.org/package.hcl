dependencies = {
  "libpng.org"                = "^1"
  "littlecms.com"             = "^2"
  "simplesystems.org/libtiff" = "^4"
}

build {
  dependencies = {
    "cmake.org" = "^3"
  }
  script            = <<EOT
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
