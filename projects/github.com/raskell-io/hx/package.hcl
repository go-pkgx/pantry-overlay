companions = {
  "haskell.org" = "*"
  "haskell.org/cabal" = "*"
}
display-name = "hx"
provides = [
  "bin/hx",
]
test = [
  "hx --version | tee out",
  "grep {{version}} out",
  "hx doctor",
]

build {
  dependencies = {
    "openssl.org" = "^3"
    "rust-lang.org" = ">=1.85"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --root={{prefix}} --locked --path=crates/hx-cli"
}

distributable {
  strip-components = 1
  url = "https://github.com/raskell-io/hx/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "raskell-io/hx"
}
