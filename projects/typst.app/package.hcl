dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/typst",
]

build {
  dependencies = {
    "rust-lang.org" = "^1.80"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      if = "<0.7"
      run = "cargo install --path cli --locked --root {{prefix}}"
    },
    {
      if = ">=0.7"
      run = "cargo install --path crates/typst-cli --locked --root {{prefix}}"
    },
  ]

  env {
    TYPST_VERSION = "$${{ version }}"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/typst/typst/archive/refs/tags/v{{ version }}.tar.gz"
}

test {
  fixture = <<EOT
Total displaced soil by glacial flow:

$ 7.32 beta +
  sum_(i=0)^nabla Q_i / 2 $
EOT
  script = <<EOT
cp $FIXTURE test.typ
typst compile test.typ
test -s test.pdf
EOT
}

versions {
  github = "typst/typst/releases/tags"
  strip = "/^v\\d\\d-\\d\\d-\\d\\d(-\\d)?/"
}
