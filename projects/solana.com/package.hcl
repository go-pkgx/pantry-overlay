dependencies = {
  "openssl.org" = "^3"
  "protobuf.dev" = "^21"
  "zlib.net" = "^1.2"
}
provides = [
  "bin/solana",
  "bin/solana-keygen",
  "bin/solana-bench-streamer",
  "bin/solana-faucet",
  "bin/solana-keygen",
  "bin/solana-log-analyzer",
  "bin/solana-net-shaper",
  "bin/solana-stake-accounts",
  "bin/solana-tokens",
  "bin/solana-watchtower",
]
test = <<EOT
solana-keygen new --no-bip39-passphrase --no-outfile
solana-keygen --version | grep {{version}}
EOT

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "github.com/mikefarah/yq" = ">=4"
    linux = {
      "systemd.io" = "*"
    }
    "rust-lang.org" = ">=1.75<1.78"
    "rust-lang.org/cargo" = "<0.83"
  }
  env = {
    "linux/aarch64" = {
      PKG_CONFIG_PATH = "/usr/lib/aarch64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
    }
    "linux/x86-64" = {
      PKG_CONFIG_PATH = "/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
    }
  }
  script = [
    "yq -i '(.workspace.dependencies.ahash | select(. == \"=0.8.3\" or . == \"=0.8.4\")) = \"=0.8.5\"' Cargo.toml",
    <<EOT
for x in \
  cli \
  bench-streamer \
  faucet \
  keygen \
  log-analyzer \
  net-shaper \
  stake-accounts \
  sys-tuner \
  tokens \
  watchtower
do
  if test -d $x; then
    cargo install --root {{prefix}} --path $x
  fi
done
EOT
,
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/solana-labs/solana/archive/v{{version}}.tar.gz"
}

versions {
  github = "solana-labs/solana"
}
