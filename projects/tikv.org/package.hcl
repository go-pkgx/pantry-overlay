dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/tikv-server",
]
test = [
  "tikv-server --version | tee out",
  "grep {{version}} out",
]

build {
  dependencies = {
    "cmake.org" = "^3.12"
    linux = {
      "llvm.org" = "^18"
    }
    "protobuf.dev" = "*"
    "rust-lang.org/rustup" = "*"
  }
  script = [
    {
      run = "ln -sf {{deps.rust-lang.org/rustup.prefix}}/bin/rustup rustup"
      working-directory = "$HOME/.cargo/bin"
    },
    {
      run = "rustup default \"$(sed -n 's/^channel = \"\\(.*\\)\".*/\\1/p' $SRCROOT/rust-toolchain.toml)\""
    },
    {
      run = "ln -sf $HOME/.rustup/toolchains/*/bin/* ."
      working-directory = "$HOME/.cargo/bin"
    },
    {
      if = "linux"
      run = [
        "export LIBCLANG_PATH=\"$(llvm-config --libdir)\"",
        "export BINDGEN_EXTRA_CLANG_ARGS=\"--sysroot=/ -isystem /usr/include/$(uname -m)-linux-gnu\"",
      ]
    },
    "make release",
    "install -D target/release/tikv-server {{prefix}}/bin/tikv-server",
  ]

  env {
    OPENSSL_DIR = "$${{deps.openssl.org.prefix}}"
    OPENSSL_NO_VENDOR = "1"
    PATH = "$HOME/.cargo/bin:$PATH"
    ROCKSDB_SYS_SSE = "0"
    TIKV_FRAME_POINTER = 0
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/tikv/tikv/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "tikv/tikv"
}
