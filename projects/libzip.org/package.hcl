dependencies = {
  darwin = {
    "sourceware.org/bzip2" = ">=1.0.8"
    "tukaani.org/xz" = ">=5.2.7"
    "zlib.net" = ">=1.2.13"
  }
  "facebook.com/zstd" = ">=1.5.0"
  linux = {
    "openssl.org" = "^3"
  }
}
provides = [
  "bin/zipcmp",
  "bin/zipmerge",
  "bin/ziptool",
]

build {
  dependencies = {
    "cmake.org" = ">=3.24"
  }
  script = <<EOT
cmake . $ARGS
cmake --build .
cmake --install .
EOT

  env {
    ARGS = [
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}\"",
      "-DBUILD_REGRESS=OFF",
      "-DBUILD_EXAMPLES=OFF",
      "-DENABLE_GNUTLS=OFF",
      "-DENABLE_MBEDTLS=OFF",
    ]

    darwin {
      ARGS = [
        "-DENABLE_OPENSSL=OFF",
      ]
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/nih-at/libzip/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  script = <<EOT
ziptool -n foobar.zip add foo.txt bar
out=$(ziptool foobar.zip cat 0)
test "$out" = "bar"
EOT
}

versions {
  github = "nih-at/libzip"
  strip = "/^libzip /"
}
