dependencies = {
  "pcre.org/v2" = "*"
}
provides = [
  "bin/grep",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "gnu.org/grep" = "*"
    "pcre.org/v2" = "=10.47"
  }
  script = <<EOT
./configure $ARGS
make --jobs {{ hw.concurrency }} install
EOT

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-nls",
      "--mandir={{prefix}}/man",
      "--infodir={{prefix}}/info",
      "-with-packager=tea",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/grep/grep-{{version.raw}}.tar.gz"
}

test {
  fixture = "This line should be matched"
  script = "grep -P match $FIXTURE"
}

versions {
  match = "/grep-(\\d+\\.\\d+(\\.\\d+)?)\\.tar\\.gz/"
  strip = [
    "/grep-/",
    "/.tar.gz/",
  ]
  url = "https://ftp.gnu.org/gnu/grep/"
}
