provides = [
  "bin/iconv",
]
test = [
  "g++ -std=c++11 test.cc -liconv",
  "./a.out",
]

build {
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--enable-extra-encodings",
      "--enable-static",
    ]
  }
}

dependencies {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/libiconv/libiconv-{{version.marketing}}.tar.gz"
}

versions {
  match = "/libiconv-(\\d+\\.\\d+(\\.\\d+)?)\\.tar\\.gz/"
  strip = [
    "/libiconv-/",
    "/.tar.gz/",
  ]
  url = "https://ftp.gnu.org/gnu/libiconv/"
}
