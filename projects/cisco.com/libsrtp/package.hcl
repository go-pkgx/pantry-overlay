dependencies = {
  "openssl.org" = "^3"
}

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    linux = {
      "gnu.org/gcc" = "*"
    }
  }
  script = [
    "./configure $CONFIGURE_ARGS",
    "make --jobs {{ hw.concurrency }} test",
    "make --jobs {{ hw.concurrency }} shared_library",
    "make --jobs {{ hw.concurrency }} install",
    "mkdir -p {{prefix}}/libexec",
    {
      run = "cp rtpw {{prefix}}/libexec/"
      working-directory = "test"
    },
  ]

  env {
    CONFIGURE_ARGS = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--prefix=\"{{prefix}}\"",
      "--libdir=\"{{prefix}}/lib\"",
      "--enable-openssl",
    ]

    linux {
      LDFLAGS = "-fPIC"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/cisco/libsrtp/archive/v{{version}}.tar.gz"
}

test {
  script = [
    "{{prefix}}/libexec/rtpw -l | grep {{version}}",
  ]
}

versions {
  github = "cisco/libsrtp"
}
