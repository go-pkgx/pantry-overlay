companions = {
  "info-zip.org/zip" = "*"
  "kornel.ski/dssim" = "*"
}
dependencies = {
  "openssl.org" = "^3"
}
platforms = [
  "linux/x86-64",
]
provides = [
  "bin/imageflow_tool",
]
versions = [
  "2023.9.25",
]

build {
  dependencies = {
    "info-zip.org/zip" = "*"
    "kornel.ski/dssim" = "*"
    "nasm.us" = "*"
    "rust-lang.org" = ">=1.65<1.78"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "./build.sh release",
    "mkdir -p '{{prefix}}'/{bin,lib,include}",
    "./artifacts/staging/install.sh",
  ]
  skip = "fix-machos"

  env {
    INSTALL_BASE = "$${{prefix}}"
  }
}

distributable {
  ref = "v2.0.0-preview8"
  url = "git+https://github.com/imazen/imageflow.git"
}

test {
  dependencies = {
    "darwinsys.com/file" = "*"
    "gnome.org/pango" = "*"
  }
  script = [
    {
      fixture = {
        content = "hi"
        extname = "txt"
      }
      run = "pango-view --height=50 --width=50 -qo hi.png $FIXTURE"
    },
    "imageflow_tool v1/querystring --in hi.png --out hi.jpg --command \"width=100&height=100&scale=both&format=jpg\" | tee imageflow.out",
    "grep \"\\\"success\\\": true,\" imageflow.out",
    "file hi.jpg | tee file.out grep 'JPEG image' file.out",
    "grep 100x100 file.out",
  ]
}
