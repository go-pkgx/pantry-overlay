dependencies = {
  "curl.se" = "*"
  "openssl.org" = "^3"
  "zlib.net" = 1
}

build {
  dependencies = {
    "cmake.org" = "*"
    "git-scm.org" = "^2"
    linux = {
      "kernel.org/linux-headers" = "^5"
    }
  }
  script = [
    "git submodule update --init --recursive",
    "cmake -S . -B build $ARGS",
    "cmake --build build -j {{hw.concurrency}}",
    "cmake --install build",
  ]

  env {
    ARGS = [
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}\"",
      "-DENABLE_TESTING=OFF",
      "-DZLIB_INCLUDE_DIR={{deps.zlib.net.prefix}}/include",
      "-Dcrypto_INCLUDE_DIR={{deps.openssl.org.prefix}}/include",
    ]
    LDFLAGS = "-Wl,-rpath,{{prefix}}"

    darwin {
      ARGS = [
        "-DZLIB_LIBRARY={{deps.zlib.net.prefix}}/lib/libz.dylib",
        "-Dcrypto_LIBRARY={{deps.openssl.org.prefix}}/lib/libcrypto.dylib",
      ]
    }

    linux {
      ARGS = [
        "-DZLIB_LIBRARY={{deps.zlib.net.prefix}}/lib/libz.so",
        "-Dcrypto_LIBRARY={{deps.openssl.org.prefix}}/lib/libcrypto.so",
      ]
    }
  }
}

distributable {
  ref = "$${{version}}"
  url = "git+https://github.com/aws/aws-sdk-cpp"
}

test {
  fixture = <<EOT
#include <aws/core/Version.h>
#include <iostream>

int main() {
  std::cout << Aws::Version::GetVersionString() << std::endl;
  return 0;
}
EOT
  script = <<EOT
mv $FIXTURE test.cpp
c++ -std=c++11 test.cpp -laws-cpp-sdk-core -o test
./test
EOT
}

versions {
  github = "aws/aws-sdk-cpp/tags"
  ignore = "/[1-9]$/"
}
