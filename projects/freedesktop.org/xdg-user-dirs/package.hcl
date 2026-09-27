dependencies = {
  "gnu.org/gettext" = "^1"
  "gnu.org/libiconv" = "^1.1"
}
distributable = [
  {
    strip-components = 1
    url = "https://user-dirs.freedesktop.org/releases/xdg-user-dirs-{{version.marketing}}.tar.xz"
  },
  {
    strip-components = 1
    url = "https://user-dirs.freedesktop.org/releases/xdg-user-dirs-{{version.tag}}.tar.gz"
  },
]
provides = [
  "bin/xdg-user-dir",
  "bin/xdg-user-dirs-update",
]
test = "xdg-user-dir --help"

build {
  dependencies = {
    "mesonbuild.com" = "*"
    "ninja-build.org" = "*"
  }
  script = [
    {
      if = "<0.19"
      run = [
        "./configure --prefix=\"{{ prefix }}\" --disable-documentation",
        "make --jobs {{ hw.concurrency }} install",
      ]
    },
    {
      if = ">=0.19"
      run = [
        "meson setup build $MESON_ARGS",
        "meson compile -C build",
        "meson install -C build",
      ]
    },
  ]

  env {
    LDFLAGS = "-liconv"
    MESON_ARGS = [
      "--prefix={{ prefix }}",
      "-Ddocs=false",
    ]
  }
}

versions {
  gitlab = "gitlab.freedesktop.org:xdg/xdg-user-dirs/tags"
}
