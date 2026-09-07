#!/usr/bin/bash
set -euo pipefail

# Packages needed by the final initramfs generation step.
dnf5 install -y \
    --setopt=install_weak_deps=False \
    linux-firmware \
    dracut

dnf5 -y copr enable bieszczaders/kernel-cachyos

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

# Let this transaction install the kernel files without starting kernel-install
# or dracut inside the intermediate container layer.
for hook in "${HOOKS[@]}"; do
    if [[ -e "$HOOK_DIR/$hook" ]]; then
        mv "$HOOK_DIR/$hook" "$HOOK_DIR/$hook.disabled"
        printf '%s\n' '#!/bin/sh' 'exit 0' > "$HOOK_DIR/$hook"
        chmod 0755 "$HOOK_DIR/$hook"
    fi
done

# Remove the Fedora kernel before installing CachyOS. The explicit cleanup is
# required because the disabled kernel hooks can leave an old module directory.
dnf5 remove -y \
    kernel \
    kernel-core \
    kernel-devel \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    || true

rm -rf /usr/lib/modules/*

dnf5 install -y \
    --setopt=install_weak_deps=False \
    kernel-cachyos \
    kernel-cachyos-devel
