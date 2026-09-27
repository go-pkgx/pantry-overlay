dependencies = {
  "curl.se" = "^8"
  "openssl.org" = "^3"
  "pcre.org" = "^8"
}
test = "vanitygen++ 1pkgx"

build {
  script = [
    {
      if = "darwin"
      run = [
        "make all",
        "install -D oclvanityminer '{{prefix}}/bin/oclvanityminer'",
        "install -D oclvanitygen++ '{{prefix}}/bin/oclvanitygen++'",
      ]
    },
    {
      if = "linux"
      run = "make most"
    },
    "install -D vanitygen++ '{{prefix}}/bin/vanitygen++'",
    "install -D keyconv '{{prefix}}/bin/keyconv'",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/10gic/vanitygen-plusplus/archive/refs/tags/{{version.tag}}.tar.gz"
}

provides {
  darwin = [
    "bin/vanitygen++",
    "bin/keyconv",
    "bin/oclvanitygen++",
    "bin/oclvanityminer",
  ]
  linux = [
    "bin/vanitygen++",
    "bin/keyconv",
  ]
}

versions {
  github = "10gic/vanitygen-plusplus/tags"
}
