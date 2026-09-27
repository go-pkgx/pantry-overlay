companions = {
  "npmjs.com" = "*"
}
dependencies = {
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
  "openssl.org" = "^3"
  "unicode.org" = "^73"
  "zlib.net" = 1
}
provides = [
  "bin/node",
]

build {
  dependencies = {
    linux = {
      "gnu.org/gcc" = 14
    }
    "ninja-build.org" = "*"
    "python.org" = "~3.10"
  }
  env = {
    ARGS = [
      "--ninja",
      "--with-intl=system-icu",
      "--without-npm",
      "--prefix={{ prefix }}",
      "--shared-openssl",
      "--shared-zlib",
    ]
    linux = {
      CC = "gcc"
    }
    "linux/x86-64" = {
      CFLAGS = "-fPIC"
      CXXFLAGS = "-fPIC"
    }
  }
  script = [
    {
      if = "<14"
      run = "python configure.py $ARGS"
    },
    {
      if = ">=14"
      run = "./configure $ARGS"
    },
    {
      if = "^22"
      run = <<EOT
sed -i '/wasm-disassembler.h/a\
\
#include <iomanip>' wasm-disassembler.cc
EOT
      working-directory = "deps/v8/src/wasm"
    },
    {
      if = "^23.5.0"
      run = "export LDFLAGS=\"$(echo $LDFLAGS | sed 's/-pie//')\""
    },
    {
      if = "^25"
      prop = <<EOT
s/simdutf::atomic_base64_to_binary_safe/simdutf::base64_to_binary_safe/g
s/simdutf::atomic_binary_to_base64/simdutf::binary_to_base64/g
EOT
      run = "sed -i -f $PROP builtins-typed-array.cc"
      working-directory = "deps/v8/src/builtins"
    },
    "make --jobs {{ hw.concurrency }} JOBS={{ hw.concurrency }} install",
  ]
}

distributable {
  strip-components = 1
  url = "https://nodejs.org/dist/v{{ version }}/node-v{{ version }}.tar.xz"
}

interprets {
  args = "node"
  extensions = "js"
}

test {
  fixture = "console.log(\"Hello, world!\");"
  script = [
    "out=$(node $FIXTURE)",
    "test \"$out\" = \"Hello, world!\"",
  ]
}

versions {
  github = "nodejs/node/tags"
}
