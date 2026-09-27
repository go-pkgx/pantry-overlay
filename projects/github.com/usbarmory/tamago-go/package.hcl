dependencies = {
  "openssl.org" = "^3"
}
display-name = "TamaGo (bare-metal Go toolchain)"
test = [
  "test \"$({{prefix}}/bin/go version | grep -c tamago)\" -ge 0",
  {
    fixture = {
      content = <<EOT
package main
import "fmt"
func main() { fmt.Println("Hello World") }
EOT
      extname = "go"
    }
    run = "test \"Hello World\" = \"$({{prefix}}/bin/go run $FIXTURE)\""
  },
]

build {
  dependencies = {
    "gnu.org/m4" = 1
    "go.dev" = "*"
  }
  script = [
    "./make.bash",
    "rm -f *.{bash,bat,rc} Make.dist",
    {
      run = "find . -mindepth 1 -delete"
      working-directory = "$${{ prefix }}"
    },
    {
      run = [
        "cp -a api bin doc lib misc pkg src test \"{{prefix}}\"",
        "if test -f go.env; then cp go.env \"{{prefix}}\"; fi",
        "if test -f VERSION; then cp VERSION \"{{prefix}}\"; fi",
      ]
      working-directory = "$SRCROOT"
    },
  ]
  skip = "fix-patchelf"
  working-directory = "src"

  env {
    GOCACHE = "$SRCROOT/.gocache"
    GOROOT_BOOTSTRAP = "$${{ deps.go.dev.prefix }}"
    GOROOT_FINAL = "$${{ prefix }}"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/usbarmory/tamago-go/archive/refs/tags/tamago-go{{version.raw}}.tar.gz"
}

versions {
  github = "usbarmory/tamago-go/tags"
  strip = "/^tamago-go/"
}
