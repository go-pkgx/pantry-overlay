dependencies = {
  "facebook.com/zstd"             = "^1"
  "github.com/besser82/libxcrypt" = "^4"
  "gnome.org/libxml2"             = "~2.13"
  "invisible-island.net/ncurses"  = "^6"
  "openssl.org"                   = "^3"
  "pcre.org/v2"                   = "^10"
  "sourceware.org/bzip2"          = "^1"
  "zlib.net"                      = "^1"
}

build {
  dependencies = {
    "cmake.org"                  = "*"
    "freedesktop.org/pkg-config" = "*"
    "git-scm.org"                = "*"
    "gnu.org/bison"              = "*"
    "gnu.org/coreutils"          = "*"
    "groonga.org"                = 15
    linux = {
      "fmt.dev" = "^9"
    }
  }
  script = [
    "git submodule update --init --recursive",
    "rm -rf storage/mroonga/vendor/groonga",
    {
      if  = ">=11.3.2"
      run = <<EOT
if test "{hw.platform}" = "darwin"; then
  sed -i 's/OS_DATA_FILE_NO_O_DIRECT/OS_DATA_FILE/g' \
    storage/innobase/include/os0file.h \
    storage/innobase/fil/fil0fil.cc \
    storage/innobase/os/os0file.cc \
    extra/mariabackup/xtrabackup.cc
fi
EOT
    },
    "cmake -S . -B build $CMAKE_ARGS",
    "cmake --build build",
    "cmake --install build",
    {
      run = [
        "mkdir my.cnf.d",
        "sed -i 's|!includedir /etc/my.cnf.d|!includedir {{ prefix }}/etc/my.cnf.d|' my.cnf",
      ]
      working-directory = "$${{ prefix }}/etc"
    },
    {
      run               = "ln -s ../scripts/mysql_install_db ."
      working-directory = "$${{ prefix }}/bin"
    },
    {
      run = [
        "sed -i 's|\\(PATH=\"\\)|\\1{{ prefix }}/bin:|' mysql.server",
        "ln -s ../support-files/mysql.server ../bin/",
      ]
      working-directory = "$${{ prefix }}/support-files"
    },
    {
      run               = "mv ../bin/wsrep_sst_common ."
      working-directory = "$${{ prefix }}/libexec"
    },
    {
      run               = "sed -i 's|$(dirname \"$0\")/wsrep_sst_common|$(dirname \"$0\")/../libexec/wsrep_sst_common|g' wsrep_sst_mysqldump wsrep_sst_rsync wsrep_sst_mariabackup"
      working-directory = "$${{ prefix }}/bin"
    },
  ]

  env {
    CMAKE_ARGS = [
      "-DCMAKE_INSTALL_PREFIX={{ prefix }}",
      "-DMYSQL_DATADIR={{ prefix }}/var/mysql",
      "-DINSTALL_SYSCONFDIR=etc",
      "-DINSTALL_INCLUDEDIR=include",
      "-DINSTALL_MANDIR=share/man",
      "-DINSTALL_DOCDIR=share/doc/mariadb",
      "-DINSTALL_INFODIR=share/info",
      "-DINSTALL_MYSQLSHAREDIR=share/mysql",
      "-DWITH_LIBFMT=bundled",
      "-DWITH_SSL=system",
      "-DWITH_UNIT_TESTS=OFF",
      "-DDEFAULT_CHARSET=utf8mb4",
      "-DDEFAULT_COLLATION=utf8mb4_general_ci",
      "-DCOMPILATION_COMMENT=made_by_tea",
      "-DPLUGIN_ROCKSDB=NO",
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
    ]

    linux {
      CC  = "clang"
      CXX = "clang++"
      LD  = "clang"
    }
  }
}
