build {
  dependencies = {
    "freedesktop.org/pkg-config"      = "^0.29"
    "gnome.org/gobject-introspection" = 1
    "gnu.org/gettext"                 = "^1"
    "mesonbuild.com"                  = "^0.63"
    "ninja-build.org"                 = 1
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
