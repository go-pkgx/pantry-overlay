dependencies = {
  "libexpat.github.io" = "^2"
  "openssl.org" = "^3"
  "pkgx.sh" = ">=1"
}
provides = [
  "bin/virtualenv",
]
test = [
  "echo \"$(virtualenv --version)\" | grep \"^virtualenv {{version}}\"",
  "virtualenv venv_dir",
  "WANT=$(venv_dir/bin/python -c 'import sys; print(sys.prefix)')",
  "source venv_dir/bin/activate",
  "test $WANT=$VIRTUAL_ENV",
  "pip install pycowsay",
  "deactivate",
  "venv_dir/bin/pycowsay \"All tests pass!\"",
]

build {
  dependencies = {
    "python.org" = ">=3.7<3.12"
  }
  script = [
    "bkpyvenv stage '{{prefix}}' {{version}}",
    "$${{prefix}}/venv/bin/pip install .",
    "bkpyvenv seal '{{prefix}}' virtualenv",
    {
      if = "linux"
      run = "cp {{deps.python.org.prefix}}/lib/libpython{{deps.python.org.version.marketing}}.so* ."
      working-directory = "$${{prefix}}/lib"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/pypa/virtualenv/archive/refs/tags/{{ version }}.tar.gz"
}

versions {
  github = "pypa/virtualenv/releases/tags"
  strip = "/^v/"
}
