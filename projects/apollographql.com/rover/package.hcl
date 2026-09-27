dependencies = {
  "libgit2.org" = "~1.7"
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/rover",
]
test = "test \"$(rover --version)\" = \"Rover {{version}}\""

build {
  dependencies = {
    "github.com/mikefarah/yq" = ">=4"
    linux = {
      "perl.org" = "^5"
    }
    "rust-lang.org" = ">=1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "yq -i '.package.version = \"{{ version }}\"' Cargo.toml",
    "cargo install --locked --path . --root {{prefix}}",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/apollographql/rover/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "apollographql/rover"
}
