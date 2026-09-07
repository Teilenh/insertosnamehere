#!/usr/bin/bash
set -eoux pipefail

dnf5 install \
    --setopt=install_weak_deps=False \
    --skip-unavailable \
    -y \
    linux-firmware \
    dracut

dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons

HOOK_DIR=/usr/lib/kernel/install.d
HOOKS=(05-rpmostree.install 50-dracut.install)

restore_hooks() {
    for hook in "${HOOKS[@]}"; do
        if [[ -e "$HOOK_DIR/$hook.disabled" ]]; then
            rm -f "$HOOK_DIR/$hook"
            mv -f "$HOOK_DIR/$hook.disabled" "$HOOK_DIR/$hook"
        fi
    done
}

trap restore_hooks EXIT

for hook in "${HOOKS[@]}"; do
    if [[ -e "$HOOK_DIR/$hook" ]]; then
        mv "$HOOK_DIR/$hook" "$HOOK_DIR/$hook.disabled"
        printf '%s\n' '#!/bin/sh' 'exit 0' > "$HOOK_DIR/$hook"
        chmod 0755 "$HOOK_DIR/$hook"
    fi
done

# Retirer le kernel Fedora proprement.
dnf5 remove -y \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-devel \
    || true

# Installer CachyOS.
dnf5 install \
    --setopt=install_weak_deps=False \
    --skip-unavailable \
    -y \
    kernel-cachyos \
    kernel-cachyos-devel

KVER="$(
    find /usr/lib/modules \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%f\n' |
    grep cachyos |
    sort -V |
    tail -n1
)"

test -n "$KVER"
test -d "/usr/lib/modules/$KVER"
test -s "/usr/lib/modules/$KVER/vmlinuz"

depmod -a "$KVER"

INITRAMFS="/usr/lib/modules/$KVER/initramfs.img"

DRACUT_NO_XATTR=1 dracut \
    --force \
    --no-hostonly \
    --reproducible \
    --add ostree --zstd -v --add fido2 \
    --tmpdir=/var/tmp \
    --kver "$KVER" \
    -f "$INITRAMFS"
    
test -s "$INITRAMFS"
lsinitrd "$INITRAMFS" >/dev/null

echo "Kernel:"
ls -lh "/usr/lib/modules/$KVER/vmlinuz"

echo "Initramfs:"
ls -lh "$INITRAMFS"

echo "OSTree bits:"
lsinitrd "$INITRAMFS" |
    grep -Ei 'ostree|prepare-root' |
    head -50 || true
