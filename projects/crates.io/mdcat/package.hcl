dependencies = {
  "curl.se" = 8
  "openssl.org" = "^3"
}
provides = [
  "bin/mdcat",
]
test = "mdcat --version"

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/swsnr/mdcat/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "swsnr/mdcat/tags"
  strip = "/mdcat-/"
}
