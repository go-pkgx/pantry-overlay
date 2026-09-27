dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
provides = [
  "bin/forc",
]

build {
  dependencies = {
    "gnu.org/make" = "*"
    "perl.org" = "*"
    "rust-lang.org" = "^1.78"
    "rust-lang.org/cargo" = "^0"
  }
  script = "cargo install --locked --path forc --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/FuelLabs/sway/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  fixture = <<EOT
script;

#[test]
fn test_meaning_of_life() {
    assert(6 * 7 == 42);
}

fn main() {
    ()
}
EOT
  script = [
    "forc new pkgx_test",
    "cd pkgx_test",
    "cat $FIXTURE >src/main.sw",
    "forc test",
  ]
}

versions {
  github = "FuelLabs/sway"
}
