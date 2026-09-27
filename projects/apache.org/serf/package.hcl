dependencies = {
  "apache.org/apr" = "^1"
  "apache.org/apr-util" = "^1"
  "kerberos.org" = "^1.20"
  "libexpat.github.io" = "^2"
  "openssl.org" = "^3"
  "zlib.net" = "^1.2"
}
display-name = "serf"
test = [
  "test \"$(pkg-config --modversion serf-1)\" = \"{{version}}\"",
]

build {
  dependencies = {
    "python.org" = "~3.11"
    "scons.org" = "*"
  }
  script = [
    {
      prop = <<EOT
s/env = Environment(variables=opts,/env = Environment(ENV = os.environ, variables=opts,/
EOT
      run = "sed -i -f $PROP SConstruct"
    },
    "scons $ARGS",
    "scons install",
  ]

  env {
    ARGS = [
      "APR={{deps.apache.org/apr.prefix}}",
      "APU={{deps.apache.org/apr-util.prefix}}",
      "OPENSSL={{deps.openssl.org.prefix}}",
      "ZLIB={{deps.zlib.net.prefix}}",
      "GSSAPI={{deps.kerberos.org.prefix}}",
      "CFLAGS=-Wno-incompatible-pointer-types",
      "PREFIX={{prefix}}",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://archive.apache.org/dist/serf/serf-{{version}}.tar.bz2"
}

versions {
  match = "/serf-(\\d+\\.\\d+\\.\\d+)\\.tar\\.bz2/"
  strip = [
    "/serf-/",
    "/.tar.bz2/",
  ]
  url = "https://archive.apache.org/dist/serf/"
}
