dependencies = {
  "openssl.org" = "^3"
  "pcre.org" = 8
  "perl.org" = "*"
  "zlib.net" = "^1.2"
}
provides = [
  "bin/nginx-xml2pod",
  "bin/opm",
  "bin/resty",
  "bin/restydoc",
  "bin/restydoc-index",
]
test = [
  "resty -V",
  "resty -V 2>&1 | grep 'openresty/{{version}}'",
]

build {
  dependencies = {
    "git-scm.org" = "*"
    "gnu.org/wget" = "*"
    "mercurial-scm.org" = "*"
    "waterlan.home.xs4all.nl/dos2unix" = "*"
  }
  script = [
    {
      run = "make"
    },
    {
      run = [
        "./configure --prefix={{ prefix }}",
        "make -j {{ hw.concurrency }}",
        "make install",
      ]
      working-directory = "openresty-{{version}}"
    },
    {
      run = [
        "ln -sf ../nginx/sbin/nginx openresty",
        "sed -i -e '2i use File::Basename qw(dirname);' -e \"s|'{{prefix}}|dirname(\\$0) . '/..|g\" resty",
      ]
      working-directory = "$${{prefix}}/bin"
    },
    {
      run = [
        "mv ../nginx/sbin/nginx .",
        "ln -s ../../bin/nginx ../nginx/sbin/",
      ]
      working-directory = "$${{prefix}}/bin"
    },
    {
      run = "ln -s luajit/lib ."
      working-directory = "$${{prefix}}"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/openresty/openresty/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "openresty/openresty"
}
