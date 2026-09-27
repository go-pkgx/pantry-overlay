provides = [
  "bin/kaspad",
  "bin/kaspa-cli",
]
test = [
  "(kaspad --version || true) | grep \"{{version}}\"",
]

build {
  dependencies = {
    "abseil.io" = "^20250127"
    "curl.se" = "*"
    "protobuf.dev" = "*"
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "cargo install --path kaspad --locked --root {{prefix}} --features=heap",
    "cargo install --path cli --locked --root {{prefix}}",
  ]
}

dependencies {
  linux = {
    "openssl.org" = "^3"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/kaspanet/rusty-kaspa/archive/refs/tags/v{{ version }}.tar.gz"
}

versions {
  github = "kaspanet/rusty-kaspa/tags"
  strip = "/v/"
}
