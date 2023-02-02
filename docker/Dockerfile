# syntax=docker/dockerfile:1

## base image and arg
FROM --platform=$TARGETPLATFORM debian:11@sha256:534da5794e770279c889daa891f46f5a530b0c5de8bfbc5e40394a0164d9fa87
ARG TARGETARCH

## common java options
ENV JAVA_TOOL_OPTIONS -XX:-UsePerfData
#-Djdk.disableLastUsageTracking

## install packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -o Dpkg::Use-Pty=0 openjdk-11-jre-headless tini

## cleanup
RUN rm /var/cache/debconf/*-old
RUN rm /var/cache/ldconfig/aux-cache
RUN rm -r /var/lib/apt/lists/*
RUN rm /var/lib/dpkg/*-old
RUN rm /var/log/apt/term.log
#RUN rmdir /tmp/hsperfdata_root

## add UniFi Network Controller
COPY UniFi /opt/unifi
WORKDIR /opt/unifi

## remove unused native libraries
RUN ["/bin/bash", "-O", "extglob", "-c", "case $TARGETARCH in amd64) ARCH=x86_64;; arm) ARCH=armv7;; arm64) ARCH=aarch64;; *) echo Unsupported architecture: $TARGETARCH; exit 1;; esac; cd lib/native/Linux; rm -r !(${ARCH})"]

## entrypoint
COPY entrypoint.sh /
RUN mkdir /entrypoint.d
ENTRYPOINT ["/entrypoint.sh"]

## expose ports (https://help.ui.com/hc/en-us/articles/218506997)
# unifi.http.port
EXPOSE 8080/tcp
# unifi.https.port
EXPOSE 8443/tcp
# portal.http.port
EXPOSE 8880/tcp
# portal.https.port
EXPOSE 8843/tcp
# unifi.throughput.port
EXPOSE 6789/tcp
# SSDP for controller
EXPOSE 1900/udp
# unifi.stun.port
EXPOSE 3478/udp
# remote syslog capture
EXPOSE 5514/udp
# AP-EDU broadcasting
EXPOSE 5656-5699/udp
# device discovery
EXPOSE 10001/udp
