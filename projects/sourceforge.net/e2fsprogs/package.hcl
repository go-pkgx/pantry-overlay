test = [
  {
    if = "linux"
    run = "lsattr -al | grep Extents"
  },
  {
    if = "darwin"
    run = <<EOT
lsattr -al | grep '\-\-\-'
uuidgen | wc -c | grep 37 # 36 + 1 newline
EOT
  },
]

build {
  script = [
    {
      if = "linux"
      run = "./configure $ARGS"
    },
    {
      if = "darwin"
      run = "./configure $ARGS MKDIR_P='mkdir -p'"
    },
    "make --jobs {{hw.concurrency}}",
    "make install",
    "make install-libs",
    {
      run = "sed -i 's|{{prefix}}|\\$(dirname \\$0)/..|g' compile_et mk_cmds"
      working-directory = "$${{prefix}}/bin"
    },
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--exec-prefix={{prefix}}",
      "--disable-e2initrd-helper",
      "--without-udev-rules-dir",
      "--without-systemd-unit-dir",
    ]

    darwin {
      ARGS = [
        "--enable-bsd-shlibs",
      ]
    }

    linux {
      ARGS = [
        "--enable-elf-shlibs",
        "--disable-fsck",
        "--disable-uuidd",
        "--disable-libuuid",
        "--disable-libblkid",
        "--without-crond-dir",
      ]
      CC = "clang"
      CXX = "clang++"
      LD = "clang"
    }
  }
}

dependencies {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
  linux = {
    "github.com/util-linux/util-linux" = "^2.39"
  }
}

distributable {
  strip-components = 1
  url = "https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v{{version}}/e2fsprogs-{{version}}.tar.gz"
}

provides {
  darwin = [
    "bin/chattr",
    "bin/compile_et",
    "bin/lsattr",
    "bin/mk_cmds",
    "bin/uuidgen",
  ]
  linux = [
    "bin/chattr",
    "bin/compile_et",
    "bin/lsattr",
    "bin/mk_cmds",
  ]
}

versions {
  match = "/e2fsprogs-(\\d+\\.\\d+\\.\\d+)\\.tar\\.gz/"
  strip = [
    "/^e2fsprogs-/",
    "/\\.tar\\.gz$/",
  ]
  url = "https://sourceforge.net/projects/e2fsprogs/rss"
}
