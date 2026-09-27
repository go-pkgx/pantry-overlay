dependencies = {
  "gnome.org/glib" = 2
}

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "gnome.org/gobject-introspection" = 1
    "gnu.org/gettext" = "^1"
    "mesonbuild.com" = "^0.63"
    "ninja-build.org" = 1
  }
  script = <<EOT
meson setup build $ARGS
meson compile -C build
meson install -C build
EOT

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--libdir={{prefix}}/lib",
      "--wrap-mode=nofallback",
      "--buildtype=release",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://download.gnome.org/sources/atk/{{ version.major }}.{{ version.minor }}/atk-{{ version }}.tar.xz"
}

test {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
  }
  fixture = "#include <atk/atk.h>\n\nint main(int argc, char *argv[]) {\n  const gchar *version = atk_get_version();\n  return 0;\n}"
  script = <<EOT
cp $FIXTURE test.c
cc -o test test.c `pkg-config --cflags --libs atk`
./test
EOT
}

versions {
  github = "GNOME/atk/tags"
}
