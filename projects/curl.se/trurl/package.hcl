build {
  dependencies = {
    "openssl.org" = "^3"
  }
  script = <<EOT
# Makefile is not very flexible, so we have to edit it
sed -i.bak -e "s/^\(CFLAGS = .*\)\$/\1 $CFLAGS/" Makefile
rm Makefile.bak

make
mkdir -p {{prefix}}/bin
mv trurl {{prefix}}/bin
EOT
}
