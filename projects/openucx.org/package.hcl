dependencies = {
  "github.com/linux-rdma/rdma-core" = "*"
  "linux/x86-64" = {
    "github.com/ROCm/ROCR-Runtime" = "*"
  }
  "zlib.net" = "^1.3"
}
platforms = [
  "linux",
]
provides = [
  "bin/ucx_info",
  "bin/ucx_perftest",
  "bin/ucx_read_profile",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "gnu.org/autoconf" = "*"
    "gnu.org/automake" = "*"
    "gnu.org/libtool" = "*"
    "gnu.org/m4" = "*"
  }
  env = {
    ARGS = [
      "--prefix={{prefix}}",
      "--libdir={{prefix}}/lib",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--disable-logging",
      "--disable-debug",
      "--disable-assertions",
      "--disable-params-check",
      "--without-java",
      "--without-go",
      "--without-cuda",
      "--with-verbs={{deps.github.com/linux-rdma/rdma-core.prefix}}",
    ]
    "linux/aarch64" = {
      ARGS = [
        "--without-rocm",
      ]
    }
    "linux/x86-64" = {
      ARGS = [
        "--with-rocm={{deps.github.com/ROCm/ROCR-Runtime.prefix}}",
      ]
    }
  }
  script = [
    "sed -i 's/-Wall -Werror/-Wall/' configure",
    "sed -i 's|^SUBDIRS = profiling iodemo$|SUBDIRS = profiling|' test/apps/Makefile.in",
    "./configure $ARGS",
    "make --jobs {{hw.concurrency}}",
    "make install",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/openucx/ucx/releases/download/v{{version}}/ucx-{{version}}.tar.gz"
}

test {
  script = [
    "ucx_info -v | grep -q \"Library version\"",
    {
      "ucx_info -d | grep -q \"Transport" = "posix\""
    },
    {
      "ucx_info -d | grep -q \"Transport" = "sysv\""
    },
    "test -f {{prefix}}/lib/ucx/libuct_ib.so",
    <<EOT
case "$(uname -m)" in
  x86_64) test -f {{prefix}}/lib/ucx/libuct_rocm.so ;;
  *) echo "no rocm transport on $(uname -m): ROCr is x86-64 only" ;;
esac
EOT
,
  ]
}

versions {
  github = "openucx/ucx"
}
