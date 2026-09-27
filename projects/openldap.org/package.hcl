dependencies = {
  linux = {
    "github.com/util-linux/util-linux" = "*"
  }
  "openssl.org" = "^3"
}
provides = [
  "bin/ldapcompare",
  "bin/ldapdelete",
  "bin/ldapexop",
  "bin/ldapmodify",
  "bin/ldapmodrdn",
  "bin/ldappasswd",
  "bin/ldapsearch",
  "bin/ldapurl",
  "bin/ldapvc",
  "bin/ldapwhoami",
]
test = "ldapcompare -VV 2>&1 | grep {{version}}"

build {
  dependencies = {
    "gnu.org/sed" = "*"
  }
  script = <<EOT
./configure $ARGS

# Avoid needing groff to build the docs
sed -i.bak -e 's/SUBDIRS=\(.*\)\bdoc\b\(.*\)/SUBDIRS=\1\2/' Makefile
rm Makefile.bak

make --jobs {{ hw.concurrency }} install
EOT

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--enable-accesslog",
      "--enable-auditlog",
      "--enable-constraint",
      "--enable-dds",
      "--enable-deref",
      "--enable-dyngroup",
      "--enable-dynlist",
      "--enable-memberof",
      "--enable-ppolicy",
      "--enable-proxycache",
      "--enable-refint",
      "--enable-retcode",
      "--enable-seqmod",
      "--enable-translucent",
      "--enable-unique",
      "--enable-valsort",
      "--without-systemd",
    ]

    linux {
      CFLAGS = "$CFLAGS -Wl,--undefined-version"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-{{version}}.tgz"
}

versions {
  match = "/openldap-\\d+\\.\\d+\\.\\d+.tgz/"
  strip = [
    "/^openldap-/",
    "/\\.tgz/",
  ]
  url = "https://www.openldap.org/software/download/OpenLDAP/openldap-release/"
}
