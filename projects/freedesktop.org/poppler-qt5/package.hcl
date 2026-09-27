dependencies = {
  "cairographics.org" = "^1"
  "curl.se" = "^8"
  darwin = {
    "gnupg.org/libassuan" = "^2"
  }
  "freedesktop.org/fontconfig" = "^2"
  "freetype.org" = "^2"
  "gnome.org/glib" = "^2"
  "gnome.org/libxml2" = "~2.13"
  "gnome.org/libxslt" = "~1.1.44"
  "gnu.org/gettext" = "^1"
  "gnupg.org/gpgme" = "^1"
  "gnupg.org/libassuan" = "^2"
  "gnupg.org/libgpg-error" = "^1"
  "libjpeg-turbo.org" = "^2"
  "libpng.org" = "^1"
  linux = {
    "gnu.org/gcc" = "*"
  }
  "littlecms.com" = "^2"
  "mozilla.org/nss" = "^3"
  "openjpeg.org" = "^2"
  "qt.io" = "~5"
  "simplesystems.org/libtiff" = "^4"
}
display-name = "poppler-qt5"
provides = [
  "bin/pdfattach",
  "bin/pdfdetach",
  "bin/pdffonts",
  "bin/pdfimages",
  "bin/pdfinfo",
  "bin/pdfseparate",
  "bin/pdfsig",
  "bin/pdftocairo",
  "bin/pdftohtml",
  "bin/pdftoppm",
  "bin/pdftops",
  "bin/pdftotext",
  "bin/pdfunite",
]
test = [
  "pdfinfo lorem.pdf | grep \"Lorem Ipsum\"",
  "pkg-config --modversion poppler-qt5 | grep \"{{version.raw}}\"",
]

build {
  dependencies = {
    "cmake.org" = "*"
    "gnome.org/gobject-introspection" = "*"
    linux = {
      "gnu.org/binutils" = "^2"
      "llvm.org" = "~22.1"
    }
  }
  script = [
    {
      if = "linux"
      run = <<EOT
ORIG_AS="$(command -v as)"
if echo $ORIG_AS | grep llvm.org; then
  mv $${ORIG_AS}{,.bak}
fi
EOT
    },
    {
      run = [
        "cmake .. $CMAKE_ARGS",
        "make --jobs {{ hw.concurrency }} install",
        "make clean",
        "cmake .. -DBUILD_SHARED_LIBS=OFF $CMAKE_ARGS",
        "make --jobs {{ hw.concurrency }}",
        "install libpoppler.a cpp/libpoppler-cpp.a glib/libpoppler-glib.a {{prefix}}/lib/",
      ]
      working-directory = "build"
    },
    {
      run = [
        "curl -L \"$FONT_DATA\" | tar -xz --strip-components=1",
        "make install prefix={{prefix}}",
      ]
      working-directory = "font-data"
    },
    {
      if = "linux"
      run = <<EOT
if test -e "$${ORIG_AS}.bak"; then
  mv $${ORIG_AS}{.bak,}
fi
EOT
    },
  ]

  env {
    CMAKE_ARGS = [
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}",
      "-DCMAKE_INSTALL_LIBDIR=lib",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_FIND_FRAMEWORK=LAST",
      "-DCMAKE_VERBOSE_MAKEFILE=ON",
      "-Wno-dev",
      "-DBUILD_TESTING=OFF",
      "-DBUILD_GTK_TESTS=OFF",
      "-DENABLE_BOOST=OFF",
      "-DENABLE_CMS=lcms2",
      "-DENABLE_GLIB=ON",
      "-DENABLE_QT5=ON",
      "-DENABLE_QT6=OFF",
      "-DENABLE_NSS3=OFF",
      "-DENABLE_UNSTABLE_API_ABI_HEADERS=ON",
      "-DRUN_GPERF_IF_PRESENT=OFF",
      "-DWITH_GObjectIntrospection=ON",
    ]
    FONT_DATA = "https://poppler.freedesktop.org/poppler-data-0.4.12.tar.gz"

    linux {
      CC = "gcc"
      CXX = "g++"
      LD = "ld.gold"
      LDFLAGS = "$LDFLAGS -lstdc++fs"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://poppler.freedesktop.org/{{version.tag}}.tar.xz"
}

versions {
  gitlab = "gitlab.freedesktop.org:poppler/poppler/tags"
  strip = "/^poppler-/"
}
