dependencies = {
  "gnu.org/gettext" = "^1"
  linux = {
    "gnu.org/libiconv" = "^1.1"
  }
}
provides = [
  "bin/nvim",
]

build {
  dependencies = {
    "cmake.org" = ">=3.16"
    "freedesktop.org/pkg-config" = "^0.29"
    "git-scm.org" = "^2"
    "gnu.org/libtool" = "^2"
    "info-zip.org/unzip" = "*"
  }
  env = {
    "linux/aarch64" = {
      RT_LIBDIR = "/usr/lib/aarch64-linux-gnu"
    }
    "linux/x86-64" = {
      RT_LIBDIR = "/usr/lib/x86_64-linux-gnu"
    }
  }
  script = [
    {
      if = "linux"
      run = <<EOT
if test -f BuildLuarocks.cmake; then
  sed -i.bak \
    -e "1i\
    set(RT_LIBDIR \"$RT_LIBDIR\")" \
    -e 's/\(build busted [0-9]\+\.[0-9]\+\.[0-9]\+\)/\1 RT_LIBDIR=$${RT_LIBDIR}/' \
    BuildLuarocks.cmake
fi
EOT
      working-directory = "cmake.deps/cmake"
    },
    "make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=\"{{prefix}}\" install",
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/neovim/neovim/archive/refs/tags/v{{version}}.tar.gz"
}

test {
  script = [
    "echo \"$FIXTURE vim\\!\\!\" > fixture",
    "nvim --headless -i NONE -u NONE '+s/vim/neovim/g' +wq fixture",
    "test \"Hello World from neovim\\!\\!\" = \"$(cat fixture)\"",
  ]

  env {
    FIXTURE = "Hello World from "
  }
}

versions {
  github = "neovim/neovim/releases/tags"
}
