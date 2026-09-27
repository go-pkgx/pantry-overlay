dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/rucola",
]
test = "test \"$(rucola --version)\" = \"rucola-notes {{version}}\""

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/Linus-Mussmaecher/rucola/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "Linus-Mussmaecher/rucola"
}
