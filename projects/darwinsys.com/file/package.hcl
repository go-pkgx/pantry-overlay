dependencies = {
  "sourceware.org/bzip2" = "^1"
  "tukaani.org/xz" = "^5"
  "zlib.net" = 1
}
provides = [
  "bin/file",
]
test = "file {{prefix}}/bin/file"

build {
  dependencies = {
    "gnu.org/patch" = "*"
  }
  script = [
    "patch -p1 <props/relocatable.diff",
    {
      if = ">=5.45"
      run = "sed -i -e 's/^protected const char/file_protected const char/' magic.c"
      working-directory = "src"
    },
    "./configure --prefix={{prefix}}",
    "make --jobs {{hw.concurrency}} install",
    "cp -a magic/Magdir {{prefix}}/share/misc/magic",
  ]
}

distributable {
  strip-components = 1
  url = "https://astron.com/pub/file/file-{{version.raw}}.tar.gz"
}

versions {
  match = "/file-\\d+\\.\\d+\\.tar\\.gz/"
  strip = [
    "/file-/",
    "/.tar.gz/",
  ]
  url = "https://astron.com/pub/file/"
}
