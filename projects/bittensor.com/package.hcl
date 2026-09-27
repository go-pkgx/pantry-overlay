dependencies = {
  "openssl.org" = "^3"
  "pkgx.sh" = ">=1"
}
display-name = "Bittensor"

build {
  dependencies = {
    "cmake.org" = 3
    "python.org" = "~3.11"
    "rust-lang.org" = ">=1.56"
    "rust-lang.org/cargo" = "*"
  }
  env = {
    darwin = {
      LDFLAGS = "$LDFLAGS -Wl,-headerpad_max_install_names"
      OPENSSL_STATIC = "1"
      RUSTFLAGS = "-C link-args=-headerpad_max_install_names"
    }
    "darwin/aarch64" = {
      HOMEBREW_PREFIX = "/opt/homebrew"
    }
    "darwin/x86-64" = {
      HOMEBREW_PREFIX = "/usr/local"
    }
  }
  script = [
    {
      if = "<8"
      run = [
        "bkpyvenv stage {{prefix}} {{version}}",
        "$${{prefix}}/venv/bin/pip install .",
        "bkpyvenv seal {{prefix}} btcli",
      ]
    },
    {
      if = ">=10"
      run = "python -m pip install --no-deps --force-reinstall --no-cache-dir -v --no-binary bittensor_drand,bittensor_wallet --prefix={{prefix}} bittensor_drand bittensor_wallet"
    },
    {
      if = ">=8"
      run = [
        "pip install . --prefix={{prefix}} --no-build-isolation",
        "python -m pip install --no-deps --force-reinstall --no-cache-dir -v --no-binary bittensor_wallet --prefix={{prefix}} bittensor_wallet",
        "ln -s python{{deps.python.org.version.marketing}} {{prefix}}/lib/python{{deps.python.org.version.major}}",
      ]
    },
    {
      if = ">=10"
      run = <<EOT
if test "{{hw.platform}}" = "darwin"; then
  pkgx +openssl.org^3
  cp -a {{pkgx.prefix}}/openssl.org/v3/lib/* {{prefix}}/lib/
  otool -l bittensor_wallet/bittensor_wallet.cpython-311-darwin.so | grep -C5 openssl || true
  install_name_tool -change $${HOMEBREW_PREFIX}/opt/openssl@3/lib/libssl.3.dylib {{prefix}}/lib/libssl.3.dylib bittensor_wallet/bittensor_wallet.cpython-311-darwin.so
  install_name_tool -change $${HOMEBREW_PREFIX}/opt/openssl@3/lib/libcrypto.3.dylib {{prefix}}/lib/libcrypto.3.dylib bittensor_wallet/bittensor_wallet.cpython-311-darwin.so
  otool -l bittensor_wallet/bittensor_wallet.cpython-311-darwin.so | grep -C5 openssl || true
fi
EOT
      working-directory = "{{prefix}}/lib/python{{deps.python.org.version.marketing}}/site-packages"
    },
  ]
}

distributable {
  strip-components = 1
  url = "https://github.com/opentensor/bittensor/archive/refs/tags/{{version.tag}}.tar.gz"
}

runtime {

  env {
    PYTHONPATH = "{{prefix}}/lib/python{{deps.python.org.version.major}}/site-packages:$PYTHONPATH"
  }
}

test {
  dependencies = {
    "python.org" = "~3.11"
  }
  script = [
    {
      if = "darwin"
      run = <<EOT
if test "$(sw_vers -productVersion | cut -d . -f 1)" -lt 13; then
  exit 0
fi
EOT
    },
    {
      if = "<8"
      run = "btcli --help | grep {{version}}"
    },
    {
      if = ">=8<10"
      run = "test \"$(python -c 'import bittensor; print(bittensor.__version__)')\" = \"{{version}}\""
    },
    {
      if = ">=10"
      run = "test \"$(python -c 'import importlib.metadata; print(importlib.metadata.version(\"bittensor\"))')\" = \"{{version}}\""
    },
  ]
}

versions {
  github = "opentensor/bittensor"
}
