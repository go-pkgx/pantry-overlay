dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/click",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = <<EOT
cargo install --locked --path . --root {{prefix}}
EOT
}

distributable {
  strip-components = 1
  url = "https://github.com/databricks/click/archive/refs/tags/v{{ version }}.tar.gz"
}

test {
  script = [
    "test \"$(click --version)\" = \"Click {{version}}\"",
  ]
}

versions {
  github = "databricks/click"
  strip = "/v/"
}
