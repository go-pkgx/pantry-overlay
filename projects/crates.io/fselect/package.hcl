dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/fselect",
]
test = "fselect size, path from ~"

build {
  dependencies = {
    "cmake.org" = "^3"
    "rust-lang.org" = "^1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/jhspetersson/fselect/archive/refs/tags/{{version}}.tar.gz"
}

versions {
  github = "jhspetersson/fselect"
}
