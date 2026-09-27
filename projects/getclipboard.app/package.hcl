dependencies = {
  linux = {
    "alsa-project.org/alsa-lib" = 1
    "gnu.org/gcc/libstdcxx" = 14
    "wayland.freedesktop.org" = 1
    "x.org/x11" = 1
  }
  "openssl.org" = "^3"
}
provides = [
  "bin/cb",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    linux = {
      "gnu.org/gcc" = 14
      "wayland.freedesktop.org/protocols" = "*"
    }
  }
  script = [
    "cmake -S . -B build -DCMAKE_INSTALL_PREFIX={{ prefix }} -DCMAKE_BUILD_TYPE=Release -Wno-dev",
    "cmake --build build",
    "cmake --install build",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/Slackadays/Clipboard/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  dependencies = {
    "gnu.org/diffutils" = "*"
  }
  fixture = <<EOT
this is a test file
it includes random information
and is used to test the clipboard
EOT
  script = [
    "cb copy $FIXTURE",
    "cb paste > foo",
    "cmp $FIXTURE foo",
    "cb info",
    "cb status",
  ]
}

versions {
  github = "Slackadays/Clipboard"
}
