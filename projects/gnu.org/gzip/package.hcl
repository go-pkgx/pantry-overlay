provides = [
  "bin/gzip",
  "bin/gunzip",
  "bin/zcat",
]

build {
  script = [
    "./configure --prefix={{ prefix }}",
    "make --jobs {{ hw.concurrency }} install",
  ]
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/gzip/gzip-{{ version.raw }}.tar.xz"
}

test {
  script = [
    "echo \"the quick brown fox\" > t.txt",
    "gzip t.txt",
    "test -f t.txt.gz",
    "gunzip t.txt.gz",
    "test \"$(cat t.txt)\" = \"the quick brown fox\"",
  ]
}

versions {
  match = "/gzip-(\\d+\\.\\d+(\\.\\d+)?)\\.tar\\.xz/"
  strip = [
    "/gzip-/",
    "/\\.tar\\.xz/",
  ]
  url = "https://ftp.gnu.org/gnu/gzip/"
}
