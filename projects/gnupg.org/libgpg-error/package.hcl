provides = [
  "bin/gpg-error",
  "bin/gpg-error-config",
  "bin/gpgrt-config",
  "bin/yat2m",
]

build {
  script = [
    {
      if = ">=1.50"
      run = <<EOT
sed -i -e '/#include "gpgrt-int.h"/a\
\
#if defined (__APPLE__)\
extern char** environ;\
#endif' \
spawn-posix.c
EOT
      working-directory = "src"
    },
    "./configure --prefix={{prefix}} --enable-install-gpg-error-config",
    "make",
    "make check",
    "make install",
  ]
}

dependencies {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
}

distributable {
  strip-components = 1
  url = "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-{{version.raw}}.tar.gz"
}

test {
  script = "test \"$(gpg-error 56)\" = \"$OUTPUT\""

  env {
    OUTPUT = "56 = (0, 56) = (GPG_ERR_SOURCE_UNKNOWN, GPG_ERR_BAD_CERT_CHAIN) = (Unspecified source, Bad certificate chain)"
  }
}

versions {
  match = "/libgpg-error-\\d+\\.\\d+(\\.\\d+)?\\.tar\\.gz/"
  strip = [
    "/libgpg-error-/",
    "/.tar.gz/",
  ]
  url = "https://gnupg.org/ftp/gcrypt/libgpg-error/"
}
