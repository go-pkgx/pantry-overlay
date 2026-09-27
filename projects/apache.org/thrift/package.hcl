dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "*"
}
provides = [
  "bin/thrift",
]
test = "thrift --version | grep {{version}}"

build {
  dependencies = {
    "boost.org" = "*"
    "freedesktop.org/pkg-config" = "*"
    "gnu.org/autoconf" = "*"
    "gnu.org/automake" = "*"
    "gnu.org/bison" = "*"
    "gnu.org/libtool" = "*"
  }
  env = {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-debug",
      "--disable-tests",
      "--prefix={{prefix}}",
      "--libdir={{prefix}}/lib",
      "--with-openssl={{deps.openssl.org.prefix}}",
      "--with-boost={{deps.boost.org.prefix}}",
      "--without-java",
      "--without-kotlin",
      "--without-python",
      "--without-py3",
      "--without-ruby",
      "--without-haxe",
      "--without-netstd",
      "--without-perl",
      "--without-php",
      "--without-php_extension",
      "--without-dart",
      "--without-erlang",
      "--without-go",
      "--without-d",
      "--without-nodejs",
      "--without-nodets",
      "--without-lua",
      "--without-rs",
      "--without-swift",
      "--with-qt5=no",
    ]
    CXXFLAGS = "$CXXFLAGS -Wno-unused-but-set-variable"
    PHP_PREFIX = "{{prefix}}"
    PY_PREFIX = "{{prefix}}"
    darwin = {
      MACOSX_DEPLOYMENT_TARGET = 11
    }
    "linux/aarch64" = {
      CXXFLAGS = "$CXXFLAGS -Wno-unused-but-set-variable -fPIC"
    }
  }
  script = [
    "cp {{deps.freedesktop.org/pkg-config.prefix}}/share/aclocal/pkg.m4 aclocal/",
    "./bootstrap.sh",
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]
}

distributable {
  strip-components = 1
  url = "https://dlcdn.apache.org/thrift/{{version}}/thrift-{{version}}.tar.gz"
}

versions {
  github = "apache/thrift"
}
