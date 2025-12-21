#!/bin/bash

set -ouex pipefail

### Install packages
# this activate some repo, first the free and non-free rpmfusion, 
# RPM FUSION
sudo dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# FLATHUB
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak update -y
# this installs a package from fedora repos
PACKAGES=(
  fastfetch
  steam
  discord
  kitty
  btop
  gamemode
  mpv
  distrobox
  wlogout
  unzip
  cabextract
)
RM_PACKAGES=(
  foot
)
dnf remove -y "${RM_PACKAGES[@]}"
dnf install --setopt=install_weak_deps=False -y "${PACKAGES[@]}"
# Clean dnf cache and autoremove
dnf clean all
dnf autoremove -y

flatpak -y install flathub md.obsidian.Obsidian com.ranfdev.DistroShelf
# Use a COPR Example:
#
#dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
#dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
