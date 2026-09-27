dependencies = {
  "curl.se" = 8
  "openssl.org" = "^3"
}
distributable = null
provides = [
  "bin/install_compass",
  "bin/mongod",
  "bin/mongos",
]
warnings = [
  "vendored",
]

build {
  dependencies = null
  env = {
    "darwin/aarch64" = {
      DIST = "https://fastdl.mongodb.org/osx/mongodb-macos-arm64-{{version}}.tgz"
    }
    "darwin/x86-64" = {
      DIST = "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-{{version}}.tgz"
    }
    "linux/aarch64" = {
      DIST = "https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-ubuntu2004-{{version}}.tgz"
    }
    "linux/x86-64" = {
      DIST = "https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-ubuntu2004-{{version}}.tgz"
    }
  }
  script = [
    "curl -L \"$DIST\" | tar xzf - --strip-components=1",
    "mkdir -p \"{{prefix}}/bin\"",
    "cp -a bin/* \"{{prefix}}/bin\"",
  ]
}

test {
  dependencies = {
    linux = {
      "crates.io/semverator" = "*"
    }
    "mongodb.com/shell" = "*"
    "npmjs.com" = "*"
  }
  script = [
    {
      if = "darwin"
      run = <<EOT
if test "$(sw_vers -productVersion | cut -d . -f 1)" -lt 14; then
  exit 0
fi
EOT
    },
    {
      if = "linux"
      run = <<EOT
LIBCV=$(getconf GNU_LIBC_VERSION | sed 's/^glibc //')
if ! semverator gt $LIBCV 2.30; then
  echo "Skipping test on glibc $LIBCV"
  exit 0
fi
EOT
    },
    "mkdir -p data/{db,log/mongodb}",
    {
      if = "linux"
      run = "mongod --dbpath data/db --logpath data/log/mongodb/mongo.log --port $PORT --fork"
    },
    {
      if = "darwin"
      run = [
        "mongod --dbpath data/db --logpath data/log/mongodb/mongo.log --port $PORT &",
        "PID=$!",
        "sleep 5",
      ]
    },
    "mongosh --port $PORT --eval 'db.version()'",
    "mongosh --port $PORT --eval 'db.adminCommand({ shutdown: 1 })' || true",
  ]

  env {
    PORT = "$(npx --yes get-port-cli | tail -n1)"
  }
}

versions {
  github = "mongodb/mongo/tags"
  strip = "/^r/"
}
