companions = null
dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/go",
  "bin/gofmt",
]

bootstrap {
  dependencies = {
    "curl.se" = "*"
  }
  env = {
    "*/aarch64" = {
      GOARCH = "arm64"
    }
    "*/x86-64" = {
      GOARCH = "amd64"
    }
  }
  script = <<EOT
curl -L "$URL" | tar xzf - -C "{{ prefix }}" --strip-components=1
EOT
}

build {
  dependencies = {
    "gnu.org/m4" = 1
    "go.dev" = "*"
  }
  script = [
    "./make.bash",
    "rm *.{bash,bat,rc} Make.dist",
    {
      run = "find . -mindepth 1 -delete"
      working-directory = "$${{ prefix }}"
    },
    {
      run = <<EOT
cp -a api bin doc lib misc pkg src test "{{prefix}}"
if test -f go.env; then
  cp go.env "{{prefix}}"
fi
EOT
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
  url = "https://go.dev/dl/go{{version.raw}}.src.tar.gz"
}

interprets {
  args = [
    "go",
    "run",
  ]
  extensions = "go"
}

test {
  fixture = <<EOT
package main
import "fmt"
func main() {
  fmt.Println("Hello World")
}
EOT
  script = <<EOT
mv $FIXTURE $FIXTURE.go
OUTPUT=$(go run $FIXTURE.go)
test "Hello World" = "$OUTPUT"
go build -o my-artifact $FIXTURE.go
ls -la $FIXTURE.go
EOT
}

versions {
  github = "golang/go/tags"
  strip = "/^go/"
}
