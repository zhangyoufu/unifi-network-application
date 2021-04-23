## base image
FROM ubuntu:latest@sha256:3c9c713e0979e9bd6061ed52ac1e9e1f246c9495aa063619d9d695fb8039aa1f

## common java options
ENV JAVA_TOOL_OPTIONS -XX:-UsePerfData
#-Djdk.disableLastUsageTracking

## install packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -o Dpkg::Use-Pty=0 openjdk-8-jre-headless tini

## cleanup
RUN rm /var/cache/debconf/*-old
RUN rm /var/cache/ldconfig/aux-cache
RUN rm -r /var/lib/apt/lists/*
RUN rm /var/lib/dpkg/*-old
RUN rm /var/log/apt/term.log
#RUN rmdir /tmp/hsperfdata_root

## add UniFi Network Controller
COPY UniFi /opt/unifi

## entrypoint
COPY entrypoint.sh /
RUN mkdir /entrypoint.d
ENTRYPOINT ["/entrypoint.sh"]

## runtime
WORKDIR /opt/unifi

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
