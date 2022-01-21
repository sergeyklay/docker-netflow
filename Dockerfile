FROM debian:bullseye-slim AS builder

ARG NFDUMP_VERSION=1.6.23
ARG NFSEN_VERSION=1.3.8
ARG TIMEZONE=UTC
ARG VERSION=1.0.0
ARG BUILD_ID=0000000

ENV DEBIANFRONTEND=noninteractive
ENV NFDUMP_VERSION=${NFDUMP_VERSION}
ENV NFSEN_VERSION=${NFSEN_VERSION}
ENV TIMEZONE=${TIMEZONE}
ENV VERSION=${VERSION}
ENV BUILD_ID=${BUILD_ID}

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update -qq \
    && apt-get install --no-install-recommends --no-install-suggests -y \
       autoconf \
       autogen \
       automake \
       bison \
       build-essential \
       ca-certificates \
       flex \
       libbz2-dev \
       librrd-dev \
       libtool \
       m4 \
       pkg-config \
       wget

WORKDIR /artifacts

# Bellow are nfdump configure options:
#
# --prefix           - Install files in PREFIX/bin, PREFIX/lib, etc.
# --enable-nfprofile - Build nfprofile used by NfSen.
# --enable-nftrack   - Build nftrack used by PortTracker.
# --enable-sflow     - Build sflow collector sfcpad.
#
RUN wget -O nfdump.tar.gz https://github.com/phaag/nfdump/archive/refs/tags/v${NFDUMP_VERSION}.tar.gz \
    && tar -xzf nfdump.tar.gz \
    && cd nfdump-${NFDUMP_VERSION} \
    && bash autogen.sh \
    && mkdir -p /artifacts/nfdump \
    && ./configure \
       --prefix=/artifacts/nfdump \
       --enable-nfprofile \
       --enable-nftrack \
       --enable-sflow \
    && make \
    && make install

ADD nfsen.conf /artifacts/nfsen.conf
ADD entrypoint.sh /artifacts/entrypoint.sh
ADD healthcheck.sh /artifacts/healthcheck.sh

WORKDIR /artifacts
RUN wget -O nfsen.tar.gz http://sourceforge.net/projects/nfsen/files/stable/nfsen-${NFSEN_VERSION}/nfsen-${NFSEN_VERSION}.tar.gz \
    && tar -xzf nfsen.tar.gz \
    && mv nfsen-${NFSEN_VERSION} nfsen \
    && sed -i -re "s|rrd_version < 1.6|rrd_version < 1.8|g" nfsen/libexec/NfSenRRD.pm \
    && mv /artifacts/nfsen.conf /artifacts/nfsen/etc/nfsen.conf

FROM debian:bullseye-slim

ARG TIMEZONE=UTC
ARG VERSION=1.0.0
ARG BUILD_ID=0000000

LABEL org.opencontainers.image.authors="Serghei Iakovlev <egrep@protonmail.ch>" \
      org.opencontainers.image.description="Slimmed-down Netflow collector and local processing Docker image" \
      org.opencontainers.image.source="https://github.com/sergeyklay/docker-netflow" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$BUILD_ID

# Copy artifacts
COPY --from=builder /artifacts/nfdump/ /usr/local
COPY --from=builder /artifacts/nfsen /build/nfsen

# start script
COPY --from=builder /artifacts/entrypoint.sh /entrypoint.sh

# healthcheck script
COPY --from=builder /artifacts/healthcheck.sh /healthcheck.sh

HEALTHCHECK --interval=1m --timeout=5s CMD /healthcheck.sh

RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "$TIMEZONE" > /etc/timezone \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update -qq \
    && apt-get install --no-install-recommends --no-install-suggests -y \
       libmailtools-perl \
       librrds-perl \
       libsocket6-perl \
       lighttpd \
       php-cgi \
    && lighttpd-enable-mod fastcgi-php \
    && sed -i -re 's|^server.document-root[ ]+=.*|server.document-root = "/var/www/nfsen"|g' /etc/lighttpd/lighttpd.conf \
    && sed -i -re 's|^server.errorlog[ ]+=.*|server.errorlog = "/dev/stdout"|g' /etc/lighttpd/lighttpd.conf \
    && sed -i -re 's|^index-file.names[ ]+=.*|index-file.names = ( "nfsen.php" )|g' /etc/lighttpd/lighttpd.conf \
    && sed -i -re 's|^server.pid-file[ ]+=.*|server.pid-file = "/run/lighttpd/lighttpd.pid"|g' /etc/lighttpd/lighttpd.conf \
    && sed -i -re 's|"socket"[ ]+=>.*|"socket" => "/run/lighttpd/php.socket",|g' /etc/lighttpd/conf-enabled/15-fastcgi-php.conf \
    && mkdir -p /var/www /opt/nfsen /build/nfsen \
    && cd /build/nfsen \
    && ldconfig \
    && echo | ./install.pl ./etc/nfsen.conf || true \
    && chmod +x /entrypoint.sh \
    && rm -rf /var/www/html \
    && rm -f /etc/lighttpd/conf-enabled/99-unconfigured.conf \
    && rm -rf /build \
    && apt-get autoremove -y >/dev/null 2>&1 || true \
    && apt-get clean -y >/dev/null 2>&1 || true \
    && apt-get autoclean -y >/dev/null 2>&1 || true \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete \
    && find /var/log -type f | while read -r f; do echo -ne '' > "${f}" >/dev/null 2>&1 || true; done

# HTTP server
EXPOSE 80

# NetFlow
EXPOSE 2055/udp

# IPFIX
EXPOSE 4739/udp

# sFlow
EXPOSE 6343/udp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf", "2>&1"]
