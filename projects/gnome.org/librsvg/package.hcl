dependencies = {
  "cairographics.org" = "^1.18"
  "gnome.org/gdk-pixbuf" = 2
  "gnome.org/glib" = 2
  "gnome.org/pango" = 1
  "gnu.org/gettext" = "^1"
}
provides = [
  "bin/rsvg-convert",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "github.com/lu-zero/cargo-c" = "*"
    "gnome.org/gobject-introspection" = 1
    "mesonbuild.com" = "*"
    "ninja-build.org" = "*"
    "python.org" = ">=3<3.12"
    "rust-lang.org" = "^1.63"
    "rust-lang.org/cargo" = 0
  }
  script = [
    {
      if = "<2.59"
      run = [
        "./configure $ARGS",
        "make --jobs {{hw.concurrency}} install",
      ]
    },
    {
      if = ">=2.59"
      run = [
        "mkdir -p {{prefix}}/bin",
        "ln -s {{deps.gnome.org/gdk-pixbuf.prefix}}/bin/gdk-pixbuf-query-loaders {{prefix}}/bin/",
        "mkdir -p build",
        "meson setup build $MESON_ARGS",
        "meson compile -C build",
        "meson install -C build",
        "rm {{prefix}}/bin/gdk-pixbuf-query-loaders",
      ]
    },
  ]

  env {
    ARGS = [
      "--prefix={{ prefix }}",
      "--enable-pixbuf-loader=yes",
      "--enable-introspection=yes",
      "--disable-Bsymbolic",
    ]
    MESON_ARGS = [
      "--prefix={{prefix}}",
      "--buildtype=release",
      "-Ddocs=disabled",
      "-Dpixbuf-loader=enabled",
      "-Dintrospection=enabled",
    ]

    linux {
      LDFLAGS = "$LDFLAGS -Wl,-ldl"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://download.gnome.org/sources/librsvg/{{ version.major }}.{{ version.minor }}/librsvg-{{ version }}.tar.xz"
}

test {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
  }
  script = <<EOT
cc test.c -lrsvg-{{version.major}}
./a.out
EOT
}

versions {
  github = "GNOME/librsvg/tags"
  ignore = "/\\.9[0-9]$/"
}
