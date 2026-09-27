dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/teller",
]
test = [
  {
    fixture = {
      content = <<EOT
project: test
providers:
  # this will fuse vars with the below .env file
  # use if you'd like to grab secrets from outside of the project tree
  dotenv:
    env_sync:
      path: test.env
EOT
      extname = ".yml"
    }
    if = "<2"
    run = <<EOT
echo 'foo: var' > test.env
teller -c $FIXTURE show  2>&1 | grep 'foo'
teller version | grep {{version}}
EOT
  },
  {
    fixture = {
      content = <<EOT
providers:
  dot_1:
    kind: dotenv
    maps:
      - id: foo
        path: test.env
EOT
      extname = ".yml"
    }
    if = ">=2"
    run = <<EOT
echo 'foo=var' > test.env
teller -c $FIXTURE show  2>&1 | grep 'foo'
test "$(teller --version)" = "teller {{version}}"
EOT
  },
]

build {
  dependencies = {
    "go.dev" = "^1.21"
    "protobuf.dev" = "*"
    "rust-lang.org" = "^1.78"
  }
  script = [
    {
      if = "<2"
      run = "go build $GO_ARGS -ldflags=\"$GO_LDFLAGS\" ."
    },
    {
      if = ">=2"
      run = "cargo install --locked --path teller-cli --root {{prefix}}"
    },
  ]

  env {
    COMMIT_SHA = "$(git describe --always --abbrev=8 --dirty)"
    GO_ARGS = [
      "-trimpath",
      "-o={{prefix}}/bin/teller",
    ]
    GO_LDFLAGS = [
      "-s",
      "-w",
      "-X main.version={{version}}",
      "-X main.commit=$${COMMIT_SHA}",
      "-X main.date=$${VERSION_DATE}",
    ]
    VERSION_DATE = "$(date -u +%FT%TZ)"

    linux {
      GO_ARGS = [
        "-buildmode=pie",
      ]
    }
  }
}

distributable {
  ref = "$${{version.tag}}"
  url = "git+https://github.com/SpectralOps/teller.git"
}

versions {
  github = "SpectralOps/teller"
}
