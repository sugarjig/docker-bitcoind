FROM ubuntu:xenial

RUN apt-get update \
    && apt-get install -y software-properties-common=0.96.20.7 \
    && rm -rf /var/lib/apt/lists/*
RUN add-apt-repository ppa:bitcoin/bitcoin \
    && apt-get update \
    && apt-get install -y bitcoind=0.15.0-xenial9 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r bitcoin && useradd --no-log-init -r -g bitcoin bitcoin
RUN mkdir /var/lib/bitcoind && chown bitcoin:bitcoin /var/lib/bitcoind

EXPOSE 8333
VOLUME ["/var/lib/bitcoind"]

USER bitcoin
CMD ["bitcoind", "-printtoconsole", "-disablewallet", "-txindex", "-datadir=/var/lib/bitcoind"]
