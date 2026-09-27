platforms = [
  "linux",
]
provides = []

build {
  dependencies = {
    "curl.se" = "*"
    "python.org" = "^3"
  }
  script = [
    "curl -fsSL -o redistrib.json https://developer.download.nvidia.com/compute/cuda/redist/redistrib_{{version}}.json",
    <<EOT
python3 - <<'PY' > component.txt
import json
# pkgx says x86-64 / aarch64; NVIDIA says x86_64, and distinguishes sbsa
# (server ARM, what a cluster has) from aarch64 (Tegra). HPC wants sbsa.
arch = {"x86-64": "linux-x86_64", "aarch64": "linux-sbsa"}["{{hw.arch}}"]
c = json.load(open("redistrib.json"))["cuda_cudart"]
if arch not in c:
    raise SystemExit(f"cuda_cudart has no {arch} in this toolkit")
print(c["version"], c[arch]["relative_path"], c[arch]["sha256"])
PY
EOT
,
    "cat component.txt",
    "curl -fsSL -o cudart.tar.xz \"https://developer.download.nvidia.com/compute/cuda/redist/$(cut -d' ' -f2 component.txt)\"",
    "echo \"$(cut -d' ' -f3 component.txt)  cudart.tar.xz\" | sha256sum -c -",
    "mkdir -p {{prefix}}",
    "tar -xJf cudart.tar.xz --strip-components=1 -C {{prefix}}",
    "rm -rf {{prefix}}/pkg-config",
  ]
}

test {
  script = [
    "test -f {{prefix}}/lib/libcudart.so",
    "test -f {{prefix}}/include/cuda_runtime.h",
    "test -f {{prefix}}/LICENSE",
  ]
}

versions {
  match = "/redistrib_\\d+\\.\\d+\\.\\d+\\.json/"
  strip = [
    "/^redistrib_/",
    "/\\.json$/",
  ]
  url = "https://developer.download.nvidia.com/compute/cuda/redist/"
}
