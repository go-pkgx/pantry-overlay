dependencies = {
  "gnu.org/gettext" = "^1"
  "gnu.org/m4" = "^1"
}
provides = [
  "bin/flex",
  "bin/flex++",
]

build {
  script = <<EOT
./configure $ARGS
make --jobs {{ hw.concurrency }} install
EOT

  env {
    ARGS = [
      "--prefix={{ prefix }}",
      "--with-pic",
      "--disable-bootstrap",
      "--enable-shared",
    ]

    darwin {
      MACOSX_DEPLOYMENT_TARGET = 10.6
    }

    linux {
      CPPFLAGS = "-D_GNU_SOURCE"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
}

test {
  script = <<EOT
flex test.flex
cc lex.yy.c -lfl
OUT=$(echo "Hello World" | ./a.out)
test "$OUT" = "Hello
World"
EOT
}

versions {
  github = "westes/flex"
  strip = "/^flex /"
}
