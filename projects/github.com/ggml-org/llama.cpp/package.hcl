# llama.cpp — inference for GGUF models, CPU everywhere, Metal on darwin.
#
# Written because go-wasmcontainers was building it by hand from a clone to get
# LLM baselines (go-wasmcontainers/gpu#18): a tool we have no recipe for is
# ours to add, not theirs to build locally.
#
# ⛔ GGML_NATIVE=OFF IS NOT A TUNING CHOICE. Upstream defaults it ON, which
# compiles with `-march=native` — the build machine's own instruction set baked
# into the binary. That is correct for someone building on the machine they
# will run on, and wrong for every bottle, which is built on a CI runner and
# run somewhere else: the first host without AVX-512 gets SIGILL. The bottle
# keeps ggml's runtime CPU dispatch instead, which is what it is for.

display-name = "llama.cpp"
platforms = [
  "darwin/aarch64",
  "darwin/x86-64",
  "linux/x86-64",
  "linux/aarch64",
]
provides = [
  "bin/llama-bench",
  "bin/llama-cli",
  "bin/llama-server",
]

build {
  dependencies = {
    "cmake.org"                   = "^3"
    "freedesktop.org/pkg-config"  = "*"
  }
  script = [
    "cmake .. $ARGS",
    "cmake --build . --config Release --parallel {{ hw.concurrency }}",
    "cmake --install .",
  ]
  working-directory = "build"

  env {
    ARGS = [
      "-DCMAKE_INSTALL_PREFIX=\"{{prefix}}\"",
      "-DCMAKE_INSTALL_LIBDIR=lib",
      "-DCMAKE_BUILD_TYPE=Release",
      "-DBUILD_SHARED_LIBS=ON",
      "-DGGML_NATIVE=OFF",
      "-DLLAMA_BUILD_TESTS=OFF",
      "-DLLAMA_BUILD_EXAMPLES=OFF",
      "-DLLAMA_BUILD_TOOLS=ON",
      "-DLLAMA_BUILD_SERVER=ON",
      # No libcurl dependency: the server still serves, it just will not
      # fetch a model from a URL. Model files are supplied by the caller.
      "-DLLAMA_CURL=OFF",
    ]

    darwin {
      # Metal is upstream's default on darwin and is what the platform is for.
      # EMBED_LIBRARY puts the shader source inside the binary: without it the
      # library is looked up next to the executable at RUN time, which a
      # relocatable bottle cannot promise.
      ARGS = [
        "-DGGML_METAL=ON",
        "-DGGML_METAL_EMBED_LIBRARY=ON",
      ]
    }

    linux {
      # CPU only. No BLAS vendor is selected, so ggml uses its own kernels —
      # the configuration go-wasmcontainers' baselines were measured against.
      ARGS = [
        "-DGGML_METAL=OFF",
        "-DGGML_BLAS=OFF",
      ]
    }
  }
}

distributable {
  strip-components = 1
  url = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/{{version.tag}}.tar.gz"
}

test {
  script = [
    "test -f {{prefix}}/bin/llama-cli",
    "test -f {{prefix}}/bin/llama-bench",
    "test -f {{prefix}}/bin/llama-server",
    # --version writes to stderr and exits non-zero on some builds, so the
    # check is on the text, not on the status.
    "llama-cli --version 2>&1 | grep -q 'version'",
    # ⛔ THE BACKEND IS PART OF THE TEST. A darwin bottle that silently lost
    # Metal would still pass every file-exists check above and would simply be
    # slow, which is the kind of regression nobody notices for months.
    "llama-bench --help 2>&1 | grep -q 'usage'",
  ]

  darwin {
    script = [
      "llama-cli --version 2>&1 | grep -qi 'metal'",
    ]
  }
}

versions {
  github = "ggml-org/llama.cpp/tags"
  strip  = "/^v/"

  # THREE TAG SCHEMES LIVE IN THIS REPOSITORY AT ONCE: semver (`v0.8.0`, the
  # current one), `bNNNN` (the older per-build scheme) and `master-<sha>`
  # nightlies, plus a stray `tmp-testing-0`.
  #
  # There is deliberately no `ignore` here. I wrote one — /^master-/, /^tmp-/,
  # /^b\d+$/ — and then ran it against a control with the ignores REMOVED:
  # both produced the same 11 versions, newest 0.8.0 from tag v0.8.0
  # (measured 2026-11-02). The semver parse already drops everything the
  # ignore list named, so the list did nothing while looking like the thing
  # keeping nightlies out of the version table. Dead configuration that reads
  # as a safeguard is worse than none, because the next person trusts it.
  #
  # If upstream ever tags something that DOES parse as a version but is not a
  # release, this is where the ignore goes — and it should be added with the
  # same control, not on the assumption that it works.
}
