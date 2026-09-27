dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/redis-server",
  "bin/redis-cli",
  "bin/redis-benchmark",
]
test = [
  "redis-server --daemonize yes",
  "redis-cli --raw SET key123 value123",
  "test \"$(redis-cli --raw GET key123)\" = \"value123\"",
  "redis-cli shutdown",
]

build {
  env = {
    BUILD_TLS = "yes"
    darwin = {
      LDFLAGS = "-rpath {{pkgx.prefix}}"
    }
    "linux/x86-64" = {
      CFLAGS = "-fPIC"
      CXXFLAGS = "-fPIC"
      LDFLAGS = "-pie"
    }
  }
  script = [
    "make install PREFIX=\"{{prefix}}\"",
  ]
}

distributable {
  strip-components = 1
  url = "https://download.redis.io/releases/redis-{{ version }}.tar.gz"
}

versions {
  github = "redis/redis"
}
