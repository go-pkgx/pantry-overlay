dependencies = {
  "openssl.org" = "^3"
  "speex.org" = "*"
  "theora.org" = "*"
  "xiph.org/ogg" = "*"
  "xiph.org/vorbis" = "*"
}
provides = [
  "bin/shout",
]

build {
  dependencies = {
    darwin = {
      "curl.se" = "*"
      "gnu.org/patch" = "*"
    }
    "freedesktop.org/pkg-config" = "*"
    linux = {
      "gnu.org/gcc" = "*"
    }
  }
  script = [
    {
      if = "darwin"
      run = "curl -L \"$PATCH\" | patch"
    },
    "./configure $CONFIGURE_ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {
    CONFIGURE_ARGS = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--prefix=\"{{prefix}}\"",
      "--libdir=\"{{prefix}}/lib\"",
    ]
    PATCH = "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
  }
}

distributable {
  strip-components = 1
  url = "https://downloads.xiph.org/releases/libshout/libshout-{{version}}.tar.gz"
}

test {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    linux = {
      "gnu.org/gcc" = "*"
    }
  }
  script = [
    "pkg-config --modversion shout | grep {{version}}",
    "cc test.c -lshout -lssl -lcrypto -o test",
    "./test",
  ]

  env {

    linux {
      LDFLAGS = "-fPIC"
    }
  }
}

versions {
  match = "/libshout-\\d+\\.\\d+\\.\\d+\\.tar\\.gz/"
  strip = [
    "/^libshout-/",
    "/\\.tar\\.gz/",
  ]
  url = "https://ftp.osuosl.org/pub/xiph/releases/libshout/"
}
