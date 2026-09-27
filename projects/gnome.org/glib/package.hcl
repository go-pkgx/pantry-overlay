companions = {
  "gnome.org/gsettings-desktop-schemas" = "*"
}
dependencies = {
  "gnu.org/gettext" = "^1"
  "pcre.org" = 8
  "pcre.org/v2" = 10
  "python.org" = 3
  "sourceware.org/libffi" = 3
}
provides = [
  "bin/gdbus",
  "bin/gdbus-codegen",
  "bin/gio",
  "bin/gio-querymodules",
  "bin/glib-compile-resources",
  "bin/glib-compile-schemas",
  "bin/glib-genmarshal",
  "bin/glib-gettextize",
  "bin/glib-mkenums",
  "bin/gobject-query",
  "bin/gresource",
  "bin/gsettings",
  "bin/gtester",
  "bin/gtester-report",
]

build {
  dependencies = {
    "gnome.org/gobject-introspection" = "*"
    "gnome.org/libxml2" = "~2.13"
    "mesonbuild.com" = "^1.2"
    "ninja-build.org" = 1
    "python.org" = ">=3.5<3.12"
  }
  script = [
    {
      run = [
        "python -m venv venv",
        "source venv/bin/activate",
        "python -m pip install packaging",
        "deactivate",
        "PYTHONPATH=\"$(pwd)/venv/lib/python{{deps.python.org.version.marketing}}/site-packages:$PYTHONPATH\"",
      ]
    },
    "meson out $ARGS",
    "cd out",
    "ninja install",
    "GT='$${prefix}/../../../gnu.org/gettext/v{{ deps.gnu.org/gettext.version.major }}'",
    {
      run = [
        <<EOT
sed -i -e \
's|Libs: -L$${libdir} -lglib-2.0 -lintl|Libs: -L$${libdir} -lglib-2.0'\ -L$GT/lib\ -lintl\| \
./glib-2.0.pc
EOT
,
        <<EOT
sed -i -e \
's|Cflags: -I$${includedir}/glib-2.0 -I$${libdir}/glib-2.0/include|Cflags: -I$${includedir}/glib-2.0 -I$${libdir}/glib-2.0/include'\ -I$GT/include\| \
./glib-2.0.pc
EOT
,
      ]
      working-directory = "{{prefix}}/lib/pkgconfig"
    },
    {
      run = [
        "mv glib-{{version.major}}.0/* .",
        "rmdir glib-{{version.major}}.0",
        "ln -s . glib-{{version.major}}.0",
        "mv gio-unix-{{version.major}}.0/gio/* gio/",
        "rmdir -p gio-unix-{{version.major}}.0/gio",
        "ln -s . gio-unix-{{version.major}}.0",
        "ln -s ../lib/glib-{{version.major}}.0/include/* .",
      ]
      working-directory = "{{prefix}}/include"
    },
    "cp -a ../venv/lib/python{{deps.python.org.version.marketing}} \"{{prefix}}\"/lib",
    {
      run = "ln -s python{{deps.python.org.version.marketing}} python{{deps.python.org.version.major}}"
      working-directory = "{{prefix}}/lib"
    },
    {
      run = "sed -i -e 's_{{deps.mesonbuild.com.prefix}}/venv/bin/python_/usr/bin/env python_' gdbus-codegen glib-genmarshal glib-mkenums gtester-report"
      working-directory = "{{prefix}}/bin"
    },
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--libdir={{prefix}}/lib",
      "--wrap-mode=nofallback",
      "--buildtype=release",
      "-Dtests=false",
      "-Dintrospection=enabled",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://download.gnome.org/sources/glib/{{ version.major }}.{{ version.minor }}/glib-{{ version }}.tar.xz"
}

runtime {

  env {
    PYTHONPATH = "{{prefix}}/lib/python{{deps.python.org.version.major}}/site-packages:$PYTHONPATH"
  }
}

test {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
  }
  script = [
    {
      if = "linux"
      run = <<EOT
if [ -f /etc/os-release ] && grep -q '^ID=arch' /etc/os-release; then
  echo "Arch Linux detected! Not currently testable."
  exit 0
fi
EOT
    },
    "unset LIBRARY_PATH",
    "unset CPATH",
    "LD_LIBRARY_PATH_BAK=$LD_LIBRARY_PATH",
    "unset LD_LIBRARY_PATH",
    "DYLD_FALLBACK_LIBRARY_PATH_BAK=$DYLD_FALLBACK_LIBRARY_PATH",
    "unset DYLD_FALLBACK_LIBRARY_PATH",
    "cc $CFLAGS test.c $LDFLAGS",
    "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH_BAK",
    "export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH_BAK",
    "./a.out",
    "glib-mkenums --help",
  ]

  env {
    CFLAGS = "$(pkg-config --cflags libpcre2-8 glib-2.0)"
    LDFLAGS = "$(pkg-config --libs libpcre2-8 glib-2.0)"
  }
}

versions {
  gitlab = "gitlab.gnome.org:GNOME/glib"
}
