dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/spacetime",
]
versions = [
  "2023.12.8",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    "freedesktop.org/pkg-config" = "^0.29"
    "perl.org" = "*"
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = <<EOT
cargo install --locked --path . --root {{prefix}}
EOT
  working-directory = "crates/cli"

  env {

    linux {
      OPENSSL_DIR = "{{ deps.openssl.org.prefix }}"
      OPENSSL_NO_VENDOR = true
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/clockworklabs/SpacetimeDB/archive/refs/tags/v0.8.0-beta.tar.gz"
}

test {
  script = [
    "spacetime --help",
  ]
}
