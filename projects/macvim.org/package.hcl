dependencies = {
  "cscope.sourceforge.io" = "*"
  "gnu.org/gettext" = "^1"
  "invisible-island.net/ncurses" = "*"
  "libsodium.org" = "*"
  "lua.org" = "*"
  "python.org" = "~3.11"
  "ruby-lang.org" = "*"
}
platforms = [
  "darwin",
]
provides = [
  "bin/gview",
  "bin/gvim",
  "bin/gvimdiff",
  "bin/gvimtutor",
  "bin/mview",
  "bin/mvim",
  "bin/mvimdiff",
  "bin/mvimtutor",
  "bin/view",
  "bin/vim",
  "bin/vimdiff",
  "bin/vimtutor",
]
test = [
  "mvim --version | grep VIM",
  "mvim -v -T dump  -s commands.vim test.txt <<< $'\\n'",
  "cat test.txt | grep \"hello python3\"",
]

build {
  dependencies = {
    "gnu.org/make" = "*"
  }
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }}",
    {
      run = "cp -a $SRCROOT/src/MacVim/build/Release/MacVim.app ."
      working-directory = "$${{prefix}}/libexec"
    },
    {
      run = <<EOT
for file in {g,m,}{view,vim,vimdiff,vimtutor}; do
  ln -s ../libexec/MacVim.app/Contents/bin/$file $file
done
EOT
      working-directory = "$${{prefix}}/bin"
    },
  ]

  env {
    ARGS = [
      "--with-features=huge",
      "--enable-multibyte",
      "--enable-perlinterp",
      "--enable-rubyinterp",
      "--enable-tclinterp",
      "--enable-terminal",
      "--without-x",
      "--with-compiledby=tea.xyz",
      "--without-local-dir",
      "--enable-cscope",
      "--enable-luainterp",
      "--with-lua-prefix={{deps.lua.org.prefix}}",
      "--enable-luainterp",
      "--enable-python3interp",
      "--disable-sparkle",
      "--disable-gpm",
      "--disable-canberra",
      "--enable-fail-if-missing",
      "--with-macarchs=$(uname -m)",
      "--with-tlib=ncurses",
    ]
    CC = "clang"
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/macvim-dev/macvim/archive/release-{{version.major}}.tar.gz"
}

runtime {

  env {
    PYTHONHOME = "{{deps.python.org.prefix}}"
  }
}

versions {
  github = "macvim-dev/macvim/tags"
  match = "/release-\\d+/"
  strip = [
    "/^release-/",
  ]
}
