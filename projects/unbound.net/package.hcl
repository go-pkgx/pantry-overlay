dependencies = {
  "libexpat.github.io" = "^2"
  "openssl.org" = "^3"
}
provides = [
  "bin/unbound",
  "bin/unbound-anchor",
  "bin/unbound-checkconf",
  "bin/unbound-control",
  "bin/unbound-control-setup",
  "bin/unbound-host",
]

build {
  dependencies = {
    "github.com/westes/flex" = "*"
    "gnu.org/bison" = "^3"
    "libexpat.github.io" = "*"
  }
  script = <<EOT
./configure $ARGS
make -j {{ hw.concurrency }} install

cd {{prefix}}/bin
sed -i.bak -e "s|$PKGX_DIR/|\$PKGX_DIR/|g" unbound-control-setup
rm unbound-control-setup.bak
EOT

  env {
    ARGS = [
      "--prefix={{ prefix }}",
      "--sbindir={{ prefix }}/bin",
      "--with-ssl={{ deps.openssl.org.prefix }}",
      "--with-libexpat={{ deps.libexpat.github.io.prefix }}",
    ]
    CFLAGS = "-Werror=implicit-function-declaration"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/NLnetLabs/unbound/archive/refs/tags/release-{{ version }}.tar.gz"
}

test {
  script = [
    "unbound-control-setup -d .",
    {
      if = "darwin"
      run = "exit 0"
    },
    "OUT=\"$(unbound-host tea.xyz)\"",
    "grep \"$TEST1\" <<< \"$OUT\"",
    "grep \"$TEST2\" <<< \"$OUT\"",
  ]

  env {
    TEST1 = "tea.xyz has address"
    TEST2 = "tea.xyz mail is handled by"
  }
}

versions {
  github = "NLnetLabs/unbound/tags"
  strip = "/^release-/"
}
