dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/git-trim",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "rust-lang.org" = ">=1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --root {{prefix}}"
}

distributable {
  ref = "v{{ version }}"
  url = "git+https://github.com/foriequal0/git-trim"
}

test {
  script = [
    "test \"$(git-trim --version)\" = \"git-trim {{version}}\"",
  ]
}

versions {
  github = "foriequal0/git-trim"
  strip = "/v/"
}
