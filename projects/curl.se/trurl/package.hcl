dependencies = {
  "curl.se" = "^7,^8"
}
provides = [
  "bin/trurl",
]
test = <<EOT
a="$(trurl --url "https://example.com?name=hello" --append query=search=string)"
test "$a" = "https://example.com/?name=hello&search=string"
EOT

build {
  dependencies = {
    "openssl.org" = "^3"
  }
  script = <<EOT
# Makefile is not very flexible, so we have to edit it
sed -i.bak -e "s/^\(CFLAGS = .*\)\$/\1 $CFLAGS/" Makefile
rm Makefile.bak

make
mkdir -p {{prefix}}/bin
mv trurl {{prefix}}/bin
EOT
}

distributable {
  strip-components = 1
  url = "https://github.com/curl/trurl/archive/refs/tags/trurl-{{version.raw}}.tar.gz"
}

versions {
  github = "curl/trurl"
  strip = "/trurl-/"
}
