provides = [
  "bin/make",
]

build {
  dependencies = {
    "gnu.org/m4" = 1
  }
  script = <<EOT
./configure --prefix={{ prefix }} --disable-dependency-tracking
make --jobs {{ hw.concurrency }} install
EOT
}

dependencies {
  darwin = {
    "gnu.org/gettext" = "*"
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/make/make-{{ version.raw }}.tar.gz"
}

interprets {
  args = [
    "make",
    "--file",
  ]
  filename = "Makefile"
}

test {
  fixture = "foo:\n\techo bar > $@"
  script = <<EOT
make --file=$FIXTURE
test "$(cat foo)" = bar
make --question --file=$FIXTURE
EOT

  env {
    MAKEFLAGS = "--file=$FIXTURE"
  }
}

versions {
  match = "/make-\\d+\\.\\d+(\\.\\d+)?\\.tar\\.gz/"
  strip = [
    "/make-/",
    "/.tar.gz/",
  ]
  url = "https://ftp.gnu.org/gnu/make/"
}
