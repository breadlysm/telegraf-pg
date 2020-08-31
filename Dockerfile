FROM buildpack-deps:buster-curl

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends iputils-ping snmp procps lm-sensors && \
    rm -rf /var/lib/apt/lists/*

RUN set -ex && \
    for key in \
        05CE15085FC09D18E99EFB22684A14CF2582E0C5 ; \
    do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
        gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
    done

ENV TELEGRAF_VERSION 1.13.0
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" && \
    case "${dpkgArch##*-}" in \
      amd64) ARCH='amd64';; \
      arm64) ARCH='arm64';; \
      armhf) ARCH='armhf';; \
      armel) ARCH='armel';; \
      *)     echo "Unsupported architecture: ${dpkgArch}"; exit 1;; \
    esac && \
# https://telegrafreleases.blob.core.windows.net/linux/telegraf_1.13.0~with~pg-1_amd64.deb
    wget --no-verbose https://telegrafreleases.blob.core.windows.net/linux/telegraf_1.13.0~with~pg-1_amd64.deb && \
    dpkg -i telegraf_1.13.0~with~pg-1_amd64.deb && \
    rm -f telegraf_1.13.0~with~pg-1_amd64.deb*

EXPOSE 8125/udp 8092/udp 8094


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["telegraf"]