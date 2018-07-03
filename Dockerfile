FROM gcc:8.1.0 as builder

RUN git clone https://github.com/bitcoin/bitcoin.git
WORKDIR /bitcoin
RUN git checkout v0.16.1

RUN apt-get update
RUN apt-get install -y \
    bsdmainutils \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev

RUN ./autogen.sh \
    && ./configure --disable-wallet --without-gui \
    && make

FROM alpine:3.7

RUN apk update
RUN apk add libevent
RUN addgroup -S bitcoin
RUN adduser -G bitcoin -S -D -H bitcoin
COPY --from=builder --chown=bitcoin:bitcoin \
    /bitcoin/src/bitcoin-cli \
    /bitcoin/src/bitcoin-tx \
    /bitcoin/src/bitcoind \
    /usr/local/bin/

RUN mkdir /var/lib/bitcoind && chown bitcoin:bitcoin /var/lib/bitcoind
VOLUME ["/var/lib/bitcoind"]

EXPOSE 8333

USER bitcoin
#CMD ["bitcoind", "-printtoconsole", "-disablewallet", "-txindex", "-datadir=/var/lib/bitcoind"]
