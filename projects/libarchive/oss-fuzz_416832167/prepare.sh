#!/usr/bin/env bash
# Nothing to do!

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/corkami/pocs)
( git clone --mirror https://github.com/corkami/pocs.git /deps/git/github.com/corkami/pocs 2>/dev/null || git clone --mirror https://github.com/corkami/pocs /deps/git/github.com/corkami/pocs ) || echo 'WARN: could not mirror https://github.com/corkami/pocs'
[ -d /deps/git/github.com/corkami/pocs ] && ln -sfn /deps/git/github.com/corkami/pocs /deps/git/github.com/corkami/pocs.git || true
mkdir -p $(dirname /deps/git/github.com/nwellnhof/xmlstar)
( git clone --mirror https://github.com/nwellnhof/xmlstar.git /deps/git/github.com/nwellnhof/xmlstar 2>/dev/null || git clone --mirror https://github.com/nwellnhof/xmlstar /deps/git/github.com/nwellnhof/xmlstar ) || echo 'WARN: could not mirror https://github.com/nwellnhof/xmlstar'
[ -d /deps/git/github.com/nwellnhof/xmlstar ] && ln -sfn /deps/git/github.com/nwellnhof/xmlstar /deps/git/github.com/nwellnhof/xmlstar.git || true
mkdir -p $(dirname /deps/git/github.com/sparklemotion/nokogiri)
( git clone --mirror https://github.com/sparklemotion/nokogiri.git /deps/git/github.com/sparklemotion/nokogiri 2>/dev/null || git clone --mirror https://github.com/sparklemotion/nokogiri /deps/git/github.com/sparklemotion/nokogiri ) || echo 'WARN: could not mirror https://github.com/sparklemotion/nokogiri'
[ -d /deps/git/github.com/sparklemotion/nokogiri ] && ln -sfn /deps/git/github.com/sparklemotion/nokogiri /deps/git/github.com/sparklemotion/nokogiri.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
