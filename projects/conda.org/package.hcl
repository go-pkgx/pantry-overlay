dependencies = {
  "openssl.org" = "^3"
  "pkgx.sh" = ">=1"
}
provides = [
  "bin/conda",
]
test = [
  "conda --version | grep {{version}}",
  "source /dev/stdin <<<\"$(conda shell.bash hook)\"",
  {
    if = ">=25.7.0"
    run = [
      "conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main",
      "conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r",
    ]
  },
  "conda create --yes --name snowflakes biopython",
  "conda activate snowflakes",
  "conda info --envs | grep snowflakes",
  "conda deactivate",
  <<EOT
if ! conda info --envs | grep snowflakes; then
  exit 1
fi
EOT
,
]
warnings = [
  "vendored",
]

build {
  dependencies = {
    "curl.se" = "*"
    "gnu.org/patch" = "*"
    "python.org" = "=3.11.5"
  }
  env = {
    "darwin/aarch64" = {
      SUFFIX = "MacOSX-arm64"
    }
    "darwin/x86-64" = {
      SUFFIX = "MacOSX-x86_64"
    }
    "linux/aarch64" = {
      SUFFIX = "Linux-aarch64"
    }
    "linux/x86-64" = {
      SUFFIX = "Linux-x86_64"
    }
  }
  script = [
    "bkpyvenv stage {{prefix}} {{version}}",
    <<EOT
for v in 9 8 7 6 5 4 3 2 1 0; do
  if curl -fLS https://repo.anaconda.com/miniconda/Miniconda3-py311_{{version}}-$v-$${SUFFIX}.sh -o miniconda.sh; then
    break
  fi
done
test -f miniconda.sh
EOT
,
    "chmod +x miniconda.sh",
    "./miniconda.sh -b -f -s -p {{prefix}}/venv",
    {
      run = <<EOT
cd conda-{{version}}-*/lib/python3.11/site-packages
patch -p1 < $SRCROOT/props/context.py.diff
EOT
      working-directory = "$${{prefix}}/venv/pkgs"
    },
    {
      run = "patch -p1 < $SRCROOT/props/context.py.diff"
      working-directory = "$${{prefix}}/venv/lib/python3.11/site-packages"
    },
    "bkpyvenv seal {{prefix}} conda",
    "{{prefix}}/bin/conda init",
    {
      run = "ln -s venv/lib lib"
      working-directory = "$${{prefix}}"
    },
  ]
}

runtime {

  env {
    CRYPTOGRAPHY_OPENSSL_NO_LEGACY = 1
  }
}

versions {
  match = "/Miniconda3-py311_\\d+\\.\\d+\\.\\d+-\\d+-MacOSX-arm64.sh/"
  strip = [
    "/Miniconda3-py311_/",
    "/-\\d+-MacOSX-arm64.sh/",
  ]
  url = "https://repo.anaconda.com/miniconda/"
}
