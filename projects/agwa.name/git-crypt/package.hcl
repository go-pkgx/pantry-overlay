dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/git-crypt",
]
test = [
  "git-crypt keygen keyfile",
  "ls | grep keyfile",
  "git-crypt version | grep {{version}}",
]

build {
  dependencies = {
    "docbook.org" = "*"
    "docbook.org/xsl" = "*"
    "gnome.org/libxslt" = "*"
  }
  script = [
    "sed -i \"s|http://docbook.sourceforge.net/release/xsl/current|{{deps.docbook.org/xsl.prefix}}/libexec/docbook-xsl|g\" Makefile",
    "make ENABLE_MAN=yes PREFIX={{prefix}} install",
  ]

  env {
    CFLAGS = "$CFLAGS -DOPENSSL_API_COMPAT=0x30000000L"
    XML_CATALOG_FILES = "$${{prefix}}/etc/xml/catalog"
  }
}

distributable {
  strip-components = 1
  url = "https://www.agwa.name/projects/git-crypt/downloads/git-crypt-{{version}}.tar.gz"
}

versions {
  match = "/git-crypt-\\d+\\.\\d+\\.\\d+\\.tar\\.gz/"
  strip = [
    "/^git-crypt-/",
    "/\\.tar\\.gz$/",
  ]
  url = "https://www.agwa.name/projects/git-crypt/"
}
