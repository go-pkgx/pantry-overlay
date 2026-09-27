dependencies = {
  "git-scm.org" = "^2"
  "libgit2.org" = "~1.7"
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/gitopolis",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0"
    "gnu.org/make" = "*"
    "rust-lang.org" = "^1.70"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --root {{prefix}} --path ."
}

distributable {
  strip-components = 1
  url = "https://github.com/rustworkshop/gitopolis/archive/refs/tags/v{{version}}.tar.gz"
}

test {
  fixture = <<EOT
[[repos]]
path = "cli"
tags = ["cli"]
[repos.remotes.origin]
name = "origin"
url = "https://github.com/pkgxdev/pkgx"

[[repos]]
path = "lib"
tags = ["cli", "lib"]
[repos.remotes.origin]
name = "origin"
url = "https://github.com/pkgxdev/libpkgx"

[[repos]]
path = "docs"
tags = ["docs"]
[repos.remotes.origin]
name = "origin"
url = "https://github.com/pkgxdev/brewkit"
EOT
  script = [
    "cp $FIXTURE .gitopolis.toml",
    "gitopolis clone",
    "test -f cli/README.md",
    "test -f lib/README.md",
    "test -f docs/README.md",
  ]
}

versions {
  github = "rustworkshop/gitopolis"
  strip = "/^v/"
}
