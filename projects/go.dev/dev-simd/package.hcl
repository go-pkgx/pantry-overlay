dependencies = {
  "openssl.org" = "^3"
}
display-name = "Go (dev.simd SIMD intrinsics)"
distributable = null
versions = [
  "2026.6.1.17.4.35",
]

build {
  dependencies = {
    "curl.se" = "*"
    "gnu.org/m4" = 1
    "go.dev" = "*"
  }
  script = [
    {
      if = "2026.6.1.17.4.35"
      run = [
        "export SHA=0e5948dc597c831b0c235cc0b3d34fa7587ddd47",
        "export GOVER=go1.27",
      ]
    },
    {
      run = [
        "curl -Lf \"https://github.com/golang/go/archive/$${SHA}.tar.gz\" | tar xz --strip-components=1",
        "test -f VERSION || echo \"$GOVER\" > VERSION",
      ]
      working-directory = "$SRCROOT"
    },
    "./make.bash",
    "rm -f *.{bash,bat,rc} Make.dist",
    {
      run = "find . -mindepth 1 -exec rm -r {} \\;"
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

test {
  fixture = <<EOT
package main

import (
    "fmt"

    "simd/archsimd"
)

func main() {
    // Compiles only when the simd intrinsics package exists (GOEXPERIMENT=simd).
    // AVX2() is defined on every GOARCH (false off amd64), so this is portable.
    _ = archsimd.X86.AVX2()
    fmt.Println("Hello World")
}
EOT
  script = [
    "mv $FIXTURE $FIXTURE.go",
    "test \"Hello World\" = \"$(go run $FIXTURE.go)\"",
    "go build -o /dev/null $FIXTURE.go",
  ]

  env {
    GOEXPERIMENT = "simd"
  }
}
