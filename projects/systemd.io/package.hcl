dependencies = {
  "curl.se" = "*"
  "facebook.com/zstd" = "*"
  "github.com/besser82/libxcrypt" = "*"
  "github.com/util-linux/util-linux" = "*"
  "gnu.org/libidn2" = "*"
  "gnutls.org" = "*"
  "google.com/fullycapable" = "*"
  "libexpat.github.io" = "*"
  "lz4.org" = "*"
  "openssl.org" = "^3"
  "pcre.org/v2" = "*"
  "sourceware.org/bzip2" = "*"
  "tukaani.org/xz" = "*"
}
platforms = [
  "linux",
]
provides = [
  "bin/busctl",
  "bin/coredumpctl",
  "bin/hostnamectl",
  "bin/journalctl",
  "bin/kernel-install",
  "bin/localectl",
  "bin/loginctl",
  "bin/machinectl",
  "bin/networkctl",
  "bin/oomctl",
  "bin/portablectl",
  "bin/resolvectl",
  "bin/systemctl",
  "bin/systemd-ac-power",
  "bin/systemd-analyze",
  "bin/systemd-ask-password",
  "bin/systemd-cat",
  "bin/systemd-cgls",
  "bin/systemd-cgtop",
  "bin/systemd-confext",
  "bin/systemd-creds",
  "bin/systemd-delta",
  "bin/systemd-detect-virt",
  "bin/systemd-dissect",
  "bin/systemd-escape",
  "bin/systemd-firstboot",
  "bin/systemd-id128",
  "bin/systemd-inhibit",
  "bin/systemd-machine-id-setup",
  "bin/systemd-mount",
  "bin/systemd-notify",
  "bin/systemd-nspawn",
  "bin/systemd-path",
  "bin/systemd-repart",
  "bin/systemd-resolve",
  "bin/systemd-run",
  "bin/systemd-socket-activate",
  "bin/systemd-stdio-bridge",
  "bin/systemd-sysext",
  "bin/systemd-sysusers",
  "bin/systemd-tmpfiles",
  "bin/systemd-tty-ask-password-agent",
  "bin/systemd-umount",
  "bin/timedatectl",
  "bin/udevadm",
  "bin/userdbctl",
  "sbin/halt",
  "sbin/init",
  "sbin/mount.ddi",
  "sbin/poweroff",
  "sbin/reboot",
  "sbin/resolvconf",
  "sbin/runlevel",
  "sbin/shutdown",
  "sbin/telinit",
]
test = "systemd-path | grep 'temporary: /tmp'"

build {
  dependencies = {
    "docbook.org" = "*"
    "freedesktop.org/pkg-config" = "*"
    "github.com/mattrobenolt/jinja2-cli" = "*"
    "gnome.org/libxml2" = "~2.13"
    "gnome.org/libxslt" = "*"
    "gnu.org/coreutils" = "*"
    "gnu.org/gettext" = "*"
    "gnu.org/gperf" = "*"
    "gnu.org/libtool" = "*"
    "gnu.org/m4" = "*"
    "gnupg.org/libgpg-error" = "*"
    linux = {
      "kernel.org/linux-headers" = ">=5.2"
      "llvm.org" = "<22"
    }
    "mesonbuild.com" = "*"
    "ninja-build.org" = "*"
    "python.org" = ">=3<3.12"
    "rsync.samba.org" = "*"
  }
  script = [
    {
      prop = <<EOT
/sched\.h/i\
#include <linux/sched.h>
EOT
      run = "sed -i -f $PROP process-util.h"
      working-directory = "src/basic"
    },
    "meson setup $ARGS build",
    "meson compile -C build",
    "meson install -C build",
    {
      run = <<EOT
if test -d systemd; then
  ln -s systemd/lib* .
fi
EOT
      working-directory = "{{prefix}}/lib"
    },
  ]

  env {
    ARGS = [
      "--sysconfdir={{prefix}}/etc",
      "--localstatedir={{prefix}}/var",
      "-Dprefix={{prefix}}",
      "-Dsysvinit-path={{prefix}}/etc/init.d",
      "-Dsysvrcnd-path={{prefix}}/etc/rc.d",
      "-Dpamconfdir={{prefix}}/etc/pam.d",
      "-Dcreate-log-dirs=false",
      "-Dhwdb=false",
      "-Dlz4=enabled",
      "-Dgcrypt=disabled",
      "-Dmode=release",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/systemd/systemd/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "systemd/systemd"
  ignore = [
    "/25[8-9]/",
    "/2[6-9]\\d/",
    "/[3-9]\\d\\d/",
  ]
}
