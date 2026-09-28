dependencies = {
  "openssl.org" = "^3"
}

build {
  dependencies = {
    "rust-lang.org" = ">=1.85"
  }
  script = [
    "cargo build --release --no-default-features --features crypto-openssl",
    {
      run               = "install -Dm755 $SRCROOT/target/release/librpm_sequoia.so librpm_sequoia.so"
      working-directory = "$${{prefix}}/lib/"
    },
    {
      if                = "linux"
      run               = "ln -s librpm_sequoia.so librpm_sequoia.so.1"
      working-directory = "$${{prefix}}/lib"
    },
    {
      run               = "sed 's|/usr/local|{{prefix}}|' $SRCROOT/target/release/rpm-sequoia.pc >rpm-sequoia.pc"
      working-directory = "$${{prefix}}/lib/pkgconfig/"
    },
  ]

  env {
    OPENSSL_DIR = "{{deps.openssl.org.prefix}}"
  }
}

test {
  dependencies = {
    "gnu.org/gcc" = "*"
  }
  script = [
    "test -f {{prefix}}/lib/librpm_sequoia.so",
    "test -f {{prefix}}/lib/pkgconfig/rpm-sequoia.pc",
    "pkg-config --exists rpm-sequoia",
    {
      fixture = {
        content = <<EOT
#include <stdio.h>

int main(void) {
  puts("rpm-sequoia library linkage test passed");
  return 0;
}
EOT
        extname = "c"
      }
      run = "gcc -v $FIXTURE -o test_link $(pkg-config --cflags --libs rpm-sequoia)"
    },
    "./test_link",
  ]
}
