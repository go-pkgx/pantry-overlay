dependencies = {
  "gnome.org/glib" = 2
  "gnu.org/gettext" = "^1"
}
provides = [
  "bin/update-mime-database",
]
test = [
  {
    fixture = <<EOT
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="application/x-pkgx-test">
    <comment>pkgx test type</comment>
    <glob pattern="*.pkgxtest"/>
  </mime-type>
</mime-info>
EOT
    run = "cp $FIXTURE pkgx-test.xml"
    working-directory = "mimetest/packages"
  },
  "update-mime-database mimetest",
  "test -f mimetest/mime.cache",
  "grep -q 'application/x-pkgx-test' mimetest/types",
  "grep -q '\\.pkgxtest' mimetest/globs",
]

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "gnome.org/libxml2" = 2
    "mesonbuild.com" = "*"
    "ninja-build.org" = 1
  }
  script = [
    {
      if = "darwin"
      run = "sed -i -e '/fdatasync/d' meson.build"
      working-directory = ".."
    },
    "meson .. $MESON_ARGS",
    {
      if = "darwin"
      run = "sed -i -e \"/subdir('fuzzing')/d\" meson.build"
      working-directory = "../subprojects/xdgmime"
    },
    "ninja",
    "ninja install",
    {
      run = "./update-mime-database ../share/mime"
      working-directory = "$${{prefix}}/bin"
    },
  ]
  working-directory = "build"

  env {
    CFLAGS = "$CFLAGS -Wno-implicit-function-declaration"
    CXXFLAGS = "$CXXFLAGS -std=c++17 -Wno-reserved-user-defined-literal"
    MESON_ARGS = [
      "--prefix={{prefix}}",
      "--buildtype=release",
      "-Dbuild-spec=false",
    ]

    linux {
      LDFLAGS = "$LDFLAGS -lstdc++fs"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/{{version.raw}}/shared-mime-info-{{version.raw}}.tar.bz2"
}

versions {
  gitlab = "gitlab.freedesktop.org:xdg/shared-mime-info/tags"
}
