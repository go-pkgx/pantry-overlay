build = [
  {
    run = [
      "cp -r $SRCROOT/* ./",
      "find . -mindepth 1 -maxdepth 1 -name \\*.pkgx.\\* -exec rm -rf {} \\;",
      "if test -f pkgx.yaml; then rm pkgx.yaml; fi",
    ]
    working-directory = "{{prefix}}"
  },
  {
    run = "mkdir -p lib/rabbitmq og/rabbitmq"
    working-directory = "{{prefix}}/var"
  },
]
dependencies = {
  "erlang.org" = "^27"
  linux = {
    "gnu.org/gcc" = 14
    "gnu.org/gcc/libstdcxx" = 14
  }
  "openssl.org" = "^3"
}
provides = [
  "bin/rabbitmqctl",
  "bin/rabbitmq-defaults",
  "bin/rabbitmq-diagnostics",
  "bin/rabbitmq-env",
  "bin/rabbitmq-plugins",
  "bin/rabbitmq-queues",
  "bin/rabbitmq-server",
  "bin/rabbitmq-streams",
  "bin/rabbitmq-upgrade",
  "bin/vmware-rabbitmq",
]
warnings = [
  "vendored",
]

distributable {
  strip-components = 1
  url = "https://github.com/rabbitmq/rabbitmq-server/releases/download/{{version.tag}}/rabbitmq-server-generic-unix-{{version}}.tar.xz"
}

test {
  script = [
    "killall rabbitmq-server || true",
    "killall epmd || true",
    "killall beam.smp || true",
    "rabbitmq-server &",
    "sleep 5",
    "rabbitmqctl await_startup --timeout 60",
    "rabbitmqctl status 2>&1 | tee out",
    "grep \"Virtual host count\" out",
    "rabbitmqctl stop 2>&1 | tee out",
    "grep \"Stopping and halting node\" out",
  ]

  env {
    LANG = "C.UTF-8"
    LC_ALL = "C.UTF-8"
    RABBITMQ_MNESIA_BASE = "$PWD/var/lib/rabbitmq/mnesia"
    RABBITMQ_NODENAME = "rabbit@localhost"
  }
}

versions {
  github = "rabbitmq/rabbitmq-server"
}
