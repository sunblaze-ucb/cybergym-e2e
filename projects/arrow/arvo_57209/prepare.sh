#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch arrow thirdparty tarballs so the agent phase builds offline ---
# Upstream ships an offline-build downloader; it needs wget, and one of its URLs
# (c-ares) has rotted, so run a failure-tolerant copy written BESIDE the original
# (the script reads versions.txt relative to ${BASH_SOURCE[0]}).
if [ -f "$SRC/arrow/cpp/thirdparty/download_dependencies.sh" ]; then
  apt-get install -y -qq wget
  mkdir -p /deps/arrow
  TP="$SRC/arrow/cpp/thirdparty"
  set +e
  sed 's/exit 1)/true)/' "$TP/download_dependencies.sh" > "$TP/dl_tolerant.sh"
  bash "$TP/dl_tolerant.sh" /deps/arrow > /deps/arrow_env.sh 2>/deps/arrow_err.txt
  set -e
  # keep only exports whose tarball actually downloaded
  awk '/^export /{split($2,a,"="); if (system("test -f " a[2])==0) print}' \
      /deps/arrow_env.sh > /deps/arrow_env_ok.sh
  echo "arrow prefetched deps: $(wc -l < /deps/arrow_env_ok.sh)"
fi

# --- prefetch git deps used for corpus generation ---
# arrow's build clones pandas to build a parquet seed corpus; mirror it so the
# agent phase resolves the clone locally.
mkdir -p /deps/git/github.com/pandas-dev
if [ ! -d /deps/git/github.com/pandas-dev/pandas ]; then
  git clone --mirror https://github.com/pandas-dev/pandas.git /deps/git/github.com/pandas-dev/pandas \
    || echo "WARN: could not mirror pandas"
fi
[ -d /deps/git/github.com/pandas-dev/pandas ] && \
  ln -sfn /deps/git/github.com/pandas-dev/pandas /deps/git/github.com/pandas-dev/pandas.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
