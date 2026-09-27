dependencies = {
  "gnu.org/gettext" = "*"
  "gnu.org/libidn2" = "*"
  "gnu.org/readline" = "*"
  "invisible-island.net/ncurses" = "*"
  "libexpat.github.io" = "*"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
  "openssl.org" = "^3"
  "zlib.net" = "*"
}
provides = [
  "bin/lftp",
  "bin/lftpget",
]
test = "lftp -c \"open ftp.gnu.org; ls\""

build {
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  dependencies {
    linux = {
      "gnu.org/gcc" = 14
    }
  }

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--with-openssl=\"{{deps.openssl.org.prefix}}\"",
      "--with-readline=\"{{deps.gnu.org/readline.prefix}}\"",
      "--with-libidn2=\"{{deps.gnu.org/libidn2.prefix}}\"",
    ]

    darwin {
      CFLAGS = "$CFLAGS -Wno-implicit-function-declaration"
    }
  }
}

distributable {
  strip-components = 1
  url = "http://ftp.st.ryukoku.ac.jp/pub/network/ftp/lftp/lftp-{{ version }}.tar.xz"
}

versions {
  github = "lavv17/lftp"
}
