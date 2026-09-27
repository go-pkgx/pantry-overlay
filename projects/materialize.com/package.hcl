dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/mz",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    "github.com/mikefarah/yq" = ">=4"
    "gnu.org/autoconf" = "*"
    "gnu.org/automake" = "*"
    linux = {
      "git-scm.org" = "^2"
      "llvm.org" = "<17"
    }
    "perl.org" = "*"
    "protobuf.dev" = 26.1
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      if = ">=0.106"
      run = "yq -i '.features.default -= [\"protobuf-src\"]' Cargo.toml"
      working-directory = "../build-tools"
    },
    "cargo install --locked --path . --root {{prefix}}",
  ]
  working-directory = "src/mz"

  env {
    PROTOC_INCLUDE = "{{ deps.protobuf.dev.prefix }}/include"

    linux {
      LD = "clang"
      OPENSSL_DIR = "{{ deps.openssl.org.prefix }}"
      OPENSSL_NO_VENDOR = true
      RUSTFLAGS = "-C link-arg=-Wl,--compress-debug-sections=none"
    }
  }
}

distributable {
  ref = "$${{ version.tag }}"
  url = "git+https://github.com/MaterializeInc/materialize"
}

test {
  script = [
    {
      if = "<0.69.1"
      run = "VERSION=0.1.3"
    },
    {
      if = ">=0.69.1<0.71"
      run = "VERSION=0.2.1"
    },
    {
      if = ">=0.71<0.75"
      run = "VERSION=0.2.2"
    },
    {
      if = ">=0.75<26.27.0"
      run = "VERSION=0.3.0"
    },
    {
      if = ">=26.27.0"
      run = "VERSION=0.3.1"
    },
    "test \"$(mz --version)\" = \"mz $VERSION\"",
  ]
}

versions {
  github = "MaterializeInc/materialize"
}
