dependencies = {
  "freetype.org" = "*"
  "graphite.sil.org" = "*"
  "harfbuzz.org" = "*"
  "libpng.org" = "*"
  "openssl.org" = "^3"
  "unicode.org" = "^71"
}
provides = [
  "bin/tectonic",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "rust-lang.org" = ">=1.48.0"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --features external-harfbuzz --locked --path . --root {{prefix}}"

  env {
    OPENSSL_DIR = "{{ deps.openssl.org.prefix }}"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/tectonic-typesetting/tectonic/archive/refs/tags/tectonic@{{ version }}.tar.gz"
}

test {
  script = <<EOT
tectonic -X new
tectonic -X build
test -f build/default/default.pdf
EOT
}

versions {
  github = "tectonic-typesetting/tectonic/releases/tags"
  strip = "/^tectonic@/"
}
