dependencies = {
  "boost.org" = "^1.66"
  "gnu.org/readline" = "*"
  "libsodium.org" = "*"
  "openssl.org" = "^3"
  "unbound.net" = "^1.4"
  "zeromq.org" = "^4.2"
}
provides = [
  "bin/monero-wallet-rpc",
  "bin/monero-wallet-cli",
  "bin/monero-gen-trusted-multisig",
  "bin/monero-gen-ssl-cert",
  "bin/monerod",
  "bin/monero-blockchain-import",
  "bin/monero-blockchain-export",
  "bin/monero-blockchain-mark-spent-outputs",
  "bin/monero-blockchain-usage",
  "bin/monero-blockchain-ancestry",
  "bin/monero-blockchain-depth",
  "bin/monero-blockchain-stats",
  "bin/monero-blockchain-prune-known-spent-data",
  "bin/monero-blockchain-prune",
]
test = [
  "( yes '' | monero-wallet-cli --restore-deterministic-wallet --password brew-test --restore-height 1 --generate-new-wallet wallet --electrum-seed 'baptism cousin whole exquisite bobsled fuselage left scoop emerge puzzled diet reinvest basin feast nautical upon mullet ponies sixteen refer enhanced maul aztec bemused basin' --command address 2>&1 || true ) | tee wallet.address",
  "grep \"4BDtRc8Ym9wGzx8vpkQQvpejxBNVpjEmVBebBPCT4XqvMxW3YaCALFraiQibejyMAxUXB5zqn4pVgHVm3JzhP2WzVAJDpHf\" wallet.address",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    linux = {
      "llvm.org" = 20
    }
  }
  script = [
    "cmake -S .. $CMAKE_ARGS",
    "cmake --build .",
    "cmake --install .",
  ]
  working-directory = "build"

  env {
    CMAKE_ARGS = [
      "-DCMAKE_INSTALL_PREFIX={{ prefix }}",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DARCH=\"default\"",
      "-Wno-dev",
      "-DMANUAL_SUBMODULES=1",
    ]

    darwin {
      CMAKE_ARGS = [
        "-DSTATIC=ON",
      ]
    }
  }
}

distributable {
  strip-components = 1
  url = "https://downloads.getmonero.org/cli/monero-source-{{version.tag}}.tar.bz2"
}

versions {
  github = "monero-project/monero"
}
