dependencies = {
  "curl.se" = "^8.4"
  "openssl.org" = "^3"
}
provides = [
  "bin/leo",
]
test = [
  "leo new helloworld",
  "cd helloworld",
  "leo build",
  {
    if = "<2"
    run = "leo build | grep \"Compiled 'main.leo' into Aleo instructions\""
  },
  {
    if = ">=2"
    run = "leo build | grep \"Compiled 'helloworld.aleo' into Aleo instructions\""
  },
  "leo run main 21u32 32u32 | grep \"53u32\"",
  "leo --version | grep {{version}}",
]

build {
  dependencies = {
    "cmake.org" = "^3"
    "git-scm.org" = 2
    "github.com/mikefarah/yq" = ">=4"
    "rust-lang.org" = "^1.65"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "git submodule update --init --recursive",
    {
      if = "=4.0.2"
      run = [
        "yq -i '(.workspace.dependencies[] | select(has(\"path\")).version) = \"={{version}}\"' Cargo.toml",
        "for f in $(find crates -name Cargo.toml); do yq -i '(.package | select(has(\"version\")).version) = \"{{version}}\"' \"$f\"; done",
      ]
    },
    {
      if = "<4"
      run = "cargo install --locked --path . --root {{prefix}}"
    },
    {
      if = ">=4"
      run = "cargo install --locked --path crates/leo --root {{prefix}}"
    },
  ]
}

distributable {
  ref = "$${{version.tag}}"
  url = "git+https://github.com/AleoHQ/leo"
}

versions {
  github = "AleoHQ/leo"
}
