dependencies = {
  "curl.se/ca-certs" = "*"
  "openssl.org"      = "^3"
}

build {
  dependencies = {
    "curl.se/ca-certs"    = "*"
    "openssl.org"         = "^3"
    "rust-lang.org"       = ">=1.70"
    "rust-lang.org/cargo" = "*"
  }
  script = <<EOT
cargo install --locked --path . --root {{prefix}}
EOT
}
