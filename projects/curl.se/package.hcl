dependencies = {
  "curl.se/ca-certs" = "*"
  "nghttp2.org" = "*"
  "openssl.org" = "^3"
  "zlib.net" = "^1.2.11"
}
display-name = "cURL"
provides = [
  "bin/curl",
  "bin/curl-config",
]
test = [
  "curl -i pkgx.sh",
  "curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org",
]

build {
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--with-openssl",
      "--without-libpsl",
      "--with-ca-fallback",
      "--with-nghttp2",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://curl.se/download/curl-{{version}}.tar.bz2"
}

versions {
  github = "curl/curl/releases"
  ignore = [
    "/8\\.1[8-9]\\..*/",
    "/8\\.2\\d\\..*/",
    "/9\\.\\d+\\.\\d+/",
  ]
  strip = "/^curl /"
}
