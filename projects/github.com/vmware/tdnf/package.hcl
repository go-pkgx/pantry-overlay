dependencies = {
  "curl.se" = "*"
  "gnupg.org/gpgme" = "*"
  "gnupg.org/libgpg-error" = "*"
  "libexpat.github.io" = "*"
  "openssl.org" = "^3"
  "opensuse.org/libsolv" = "*"
  "rpm.org/rpm" = "*"
  "sqlite.org" = 3
}
display-name = "tdnf"
platforms = [
  "linux",
]
provides = [
  "bin/tdnf",
]

build {
  dependencies = {
    "cmake.org" = "^3"
  }
  script = [
    {
      prop = <<EOT
s|set(CMAKE_INSTALL_FULL_SYSCONDIR "/etc")|set(CMAKE_INSTALL_FULL_SYSCONDIR "$${CMAKE_INSTALL_PREFIX}/etc")|
s|set(SYSCONFDIR /etc)|set(SYSCONFDIR "$${CMAKE_INSTALL_PREFIX}/etc")|
s|set(MOTGEN_DIR /etc/motdgen.d)|set(MOTGEN_DIR "$${CMAKE_INSTALL_PREFIX}/etc/motdgen.d")|
EOT
      run = "sed -i -f $PROP ../CMakeLists.txt"
    },
    "mkdir -p {{prefix}}/etc {{prefix}}/var/lib/tdnf",
    "cmake .. $CMAKE_ARGS",
    "make --jobs {{ hw.concurrency }}",
    "make install",
  ]
  working-directory = "build"

  env {
    CMAKE_ARGS = [
      "-DCMAKE_INSTALL_PREFIX={{prefix}}",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_EXE_LINKER_FLAGS=-ldl",
      "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-ldl,-lssl,-lcrypto",
      "-DSYSTEMD_DIR={{prefix}}/lib/systemd/system",
      "-DHISTORY_DB_DIR={{prefix}}/var/lib/tdnf",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/vmware/tdnf/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  script = [
    {
      run = "test \"$(tdnf --version)\" = \"tdnf: {{version}}\""
    },
    {
      fixture = <<EOT
[main]
gpgcheck=0
installonly_limit=3
clean_requirements_on_remove=true
best=true
keepcache=false
EOT
      run = "cp $FIXTURE tdnf.conf"
    },
    {
      fixture = <<EOT
[rocky-baseos]
name=Rocky Linux $releasever BaseOS
baseurl=https://download.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/
gpgcheck=0
enabled=1
EOT
      run = "cp $FIXTURE rocky.repo"
      working-directory = "yum.repos.d"
    },
    "tdnf --config=\"$PWD/tdnf.conf\" --setopt=reposdir=\"$PWD/yum.repos.d\" --setopt=cachedir=\"$PWD/cache\" --setopt=rocky-baseos.sslcacert=\"$SSL_CERT_FILE\" --installroot=\"$PWD/$${ROOTFS}\" --releasever=\"$${RELEASE}\" --forcearch=\"$ARCH\" --refresh list available filesystem | tee list.out",
    "grep '^filesystem' list.out",
  ]

  env {
    RELEASE = "10"
    ROOTFS = "rocky-$${RELEASE}-rootfs"

    aarch64 {
      ARCH = "aarch64"
    }

    x86-64 {
      ARCH = "x86_64"
    }
  }
}

versions {
  github = "vmware/tdnf/releases"
}
