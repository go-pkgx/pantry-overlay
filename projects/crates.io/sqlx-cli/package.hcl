dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/cargo-sqlx",
  "bin/sqlx",
]

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path sqlx-cli --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/launchbadge/sqlx/archive/refs/tags/{{ version.tag }}.tar.gz"
}

test {
  script = [
    "sqlx database create",
    "sqlx migrate add create_users_table",
    "sqlx migrate run",
  ]

  env {
    DATABASE_URL = "sqlite://test.db"
  }
}

versions {
  github = "launchbadge/sqlx/tags"
}
