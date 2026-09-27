dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}

build {
  dependencies = {
    "cmake.org" = "^3"
  }
  script = <<EOT
cmake .. $ARGS
make install
mv src/libssh.a {{ prefix }}/lib
EOT
  working-directory = "build"

  env {
    ARGS = [
      "-DBUILD_STATIC_LIB=ON",
      "-DWITH_SYMBOL_VERSIONING=OFF",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://www.libssh.org/files/{{ version.major }}.{{ version.minor }}/libssh-{{ version }}.tar.xz"
}

test {
  fixture = <<EOT
#include <libssh/libssh.h>
#include <stdlib.h>
int main()
{
  ssh_session my_ssh_session = ssh_new();
  if (my_ssh_session == NULL)
    exit(-1);
  ssh_free(my_ssh_session);
  return 0;
}
EOT
  script = <<EOT
mv $FIXTURE test.c
gcc test.c -lssh -o test
./test
EOT
}

versions {
  match = "/libssh-\\d+\\.\\d+\\.\\d+\\.tar\\.gz/"
  strip = [
    "/libssh-/",
    "/.tar.gz/",
  ]
  url = "https://git.libssh.org/projects/libssh.git/refs/tags"
}
