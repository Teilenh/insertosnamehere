# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM quay.io/fedora/fedora-sway-atomic:latest

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:stable
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable

# list of UBlue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:42
# Fedora Sway atomic: quay.io/fedora/fedora-sway-atomic:latest

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### COPY CONFIG FILES
## this copy many files for Sway, Rofi, Swaylock, wlogout, Waybar
COPY --chmod=644 build_files/files/sway/10-variables.conf /usr/share/sway/config.d/10-variables.conf
COPY --chmod=644 build_files/files/sway/15-colors.conf /usr/share/sway/config.d/15-colors.conf
COPY --chmod=644 build_files/files/sway/20-outputs.conf /usr/share/sway/config.d/20-outputs.conf
COPY --chmod=644 build_files/files/sway/30-appearance.conf /usr/share/sway/config.d/30-appearance.conf
COPY --chmod=644 build_files/files/sway/35-rules.conf /usr/share/sway/config.d/35-rules.conf
COPY --chmod=644 build_files/files/sway/40.keybinds.conf /usr/share/sway/config.d/40.keybinds.conf
COPY --chmod=644 build_files/files/sway/96-autostart.conf /usr/share/sway/config.d/96-autostart.conf

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
