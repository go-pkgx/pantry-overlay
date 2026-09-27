dependencies = {
  "openssl.org" = "^3"
  "python.org" = ">=3.10<3.12"
  "sourceware.org/libffi" = "*"
}
provides = [
  "bin/az",
]

build {
  dependencies = {
    linux = {
      "freedesktop.org/pkg-config" = "*"
    }
    "rust-lang.org" = "*"
  }
  script = <<EOT
_SRCROOT="$SRCROOT"
for venv in azure-cli{-telemetry,-core,}; do
  SRCROOT="$_SRCROOT"/src/"$venv" python-venv.sh "{{prefix}}"/bin/az
done
EOT

  env {
    CC = "clang"
    LD = "clang"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/Azure/azure-cli/archive/refs/tags/azure-cli-{{version}}.tar.gz"
}

test {
  script = <<EOT
az cloud show --name AzureCloud
EOT
}

versions {
  github = "Azure/azure-cli/tags"
  strip = "/^azure-cli-/"
}
