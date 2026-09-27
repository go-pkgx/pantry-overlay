dependencies = {
  "gnupg.org/libgpg-error" = "^1"
}
provides = [
  "bin/libassuan-config",
]
test = "test \"$(libassuan-config --version)\" = \"{{version}}\""

build {
  dependencies = {
    "gnupg.org/libgpg-error" = 1
  }
  script = [
    "./configure --prefix={{prefix}}",
    "make",
    "make check",
    "make install",
  ]

  env {

    darwin {
      CFLAGS = "$CFLAGS -std=gnu89"
      CXXFLAGS = "$CXXFLAGS -stdlib=libstdc++ -std=c++03"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://gnupg.org/ftp/gcrypt/libassuan/libassuan-{{version}}.tar.bz2"
}

versions {
  match = "/libassuan-(\\d+\\.\\d+(\\.\\d+)?)\\.tar\\.bz2/"
  strip = [
    "/libassuan-/",
    "/.tar.bz2/",
  ]
  url = "https://gnupg.org/ftp/gcrypt/libassuan/"
}
