dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/surreal",
]
test = "surreal version"

build {
  dependencies = {
    "gnu.org/patch" = "*"
    "rust-lang.org" = ">=1.60"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      if = "^3.0.3"
      prop = <<EOT
1i #![recursion_limit = "256"]
EOT
      run = "sed -i -f $PROP lib.rs"
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

distributable {
  strip-components = 1
  url = "https://github.com/surrealdb/surrealdb/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "surrealdb/surrealdb"
}
