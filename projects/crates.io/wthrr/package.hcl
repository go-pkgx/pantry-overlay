dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/wthrr",
]

build {
  dependencies = {
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/ttytm/wthrr-the-weathercrab/archive/refs/tags/{{ version.tag }}.tar.gz"
}

test {
  fixture = <<EOT
(
    address: "san juan, pr",
    language: "en_US",
    forecast: [
        week,
    ],
    units: (
        temperature: celsius,
        speed: kmh,
        time: military,
        precipitation: probability,
    ),
    gui: (
        border: rounded,
        color: default,
        graph: (
            style: lines(solid),
            rowspan: double,
            time_indicator: true,
        ),
        greeting: true,
    ),
)
EOT
  script = [
    {
      run = "cat $FIXTURE > wthrr.ron"
      working-directory = "$WTHRR_HOME"
    },
    "wthrr 'san juan, pr'",
  ]

  env {

    darwin {
      WTHRR_HOME = "$HOME/Library/Application Support/weathercrab"
    }

    linux {
      WTHRR_HOME = "$HOME/.config/weathercrab"
    }
  }
}

versions {
  github = "ttytm/wthrr-the-weathercrab"
}
