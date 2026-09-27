dependencies = {
  "dri.freedesktop.org" = "*"
  "elfutils.org" = "*"
  "github.com/numactl/numactl" = "*"
}
display-name = "ROCr"
platforms = [
  "linux/x86-64",
]
provides = []

build {
  dependencies = {
    "cmake.org" = "^3"
    "freedesktop.org/pkg-config" = "*"
    "gnu.org/coreutils" = "*"
  }
  script = [
    <<EOT
h=../runtime/hsa-runtime/core/inc/signal.h
awk '/^\/\/ Allow hsa_signal_t to be keys in STL structures\.$/ {
       print "inline bool operator<(const hsa_signal_t\& x, const hsa_signal_t\& y) { return x.handle < y.handle; }"
       print ""
     }
     { print }' "$h" > "$h.new"
mv "$h.new" "$h"
grep -q 'inline bool operator<(const hsa_signal_t' "$h" \
  || { echo "signal.h did not take the operator< insertion" >&2; exit 1; }
EOT
,
    <<EOT
found=0
for s in $(grep -rl 'xxd -i' .. --include='*.sh'); do
  {
    echo '#!/bin/sh -e'
    echo 'xxd() {'
    echo '  f=$2'
    echo '  echo "unsigned char $f[] = {"'
    echo "  od -An -v -tx1 \"\$f\" | sed -e 's/[0-9a-f][0-9a-f]/0x&,/g'"
    echo '  echo "};"'
    echo '  echo "unsigned int $${f}_len = $(wc -c < "$f");"'
    echo '}'
    tail -n +2 "$s" | sed -e "s/echo -e '\\\\n'/echo/"
  } > "$s.new"
  mv "$s.new" "$s"
  chmod +x "$s"
  echo "de-xxd'd $s"
  found=$((found + 1))
done
# If upstream stops using xxd this loop would silently do nothing and the
# build would fail on a bash shebang with no explanation here.
test "$found" -gt 0 || { echo "no xxd-based generator found; is this still needed?" >&2; exit 1; }
EOT
,
    <<EOT
libcdir=$(dirname "$($CC -print-file-name=libc.so)")
test -f "$libcdir/libc.so" || {
  echo "cannot locate libc.so: $CC -print-file-name=libc.so said $($CC -print-file-name=libc.so)" >&2
  exit 1
}
echo "libc.so found in $libcdir"
cmake .. $ARGS -DCMAKE_LIBRARY_PATH="$libcdir"
EOT
,
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]
  working-directory = "build"

  env {
    ARGS = [
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}\"",
      "-DCMAKE_INSTALL_LIBDIR=lib",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DBUILD_SHARED_LIBS=ON",
      "-DIMAGE_SUPPORT=OFF",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/ROCm/ROCR-Runtime/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  fixture = <<EOT
#include <hsa/hsa.h>
#include <stdio.h>
int main(void) {
  printf("hsa_init=%d\n", (int)hsa_init());
  return 0;
}
EOT
  script = [
    "test -f {{prefix}}/lib/libhsa-runtime64.so",
    "test -f {{prefix}}/include/hsa/hsa.h",
    "test -f {{prefix}}/include/hsa/hsa_ext_amd.h",
    "test -f {{prefix}}/lib/libhsakmt.a",
    "mv $FIXTURE test.c",
    "cc test.c -lhsa-runtime64 -o test",
    "./test | grep -q '^hsa_init='",
  ]
}

versions {
  github = "ROCm/ROCR-Runtime/tags"
  strip = "/^rocm-/"
}
