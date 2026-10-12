provides = [
  "bin/gunzip",
  "bin/gzexe",
  "bin/gzip",
  "bin/uncompress",
  "bin/zcat",
  "bin/zcmp",
  "bin/zdiff",
  "bin/zegrep",
  "bin/zfgrep",
  "bin/zforce",
  "bin/zgrep",
  "bin/zless",
  "bin/zmore",
  "bin/znew",
]

build {
  env = {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--disable-dependency-tracking",
    ]
    MAKE_CFLAGS = [
      "-g",
      "-O2",
    ]
    "linux/aarch64" = {
      MAKE_CFLAGS = [
        "-include asm/sigcontext.h",
      ]
    }
  }
  script = [
    "./configure $ARGS ac_cv_prog_LESS=less ac_cv_prog_MORE=more",
    "make --jobs {{ hw.concurrency }} install CFLAGS=\"$MAKE_CFLAGS\"",
  ]
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/gzip/gzip-{{version.raw}}.tar.xz"
}

test {
  script = [
    "gzip --version | grep {{version.raw}}",
    "test \"$(printf '%s' \"$INPUT\" | gzip -c | gunzip -c)\" = \"$INPUT\"",
    "test \"$(printf '%s' \"$INPUT\" | gzip -c | zcat)\" = \"$INPUT\"",
  ]

  env {
    INPUT = "tea.xyz.test-string"
  }
}

versions {
  match = "/gzip-\\d+\\.\\d+(\\.\\d+)?\\.tar\\.xz/"
  strip = [
    "/^gzip-/",
    "/\\.tar\\.xz$/",
  ]
  url = "https://ftp.gnu.org/gnu/gzip/"
}
