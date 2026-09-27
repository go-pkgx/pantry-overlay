dependencies = {
  "gnu.org/readline" = "*"
  "kerberos.org" = "*"
  "openssl.org" = "^3"
  "unixodbc.org" = "*"
}
provides = [
  "bin/bsqldb",
  "bin/bsqlodbc",
  "bin/datacopy",
  "bin/defncopy",
  "bin/freebcp",
  "bin/tdspool",
  "bin/tsql",
]
test = "tsql -C | grep {{version}}"

build {
  dependencies = {
    "cmake.org" = "*"
    "gnu.org/autoconf" = "*"
    "gnu.org/automake" = "*"
    "gnu.org/gettext" = "*"
    "gnu.org/libtool" = "*"
  }
  script = [
    {
      if = "<1.5.7"
      run = [
        "./configure $ARGS",
        "make --jobs {{ hw.concurrency }} install -i",
      ]
    },
    {
      if = ">=1.5.7"
      run = [
        "cmake -S . -B build $CMAKE_ARGS",
        "cmake --build build",
        "cmake --install build",
      ]
    },
  ]

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--mandir=\"{{prefix}}/man\"",
      "--sysconfdir=\"{{prefix}}/etc\"",
      "--with-unixodbc={{deps.unixodbc.org.prefix}}",
      "--with-openssl={{deps.openssl.org.prefix}}",
      "--enable-sybase-compat",
      "--enable-krb5",
      "--enable-odbc-wide",
    ]
    CMAKE_ARGS = [
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
      "-DCMAKE_INSTALL_SYSCONFDIR={{prefix}}/etc",
      "-DWITH_OPENSSL=ON",
      "-DENABLE_MSDBLIB=ON",
      "-DENABLE_KRB5=ON",
      "-DENABLE_ODBC_WIDE=ON",
    ]

    darwin {
      CFLAGS = "$CFLAGS -Wno-implicit-function-declaration -Wno-int-conversion"
      CMAKE_ARGS = [
        "-DCMAKE_EXE_LINKER_FLAGS=-liconv",
        "-DCMAKE_SHARED_LINKER_FLAGS=-liconv",
        "-DCMAKE_MODULE_LINKER_FLAGS=-liconv",
      ]
      LDFLAGS = "-liconv"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://www.freetds.org/files/stable/freetds-{{ version }}.tar.gz"
}

versions {
  match = "/freetds-\\d+\\.\\d+\\.\\d+\\.tar\\.gz/"
  strip = [
    "/^freetds-/",
    "/.tar\\.gz$/",
  ]
  url = "https://www.freetds.org/files/stable/"
}
