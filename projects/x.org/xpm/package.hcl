build {
  dependencies = {
    "freedesktop.org/pkg-config" = "~0.29"
    "gnu.org/gettext"            = "^1"
  }
  script = <<EOT
./configure \
  --prefix="{{prefix}}" \
  --sysconfdir="$SHELF"/etc \
  --localstatedir="$SHELF"/var \
  --disable-open-zfile
make --jobs {{ hw.concurrency }} install
EOT

  env {
    SHELF = "$${{pkgx.prefix}}/x.org"
  }
}
