FROM node:22-bullseye-slim

LABEL author="RelixOfficial" maintainer="dzakyadis9@gmail.com" \
      description="A Docker image for running Node.js applications with PM2, essential utilities, and Docker-in-Docker."

# Buat user 'container' dan set stop signal
RUN useradd -m -d /home/container container
STOPSIGNAL SIGINT

# Instalasi dependensi dasar dan persiapan Docker CE
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        ffmpeg \
        iproute2 \
        git \
        sqlite3 \
        libsqlite3-dev \
        python3 \
        python3-dev \
        python3-pip \
        golang \
        webp \
        neofetch \
        imagemagick \
        php \
        sudo \
        wget \
        ca-certificates \
        dnsutils \
        tzdata \
        zip \
        tar \
        build-essential \
        libtool \
        iputils-ping \
        libnss3 \
        tini \
        # HAPUS paket 'docker' bawaan Debian jika sudah terinstall, lalu pasang Docker CE:
        && apt-get remove -y docker docker-engine docker.io containerd runc || true \
        && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
        && echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
            > /etc/apt/sources.list.d/docker.list \
        && apt-get update \
        && apt-get install -y --no-install-recommends \
            docker-ce \
            docker-ce-cli \
            containerd.io \
        # Bersihkan cache apt agar image lebih ringkas
        && rm -rf /var/lib/apt/lists/*

# Install sqlmap dari GitHub dan buat executable global
RUN git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /usr/share/sqlmap \
    && ln -s /usr/share/sqlmap/sqlmap.py /usr/bin/sqlmap \
    && chmod +x /usr/share/sqlmap/sqlmap.py /usr/bin/sqlmap

# Instalasi npm global: npm terbaru, typescript, ts-node, @types/node, pm2
RUN npm install --global npm@latest typescript ts-node @types/node pm2

# Instalasi pnpm via corepack
RUN npm install -g corepack \
    && corepack enable \
    && corepack prepare pnpm@latest --activate

# Tambahkan user 'container' ke grup 'docker' agar bisa jalankan docker tanpa sudo
RUN usermod -aG docker container

# Ubah user ke 'container'
USER container
ENV USER=container \
    HOME=/home/container \
    DOCKER_HOST=unix:///var/run/docker.sock

WORKDIR /home/container

# Salin dan set permission untuk entrypoint.sh
COPY --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ENTRYPOINT:
# 1. Jalankan dockerd di background (Docker daemon).
# 2. Tunggu sebentar hingga dockerd siap (sleep 5s).
# 3. Baru eksekusi skrip /entrypoint.sh Anda.
ENTRYPOINT ["/usr/bin/tini", "--", "sh", "-c", "\
    dockerd > /var/log/docker.log 2>&1 & \
    sleep 5 && \
    exec /entrypoint.sh \
"]

CMD []
