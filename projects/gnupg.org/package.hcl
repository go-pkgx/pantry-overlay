build = {
  env = {
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
  "freedesktop.org/pkg-config" = "*"
  linux = {
    "gnu.org/gcc" = "*"
  }
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make --jobs {{ hw.concurrency }} install",
    "cp props/gpgconf.ctl {{prefix}}/bin",
    {
      run = <<EOT
sed -i.bak "s|{{prefix}}|\$(dirname \$0)/..|g" gpg-wks-client
rm gpg-wks-client.bak
EOT
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
}
dependencies = {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
  "gnu.org/readline" = "^8"
  "gnupg.org/libassuan" = 2
  "gnupg.org/libgcrypt" = "*"
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
provides = [
  "bin/gpg",
  "bin/gpg-agent",
  "bin/gpg-connect-agent",
  "bin/gpg-wks-server",
  "bin/gpgconf",
  "bin/gpgparsemail",
  "bin/gpgscm",
  "bin/gpgsm",
  "bin/gpgsplit",
  "bin/gpgtar",
  "bin/gpgv",
  "bin/kbxutil",
  "bin/watchgnupg",
]

distributable {
  strip-components = 1
  url = "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-{{version}}.tar.bz2"
}

runtime {

  env {
    GNUPG_BUILD_ROOT = "{{prefix}}"
  }
}

test {
  script = [
    "killall gpg-agent || true",
    "gpg --version | grep {{version}}",
    "gpg --quick-gen-key --batch --passphrase \"\"  \"Testing\" default default never",
    "gpg --detach-sign test.txt",
    "gpg --verify test.txt.sig",
  ]
}

versions {
  match = "/gnupg-(([01]\\.\\d+)|(2\\.[0-4]))(\\.\\d+)?\\.tar\\.bz2/"
  strip = [
    "/gnupg-/",
    "/.tar.bz2/",
  ]
  url = "https://gnupg.org/ftp/gcrypt/gnupg/"
}
