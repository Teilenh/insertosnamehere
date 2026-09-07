#!/bin/bash

set -ouex pipefail

###add repo, and after Install packages
# this activate some repo, first the free and non-free rpmfusion, and terra
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf5 install -y \
  --nogpgcheck \
  --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
  terra-release \
  terra-release-mesa
dnf5 config-manager setopt terra-mesa.enabled=false


curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo

#VS-codium 
tee -a /etc/yum.repos.d/vscodium.repo << 'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF

# this list packages to install from fedora repos and LACT
#LACT=$(curl -s https://api.github.com/repos/ilya-zlobintsev/LACT/releases/latest | grep -oP 'https://github\.com/ilya-zlobintsev/LACT/releases/download/[^"]*lact-headless[^"]*fedora-44\.rpm' | head -n 1)

MESA_TERRA_PACKAGES=(
  mesa-filesystem.x86_64
  mesa-filesystem.i686
  mesa-dri-drivers.x86_64
  mesa-dri-drivers.i686
  mesa-libEGL.x86_64
  mesa-libEGL.i686
  mesa-libGL.x86_64
  mesa-libGL.i686
  mesa-libgbm.x86_64
  mesa-libgbm.i686
  mesa-vulkan-drivers.x86_64
  mesa-vulkan-drivers.i686
)
PACKAGES=(
  mpv
  git
  zsh
  nemo
  btop
  gvfs
  lact
  cava
  wget
  nmap
  unrar
  unzip
  kitty
  steam
  socat
  netcat
  iperf3
  pokeget
  cmatrix
  SwayOSD
  discord
  udisks2
  openssl
  cliphist
  wlsunset
  nwg-look
  gvfs-mtp
  gvfs-smb
  fastfetch
  vs-codium
  distrobox
  wlr-randr
  tracroute
  cabextract
  xfce-polkit
  file-roller
  wf-recorder
  vulkan-tools
  wl-clipboard
  nemo-preview
  smartmontools
  wireshark-cli
  systemd-devel
  kernel-headers
  nemo-fileroller
  cloudflare-warp
  pocillo-gtk-theme
  helium-browser-bin
  zsh-autosuggestions
  firamono-nerd-fonts
  firacode-nerd-fonts
  rsms-inter-vf-fonts
  libappindicator-gtk3
  google-noto-sans-fonts
  SwayNotificationCenter
  google-noto-serif-fonts
  impallari-raleway-fonts
  zsh-syntax-highlighting
  sway-audio-idle-inhibit
  jetbrainsmono-nerd-fonts
  folder-color-switcher-nemo
  google-noto-sans-math-fonts 
  google-noto-color-emoji-fonts 
  google-noto-sans-symbols-2-fonts
  SwayNotificationCenter-zsh-completion
)
GAMING_PACKAGES=(
  vkBasalt.x86_64
  vkBasalt.i686
  libFAudio.x86_64
  libFAudio.i686
  lm_sensors
  kernel-tools
  amdsmi
  libinput-utils
  vulkan-low-latency-layer
)
SCHED_EXT=(
  scx-scheds
  scx-tools
)
BUILD_PACKAGES=(
  meson
  ninja
  gcc
  make
  cmake
  gcc-c++
  kernel-devel
  perl
  glib2-devel
  perl-IPC-Cmd
  perl-FindBin
  perl-File-Compare
  perl-File-Copy
  clang
  llvm
)
RM_PACKAGES=(
  foot
  bluez
  cups
  qemu-guest-agent
  virtualbox-guest-additions
  ModemManager
  tuned
  xarchiver
  google-noto-emoji-fonts
  gdouros-symbola-fonts
)
CODECS=(
  gstreamer1-plugins-base
  gstreamer1-plugins-good
  gstreamer1-plugins-bad-free
  gstreamer1-plugins-bad-freeworld
  gstreamer1-plugins-ugly
  gstreamer1-libav
  mozilla-openh264
  lame
)
dnf5 remove -y "${RM_PACKAGES[@]}" "${BUILD_PACKAGES}"
dnf5 install --setopt=install_weak_deps=False --skip-unavailable -y \
  "${PACKAGES[@]}" \
  "${CODECS[@]}" \
  "${GAMING_PACKAGES[@]}" "${SCHED_EXT[@]}"
#  "$LACT"
# commented because no need actually, reduce build time, I uncomment these when I need it
# dnf5 install --setopt=install_weak_deps=False --setopt=tsflags=nodocs -y "${BUILD_PACKAGES[@]}"
dnf5 swap -y \
  --from-repo=terra-mesa \
  mesa-filesystem \
  mesa-filesystem

dnf5 install -y \
  --enable-repo=terra-mesa \
  --setopt=install_weak_deps=False \
  "${MESA_TERRA_PACKAGES[@]}"
  
dnf5 versionlock add \
  mesa-filesystem \
  mesa-dri-drivers \
  mesa-libEGL \
  mesa-libGL \
  mesa-libgbm \
  mesa-vulkan-drivers
  
echo "Mesa packages selected for the image:"
rpm -q \
  --queryformat '%{NAME}.%{ARCH} %{EPOCHNUM}:%{VERSION}-%{RELEASE} | %{VENDOR}\n' \
  "${MESA_TERRA_PACKAGES[@]}"
echo "Mesa versionlocks:"
dnf5 versionlock list
# for a lightweight image
#dnf5 remove -y "${BUILD_PACKAGES[@]}"

# FLATHUB -- but now with a .sh and a service
# flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# flatpak -y install flathub md.obsidian.Obsidian com.ranfdev.DistroShelf io.github.kolunmi.Bazaar
# Use a COPR Example:
# dnf5 copr enable scottames/vicinae bieszczaders/kernel-cachyos-addons
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disabled bieszczaders/kernel-cachyos-addons scottames/vicinae

### ICON THEME ARASHI
git clone --depth=1 https://github.com/0hStormy/Arashi /tmp/Arashi
mkdir -p /usr/share/icons
cp -r /tmp/Arashi /usr/share/icons/Arashi && rm -rf /tmp/Arashi

### CONFIGURE DEFAULT SHELL TO ZSH
#if [ -f /etc/default/useradd ]; then
#    sed -i 's|SHELL=/bin/bash|SHELL=/bin/zsh|g' /etc/default/useradd
#    sed -i 's|SHELL=/usr/bin/bash|SHELL=/bin/zsh|g' /etc/default/useradd
#else
#    mkdir -p /etc/default
#    echo "SHELL=/bin/zsh" > /etc/default/useradd
#fi


