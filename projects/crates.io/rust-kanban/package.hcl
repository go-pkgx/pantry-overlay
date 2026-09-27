dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/rust-kanban",
]
test = [
  "rust-kanban --help",
  "test \"$(rust-kanban --version)\" = \"rust-kanban {{version}}\"",
]

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/yashs662/rust_kanban/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "yashs662/rust_kanban/tags"
}
