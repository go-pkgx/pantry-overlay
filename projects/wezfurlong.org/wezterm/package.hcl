dependencies = {
  linux = {
    "freedesktop.org/fontconfig" = "*"
    "freetype.org" = "*"
    "openssl.org" = "^3"
  }
  "zlib.net" = "^1.3"
}
provides = [
  "bin/wezterm",
]
test = "test \"$(wezterm --version)\" = \"wezterm {{version.tag}}\""

build {
  dependencies = {
    "rust-lang.org" = ">=1.71<1.78"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install $ARGS"

  env {
    ARGS = [
      "--locked",
      "--path=wezterm",
      "--root {{prefix}}",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/wez/wezterm/releases/download/{{version.tag}}/wezterm-{{version.tag}}-src.tar.gz"
}

versions {
  github = "wez/wezterm/tags"
  transform = "v => v.replace(/^(\\d{4})(\\d{2})(\\d{2})-.*$/, '$1.$2.$3')"
}
