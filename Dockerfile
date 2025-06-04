FROM       node:22-bullseye-slim

LABEL      author="RelixOfficial" maintainer="dzakyadis9@gmail.com" description="A Docker image for running Node.js applications with PM2 and essential utilities."

# add container user and set stop signal
RUN         useradd -m -d /home/container container
STOPSIGNAL  SIGINT

RUN         apt update \
            && apt -y install \
                ffmpeg \
                iproute2 \
                git \
                sqlite3 \
                libsqlite3-dev \
                python \
                python3 \
                python3-dev \
                python3-pip \
                golang \
                webp \
                docker \
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
                curl \
                build-essential \
                libtool \
                iputils-ping \
                libnss3 \
                tini

# Install sqlmap dari GitHub dan buat executable global
RUN         git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /usr/share/sqlmap \
            && ln -s /usr/share/sqlmap/sqlmap.py /usr/bin/sqlmap \
            && chmod +x /usr/bin/sqlmap /usr/share/sqlmap/sqlmap.py

RUN         npm install --global npm@latest typescript ts-node @types/node
RUN         npm install -g pm2

# install pnpm
RUN         npm install -g corepack
RUN         corepack enable
RUN         corepack prepare pnpm@latest --activate

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
