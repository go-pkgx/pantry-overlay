dependencies = {
  "freedesktop.org/pkg-config" = "^0.29"
  "freetype.org" = "^2"
  "openssl.org" = "^3"
  "x.org/exts" = "^1"
  "x.org/x11" = "=1.8.11"
  "zlib.net" = "^1.3"
}
provides = [
  "bin/tclsh",
  "bin/wish",
  "bin/critcl",
]
test = [
  {
    fixture = {
      content = <<EOT
puts [info patchlevel]
exit
EOT
      extname = "tcl"
    }
    run = "tclsh $FIXTURE | tee out.log"
  },
  "grep {{version}} out.log",
  {
    fixture = {
      content = <<EOT
# Check that Itcl and Itk load, and that we can define, instantiate,
# and query the properties of a widget.

# If anything errors, just exit
catch {
    package require Itcl
    package require Itk

    # Define class
    itcl::class TestClass {
        inherit itk::Toplevel
        constructor {args} {
            itk_component add bye {
                button $itk_interior.bye -text "Bye"
            }
            eval itk_initialize $args
        }
    }

    # Create an instance
    set testobj [TestClass .#auto]

    # Check the widget has a bye component with text property "Bye"
    if {[[$testobj component bye] cget -text]=="Bye"} {
        puts "OK"
    }
}
exit
EOT
      extname = "tcl"
    }
    run = "wish $FIXTURE"
  },
]

build {
  dependencies = {
    "gnu.org/patch" = "*"
    "info-zip.org/zip" = "*"
    linux = {
      "curl.se" = "*"
      "tukaani.org/xz" = "*"
    }
  }
  script = [
    {
      run = "./configure $ARGS"
      working-directory = "unix"
    },
    {
      if = ">=9.0.4"
      run = [
        "make --jobs {{hw.concurrency}} binaries",
        "mkdir -p {{prefix}}/lib",
        "cp libtcl9.0.* {{prefix}}/lib/",
        "export LD_LIBRARY_PATH=\"{{prefix}}/lib:$LD_LIBRARY_PATH\"",
      ]
      working-directory = "unix"
    },
    {
      run = [
        "make --jobs {{hw.concurrency}}",
        "make --jobs {{hw.concurrency}} install",
        "make --jobs {{hw.concurrency}} install-private-headers",
      ]
      working-directory = "unix"
    },
    {
      run = "if test ! -f tclsh; then ln -s tclsh{{version.marketing}} tclsh; fi"
      working-directory = "{{prefix}}/bin"
    },
    {
      if = "<8.6.14"
      run = [
        "curl -L \"$patch_1\" | patch -p0",
        "curl -L \"$patch_2\" | patch -p0",
      ]
      working-directory = "tk"
    },
    {
      run = [
        "curl -L \"$res_tk\" | tar -xz --strip-components=1",
        "cd unix",
        "./configure $ARGS --without-x --with-tcl={{prefix}}/lib",
        "make --jobs {{hw.concurrency}}",
        "make --jobs {{hw.concurrency}} install",
        "make --jobs {{hw.concurrency}} install-private-headers",
      ]
      working-directory = "tk"
    },
    {
      run = "if test ! -f wish; then ln -s wish{{version.marketing}} wish; fi"
      working-directory = "{{prefix}}/bin"
    },
    {
      run = [
        "curl -L \"$res_critcl\" | tar -xz --strip-components=1",
        "sed -i \"s|package require Tcl 8.6.9$|package require Tcl {{version.major}}|g\" build.tcl",
        "tclsh build.tcl install",
      ]
      working-directory = "critcl"
    },
    {
      run = [
        "curl -L \"$res_tcllib\" | tar -xJ --strip-components=1",
        "./configure --prefix={{prefix}} --mandir={{prefix}}/share/man",
        "sed -i \"s|package require Tcl 8.2|package require Tcl {{version.major}}|g\" installer.tcl",
        "make --jobs {{hw.concurrency}} install",
        "make --jobs {{hw.concurrency}} critcl",
        "cp -r modules/tcllibc {{prefix}}/lib/",
      ]
      working-directory = "tcllib"
    },
    {
      run = [
        "curl -L \"$res_tcltls\" | tar -xz --strip-components=1",
        "sed -i '/SSL_SESSION_get0_ticket_appdata/s/&ticket/(void **)\\&ticket/' generic/tls.c",
        "./configure $TLS_ARGS",
        "make --jobs {{hw.concurrency}}",
        "make --jobs {{hw.concurrency}} install",
      ]
      working-directory = "tcltls"
    },
    {
      run = [
        "curl -L \"$res_itk4\" | tar -xz --strip-components=1",
        "itcl_dir=$(ls -d {{prefix}}/lib/itcl* | tail -n 1)",
        "./configure $ITK4_ARGS --with-itcl=$itcl_dir",
        "make --jobs {{hw.concurrency}}",
        "cp -a ../tcltls/tclconfig .",
        "make install",
      ]
      working-directory = "itk4"
    },
    "rm {{prefix}}/bin/sqlite3_analyzer",
    {
      prop = <<EOT
s|='\(.*\){{prefix}}\(.*\)'|="\1$(cd $(dirname $0) \&\& pwd)/..\2"|g
s|="\(.*\){{prefix}}\(.*\)"|="\1$(cd $(dirname $0) \&\& pwd)/..\2"|g
EOT
      run = "sed -i -f $PROP *.sh"
      working-directory = "{{prefix}}/lib"
    },
    {
      prop = <<EOT
s|='\(.*\){{prefix}}\(.*\)'|="\1$(cd $(dirname $0) \&\& pwd)/../..\2"|g
s|="\(.*\){{prefix}}\(.*\)"|="\1$(cd $(dirname $0) \&\& pwd)/../..\2"|g
EOT
      run = "sed -i -f $PROP */*.sh"
      working-directory = "{{prefix}}/lib"
    },
    {
      if = "darwin"
      run = [
        "for f in $(find bin lib -type f); do",
        "file \"$f\" | grep -q Mach-O || continue",
        "up=\"$(dirname \"$f\" | sed 's:[^/][^/]*:..:g')\"",
        "id=$(otool -D \"$f\" | sed -n 2p)",
        "case \"$id\" in {{prefix}}/*) install_name_tool -id \"@rpath/$${id##*/}\" \"$f\";; esac",
        "for dep in $(otool -L \"$f\" | awk 'NR>1{print $1}' | grep -F \"{{prefix}}/\"); do",
        "install_name_tool -change \"$dep\" \"@loader_path/$up/$${dep#{{prefix}}/}\" \"$f\"",
        "done",
        "install_name_tool -add_rpath \"@loader_path/$up/../..\" \"$f\"",
        "if otool -l \"$f\" | grep -qF \"{{pkgx.prefix}} (offset\"; then install_name_tool -delete_rpath {{pkgx.prefix}} \"$f\"; fi",
        "codesign --remove-signature \"$f\"",
        "codesign -s - --force \"$f\"",
        "done",
      ]
      working-directory = "$${{prefix}}"
    },
  ]
  skip = "fix-machos"

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--includedir={{prefix}}/include/tcl-tk",
      "--mandir={{prefix}}/share/man",
      "--enable-threads",
      "--enable-64bit",
      "--disable-zipfs",
    ]
    ITK4_ARGS = [
      "--prefix={{prefix}}",
      "--exec-prefix={{prefix}}",
      "--with-tcl={{prefix}}/lib",
      "--with-tclinclude={{prefix}}/include/tcl-tk",
      "--with-tk={{prefix}}/lib",
      "--with-tkinclude={{prefix}}/include/tcl-tk",
      "--with-itcl={{prefix}}/lib/itcl*",
    ]
    PATH = "{{prefix}}/bin:$PATH"
    TCL_PACKAGE_PATH = "{{prefix}}/lib"
    TLS_ARGS = [
      "--with-openssl-dir={{deps.openssl.org.prefix}}",
      "--prefix={{prefix}}",
      "--mandir={{prefix}}/share/man",
    ]
    patch_1 = "https://raw.githubusercontent.com/macports/macports-ports/db4f8f774193/x11/tk/files/fix-themechanged-error.patch"
    patch_2 = "https://raw.githubusercontent.com/macports/macports-ports/6a93695d61d3/x11/tk/files/fix-kvo-crash.diff"
    res_critcl = "https://github.com/andreas-kupries/critcl/archive/refs/tags/3.3.1.tar.gz"
    res_itk4 = "https://github.com/tcltk/itk/archive/refs/tags/itk-4-2-3.tar.gz"
    res_tcllib = "https://downloads.sourceforge.net/project/tcllib/tcllib/2.0/tcllib-2.0.tar.xz"
    res_tcltls = "https://core.tcl-lang.org/tcltls/tarball/e03e54ee87/tcltls-e03e54ee87.tar.gz"
    res_tk = "https://downloads.sourceforge.net/project/tcl/Tcl/{{version}}/tk{{version}}-src.tar.gz"

    darwin {
      LDFLAGS = "$LDFLAGS -Wl,-headerpad_max_install_names"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://downloads.sourceforge.net/project/tcl/Tcl/{{version}}/tcl{{version}}-src.tar.gz"
}

versions {
  match = "/tcl\\d+\\.\\d+\\.\\d+-src\\.tar\\.gz/"
  strip = [
    "/^tcl/",
    "/-src\\.tar\\.gz/",
  ]
  url = "https://www.tcl-lang.org/software/tcltk/download.html"
}
