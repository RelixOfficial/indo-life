FROM       node:22-bullseye-slim

LABEL      author="RelixOfficial" maintainer="dzakyadis9@gmail.com" description="A Docker image for running Node.js applications with PM2 and essential utilities."

# add container user and set stop signal
RUN         useradd -m -d /home/container container
STOPSIGNAL  SIGINT

ARG GO_VERSION=1.22.3
ARG PYTHON_VERSION=3.12.3
ARG PHP_VERSION=8.3.7
ARG PERL_VERSION=5.38.2
ARG JAVA_VERSION=jdk-21.0.3+9
ARG DOTNET_VERSION=8.0.300
ARG RUBY_VERSION=3.3.0
ARG SWIFT_VERSION=5.10
ARG LUA_VERSION=5.4.6

RUN         apt update \
            && apt -y install \
                ffmpeg \
                iproute2 \
                git \
                sqlite3 \
                libsqlite3-dev \
                
                python3 \
                python3-dev \
                python3-pip \
                webp \
                neofetch \
                imagemagick \
                ssh \
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
                tini \
                unzip \
                xz-utils \
                pkg-config \
                libssl-dev \
                zlib1g-dev \
                libreadline-dev \
                libbz2-dev \
                liblzma-dev \
                libncurses-dev \
                libgdbm-dev \
                libffi-dev \
                libmpdec-dev \
                libicu-dev \
                libpq-dev \
                cmake \
                autoconf \
                libxml2-dev \
                
                libyaml-dev \
                libjpeg-dev \
                libpng-dev

# Install bahasa dari sumber resmi (manual install)
# GO
RUN curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:$PATH"

# RUST
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"

# PYTHON
WORKDIR /tmp/python
RUN curl -fsSL https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz -o python.tgz \
 && tar -xzf python.tgz && cd Python-${PYTHON_VERSION} \
 && ./configure --enable-optimizations \
 && make -j$(nproc) && make install

# PHP
WORKDIR /tmp/php
RUN curl -fsSL https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz -o php.tgz \
 && tar -xzf php.tgz && cd php-${PHP_VERSION} \
 && ./configure --disable-cgi --enable-cli --with-openssl --with-zlib \
 && make -j$(nproc) && make install

# PERL
WORKDIR /tmp/perl
RUN curl -fsSL https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz -o perl.tgz \
 && tar -xzf perl.tgz && cd perl-${PERL_VERSION} \
 && ./Configure -des -Dprefix=/usr/local \
 && make -j$(nproc) && make install

# JAVA
WORKDIR /opt
RUN curl -fsSL https://github.com/adoptium/temurin21-binaries/releases/download/${JAVA_VERSION}/OpenJDK21U-jdk_x64_linux_hotspot_21.0.3_9.tar.gz -o java.tgz \
 && tar -xzf java.tgz && mv jdk-* java
ENV JAVA_HOME="/opt/java"
ENV PATH="$JAVA_HOME/bin:$PATH"

# .NET
WORKDIR /tmp/dotnet
RUN curl -fsSL https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -o dotnet-install.sh \
 && chmod +x dotnet-install.sh \
 && ./dotnet-install.sh --version $DOTNET_VERSION --install-dir /usr/share/dotnet
ENV DOTNET_ROOT="/usr/share/dotnet"
ENV PATH="$DOTNET_ROOT:$PATH"

# RUBY
WORKDIR /tmp/ruby
RUN curl -fsSL https://cache.ruby-lang.org/pub/ruby/3.3/ruby-${RUBY_VERSION}.tar.gz -o ruby.tgz \
 && tar -xzf ruby.tgz && cd ruby-${RUBY_VERSION} \
 && ./configure && make -j$(nproc) && make install

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
