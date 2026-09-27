dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/fend",
]
test = "echo 'roll 1d20+8' | fend"

build {
  dependencies = {
    "rust-lang.org" = "^1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path cli --root {{prefix}} --locked"
}

distributable {
  strip-components = 1
  url = "https://github.com/printfn/fend/archive/refs/tags/v{{version}}.tar.gz"
}

versions {
  github = "printfn/fend"
  strip = "/^v/"
}
