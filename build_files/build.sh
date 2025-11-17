#!/bin/bash

set -ouex pipefail

### Install packages
# this activate some repo, first the free and non-free rpmfusion, 
# RPM FUSION
sudo dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# FLATHUB
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# this installs a package from fedora repos
PACKAGES=(
  fastfetch
  steam
  discord
  kitty
)
RM_PACKAGES=(
  foot
)
dnf remove -y "${RM_PACKAGES[@]}"
dnf install --setopt=install_weak_deps=False -y "${PACKAGES[@]}"
# Clean dnf cache and autoremove
dnf clean all
rm -rf /var/cache/dnf
dnf autoremove -y
rm -rf /tmp/* /var/tmp/*

# Use a COPR Example:
#
#dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
#dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
