dependencies = {
  "gnupg.org/gpgme" = "^1.13"
  "gnupg.org/libassuan" = "*"
  "gnupg.org/libgpg-error" = 1
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/versio",
]
test = "test \"$(versio --version)\" = \"versio {{version}}\""

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "rust-lang.org" = "^1.78"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/chaaz/versio/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "chaaz/versio"
}
