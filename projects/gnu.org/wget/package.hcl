dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/wget",
]
test = "wget tea.xyz"

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
  }
  script = <<EOT
./configure $ARGS
make --jobs {{hw.concurrency}} install
EOT

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-pcre",
      "--disable-pcre2",
      "--without-libps1",
      "--without-included-regex",
      "--with-ssl=openssl",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/wget/wget-{{version}}.tar.gz"
}

versions {
  match = "/wget-(\\d+\\.\\d+(\\.\\d+)?)\\.tar\\.gz/"
  strip = [
    "/wget-/",
    "/.tar.gz/",
  ]
  url = "https://ftp.gnu.org/gnu/wget/"
}
