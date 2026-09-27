companions = {
  "pip.pypa.io" = "*"
}
dependencies = {
  "bytereef.org/mpdecimal" = 2
  darwin = {
    "gnu.org/gettext" = "^1"
  }
  "facebook.com/zstd" = ">=1.5"
  "gnu.org/readline" = 8
  "invisible-island.net/ncurses" = 6
  "libexpat.github.io" = 2
  "openssl.org" = "^3"
  "sourceware.org/bzip2" = 1
  "sourceware.org/libffi" = 3
  "sqlite.org" = 3
  "tcl-lang.org" = "=8.6.16"
  "tukaani.org/xz" = 5
  "zlib.net" = "=1.3.1"
}
provides = [
  "bin/python",
  "bin/python{{ version.major }}",
  "bin/python{{ version.marketing }}",
]
unpackaged = [
  {
    arch = "aarc64"
    platform = "darwin"
    reason = "help-wanted"
    version = "^2"
  },
]

build {
  dependencies = {
    "curl.se" = "*"
    "gnu.org/patch" = "*"
  }
  script = [
    {
      if = "^2"
      run = <<EOT
for PATCH in $PYTHON2PATCHES; do
  curl -sSL $PATCH | patch -p0
done
EOT
    },
    {
      if = "<3.12"
      run = [
        "sed -i -e 's|system_lib_dirs = .*|system_lib_dirs = os.getenv(\"LIBRARY_PATH\").split(\":\")|' ./setup.py",
        "sed -i -e 's|system_include_dirs = .*|system_include_dirs = os.getenv(\"CPATH\").split(\":\")|' ./setup.py",
      ]
    },
    {
      if = "^2"
      run = [
        "confdir=\"$libdir/config\"",
        "ARGS=$${ARGS/--with-ensurepip/--without-ensurepip}",
      ]
    },
    {
      if = ">=3<3.8"
      run = [
        "confdir=$(echo $confdir | sed -e 's/\\(config-{{ version.marketing }}\\)/\\1m/')",
        "SUFFIX=m",
        "ARGS=$${ARGS/--with-ensurepip/--without-ensurepip}",
      ]
    },
    {
      if = ">=3<3.6"
      run = "confdir=\"$libdir/config-{{version.marketing}}m\""
    },
    {
      if = ">=3<3.9.1"
      run = <<EOT
if test "{{hw.platform}}" = "darwin"; then
  sed -i \
      -e 's/ppc)/arm64)/g' \
      -e 's/MACOSX_DEFAULT_ARCH="ppc.*$/MACOSX_DEFAULT_ARCH="arm64"/g' \
      configure
fi
EOT
    },
    {
      if = ">=3<3.10.1"
      run = <<EOT
if test "{{hw.platform}}" = "darwin"; then
  sed -i -e 's/^MULTIARCH=.*$/MULTIARCH=""/' configure
fi
EOT
    },
    {
      if = ">=3.8<3.8.4 || >=3<3.7.8"
      run = <<EOT
if test "{{hw.platform}}" = "darwin"; then
  curl -L https://github.com/python/cpython/commit/8ea6353.patch | patch -p1
fi
EOT
    },
    {
      if = ">=3.5<3.5.3"
      run = "patch -p1 < props/patch3.5.diff"
    },
    {
      if = "~3.4.1"
      run = "patch -p1 < props/patch3.4.diff"
    },
    {
      if = "darwin/x86-64"
      run = "sed -i 's/libmpdec_machine=universal/libmpdec_machine=x64/' configure"
    },
    {
      if = "darwin/aarch64"
      run = "sed -i 's/libmpdec_machine=universal/libmpdec_machine=uint128/' configure"
    },
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
    "cp props/sitecustomize.py {{prefix}}/lib/python{{version.marketing}}",
    {
      run = [
        <<EOT
for x in python idle pydoc; do
  ln -sf $${x}{{ version.marketing }} $x
done
EOT
,
        "ln -sf python{{ version.marketing }}-config python-config",
      ]
      working-directory = "$${{prefix}}/bin"
    },
    {
      run = "find . -mindepth 1 -maxdepth 1 -type f -name 'pip*' -exec rm {} \\;"
      working-directory = "$${{prefix}}/bin"
    },
    {
      run = [
        <<EOT
for binfile in $shebangs $confdir/python-config.py; do
  if ! test -f $binfile; then
    binfile=$${binfile/{{version.marketing}}/{{version.marketing}}$SUFFIX}
  fi
  if ! test -f $binfile; then
    continue
  fi
  binfile=$(readlink -f $binfile)
  sed -i.bak -e 's|#!{{ prefix }}/bin/|#!/usr/bin/env |g' $binfile
  rm $binfile.bak
done
EOT
,
        "sed -i -e 's|{{ prefix }}|\\\\$(or $(PKGX_DIR),$(HOME)/.pkgx)/python.org/v{{version.major}}|g' $confdir/Makefile",
      ]
      working-directory = "$${{prefix}}"
    },
    {
      prop = <<EOT
import os
import re

pkgx_prefix = os.path.normpath(os.path.join(os.path.dirname(__file__), '../../../../'))
for key in build_time_vars:
  if isinstance(build_time_vars[key], str):
    build_time_vars[key] = re.sub(r'(\s|^)/opt/', r'\g<1>{}/'.format(pkgx_prefix), build_time_vars[key])
    build_time_vars[key] = re.sub(r'\+brewing', r'', build_time_vars[key])
EOT
      run = "cat $PROP >> _sysconfigdata__*.py"
      working-directory = "$${{prefix}}/lib/python{{version.marketing}}"
    },
    "ln -s /dev {{prefix}}/lib/python{{version.marketing}}/site-packages",
    {
      run = [
        "mv python{{version.marketing}}$SUFFIX/* .",
        "rmdir python{{version.marketing}}$SUFFIX",
        "ln -s . python{{version.marketing}}",
        <<EOT
if test -n "$SUFFIX"; then
  ln -s . python{{version.marketing}}$SUFFIX
fi
EOT
,
      ]
      working-directory = "$${{prefix}}/include"
    },
  ]

  env {
    ARGS = [
      "--prefix=\"{{ prefix }}\"",
      "--with-ensurepip",
      "--enable-ipv6",
      "--disable-loadable-sqlite-extensions",
      "--with-system-expat",
      "--with-system-ffi",
      "--with-system-libmpdec",
      "--enable-shared",
    ]
    CPPFLAGS = "$${CPPFLAGS:+$CPPFLAGS }-I{{ deps.zlib.net.prefix }}/include"
    LDFLAGS = "$${LDFLAGS:+$LDFLAGS }-L{{ deps.zlib.net.prefix }}/lib"
    OPENSSL_INCLUDES = "$${{ deps.openssl.org.prefix }}/include"
    OPENSSL_LDFLAGS = "-L{{ deps.openssl.org.prefix }}/lib"
    PYTHON2PATCHES = [
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-Makefile.pre.in.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-setup.py.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-Lib-cgi.py.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-Lib-ctypes-macholib-dyld.py.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-configure.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-libedit.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/enable-loadable-sqlite-extensions.patch",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-_osx_support.py.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/darwin20.diff",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/arm.patch",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/implicit.patch",
      "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/openssl_ver.patch",
    ]
    libdir = "lib/python{{version.marketing}}"
    shebangs = [
      "bin/2to3-{{version.marketing}}",
      "bin/idle{{version.marketing}}",
      "bin/pydoc{{version.marketing}}",
      "bin/python{{version.marketing}}-config",
    ]

    darwin {
      PYTHON2PATCHES = [
        "https://raw.githubusercontent.com/macports/macports-ports/master/lang/python27/files/patch-getpath.diff",
      ]
      confdir = "$libdir/config-{{version.marketing}}-darwin"
    }

    linux {
      ARCH = "$${{hw.arch}}"
      CFLAGS = "$${CFLAGS:+$CFLAGS }-fPIC"
      confdir = "$libdir/config-{{version.marketing}}-$${ARCH/-/_}-linux-gnu"
    }
  }
}

distributable {
  strip-components = 1
  url = "https://www.python.org/ftp/python/{{ version.raw }}/Python-{{ version.raw }}.tar.xz"
}

interprets {
  args = "python"
  extensions = "py"
}

test {
  dependencies = {
    "crates.io/semverator" = "*"
  }
  script = [
    {
      if = "^3.7"
      run = "python -c \"import sqlite3\""
    },
    {
      if = "^3.8"
      run = "python -m venv myvenv"
    },
    "python -c \"import zlib\"",
    "python -c \"import pyexpat\"",
    {
      run = <<EOT
if test "{{hw.platform}}" = "linux"; then
  python -v -c "import _ctypes"
elif semverator gt {{version}} 3.6.3; then
  python -v -c "import _ctypes"
fi
EOT
    },
    <<EOT
if which -a pip | grep '{{ prefix }}'; then
  exit 1
fi
EOT
,
    {
      fixture = {
        content = <<EOT
#include <Python.h>
#include <python{{version.major}}.{{version.minor}}/Python.h>
EOT
        extname = "c"
      }
      run = "cc -c $FIXTURE"
    },
    {
      if = ">=3<3.8"
      run = "SUFFIX=m"
    },
    {
      fixture = <<EOT
import sysconfig
include_path = sysconfig.get_paths()['include']
print(include_path)
EOT
      run = "test $(python $FIXTURE) = {{prefix}}/include/python{{version.marketing}}$SUFFIX"
    },
  ]
}

versions {
  github = "python/cpython/tags"
  ignore = [
    "3.4.[0-1]",
    "3.3.[1-7]",
    "3.[0-2].x",
    "2.7.1[0-7]",
    "2.7.[0-9]",
    "2.[0-6].x",
  ]
}
