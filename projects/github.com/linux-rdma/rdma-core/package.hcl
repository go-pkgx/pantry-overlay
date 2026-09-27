dependencies = {
  "github.com/thom311/libnl" = "^3"
}
platforms = [
  "linux",
]
provides = [
  "bin/ibv_devices",
  "bin/ibv_devinfo",
  "bin/rdma",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    "freedesktop.org/pkg-config" = "^0.29"
    "ninja-build.org" = "^1"
    "python.org" = "^3"
  }
  script = [
    "cmake -G Ninja $ARGS",
    "ninja -C build",
    "ninja -C build install",
  ]

  env {
    ARGS = [
      "-B build",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
      "-DCMAKE_INSTALL_LIBDIR=lib",
      "-DIN_PLACE=0",
      "-DNO_MAN_PAGES=1",
      "-DENABLE_STATIC=0",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/linux-rdma/rdma-core/releases/download/v{{version.raw}}/rdma-core-{{version.raw}}.tar.gz"
}

test {
  script = [
    "ibv_devices 2>&1 | grep -qE \"device|No IB devices found\"",
    "test -f {{prefix}}/lib/libibverbs.so",
    "test -f {{prefix}}/lib/librdmacm.so",
  ]
}

versions {
  github = "linux-rdma/rdma-core"
}
