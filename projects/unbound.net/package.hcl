dependencies = {
  "libexpat.github.io" = "^2"
  "openssl.org"        = "^3"
}

build {
  dependencies = {
    "github.com/westes/flex" = "*"
    "gnu.org/bison"          = "^3"
    "libexpat.github.io"     = "*"
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
