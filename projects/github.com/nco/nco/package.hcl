dependencies = {
  darwin = {
    "gnu.org/gettext" = "^1"
  }
  "facebook.com/zstd" = "*"
  "unidata.ucar.edu/netcdf" = "*"
}
provides = [
  "bin/ncks",
  "bin/ncra",
  "bin/ncrcat",
  "bin/ncbo",
  "bin/ncdiff",
  "bin/ncea",
  "bin/nces",
  "bin/ncecat",
  "bin/ncflint",
  "bin/ncpdq",
  "bin/ncrename",
  "bin/ncatted",
  "bin/ncwa",
]
test = [
  "(ncks --version 2>&1 || true) | grep '{{ version }}'",
  "ncgen -o test.nc test.cdl",
  "ncks -M test.nc | grep temperature",
  "ncra -O test.nc out.nc",
  "test \"$(ncks -s '%g\\n' -H -C -v temperature out.nc)\" = 25",
]

build {
  dependencies = {
    "github.com/westes/flex" = "*"
    "gnu.org/bison" = "*"
    "gnu.org/m4" = "*"
    linux = {
      "gnu.org/gcc" = 14
    }
  }
  script = [
    "./configure $ARGS",
    "make --jobs {{ hw.concurrency }} install",
  ]

  env {
    ARGS = [
      "--prefix={{ prefix }}",
      "--disable-ncap2",
      "--disable-udunits",
      "--disable-udunits2",
      "--disable-gsl",
      "--disable-openmp",
    ]
    CPPFLAGS = [
      "-I{{ deps.unidata.ucar.edu/netcdf.prefix }}/include",
    ]
    LDFLAGS = [
      "-L{{ deps.unidata.ucar.edu/netcdf.prefix }}/lib",
    ]
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/nco/nco/archive/{{ version }}.tar.gz"
}

versions {
  github = "nco/nco"
}
