dependencies = {
  "github.com/Cyan4973/xxHash" = "^0.8"
  "pkgx.sh" = ">=1"
}
provides = [
  "bin/borg",
  "bin/borgfs",
]

build {
  dependencies = {
    "facebook.com/zstd" = "*"
    linux = {
      "savannah.nongnu.org/acl" = "^2.3.1"
    }
    "lz4.org" = "*"
    "openssl.org" = "^3"
    "python.org" = "^3.10"
  }
  script = [
    "bkpyvenv stage {{prefix}} {{version}}",
    "$${{prefix}}/venv/bin/pip install -r requirements.d/development.txt",
    "$${{prefix}}/venv/bin/pip install .",
    "bkpyvenv seal {{prefix}} borg borgfs",
  ]

  env {
    BORG_LIBACL_PREFIX = "{{deps.savannah.nongnu.org/acl.prefix}}"
    BORG_LIBLZ4_PREFIX = "{{deps.lz4.org.prefix}}"
    BORG_LIBXXHASH_PREFIX = "{{deps.github.com/Cyan4973/xxHash.prefix}}"
    BORG_LIBZSTD_PREFIX = "{{deps.facebook.com/zstd.prefix}}"
    BORG_OPENSSL_PREFIX = "{{deps.openssl.org.prefix}}"
    TMPDIR = "$(mktemp -d)"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/borgbackup/borg/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  fixture = <<EOT
# borg test fixture
EOT
  script = [
    "borg --version | grep \"^borg {{version}}\"",
    "borg init --encryption=none test-repo",
    "borg create --compression zstd test-repo::test-archive $FIXTURE",
    "borg list test-repo | grep \"test-archive\"",
    "borg extract test-repo::test-archive",
    "test \"# borg test fixture\" = \"$(cat .$FIXTURE)\"",
  ]
}

versions {
  github = "borgbackup/borg"
}
