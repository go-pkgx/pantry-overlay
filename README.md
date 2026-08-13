# pantry-overlay

A tiny **overlay** for the pkgx pantry, consumed by `go-pkgx/bottle` via
`PKGX_PANTRY_OVERLAY`. Each recipe here overrides the matching upstream
`pkgxdev/pantry` recipe (everything else falls back upstream).

Purpose: correct **stale dependency constraints** so `pkgm install` resolves the
closure that our published bottles were actually built against — e.g. curl/wget/git
pin `openssl.org: ^1.1`, but openssl is now 3.x/4.x, so the upstream recipe is
unsatisfiable against the current registry.

BSD-3-Clause, © the go-pkgx authors.
