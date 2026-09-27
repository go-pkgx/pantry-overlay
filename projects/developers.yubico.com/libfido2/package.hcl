dependencies = {
  "github.com/PJK/libcbor" = 0
  linux = {
    "systemd.io" = "*"
  }
  "openssl.org" = "^3"
  "zlib.net" = 1
}
provides = [
  "bin/fido2-assert",
  "bin/fido2-cred",
  "bin/fido2-token",
]

build {
  dependencies = {
    "cmake.org" = 3
    "freedesktop.org/pkg-config" = "^0.29"
  }
  script = [
    "cmake .. $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]
  working-directory = "build"

  env {
    ARGS = [
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}\"",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://developers.yubico.com/libfido2/Releases/libfido2-{{ version }}.tar.gz"
}

test {
  fixture = <<EOT
#include <stddef.h>
#include <stdio.h>
#include <fido.h>
int main(void) {
  fido_init(FIDO_DEBUG);
  // Attempt to enumerate up to five FIDO/U2F devices. Five is an arbitrary number.
  size_t max_devices = 5;
  fido_dev_info_t *devlist;
  if ((devlist = fido_dev_info_new(max_devices)) == NULL)
    return 1;
  size_t found_devices = 0;
  int error;
  if ((error = fido_dev_info_manifest(devlist, max_devices, &found_devices)) == FIDO_OK)
    printf("FIDO/U2F devices found: %s\\n", found_devices ? "Some" : "None");
  fido_dev_info_free(&devlist, max_devices);
}
EOT
  script = [
    "mv $FIXTURE test.c",
    "cc test.c -o test -lfido2",
    "./test",
  ]
}

versions {
  github = "Yubico/libfido2/tags"
}
