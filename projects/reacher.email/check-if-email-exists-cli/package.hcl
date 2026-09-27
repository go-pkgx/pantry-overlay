dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/check_if_email_exists",
]
test = "test \"$(check_if_email_exists --version)\" = \"check-if-email-exists-cli {{version}}\""

build {
  dependencies = {
    "github.com/mikefarah/yq" = ">=4"
    "perl.org" = "*"
    "rust-lang.org" = ">=1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      run = [
        "yq -i '.package.version = \"{{version}}\"' core/Cargo.toml",
        "yq -i '.package.version = \"{{version}}\"' cli/Cargo.toml",
        "yq -i '.package.version = \"{{version}}\"' backend/Cargo.toml",
      ]
      working-directory = ".."
    },
    {
      if = "^0.10"
      run = "yq -i '.dependencies[\"check-if-email-exists\"].features = [\"sentry\"]' Cargo.toml"
    },
    "cargo install --path . --root {{prefix}}",
  ]
  working-directory = "cli"
}

distributable {
  strip-components = 1
  url = "https://github.com/reacherhq/check-if-email-exists/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "reacherhq/check-if-email-exists"
}
