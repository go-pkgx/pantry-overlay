dependencies = {
  "apache.org/apr" = "^1"
  "apache.org/apr-util" = "^1"
  "bcrypt.sourceforge.net" = "^1"
  "curl.se" = "^8"
  darwin = {
    "sourceware.org/bzip2" = "^1"
    "zlib.net" = "^1"
  }
  "github.com/kkos/oniguruma" = "^6"
  "gnome.org/libxml2" = "*"
  "gnome.org/libxslt" = ">=1.1.0<1.1.43"
  "gnu.org/autoconf" = "^2"
  "gnu.org/bison" = "^3"
  "gnu.org/gcc/libstdcxx" = "^14"
  "gnu.org/gettext" = "^1"
  "gnu.org/gmp" = "^6"
  "gnu.org/libiconv" = "^1"
  "gnu.org/sed" = "^4"
  "google.com/webp" = "^1"
  "ijg.org" = "^9"
  "kerberos.org" = "^1"
  "libpng.org" = "^1"
  "libsodium.org" = "<1.0.19"
  "libzip.org" = "^1.9"
  "nghttp2.org" = "*"
  "openldap.org" = "^2"
  "openssl.org" = "*"
  "pcre.org/v2" = ">=10.30"
  "postgresql.org" = "*"
  "re2c.org" = "^3"
  "sourceware.org/libffi" = ">=3.4.7"
  "sqlite.org" = "^3"
  "thrysoee.dk/editline" = "^3"
  "unicode.org" = "^71"
}
provides = [
  "bin/pear",
  "bin/pecl",
  "bin/phar",
  "bin/php",
  "bin/php-cgi",
  "bin/php-config",
  "bin/phpdbg",
  "bin/phpize",
]
test = [
  "php --version | grep {{ version }}",
  "php -r 'echo \"Hello World!\\n\";'",
  "php -m | grep -w pdo_mysql",
  "php -m | grep -w pdo_pgsql",
]

build {
  dependencies = {
    darwin = {
      "tukaani.org/xz" = "*"
    }
    "freetype.org" = "*"
    "gnu.org/libtool" = "*"
  }
  env = {
    ARGS = [
      "--prefix={{prefix}}",
      "--enable-bcmath",
      "--enable-calendar",
      "--enable-dba",
      "--enable-exif",
      "--enable-ftp",
      "--enable-fpm",
      "--enable-gd",
      "--enable-intl",
      "--enable-mbregex",
      "--enable-mbstring",
      "--enable-mysqlnd",
      "--enable-pcntl",
      "--enable-phpdbg",
      "--enable-phpdbg-readline",
      "--enable-shmop",
      "--enable-soap",
      "--enable-sockets",
      "--enable-sysvmsg",
      "--enable-sysvsem",
      "--enable-sysvshm",
      "--with-pear",
      "--with-curl",
      "--with-external-pcre",
      "--with-ffi",
      "--with-gettext={{deps.gnu.org/gettext.prefix}}",
      "--with-gmp={{deps.gnu.org/gmp.prefix}}",
      "--with-iconv={{deps.gnu.org/libiconv.prefix}}",
      "--with-kerberos",
      "--with-layout=GNU",
      "--with-libxml",
      "--with-libedit",
      "--with-openssl",
      "--with-pdo-sqlite",
      "--with-pdo-mysql=mysqlnd",
      "--with-pdo-pgsql={{deps.postgresql.org.prefix}}",
      "--with-pic",
      "--with-sodium",
      "--with-sqlite3",
      "--with-xsl",
      "--with-zlib",
      "--disable-dtrace",
      "--without-ldap-sasl",
      "--without-ndbm",
      "--without-gdbm",
      "CC=gcc",
    ]
    darwin = {
      ARGS = [
        "--with-zip",
        "--enable-dtrace",
        "--with-ldap-sasl",
      ]
      CC = "clang"
      CXX = "clang++"
      LD = "/usr/bin/ld"
      LDFLAGS = "-Wl,-rpath,{{pkgx.prefix}},-headerpad_max_install_names"
    }
    "darwin/x86-64" = {
      CFLAGS = [
        "-fno-sanitize=all",
      ]
      CXXFLAGS = [
        "-fno-sanitize=all",
      ]
    }
    linux = {
      LDFLAGS = "-Wl,-rpath,{{pkgx.prefix}}"
    }
  }
  script = [
    {
      if = "linux"
      run = <<EOT
if command -v sudo >/dev/null; then
  SUDO=sudo
fi
EOT
    },
    {
      if = "linux"
      run = <<EOT
if [ ! -f /usr/bin/cpp ]; then
  $SUDO ln -s "{{deps.gnu.org/gcc.prefix}}/bin/cpp" /usr/bin/cpp
  FAKE_CPP=1
fi
EOT
    },
    "./configure $ARGS",
    "make install",
    {
      if = "linux"
      run = <<EOT
if [ -n "$FAKE_CPP" ]; then
  $SUDO rm /usr/bin/cpp
fi
EOT
    },
    {
      run = [
        "sed -i -e's|^prefix=.*|prefix=\"$(dirname \"$(dirname \"$0\")\")\"|g' -e's|^datarootdir=.*|datarootdir=\"$${prefix}/share\"|g' -e's|^ini_path=.*|ini_path=\"$${prefix}/etc\"|g' -e's|^extension_dir='\\''{{prefix}}\\(.*\\)'\\''|extension_dir=\"$${prefix}\\1\"|g' -e's|^SED=.*|SED=\"$(dirname \"$(dirname \"$(dirname \"$(dirname \"$0\")\")\")\")/gnu.org/sed/v4/bin/sed\"|g' -e's|#{{prefix}}#|#$(dirname \"$(dirname \"$0\")\")#|g' -e's|{{pkgx.prefix}}|$${prefix}/../..|g' php-config phpize",
        "fix-shebangs.ts \"{{prefix}}/bin/phar\"",
        "sed -i -e's|{{prefix}}|$(dirname \"$(dirname \"$0\")\")|g' pear peardev pecl",
      ]
      working-directory = "$${{prefix}}/bin"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://www.php.net/distributions/php-{{ version }}.tar.gz"
}

versions {
  github = "php/php-src/tags"
  strip = "/^php-/"
}
