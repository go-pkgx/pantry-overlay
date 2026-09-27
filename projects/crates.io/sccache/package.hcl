dependencies = {
  "curl.se/ca-certs" = "*"
  "openssl.org" = "^3"
}
provides = [
  "bin/sccache",
]

build {
  dependencies = {
    "curl.se/ca-certs" = "*"
    "openssl.org" = "^3"
    "rust-lang.org" = ">=1.70"
    "rust-lang.org/cargo" = "*"
  }
  script = <<EOT
cargo install --locked --path . --root {{prefix}}
EOT
}

distributable {
  strip-components = 1
  url = "https://github.com/mozilla/sccache/archive/refs/tags/v{{ version }}.tar.gz"
}

test {
  script = [
    "test \"$(sccache --version)\" = \"sccache {{version}}\"",
  ]
}

versions {
  github = "mozilla/sccache"
  strip = "/v/"
}
