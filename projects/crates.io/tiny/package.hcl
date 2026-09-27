dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/tiny",
]
test = [
  "tiny --help",
  "tiny --version | grep \"{{version}}\"",
]

build {
  dependencies = {
    "rust-lang.org" = "^1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path crates/tiny --root {{prefix}} --locked"
}

distributable {
  strip-components = 1
  url = "https://github.com/osa1/tiny/archive/refs/tags/v{{version}}.tar.gz"
}

versions {
  github = "osa1/tiny"
  strip = "/^v/"
}
