dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/md5sum",
  "bin/sha1sum",
  "bin/ripemd160sum",
]
test = [
  "echo \"Hello, world!\" > test.txt",
  "md5sum test.txt > test.txt.md5",
  "sha1sum test.txt > test.txt.sha1",
  "ripemd160sum test.txt > test.txt.ripemd160",
  "md5sum -c test.txt.md5 | grep OK",
  "sha1sum -c test.txt.sha1 | grep OK",
  "ripemd160sum -c test.txt.ripemd160 | grep OK",
]

build {
  script = [
    "./configure --prefix={{prefix}}",
    "make --jobs={{hw.concurrency}}",
    "install -D md5sum {{prefix}}/bin/md5sum",
    {
      run = <<EOT
ln -s md5sum sha1sum
ln -s md5sum ripemd160sum
EOT
      working-directory = "$${{prefix}}/bin"
    },
  ]

  env {
    SSLINCPATH = "$${{deps.openssl.org.prefix}}/include"
    SSLLIBPATH = "$${{deps.openssl.org.prefix}}/lib"
  }
}

distributable {
  strip-components = 1
  url = "http://microbrew.org/tools/md5sha1sum/md5sha1sum-{{version}}.tar.gz"
}

versions {
  match = "/md5sha1sum-\\d+\\.\\d+\\.\\d+\\.tar\\.gz/"
  strip = [
    "/^md5sha1sum-/",
    "/\\.tar\\.gz$/",
  ]
  url = "http://microbrew.org/tools/md5sha1sum/"
}
