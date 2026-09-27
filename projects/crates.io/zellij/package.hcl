dependencies = {
  "curl.se" = 8
  "zlib.net" = "^1"
}
provides = [
  "bin/zellij",
]

build {
  dependencies = {
    "openssl.org" = "^3"
    "perl.org" = "^5"
    "rust-lang.org" = ">=1.60"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/zellij-org/zellij/archive/refs/tags/v{{version}}.tar.gz"
}

test {
  script = <<EOT
zellij --version
EOT
}

versions {
  github = "zellij-org/zellij"
  strip = "/v/"
}
