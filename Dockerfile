FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    xrdp \
    xorgxrdp \
    openbox \
    dbus-x11 \
    dbus \
    sudo \
    supervisor \
    xterm \
    x11-xserver-utils \
    nano \
    psmisc \
    xauth \
    wmctrl \
    git \
    wget \
    build-essential \
    qtbase5-dev \
    qtwebengine5-dev \
    libqt5sql5-sqlite \
    libqt5svg5-dev \
    libqt5websockets5-dev \
    qt5-qmake \
    qtchooser \
    libssl-dev \
    libgcrypt20-dev \
    zlib1g-dev \
    cmake \
    pkg-config \
    python3-xdg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crea directory di lavoro
WORKDIR /opt

# Clona il repository di Dooble
RUN git clone --depth 1 --branch 2025.04.27 https://github.com/textbrowser/dooble.git

# Passa alla directory di Dooble
WORKDIR /opt/dooble

# Compila Dooble
RUN qmake -qt=qt5 && \
    make -j$(nproc)

WORKDIR /

# Configure xrdp
RUN sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/xserverbpp=24/xserverbpp=24/g' /etc/xrdp/xrdp.ini && \
    mkdir -p /var/run/xrdp && \
    chmod 2775 /var/run/xrdp && \
    mkdir -p /var/run/xrdp/sockdir && \
    chmod 3777 /var/run/xrdp/sockdir

# Setup dbus service
RUN mkdir -p /var/run/dbus && \
    chown -R messagebus:messagebus /var/run/dbus && \
    mkdir -p /run/dbus && \
    chown -R messagebus:messagebus /run/dbus

# Setup default Openbox config
RUN mkdir -p /etc/skel/.config/openbox
COPY --chown=root:root scripts/autostart /etc/skel/.config/openbox/

# Setup supervisor for service management
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup user management script
COPY scripts/create-user.sh /usr/local/bin/create-user.sh
RUN chmod +x /usr/local/bin/create-user.sh

# Setup xrdp session startup
COPY scripts/xrdp-session.sh /etc/xrdp/startwm.sh
RUN chmod +x /etc/xrdp/startwm.sh

# Setup the container entrypoint
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ARG HOME_PAGE

RUN touch /tmp/HOMEPAGE && echo $HOME_PAGE >> /tmp/HOMEPAGE

# Expose port for RDP
EXPOSE 3389

ENTRYPOINT ["/entrypoint.sh"]