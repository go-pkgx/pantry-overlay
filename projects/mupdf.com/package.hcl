dependencies = {
  darwin = {
    "libarchive.org" = "^3"
  }
  "freetype.org" = "^2"
  "github.com/google/brotli" = "^1"
  "harfbuzz.org" = "^9"
  "info-zip.org/unzip" = "^6"
  "jbig2dec.com" = "^0"
  linux = {
    "freedesktop.org/mesa-glu" = "^9"
    "freeglut.sourceforge.io" = "^3"
    "gnome.org/glib" = "^2"
    "mesa3d.org" = "^23"
    "x.org/protocol" = ">=2022"
    "x.org/x11" = "^1"
    "x.org/xcursor" = "^1"
    "x.org/xinerama" = "^1"
    "x.org/xrandr" = "^1"
    "x.org/xtrans" = "^1"
  }
  "mujs.com" = "^1"
  "openjpeg.org" = "^2"
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/mudraw",
  "bin/mupdf-gl",
  "bin/mutool",
]
test = [
  "mudraw -F txt test.pdf | grep 'pkgx test'",
]

build {
  dependencies = {
    "git-scm.org" = "*"
  }
  script = [
    "git submodule update --init --recursive $SUBMODULES",
    {
      if = ">=1.27"
      run = "sed -i 's|\"\\.\\./thirdparty/mujs/regexp\\.h\"|\"../../thirdparty/mujs/regexp.h\"|' stext-search.c"
      working-directory = "source/fitz"
    },
    {
      if = "darwin"
      run = [
        "declare -a DARWIN_ARGS",
        "DARWIN_ARGS=( SYS_FREETYPE_CFLAGS=\"$(pkg-config --cflags freetype2)\" SYS_FREETYPE_LIBS=\"$(pkg-config --libs freetype2)\" SYS_HARFBUZZ_CFLAGS=\"$(pkg-config --cflags harfbuzz)\" SYS_HARFBUZZ_LIBS=\"$(pkg-config --libs harfbuzz)\" )",
      ]
    },
    "make $ARGS \"$${DARWIN_ARGS[@]}\" install",
    {
      run = "ln -sf mutool mudraw"
      working-directory = "$${{prefix}}/bin"
    },
    {
      if = "darwin"
      run = [
        "install_name_tool -change build/shared-release/libmupdf.dylib @loader_path/../lib/libmupdf.dylib bin/mutool",
        "install_name_tool -change build/shared-release/libmupdf.dylib @loader_path/../lib/libmupdf.dylib bin/mupdf-gl",
        "rm lib/libmupdf.dylib",
        "cp $SRCROOT/build/shared-release/libmupdf.dylib lib/",
      ]
      working-directory = "$${{prefix}}"
    },
  ]

  env {
    ARGS = [
      "prefix={{prefix}}",
      "build=release",
      "shared=yes",
      "verbose=yes",
      "USE_SYSTEM_LIBS=yes",
      "USE_SYSTEM_MUJS=yes",
    ]
    AS = "llvm-as"
    CC = "clang"
    CPATH = "$SRCROOT/thirdparty/gumbo-parser/src:$SRCROOT/thirdparty/mujs:$CPATH"
    CXX = "clang++"
    LD = "clang"
    SUBMODULES = [
      "thirdparty/extract",
      "thirdparty/lcms2",
      "thirdparty/gumbo-parser",
      "thirdparty/mujs",
      "thirdparty/cmark-gfm",
    ]

    darwin {
      LDFLAGS = "$LDFLAGS -Wl,-undefined,dynamic_lookup"
    }

    linux {
      LDFLAGS = "$LDFLAGS -Wl,-allow-shlib-undefined"
    }
  }
}

distributable {
  ref = "$${{version}}"
  url = "git+https://github.com/ArtifexSoftware/mupdf"
}

versions {
  github = "ArtifexSoftware/mupdf/tags"
}
