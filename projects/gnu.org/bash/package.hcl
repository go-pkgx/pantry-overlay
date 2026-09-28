build {
  script = [
    {
      if  = "<5"
      run = "CFLAGS=\"$CFLAGS -Wno-incompatible-pointer-types -Wno-implicit-int\""
    },
    {
      if  = "<5"
      run = "ARGS=\"$ARGS $LEGACY_ARGS\""
    },
    {
      run = "ARGS=\"$ARGS --without-bash-malloc\""
    },
    "./configure --prefix={{ prefix }} $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {
    CFLAGS = [
      "-DSSH_SOURCE_BASHRC",
      "-Wno-implicit-function-declaration",
    ]

    darwin {
      LDFLAGS = "$LDFLAGS -Wl,-headerpad_max_install_names"
      LEGACY_ARGS = [
        "ac_cv_func_snprintf=yes",
        "ac_cv_func_vsnprintf=yes",
        "--disable-nls",
      ]
    }
  }
}

dependencies {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
}
