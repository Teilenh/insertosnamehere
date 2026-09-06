#!/usr/bin/bash
set -euo pipefail

dnf5 install \
    --setopt=install_weak_deps=False \
    --skip-unavailable \
    -y linux-firmware dracut

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

# Neutralise kernel-install pendant les transactions RPM.
for hook in "${HOOKS[@]}"; do
    if [[ -e "$HOOK_DIR/$hook" ]]; then
        mv "$HOOK_DIR/$hook" "$HOOK_DIR/$hook.disabled"
        printf '%s\n' '#!/bin/sh' 'exit 0' > "$HOOK_DIR/$hook"
        chmod 0755 "$HOOK_DIR/$hook"
    fi
done

# Retirer les anciens modules avant installation du kernel voulu.
rm -rf /usr/lib/modules/*

dnf5 install \
    --setopt=install_weak_deps=False \
    --skip-unavailable \
    -y \
    kernel-cachyos \
    kernel-cachyos-devel

dnf5 remove -y \
    kernel \
    kernel-modules \
    kernel-devel \
    || true

# Trouver exactement le kernel installé.
mapfile -t kernels < <(
    find /usr/lib/modules \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%f\n'
)

if (( ${#kernels[@]} != 1 )); then
    printf 'Expected exactly one kernel, found:\n' >&2
    printf '  %s\n' "${kernels[@]}" >&2
    exit 1
fi

KVER="${kernels[0]}"

echo "CachyOS kernel: $KVER"

test -d "/usr/lib/modules/$KVER" || {
    echo "Missing /usr/lib/modules/$KVER" >&2
    exit 1
}

test -s "/usr/lib/modules/$KVER/vmlinuz" || {
    echo "Missing kernel image /usr/lib/modules/$KVER/vmlinuz" >&2
    exit 1
}

depmod -a "$KVER"

# Génération explicite de l'initramfs.
mkdir -p /usr/lib/modules/"$KVER"

dracut \
    --force \
    --kver "$KVER" \
    "/usr/lib/modules/$KVER/initramfs.img"

test -s "/usr/lib/modules/$KVER/initramfs.img" || {
    echo "initramfs generation failed" >&2
    exit 1
}

# Vérifie que dracut sait au moins lire son propre résultat.
lsinitrd "/usr/lib/modules/$KVER/initramfs.img" >/dev/null

echo "Kernel artifacts:"
ls -lh \
    "/usr/lib/modules/$KVER/vmlinuz" \
    "/usr/lib/modules/$KVER/initramfs.img"