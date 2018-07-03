FROM alpine:3.7 as builder

RUN apk update && apk add git
RUN git clone https://github.com/bitcoin/bitcoin.git
WORKDIR /bitcoin
RUN git checkout v0.16.1

RUN apk update && apk add \
  autoconf \
  automake \
  boost-dev \
  g++ \
  libevent-dev \
  libtool \
  make \
  openssl-dev
RUN ./autogen.sh
RUN ./configure --disable-wallet --without-gui
RUN make

FROM alpine:3.7

RUN apk update && apk add \
  boost \
  boost-program_options \
  libevent \
  openssl

RUN addgroup -S bitcoin \
  && adduser -G bitcoin -S -D -H bitcoin
COPY --from=builder --chown=bitcoin:bitcoin \
  /bitcoin/src/bitcoind \
  /usr/local/bin/

RUN mkdir /var/lib/bitcoind \
  && chown bitcoin:bitcoin /var/lib/bitcoind
VOLUME ["/var/lib/bitcoind"]

EXPOSE 8333

USER bitcoin
ENTRYPOINT ["bitcoind", "-printtoconsole", "-datadir=/var/lib/bitcoind"]
