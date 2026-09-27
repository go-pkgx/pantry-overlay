dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/rad",
  "bin/git-remote-rad",
  "bin/rad-account",
  "bin/rad-auth",
  "bin/rad-checkout",
  "bin/rad-clone",
  "bin/rad-edit",
  "bin/rad-ens",
  "bin/rad-gov",
  "bin/rad-help",
  "bin/rad-init",
  "bin/rad-inspect",
  "bin/rad-issue",
  "bin/rad-ls",
  "bin/rad-merge",
  "bin/rad-patch",
  "bin/rad-path",
  "bin/rad-pull",
  "bin/rad-push",
  "bin/rad-remote",
  "bin/rad-reward",
  "bin/rad-rm",
  "bin/rad-self",
  "bin/rad-sync",
  "bin/rad-track",
  "bin/rad-untrack",
]
test = "rad --help"

build {
  dependencies = {
    "cmake.org" = "^3"
    "freedesktop.org/pkg-config" = "^0.29"
    "rust-lang.org/cargo" = "^0"
  }
  script = <<EOT
cargo install --locked --path . --root {{prefix}}
EOT
}

distributable {
  strip-components = 1
  url = "https://github.com/radicle-dev/radicle-cli/archive/refs/tags/v{{version}}.tar.gz"
}

versions {
  github = "radicle-dev/radicle-cli"
}
