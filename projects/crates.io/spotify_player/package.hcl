dependencies = {
  "github.com/libsixel/libsixel" = "^1"
  linux = {
    "alsa-project.org/alsa-lib" = "^1"
    "freedesktop.org/dbus" = "^1"
  }
  "openssl.org" = "^3"
}
provides = [
  "bin/spotify_player",
]
test = "test \"$(spotify_player --version)\" = \"spotify_player {{version}}\""

build {
  dependencies = {
    "github.com/mikefarah/yq" = ">=4"
    "rust-lang.org" = ">=1.60"
    "rust-lang.org/cargo" = "*"
  }
  script = [
    "yq -i '.package.version = \"{{version}}\"' spotify_player/Cargo.toml",
    "cargo install $ARGS",
    {
      if = "darwin"
      run = [
        "SIXEL=$(otool -l {{prefix}}/bin/spotify_player | sed -n 's/.*name \\(.*libsixel\\.1\\.dylib\\) (offset.*/\\1/p')",
        "if test ! -z \"$SIXEL\"; then",
        "install_name_tool -change \"$SIXEL\" {{deps.github.com/libsixel/libsixel.prefix}}/lib/libsixel.1.dylib {{prefix}}/bin/spotify_player",
        "fi",
      ]
    },
  ]

  env {
    ARGS = [
      "--locked",
      "--path spotify_player",
      "--root {{prefix}}",
      "--features sixel,notify,fzf",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/aome510/spotify-player/archive/refs/tags/{{version.tag}}.tar.gz"
}

versions {
  github = "aome510/spotify-player"
}
