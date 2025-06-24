FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    uidmap \
    podman \
    fuse-overlayfs \
    slirp4netns \
    sudo \
    dbus-user-session \
    ca-certificates \
    iproute2 \
    iputils-ping \
    gnupg2 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m rootless && \
    echo "rootless:100000:65536" >> /etc/subuid && \
    echo "rootless:100000:65536" >> /etc/subgid && \
    echo "rootless ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN chmod u+s /usr/bin/newuidmap /usr/bin/newgidmap

USER rootless
WORKDIR /home/rootless

# Verzeichnisse für rootless Storage
ENV TMPDIR=/tmp
ENV XDG_RUNTIME_DIR=/tmp/xdg
ENV _CONTAINERS_USERNS_CONFIGURED=1

RUN mkdir -p /tmp/storage /tmp/storage/tmp /tmp/xdg /home/rootless/.config/containers

# Konfiguration schreiben, um ~/.local/share/... zu verhindern
RUN echo '[storage]\n'\
'driver = "overlay"\n'\
'runroot = "/tmp/storage/runroot"\n'\
'graphroot = "/tmp/storage/graphroot"\n'\
'[storage.options]\n'\
'mount_program = "/usr/bin/fuse-overlayfs"\n' > /home/rootless/.config/containers/storage.conf

EXPOSE 2375

CMD ["podman", "system", "service", "--time=0", "tcp:0.0.0.0:2375"]
