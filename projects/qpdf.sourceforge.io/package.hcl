dependencies = {
  "gnutls.org" = "^3"
  "libjpeg-turbo.org" = "^2"
  linux = {
    "gnu.org/gcc/libstdcxx" = "^14"
  }
  "openssl.org" = "^3"
  "zlib.net" = "^1"
}
display-name = "qpdf"
provides = [
  "bin/qpdf",
]
test = "qpdf --version | grep {{version}}"

build {
  dependencies = {
    "cmake.org" = "^3"
    linux = {
      "gnu.org/gcc" = "^14"
    }
    "pip.pypa.io" = "*"
    "python.org" = "^3"
    "pyyaml.org/libyaml" = "*"
  }
  script = [
    "python -m venv venv",
    "source venv/bin/activate",
    "pip install pyyaml",
    "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DMAINTAINER_MODE=1 -DBUILD_STATIC_LIBS=0 -DCMAKE_INSTALL_PREFIX={{ prefix }} -DCMAKE_BUILD_TYPE=Release -DBUILD_DOC=0 -DCMAKE_CXX_STANDARD=20 -DCMAKE_CXX_STANDARD_REQUIRED=ON ..",
    "cmake --build .",
    "cmake --install .",
  ]
  working-directory = "build"
}

distributable {
  strip-components = 1
  url = "https://github.com/qpdf/qpdf/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "qpdf/qpdf"
}
