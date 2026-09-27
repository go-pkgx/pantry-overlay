dependencies = {
  "gnu.org/gettext" = "*"
  "perl.org" = "~5.44"
}
provides = [
  "bin/help2man",
]
test = [
  "help2man --version | grep {{version}}",
  "help2man --locale=en_US.UTF-8 help2man | grep {{version}}",
]

build {
  dependencies = {
    "cpanmin.us" = "*"
  }
  script = [
    {
      if = "darwin"
      prop = <<EOT
#!/bin/sh
exec /usr/bin/cc -Wl,-headerpad_max_install_names -Wl,-rpath,{{pkgx.prefix}} "$@"
EOT
      run = [
        "WRAP=$(mktemp -d)",
        "install -Dm755 $PROP $WRAP/cc",
        "PATH=\"$WRAP:$PATH\" CC=\"$WRAP/cc\" cpanm -l {{prefix}} Locale::gettext",
        "rm -rf \"$WRAP\"",
      ]
    },
    {
      if = "linux"
      run = "cpanm -l {{prefix}} Locale::gettext"
    },
    "./configure $CONFIGURE_ARGS",
    "make install",
    {
      run = "sed -i '1s|.*|#!/usr/bin/env perl|' help2man"
      working-directory = "$${{prefix}}/bin"
    },
  ]

  env {
    CONFIGURE_ARGS = [
      "--disable-debug",
      "--disable-dependency-tracking",
      "--prefix=\"{{prefix}}\"",
      "--libdir=\"{{prefix}}/lib\"",
    ]
    PERL5LIB = "{{prefix}}/lib/perl5:{{prefix}}/libexec/lib/perl5:$PERL5LIB"

    darwin {
      LDFLAGS = "$LDFLAGS -Wl,-headerpad_max_install_names"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://ftp.gnu.org/gnu/help2man/help2man-{{version}}.tar.xz"
}

runtime {

  env {
    PERL5LIB = "{{prefix}}/lib/perl5:{{prefix}}/libexec/lib/perl5:$PERL5LIB"
  }
}

versions {
  match = "/help2man-\\d+\\.\\d+\\.\\d+\\.tar\\.xz/"
  strip = [
    "/^help2man-/",
    "/\\.tar\\.xz/",
  ]
  url = "https://ftp.gnu.org/gnu/help2man/"
}
