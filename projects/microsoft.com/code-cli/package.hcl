dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = 1
}
display-name = "vscode cli"
provides = [
  "bin/code",
]
test = [
  "test \"$(code --version)\" == \"code-oss {{version}} (commit unknown)\"",
  "code tunnel prune | grep 'Successfully removed all unused servers'",
]

build {
  dependencies = {
    "github.com/mikefarah/yq" = ">=4"
    "rust-lang.org" = "^1.81"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "yq -i '.version = \"{{version}}\"' ../package.json",
    "cargo install --locked --path . --root {{prefix}}",
    {
      if = "darwin"
      run = "install_name_tool -change \"@rpath/gnu.org/libiconv/v1/lib/libiconv.2.dylib\" \"/usr/lib/libiconv.2.dylib\" code"
      working-directory = "$${{prefix}}/bin"
    },
  ]
  working-directory = "cli"

  env {
    OPENSSL_DIR = "{{deps.openssl.org.prefix}}"
    OPENSSL_NO_VENDOR = 1
    VSCODE_CLI_VERSION = "{{version}}"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/microsoft/vscode/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "microsoft/vscode"
}
