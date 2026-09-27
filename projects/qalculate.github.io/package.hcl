dependencies = {
  "ginac.de/cln" = "*"
  "gnome.org/libxml2" = "*"
  "gnu.org/gettext" = "^1"
  "gnu.org/gmp" = "*"
  "gnu.org/mpfr" = "*"
  "gnu.org/readline" = "^8"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
  }
  "unicode.org" = "*"
}
provides = [
  "bin/qalc",
]

build {
  script = [
    "./configure $ARGS",
    "make --jobs {{hw.concurrency}}",
    "make install",
  ]

  dependencies {
    linux = {
      "gnu.org/gcc" = 14
    }
  }

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--disable-dependency-tracking",
      "--without-libcurl",
    ]
    CXXFLAGS = "$CXXFLAGS -std=c++17"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/Qalculate/libqalculate/releases/download/{{version.tag}}/libqalculate-{{version}}.tar.gz"
}

runtime {

  env {
    QALCULATE_DEFINITIONS_DIR = "$${{prefix}}/share/qalculate"
  }
}

test {
  script = [
    "(qalc --version 2>&1 || true) | grep \"{{version.raw}}\"",
    "qalc -t \"2+2\" 2>&1 | tee out",
    "grep \"^4$\" out",
  ]

  env {
    QALCULATE_DEFINITIONS_DIR = "$${{prefix}}/share/qalculate"
  }
}

versions {
  github = "Qalculate/libqalculate"
}
