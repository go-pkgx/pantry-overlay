dependencies = {
  "github.com/json-c/json-c" = "^0.14"
  "github.com/seccomp/libseccomp" = "*"
  "kernel.org/libcap" = "*"
}
platforms = [
  "linux",
]
provides = [
  "bin/crun",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "python.org" = "^3"
  }
  script = [
    "./configure $ARGS",
    "make --jobs {{hw.concurrency}}",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-systemd",
      "--disable-criu",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/containers/crun/releases/download/{{version}}/crun-{{version}}.tar.gz"
}

test {
  script = [
    "crun --version | grep {{version}}",
    "crun features | grep -q '\"seccomp\"'",
    "crun features | grep -q '\"apparmor\"'",
  ]
}

versions {
  github = "containers/crun"
  ignore = [
    "/^v?0\\./",
  ]
}
