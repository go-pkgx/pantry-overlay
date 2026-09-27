dependencies = {
  "kerberos.org" = "*"
  linux = {
    "openssl.org" = "^3"
  }
  "zlib.net" = "*"
}
provides = [
  "bin/cups-config",
  "bin/ippeveprinter",
  "bin/ipptool",
]
test = "cups-config --version | grep {{version}}"

build {
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--with-components=core",
      "--without-bundledir",
      "--disable-debug",
      "--disable-dependency-tracking",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/OpenPrinting/cups/releases/download/v{{version}}/cups-{{version}}-source.tar.gz"
}

versions {
  github = "OpenPrinting/cups"
}
