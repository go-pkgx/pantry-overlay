dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/drill",
]

build {
  dependencies = {
    "github.com/mikefarah/yq" = ">=4"
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "yq -i '.package.version = \"{{version}}\"' Cargo.toml",
    "cargo install --path . --root {{prefix}}",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/fcsonline/drill/archive/refs/tags/{{ version.tag }}.tar.gz"
}

test {
  script = [
    "test \"$(drill --version)\" = \"drill {{version}}\"",
    {
      fixture = {
        content = <<EOT
---

concurrency: 4
base: 'http://pkgx.sh'
iterations: 5
rampup: 2

plan:
  - name: Fetch root
    request:
      url: /
EOT
        extname = "yml"
      }
      run = "drill --benchmark $FIXTURE --stats --timeout 4"
    },
  ]

  env {
    RUST_BACKTRACE = 1
  }
}

versions {
  github = "fcsonline/drill"
}
