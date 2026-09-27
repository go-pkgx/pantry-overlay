dependencies = {
  "apache.org/apr" = "^1"
  "apache.org/apr-util" = "^1"
  "apache.org/serf" = "^1"
  "github.com/JuliaStrings/utf8proc" = "^2"
  "gnu.org/gettext" = "^1"
  "kerberos.org" = "^1.20"
  "libexpat.github.io" = "^2"
  "lz4.org" = "^1"
  "openssl.org" = "^3"
  "sqlite.org" = "^3"
  "zlib.net" = "^1.2"
}
provides = [
  "bin/svn",
  "bin/svnadmin",
  "bin/svnbench",
  "bin/svndumpfilter",
  "bin/svnfsfs",
  "bin/svnlook",
  "bin/svnmucc",
  "bin/svnrdump",
  "bin/svnserve",
  "bin/svnsync",
  "bin/svnversion",
]
test = [
  {
    run = "svn --version"
    working-directory = "$(mktemp -d)"
  },
  {
    if = "linux"
    run = "ldd {{prefix}}/bin/svn | grep serf"
  },
  {
    if = "darwin"
    run = "otool -l {{prefix}}/bin/svn | grep serf"
  },
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "python.org" = "~3.11"
    "swig.org" = "^4"
  }
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--disable-debug",
      "--enable-optimize",
      "--disable-mod-activation",
      "--disable-plaintext-password-storage",
      "--with-apxs=no",
      "--without-apache-libexecdir",
      "--without-berkeley-db",
      "--without-gpg-agent",
      "--without-jikes",
      "--with-apr-util={{deps.apache.org/apr-util.prefix}}",
      "--with-serf={{deps.apache.org/serf.prefix}}",
    ]
    CFLAGS = "$CFLAGS -I{{deps.apache.org/apr-util.prefix}}/include/apr-1"
  }
}

distributable {
  strip-components = 1
  url = "https://archive.apache.org/dist/subversion/subversion-{{version}}.tar.bz2"
}

versions {
  match = "/subversion-(\\d+\\.\\d+\\.\\d+)\\.tar\\.bz2/"
  strip = [
    "/subversion-/",
    "/.tar.bz2/",
  ]
  url = "https://archive.apache.org/dist/subversion/"
}
