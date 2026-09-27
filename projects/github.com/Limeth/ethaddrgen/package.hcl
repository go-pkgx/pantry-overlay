dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/ethaddrgen",
]
test = [
  "test \"$(ethaddrgen --version)\" = \"ethaddrgen {{version}}\"",
  "ethaddrgen 7ea",
]

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/Limeth/ethaddrgen/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "Limeth/ethaddrgen"
}
