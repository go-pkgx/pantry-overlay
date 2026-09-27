dependencies = {
  "openssl.org" = "^3"
}
display-name = "chomp"
provides = [
  "bin/chomp",
]
test = [
  "test \"$(chomp --version)\" = \"Chomp {{version}}\"",
  {
    fixture = <<EOT
version = 0.1

[[task]]
target = 'name.txt'
run = '''
  echo "No name.txt, writing one."
  echo "World" > name.txt
'''

[[task]]
name = 'hello'
target = 'hello.txt'
dep = 'name.txt'
run = '''
  echo "Hello $(cat name.txt)" > hello.txt
'''
EOT
    run = "cp $FIXTURE chompfile.toml"
  },
  "test ! -f hello.txt",
  "test ! -f name.txt",
  "chomp hello | tee out.log",
  "grep 'writing one' out.log",
  "grep hello.txt out.log",
  "grep name.txt out.log",
  "test \"$(cat hello.txt)\" = \"Hello World\"",
  "test \"$(cat name.txt)\" = \"World\"",
]

build {
  dependencies = {
    "rust-lang.org" = "^1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    {
      run = "sed -i 's/let version = \".*\";/let version = \"{{version}}\";/' main.rs"
      working-directory = "src"
    },
    "cargo install --locked --path . --root {{prefix}}",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/guybedford/chomp/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "guybedford/chomp"
}
