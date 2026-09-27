provides = [
  "bin/dy",
]
test = "test \"$(dy --version)\" = \"dynein {{version}}\""

build {
  dependencies = {
    "cmake.org" = 3
    linux = {
      "freedesktop.org/pkg-config" = "*"
      "openssl.org" = "*"
    }
    "rust-lang.org" = ">=1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

dependencies {
  linux = {
    "openssl.org" = "^3"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/awslabs/dynein/archive/refs/tags/v{{ version }}.tar.gz"
}

versions {
  github = "awslabs/dynein"
  strip = "/v/"
}
