provides = [
  "bin/corelist",
  "bin/cpan",
  "bin/enc2xs",
  "bin/encguess",
  "bin/h2ph",
  "bin/h2xs",
  "bin/instmodsh",
  "bin/json_pp",
  "bin/libnetcfg",
  "bin/perl",
  "bin/perlbug",
  "bin/perldoc",
  "bin/perlivp",
  "bin/perlthanks",
  "bin/piconv",
  "bin/pl2pm",
  "bin/pod2html",
  "bin/pod2man",
  "bin/pod2text",
  "bin/pod2usage",
  "bin/podchecker",
  "bin/prove",
  "bin/ptar",
  "bin/ptardiff",
  "bin/ptargrep",
  "bin/shasum",
  "bin/splain",
  "bin/streamzip",
  "bin/xsubpp",
  "bin/zipdetails",
]

build {
  script = <<EOT
./Configure $ARGS
make --jobs {{ hw.concurrency }} install

cd "{{prefix}}"/bin
for x in *; do
  case $x in
  perl|perl{{version}})
    ;;
  *)
    sed -i.bak 's|^#!{{prefix}}/bin/|#!/usr/bin/env |' $x
    sed -i.bak 's|exec {{prefix}}/bin/|exec |' $x
  esac
done

rm -f *.bak
EOT

  dependencies {
    linux = {
      "gnu.org/make" = "*"
      "llvm.org" = "<19"
    }
  }

  env {
    ARGS = [
      "-d",
      "-e",
      "-Dprefix={{prefix}}",
      "-Duselargefiles",
      "-Dusethreads",
      "-Duseshrplib=false",
      "-Duserelocatableinc",
    ]

    linux {
      ARGS = [
        "-Accflags=-fPIC",
      ]
    }
  }
}

dependencies {
  linux = {
    "github.com/besser82/libxcrypt" = "*"
  }
}

distributable {
  strip-components = 1
  url = "https://www.cpan.org/src/{{ version.major }}.0/perl-{{ version }}.tar.xz"
}

interprets {
  args = "perl"
  extensions = "pl"
}

test {
  fixture = <<EOT
print 'Perl is not an acronym, but JAPH is a Perl acronym!'
EOT
  script = <<EOT
perl $FIXTURE
shasum --version
EOT
}

versions {
  github = "perl/perl5/tags"
  ignore = "/^v\\d+\\.\\d*[13579]\\.\\d+$/"
}
