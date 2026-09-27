dependencies = {
  "gnu.org/gettext" = "^1"
  "sqlite.org" = "^3"
}

build {
  dependencies = {
    darwin = {
      "llvm.org" = "*"
    }
    "gnu.org/bison" = "*"
    "gnu.org/patch" = "*"
    linux = {
      "linux-pam.org" = "*"
    }
  }
  script = [
    {
      if = "<2.39"
      run = <<EOT
if test darwin = {{hw.platform}}; then
  patch -p0 <props/macports.patch
fi
EOT
    },
    {
      if = ">=2.42"
      run = <<EOT
if test darwin = {{hw.platform}}; then
  echo '/* pidfd is Linux-only */' > lib/pidfd-utils.c
fi
EOT
    },
    "sed -i 's/build_waitpid=yes ;;/build_waitpid=no ;;/g' configure",
    {
      if = ">=2.41"
      prop = <<EOT
s/build_bits=yes/build_bits=no/
s/enable_bits=yes/enable_bits=no/
EOT
      run = <<EOT
if test darwin = {{hw.platform}}; then
  sed -i -f $PROP configure
fi
EOT
    },
    "./configure $ARGS",
    "make --jobs {{hw.concurrency}} install",
    {
      run = <<EOT
for x in $HEADERS; do
  if test -f "$x/$x.h"; then
    mv "$x/$x.h" .
    ln -s "../$x.h" "$x/"
  fi
done
EOT
      working-directory = "{{prefix}}/include"
    },
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-makeinstall-chown",
      "--disable-makeinstall-setuid",
      "--disable-liblastlog2",
    ]
    HEADERS = [
      "blkid",
      "libfdisk",
      "libsmartcols",
      "uuid",
    ]

    darwin {
      ARGS = [
        "--disable-pam-lastlog2",
        "--disable-libuuid",
      ]
    }

    linux {
      CFLAGS = "$CFLAGS -Wl,--undefined-version"
      HEADERS = [
        "libmount",
      ]
    }
  }
}

distributable {
  strip-components = 1
  url = "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v{{version.marketing}}/util-linux-{{version.raw}}.tar.xz"
}

provides {
  darwin = [
    "bin/cal",
    "bin/colcrt",
    "bin/colrm",
    "bin/column",
    "bin/flock",
    "bin/getopt",
    "bin/hardlink",
    "bin/hexdump",
    "bin/isosize",
    "bin/logger",
    "bin/look",
    "bin/mcookie",
    "bin/mesg",
    "bin/namei",
    "bin/rename",
    "bin/renice",
    "bin/rev",
    "bin/scriptreplay",
    "bin/setsid",
    "bin/wall",
    "bin/whereis",
  ]
  linux = [
    "bin/cal",
    "bin/chmem",
    "bin/choom",
    "bin/chrt",
    "bin/col",
    "bin/colcrt",
    "bin/colrm",
    "bin/column",
    "bin/dmesg",
    "bin/eject",
    "bin/fallocate",
    "bin/fincore",
    "bin/findmnt",
    "bin/flock",
    "bin/getopt",
    "bin/hardlink",
    "bin/hexdump",
    "bin/ionice",
    "bin/ipcmk",
    "bin/ipcrm",
    "bin/ipcs",
    "bin/isosize",
    "bin/kill",
    "bin/last",
    "bin/lastb",
    "bin/linux32",
    "bin/linux64",
    "bin/logger",
    "bin/look",
    "bin/lsblk",
    "bin/lscpu",
    "bin/lsfd",
    "bin/lsipc",
    "bin/lsirq",
    "bin/lslocks",
    "bin/lslogins",
    "bin/lsmem",
    "bin/lsns",
    "bin/mcookie",
    "bin/mesg",
    "bin/mount",
    "bin/mountpoint",
    "bin/namei",
    "bin/nsenter",
    "bin/prlimit",
    "bin/rename",
    "bin/renice",
    "bin/rev",
    "bin/script",
    "bin/scriptlive",
    "bin/scriptreplay",
    "bin/setarch",
    "bin/setsid",
    "bin/taskset",
    "bin/uclampset",
    "bin/umount",
    "bin/uname26",
    "bin/unshare",
    "bin/utmpdump",
    "bin/uuidgen",
    "bin/uuidparse",
    "bin/wall",
    "bin/wdctl",
    "bin/whereis",
  ]
}

test {
  dependencies = {
    "stedolan.github.io/jq" = "*"
  }
  script = "test \"$(echo 5 6 7 | column -tJN first,second,third | jq .table[0].second)\" = '\"6\"'"
}

versions {
  github = "util-linux/util-linux/tags"
}
