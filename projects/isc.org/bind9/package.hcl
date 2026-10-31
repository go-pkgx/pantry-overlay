dependencies = {
  "github.com/json-c/json-c" = 0.18
  "gnome.org/libxml2"        = 2.13
  "gnu.org/libidn2"          = 2.3
  "gnu.org/readline"         = 8.2
  "jemalloc.net"             = 5
  "liburcu.org"              = 0.15
  "libuv.org"                = 1.49
  linux = {
    "kernel.org/libcap" = "*"
  }
  "nghttp2.org"          = 1.57
  "openldap.org/liblmdb" = 0.9
  "openssl.org"          = "^3"
}

build {
  dependencies = {
    "cmake.org" = 3
    linux = {
      "nixos.org/patchelf" = "*"
    }
    "mesonbuild.com"  = 1
    "ninja-build.org" = "*"
  }
  script = [
    {
      if = "<9.21.10"
      run = [
        "./configure $ARGS",
        "make --jobs {{ hw.concurrency }} install",
      ]
    },
    {
      if = ">=9.21.10"
      run = [
        "meson setup build $MESON_ARGS",
        "meson compile -C build -j4",
        "meson install -C build",
      ]
    },
    {
      if = "linux"
      run = [
        "for BIN in bin/* sbin/* lib/*.so*; do",
        "patchelf --replace-needed {{deps.openldap.org/liblmdb.prefix}}/lib/pkgconfig/../../lib/liblmdb.so liblmdb.so $BIN",
        "ldd $BIN | grep liblmdb || true",
        "done",
      ]
      working-directory = "$${{prefix}}"
    },
  ]

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--with-json-c",
      "--with-libidn2={{deps.gnu.org/libidn2.prefix}}",
      "--with-openssl={{deps.openssl.org.prefix}}",
      "--with-lmdb={{deps.openldap.org/liblmdb.prefix}}",
    ]
    MESON_ARGS = [
      "--prefix=\"{{prefix}}\"",
    ]

    darwin {
      MACOSX_DEPLOYMENT_TARGET = 14
      MESON_ARGS = [
        "-Dnamed-lto=disabled",
      ]
    }
  }
}
