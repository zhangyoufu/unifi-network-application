# syntax=docker/dockerfile:1

################################################################################

FROM --platform=${BUILDPLATFORM} alpine:latest AS prepare
ARG URL
ARG MD5
ARG SHA256

## install dependencies
RUN apk --no-cache add coreutils unzip wget

## download and verify checksum
RUN wget --quiet --show-progress --progress=dot:giga --output-document UniFi.unix.zip "${URL}"
RUN if [ -n "${MD5}" ]; then echo "${MD5}  UniFi.unix.zip" | md5sum --status --check; fi
RUN if [ -n "${SHA256}" ]; then echo "${SHA256}  UniFi.unix.zip" | sha256sum --status --check; fi

## unzip
RUN unzip -q UniFi.unix.zip
WORKDIR UniFi

## remove unwanted files
RUN rm readme.txt
RUN rm bin/mongod
RUN rmdir bin

## remove unused native libraries
RUN rm -rf lib/native/Windows
RUN rm -rf lib/native/Mac
RUN rm lib/native/Linux/*/libubnt_sdnotify_jni.so

## create directory structure that would be used at runtime
RUN mkdir data
RUN mkdir logs
RUN mkdir -p run/work/ROOT
RUN mkdir -p work/Tomcat/localhost/ROOT

################################################################################

FROM --platform=${TARGETPLATFORM} debian:12@sha256:eaace54a93d7b69c7c52bb8ddf9b3fcba0c106a497bc1fdbb89a6299cf945c63
ARG TARGETARCH

## common java options
ENV JAVA_TOOL_OPTIONS -XX:-UsePerfData
#-Djdk.disableLastUsageTracking

## install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -o Dpkg::Use-Pty=0 openjdk-17-jre-headless tini

## cleanup
RUN rm /var/cache/debconf/*-old
RUN rm /var/cache/ldconfig/aux-cache
RUN rm -r /var/lib/apt/lists/*
RUN rm /var/lib/dpkg/*-old
RUN rm /var/log/apt/term.log
#RUN rmdir /tmp/hsperfdata_root

## add UniFi Network Controller
COPY --from=prepare UniFi /opt/unifi
WORKDIR /opt/unifi

## remove unused native libraries
RUN ["/bin/bash", "-O", "extglob", "-c", "case ${TARGETARCH} in amd64) ARCH=x86_64;; arm) ARCH=armv7;; arm64) ARCH=aarch64;; *) echo Unsupported architecture: ${TARGETARCH}; exit 1;; esac; cd lib/native/Linux; rm -r !(${ARCH})"]

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
