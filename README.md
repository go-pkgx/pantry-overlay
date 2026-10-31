# pantry-overlay

A tiny **overlay** for the pkgx pantry, consumed by `go-pkgx/bottle` via
`PKGX_PANTRY_OVERLAY`. Each recipe here overrides the matching upstream
`pkgxdev/pantry` recipe (everything else falls back upstream).

Two purposes.

**1. Correct stale dependency constraints** so `pkgm install` resolves the
closure that our published bottles were actually built against — e.g. curl/wget/git
pin `openssl.org: ^1.1`, but openssl is now 3.x/4.x, so the upstream recipe is
unsatisfiable against the current registry.

**OpenSSL is pinned to the LTS line: `openssl.org: ~3.5`.** Every recipe here
that depends on openssl declares `~3.5`, not `^3`. OpenSSL 3.5 is the only LTS
(supported until 2030-04-08, per
<https://openssl-library.org/policies/releasestrat/>); 3.4 expired on 2026-10-22
and 3.6 loses support on 2026-11-01, yet `^3` resolves to the newest 3.x, 3.6.4.
Mind the operator: `^3.5` would **not** pin the line, because the caret permits
minor upgrades and 3.6 satisfies it. Only `~3.5` fixes major.minor.
`tools/opensslpin` prints what a constraint resolves to, per platform, against
the real registry. Bump the pin deliberately when the next LTS ships.

BSD-3-Clause, © the go-pkgx authors.

**2. Carry recipes that exist only here.** A recipe the go-pkgx factory adds
through `packages/overrides/` (a creation patch) reaches the BUILD and nothing
else: `overrides/` is applied to the pantry checkout the factory builds from,
while a consumer resolving a closure reads the pantry over HTTP and gets a 404.

`kernel.org/linux` is the case that showed it. The bottle is published, signed
and attested — and `bottle.ResolveClosureFor` could not resolve it at all, so
the only way to install the kernel was to pick its version straight from the
registry and skip the closure walk. **A package published without a readable
recipe is half published.** Recipes created by an override belong here too.
