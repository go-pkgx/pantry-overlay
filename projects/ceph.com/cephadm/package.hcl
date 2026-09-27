dependencies = {
  "openssl.org" = "^3"
  "python.org" = "^3"
}
display-name = "cephadm"
provides = [
  "bin/cephadm",
]
test = "test \"$(cephadm version|cut -d' ' -f3)\" = {{version.tag}}"

build {
  dependencies = {
    "gnu.org/coreutils" = "*"
    "python.org" = "^3"
  }
  script = [
    "mkdir -p {{prefix}}/bin",
    {
      run = "./build.sh $BUILD_FLAGS {{prefix}}/bin/cephadm"
      working-directory = "src/cephadm"
    },
    {
      run = [
        "shebang_length=$(head -n 1 {{prefix}}/bin/cephadm | wc -c)",
        "new_shebang=\"#!/usr/bin/env python3\"",
        "padding_length=$((shebang_length - $${#new_shebang}))",
        <<EOT
if [ $padding_length -lt 0 ]; then
  echo "Error: New shebang is too long!" >&2
  exit 1
fi
EOT
,
        "padding=$(printf '%*s' \"$padding_length\" '')",
        "sed -i \"1s|^#!.*$|$${new_shebang}$${padding}|\" cephadm",
      ]
      working-directory = "$${{prefix}}/bin"
    },
  ]

  env {
    BUILD_FLAGS = [
      "--set-version-var CEPH_GIT_VER=\"$(git rev-parse HEAD)\"",
      "--set-version-var CEPH_GIT_NICE_VER=\"$(git describe)\"",
      "--set-version-var CEPH_RELEASE=\"$(sed -n '1p' ./src/ceph_release)\"",
      "--set-version-var CEPH_RELEASE_NAME=\"$(sed -n '2p' ./src/ceph_release)\"",
      "--set-version-var CEPH_RELEASE_TYPE=\"$(sed -n '3p' ./src/ceph_release)\"",
    ]

    linux {
      TMPDIR = "$(mktemp -d -p /tmp)"
    }
  }
}

distributable {
  ref = "v{{version}}"
  url = "git+https://github.com/ceph/ceph.git"
}

versions {
  github = "ceph/ceph/tags"
}
