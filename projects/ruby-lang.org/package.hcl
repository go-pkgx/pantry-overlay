dependencies = {
  "openssl.org" = "^3"
  "pyyaml.org"  = "^0.2"
  "zlib.net"    = "^1"
}

build {
  dependencies = {
    "gnu.org/autoconf" = "*"
    "gnu.org/bison"    = "^3"
    "gnu.org/gettext"  = "^1"
    "gnu.org/patch"    = "*"
    linux = {
      "ruby-lang.org" = "^3"
      "rubygems.org"  = "*"
    }
    "rsync.samba.org" = "*"
    "rust-lang.org"   = "^1"
  }
  script = [
    {
      if  = "<4"
      run = "ARGS=\"$ARGS --with-sitearchdir={{prefix}}/lib/ruby/site_ruby\""
    },
    {
      if  = ">=4"
      run = "ARGS=\"$ARGS --with-sitearchdir=/lib/ruby/site_ruby\""
    },
    "patch -p1 -F5 < props/mkconfig.rb.diff",
    "CC=cc CXX=c++ ./configure $ARGS",
    {
      if = "linux"
      run = [
        "if test -f maybe_unused.h; then",
        "sed -i -e 's/elif RBIMPL_HAS_C_ATTRIBUTE(maybe_unused)/elif RBIMPL_HAS_C_ATTRIBUTE(maybe_unused) \\&\\& (__STDC_VERSION__ >= 202000L)/' maybe_unused.h",
        "fi",
      ]
      working-directory = "include/ruby/internal/attr"
    },
    {
      if = ">=3.1.4<3.2"
      run = [
        "if test \"{{hw.platform}}\" = \"linux\"; then",
        "sed -i \"s_^RUBYLIB.*=.*\\$_RUBYLIB = $${RUBYLIB}_\" uncommon.mk",
        "fi",
      ]
    },
    {
      if = ">=4"
      run = [
        "if test \"{{hw.platform}}\" = \"linux\"; then",
        "sed -i \"s_^RUBYLIB.*=.*\\$_RUBYLIB = $${RUBYLIB}_\" common.mk",
        "fi",
      ]
    },
    "make install",
    {
      run               = "rm -f bundle bundler gem"
      working-directory = "$${{prefix}}/bin"
    },
    "fix-shebangs.ts $${{prefix}}/bin/*",
    {
      run = [
        <<EOT
for x in bundler rubygems bundler.rb rubygems.rb; do
  if test -d $x; then
    rm -rf $x
  else
    rm -f $x
  fi
done
EOT
        ,
        "rm -rf ../gems/3.2.0/gems/bundler-*.*.*",
      ]
      working-directory = "$${{prefix}}/lib/ruby/{{version.marketing}}.0"
    },
    {
      run = [
        "rm -rf share/ri",
        "rm -rf share/doc",
        "rm -rf lib/ruby/site_ruby",
        "rm -rf lib/ruby/vendor_ruby",
      ]
      working-directory = "$${{prefix}}"
    },
    {
      if = ">=2.6"
      run = [
        "if test -d pkgconfig; then rm -rf pkgconfig; fi",
        <<EOT
if test -d *-{{hw.platform}}* ; then
  mv *-{{hw.platform}}*/* .
  rmdir *-{{hw.platform}}*
fi
EOT
        ,
      ]
      working-directory = "$${{prefix}}/lib"
    },
    {
      if                = ">=3.4"
      run               = <<EOT
if test *-{{hw.platform}}*/bin/ruby ; then
  unlink bin/ruby
  mv *-{{hw.platform}}*/bin/ruby bin/ruby
  rmdir *-{{hw.platform}}*/bin
  rmdir *-{{hw.platform}}*
fi
EOT
      working-directory = "$${{prefix}}"
    },
    {
      if   = ">=4"
      prop = <<EOT
/def RbConfig::expand/a\
    val = val || ''
EOT
      run = [
        "if test -d include; then rsync include/ {{prefix}}/include/ -a; fi",
        "sed -i -f $PROP lib/ruby/{{version.marketing}}.0/rbconfig.rb",
        "if test -d lib; then rsync lib/ {{prefix}}/lib/ -a; fi",
        "cd ..",
        "rm -rf ./{{prefix}}",
      ]
      working-directory = "$${{prefix}}/{{prefix}}"
    },
    {
      prop              = <<EOT
s|$$(DESTDIR){{prefix}}|$$(topdir)|g
s|CONFIG\["prefix"\] = .*|CONFIG\["prefix"\] = KEGDIR|g
s|CONFIG\["topdir"\] = .*|CONFIG\["topdir"\] = KEGDIR\n  CONFIG["kegdir"] = KEGDIR\n  CONFIG["sitearchdir"] = File.join(KEGDIR, "lib", "ruby", "site_ruby", File.basename(File.dirname(__FILE__)))|g
s|CONFIG\["bindir"\] = .*|CONFIG\["bindir"\] = File.join(KEGDIR, "bin")|g
s|CONFIG\["sysconfdir"\] = .*|CONFIG\["sysconfdir"\] = File.join(KEGDIR, "etc")|g
s|CONFIG\["rubyhdrdir"\] = .*|CONFIG\["rubyhdrdir"\] = File.join(KEGDIR, "include")|g
s|CONFIG\["rubyarchhdrdir"\] = .*|CONFIG\["rubyarchhdrdir"\] = File.join(KEGDIR, "include")|g
s|CONFIG\["rubylibprefix"\] = .*|CONFIG\["rubylibprefix"\] = File.join(KEGDIR, "lib", "ruby")|g
s|CONFIG\["rubylibdir"\] = .*|CONFIG\["rubylibdir"\] = File.join(KEGDIR, "lib", "ruby", File.basename(File.dirname(__FILE__)))|g
s|CONFIG\["archdir"\] = .*|CONFIG\["archdir"\] = File.join(KEGDIR, "lib", "ruby", File.basename(File.dirname(__FILE__)))|g
s|CONFIG\["rubyarchdir"\] = .*|CONFIG\["rubyarchdir"\] = File.join(KEGDIR, "lib", "ruby", File.basename(File.dirname(__FILE__)))|g
s|CONFIG\["sitehdrdir"\] = .*|CONFIG\["sitehdrdir"\] = File.join(KEGDIR, "include", "site_ruby")|g
s|CONFIG\["vendorhdrdir"\] = .*|CONFIG\["vendorhdrdir"\] = File.join(KEGDIR, "include", "vendor_ruby")|g
s|CONFIG\["INSTALL"\] =.*|CONFIG\["INSTALL"\] = "/usr/bin/install"|g
EOT
      run               = "sed -i -f $PROP rbconfig.rb"
      working-directory = "$${{prefix}}/lib/ruby/{{version.marketing}}.0"
    },
    {
      if                = "<4"
      run               = <<EOT
sed -i -e 's|CONFIG\["MJIT_CC"\] =.*|CONFIG\["MJIT_CC"\] = "/usr/bin/cc"|g' rbconfig.rb
EOT
      working-directory = "$${{prefix}}/lib/ruby/{{version.marketing}}.0"
    },
  ]

  env {
    ARGS = [
      "--prefix=\"{{prefix}}\"",
      "--enable-load-relative",
      "--without-gmp",
      "--with-rubyarchprefix={{prefix}}/lib/ruby",
      "--with-rubyhdrdir={{prefix}}/include",
      "--with-rubyarchhdrdir={{prefix}}/include",
      "--disable-multiarch",
      "--with-vendordir=no",
      "--with-vendorarchdir=no",
      "--enable-yjit",
      "--disable-install-doc",
    ]
    CFLAGS = "$CFLAGS -Wno-implicit-function-declaration"
  }
}
