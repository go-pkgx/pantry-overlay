dependencies = {
  "openssl.org" = "^3"
}

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "gnu.org/autoconf" = 2
    "gnu.org/automake" = 1
    "gnu.org/libtool" = 2
  }
  script = [
    "./autogen.sh",
    "./configure $ARGS",
    "make V=1 --jobs {{ hw.concurrency }}",
    "make install",
    {
      run = "sed -i -e 's|{{deps.openssl.org.prefix}}|\\$${pcfiledir}/../../../../openssl.org/v{{deps.openssl.org.version.major}}|g' *.pc"
      working-directory = "{{prefix}}/lib/pkgconfig"
    },
  ]

  env {
    ARGS = [
      "--disable-debug-mode",
      "--prefix=\"{{prefix}}\"",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/libevent/libevent/releases/download/release-{{version}}-stable/libevent-{{version}}-stable.tar.gz"
}

test {
  fixture = <<EOT
#include <event2/event.h>
int main() {
  struct event_base *base;
  base = event_base_new();
  event_base_free(base);
  return 0;
}
EOT
  script = <<EOT
mv $FIXTURE $FIXTURE.c
cc $FIXTURE.c "-levent"
./a.out
EOT
}

versions {
  github = "libevent/libevent/tags"
  strip = [
    "/^release-/",
    "/-stable$/",
  ]
}
