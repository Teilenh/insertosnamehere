#!/usr/bin/bash

## script for copr of cachy and install
set -euo pipefail

dnf5 install --setopt=install_weak_deps=False --skip-unavailable -y linux-firmware
# Add CachyOS COPR repository
dnf5 -y copr enable bieszczaders/kernel-cachyos
dnf5 -y copr enable bieszczaders/kernel-cachyos-addons


HOOK_DIR=/usr/lib/kernel/install.d
HOOKS=(05-rpmostree.install 50-dracut.install)

restore_hooks() {
    for hook in "${HOOKS[@]}"; do
        if [ -e "$HOOK_DIR/$hook.disabled" ]; then
            mv -f "$HOOK_DIR/$hook.disabled" "$HOOK_DIR/$hook"
        fi
    done
}

trap restore_hooks EXIT

# Désactiver temporairement la génération automatique de l’initramfs
for hook in "${HOOKS[@]}"; do
    if [ -e "$HOOK_DIR/$hook" ]; then
        mv "$HOOK_DIR/$hook" "$HOOK_DIR/$hook.disabled"
        printf '%s\n' '#!/bin/sh' 'exit 0' > "$HOOK_DIR/$hook"
        chmod +x "$HOOK_DIR/$hook"
    fi
done
# Nettoyer les répertoires restants de l’ancien noyau
rm -rf /usr/lib/modules/*

# Installer le noyau CachyOS
dnf5 install \
  --setopt=install_weak_deps=False \
  --skip-unavailable \
  -y kernel-cachyos kernel-cachyos-devel
  
dnf5 remove -y \
  kernel \
  kernel-modules \
  kernel-devel \
  || true
# Générer modules.dep avant de restaurer les hooks
KVER="$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -V | tail -n1)"
depmod -a "$KVER"
echo "Kernel directories:"
find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n'
