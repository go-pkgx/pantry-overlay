dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/replibyte",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "rust-lang.org" = ">=1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
  working-directory = "replibyte"
}

distributable {
  strip-components = 1
  url = "https://github.com/Qovery/Replibyte/archive/refs/tags/v{{ version }}.tar.gz"
}

test {
  script = [
    "test \"$(replibyte --version)\" = \"replibyte {{version}}\"",
  ]
}

versions {
  github = "Qovery/Replibyte"
  strip = "/v/"
}
