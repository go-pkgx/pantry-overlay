dependencies = {
  "gnu.org/libiconv" = "^1"
  "openssl.org" = "^3"
}
provides = [
  "bin/raccoin",
]
test = "test \"$(raccoin --version)\" = \"raccoin v{{version}}\""

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      run = <<EOT
sed -i \
    -e'1a\
const VERSION: &str = "{{version}}";' \
main.rs
EOT
      working-directory = "src"
    },
    {
      if = "<0.2.0"
      run = <<EOT
sed -i \
    -e'/let portfolio_file: PathBuf = portfolio_file.into();/i\
        if portfolio_file == "--version" {\
            println!("raccoin v{VERSION}");\
            return Ok(());\
        }' \
main.rs
EOT
      working-directory = "src"
    },
    {
      if = ">=0.2.0"
      run = <<EOT
sed -i \
    -e'/let Some(portfolio_file)/i\
    if let Some(arg1) = env::args_os().nth(1) {\
        if arg1 == "--version" {\
            println!("raccoin v{VERSION}");\
            return Ok(());\
        }\
    }' \
main.rs
EOT
      working-directory = "src"
    },
    "cargo install --locked --path . --root {{prefix}}",
  ]

  env {

    linux {
      LD = "clang"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/bjorn/raccoin/archive/refs/tags/v{{ version }}.tar.gz"
}

versions {
  github = "bjorn/raccoin"
  strip = "/v/"
}
