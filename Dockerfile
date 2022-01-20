FROM debian:bullseye-slim AS builder

ARG NFDUMP_VERSION=1.6.23
ARG NFSEN_VERSION=1.3.8
ARG TIMEZONE=Europe/Kiev

ENV DEBIANFRONTEND=noninteractive
ENV NFDUMP_VERSION=${NFDUMP_VERSION}
ENV NFSEN_VERSION=${NFSEN_VERSION}
ENV TIMEZONE=${TIMEZONE}

RUN DEBIANFRONTEND=noninteractive apt-get update -qq \
    && DEBIANFRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
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
RUN wget -O nfdump.tar.gz https://github.com/phaag/nfdump/archive/refs/tags/v${NFDUMP_VERSION}.tar.gz \
    && tar -xzf nfdump.tar.gz \
    && cd nfdump-${NFDUMP_VERSION} \
    && bash autogen.sh \
    && mkdir -p /artifacts/nfdump \
    && ./configure --prefix=/artifacts/nfdump --enable-nfprofile --enable-sflow \
    && make \
    && make install

ADD nfsen.conf /artifacts/nfsen.conf

WORKDIR /artifacts
RUN wget -O nfsen.tar.gz http://sourceforge.net/projects/nfsen/files/stable/nfsen-${NFSEN_VERSION}/nfsen-${NFSEN_VERSION}.tar.gz \
    && tar -xzf nfsen.tar.gz \
    && mv nfsen-${NFSEN_VERSION} nfsen \
    && mv /artifacts/nfsen.conf /artifacts/nfsen/etc/nfsen.conf

FROM debian:bullseye-slim

ARG TIMEZONE=Europe/Kiev

LABEL org.opencontainers.image.authors="Serghei Iakovlev <egrep@protonmail.ch>"

RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "$TIMEZONE" > /etc/timezone \
    && DEBIANFRONTEND=noninteractive apt-get update -qq \
    && DEBIANFRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
       lighttpd \
       php-cgi \
    && lighttpd-enable-mod fastcgi-php \
    && mkdir -p /var/www /data /build

# Copy artifacts
COPY --from=builder /artifacts/nfdump/ /usr/local
COPY --from=builder /artifacts/nfsen /build
