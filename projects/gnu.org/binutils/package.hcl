dependencies = {
  "facebook.com/zstd" = "^1"
}
distributable = [
  {
    strip-components = 1
    url = "https://ftp.gnu.org/gnu/binutils/binutils-with-gold-{{ version.raw }}.tar.gz"
  },
  {
    strip-components = 1
    url = "https://ftp.gnu.org/gnu/binutils/binutils-{{ version.raw }}.tar.gz"
  },
  {
    strip-components = 1
    url = "https://ftp.gnu.org/gnu/binutils/binutils-{{ version.raw }}.tar.bz2"
  },
]

build {
  dependencies = {
    "facebook.com/zstd" = "*"
    "gnu.org/bison" = "*"
    "gnu.org/texinfo" = "*"
    linux = {
      "gnu.org/gcc" = "*"
      "perl.org" = "~5.42"
    }
  }
  script = [
    {
      if = "<2.29"
      run = "if test -f zutil.h; then sed -i '/define fdopen(fd,mode) NULL/d' zutil.h; fi"
      working-directory = "zlib"
    },
    {
      if = "<2.29"
      prop = <<EOT
/#include "gold-threads.h"/i\
#include <string>
EOT
      run = "if test -f errors.h; then sed -i -f $PROP errors.h; fi"
      working-directory = "gold"
    },
    {
      if = ">=2.39"
      run = "export ARGS=\"$ARGS --with-zstd\""
    },
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix={{ prefix }}",
      "--disable-werror",
    ]

    linux {
      ARGS = [
        "--enable-ld=yes",
        "--enable-gold=yes",
      ]
    }
  }
}

provides {
  darwin = [
    "bin/addr2line",
    "bin/ar",
    "bin/c++filt",
    "bin/elfedit",
    "bin/nm",
    "bin/objcopy",
    "bin/objdump",
    "bin/ranlib",
    "bin/readelf",
    "bin/size",
    "bin/strings",
    "bin/strip",
  ]
  linux = [
    "bin/addr2line",
    "bin/ar",
    "bin/as",
    "bin/c++filt",
    "bin/elfedit",
    "bin/gprof",
    "bin/ld",
    "bin/ld.bfd",
    "bin/nm",
    "bin/objcopy",
    "bin/objdump",
    "bin/ranlib",
    "bin/readelf",
    "bin/size",
    "bin/strings",
    "bin/strip",
  ]
}

test {
  script = [
    {
      if = "<2.29"
      run = [
        <<EOT
if test "$(uname)" = Darwin; then
  printf 'int main(void) { return 0; }\n' > test.c
  cc -c test.c -o test.o
  ar rcS libtest.a test.o
  strings libtest.a | grep -s _main
  exit 0
fi
EOT
,
      ]
    },
    "objdump -x $(which objdump) | grep -s $TEST_STRING",
  ]

  env {

    darwin {
      TEST_STRING = "_opendir"
    }

    linux {
      TEST_STRING = "GNU_HASH"
    }
  }
}

versions {
  match = "/binutils-\\d+\\.\\d+(\\.\\d+)?.tar.gz/"
  strip = [
    "/binutils-/",
    "/.tar.gz/",
  ]
  url = "https://ftp.gnu.org/gnu/binutils/"
}
