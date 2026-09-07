# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS build-script
COPY build_files/build.sh /build.sh

FROM scratch AS systemd-script
COPY build_files/systemd-service.sh /systemd-service.sh

FROM scratch AS ccachy-script
COPY build_files/copr-cachy.sh /copr-cachy.sh

FROM scratch AS finalize-script
COPY build_files/finalize.sh /finalize.sh

FROM scratch AS install-kernel
COPY build_files/install-kernel.sh /install-kernel.sh

# Base Image
FROM quay.io/fedora/fedora-sway-atomic:latest

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:stable
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable

# list of UBlue Images: https://github.com/orgs/ublue-os/packages
# Fedora Sway atomic: quay.io/fedora/fedora-sway-atomic:latest

LABEL org.opencontainers.image.title="custom-sericea" \
      org.opencontainers.image.version="latest" \
      org.opencontainers.image.source="https://github.com/Teilenh/custom-sericea/main" \
      org.opencontainers.image.vendor="no-one" \
      org.opencontainers.image.url="https://github.com/Teilenh/custom-sericea" \
      org.opencontainers.image.description="simple sway atomic for my daily use"

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.
RUN --mount=type=bind,from=build-script,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    HOME=/tmp bash /ctx/build.sh

### REMOVE FEDORA DEFAULT SWAY BINDINGS
RUN rm -f \
    /usr/share/sway/config.d/60-bindings-screenshot.conf \
    /usr/share/sway/config.d/60-bindings-brightness.conf \
    /usr/share/sway/config.d/50-rules-policykit-agent.conf \
    /usr/share/sway/config.d/50-rules-pavucontrol.conf \
    /usr/share/sway/config.d/50-rules-browser.conf

### COPY CONFIG FILES
## Files under rootfs mirror their final absolute paths. Keeping this as a small amount of 
## instruction preserves layers without creating one expensive layer per file.
# Configuration système stable
COPY build_files/rootfs/etc/ /etc/

# Services et scripts relativement stables
COPY --chmod=0755 build_files/rootfs/usr/bin/ /usr/bin/
COPY build_files/rootfs/usr/lib/ /usr/lib/
COPY build_files/rootfs/usr/libexec/ /usr/libexec/

# Apparence, thèmes et fonds d’écran plus changeants
COPY build_files/rootfs/usr/share/ /usr/share/
## change the kernel to cachyOS kernel
RUN --mount=type=bind,from=ccachy-script,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    HOME=/tmp bash /ctx/copr-cachy.sh

## Activate systemd services + cleanup
RUN --mount=type=bind,from=systemd-script,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    HOME=/tmp bash /ctx/systemd-service.sh
    
RUN --mount=type=bind,from=finalize-script,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/finalize.sh

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=bind,from=install-kernel,source=/,target=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/install-kernel.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
