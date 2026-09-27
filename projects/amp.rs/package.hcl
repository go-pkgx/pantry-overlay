dependencies = {
  "libgit2.org" = 1
  linux = {
    "openssl.org" = "^3"
  }
  "zlib.net" = 1
}
provides = [
  "bin/amp",
]
test = [
  "test \"$(amp --version)\" = \"amp {{version}}\"",
  "amp --help",
]

build {
  dependencies = {
    "rust-lang.org" = "^1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      prop = <<EOT
/fn main() {/a\\
    let first_arg = std::env::args().nth(1);\\
    if first_arg == Some("--version".to_string()) {\\
        println!("amp {{ version }}");\\
        return;\\
    } else if first_arg == Some("--help".to_string()) {\\
        println!("See https://amp.rs for complete documentation.");\\
        return;\\
    }\\
EOT
      run = "sed -i -f $PROP main.rs"
      working-directory = "src"
    },
    "cargo install --locked --path . --root {{prefix}}",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/jmacdonald/amp/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "jmacdonald/amp"
}
