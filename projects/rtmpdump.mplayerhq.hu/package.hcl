dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "*"
}
display-name = "rtmpdump"
provides = [
  "bin/rtmpdump",
  "bin/rtmpgw",
  "bin/rtmpsrv",
  "bin/rtmpsuck",
]
test = [
  "rtmpdump -h",
  "rtmpdump -h 2>&1 | grep {{version.marketing}}",
]

build {
  dependencies = {
    "curl.se" = "*"
    "gnu.org/patch" = "*"
  }
  script = [
    "curl $PATCH | patch -p0 || true",
    "make XCFLAGS=\"$CFLAGS\" XLDFLAGS=\"$LDFLAGS\" $ARGS install",
  ]

  env {
    ARGS = [
      "CC=cc",
      "prefix={{prefix}}",
      "SHARED=no",
    ]
    PATCH = "https://raw.githubusercontent.com/Homebrew/formula-patches/85fa66a9/rtmpdump/openssl-1.1.diff"

    darwin {
      ARGS = [
        "SYS=\"darwin\"",
      ]
    }

    linux {
      ARGS = [
        "SYS=\"posix\"",
      ]
      CFLAGS = "$CFLAGS -fPIC"
      LDFLAGS = "$LDFLAGS -pie"
    }
  }
}

distributable {
  strip-components = 1
  url = "http://rtmpdump.mplayerhq.hu/download/rtmpdump-{{version.marketing}}.tgz"
}

versions {
  match = "/rtmpdump-\\d+\\.\\d+\\.tgz/"
  strip = [
    "/^rtmpdump-/",
    "/.tgz$/",
  ]
  url = "http://rtmpdump.mplayerhq.hu/download/"
}
