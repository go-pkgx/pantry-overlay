dependencies = {
  "kerberos.org" = "*"
  linux = {
    "gnu.org/readline" = "*"
  }
  "openssl.org" = "^3"
  "unicode.org" = "^71"
  "zlib.net" = "^1"
}
test = [
  "cc libpq.c -lpq -o libpqtest",
  "test \"$(./libpqtest)\" = 'Connection to database attempted and failed'",
]

build {
  script = [
    "export CFLAGS=\"$(echo $CFLAGS | tr ' ' '\\n' | sed -e '/^-w$/d' | tr '\\n' ' ')\"",
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make -C src/bin install $DIRS",
    "make -C src/include install $DIRS",
    "make -C src/interfaces install $DIRS",
    "make -C src/common install $DIRS",
    "make -C src/port install $DIRS",
  ]

  dependencies {
    linux = {
      "github.com/westes/flex" = "*"
      "gnu.org/bison" = "*"
    }
  }

  env {
    ARGS = [
      "--disable-debug",
      "--prefix={{prefix}}",
      "--with-gssapi",
      "--with-openssl",
      "--libdir={{prefix}}/lib",
      "--includedir={{prefix}}/include",
    ]
    DIRS = [
      "libdir={{prefix}}/lib",
      "includedir={{prefix}}/include",
      "pkgincludedir={{prefix}}/include/postgresql",
      "includedir_server={{prefix}}/include/postgresql/server",
      "includedir_internal={{prefix}}/include/postgresql/internal",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.postgresql.org/pub/source/v{{version.raw}}/postgresql-{{version.raw}}.tar.bz2"
}

versions {
  match = "/v\\d+\\.\\d+(\\.\\d+)?\\//"
  strip = [
    "/^v/",
    "/\\/$/",
  ]
  url = "https://ftp.postgresql.org/pub/source"
}
