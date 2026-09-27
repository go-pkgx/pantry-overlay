dependencies = {
  "curl.se" = ">=6.0"
  "developers.yubico.com/libfido2" = "^1"
  "facebook.com/zstd" = "^1"
  "libevent.org" = "^2"
  linux = {
    "gnu.org/gcc/libstdcxx" = "^14"
  }
  "lz4.org" = "^1"
  "openssl.org" = "^3"
  "protobuf.dev" = "^21"
  "thrysoee.dk/editline" = "^3"
  "unicode.org" = "^71"
  "zlib.net" = "^1.2"
}
distributable = [
  {
    strip-components = 1
    url = "https://cdn.mysql.com/Downloads/MySQL-{{version.marketing}}/mysql-boost-{{version}}.tar.gz"
  },
  {
    strip-components = 1
    url = "https://cdn.mysql.com/Downloads/MySQL-{{version.marketing}}/mysql-{{version}}.tar.gz"
  },
  {
    strip-components = 1
    url = "https://github.com/mysql/mysql-server/archive/refs/tags/mysql-{{version}}.tar.gz"
  },
]
provides = [
  "bin/mysql_client_test",
  "bin/my_print_defaults",
  "bin/myisam_ftdump",
  "bin/myisamchk",
  "bin/myisamlog",
  "bin/myisampack",
  "bin/mysql",
  "bin/mysql_config",
  "bin/mysql_config_editor",
  "bin/mysql_keyring_encryption_test",
  "bin/mysql_migrate_keyring",
  "bin/mysql_secure_installation",
  "bin/mysql_tzinfo_to_sql",
  "bin/mysqladmin",
  "bin/mysqlbinlog",
  "bin/mysqlcheck",
  "bin/mysqld",
  "bin/mysqld_multi",
  "bin/mysqld_safe",
  "bin/mysqldump",
  "bin/mysqldumpslow",
  "bin/mysqlimport",
  "bin/mysqlrouter",
  "bin/mysqlrouter_keyring",
  "bin/mysqlrouter_passwd",
  "bin/mysqlrouter_plugin_info",
  "bin/mysqlshow",
  "bin/mysqlslap",
  "bin/mysqltest",
  "bin/mysqltest_safe_process",
  "bin/mysqlxtest",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    "gnu.org/bison" = ">=3.0.4"
    linux = {
      "gnu.org/gcc" = "^14"
    }
  }
  env = {
    ARGS = [
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DFORCE_INSOURCE_BUILD=1",
      "-DCOMPILATION_COMMENT=pkgx",
      "-DINSTALL_DOCDIR=share/doc",
      "-DINSTALL_INCLUDEDIR=include",
      "-DINSTALL_INFODIR=share/info",
      "-DINSTALL_MANDIR=share/man",
      "-DINSTALL_MYSQLSHAREDIR=share",
      "-DINSTALL_PLUGINDIR=lib/plugin",
      "-DSYSCONFDIR=/etc",
      "-DWITH_SYSTEM_LIBS=ON",
      "-DWITH_EDITLINE=system",
      "-DWITH_ICU=system",
      "-DWITH_LIBEVENT=system",
      "-DWITH_LZ4=system",
      "-DWITH_PROTOBUF=system",
      "-DWITH_SSL=system",
      "-DWITH_ZLIB=system",
      "-DWITH_ZSTD=system",
      "-DWITH_UNIT_TESTS=OFF",
      "-DENABLED_LOCAL_INFILE=1",
      "-DWITH_INNODB_MEMCACHED=ON",
      "-DWITH_FIDO=system",
      "-DDOWNLOAD_BOOST=1",
      "-DWITH_BOOST=boost",
      "-DBISON_EXECUTABLE={{deps.gnu.org/bison.prefix}}/bin/bison",
    ]
    "linux/aarch64" = {
      ARGS = [
        "-DCMAKE_CXX_FLAGS=\"-mno-outline-atomics\"",
        "-DCMAKE_C_FLAGS=\"-mno-outline-atomics\"",
      ]
    }
  }
  script = [
    "sed -i -e 's/\\(STRING_APPEND.*moutline-atomics.*\\)/# \\1/' ../CMakeLists.txt",
    {
      if = ">=8.0.33<8.0.38"
      run = "export ARGS=\"$(echo $ARGS | sed 's/WITH_ZLIB=system/WITH_ZLIB=bundled/g')\""
    },
    {
      if = "^8.4"
      run = "export ARGS=\"$ARGS -DCMAKE_C_STANDARD=17\""
    },
    "cmake .. $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]
  working-directory = "build"
}

test {
  dependencies = {
    "gnu.org/coreutils" = "^9"
    "npmjs.com" = "*"
  }
  script = [
    "mkdir -p mysql tmp",
    "mysqld --no-defaults --initialize-insecure --user=$USER --datadir=$PWD/mysql --tmpdir=$PWD/tmp",
    "PORT=$(npx --yes get-port-cli | tail -n1)",
    "mysqld --no-defaults --user=$USER --datadir=$PWD/mysql --port=$PORT --tmpdir=$PWD/tmp &",
    "sleep 5",
    "mysql --port=$PORT --user=root --password= --execute='show databases;'",
    "mysqladmin --port=$PORT --user=root --password= shutdown",
  ]
}

versions {
  github = "mysql/mysql-server/tags"
  strip = "/^mysql-/"
}
