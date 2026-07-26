We pre-compile FTL for you to save you the trouble of compiling anything yourself. However, sometimes you may want to make your own modifications. To test them, you have to compile FTL from source. Luckily, you don't have to be a programmer to build FTL from source and install it on your system; you only have to know the basics we provide in here. With just a few commands, you can build FTL from source like a pro.

!!! note
    These instructions follow FTL's `development` branch - the code the next release is built from. They are not guaranteed to match the current `master` branch or older releases, whose build dependencies can differ (for example, `master` still links mbedTLS while `development` has moved to OpenSSL). If you are building a different branch and something does not line up, just ask us - we are happy to help with the specifics.

# Install native build environment

This will install all necessary tools to build FTL directly in your host operating system. It is usually the easiest solution and works with all editors available.

## Installing the Required Software

First, we'll install the basic software you'll need to compile from source, like the GCC compiler and other utilities.
Install them by running the following command in a terminal:

### Debian / Ubuntu / Raspbian

```bash
sudo apt install git wget ca-certificates build-essential libgmp-dev m4 cmake libidn2-dev libunistring-dev libreadline-dev xxd
```

### Fedora

```bash
sudo dnf install git wget ca-certificates gcc gmp-devel gmp-static m4 cmake libidn2-devel libunistring-devel readline-devel xxd
```

## Compile `libnettle` from source

FTL uses a cryptographic library (`libnettle`) for handling DNSSEC signatures.
Compile and install a recent version using:

```bash
wget https://ftp.gnu.org/gnu/nettle/nettle-3.10.2.tar.gz
tar -xzf nettle-3.10.2.tar.gz
cd nettle-3.10.2
./configure --libdir=/usr/local/lib --enable-static --disable-shared --disable-openssl --disable-mini-gmp -disable-gcov --disable-documentation
make -j $(nproc)
sudo make install
```

Since Ubuntu 20.04, you need to specify the library directory explicitly. Otherwise, the library will be installed in custom locations where it would not be found by `cmake`.

## Compile `OpenSSL` from source

FTL uses this cryptographic library (OpenSSL) containing cryptographic primitives, X.509 certificate manipulation and the SSL/TLS protocols used for serving the web interface and the API over HTTPS. Build **OpenSSL 4.0** here: it is the version FTL is developed against and the one that provides the native QUIC API the HTTP/3 features rely on.

Compile and install a recent version using:

```bash
wget https://ftl.pi-hole.net/libraries/openssl-4.0.0.tar.gz -O openssl-4.0.0.tar.gz
tar -xzf openssl-4.0.0.tar.gz
cd openssl-4.0.0
./config \
    no-shared no-tests no-docs no-apps \
    no-legacy no-comp no-dtls \
    no-psk no-srp no-idea no-rc2 no-rc4 no-rc5 no-md4 no-mdc2 no-whirlpool \
    no-dso \
    --prefix=/usr/local --libdir=lib --openssldir=/usr/local/ssl
make -j $(nproc)
sudo make install_dev
```

`./config` auto-detects the correct build target for your host, so no per-architecture tuning is needed. The `no-*` options trim the build down to just the static `libssl`/`libcrypto` that FTL links against, dropping the legacy provider, unused protocols and ciphers, and DSO to keep the binary small (`no-ssl3` and `no-engine` are not needed on OpenSSL 4.0 - SSLv3 and the ENGINE API are already removed there). Multi-threading support is enabled by default, so no manual configuration is required. `make install_dev` installs only the headers and static libraries (no `openssl` command-line tool or man pages).

!!! note "Building against an older OpenSSL"
    An older OpenSSL such as 3.5.7 works too, but it lacks the per-connection QUIC peer-address API FTL relies on, so building against it disables the HTTP/3 and QUIC features (HTTP/1.1 and HTTP/2 remain available). Use OpenSSL 4.0 for a feature-complete binary.

## Compile `nghttp2` from source

FTL uses `nghttp2` to serve the web interface and the API over HTTP/2. Compile and install a recent version using:

```bash
wget https://ftl.pi-hole.net/libraries/nghttp2-1.69.0.tar.gz -O nghttp2-1.69.0.tar.gz
tar -xzf nghttp2-1.69.0.tar.gz
cd nghttp2-1.69.0
./configure --enable-lib-only --enable-static --disable-shared
make -j $(nproc)
sudo make install
```

`--enable-lib-only` builds just the `libnghttp2` library FTL links against, skipping the bundled applications and their extra dependencies.

## Compile `nghttp3` from source

FTL uses `nghttp3` together with OpenSSL's native QUIC to serve the web interface and the API over HTTP/3. Compile and install a recent version using:

```bash
wget https://ftl.pi-hole.net/libraries/nghttp3-1.17.0.tar.gz -O nghttp3-1.17.0.tar.gz
tar -xzf nghttp3-1.17.0.tar.gz
cd nghttp3-1.17.0
./configure --enable-lib-only --enable-static --disable-shared
make -j $(nproc)
sudo make install
```

`nghttp2` and `nghttp3` are technically optional - without them FTL still builds and serves the web interface over HTTP/1.1 - but we install both here so the locally built binary is feature-complete and matches the official release (HTTP/1.1, HTTP/2 and, with OpenSSL 4.0, HTTP/3).

## Get the source

Now, clone the FTL repo (or your own fork) to get the source code of FTL:

```bash
git clone https://github.com/pi-hole/FTL.git && cd FTL
```

If you want to build another branch and not `master`, use checkout to get to this branch, like

```bash
git checkout development
```

## Compile the source

FTL can now be compiled using either the build script

```bash
./build.sh
```

or manually

```bash
mkdir -p cmake && cd cmake
cmake ..
cmake --build . -- -j $(nproc)
```

Note that both ways are exactly equivalent and that you do not need `root` privileges here.

## Install the new binary system-wide

Install the new binary using either

```bash
./build.sh install
```

or

```bash
cd cmake && sudo make install
```

Finally, restart FTL to use the new binary:

```bash
sudo service pihole-FTL restart
```

## Caution

Once your homebrew `pihole-FTL` binary is built and installed, do not run `pihole -up` or `pihole checkout`. These commands might overwrite your local `pihole-FTL` binary with Pi-hole's pre-compiled binaries.

# Use containerized build environment

While most people think of [Docker](https://www.docker.com/) as a deployment environment, it's also a wonderful tool to create and maintain build environments. Pi-hole provides `ftl-build` containers composed of everything needed to build FTL for various architectures on your `x86_64` hosts. Check out [Docker Hub `pi-hole/ftl-build`](https://hub.docker.com/r/pihole/ftl-build/tags) for the available build containers as well as the [Releases overview](https://github.com/pi-hole/docker-base-images/releases/) for a detailed changelog.

The `ftl-build` containers can, for instance, easily be used as [`devcontainers`](https://code.visualstudio.com/docs/devcontainers/containers) with Visual Studio Code's [`remote-containers`](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension. The necessary `devcontainer.json` is provided in the FTL repository. See the description of the extension for further details. Note that `./build.sh install` would only install FTL in the container in this case. Instead, you have to copy the FTL binary generated inside the container yourself to the final destination on your installation target.
