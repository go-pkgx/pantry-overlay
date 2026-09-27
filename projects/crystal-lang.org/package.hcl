companions = {
  "crystal-lang.org/shards" = "*"
}
dependencies = {
  "freedesktop.org/pkg-config" = "^0"
  "gnu.org/gmp" = "^6"
  "hboehm.info/gc" = "^8"
  "invisible-island.net/ncurses" = "^6"
  "libevent.org" = "^2"
  "llvm.org" = "<17"
  "openssl.org" = "^3"
  "pcre.org/v2" = "^10"
  "pyyaml.org/libyaml" = "^0"
  "sourceware.org/libffi" = "^3"
}
provides = [
  "bin/crystal",
]
test = [
  {
    fixture = {
      content = "puts {{Crystal::VERSION}}"
      extname = "cr"
    }
    run = "crystal build -o test $FIXTURE"
  },
  "test \"$(./test)\" = \"{{version}}\"",
  "test \"$(crystal eval 'puts {{Crystal::VERSION}}')\" = \"{{version}}\"",
  {
    fixture = {
      content = "puts {{Crystal::VERSION}}"
      extname = "cr"
    }
    run = "test \"$(cat $FIXTURE | crystal eval)\" = \"{{version}}\""
  },
]
warnings = [
  "vendored",
]

build {
  dependencies = {
    "curl.se" = "*"
    "linux/aarch64" = {
      "gnu.org/binutils" = "*"
    }
  }
  env = {
    ARGS = [
      "release=true",
      "FLAGS=--no-debug",
      "interpreter=true",
      "CRYSTAL_CONFIG_PATH=../lib",
    ]
    CRYSTAL_LIBRARY_PATH = "$LD_LIBRARY_PATH"
    LDFLAGS = "-Wl,-rpath,{{pkgx.prefix}}"
    PATH = "$SRCROOT/.bootstrap/bin:$PATH"
    darwin = {
      PLATFORM = "darwin-universal"
    }
    linux = {
      CC = "clang"
      CXX = "clang++"
      LD = "clang"
    }
    "linux/x86-64" = {
      PLATFORM = "linux-x86_64"
    }
  }
  script = [
    {
      run = <<EOT
if test '{{hw.platform}}+{{hw.arch}}' = 'linux+aarch64'; then
  curl -L "https://packagecloud.io/84codes/crystal/packages/any/any/crystal_1.13.3-145_arm64.deb/download.deb?distro_version_id=35" -o crystal.deb
  ar x crystal.deb
  tar zxf data.tar.gz --strip-components=2
else
  curl -Lf "https://github.com/crystal-lang/crystal/releases/download/{{version}}/crystal-{{version}}-1-$PLATFORM.tar.gz" | tar --strip-components=1 -zxf -
fi
EOT
      working-directory = ".bootstrap"
    },
    "mkdir -p .build",
    "make deps",
    {
      if = "linux"
      run = "export LDFLAGS=\"$LDFLAGS -Wl,-ltinfow\""
    },
    "make crystal $ARGS",
    "mkdir -p \"{{prefix}}/bin\"",
    "cp .build/crystal \"{{prefix}}/bin/crystal.bin\"",
    "cp props/shim \"{{prefix}}/bin/crystal\"",
    "cp -a src \"{{prefix}}/lib\"",
    {
      if = "=1.14.0"
      run = <<EOT
if test "{{hw.platform}}" = "darwin"; then
  sed -i 's/mask = LibC::SigsetT.new$/mask = LibC::SigsetT.new(0_u32)/' pthread.cr
fi
EOT
      working-directory = "$${{prefix}}/lib/crystal/system/unix"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/crystal-lang/crystal/archive/refs/tags/{{ version }}.tar.gz"
}

runtime {

  env {
    CRYSTAL_LINK_FLAGS = "-Wl,-rpath,{{prefix}}/../.."
    CRYSTAL_PATH = "$${{prefix}}/lib:$CRYSTAL_PATH"
  }
}

versions {
  github = "crystal-lang/crystal"
}
