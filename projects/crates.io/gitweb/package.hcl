dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/gitweb",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "rust-lang.org" = ">=1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/yoannfleurydev/gitweb/archive/refs/tags/v{{ version }}.tar.gz"
}

test {
  script = [
    "test \"$(gitweb --version)\" = \"gitweb {{version}}\"",
  ]
}

versions {
  github = "yoannfleurydev/gitweb"
  strip = "/v/"
}
