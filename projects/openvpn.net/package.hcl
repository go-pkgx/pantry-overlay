dependencies = {
  linux = {
    "github.com/thom311/libnl" = "*"
    "sourceforge.net/net-tools" = "*"
  }
  "lz4.org" = "^1.9"
  "oberhumer.com/lzo" = "^2.10"
  "openssl.org" = "^3"
}
platforms = [
  "darwin",
]
provides = [
  "bin/openvpn",
]
test = "openvpn --show-ciphers"

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
  }
  script = <<EOT
./configure $ARGS
make --jobs {{ hw.concurrency }} install
EOT

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--with-crypto-library=openssl",
      "--disable-pkcs11",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://swupdate.openvpn.org/community/releases/openvpn-{{version}}.tar.gz"
}

versions {
  match = "_/community/releases/openvpn-\\d+\\.\\d+\\.\\d+\\.tar\\.gz/"
  strip = [
    "_/community/releases/openvpn-_",
    "/.tar.gz/",
  ]
  url = "https://openvpn.net/community-downloads/"
}
