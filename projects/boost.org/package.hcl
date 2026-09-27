dependencies = {
  "facebook.com/zstd" = "^1"
  "sourceware.org/bzip2" = "^1"
}
distributable = [
  {
    strip-components = 1
    url = "https://archives.boost.io/release/{{version}}/source/boost_{{version.major}}_{{version.minor}}_{{version.patch}}.tar.gz"
  },
  {
    strip-components = 1
    url = "https://boostorg.jfrog.io/artifactory/main/release/{{ version }}/source/boost_{{version.major}}_{{version.minor}}_{{version.patch}}.tar.gz"
  },
]
test = [
  "c++ test.cpp -std=c++14 -lboost_iostreams -lzstd",
  "./a.out",
]

build {
  script = [
    "./bootstrap.sh --prefix={{ prefix }}",
    "./b2 $ARGS",
    {
      if = "darwin"
      run = <<EOT
for LIB in *.dylib; do
  install_name_tool -add_rpath @loader_path $LIB
  install_name_tool -add_rpath @loader_path/../../.. $LIB
done
EOT
      working-directory = "$${{prefix}}/lib"
    },
  ]

  env {
    ARGS = [
      "install",
      "--prefix={{ prefix }}",
    ]

    darwin {
      ARGS = [
        "linkflags=-Wl,-headerpad_max_install_names",
      ]
    }

    linux {
      ARGS = [
        "cxxflags=-fPIC",
        "linkflags=-fPIC",
      ]
    }
  }
}

versions {
  github = "boostorg/boost"
  strip = "/^boost-/"
}
