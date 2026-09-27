dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/dog",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = <<EOT
cargo install --locked --path . --root {{prefix}}
EOT
}

distributable {
  strip-components = 1
  url = "https://github.com/ogham/dog/archive/refs/tags/v{{ version }}.tar.gz"
}

test {
  script = [
    "test \"$(dog --version)\" = \"$OUTPUT\"",
  ]

  env {
    OUTPUT = "dog ● command-line DNS client\nv{{version}}\nhttps://dns.lookup.dog/"
  }
}

versions {
  github = "ogham/dog"
  strip = "/v/"
}
