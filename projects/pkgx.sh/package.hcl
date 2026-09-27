display-name = "pkgx"
provides = [
  "bin/pkgx",
]
test = "test \"$(pkgx --version)\" = \"pkgx {{ version }}\""

build {
  dependencies = {
    "deno.land" = "~2"
    "perl.org" = 5
    "rust-lang.org" = "^1.56"
  }
  env = {
    linux = {
      AR = "llvm-ar"
      LZMA_API_STATIC = 1
    }
    "linux/aarch64" = {
      DENORT_BIN = "{{deps.deno.land.prefix}}/bin/denort"
    }
  }
  script = [
    {
      if = "<2"
      run = "deno task --config \"$SRCROOT\"/deno.jsonc compile"
      working-directory = "$${{prefix}}/bin"
    },
    {
      if = ">=2"
      run = [
        "cargo install --path crates/cli --root \"{{prefix}}\"",
        "strip '{{prefix}}/bin/pkgx'",
      ]
    },
  ]
  skip = "fix-patchelf"
}

dependencies {
  darwin = {
    "tukaani.org/xz" = "^5"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/pkgxdev/pkgx/releases/download/v{{ version }}/pkgx-{{ version }}.tar.xz"
}

versions {
  github = "pkgxdev/pkgx"
}
