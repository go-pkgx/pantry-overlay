dependencies = {
  "gnome.org/libxml2" = "~2.13"
  "gnome.org/libxslt" = "*"
  "gnu.org/readline" = "*"
  "lz4.org" = "*"
  "openssl.org" = "^3"
  "unicode.org" = "^73"
  "zlib.net" = "*"
}
provides = [
  "bin/clusterdb",
  "bin/createdb",
  "bin/dropdb",
  "bin/dropuser",
  "bin/ecpg",
  "bin/initdb",
  "bin/pg_archivecleanup",
  "bin/pg_basebackup",
  "bin/pg_config",
  "bin/pg_controldata",
  "bin/pg_ctl",
  "bin/pg_dump",
  "bin/pg_dumpall",
  "bin/pg_isready",
  "bin/pg_receivewal",
  "bin/pg_recvlogical",
  "bin/pg_resetwal",
  "bin/pg_restore",
  "bin/pg_rewind",
  "bin/pg_test_fsync",
  "bin/pg_test_timing",
  "bin/pg_upgrade",
  "bin/pg_waldump",
  "bin/pgbench",
  "bin/postgres",
  "bin/psql",
  "bin/reindexdb",
  "bin/vacuumdb",
]
test = [
  {
    if = "linux"
    run = [
      "pg_config --sharedir",
      "pg_config --libdir",
      "pg_config --pkglibdir",
      "pg_config --pkgincludedir",
      "pg_config --includedir-server",
    ]
  },
  {
    if = "darwin"
    run = [
      "mkdir -p ./data",
      "initdb -D ./data",
      "pg_ctl -D ./data -l logfile start",
      "createdb test",
      "psql -c 'create table test (id int);' test",
      "dropdb test",
      "pg_ctl -D ./data stop",
      "rm -rf ./data",
    ]
  },
]

build {
  dependencies = {
    "github.com/westes/flex" = "^2.5.31"
    "gnu.org/bison" = "*"
    "perl.org" = "*"
  }
  script = [
    "export CFLAGS=\"$(echo $CFLAGS | tr ' ' '\\n' | sed -e '/^-w$/d' | tr '\\n' ' ')\"",
    "sed -i 's|\\([^\\t]*sgml.*\\)$|#\\1|' GNUmakefile.in doc/src/Makefile",
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install-world",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--with-ssl=openssl",
      "--with-lz4",
      "--with-libxml",
      "--with-libxslt",
    ]
    CC = "clang"
    CFLAGS = "$CFLAGS -Wno-incompatible-function-pointer-types"
    CXX = "clang++"
    LD = "clang"

    darwin {
      LDFLAGS = "$LDFLAGS -headerpad_max_install_names"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/postgres/postgres/archive/refs/tags/REL_{{version.major}}_{{version.minor}}.tar.gz"
}

versions {
  match = "/\"v\\d+\\.\\d+(\\.\\d+)?\\/\"/"
  strip = [
    "/\"v/",
    "/\\/\"/",
  ]
  url = "https://www.postgresql.org/ftp/source/"
}
