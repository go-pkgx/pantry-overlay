dependencies = {
  "openssl.org" = "^3"
}

build {
  dependencies = {
    "gnu.org/patch"       = "*"
    "rust-lang.org"       = ">=1.60"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      if                = "^3.0.3"
      prop              = <<EOT
1i #![recursion_limit = "256"]
EOT
      run               = "sed -i -f $PROP lib.rs"
      working-directory = "surrealdb/server/src"
    },
    "cargo install --path . --locked --root {{prefix}}",
  ]

  env {
    RUSTFLAGS = [
      "--cfg surrealdb_unstable",
    ]
    SURREAL_BUILD_METADATA = "pkgx"

    linux {
      RUSTFLAGS = [
        "-C linker=cc",
      ]
    }
  }
}
