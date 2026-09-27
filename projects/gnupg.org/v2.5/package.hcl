dependencies = {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
  "gnu.org/readline" = "^8"
  "gnupg.org/libassuan" = 3
  "gnupg.org/libgcrypt" = "^1.11"
  "gnupg.org/libgpg-error" = "*"
  "gnupg.org/libksba" = "*"
  "gnupg.org/npth" = "*"
  "gnupg.org/pinentry" = "*"
  "gnutls.org" = "^3"
  "openldap.org" = "^2"
  "sourceware.org/bzip2" = "*"
  "sqlite.org" = "^3"
  "zlib.net" = "^1.1"
}
platforms = [
  "linux",
]
test = [
  "killall gpg-agent || true",
  "gpg --version | grep {{version}}",
  "gpgconf --launch keyboxd",
  "gpgconf --launch gpg-agent",
  "gpg --quick-gen-key --batch --passphrase \"\"  \"Testing\" default default never",
  "gpg --detach-sign test.txt",
  "gpg --verify test.txt.sig",
]

build {
  darwin = {
    "gnu.org/patch" = "*"
  }
  linux = {
    "gnu.org/gcc" = "*"
  }
  script = [
    {
      run = <<EOT
sed -i -e '/#include "exechelp.h"/a\
\
#if defined (__APPLE__)\
extern char** environ;\
#endif' \
exechelp-posix.c
EOT
      working-directory = "common"
    },
    {
      if = "darwin"
      run = "patch -p1 < props/proc-fix.diff"
    },
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make --jobs {{ hw.concurrency }} install",
    "cp props/gpgconf.ctl {{prefix}}/bin",
    {
      run = "sed -i \"s|{{prefix}}|\\$(dirname \\$0)/..|g\" gpg-wks-client"
      working-directory = "{{prefix}}/libexec"
    },
    {
      run = <<EOT
mkdir -p var/run etc/gnupg
chmod 700 etc/gnupg
EOT
      working-directory = "{{prefix}}"
    },
    {
      run = "cp props/gpg.conf {{prefix}}/etc/gnupg/gpg.conf"
    },
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--libdir={{prefix}}/lib",
      "--sysconfdir={{prefix}}/etc",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--with-pinentry-pgm={{deps.gnupg.org/pinentry.prefix}}/bin/pinentry",
    ]
    CFLAGS = "$CFLAGS -Wno-implicit-function-declaration"
  }
}

distributable {
  strip-components = 1
  url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-{{version}}.tar.bz2"
}

runtime {

  env {
    GNUPG_BUILD_ROOT = "{{prefix}}"
  }
}

versions {
  match = "/gnupg-((2\\.[5-9]\\d*)|([3-9]\\.\\d+)|([1-9]\\d+\\.\\d+))(\\.\\d+)?\\.tar\\.bz2/"
  strip = [
    "/gnupg-/",
    "/.tar.bz2/",
  ]
  url = "https://gnupg.org/ftp/gcrypt/gnupg/"
}
