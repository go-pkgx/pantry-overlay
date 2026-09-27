dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/snmpget",
  "bin/snmpgetnext",
  "bin/snmpwalk",
  "bin/snmptranslate",
  "bin/snmpset",
  "bin/snmpd",
  "bin/snmptrap",
  "bin/net-snmp-config",
]

build {
  dependencies = {
    "darwinsys.com/file" = "*"
  }
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--with-defaults",
      "--with-openssl={{deps.openssl.org.prefix}}",
      "--with-default-snmp-version=3",
      "--disable-embedded-perl",
      "--without-perl-modules",
      "--disable-dependency-tracking",
    ]

    darwin {
      CFLAGS = "$CFLAGS -Wno-implicit-function-declaration -Wno-error=declaration-after-statement"
      LDFLAGS = "$LDFLAGS -framework CoreFoundation -framework IOKit -framework DiskArbitration -framework CoreServices"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://downloads.sourceforge.net/project/net-snmp/net-snmp/{{version}}/net-snmp-{{version}}.tar.gz"
}

test {
  script = [
    "snmptranslate -V 2>&1 | tee out",
    "grep -i \"net-snmp version\" out",
    "net-snmp-config --cflags | tee out",
    "grep -- -I out",
  ]
}

versions {
  match = "_/projects/net-snmp/files/net-snmp/\\d+\\.\\d+\\.\\d+/_"
  strip = [
    "_^/projects/net-snmp/files/net-snmp/_",
    "_/$_",
  ]
  url = "https://sourceforge.net/projects/net-snmp/files/net-snmp/"
}
