build {
  dependencies = {
    "kerberos.org" = "*"
    "openssl.org"  = "^3"
  }
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {
    ARGS = [
      "--disable-macos-framework",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
      "--prefix=\"{{prefix}}\"",
      "--with-ssl={{ deps.openssl.org.prefix }}",
    ]

    linux {
      CFLAGS = "-Wno-implicit-function-declaration"
    }
  }
}
