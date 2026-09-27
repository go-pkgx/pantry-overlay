dependencies = {
  "openssl.org" = "^3"
}
provides = [
  "bin/factotum",
]
test = [
  "test \"$(factotum --version)\" = \"Factotum version {{version}}\"",
  {
    fixture = {
      content = <<EOT
{
    "schema": "iglu:com.snowplowanalytics.factotum/factfile/jsonschema/1-0-0",
    "data": {
        "name": "Factotum demo",
        "tasks": [
            {
                "name": "echo alpha",
                "executor": "shell",
                "command": "echo",
                "arguments": [ "alpha" ],
                "dependsOn": [],
                "onResult": {
                    "terminateJobWithSuccess": [],
                    "continueJob": [ 0 ]
                }
            },
            {
                "name": "echo beta",
                "executor": "shell",
                "command": "echo",
                "arguments": [ "beta" ],
                "dependsOn": [ "echo alpha" ],
                "onResult": {
                    "terminateJobWithSuccess": [],
                    "continueJob": [ 0 ]
                }
            },
            {
                "name": "echo omega",
                "executor": "shell",
                "command": "echo",
                "arguments": [ "and omega!" ],
                "dependsOn": [ "echo beta" ],
                "onResult": {
                    "terminateJobWithSuccess": [],
                    "continueJob": [ 0 ]
                }
            }
        ]
    }
}
EOT
      extname = ".factfile"
    }
    run = "factotum run $FIXTURE"
  },
]

build {
  dependencies = {
    "rust-lang.org" = "~1.78"
    "rust-lang.org/cargo" = "~0.80"
  }
  script = "cargo install --locked --path . --root {{prefix}}"
}

distributable {
  strip-components = 1
  url = "https://github.com/snowplow/factotum/archive/refs/tags/{{ version.tag }}.tar.gz"
}

versions {
  github = "snowplow/factotum"
}
