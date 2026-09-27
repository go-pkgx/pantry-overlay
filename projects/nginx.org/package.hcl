dependencies = {
  "openssl.org" = "^3"
  "pcre.org" = 8.45
  "zlib.net" = "^1.2.13"
}
provides = [
  "sbin/nginx",
]

build {
  script = <<EOT
./configure $ARGS
make --jobs {{ hw.concurrency }}
make install
EOT

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--with-http_ssl_module",
      "--with-stream",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://nginx.org/download/nginx-{{version}}.tar.gz"
}

test {
  script = [
    {
      if = "linux"
      run = "if ! getent group nogroup; then exit 0; fi"
    },
    "sed -i.bak -e 's/80/8080/g' {{prefix}}/conf/nginx.conf",
    "nginx -p {{prefix}} -c {{prefix}}/conf/nginx.conf -t",
  ]
}

versions {
  github = "nginx/nginx/tags"
  strip = "/^release-/"
}
