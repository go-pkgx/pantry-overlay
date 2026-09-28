build {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0.29"
    "gnu.org/grep"               = "*"
    "pcre.org/v2"                = "=10.47"
  }
  script = <<EOT
./configure $ARGS
make --jobs {{ hw.concurrency }} install
EOT

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-nls",
      "--mandir={{prefix}}/man",
      "--infodir={{prefix}}/info",
      "-with-packager=tea",
    ]
  }
}
