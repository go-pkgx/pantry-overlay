dependencies = {
  "libgit2.org" = "~1.7"
  "openssl.org" = "^3"
  "perl.org" = "*"
  "zlib.net" = "^1"
}
provides = [
  "bin/gitui",
]
test = "gitui --version"

build {
  dependencies = {
    "cmake.org" = 3
    "rust-lang.org" = "^1.78"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --path . --locked --root {{prefix}}"

  env {

    linux {
      AR = "llvm-ar"
      OPENSSL_DIR = "{{ deps.openssl.org.prefix }}"
      OPENSSL_NO_VENDOR = true
      RUSTFLAGS = "-C linker=cc"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/extrawurst/gitui/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "extrawurst/gitui/tags"
}
