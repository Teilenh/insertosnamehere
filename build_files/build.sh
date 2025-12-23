#!/bin/bash

set -ouex pipefail

### Install packages
# this activate some repo, first the free and non-free rpmfusion, 
# RPM FUSION
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# this installs a package from fedora repos
PACKAGES=(
  fastfetch
  steam
  discord
  lutris
  kitty
  btop
  gamemode
  mpv
  distrobox
  wlogout
  unzip
  cabextract
  thunar-archive-plugin
  tumbler
  gvfs
  gvfs-smb
  gvfs-mtp
  udisks2
  smartmontools
  vulkan-tools
  google-noto-sans-fonts
  google-noto-serif-fonts
  google-noto-emoji-fonts
  impallari-raleway-fonts
  fira-code-fonts
  pocillo-gtk-theme
  nemo
  nemo-extensions
  nemo-preview
  folder-color-switcher-nemo
)
RM_PACKAGES=(
  foot
  bluez
  cups
  ModemManager
  tuned
)
CODECS=(
  gstreamer1-plugins-base
  gstreamer1-plugins-good
  gstreamer1-plugins-bad-free
  gstreamer1-plugins-bad-freeworld
  gstreamer1-plugins-ugly
  gstreamer1-libav
)
dnf5 remove -y "${RM_PACKAGES[@]}"
dnf5 install --setopt=install_weak_deps=False -y "${PACKAGES[@]}"
dnf5 install --setopt=install_weak_deps=False -y "${CODECS[@]}"
# Clean dnf cache and autoremove
dnf5 clean all
dnf5 autoremove -y

# FLATHUB
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak -y install flathub md.obsidian.Obsidian com.ranfdev.DistroShelf io.github.kolunmi.Bazaar
# Use a COPR Example:
#dnf5 copr enable scottames/vicinae
#dnf5 install --skip-unavailable vicinae
# Disable COPRs so they don't end up enabled on the final image:
#dnf5 -y copr disable scottames/vicinae

### ICON THEME: ARASHI
git clone --depth=1 https://github.com/0hStormy/Arashi /tmp/Arashi
mkdir -p /usr/share/icons
cp -r /tmp/Arashi /usr/share/icons/Arashi && rm -rf /tmp/Arashi

#### Example for enabling a System Unit File

systemctl enable podman.socket
