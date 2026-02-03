# docker-bitcoind

Minimal Docker image for running Bitcoin Core (`bitcoind`) with signature and checksum verification during build.

## What's included
- Debian trixie-slim base
- Bitcoin Core binaries installed into `/usr/local/bin`
- Non-root `bitcoin` user
- Data directory volume at `/home/bitcoin/.bitcoin`
- RPC and P2P ports exposed (8332, 8333)

## Build

```sh
docker build -t docker-bitcoind .
```

To build a different Bitcoin Core release (and its expected SHA256):

```sh
docker build \
  --build-arg BITCOIN_VERSION=30.2 \
  --build-arg BITCOIN_SHA256=6aa7bb4feb699c4c6262dd23e4004191f6df7f373b5d5978b5bcdd4bb72f75d8 \
  -t docker-bitcoind .
```

## Run

```sh
docker run --rm \
  -p 8332:8332 \
  -p 8333:8333 \
  -v bitcoind-data:/home/bitcoin/.bitcoin \
  docker-bitcoind
```

To pass custom `bitcoind` flags:

```sh
docker run --rm \
  -p 8332:8332 \
  -p 8333:8333 \
  -v bitcoind-data:/home/bitcoin/.bitcoin \
  docker-bitcoind \
  -printtoconsole \
  -rpcuser=bitcoin \
  -rpcpassword=change-me
```

## Example bitcoin.conf

Create a local config file:

```ini
server=1
printtoconsole=1
rpcuser=bitcoin
rpcpassword=change-me
rpcallowip=0.0.0.0/0
```

Mount it into the container:

```sh
docker run --rm \
  -p 8332:8332 \
  -p 8333:8333 \
  -v bitcoind-data:/home/bitcoin/.bitcoin \
  -v "$PWD/bitcoin.conf:/home/bitcoin/.bitcoin/bitcoin.conf:ro" \
  docker-bitcoind
```

## Notes
- The image verifies the signed `SHA256SUMS` and also checks the tarball hash against the `BITCOIN_SHA256` build arg.
- The container runs as the non-root `bitcoin` user.
