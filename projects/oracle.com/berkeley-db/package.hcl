dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/db_verify",
  "bin/db_upgrade",
  "bin/db_tuner",
  "bin/db_replicate",
  "bin/db_stat",
  "bin/db_recover",
  "bin/db_load",
  "bin/db_log_verify",
  "bin/db_printlog",
  "bin/db_dump",
  "bin/db_hotbackup",
  "bin/db_deadlock",
  "bin/db_checkpoint",
  "bin/db_convert",
  "bin/db_archive",
]
versions = [
  "18.1.40",
]

build {
  script = <<EOT
../dist/configure $ARGS
make install DOCLIST=license
rm -rf "{{prefix}}/docs"
EOT
  working-directory = "build_unix"

  env {
    ARGS = [
      "--disable-debug",
      "--disable-static",
      "--prefix={{prefix}}",
      "--enable-cxx",
      "--enable-compat185",
      "--enable-sql",
      "--enable-sql_codegen",
      "--enable-dbm",
      "--enable-stl",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://download.oracle.com/berkeley-db/db-{{version}}.tar.gz"
}

test {
  script = <<EOT
c++ fixture.cpp -ldb_cxx
./a.out
test -f test.db
EOT
}
