dependencies = {
  "libexpat.github.io" = "*"
  "openssl.org" = "^3"
  "sqlite.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/aria2c",
]
test = "aria2c -v\naria2c https://tea.xyz\naria2c --seed-time=0 \"magnet:?xt=urn:btih:d984f67af9917b214cd8b6048ab5624c7df6a07a&tr=https%3A%2F%2Facademictorrents.com%2Fannounce.php&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.opentrackr.org%3A1337%2Fannounce\""

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "gnupg.org/libgcrypt" = "^1"
    "gnupg.org/libgpg-error" = "^1"
  }
  script = <<EOT
./configure $ARGS
make --jobs {{hw.concurrency}}
make install
EOT

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--with-openssl",
      "--with-libgcrypt",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/aria2/aria2/releases/download/release-{{ version }}/aria2-{{ version }}.tar.xz"
}

versions {
  github = "aria2/aria2/releases"
  strip = "/^aria2 /"
}
