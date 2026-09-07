#!/usr/bin/bash
set -euo pipefail

mapfile -t kernel_dirs < <(
    find /usr/lib/modules \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%f\n' |
        grep 'cachyos' |
        sort -V
)

if (( ${#kernel_dirs[@]} != 1 )); then
    printf 'Expected exactly one CachyOS kernel, found %s:\n' "${#kernel_dirs[@]}" >&2
    printf '  %s\n' "${kernel_dirs[@]}" >&2
    exit 1
fi

KVER=${kernel_dirs[0]}
KERNEL_DIR=/usr/lib/modules/$KVER
INITRAMFS=$KERNEL_DIR/initramfs.img

test -s "$KERNEL_DIR/vmlinuz"

depmod -a "$KVER"

# Generate the initramfs only after the complete bootc image has been assembled.
# xattrs cannot reliably be preserved while dracut writes through overlayfs.
DRACUT_NO_XATTR=1 dracut \
    --force \
    --no-hostonly \
    --reproducible \
    --zstd \
    --add ostree \
    --tmpdir=/var/tmp \
    --kver "$KVER" \
    "$INITRAMFS"

chmod 0600 "$INITRAMFS"
test -s "$INITRAMFS"
lsinitrd "$INITRAMFS" >/dev/null
