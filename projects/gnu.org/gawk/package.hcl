provides = [
  "bin/awk",
  "bin/gawk",
  "bin/gawk-{{version}}",
  "bin/gawkbug",
]

build {
  script = <<EOT
./configure --prefix={{ prefix }}
make --jobs {{ hw.concurrency }} install
EOT
  test = "make test"
}

dependencies {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/gawk/gawk-{{ version.raw }}.tar.gz"
}

test {
  script = "test \"$(echo \"Goodbye, cruel World\" | gawk '{ gsub(\"Goodbye, cruel\", \"Hello,\"); print }')\" = \"Hello, World\""
}

versions {
  match = "/gawk-\\d+\\.\\d+(\\.\\d+)?\\.tar\\.gz/"
  strip = [
    "/gawk-/",
    "/.tar.gz/",
  ]
  url = "https://ftp.gnu.org/gnu/gawk/"
}
