dependencies = {
  linux = {
    "alsa-project.org/alsa-lib" = 1
    "freedesktop.org/fontconfig" = 2
  }
  "openssl.org" = "^3"
  "tcpdump.org" = 1
}
provides = [
  "bin/sniffnet",
]

build {
  dependencies = {
    "rust-lang.org" = "^1.78"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/GyulyVGC/sniffnet/archive/refs/tags/{{ version.tag }}.tar.gz"
}

test {
  script = [
    {
      if = "darwin"
      run = [
        "sniffnet &",
        "PID=$!",
        "sleep 5",
        "kill -0 $PID",
        "kill $PID",
      ]
    },
    {
      if = "linux"
      run = "if ldd {{prefix}}/bin/sniffnet | grep 'not found'; then exit 1; fi"
    },
    "test \"$(sniffnet --version)\" = \"sniffnet {{version}}\"",
  ]
}

versions {
  github = "GyulyVGC/sniffnet"
}
