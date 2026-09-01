#!/usr/bin/env bash
# Nothing to do!

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/Jakuje/jcardsim)
( git clone --mirror https://github.com/Jakuje/jcardsim.git /deps/git/github.com/Jakuje/jcardsim 2>/dev/null || git clone --mirror https://github.com/Jakuje/jcardsim /deps/git/github.com/Jakuje/jcardsim ) || echo 'WARN: could not mirror https://github.com/Jakuje/jcardsim'
[ -d /deps/git/github.com/Jakuje/jcardsim ] && ln -sfn /deps/git/github.com/Jakuje/jcardsim /deps/git/github.com/Jakuje/jcardsim.git || true
mkdir -p $(dirname /deps/git/github.com/Jakuje/virt_cacard)
( git clone --mirror https://github.com/Jakuje/virt_cacard.git /deps/git/github.com/Jakuje/virt_cacard 2>/dev/null || git clone --mirror https://github.com/Jakuje/virt_cacard /deps/git/github.com/Jakuje/virt_cacard ) || echo 'WARN: could not mirror https://github.com/Jakuje/virt_cacard'
[ -d /deps/git/github.com/Jakuje/virt_cacard ] && ln -sfn /deps/git/github.com/Jakuje/virt_cacard /deps/git/github.com/Jakuje/virt_cacard.git || true
mkdir -p $(dirname /deps/git/github.com/Yubico/ykneo-openpgp)
( git clone --mirror https://github.com/Yubico/ykneo-openpgp.git /deps/git/github.com/Yubico/ykneo-openpgp 2>/dev/null || git clone --mirror https://github.com/Yubico/ykneo-openpgp /deps/git/github.com/Yubico/ykneo-openpgp ) || echo 'WARN: could not mirror https://github.com/Yubico/ykneo-openpgp'
[ -d /deps/git/github.com/Yubico/ykneo-openpgp ] && ln -sfn /deps/git/github.com/Yubico/ykneo-openpgp /deps/git/github.com/Yubico/ykneo-openpgp.git || true
mkdir -p $(dirname /deps/git/github.com/Yubico/yubico-piv-tool)
( git clone --mirror https://github.com/Yubico/yubico-piv-tool.git /deps/git/github.com/Yubico/yubico-piv-tool 2>/dev/null || git clone --mirror https://github.com/Yubico/yubico-piv-tool /deps/git/github.com/Yubico/yubico-piv-tool ) || echo 'WARN: could not mirror https://github.com/Yubico/yubico-piv-tool'
[ -d /deps/git/github.com/Yubico/yubico-piv-tool ] && ln -sfn /deps/git/github.com/Yubico/yubico-piv-tool /deps/git/github.com/Yubico/yubico-piv-tool.git || true
mkdir -p $(dirname /deps/git/github.com/arekinath/PivApplet)
( git clone --mirror https://github.com/arekinath/PivApplet.git /deps/git/github.com/arekinath/PivApplet 2>/dev/null || git clone --mirror https://github.com/arekinath/PivApplet /deps/git/github.com/arekinath/PivApplet ) || echo 'WARN: could not mirror https://github.com/arekinath/PivApplet'
[ -d /deps/git/github.com/arekinath/PivApplet ] && ln -sfn /deps/git/github.com/arekinath/PivApplet /deps/git/github.com/arekinath/PivApplet.git || true
mkdir -p $(dirname /deps/git/github.com/frankmorgner/OpenSCToken)
( git clone --mirror https://github.com/frankmorgner/OpenSCToken.git /deps/git/github.com/frankmorgner/OpenSCToken 2>/dev/null || git clone --mirror https://github.com/frankmorgner/OpenSCToken /deps/git/github.com/frankmorgner/OpenSCToken ) || echo 'WARN: could not mirror https://github.com/frankmorgner/OpenSCToken'
[ -d /deps/git/github.com/frankmorgner/OpenSCToken ] && ln -sfn /deps/git/github.com/frankmorgner/OpenSCToken /deps/git/github.com/frankmorgner/OpenSCToken.git || true
mkdir -p $(dirname /deps/git/github.com/frankmorgner/openpace)
( git clone --mirror https://github.com/frankmorgner/openpace.git /deps/git/github.com/frankmorgner/openpace 2>/dev/null || git clone --mirror https://github.com/frankmorgner/openpace /deps/git/github.com/frankmorgner/openpace ) || echo 'WARN: could not mirror https://github.com/frankmorgner/openpace'
[ -d /deps/git/github.com/frankmorgner/openpace ] && ln -sfn /deps/git/github.com/frankmorgner/openpace /deps/git/github.com/frankmorgner/openpace.git || true
mkdir -p $(dirname /deps/git/github.com/frankmorgner/vsmartcard)
( git clone --mirror https://github.com/frankmorgner/vsmartcard.git /deps/git/github.com/frankmorgner/vsmartcard 2>/dev/null || git clone --mirror https://github.com/frankmorgner/vsmartcard /deps/git/github.com/frankmorgner/vsmartcard ) || echo 'WARN: could not mirror https://github.com/frankmorgner/vsmartcard'
[ -d /deps/git/github.com/frankmorgner/vsmartcard ] && ln -sfn /deps/git/github.com/frankmorgner/vsmartcard /deps/git/github.com/frankmorgner/vsmartcard.git || true
mkdir -p $(dirname /deps/git/github.com/latchset/kryoptic)
( git clone --mirror https://github.com/latchset/kryoptic.git /deps/git/github.com/latchset/kryoptic 2>/dev/null || git clone --mirror https://github.com/latchset/kryoptic /deps/git/github.com/latchset/kryoptic ) || echo 'WARN: could not mirror https://github.com/latchset/kryoptic'
[ -d /deps/git/github.com/latchset/kryoptic ] && ln -sfn /deps/git/github.com/latchset/kryoptic /deps/git/github.com/latchset/kryoptic.git || true
mkdir -p $(dirname /deps/git/github.com/martinpaljak/oracle_javacard_sdks)
( git clone --mirror https://github.com/martinpaljak/oracle_javacard_sdks.git /deps/git/github.com/martinpaljak/oracle_javacard_sdks 2>/dev/null || git clone --mirror https://github.com/martinpaljak/oracle_javacard_sdks /deps/git/github.com/martinpaljak/oracle_javacard_sdks ) || echo 'WARN: could not mirror https://github.com/martinpaljak/oracle_javacard_sdks'
[ -d /deps/git/github.com/martinpaljak/oracle_javacard_sdks ] && ln -sfn /deps/git/github.com/martinpaljak/oracle_javacard_sdks /deps/git/github.com/martinpaljak/oracle_javacard_sdks.git || true
mkdir -p $(dirname /deps/git/github.com/philipWendland/IsoApplet)
( git clone --mirror https://github.com/philipWendland/IsoApplet.git /deps/git/github.com/philipWendland/IsoApplet 2>/dev/null || git clone --mirror https://github.com/philipWendland/IsoApplet /deps/git/github.com/philipWendland/IsoApplet ) || echo 'WARN: could not mirror https://github.com/philipWendland/IsoApplet'
[ -d /deps/git/github.com/philipWendland/IsoApplet ] && ln -sfn /deps/git/github.com/philipWendland/IsoApplet /deps/git/github.com/philipWendland/IsoApplet.git || true
mkdir -p $(dirname /deps/git/github.com/popovec/oseid)
( git clone --mirror https://github.com/popovec/oseid.git /deps/git/github.com/popovec/oseid 2>/dev/null || git clone --mirror https://github.com/popovec/oseid /deps/git/github.com/popovec/oseid ) || echo 'WARN: could not mirror https://github.com/popovec/oseid'
[ -d /deps/git/github.com/popovec/oseid ] && ln -sfn /deps/git/github.com/popovec/oseid /deps/git/github.com/popovec/oseid.git || true
mkdir -p $(dirname /deps/git/github.com/vletoux/GidsApplet)
( git clone --mirror https://github.com/vletoux/GidsApplet.git /deps/git/github.com/vletoux/GidsApplet 2>/dev/null || git clone --mirror https://github.com/vletoux/GidsApplet /deps/git/github.com/vletoux/GidsApplet ) || echo 'WARN: could not mirror https://github.com/vletoux/GidsApplet'
[ -d /deps/git/github.com/vletoux/GidsApplet ] && ln -sfn /deps/git/github.com/vletoux/GidsApplet /deps/git/github.com/vletoux/GidsApplet.git || true
mkdir -p $(dirname /deps/git/github.com/x41sec/x41-smartcard-fuzzing)
( git clone --mirror https://github.com/x41sec/x41-smartcard-fuzzing.git /deps/git/github.com/x41sec/x41-smartcard-fuzzing 2>/dev/null || git clone --mirror https://github.com/x41sec/x41-smartcard-fuzzing /deps/git/github.com/x41sec/x41-smartcard-fuzzing ) || echo 'WARN: could not mirror https://github.com/x41sec/x41-smartcard-fuzzing'
[ -d /deps/git/github.com/x41sec/x41-smartcard-fuzzing ] && ln -sfn /deps/git/github.com/x41sec/x41-smartcard-fuzzing /deps/git/github.com/x41sec/x41-smartcard-fuzzing.git || true
mkdir -p $(dirname /deps/git/gitlab.freedesktop.org/spice/libcacard)
( git clone --mirror https://gitlab.freedesktop.org/spice/libcacard.git /deps/git/gitlab.freedesktop.org/spice/libcacard 2>/dev/null || git clone --mirror https://gitlab.freedesktop.org/spice/libcacard /deps/git/gitlab.freedesktop.org/spice/libcacard ) || echo 'WARN: could not mirror https://gitlab.freedesktop.org/spice/libcacard'
[ -d /deps/git/gitlab.freedesktop.org/spice/libcacard ] && ln -sfn /deps/git/gitlab.freedesktop.org/spice/libcacard /deps/git/gitlab.freedesktop.org/spice/libcacard.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
git config --global --replace-all url."file:///deps/git/gitlab.freedesktop.org/".insteadOf "https://gitlab.freedesktop.org/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
