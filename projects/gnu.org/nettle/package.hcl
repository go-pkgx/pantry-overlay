dependencies = {
  "gnu.org/gmp" = "^6"
}
provides = [
  "bin/nettle-hash",
  "bin/nettle-lfib-stream",
  "bin/nettle-pbkdf2",
  "bin/pkcs1-conv",
  "bin/sexp-conv",
]
test = [
  {
    fixture = {
      content = <<EOT
#include <nettle/sha1.h>
#include <stdio.h>

int main()
{
  struct sha1_ctx ctx;
  uint8_t digest[SHA1_DIGEST_SIZE];
  unsigned i;

  sha1_init(&ctx);
  sha1_update(&ctx, 4, "test");
  sha1_digest(&ctx, SHA1_DIGEST_SIZE, digest);

  printf("SHA1(test)=");

  for (i = 0; i<SHA1_DIGEST_SIZE; i++)
    printf("%02x", digest[i]);

  printf("\\n");
  return 0;
}
EOT
      extname = "c"
    }
    if = "<4"
    run = "cc -lnettle -o test $FIXTURE"
  },
  {
    fixture = {
      content = <<EOT
#include <nettle/sha1.h>
#include <stdio.h>

int main()
{
  struct sha1_ctx ctx;
  uint8_t digest[SHA1_DIGEST_SIZE];
  unsigned i;

  sha1_init(&ctx);
  sha1_update(&ctx, 4, "test");
  sha1_digest(&ctx, digest);

  printf("SHA1(test)=");

  for (i = 0; i<SHA1_DIGEST_SIZE; i++)
    printf("%02x", digest[i]);

  printf("\\n");
  return 0;
}
EOT
      extname = "c"
    }
    if = ">=4"
    run = "cc -lnettle -o test $FIXTURE"
  },
  "./test",
]

build {
  dependencies = {
    "gnu.org/gmp" = "*"
    "gnu.org/m4" = "*"
  }
  script = [
    "./configure --prefix={{ prefix }}",
    "make --jobs {{ hw.concurrency }} install",
  ]
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/nettle/nettle-{{version.raw}}.tar.gz"
}

versions {
  match = "/nettle-\\d+(\\.\\d+)+\\.tar\\.gz/"
  strip = [
    "/^nettle-/",
    "/\\.tar\\.gz$/",
  ]
  url = "https://ftp.gnu.org/gnu/nettle"
}
