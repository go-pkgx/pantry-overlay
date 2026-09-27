dependencies = {
  linux = {
    "x.org/xcb" = "*"
  }
  "openssl.org" = "^3"
}
provides = [
  "bin/dym",
]

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "cargo install --path . --root {{prefix}}",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/hisbaan/didyoumean/archive/refs/tags/v{{ version }}.tar.gz"
}

test {
  script = [
    "test \"$(dym --version)\" = \"didyoumean {{version}}\"",
  ]
}

versions {
  github = "hisbaan/didyoumean"
  strip = "/v/"
}
