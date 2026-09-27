dependencies = {
  linux = {
    "unicode.org" = "^71"
  }
  "openssl.org" = "^3"
}
provides = [
  "bin/pwsh",
]
warnings = [
  "vendored",
]

build {
  dependencies = {
    "curl.se" = "*"
  }
  env = {
    "darwin/aarch64" = {
      PLATFORM = "osx-arm64"
    }
    "darwin/x86-64" = {
      PLATFORM = "osx-x64"
    }
    "linux/aarch64" = {
      PLATFORM = "linux-arm64"
    }
    "linux/x86-64" = {
      PLATFORM = "linux-x64"
    }
  }
  script = [
    "curl -L \"https://github.com/PowerShell/PowerShell/releases/download/{{version.tag}}/powershell-{{version}}-$${PLATFORM}.tar.gz\" | tar zxf -",
    "chmod +x pwsh",
  ]
  working-directory = "$${{prefix}}/bin"
}

interprets {
  args = "pwsh"
  extensions = [
    "ps1",
    "ps1xml",
    "psc1",
    "psd1",
    "psm1",
    "pssc",
    "psrc",
    "cdxml",
  ]
}

test {
  script = [
    {
      if = "linux"
      run = [
        "LIBCV=$(getconf GNU_LIBC_VERSION | sed 's/^glibc //')",
        <<EOT
if  semverator lt $LIBCV 2.33; then
  echo "Skipping test on glibc $LIBCV"
  exit 0
fi
EOT
,
      ]
    },
    "test \"$(pwsh --version)\" = \"PowerShell {{version}}\"",
  ]

  dependencies {
    linux = {
      "crates.io/semverator" = "*"
    }
  }
}

versions {
  github = "PowerShell/PowerShell"
}
