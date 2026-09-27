dependencies = {
  "curl.se" = "^8"
  "facebook.com/zstd" = "^1"
  "openssl.org" = "^3"
}
provides = [
  "bin/zck",
  "bin/unzck",
  "bin/zck_delta_size",
  "bin/zck_gen_zdict",
  "bin/zck_read_header",
  "bin/zckdl",
]
test = [
  {
    fixture = "hello zchunk roundtrip"
    run = "cp $FIXTURE greeting.txt"
  },
  "zck greeting.txt",
  "test -f greeting.txt.zck",
  "rm greeting.txt",
  "unzck greeting.txt.zck",
  "test \"$(cat greeting.txt)\" = \"hello zchunk roundtrip\"",
]

build {
  dependencies = {
    "mesonbuild.com" = "*"
    "ninja-build.org" = "*"
  }
  script = [
    {
      if = "darwin"
      prop = <<EOT
[wrap-file]
directory = argp-standalone-1.5.0
source_url = https://github.com/argp-standalone/argp-standalone/archive/refs/tags/1.5.0.tar.gz
source_filename = argp-standalone-1.5.0.tar.gz
source_hash = c29eae929dfebd575c38174f2c8c315766092cec99a8f987569d0cad3c6d64f6

[provide]
dependency_names = argp-standalone
EOT
      run = "cp $PROP subprojects/argp-standalone.wrap"
    },
    "meson setup build $ARGS",
    "meson compile -C build --jobs {{ hw.concurrency }}",
    "meson install -C build",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--buildtype=release",
      "-Ddocs=false",
      "-Dtests=false",
      "--wrap-mode=default",
      "--force-fallback-for=argp-standalone",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/zchunk/zchunk/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "zchunk/zchunk/tags"
}
