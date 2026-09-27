dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/drill",
  "bin/ldns-config",
]
test = "drill tea.xyz"

build {
  dependencies = {
    "gnu.org/autoconf" = "*"
    "gnu.org/automake" = "*"
    "swig.org" = "*"
  }
  script = <<EOT
autoreconf
./configure $ARGS
make --jobs {{ hw.concurrency }} install

# Oddly, the man pages are read-only, messing
# up our build process
find "{{ prefix }}"/share/man -type f -print0 | xargs -0 chmod u+w
EOT
  skip = "flatten-includes"

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--with-drill",
      "--with-ssl={{ deps.openssl.org.prefix }}",
      "--disable-dane-verify",
      "--without-xcode-sdk",
    ]
    CFLAGS = "$CFLAGS -I$(pwd)/ldns"
  }
}

distributable {
  strip-components = 1
  url = "https://nlnetlabs.nl/downloads/ldns/ldns-{{ version }}.tar.gz"
}

versions {
  github = "NLnetLabs/ldns/tags"
}
