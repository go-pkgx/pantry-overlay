dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/nu",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "rust-lang.org" = "^1.60.0"
    "rust-lang.org/cargo" = "^0.87"
  }
  script = "cargo install --path=. --root={{prefix}} --locked"
  test = "cargo test"
}

distributable {
  strip-components = 1
  url = "https://github.com/nushell/nushell/archive/refs/tags/{{version}}.tar.gz"
}

test {
  script = [
    "dd if=/dev/zero count=1 bs=101 of=big",
    "dd if=/dev/zero count=1 bs=99 of=little",
    "OUT=$(nu -c 'ls | where size < 100b')",
    {
      fixture = <<EOT
╭───┬────────┬──────┬──────┬──────────╮
│ # │  name  │ type │ size │ modified │
├───┼────────┼──────┼──────┼──────────┤
│ 0 │ little │ file │ 99 B │ now      │
╰───┴────────┴──────┴──────┴──────────╯
EOT
      run = "test \"$OUT\" = \"$(cat $FIXTURE)\""
    },
    {
      if = "<0.75"
      run = "nu -c 'fetch https://pkgx.sh'"
    },
    {
      if = ">=0.75"
      run = "nu -c 'http get https://pkgx.sh'"
    },
  ]
}

versions {
  github = "nushell/nushell/tags"
}
