dependencies = {
  "openssl.org" = "^3"
}
display-name = "iperf3"
provides = [
  "bin/iperf3",
]
test = [
  "iperf3 --version 2>&1 | tee out",
  "grep {{version.marketing}} out",
]

build {
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-dependency-tracking",
      "--with-openssl={{deps.openssl.org.prefix}}",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/esnet/iperf/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "esnet/iperf/tags"
  strip = [
    "/^iperf-/",
  ]
}
