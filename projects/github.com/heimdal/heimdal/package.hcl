dependencies = {
  "gnu.org/readline" = "*"
  "invisible-island.net/ncurses" = "*"
  "sqlite.org" = "*"
  "thrysoee.dk/editline" = "*"
}
provides = [
  "bin/kinit",
  "bin/klist",
  "bin/kdestroy",
  "bin/kgetcred",
  "bin/kpasswd",
  "bin/kswitch",
  "bin/ktutil",
  "bin/string2key",
  "bin/hxtool",
  "bin/asn1_compile",
  "sbin/kdc",
  "sbin/kadmind",
  "sbin/kstash",
  "sbin/iprop-log",
]
test = <<EOT
kinit --version | grep -i heimdal
ls {{prefix}}/lib/libgssapi.*
EOT

build {
  dependencies = {
    "freedesktop.org/pkg-config" = "*"
    "github.com/westes/flex" = "*"
    "gnu.org/bison" = "*"
    "perl.org" = "*"
    "python.org" = "*"
  }
  script = [
    {
      run = <<EOT
mkdir -p "$SRCROOT/compat-lib"
for w in {{deps.invisible-island.net/ncurses.prefix}}/lib/libncursesw.*; do
  ln -sf "$w" "$SRCROOT/compat-lib/$(basename "$w" | sed 's/ncursesw/ncurses/')"
done
export LDFLAGS="-L$SRCROOT/compat-lib $${LDFLAGS:-}"
export LIBS="-ltinfo $${LIBS:-}"
EOT
    },
    {
      run = <<EOT
sed -i.bak           -e 's/^typedef struct hc_HMAC_CTX HMAC_CTX;$/typedef struct hc_HMAC_CTX hc_HMAC_CTX;\n#define HMAC_CTX hc_HMAC_CTX/'           lib/hcrypto/hmac.h
grep -q '^#define HMAC_CTX hc_HMAC_CTX$' lib/hcrypto/hmac.h
EOT
    },
    "./configure $ARGS",
    "make",
    "make install",
  ]

  env {
    ARGS = [
      "--prefix={{prefix}}",
      "--without-openssl",
      "--with-sqlite3={{deps.sqlite.org.prefix}}",
      "--with-readline={{deps.gnu.org/readline.prefix}}",
      "--with-libedit={{deps.thrysoee.dk/editline.prefix}}",
      "--without-berkeley-db",
      "--without-openldap",
      "--without-libintl",
      "--without-capng",
      "--disable-heimdal-documentation",
      "--disable-otp",
      "--disable-afs-support",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/heimdal/heimdal/releases/download/heimdal-{{version}}/heimdal-{{version}}.tar.gz"
}

versions {
  github = "heimdal/heimdal/releases/tags"
  strip = [
    "/^heimdal-/",
  ]
}
