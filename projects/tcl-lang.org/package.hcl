dependencies = {
  "freedesktop.org/pkg-config" = "^0.29"
  "freetype.org"               = "^2"
  "openssl.org"                = "^3"
  "x.org/exts"                 = "^1"
  "x.org/x11"                  = "=1.8.11"
  "zlib.net"                   = "^1.3"
}

# Enumerate where the tarball actually LIVES. `distributable` above downloads
# from SourceForge, while this scraped tcl-lang.org's download page, which
# lists only what upstream currently recommends — so when 8.6.16 dropped off
# that page, this recipe could no longer name a version SourceForge still
# serves. Upstream's pantry was corrected; this copy was not, and the overlay
# WINS for a consumer, so the stale enumeration is the one tcl versions were
# being resolved with.
versions {
  match = "/Tcl\\/\\d+\\.\\d+\\.\\d+\\//"
  strip = [
    "/^Tcl\\//",
    "/\\/$/",
  ]
  url = "https://sourceforge.net/projects/tcl/files/Tcl/"
}
