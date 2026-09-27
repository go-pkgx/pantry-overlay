dependencies = {
  "openssl.org" = "^3"
}
display-name = "Scryer Prolog"
provides = [
  "bin/scryer-prolog",
]
test = "scryer-prolog --goal \"test, halt\" test.pl | grep \"H,e,l,l,o\""

build {
  dependencies = {
    "rust-lang.org" = "^1.85"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --root '{{prefix}}'"
}

distributable {
  strip-components = 1
  url = "https://github.com/mthom/scryer-prolog/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "mthom/scryer-prolog"
}
