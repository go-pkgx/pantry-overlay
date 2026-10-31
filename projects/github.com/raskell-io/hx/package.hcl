build {
  dependencies = {
    "openssl.org"         = "^3"
    "rust-lang.org"       = ">=1.85"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --root={{prefix}} --locked --path=crates/hx-cli"
}
