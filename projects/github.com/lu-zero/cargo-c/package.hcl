dependencies = {
  "curl.se" = 8
  "libgit2.org" = "~1.7"
  "libssh2.org" = "*"
  "openssl.org" = "^3"
  "zlib.net" = "*"
}
provides = [
  "bin/cargo-capi",
  "bin/cargo-cbuild",
  "bin/cargo-cinstall",
  "bin/cargo-ctest",
]
test = "cargo-capi --version | grep {{version}}"

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "rust-lang.org" = "^1.70"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install $ARGS"

  env {
    ARGS = [
      "--root {{prefix}}",
      "--locked",
      "--path .",
    ]
    LIBGIT2_SYS_USE_PKG_CONFIG = 1
    LIBSSH2_SYS_USE_PKG_CONFIG = 1
    OPENSSL_DIR = "{{deps.openssl.org.prefix}}"
    OPENSSL_NO_VENDOR = 1
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/lu-zero/cargo-c/archive/v{{version}}.tar.gz"
}

versions {
  github = "lu-zero/cargo-c"
}
