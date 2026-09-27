dependencies = {
  "curl.se" = "*"
  "facebook.com/zstd" = "*"
  "lz4.org" = "*"
  "openssl.org" = "^3"
  "zlib.net" = "*"
}

build {
  dependencies = {
    linux = {
      "llvm.org" = "*"
    }
    "python.org" = "~3.11"
  }
  script = [
    "./configure --prefix=\"{{prefix}}\"",
    "make --jobs {{ hw.concurrency }}",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {

    linux {
      AR = "llvm-ar"
      AS = "llvm-as"
      CC = "clang"
      CXX = "clang++"
      LD = "clang"
      LDFLAGS = "$LDFLAGS -Wl,--undefined-version"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/confluentinc/librdkafka/archive/refs/tags/v{{version}}.tar.gz"
}

test {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
  }
  script = "pkg-config --modversion rdkafka | grep {{version}}"
}

versions {
  match = "/\"tag_name\":\"v\\d+\\.\\d+\\.\\d+\",/"
  strip = [
    "/^\"tag_name\":\"v/",
    "/\",$/",
  ]
  url = "https://api.github.com/repos/confluentinc/librdkafka/releases?per_page=100&page=1"
}
