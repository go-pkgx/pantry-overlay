dependencies = {
  "openssl.org" = "^3"
  "pcre.org/v2" = "^10"
}
provides = [
  "bin/nmap",
  "bin/ncat",
  "bin/nping",
]
test = "nmap -vvvv localhost"

build {
  dependencies = {
    "gnu.org/patch" = "*"
    linux = {
      "kernel.org/linux-headers" = "*"
    }
    "python.org" = 3
  }
  script = [
    {
      if = "<7.94.0"
      run = "patch -p1 <props/openssl-1.1.1.patch"
    },
    "python -m venv $HOME/venv",
    "source $HOME/venv/bin/activate",
    "python -m pip install build setuptools",
    {
      if = ">=7.99"
      prop = <<EOT
s/dynamic = \["version"\]/version = "{{version}}"/
/\[tool.setuptools.dynamic\]/,/^$/d
EOT
      run = [
        "sed -i -f $PROP ndiff/pyproject.toml",
        "sed -i 's/#elif HAVE_OPAQUE_STRUCTS/#elif OPENSSL_VERSION_NUMBER >= 0x30000000L/' nse_ssl_cert.cc",
      ]
    },
    {
      if = "linux"
      run = "sed -i 's/as_fn_error.*Ethernet support not found.*/ac_cv_dnet_linux_pf_packet=yes/' libdnet-stripped/configure"
    },
    "./configure $ARGS",
    {
      run = "sed -i 's|/VERSION`|/VERSION.txt`|' Makefile"
      working-directory = "libpcap"
    },
    "make -j {{hw.concurrency}}",
    "make install",
  ]
  test = "make test"

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--with-libpcre={{deps.pcre.org/v2.prefix}}",
      "--without-zenmap",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://nmap.org/dist/nmap-{{version.raw}}.tgz"
}

versions {
  match = "/nmap-\\d+\\.\\d+(\\.\\d+)?\\.tgz/"
  strip = [
    "/nmap-/",
    "/.tgz/",
  ]
  url = "https://nmap.org/dist/"
}
