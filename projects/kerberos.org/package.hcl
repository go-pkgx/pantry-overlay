dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/compile_et",
  "bin/gss-client",
  "bin/k5srvutil",
  "bin/kadmin",
  "bin/kdestroy",
  "bin/kinit",
  "bin/klist",
  "bin/kpasswd",
  "bin/krb5-config",
  "bin/kswitch",
  "bin/ktutil",
  "bin/kvno",
  "bin/sclient",
  "bin/sim_client",
  "bin/uuclient",
  "sbin/gss-server",
  "sbin/kadmin.local",
  "sbin/kadmind",
  "sbin/kdb5_util",
  "sbin/kprop",
  "sbin/kpropd",
  "sbin/kproplog",
  "sbin/krb5-send-pr",
  "sbin/krb5kdc",
  "sbin/sim_server",
  "sbin/sserver",
  "sbin/uuserver",
]
test = "krb5-config --version\nkrb5-config --cflags"

build {
  dependencies = {
    "gnu.org/bison" = 3
  }
  script = <<EOT
./configure $ARGS
make --jobs {{ hw.concurrency }}
make install
EOT
  working-directory = "src"

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--disable-nls",
      "--without-system-verto",
      "--without-keyutils",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://kerberos.org/dist/krb5/{{ version.marketing }}/krb5-{{ version.raw }}.tar.gz"
}

versions {
  github = "krb5/krb5/tags"
  strip = [
    "/^krb5-/",
    "/-final$/",
  ]
}
