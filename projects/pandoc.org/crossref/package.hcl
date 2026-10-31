build {
  dependencies = {
    "haskell.org"       = "~9.8.4"
    "haskell.org/cabal" = "^3"
    linux = {
      "gnu.org/binutils" = "~2.44"
      "gnu.org/gcc"      = 14
    }
    "openssl.org" = "^3"
  }
  script = [
    {
      if                = "darwin"
      run               = <<EOT
if ! grep -q 'rpath,{{pkgx.prefix}}' settings; then
  sed -i \
    -e 's|\(C compiler flags.*\)")|\1 -Wl,-rpath,{{pkgx.prefix}}")|' \
    -e 's|\(C++ compiler flags.*\)")|\1 -Wl,-rpath,{{pkgx.prefix}}")|' \
    -e 's|\(C compiler link flags.*\)")|\1 -Wl,-rpath,{{pkgx.prefix}}")|' \
    settings
fi
EOT
      working-directory = "$${{deps.haskell.org.prefix}}/.ghcup/ghc/{{deps.haskell.org.version}}/lib/ghc-{{deps.haskell.org.version}}/lib"
    },
    "cabal update",
    "mkdir -p \"{{prefix}}/bin\"",
    "cabal install --install-method=copy --installdir={{prefix}}/bin",
  ]
}
