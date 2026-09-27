dependencies = {
  linux = {
    "curl.se" = "*"
  }
  "openssl.org" = "^3"
}
provides = [
  "bin/rustup",
  "bin/rustup-init",
]
test = [
  "rustup --version",
  "rustup default nightly",
]

build {
  dependencies = {
    "github.com/mikefarah/yq" = ">=4"
    "rust-lang.org" = "^1.85"
    "rust-lang.org/cargo" = "^0.86"
  }
  script = [
    {
      if = "darwin"
      run = "yq -i '.features.default -= [\"curl-backend\"]' Cargo.toml"
    },
    "cargo install --locked --path . --root {{prefix}}",
    {
      run = "ln -s rustup-init rustup"
      working-directory = "$${{prefix}}/bin"
    },
  ]

  env {
    RUSTUP_INIT_SKIP_PATH_CHECK = "yes"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/rust-lang/rustup/archive/{{version}}.tar.gz"
}

versions {
  github = "rust-lang/rustup/tags"
}
