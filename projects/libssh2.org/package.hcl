dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "^1.2"
}

build {
  script = <<EOT
./configure $ARGS
make --jobs {{ hw.concurrency }} install
EOT

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--with-openssl",
      "--with-libz",
      "--disable-examples-build",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://www.libssh2.org/download/libssh2-{{version}}.tar.gz"
}

test {
  fixture = <<EOT
#include <libssh2.h>
int main(void) {
  libssh2_exit();
  return 0;
}
EOT
  script = <<EOT
mv $FIXTURE b.c
cc b.c -lssh2
./a.out
EOT
}

versions {
  github = "libssh2/libssh2"
  strip = "/^libssh2-/"
}
