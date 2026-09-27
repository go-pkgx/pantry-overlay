dependencies = {
  "hboehm.info/gc" = 8
  "libevent.org" = 2
  "openssl.org" = "^3"
  "pcre.org/v2" = 10
}
provides = [
  "bin/lavinmq",
  "bin/lavinmqctl",
  "bin/lavinmqperf",
]
test = "test \"$(lavinmq --version)\" = {{version}}"

build {
  dependencies = {
    "crystal-lang.org" = "~1.20"
    "crystal-lang.org/shards" = "*"
    "etcd.io" = "*"
    "gnu.org/help2man" = "*"
    "lz4.org" = "^1"
    "perl.org" = "=5.42.0"
  }
  script = [
    {
      if = "darwin"
      run = "sed -i 's/--link-flags=-pie/--link-flags=-Wl,-pie,-headerpad_max_install_names/' Makefile"
    },
    {
      if = ">=2.3.0"
      prop = <<EOT
/useradd/s/^/#/g
s/-o lavinmq -g lavinmq//g
EOT
      run = "sed -i -f $PROP Makefile"
    },
    "make -j {{hw.concurrency}} install $ARGS",
  ]

  env {
    ARGS = [
      "PREFIX=\"{{prefix}}\"",
      "SYSCONFDIR=\"{{prefix}}/etc\"",
      "SHAREDSTATEDIR=\"{{prefix}}/var\"",
      "UNITDIR=\"{{prefix}}/etc\"",
      "DOCS=",
      "CRYSTAL_FLAGS=-Dbake_static",
      "SYSUSERSDIR=\"{{prefix}}/shared/sysusers.d\"",
    ]
    CRYSTAL_PATH = "./lib:$CRYSTAL_PATH"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/cloudamqp/lavinmq/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "cloudamqp/lavinmq"
}
