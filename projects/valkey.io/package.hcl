dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/valkey-server",
  "bin/valkey-cli",
  "bin/valkey-benchmark",
]
test = [
  "valkey-server --daemonize yes",
  "sleep 5",
  "valkey-cli --raw SET key123 value123",
  "test \"$(valkey-cli --raw GET key123)\" = \"value123\"",
  "valkey-cli shutdown",
]

build {
  script = "make install"

  env {
    BUILD_TLS = "yes"
    PREFIX = "$${{prefix}}"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/valkey-io/valkey/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "valkey-io/valkey"
}
