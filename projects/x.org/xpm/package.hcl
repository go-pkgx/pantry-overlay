dependencies = {
  "x.org/x11" = "*"
  "zlib.net" = "^1.2"
}

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "~0.29"
    "gnu.org/gettext" = "^1"
  }
  script = <<EOT
./configure \
  --prefix="{{prefix}}" \
  --sysconfdir="$SHELF"/etc \
  --localstatedir="$SHELF"/var \
  --disable-open-zfile
make --jobs {{ hw.concurrency }} install
EOT

  env {
    SHELF = "$${{pkgx.prefix}}/x.org"
  }
}

distributable {
  strip-components = 1
  url = "https://www.x.org/archive/individual/lib/libXpm-{{version}}.tar.gz"
}

test {
  fixture = <<EOT
#include "X11/Xlib.h"
#include "X11/xpm.h"

int main(int argc, char* argv[]) {
  XpmColor color;
  return 0;
}
EOT
  script = <<EOT
mv $FIXTURE test.c
cc test.c
./a.out
EOT
}

versions {
  match = "/libXpm-\\d+\\.\\d+\\.\\d+.tar.gz/"
  strip = [
    "/libXpm-/",
    "/.tar.gz/",
  ]
  url = "https://www.x.org/archive/individual/lib/"
}
