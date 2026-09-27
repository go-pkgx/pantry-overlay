dependencies = {
  "libgit2.org" = "~1.7"
  "openssl.org" = "^3"
}
provides = [
  "bin/pixi",
]
test = "pixi --version | grep {{version}}"

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "rust-lang.org" = ">=1.60"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      if = "<0.54"
      run = "cargo install --locked --path . --root {{prefix}}"
    },
    {
      if = ">=0.54"
      run = "cargo install --locked --path crates/pixi --root {{prefix}}"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/prefix-dev/pixi/archive/refs/tags/v{{version}}.tar.gz"
}

versions {
  github = "prefix-dev/pixi"
}
