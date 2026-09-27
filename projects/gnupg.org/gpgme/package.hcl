dependencies = {
  "gnupg.org/libassuan" = "^2"
  "gnupg.org/libgpg-error" = "^1"
}
provides = [
  "bin/gpgme-config",
  "bin/gpgme-json",
  "bin/gpgme-tool",
]
test = "test \"$(gpgme-config --version)\" = \"{{version}}\""

build {
  dependencies = {
    "gnupg.org" = "*"
    "gnupg.org/libassuan" = "^2.0.2"
    "gnupg.org/libgpg-error" = "^1.11"
  }
  script = [
    "./configure $ARGS",
    "make -j {{hw.concurrency}}",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--with-libassuan-prefix={{deps.gnupg.org/libassuan.prefix}}",
      "--with-libgpg-error-prefix={{deps.gnupg.org/libgpg-error.prefix}}",
      "--disable-gpg-test",
      "--disable-glibtest",
      "--disable-gpgconf-test",
      "--disable-gpg-test",
      "--disable-gpgsm-test",
      "--disable-g13-test",
    ]
    CFLAGS = "$CFLAGS -Wno-implicit-function-declaration"
    CXXFLAGS = "$CXXFLAGS -std=c++14"

    linux {
      LDFLAGS = "$LDFLAGS -Wl,--allow-shlib-undefined"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://gnupg.org/ftp/gcrypt/gpgme/gpgme-{{version.raw}}.tar.bz2"
}

versions {
  match = "/gpgme-\\d+\\.\\d+(\\.\\d+)?\\.tar\\.bz2/"
  strip = [
    "/gpgme-/",
    "/.tar.bz2/",
  ]
  url = "https://gnupg.org/ftp/gcrypt/gpgme/"
}
