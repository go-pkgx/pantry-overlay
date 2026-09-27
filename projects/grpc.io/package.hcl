dependencies = {
  "abseil.io" = "^20250512"
  "c-ares.org" = "*"
  "github.com/google/re2" = "*"
  linux = {
    "gnu.org/gcc/libstdcxx" = 14
    "protobuf.dev" = "35.1.0"
  }
  "openssl.org" = "^3"
  "zlib.net" = "*"
}

build {
  dependencies = {
    "cmake.org" = "^3"
    darwin = {
      "gnu.org/patch" = "*"
    }
    "git-scm.org" = "^2"
    "gnu.org/autoconf" = "*"
    "gnu.org/automake" = "*"
    "gnu.org/libtool" = "*"
  }
  script = [
    {
      run = "git submodule update --init --recursive"
      working-directory = "../.."
    },
    {
      if = ">=1.63<1.66.2"
      prop = <<EOT
--- CMakeLists.txt.orig	2024-05-16 01:01:03.000000000 +0000
+++ CMakeLists.txt
@@ -3682,6 +3682,7 @@ target_include_directories(upb_json_lib
 )
 target_link_libraries(upb_json_lib
   $${_gRPC_ALLTARGETS_LIBRARIES}
+  grpc++_unsecure
   utf8_range_lib
   upb_message_lib
 )
@@ -3883,6 +3884,7 @@ target_include_directories(upb_textforma
 )
 target_link_libraries(upb_textformat_lib
   $${_gRPC_ALLTARGETS_LIBRARIES}
+  grpc++_unsecure
   utf8_range_lib
   upb_message_lib
 )
EOT
      run = <<EOT
if test "{{hw.platform}}" = "darwin"; then
  patch -i $PROP || true
fi
EOT
      working-directory = "../.."
    },
    "cmake $COMMON_ARGS $ARGS ../..",
    "make install",
    {
      if = "darwin"
      run = [
        "cmake $COMMON_ARGS $CLI_ARGS ../..",
        "make grpc_cli",
        "cp grpc_cli \"{{prefix}}/bin\"",
        "cp libgrpc++_test_config.* \"{{prefix}}/lib\"",
      ]
    },
    {
      if = "darwin"
      run = <<EOT
for f in bin/* lib/libgrpc++_test_config.dylib; do
  if test -f $f && ! otool -l $f | grep @loader_path/../lib; then
    install_name_tool -add_rpath @loader_path/../lib $f
  fi
done
EOT
      working-directory = "{{prefix}}"
    },
  ]
  working-directory = "cmake/build"

  env {
    ARGS = [
      "-DCMAKE_CXX_STANDARD=17",
      "-DCMAKE_CXX_STANDARD_REQUIRED=TRUE",
      "-DgRPC_BUILD_TESTS=OFF",
      "-DgRPC_INSTALL=ON",
      "-DgRPC_ABSL_PROVIDER=package",
      "-DgRPC_CARES_PROVIDER=package",
      "-DgRPC_SSL_PROVIDER=package",
      "-DgRPC_ZLIB_PROVIDER=package",
      "-DgRPC_RE2_PROVIDER=package",
    ]
    CLI_ARGS = [
      "-DgRPC_BUILD_TESTS=ON",
    ]
    COMMON_ARGS = [
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}\"",
      "-DCMAKE_INSTALL_RPATH={{prefix}}",
      "-DBUILD_SHARED_LIBS=ON",
    ]

    darwin {
      ARGS = [
        "-DgRPC_PROTOBUF_PROVIDER=module",
        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath,{{pkgx.prefix}},-undefined,dynamic_lookup",
      ]
    }

    linux {
      ARGS = [
        "-DgRPC_PROTOBUF_PROVIDER=package",
        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-labsl_log_internal_message,-lstdc++,--allow-shlib-undefined",
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-labsl_log_internal_message,-lstdc++,--allow-shlib-undefined",
      ]
    }
  }
}

distributable {
  ref = "$${{version.tag}}"
  url = "git+https://github.com/grpc/grpc"
}

provides {
  darwin = [
    "bin/grpc_csharp_plugin",
    "bin/grpc_node_plugin",
    "bin/grpc_cpp_plugin",
    "bin/grpc_python_plugin",
    "bin/grpc_objective_c_plugin",
    "bin/grpc_ruby_plugin",
    "bin/grpc_php_plugin",
    "bin/grpc_cli",
  ]
  linux = [
    "bin/grpc_csharp_plugin",
    "bin/grpc_node_plugin",
    "bin/grpc_cpp_plugin",
    "bin/grpc_python_plugin",
    "bin/grpc_objective_c_plugin",
    "bin/grpc_ruby_plugin",
    "bin/grpc_php_plugin",
  ]
}

test {
  dependencies = {
    "freedesktop.org/pkg-config" = "^0"
  }
  script = [
    {
      if = "darwin"
      run = [
        "(grpc_cli ls localhost:58931 2>&1 || true) | tee out",
        "grep -E \"(failed to connect to all addresses|rpc failed)\" out",
      ]
    },
    {
      fixture = {
        content = <<EOT
#include <grpc/grpc.h>
int main() {
  grpc_init();
  grpc_shutdown();
  return GRPC_STATUS_OK;
}
EOT
        extname = "cpp"
      }
      run = "clang++ $FIXTURE -o test $PKG_CONFIG $LIBS"
    },
    "./test",
  ]

  env {
    PKG_CONFIG = "$(pkg-config --cflags --libs libcares protobuf re2 grpc++)"

    linux {
      LIBS = "-labsl_log_internal_message -lstdc++ -Wl,--allow-shlib-undefined"
    }
  }
}

versions {
  github = "grpc/grpc"
}
