dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/tea-gpg-wallet",
]
test = [
  "tea-gpg-wallet --help",
  "test \"$(tea-gpg-wallet --version)\" = 'tea-gpg-wallet {{version}}'",
  "tea-gpg-wallet find 95469C7E3DFC90B1 | tee out",
  "grep 95469C7E3DFC90B1 out",
  "grep '0xD7bAAE85D719C2e8e27A70194471ef4b6B253D33' out",
  "grep deployed out",
]

build {
  dependencies = {
    "rust-lang.org" = ">=1.89"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path cli --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/jhheider/tea-gpg-wallet/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "jhheider/tea-gpg-wallet"
}
