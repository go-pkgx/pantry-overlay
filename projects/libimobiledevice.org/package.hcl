dependencies = {
  "gnu.org/libtasn1" = "^4.19"
  "libimobiledevice.org/libimobiledevice-glue" = "^1.3"
  "libimobiledevice.org/libplist" = "^2.4"
  "libimobiledevice.org/libtatsu" = "^1"
  "libimobiledevice.org/libusbmuxd" = "^2"
  "openssl.org" = "^3"
}
provides = [
  "bin/idevicedate",
]
test = "idevicedate --help"

build {
  script = [
    {
      if = "<1.3.1"
      run = [
        "sed -i 's|PLIST_FORMAT_XML|PLIST_FORMAT_XML_|g' common/utils.h",
        "sed -i 's|PLIST_FORMAT_BINARY|PLIST_FORMAT_BINARY_|g' common/utils.h",
      ]
    },
    "./configure $ARGS",
    "make --jobs {{hw.concurrency}} install",
  ]

  env {
    ARGS = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix={{prefix}}",
      "--libdir={{prefix}}/lib",
      "--enable-debug",
      "--without-cython",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/libimobiledevice/libimobiledevice/releases/download/{{version}}/libimobiledevice-{{version}}.tar.bz2"
}

versions {
  github = "libimobiledevice/libimobiledevice"
}
