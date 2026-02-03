FROM debian:bookworm-slim

ARG BITCOIN_VERSION=26.1
ARG BITCOIN_SHA256=a5b7d206384a8100058d3f2e2f02123a8e49e83f523499e70e86e121a4897d5b

# Fail early if hash not provided
RUN test -n "$BITCOIN_SHA256"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        gnupg \
        dirmngr \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -r -m bitcoin

WORKDIR /tmp

# Download Bitcoin Core artifacts
RUN wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz && \
    wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS && \
    wget -q https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc

RUN wget -qO guix.sigs.tar.gz https://github.com/bitcoin-core/guix.sigs/archive/refs/heads/main.tar.gz \
 && tar -xzf guix.sigs.tar.gz \
 && gpg --import guix.sigs-main/builder-keys/*.gpg

# Verify signature on SHA256SUMS
RUN gpg --verify SHA256SUMS.asc SHA256SUMS

# Verify tarball hash matches signed checksum AND expected build arg
RUN grep "bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz" SHA256SUMS | \
        sha256sum -c - && \
    echo "${BITCOIN_SHA256}  bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz" | \
        sha256sum -c -

# Install binaries
RUN tar -xzf bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz && \
    install -m 0755 bitcoin-${BITCOIN_VERSION}/bin/* /usr/local/bin/ && \
    rm -rf /tmp/* /root/.gnupg

USER bitcoin

VOLUME ["/home/bitcoin/.bitcoin"]

EXPOSE 8332 8333

ENTRYPOINT ["bitcoind"]