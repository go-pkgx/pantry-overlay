companions = {
  "git-scm.org" = "*"
}
dependencies = {
  "dotnet.microsoft.com" = "^10.0"
  "openssl.org" = "^3"
  "unicode.org" = "^71"
  "zlib.net" = "^1.3"
}
provides = [
  "bin/git-credential-manager",
]
test = "git-credential-manager --version | grep {{version}}"

build {
  dependencies = {
    "git-scm.org" = "^2.27.0"
    "kerberos.org" = "^1.21.3"
    linux = {
      "gnu.org/gcc" = ">=12"
    }
  }
  env = {
    DOTNET_CLI_TELEMETRY_OPTOUT = 1
    darwin = {
      CONFIGURATION = "MacRelease"
      CSPROJ = "src/osx/Installer.Mac/*.csproj"
    }
    "darwin/aarch64" = {
      RUNTIME = "osx-arm64"
    }
    "darwin/x86-64" = {
      RUNTIME = "osx-x64"
    }
    linux = {
      CONFIGURATION = "LinuxRelease"
      CSPROJ = "src/linux/Packaging.Linux/*.csproj"
    }
    "linux/aarch64" = {
      RUNTIME = "linux-arm64"
    }
    "linux/x86-64" = {
      RUNTIME = "linux-x64"
    }
  }
  script = [
    "dotnet build $${CSPROJ} -p:InstallFromSource=true -p:installPrefix={{prefix}} --no-self-contained --configuration=$${CONFIGURATION} --runtime=$${RUNTIME}",
    {
      if = "darwin || linux/aarch64"
      run = [
        "rm -rf {{prefix}}",
        "mkdir -p {{prefix}}/bin",
        "cp -aR * {{prefix}}/bin",
      ]
      working-directory = "out/shared/Git-Credential-Manager/bin/$${CONFIGURATION}/net{{deps.dotnet.microsoft.com.version.marketing}}/$${RUNTIME}"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/git-ecosystem/git-credential-manager/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "git-ecosystem/git-credential-manager/tags"
}
