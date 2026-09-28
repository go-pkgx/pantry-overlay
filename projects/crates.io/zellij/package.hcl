build {
  dependencies = {
    "openssl.org"         = "^3"
    "perl.org"            = "^5"
    "rust-lang.org"       = ">=1.60"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --root {{prefix}}"
}
