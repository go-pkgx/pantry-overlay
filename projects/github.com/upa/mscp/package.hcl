dependencies = {
  "openssl.org" = "^3"
  "zlib.net" = "^1.2.11"
}
display-name = "mscp"
provides = [
  "bin/mscp",
]
test = "test \"$(mscp|head -1|cut -d':' -f1|cut -d' ' -f2)\" = v{{version}}"

build {
  dependencies = {
    "cmake.org" = "*"
    "git-scm.org" = "*"
    "gnu.org/bash" = "*"
    "llvm.org" = "*"
  }
  script = <<EOT
#pip install libnacl
#
# this produce an error
#
# pip install abimap
git submodule update --init
patch -d libssh -p1 < patch/$(git --git-dir=./libssh/.git describe).patch
cmake -B $${CMAKE_BUILD_PREFIX} \
      -D CMAKE_BUILD_TYPE=$${CMAKE_BUILD_TYPE} \
      -D OPENSSL_ROOT_DIR={{deps.openssl.org.prefix}}
cmake --build $${CMAKE_BUILD_PREFIX} --config $${CMAKE_BUILD_TYPE}
cmake --install $${CMAKE_BUILD_PREFIX} --prefix $${CMAKE_INSTALL_PREFIX}
EOT

  env {
    CMAKE_BUILD_PREFIX = "./build"
    CMAKE_BUILD_TYPE = "Release"
    CMAKE_INSTALL_PREFIX = "{{ prefix }}"
  }
}

distributable {
  ref = "$${{version.tag}}"
  url = "git+https://github.com/upa/mscp"
}

versions {
  github = "upa/mscp"
}
