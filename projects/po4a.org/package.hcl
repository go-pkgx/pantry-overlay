dependencies = {
  "gnome.org/libxslt" = "^1.1"
  "gnu.org/gettext" = "^1"
  "perl.org" = "^5.22"
}
provides = [
  "bin/msguntypot",
  "bin/po4a",
  "bin/po4a-display-man",
  "bin/po4a-display-pod",
  "bin/po4a-gettextize",
  "bin/po4a-normalize",
  "bin/po4a-updatepo",
  "bin/podselect",
]
test = [
  "po4a-updatepo -f latex -m en.tex -p latex.pot",
  "cat latex.pot | grep 'Hello from Tea'",
  "po4a-updatepo -f text -m en.md -p text.pot",
  "cat text.pot | grep 'Hello from Tea'",
  "po4a --version | grep {{version.marketing}}",
]

build {
  dependencies = {
    "cpanmin.us" = "*"
    "curl.se" = "*"
    "docbook.org/xsl" = "*"
  }
  script = [
    "cpanm -l {{prefix}}/libexec $PKGS --force --notest --verbose",
    {
      run = <<EOT
curl -L "https://cpan.metacpan.org/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz" | \
  tar -xz --strip-components=1
cpanm -l {{prefix}}/libexec .
EOT
      working-directory = "pkgs/SGMLSpm"
    },
    {
      run = <<EOT
curl -L "https://cpan.metacpan.org/authors/id/J/JS/JSTOWE/TermReadKey-2.38.tar.gz" | \
  tar -xz --strip-components=1
cpanm -l {{prefix}}/libexec .
EOT
      working-directory = "pkgs/TermReadKey"
    },
    "sed -i -e \"s|/usr/share/xml/docbook/stylesheet/docbook-xsl|{{deps.docbook.org/xsl.prefix}}/libexec/docbook-xsl-ns|\" -e \"s/if ( \\$\\^O ne 'MSWin32' )/if (0)/\" Po4aBuilder.pm",
    "perl Build.PL --install_base {{prefix}}/libexec",
    "./Build",
    "./Build install",
    {
      run = "ln -s ../../libexec/man/man? ."
      working-directory = "$${{prefix}}/share/man"
    },
    {
      run = "sed -i \"s|{{deps.perl.org.prefix}}/bin/perl|/usr/bin/env perl|\" *"
      working-directory = "$${{prefix}}/libexec/bin"
    },
    {
      run = "ln -s ./libexec/bin bin"
      working-directory = "$${{prefix}}"
    },
  ]

  env {
    PERL5LIB = "$${{prefix}}/libexec/lib/perl5:$PERL5LIB"
    PKGS = [
      "Locale::gettext",
      "Module::Build",
      "Pod::Parser",
      "Text::WrapI18N",
      "Unicode::GCString",
      "YAML::Tiny",
      "ExtUtils::CChecker",
      "XS::Parse::Keyword::Builder",
      "Syntax::Keyword::Try",
      "Module::Build",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/mquinson/po4a/archive/refs/tags/{{version.tag}}.tar.gz"
}

runtime {

  env {
    PERL5LIB = "$${{prefix}}/libexec/lib/perl5:$PERL5LIB"
  }
}

versions {
  github = "mquinson/po4a"
}
