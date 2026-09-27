provides = [
  "bin/sed",
]

build {
  dependencies = {
    "gnu.org/sed" = "*"
  }
  script = [
    "export PATH=\"{{deps.gnu.org/sed.prefix}}/bin:$PATH\"",
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--disable-debug",
    ]
  }
}

dependencies {
  darwin = {
    "gnu.org/gettext" = "*"
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/sed/sed-{{version.raw}}.tar.gz"
}

test {
  fixture = "Hello world!"
  script = [
    "sed -i 's/world/World/g' $FIXTURE",
    "test \"$(cat $FIXTURE)\" = 'Hello World!'",
  ]
}

versions {
  match = "/sed-(\\d+\\.\\d+(\\.\\d+)?)\\.tar\\.gz/"
  strip = [
    "/sed-/",
    "/.tar.gz/",
  ]
  url = "https://ftp.gnu.org/gnu/sed/"
}
